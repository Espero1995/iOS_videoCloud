//
//  PublicShareDetailVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/8.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "PublicShareDetailVC.h"
#import "ShareDetailCell_t.h"
#import "ZCTabBarController.h"

//通讯录
#import "SXAddressBookManager.h"
#import <ContactsUI/ContactsUI.h>
#import <AddressBook/AddressBook.h>
#import "WeiCloudListModel.h"
#import "ScottAlertController.h"
#import "UIImage+image.h"
#import "WeiCloudShareView.h"

#import "YALSunnyRefreshControl.h"

@interface PublicShareDetailVC ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UISearchBarDelegate,
    UISearchResultsUpdating,
    UIAlertViewDelegate,
    ShareDetail_tDelegete,
    CNContactPickerDelegate,
    WeiCloudShareViewDelegate
>
{
    long index;
}

/*表视图*/
@property (nonatomic,strong) UITableView * tv_list;
/*搜索控制器*/
@property(nonatomic,strong)UISearchController *searchController;
/*满足搜索条件的数组*/
@property (nonatomic, strong)NSMutableArray  *searchList;
/*都是这个设备分享出去的用户们*/
@property (nonatomic , strong) NSMutableArray *dataArr;

@property (nonatomic,copy) NSMutableString * nameStr;
@property (nonatomic,copy) NSMutableString * userID;
@property (nonatomic,copy) NSMutableString * user_id;

@end

@implementation PublicShareDetailVC

//==========================system==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"分享人列表";
    self.view.backgroundColor = BG_COLOR;
    _nameStr = [NSMutableString string];
    _userID = [NSMutableString string];
    _user_id = [NSMutableString string];
    [self createTableView];
    [self createUI];
    [self cteateNavBtn];
    self.definesPresentationContext=YES;
//    self.dataArr = [NSMutableArray arrayWithArray:self.shareUsersInfo.];
    NSLog(@"%@",self.shareUsersInfo);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    if (self.searchController.active) {
        self.searchController.active = NO;
        [self.searchController.searchBar removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//==========================init==========================
#pragma mark ------创建tableview
// 创建tableView
-(void)createTableView{
    self.tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, self.view.width, self.view.height-50-64) style:UITableViewStylePlain];
    //设置代理
    self.tv_list.delegate = self;
    self.tv_list.dataSource = self;
    self.tv_list.backgroundColor = BG_COLOR;
    UIView *footView = [[UIView alloc]init];
    self.tv_list.tableFooterView = footView;
    [self.view addSubview:self.tv_list];
}

- (void)createUI{
    _searchController = [[UISearchController  alloc]initWithSearchResultsController:nil];
    //设置背景不透明
    _searchController.searchBar.barTintColor = [UIColor colorWithHexString:@"#f1f1f1"];
    //设置searchbar的边框颜色和背景颜色一致
    _searchController.searchBar.layer.borderWidth = 1;
    _searchController.searchBar.layer.borderColor = [[UIColor colorWithHexString:@"#f1f1f1"] CGColor];
    _searchController.searchBar.placeholder = @"搜索";
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = NO;
    
    _searchController.searchBar.frame = CGRectMake(0, 0, iPhoneWidth, 50);
    [self.view addSubview:_searchController.searchBar];

}

//==========================method==========================

//==========================delegate==========================
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.searchController.active) {
        return self.searchList.count;
    }
    return self.dataArr.count;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * str = @"Cell";
    ShareDetailCell_t * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [[ShareDetailCell_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    
    if (self.searchController.active) {
        shared *listModel = [shared mj_objectWithKeyValues:self.searchList[indexPath.row]];
        if (![listModel.remarks isEqualToString:@""]) {
            cell.remarkNameLb.text = listModel.remarks;
        }else{
            cell.remarkNameLb.text = listModel.name;
        }
        cell.mobileLb.text = [NSString stringWithFormat:@"手机号:%@",[listModel.mobile stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]];
    }else{
        shared *listModel = [shared mj_objectWithKeyValues:self.dataArr[indexPath.row]];
        if (![listModel.remarks isEqualToString:@""]) {
            cell.remarkNameLb.text = listModel.remarks;
        }else{
            cell.remarkNameLb.text = listModel.name;
        }
        cell.mobileLb.text = [NSString stringWithFormat:@"手机号:%@",[listModel.mobile stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]];
    }
    
    cell.delegete = self;
    cell.headImage.image = [UIImage imageNamed:@"myhead"];
    return cell;
    
}
//cell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark ----- 取消设备分享
- (void)ShareDetail_tCancleBtnClick:(ShareDetailCell_t *)cell{
    NSIndexPath * indexpath = [self.tv_list indexPathForCell:cell];
    index = indexpath.row;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"取消分享设备"message:@"确定取消分享设备给该用户?"preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}



#pragma mark ----- searchBarDelegate
//每输入一个字符都会执行一次
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = [self.searchController.searchBar text];
    //谓词搜索
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[c] %@", searchString];
    
    if (self.searchList!= nil) {
        [self.searchList removeAllObjects];
    }
    //过滤数据
    self.searchList= [NSMutableArray arrayWithArray:[self.dataArr filteredArrayUsingPredicate:preicate]];
    //刷新表格
    [self.tv_list reloadData];
    
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    for (id obj in [searchBar subviews]) {
        if ([obj isKindOfClass:[UIView class]]) {
            for (id obj2 in [obj subviews]) {
                if ([obj2 isKindOfClass:[UIButton class]]) {
                    UIButton *btn = (UIButton *)obj2;
                    [btn setTitle:@"取消" forState:UIControlStateNormal];
                }
            }
        }
    }
    return YES;
}
//==========================lazy loading==========================
#pragma mark ----- 懒加载
- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
