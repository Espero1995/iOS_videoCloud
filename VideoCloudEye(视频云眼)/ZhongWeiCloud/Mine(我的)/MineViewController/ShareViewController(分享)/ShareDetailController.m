//
//  ShareDetailController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/6.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "ShareDetailController.h"
#import "ShareDetailCell_t.h"
#import "ZCTabBarController.h"

//通讯录
#import "SXAddressBookManager.h"
#import <ContactsUI/ContactsUI.h>
#import <AddressBook/AddressBook.h>
#import "WeiCloudListModel.h"
#import "ScottAlertController.h"
#import "UIImage+image.h"
#import "YALSunnyRefreshControl.h"
@interface ShareDetailController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UISearchBarDelegate,
    UISearchResultsUpdating,
    UIAlertViewDelegate,
    ShareDetail_tDelegete,
    CNContactPickerDelegate
>
{
    long index;
}

@property (nonatomic,strong) UITableView * tableView;

@property (nonatomic,copy) NSMutableString * nameStr;

@property (nonatomic,copy) NSMutableString * userID;

@property (nonatomic,copy) NSString * user_id;
/*手机号*/
@property (nonatomic,copy)NSString *iphoneNumberStr;
/*分享的数据*/
@property (nonatomic,strong)dev_list *shareModel;

/*搜索控制器*/
@property(nonatomic,strong) UISearchController *searchController;
/*满足搜索条件的数组*/
@property (strong, nonatomic)NSMutableArray  *searchList;
/*刷新控件*/
@property (nonatomic,strong) YALSunnyRefreshControl *sunnyRefreshControl;
@end

@implementation ShareDetailController

//==========================system==========================
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    [self.videoManage stopCloudPlay];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    if (self.searchController.active) {
        self.searchController.active = NO;
        [self.searchController.searchBar removeFromSuperview];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"分享人列表", nil);
    self.view.backgroundColor = BG_COLOR;
    _nameStr = [NSMutableString string];
    _userID = [NSMutableString string];
    _user_id = [NSMutableString string];
    [self cteateNavBtn];
    [self createUI];
    [self createTableView];
    self.definesPresentationContext=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//==========================init==========================
- (void)createUI{
    _searchController = [[UISearchController  alloc]initWithSearchResultsController:nil];
    //设置背景不透明
    _searchController.searchBar.translucent = NO;
    _searchController.searchBar.barTintColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:241/255.0 alpha:1.0];
    //设置searchbar的边框颜色和背景颜色一致
    _searchController.searchBar.layer.borderWidth = 1;
    _searchController.searchBar.layer.borderColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:241/255.0 alpha:1.0].CGColor;
    _searchController.searchBar.placeholder = NSLocalizedString(@"搜索", nil);
    _searchController.searchResultsUpdater = self;
    _searchController.dimsBackgroundDuringPresentation = NO;
    
    _searchController.searchBar.frame = CGRectMake(0, 0, iPhoneWidth, 54);
    [self.view addSubview:_searchController.searchBar];
}

#pragma mark ------创建tableview
// 创建tableView
-(void)createTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    //设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = BG_COLOR;
    UIView *footView = [[UIView alloc]init];
    self.tableView.tableFooterView = footView;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(54);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.width.mas_equalTo(iPhoneWidth);
    }];
    
    
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getShareDeviceList)];
    [header beginRefreshing];
    self.tableView.mj_header = header;
    
    
}
-(void)setupRefreshControl{
    self.sunnyRefreshControl = [YALSunnyRefreshControl attachToScrollView:self.tableView
                                                                   target:self
                                                            refreshAction:@selector(sunnyControlDidStartAnimation)];
    
}


//==========================method==========================
- (void)getShareDeviceList{

    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:_dev_id forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/share/device-shared-info" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            [self.dataArr removeAllObjects];
            MyShareModel *listModel = [MyShareModel mj_objectWithKeyValues:responseObject[@"body"]];
            NSArray *tempArr = [shared mj_objectArrayWithKeyValuesArray:listModel.userList];
            for (int i = 0; i<tempArr.count; i++) {
                shared *model = tempArr[i];
                if ([NSString isNull:model.remarks]) {
                    model.remarks = model.name;
                }
                [self.dataArr addObject:model];
            }
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }
        else{
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.tableView.mj_header endRefreshing];
    }];

}

//取消分享
- (void)cancelShareDevice{
    NSMutableDictionary * guardDic = [NSMutableDictionary dictionary];
    [guardDic setObject:_dev_id forKey:@"dev_id"];
    [guardDic setObject:_user_id forKey:@"shared_user"];

    [[HDNetworking sharedHDNetworking]POST:@"v1/device/share/delete" parameters:guardDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"取消分享成功");
        int ret = [responseObject[@"ret"]intValue];
        NSLog(@"ret=%d",ret);
        if (ret == 0) {
            if (self.searchController.active) {
                [self.searchList removeObjectAtIndex:index];
            }
            [self.dataArr removeObjectAtIndex:index];
            [self.tableView reloadData];
        }

    } failure:^(NSError * _Nonnull error) {
        NSLog(@"取消分享失败");
    }];
}



-(void)sunnyControlDidStartAnimation{
    [self performSelector:@selector(getShareDeviceList) withObject:nil afterDelay:2];
}
//结束下拉刷新
-(IBAction)endAnimationHandle{
    [self.sunnyRefreshControl endRefreshing];
}
//上拉刷新响应
- (void)loadMoreData
{
    [self performSelector:@selector(endUpRefresh) withObject:nil afterDelay:2];
}
- (void)endUpRefresh
{
    [self.tableView.mj_footer endRefreshing];
}

//==========================delegate==========================
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
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
    return _dataArr.count;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * str = @"Cell";
    ShareDetailCell_t * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [[ShareDetailCell_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    if (self.searchController.active) {
        shared *listModel = self.searchList[indexPath.row];
        if (![listModel.remarks isEqualToString:@""]) {
            cell.remarkNameLb.text = listModel.remarks;
        }else{
            cell.remarkNameLb.text = listModel.name;
        }
        if ([NSString isNull:listModel.mobile]) {
            cell.mobileLb.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"邮箱", nil),listModel.mail];
        }else{
            cell.mobileLb.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"手机号码", nil),[listModel.mobile stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]];
        }
    }else{
        shared *listModel = self.dataArr[indexPath.row];
        if (![listModel.remarks isEqualToString:@""]) {
            cell.remarkNameLb.text = listModel.remarks;
        }else{
            cell.remarkNameLb.text = listModel.name;
        }
        if ([NSString isNull:listModel.mobile]) {
            cell.mobileLb.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"邮箱", nil),listModel.mail];
        }else{
            cell.mobileLb.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"手机号码", nil),[listModel.mobile stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"]];
        }
    }
    
    cell.delegete = self;
    cell.headImage.image = [UIImage imageNamed:@"myhead"];
    return cell;
    
}

//cell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)ShareDetail_tCancelBtnClick:(ShareDetailCell_t *)cell{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (self.searchController.active) {
        shared *listModel = self.searchList[indexPath.row];
        _user_id = listModel.ID;
    }else{
        shared *listModel = self.dataArr[indexPath.row];
        _user_id = listModel.ID;
    }
    NSIndexPath * indexpath = [self.tableView indexPathForCell:cell];
    index = indexpath.row;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"取消分享设备", nil) message:NSLocalizedString(@"确定取消分享设备给该用户？", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self cancelShareDevice];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

//区头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0001;
}

//区头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 0.0001)];
    backView.backgroundColor = BG_COLOR;
    return backView;
}

//每输入一个字符都会执行一次
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    self.edgesForExtendedLayout = UIRectEdgeAll;
    NSString *searchString = [self.searchController.searchBar text];
    //谓词搜索
    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF.remarks CONTAINS[c] %@", searchString];
    
    if (self.searchList!= nil) {
        [self.searchList removeAllObjects];
    }
    //过滤数据
    self.searchList= [NSMutableArray arrayWithArray:[_dataArr filteredArrayUsingPredicate:preicate]];
    //刷新表格
    [self.tableView reloadData];
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    for (id obj in [searchBar subviews]) {
        if ([obj isKindOfClass:[UIView class]]) {
            for (id obj2 in [obj subviews]) {
                if ([obj2 isKindOfClass:[UIButton class]]) {
                    UIButton *btn = (UIButton *)obj2;
                    [btn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
                }
            }
        }
    }
    return YES;
}


#pragma mark - TableView 占位图
- (UIImage *)xy_noDataViewImage {
    return [UIImage imageNamed:@"noContent"];
}

- (NSString *)xy_noDataViewMessage {
    return NSLocalizedString(@"未找到相应的联系人", nil);
}

- (NSNumber *)xy_noDataViewCenterYOffset
{
    return @10;
}

//==========================lazy loading==========================
#pragma mark - getter && setter
- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
