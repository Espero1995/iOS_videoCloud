//
//  MyShareController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/6.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "MyShareController.h"
#import "ShareDetailController.h"
#import "MyShareCell_t.h"
#import "MyShareModel.h"
#import "YALSunnyRefreshControl.h"
@interface MyShareController ()
<
    UITableViewDataSource,
    UITableViewDelegate
>

@property (nonatomic,strong) NSMutableArray * detailArr;
@property (nonatomic,copy) NSMutableString * dev_id;

@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) NSMutableArray * dataArray;
/*刷新控件*/
@property (nonatomic,strong) YALSunnyRefreshControl *sunnyRefreshControl;
@end

@implementation MyShareController
//==========================system==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    _dev_id = [NSMutableString string];
    [self createTableView];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    [header beginRefreshing];
    self.tableView.mj_header = header;
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
    
}

-(void)setupRefreshControl{
    self.sunnyRefreshControl = [YALSunnyRefreshControl attachToScrollView:self.tableView
                                                                   target:self
                                                            refreshAction:@selector(sunnyControlDidStartAnimation)];
    
}


//==========================method==========================
#pragma mark ------加载数据
- (void)loadData
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/share/to-others" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            [self.dataArray removeAllObjects];
            self.dataArray = [MyShareModel mj_objectArrayWithKeyValuesArray:responseObject[@"body"][@"shared"]];
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
    MyShareCell_t * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [[MyShareCell_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    
    MyShareModel * model = self.dataArray[indexPath.row];
    cell.NameLabel.text = model.name;
    cell.MessageLabel.text = [NSString stringWithFormat:@"%@:%lu%@",NSLocalizedString(@"已分享", nil),(unsigned long)model.userList.count,NSLocalizedString(@"人", nil)];
    cell.headImage.image = [UIImage imageNamed:@"sharedBg"];

    return cell;
    
}

//cell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    MyShareCell_t * cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ShareDetailController * shareDetailVC = [[ShareDetailController alloc]init];
    MyShareModel *model = self.dataArray[indexPath.row];
    shareDetailVC.dev_id = model.deviceID;
    [self.navigationController pushViewController:shareDetailVC animated:YES];
}


#pragma mark - TableView 占位图
- (UIImage *)xy_noDataViewImage {
    return [UIImage imageNamed:@"content_not"];
}

- (NSString *)xy_noDataViewMessage {
    return NSLocalizedString(@"你还没有分享过任何设备", nil);
}

- (NSNumber *)xy_noDataViewCenterYOffset
{
    return @10;
}


//==========================lazy loading==========================
#pragma mark - getter && setter
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (NSMutableArray *)detailArr
{
    if (!_detailArr) {
        _detailArr = [NSMutableArray array];
    }
    return _detailArr;
}

@end
