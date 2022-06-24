//
//  OperationLogController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/9/26.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "OperationLogController.h"
#import "OperationLog_t.h"
#import "ZCTabBarController.h"
#import "LogModel.h"

#define CELL @"mineCell_t"
#define OUTCELL @"mineOutCell_t"
@interface OperationLogController ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
//tableview
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)UIView * headView;
@property (nonatomic,strong)NSMutableArray * logListArr;
@end

@implementation OperationLogController
//----------------------------------------system----------------------------------------
- (void)viewDidLoad {
    self.logListArr = [NSMutableArray array];
    [super viewDidLoad];
    [self getLogData];
//    [self setNav];
    [self cteateNavBtn];
    [self createHeadView];
    [self setUpUI];
}
#pragma mark ------UI
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    [self.tableView.mj_header beginRefreshing];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBarTintColor:[UIColor blueColor]];
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#feffff"];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    HDNetworking *manager = [[HDNetworking alloc] init];
    [manager canleAllHttp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//----------------------------------------init----------------------------------------
- (void)setUpUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, iPhoneHeight-64) style:UITableViewStylePlain];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.tableHeaderView = _headView;
    UIView *footView = [[UIView alloc]init];
    self.tableView.tableFooterView = footView;
    [self.view addSubview:self.tableView];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getLogData)];
    [header beginRefreshing];
    self.tableView.mj_header = header;
}

- (void)createHeadView{
    _headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 100)];
    _headView.backgroundColor = [UIColor blueColor];
    UILabel * nameLabel = [FactoryUI createLabelWithFrame:CGRectMake(20, 16, 300, 21) text:@"操作日志记录" font:[UIFont systemFontOfSize:21]];
    nameLabel.textColor = [UIColor colorWithHexString:@"#feffff"];
    [_headView addSubview:nameLabel];
    UILabel * timeLabel = [FactoryUI createLabelWithFrame:CGRectMake(20, 49, 300, 14) text:nil font:[UIFont systemFontOfSize:15]];
    timeLabel.textColor = [UIColor colorWithHexString:@"#feffff"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    timeLabel.text = dateTime;
    [_headView addSubview:timeLabel];
    UIImageView * backImage = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 80, 70) imageName:@"op_log_img"];
    [_headView addSubview:backImage];
    [backImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_headView.mas_right).offset(-12);
        make.bottom.equalTo(_headView.mas_bottom).offset(-8);
        make.height.equalTo(@(70));
        make.width.equalTo(@(80));
    }];
}

//----------------------------------------method----------------------------------------
- (void)endUpRefresh
{
    [self.tableView.mj_footer endRefreshing];
}

- (void)getLogData{
    //    计算现在距1970年多少秒
    NSDate *date = [NSDate date];
    NSTimeInterval currentTime = [date timeIntervalSince1970];
    NSTimeInterval lastTime = currentTime - 2592000;
    int stop_time = currentTime;
    NSNumber * stop = [NSNumber numberWithInt:stop_time];
    int start_time = lastTime;
    NSNumber * start = [NSNumber numberWithInt:start_time];
    NSMutableDictionary * logDic = [NSMutableDictionary dictionary];
    [logDic setObject:start forKey:@"start_time"];
    [logDic setObject:stop forKey:@"stop_time"];
    [logDic setObject:@"0" forKey:@"offset"];
    [logDic setObject:@"100" forKey:@"limit"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/oplog/list" parameters:logDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        NSLog(@"%d",ret);
        if (ret == 0) {
            LogModel * logListModel = [LogModel mj_objectWithKeyValues:responseObject[@"body"]];
            self.logListArr = [NSMutableArray arrayWithArray:logListModel.opLogList];
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }else{
            [self.tableView.mj_header endRefreshing];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.tableView.mj_header endRefreshing];
    }];
    
}

- (void)cteateNavBtn{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"return"] style:UIBarButtonItemStylePlain target:self action:@selector(returnVC)];
    // 设置返回图片颜色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

//返回上一页
- (void)returnVC{
    [self.navigationController popViewControllerAnimated:YES];
}

//----------------------------------------delegate----------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.logListArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * str1 = @"Cell";
    OperationLog_t * cell = [tableView dequeueReusableCellWithIdentifier:str1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(!cell){
        cell = [[OperationLog_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str1];
    }
    if (self.logListArr.count!=0) {
        opLogList * logModel = self.logListArr[indexPath.row];
        cell.model = logModel;
    }
//    cell.dateLabel.text = @"9-26";
//    cell.timeLabel.text = @"16:46:30";
//    cell.conLabel.text = @"用户登录";
//    cell.logLabel.text = @"用户admin登录ip为151.0.10.122的设备";
//    cell.ipLabel.text = @"中国浙江杭州 (10.151.0.132)";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
