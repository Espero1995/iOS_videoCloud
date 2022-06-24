//
//  SharetoPoliceVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/6.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "SharetoPoliceVC.h"
#import "YALSunnyRefreshControl.h"
#import "PublicShareDetailVC.h"
#import "PublicShareCell_t.h"
#import "MyShareModel.h"
/*无内容是显示视图*/
#import "EmptyDataBGView.h"
@interface SharetoPoliceVC ()
<
    UITableViewDataSource,
    UITableViewDelegate
>
@property (nonatomic,copy) NSMutableString * dev_id;

@property (nonatomic,strong) UITableView * tv_list;
@property (nonatomic,strong) NSMutableArray * dataArray;
//无内容时背景图
@property (nonatomic,strong)EmptyDataBGView *bgView;
/*刷新控件*/
@property (nonatomic,strong) YALSunnyRefreshControl *sunnyRefreshControl;
@end

@implementation SharetoPoliceVC
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
    self.tv_list.mj_header = header;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//==========================init==========================
#pragma mark ------创建tableview
// 创建tableView
-(void)createTableView{
    self.tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-40-iPhoneNav_StatusHeight) style:UITableViewStylePlain];
    
    //设置代理
    self.tv_list.delegate = self;
    self.tv_list.dataSource = self;
    self.tv_list.backgroundColor = BG_COLOR;
    UIView *footView = [[UIView alloc]init];
    self.tv_list.tableFooterView = footView;
    [self.view addSubview:self.tv_list];
  
}
-(void)setupRefreshControl{
    self.sunnyRefreshControl = [YALSunnyRefreshControl attachToScrollView:self.tv_list
                                                                   target:self
                                                            refreshAction:@selector(sunnyControlDidStartAnimation)];
    
}
//==========================method==========================
#pragma mark ------加载数据
- (void)loadData
{
    /*
     *  description : GET  v1/device/share/to-public(获取共享给公共用户列表)
     *  param : access_token=<令牌> & user_id=<用户ID>
     */
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults objectForKey:@"user_id"];
    [dic setObject:userID forKey:@"user_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/share/to-public" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            [self.dataArray removeAllObjects];
            MyShareModel *listModel = [MyShareModel mj_objectWithKeyValues:responseObject[@"body"]];
            self.dataArray = [NSMutableArray arrayWithArray:listModel.userList];
            [self.tv_list reloadData];
            if (self.dataArray.count == 0) {
                [self.view addSubview:self.bgView];
            }else{
                [self.bgView removeFromSuperview];
            }
            [self.tv_list.mj_header endRefreshing];
        }
        else{
            [self.tv_list reloadData];
            [self.tv_list.mj_header endRefreshing];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.view addSubview:self.bgView];
        [self.tv_list.mj_header endRefreshing];
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
    [self.tv_list.mj_footer endRefreshing];
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
    static NSString * MyShareCellStr = @"MyShareCellStr";
    PublicShareCell_t * cell = [tableView dequeueReusableCellWithIdentifier:MyShareCellStr];
    if(!cell){
        cell = [[PublicShareCell_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyShareCellStr];
    }

        shared * model = self.dataArray[indexPath.row];
        cell.idLabel.text = model.ID;
        [cell setModel:model];
        cell.headImage.image = [UIImage imageNamed:@"sharedBg"];

    return cell;
}
//cell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    PublicShareDetailVC * detailVC = [[PublicShareDetailVC alloc]init];
//    shared * model = self.dataArray[indexPath.row];
//    detailVC.shareUsersInfo = model;
//    [self.navigationController pushViewController:detailVC animated:YES];
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

//无内容时的背景图
-(EmptyDataBGView *)bgView{
    if (!_bgView) {
        _bgView = [[EmptyDataBGView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-64-44-40) bgColor:BG_COLOR bgImg:[UIImage imageNamed:@"content_not"] bgTip:NSLocalizedString(@"您还没有分享过任何设备给公安机关", nil)];
    }
    return _bgView;
}
@end
