//
//  bigScreenChannelVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/10/17.
//  Copyright © 2019 苏旋律. All rights reserved.
//
#define LeftSpace 7
#define  headViewHeight iPhoneWidth/4
#define BIGCHANNELCELL @"bigScreenChannelCell"
#import "bigScreenChannelVC.h"
//========Model========
/*刷新的控件*/
#import "UIImage+image.h"
/*通道的model*/
#import "ChannelCodeListModel.h"
/*能力集信息*/
#import "FeatureModel.h"
//========View========
/*轮播图*/
#import "SDCycleScrollView.h"
/*设备cell*/
#import "bigScreenChannelCell.h"

//========VC========
/*工具栏*/
#import "ZCTabBarController.h"
/*通道实时单屏*/
#import "RealTimeChannelVC.h"
/*录像回放*/
#import "ChannelPlayBackVC.h"

/*告警消息列表*/
#import "AlarmMsgVC.h"
@interface bigScreenChannelVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    bigChannelCellDelegate,
    SDCycleScrollViewDelegate
>

/*表视图*/
@property (nonatomic,strong) UITableView *tv_list;
/*数据源*/
@property (nonatomic,strong) NSMutableArray *dataArr;
/*截图*/
@property (nonatomic,strong) UIImage *cutImage;
/*刷新*/
@property (nonatomic,assign) BOOL refresh;
@property (nonatomic,strong) ChannelCodeListModel * channelModel;

/*能力集信息的model*/
@property (nonatomic,strong)FeatureModel *feature;

/*头视图：轮播图*/
@property (nonatomic, strong) UIView *headView;

@end

@implementation bigScreenChannelVC

//=========================system=========================
- (void)viewDidLoad {
    [super viewDidLoad];
    //能力集合model初始化
    self.feature = [[FeatureModel alloc]init];
    self.view.backgroundColor = BG_COLOR;
    [self setUpUI];//表视图布局
    [self setupTitleScrollView];//广告
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    //截图
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updataCutImageWithID:) name:UpDataCutImageWithID object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tv_list.mj_header endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//=========================init=========================
// 添加顶部的标题滚动视图
- (void)setupTitleScrollView
{
    UIView * ScrollBackView = [[UIView alloc]initWithFrame:CGRectMake(LeftSpace, 7, iPhoneWidth-14, headViewHeight)];
    ScrollBackView.backgroundColor = [UIColor clearColor];
    ScrollBackView.layer.masksToBounds = YES;
    ScrollBackView.layer.cornerRadius = 4.f;
    [self.headView addSubview:ScrollBackView];
    //加载本地的广告资源
    UIImage *placeholder2 = [UIImage imageNamed:NSLocalizedString(@"banner2", nil)];
    UIImage *placeholder3 = [UIImage imageNamed:NSLocalizedString(@"banner3", nil)];
    NSMutableArray *imaGroup = [NSMutableArray arrayWithObjects:placeholder2,placeholder3, nil];
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, iPhoneWidth-14, headViewHeight) delegate:self placeholderImage:placeholder2];//placeholder1
    cycleScrollView.localizationImageNamesGroup = imaGroup;
    cycleScrollView.pageControlBottomOffset = -8;
    [ScrollBackView addSubview:cycleScrollView];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [dic setValue:userModel.access_token forKey:@"access_token"];
        [dic setValue:userModel.user_id forKey:@"user_id"];
    }
    if (isSimplifiedChinese) {
        [dic setValue:@"10000" forKey:@"data_key"];
    }else{
        [dic setValue:@"20000" forKey:@"data_key"];
    }
    [[HDNetworking sharedHDNetworking]GET:@"v1/user/pubdata/get" parameters:dic success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSMutableString *jsonDataString=[NSMutableString string];
            NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
            jsonDataString = responseObject[@"body"][@"pub_data"][@"top_banner"];
            BaseUrlModel *urlModel = [BaseUrlDefaults geturlModel];
            if (((NSArray *)jsonDataString).count > 0) {
                for (int i = 1; i<((NSArray *)jsonDataString).count; i++) {//0
                    [tempArr addObject:[NSString stringWithFormat:@"%@%@",urlModel.bannerBaseUrl,((NSArray *)jsonDataString)[i]]];
                }
                NSMutableArray *imaGroup = [NSMutableArray arrayWithCapacity:0];
                for (int i =0; i<tempArr.count; i++) {
                    NSURL *picUrl = [NSURL URLWithString:tempArr[i]];
                    UIImage *placeholder =[[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:picUrl]];
                    if (placeholder) {
                        [imaGroup addObject:placeholder];
                    }
                }
                NSURL * picUrl0 = [NSURL URLWithString:tempArr[0]];
                UIImage *placeholder1 =[[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:picUrl0]];
                SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, iPhoneWidth-14, headViewHeight) delegate:self placeholderImage:placeholder1];
                cycleScrollView.backgroundColor = BG_COLOR;
                cycleScrollView.localizationImageNamesGroup = imaGroup;
                cycleScrollView.pageControlBottomOffset = -8;
                [ScrollBackView addSubview:cycleScrollView];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        //加载本地的广告资源
        UIImage *placeholder2 = [UIImage imageNamed:NSLocalizedString(@"banner2", nil)];
        UIImage *placeholder3 = [UIImage imageNamed:NSLocalizedString(@"banner3", nil)];
        NSMutableArray *imaGroup = [NSMutableArray arrayWithObjects:placeholder2,placeholder3, nil];//placeholder1,
        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, iPhoneWidth-14, headViewHeight) delegate:self placeholderImage:placeholder2];
        cycleScrollView.backgroundColor = BG_COLOR;
        cycleScrollView.localizationImageNamesGroup = imaGroup;
        cycleScrollView.pageControlBottomOffset = -8;
        [ScrollBackView addSubview:cycleScrollView];
    }];
}
//初始化页面布局
- (void)setUpUI{
    //表视图布局
    [self.view addSubview:self.tv_list];
    [self.tv_list mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(-iPhoneToolBarHeight);
        make.width.mas_equalTo(iPhoneWidth);
    }];
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadPublicListData)];
    [header beginRefreshing];
    self.tv_list.mj_header = header;
}


//=========================method=========================
#pragma mark -----网络加载公共设备数据信息
- (void)loadPublicListData
{
    _refresh = NO;
    [self.dataArr removeAllObjects];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.nodeId forKey:@"nodeId"];
    [[HDNetworking sharedHDNetworking]GET:@"open/deviceTree/listNodeChanCodesGroup" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"公共设备信息:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSArray *deviceGroup = responseObject[@"body"][@"deviceGroup"];
            if (deviceGroup.count != 0) {
                NSArray *channelCodeList = deviceGroup[0][@"channelCodeList"];
                self.dataArr = [ChannelCodeListModel mj_objectArrayWithKeyValuesArray:channelCodeList];
            }
            [self.tv_list reloadData];
            [self.tv_list.mj_header endRefreshing];
        }
        else{
            [self.tv_list reloadData];
            [self.tv_list.mj_header endRefreshing];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.tv_list reloadData];
        [self.tv_list.mj_header endRefreshing];
    }];
}

#pragma mark -----截图方法
- (UIImage*)getSmallImageWithUrl:(NSString*)imageUrl AtDirectory:(NSString*)directory ImaNameStr:(NSString *)nameStr
{
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取路径
    //1、拼接目录
    NSString *path = [NSHomeDirectory() stringByAppendingString:directory];
    NSString* savePath = [path stringByAppendingString:[NSString stringWithFormat:@"%@.jpg",nameStr]];
    [fileManager changeCurrentDirectoryPath:savePath];
    UIImage *cutIma =  [[UIImage alloc]initWithContentsOfFile:savePath];
    
    return cutIma;
}
- (void)updataCutImageWithID:(NSNotification *)noti
{
   if (noti) {
        NSString * cutImageID = [noti.userInfo objectForKey:@"updataImageID"];
        NSIndexPath * index = [noti.userInfo objectForKey:@"selectedIndex"];//Documents/CutImage
        UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:cutImageID];
        dispatch_async(dispatch_get_main_queue(), ^{
            bigScreenChannelCell *cell = [self.tv_list cellForRowAtIndexPath:index];
            cell.ima_photo.image = cutIma;
        });
    }
}

//截图保存并返回显示
- (void)saveSmallImageWithImage:(UIImage*)image Url:(NSString*)imageUrl AtDirectory:(NSString*)directory ImaNameStr:(NSString *)imaNameStr
{
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //1、拼接目录
    NSString *path = [NSHomeDirectory() stringByAppendingString:directory];
    NSString* savePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@.jpg",imaNameStr]];
    [fileManager changeCurrentDirectoryPath:savePath];
    NSLog(@"【monitoringVC】截图保存路径：%@",savePath);
    
    [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    BOOL ret = [fileManager createFileAtPath:savePath contents:UIImagePNGRepresentation(image) attributes:nil];
    if (!ret) {
        NSLog(@"【monitoringVC】截图保存路径 文件 创建失败");
    }
}

//=========================delegate=========================

#pragma mark -----tableViewDelegate
//组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}


//每行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (iPhoneWidth-10)*1.1/2+50;//倍率显示cell的高度
}
//每行的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    bigScreenChannelCell *cell = [tableView dequeueReusableCellWithIdentifier:BIGCHANNELCELL];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.cellDelegate = self;
    if (self.dataArr.count!=0) {
         ChannelCodeListModel *channelModel = self.dataArr[indexPath.row];
        //截图
        UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:channelModel.chanCode];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img1"];
        });
        cell.channelModel = channelModel;
    }
    return cell;
}
//每一行的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.dataArr.count!= 0) {
        ChannelCodeListModel *channelModel = self.dataArr[indexPath.row];
        //单屏
        self.tabBarController.tabBar.hidden=YES;
        RealTimeChannelVC *realTimeVC = [[RealTimeChannelVC alloc]init];
        realTimeVC.channelModel = channelModel;
        realTimeVC.selectedIndex = indexPath;
        [unitl saveDataWithKey:SCREENSTATUS Data:SHU_PING];
        [self.navigationController pushViewController:realTimeVC animated:YES];
    }else{
        [self loadPublicListData];
    }
}

//=========================delegate=========================

#pragma mark - sd卡录像点击事件代理方法
- (void)bigChannelCellSDVideoClick:(bigScreenChannelCell *)cell
{
//    NSLog(@"SD卡录像点击事件");
    if (cell.channelModel) {
        ChannelPlayBackVC * playbackVC = [[ChannelPlayBackVC alloc]init];
        playbackVC.channelModel = cell.channelModel;
        playbackVC.key = cell.channelModel.dev_p_code;
        playbackVC.isDeviceVideo = YES;
        [self.navigationController pushViewController:playbackVC animated:YES];
    }
}

#pragma mark - 云端录像点击事件代理方法
- (void)bigChannelCellCloudVideoClick:(bigScreenChannelCell *)cell
{
//    NSLog(@"云端录像点击事件");
    if (cell.channelModel) {
        ChannelPlayBackVC * playbackVC = [[ChannelPlayBackVC alloc]init];
        playbackVC.channelModel = cell.channelModel;
        playbackVC.key = cell.channelModel.dev_p_code;
        playbackVC.isDeviceVideo = NO;
        [self.navigationController pushViewController:playbackVC animated:YES];
    }
}

#pragma mark - 告警消息点击事件代理方法
- (void)bigChannelCellAlarmVideoClick:(bigScreenChannelCell *)cell
{
    NSLog(@"告警点击事件");
//    if (cell.model) {
//        AlarmMsgVC *alarmVC = [[AlarmMsgVC alloc]init];
//        alarmVC.homeDevID = cell.model.ID;
//        [self.navigationController pushViewController:alarmVC animated:YES];
//    }
}

//=========================lazy Loading=========================
#pragma mark ----- lazyloading
//表视图
-(UITableView *)tv_list{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tv_list.backgroundColor = BG_COLOR;
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        _tv_list.showsVerticalScrollIndicator = NO;
        UIView *footView = [[UIView alloc]init];
        _tv_list.tableFooterView = footView;
        [_tv_list registerNib:[UINib nibWithNibName:@"bigScreenChannelCell" bundle:nil] forCellReuseIdentifier:BIGCHANNELCELL];
        _tv_list.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tv_list.tableHeaderView = self.headView;
    }
    return _tv_list;
}
//数据源
-(NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArr;
}

#pragma mark ----- 设置能力集合
//设置能力集合
- (void)setDeviceFeature:(dev_list*)listModel{
    //1.判断Feature这个key到底在不在
    if (!listModel.ext_info.Feature) {
        //        NSLog(@"不存在Feature");
        self.feature.isWiFi = 0;
        self.feature.isTalk = 0;
        self.feature.isCloudDeck = 0;
        self.feature.isCloudStorage = 0;
        self.feature.isP2P = 0;
    }else{
        //        NSLog(@"存在Feature");
        NSString *featureStr = listModel.ext_info.Feature;
        //        NSLog(@"featureStr:%@",featureStr);
        self.feature.isWiFi = [[featureStr substringWithRange:NSMakeRange(0,1)] intValue];
        self.feature.isTalk = [[featureStr substringWithRange:NSMakeRange(2,1)] intValue];
        self.feature.isCloudDeck = [[featureStr substringWithRange:NSMakeRange(4,1)] intValue];
        self.feature.isCloudStorage = [[featureStr substringWithRange:NSMakeRange(6,1)] intValue];
        self.feature.isP2P = [[featureStr substringWithRange:NSMakeRange(8,1)] intValue];
    }
    //    NSLog(@"self.feature.isWiFi:%d,%d,%d,%d,%d",self.feature.isWiFi,self.feature.isTalk,self.feature.isCloudDeck,self.feature.isCloudStorage,self.feature.isP2P);
}

//头部视图懒加载
-(UIView *)headView{
    if (!_headView) {
        _headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, headViewHeight+14)];
        _headView.backgroundColor = BG_COLOR;
    }
    return _headView;
}


@end
