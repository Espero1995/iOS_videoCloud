//
//  OtherShareController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/6.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "OtherShareController.h"
#import "YALSunnyRefreshControl.h"
#import "OtherShareCell_t.h"
#import "OtherShareModel.h"
@interface OtherShareController ()
<
UITableViewDataSource,
UITableViewDelegate,
otherShareDelegate
>

@property (nonatomic,strong) UITableView * tableView;

@property (nonatomic,strong) NSMutableArray * dataArray;

/*刷新控件*/
@property (nonatomic,strong) YALSunnyRefreshControl *sunnyRefreshControl;


@end

@implementation OtherShareController
//==========================system==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTableView];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//==========================init==========================
#pragma mark ------创建tableview
// 创建tableView
-(void)createTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-40-iPhoneNav_StatusHeight) style:UITableViewStylePlain];
    
    //设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = BG_COLOR;
    UIView *footView = [[UIView alloc]init];
    self.tableView.tableFooterView = footView;
    
    [self.view addSubview:self.tableView];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    [header beginRefreshing];
    self.tableView.mj_header = header;
}
-(void)setupRefreshControl{
    self.sunnyRefreshControl = [YALSunnyRefreshControl attachToScrollView:self.tableView
                                                                   target:self
                                                            refreshAction:@selector(sunnyControlDidStartAnimation)];
    
}

- (void)cancelShareBtnClick:(OtherShareCell_t *)cell
{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    others_shared * model = self.dataArray[indexPath.row];
    
    [self createAlert:model];
}

//==========================method==========================
#pragma mark ------加载数据
- (void)loadData
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/share/from-others" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            [self.dataArray removeAllObjects];
            OtherShareModel *listModel = [OtherShareModel mj_objectWithKeyValues:responseObject[@"body"]];
            self.dataArray = [NSMutableArray arrayWithArray:listModel.others_shared];
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }
        else{
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }
        
    } failure:^(NSError * _Nonnull error) {
        if (self.dataArray.count == 0) {
            [self.tableView reloadData];
        }
        [self.tableView.mj_header endRefreshing];
    }];
}

-(void)sunnyControlDidStartAnimation{
    [self performSelector:@selector(loadData) withObject:nil afterDelay:2];
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


//退出按钮警告框
- (void)createAlert:(others_shared *)shared{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"是否确认取消他人对您分享的设备？", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        //    NSLog(@"点击了%@来取消别人分享",model.name);
        NSDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        [dic setValue:userModel.user_id forKey:@"user_id"];
        [dic setValue:shared.ID forKey:@"dev_id"];
        
        
        [[HDNetworking sharedHDNetworking] POST:@"v1/device/share/cancelFromOthers" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
            NSLog(@"respinseObject:%@",responseObject);
            [self loadData];
            [self.tableView reloadData];
            
        } failure:^(NSError * _Nonnull error) {
            
        }];
        
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


//==========================delegate==========================
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * str = @"Cell";
    OtherShareCell_t * cell = [tableView dequeueReusableCellWithIdentifier:str];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    if(!cell){
        cell = [[OtherShareCell_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
        others_shared * model = self.dataArray[indexPath.row];
        [cell setModel:model];
    
    return cell;
    
}

//cell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - TableView 占位图
- (UIImage *)xy_noDataViewImage {
    return [UIImage imageNamed:@"content_not"];
}

- (NSString *)xy_noDataViewMessage {
    return NSLocalizedString(@"别人还没对你分享过设备", nil);
}

- (NSNumber *)xy_noDataViewCenterYOffset
{
    return @10;
}

//==========================lazy loading==========================
#pragma mark ----- 懒加载
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
