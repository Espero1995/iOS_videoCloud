//
//  DeviceDisplayVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/14.
//  Copyright © 2018年 张策. All rights reserved.
//

#define LeftSpace 7
#define  headViewHeight iPhoneWidth/4
#define WEIClOUDCELLT @"DeviceDisPlayCell"
#import "DeviceDisplayVC.h"


//========Model========
/*刷新的控件*/
#import "YALSunnyRefreshControl.h"
#import "UITableView+Popover.h"
#import "UIImage+image.h"
/*设备的model*/
#import "WeiCloudListModel.h"
/*能力集信息*/
#import "FeatureModel.h"
//========View========
/*自定义按钮*/
#import "UnderlineBtn.h"
/*轮播图*/
#import "SDCycleScrollView.h"
/*设置界面弹框*/
#import "DeviceSetPopUpView.h"
/*分享的弹框*/
#import "SharedSheetView.h"
/*设备cell*/
#import "DeviceDisPlayCell.h"

//========VC========
/*工具栏*/
#import "ZCTabBarController.h"
/*二维码*/
#import "SGGenerateQRCodeVC.h"
#import "SGScanningQRCodeVC.h"
#import <AVFoundation/AVFoundation.h>
#import "SGAlertView.h"
/*实时单屏*/
#import "RealTimeVideoVC.h"
/*四分屏*/
#import "MonitoringVCnew.h"
/*录像回放*/
#import "OnlyPlayBackVC.h"
/*设置*/
#import "GeneralDeviceSettingVC.h"
#import "SpecialDeviceSettingVC.h"
/*好友分享*/
#import "FriendsSharedVC.h"
/*视频的微信分享*/
#import "ShareVideoToWeixinVC.h"
/*云存储页面*/
#import "MyCloudStorageVC.h"
/*排序界面*/
#import "DeviceSortingVC.h"
/*时光相册*/
#import "TimePhotoAlbumVC.h"
/*告警消息列表*/
#import "AlarmMsgVC.h"
@interface DeviceDisplayVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    DeviceDisPlayCellDelegate,
    SDCycleScrollViewDelegate,
    DeviceSetPopUpViewDelegate,
    SharedSheetViewDelegate
>

/*表视图*/
@property (nonatomic,strong) UITableView *tv_list;
/*数据源*/
@property (nonatomic,strong) NSMutableArray *dataArr;
/*截图*/
@property (nonatomic,strong) UIImage *cutImage;
/*刷新*/
@property (nonatomic,assign) BOOL refresh;
@property (nonatomic,strong) dev_list * VodeolistModel;

/*无设备时候的页面*/
@property (nonatomic,strong) UIView * backNoDeviceView;
/*无设备时的添加按钮*/
@property (nonatomic,strong) UIButton *addDeviceBtn;
/*无设备时的添加设备提示Label*/
@property (nonatomic,strong) UILabel *tipLb;
/*无设备时的底部的文字以及按钮*/
@property (nonatomic,strong) UILabel *bottomTipLb;
/*商城按钮*/
@property (nonatomic,strong) UnderlineBtn *shopBtn;
/*能力集信息的model*/
@property (nonatomic,strong)FeatureModel *feature;

/*头视图：轮播图*/
@property (nonatomic, strong) UIView *headView;
@property (nonatomic,strong) DeviceSetPopUpView *setPopUpView;//设置按钮弹出框
@property (nonatomic,strong) SharedSheetView *shareSheetView;//分享的弹框
@property (nonatomic) CGPoint mytv_listPoint;//tv_list点击所在的坐标点
@property (nonatomic, assign) NSInteger index_group;/**< 当前选定的是哪个组别，index代表着组列表的序列 */

@end

@implementation DeviceDisplayVC
//=========================system=========================
- (void)viewDidLoad {
    [super viewDidLoad];
    //能力集合model初始化
    self.feature = [[FeatureModel alloc]init];
    self.view.backgroundColor = BG_COLOR;
    [self setUpUI];//表视图布局
    [self setupTitleScrollView];//广告
    self.index_group = [unitl getCurrentDisplayGroupIndex];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;

    //截图
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updataCutImageWithID:) name:UpDataCutImageWithID object:nil];
    //添加设备
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPage) name:ADDORDELETEDEVICE object:nil];
    //刷新单个cell
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCell:) name:@"refreshCell" object:nil];
    //更新某一设备的活动状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDeviceisActivity:) name:deviceisActivity object:nil];
    //更新整个组设备的活动状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllDeviceisActivity:) name:allDeviceisActivity object:nil];
    //重新刷新设备列表UPDATESORT
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSortingDevice) name:UPDATESORT object:nil];
    //选择了当前的分组
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updataGruopInfo:) name:chooseGroup object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.tv_list removePopView];//移除所有的选项弹框
//    HDNetworking *manager = [[HDNetworking alloc] init];
//    [manager canleAllHttp];//暂时注释
     [self.tv_list.mj_header endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//=========================init=========================
#pragma mark - 通知刷新设备
- (void)refreshPage{
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadPublicListData)];
    [header beginRefreshing];
    self.tv_list.mj_header = header;
}
#pragma mark - 单个cell名字的刷新
- (void)refreshCell:(NSNotification *)noti
{
    //    NSLog(@"noti:%@",noti);
    NSIndexPath * index = [noti.userInfo objectForKey:@"selectedIndex"];
    NSMutableString * deviceNewName = [noti.userInfo objectForKey:@"deviceName"];
    DeviceDisPlayCell *cell = [self.tv_list cellForRowAtIndexPath:index];
    dev_list *listModel = self.dataArr[index.row];
    if ([[NSString stringWithString:deviceNewName] isEqualToString:@""]) {
        cell.deviceName_Lb.text = listModel.type;
        cell.nameStr =  deviceNewName;
    }else{
        cell.deviceName_Lb.text = [NSString stringWithString:deviceNewName];
        cell.nameStr = deviceNewName;
    }
}

#pragma mark - 更新某一设备的活动状态
- (void)refreshDeviceisActivity:(NSNotification *)noti
{
    NSIndexPath * index = [noti.userInfo objectForKey:@"selectedIndex"];
    NSString * isActivity = [noti.userInfo objectForKey:@"isActivity"];
    DeviceDisPlayCell *cell = [self.tv_list cellForRowAtIndexPath:index];
    if ([isActivity intValue] == 0) {
        cell.isOnline_img.image = [UIImage imageNamed:@"person_1-1"];//没有开移动侦测
    }else{
        cell.isOnline_img.image = [UIImage imageNamed:@"person_2-1"];//开移动侦测
    }
}

#pragma mark - 更新组内全部设备的活动状态
- (void)refreshAllDeviceisActivity:(NSNotification *)noti
{
    NSString * isActivity = [noti.userInfo objectForKey:@"isActivity"];
    int deviceCount = [[noti.userInfo objectForKey:@"DeviceCount"] intValue];
    for (int i = 0 ; i < deviceCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        DeviceDisPlayCell *cell = [self.tv_list cellForRowAtIndexPath:indexPath];
        if ([isActivity intValue] == 0) {
            cell.isOnline_img.image = [UIImage imageNamed:@"person_1-1"];//没有开移动侦测
        }else{
            cell.isOnline_img.image = [UIImage imageNamed:@"person_2-1"];//开移动侦测
        }
    }
    
}

#pragma mark - 更新设备排序
- (void)updateSortingDevice
{
    [self.dataArr removeAllObjects];
    self.dataArr = [unitl getCameraGroupDeviceModelIndex:[unitl getCurrentDisplayGroupIndex]];
    [self.tv_list reloadData];
}


- (void)dealloc
{
    jw_cipher_release(_cipher);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//初始化页面布局
- (void)setUpUI{
    //表视图布局
    [self.view addSubview:self.tv_list];
    [self.tv_list mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.width.mas_equalTo(iPhoneWidth);
    }];
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadPublicListData)];
    [header beginRefreshing];
    self.tv_list.mj_header = header;
}


// 添加顶部的标题滚动视图
- (void)setupTitleScrollView
{
    UIView * ScrollBackView = [[UIView alloc]initWithFrame:CGRectMake(LeftSpace, 7, iPhoneWidth-14, headViewHeight)];
    ScrollBackView.backgroundColor = [UIColor clearColor];
    ScrollBackView.layer.masksToBounds = YES;
    ScrollBackView.layer.cornerRadius = 4.f;
    [self.headView addSubview:ScrollBackView];
    
    //加载本地的广告资源
    UIImage *placeholder1 = [UIImage imageNamed:NSLocalizedString(@"banner1", nil)];
    UIImage *placeholder2 = [UIImage imageNamed:NSLocalizedString(@"banner2", nil)];
    UIImage *placeholder3 = [UIImage imageNamed:NSLocalizedString(@"banner3", nil)];
    NSMutableArray *imaGroup = [NSMutableArray arrayWithObjects:placeholder1,placeholder2,placeholder3, nil];
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, iPhoneWidth-10, headViewHeight) delegate:self placeholderImage:placeholder1];
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
//        NSLog(@"轮播图返回：responseObject：%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSMutableString *jsonDataString=[NSMutableString string];
            NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
            jsonDataString = responseObject[@"body"][@"pub_data"][@"top_banner"];
            BaseUrlModel *urlModel = [BaseUrlDefaults geturlModel];
            if (((NSArray *)jsonDataString).count > 0) {
                for (int i = 0; i<((NSArray *)jsonDataString).count; i++) {
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
        UIImage *placeholder1 = [UIImage imageNamed:NSLocalizedString(@"banner1", nil)];
        UIImage *placeholder2 = [UIImage imageNamed:NSLocalizedString(@"banner2", nil)];
        UIImage *placeholder3 = [UIImage imageNamed:NSLocalizedString(@"banner3", nil)];
        NSMutableArray *imaGroup = [NSMutableArray arrayWithObjects:placeholder1,placeholder2,placeholder3, nil];
        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, iPhoneWidth-14, headViewHeight) delegate:self placeholderImage:placeholder1];
        cycleScrollView.backgroundColor = BG_COLOR;
        cycleScrollView.localizationImageNamesGroup = imaGroup;
        cycleScrollView.pageControlBottomOffset = -8;
        [ScrollBackView addSubview:cycleScrollView];
    }];
}


//=========================method=========================
- (void)updataGruopInfo:(NSNotification *)info
{
    NSInteger index;
    if (info) {
        index = [[info.userInfo objectForKey:chooseGroup] integerValue];
        self.index_group = index;
        [self.dataArr removeAllObjects];
        self.dataArr = [unitl getCameraGroupDeviceModelIndex:index];
        self.dataArr.count == 0 ? [self createNoDevicePageIsRequestFailure:NO] : [self removeNoDevicePageIsRequestFailure];
        [self.tv_list reloadData];
    }
}
#pragma mark -----网络加载公共设备数据信息
- (void)loadPublicListData
{
    _refresh = NO;
    [self.dataArr removeAllObjects];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSNumber *languageType;
    if (isSimplifiedChinese) {
        languageType = [NSNumber numberWithInt:1];
    }else{
        languageType = [NSNumber numberWithInt:2];
    }
    [dic setObject:languageType forKey:@"languageType"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/devicegroup/listGroup" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"公共设备信息:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            WeiCloudListModel *listModel = [WeiCloudListModel mj_objectWithKeyValues:responseObject[@"body"]];
            NSInteger currentIndex = [unitl getCurrentDisplayGroupIndex];
            if (_index_group >= listModel.deviceGroup.count) {
                _index_group = 0;
            }else{
                NSString * groupID = ((deviceGroup *)[unitl getCameraGroupModelIndex:currentIndex]).groupId;
                NSInteger correntIndex = [unitl getCorrectIndexWithGroupID:groupID NeedFindData:(NSMutableArray *)listModel.deviceGroup];
                _index_group = correntIndex;
                [unitl saveCurrentDisplayGroupIndex:correntIndex];
            }
            self.dataArr = [NSMutableArray arrayWithArray:listModel.deviceGroup[_index_group].dev_list];
            
            self.dataArr = [NSMutableArray arrayWithArray:listModel.deviceGroup[_index_group].dev_list];
            NSMutableArray *videoListArr = [((deviceGroup *)[unitl getCameraGroupModelIndex:currentIndex]).dev_list mutableCopy];
            
            if (self.dataArr.count == 0) {
                //保存组名和组ID
                [unitl saveGroupNameAndIDArr:(NSMutableArray *)listModel.deviceGroup];
                [[NSNotificationCenter defaultCenter]postNotificationName:GroupCreateOrDeleteSuccess_updateUI object:nil];
                
                [self createNoDevicePageIsRequestFailure:NO];
                [self.tv_list reloadData];
                [self.tv_list.mj_header endRefreshing];
            }else
            {
                if (videoListArr.count != 0) {
                    self.dataArr = [self sortWithAlreadyHaveOrderNetworkData:self.dataArr OrderlyData:videoListArr];
                }
                [unitl saveAllGroupCameraModel:[NSMutableArray arrayWithArray:listModel.deviceGroup]];//先保存全部数据

                if (self.dataArr.count > 0 && currentIndex < self.dataArr.count) {
                    [unitl saveCameraGroupDeviceModelData:self.dataArr Index:currentIndex];
                }
                if (self.dataArr.count == 0) {
                    [self createNoDevicePageIsRequestFailure:NO];
                    [unitl clearCameraModel];
                    [self.tv_list reloadData];
                    [self.tv_list.mj_header endRefreshing];
                }else{
                    [self.backNoDeviceView removeFromSuperview];
                    
                    NSMutableArray * tempVideoListModelArr_ALL = [NSMutableArray arrayWithCapacity:0];
                    NSMutableArray * tempVideoNameArr = [NSMutableArray arrayWithCapacity:0];
                    for (int i = 0; i < self.dataArr.count; i++) {
                        self.VodeolistModel = self.dataArr[i];
                        [tempVideoListModelArr_ALL addObject:self.dataArr[i]];
                        //判断名字在不在不在就存设备类型
                        if (![NSString isNull:self.VodeolistModel.name]) {
                            [tempVideoNameArr addObject:self.VodeolistModel.name];
                        }else{
                            [tempVideoNameArr addObject:self.VodeolistModel.type];
                        }
                    }
                    NSData *data_allName = [NSKeyedArchiver archivedDataWithRootObject:tempVideoNameArr];
                    [[NSUserDefaults standardUserDefaults]setObject:data_allName forKey:VIDEOLISTMODEL_Name];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    
                    //保存组名和组ID
                    [unitl saveGroupNameAndIDArr:(NSMutableArray *)listModel.deviceGroup];
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:reloadGroupSCBtn object:nil];
                    [[NSNotificationCenter defaultCenter]postNotificationName:GroupCreateOrDeleteSuccess_updateUI object:nil];
            
                    [self.tv_list reloadData];
                    [self.tv_list.mj_header endRefreshing];
                }
            }
        }
        else{
            [self.tv_list.mj_header endRefreshing];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.tv_list reloadData];
        [self createNoDevicePageIsRequestFailure:YES];
        [self.tv_list.mj_header endRefreshing];
    }];
}

//下拉刷新
-(void)setupRefreshControl{
//    NSLog(@"下拉刷新");
}
-(void)sunnyControlDidStartAnimation{
//    NSLog(@"下拉刷新");
}
//结束下拉刷新
-(IBAction)endAnimationHandle{
//    NSLog(@"结束下拉刷新");
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

#pragma mark - 长按跳转到排序页面
- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateBegan) {
        //push效果
        CATransition *transition = [unitl pushAnimationWith:0 fromController:self];
        transition.delegate = (id)self.navigationController;
        transition.duration = 0.6f;
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        
        DeviceSortingVC *sortVC = [[DeviceSortingVC alloc]init];
        [self.navigationController pushViewController:sortVC animated:YES];
    }
}

#pragma mark - 网络获取的视频列表【未排序】和本地【已经拍排序列表】进行排序操作
- (NSMutableArray * )sortWithAlreadyHaveOrderNetworkData:(NSMutableArray *)netData OrderlyData:(NSMutableArray *)orderlydata
{
    NSMutableArray * NetArr = [netData mutableCopy];
//    NSMutableArray * tempNetArr = [netData mutableCopy];//和网络数据一致，用来删除和已有数据一样的，留下新增的数据。
    NSMutableArray * orderlyArr = [orderlydata mutableCopy];
    NSMutableArray * tempReturnArr = [NSMutableArray arrayWithCapacity:0];
    //NSMutableArray * tempNewArr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < orderlyArr.count; i++) {
        for (int j = 0; j < NetArr.count ; j++) {
            NSString * netModelID = ((dev_list *)NetArr[j]).ID;
            NSString * orderlyModelID = ((dev_list *)orderlyArr[i]).ID;
            if ([netModelID isEqualToString:orderlyModelID]) {
                //[tempReturnArr insertObject:NetArr[j] atIndex:i];//这种如果网络数据中有删除，则会空下这个删除的位置。
                [tempReturnArr addObject:NetArr[j]];
                [NetArr removeObjectAtIndex:j];
            }
        }
    }
    if (NetArr.count > 0) {
        [tempReturnArr addObjectsFromArray:NetArr];
    }
//    NSLog(@"排序好的数组是：%@ 个数：%ld",tempReturnArr,tempReturnArr.count);
    return tempReturnArr;
}


#pragma mark -----截图方法
- (UIImage*)getSmallImageWithUrl:(NSString*)imageUrl AtDirectory:(NSString*)directory ImaNameStr:(NSString *)nameStr
{
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取路径
    //1、拼接目录
    NSString *path = [NSHomeDirectory() stringByAppendingString:directory];
    NSString* savePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@.jpg",nameStr]];
    [fileManager changeCurrentDirectoryPath:savePath];
    UIImage *cutIma =  [[UIImage alloc]initWithContentsOfFile:savePath];

    return cutIma;
}
- (void)updataCutImageWithID:(NSNotification *)noti
{
    if (noti) {
        NSString * cutImageID = [noti.userInfo objectForKey:@"updataImageID"];
        NSIndexPath * index = [noti.userInfo objectForKey:@"selectedIndex"];
        UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:cutImageID];
        dispatch_async(dispatch_get_main_queue(), ^{
            DeviceDisPlayCell *cell = [self.tv_list cellForRowAtIndexPath:index];
            cell.ima_photo.image = cutIma;
        });
    }
}

#pragma mark ===== 没有设备的时候的提示图，分为【添加设备】和【网络刷新失败】
//没有设备信息时候的页面
- (void)createNoDevicePageIsRequestFailure:(BOOL)isRequestFailure{
    self.backNoDeviceView.backgroundColor = [UIColor clearColor];
    self.backNoDeviceView.hidden = NO;
    [self.parentViewController.view addSubview:self.backNoDeviceView];
    [self.backNoDeviceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(headViewHeight+NavBarHeight_UserDefined+14);
        make.bottom.mas_equalTo(-iPhoneToolBarHeight);
        make.width.mas_equalTo(iPhoneWidth);
    }];
    //添加设备按钮
    [self.addDeviceBtn setBackgroundImage:isRequestFailure?[UIImage imageNamed:@"content_not"]:[UIImage imageNamed:@"add_deviceUp"] forState:UIControlStateNormal];
    [self.addDeviceBtn addTarget:self action:@selector(showQrcode) forControlEvents:UIControlEventTouchUpInside];
    [self.backNoDeviceView addSubview:self.addDeviceBtn];
    isRequestFailure ? (self.addDeviceBtn.userInteractionEnabled = NO) : (self.addDeviceBtn.userInteractionEnabled = YES);
    [self.addDeviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backNoDeviceView.mas_centerY).offset(-50);
        make.centerX.equalTo(self.backNoDeviceView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    //添加设备提示Label
    self.tipLb.text = isRequestFailure ? NSLocalizedString(@"暂无设备数据", nil) : NSLocalizedString(@"添加设备", nil);
    self.tipLb.font = FONT(15);
    self.tipLb.textColor = [UIColor grayColor];
    self.tipLb.textAlignment = NSTextAlignmentCenter;
    [self.backNoDeviceView addSubview:self.tipLb];
    [self.tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.addDeviceBtn.mas_centerX);
        make.top.equalTo(self.addDeviceBtn.mas_bottom).offset(15);
    }];
    
    if (isRequestFailure) {
        self.bottomTipLb.hidden = YES;
        self.shopBtn.hidden = YES;
    }else{
        if (isOverSeas) {
            self.bottomTipLb.hidden = YES;
            self.shopBtn.hidden = YES;
        }else{
            self.bottomTipLb.hidden = NO;
            self.shopBtn.hidden = NO;
        }
    }
    
    [self.backNoDeviceView addSubview:self.bottomTipLb];
    [self.bottomTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        if (isSimplifiedChinese) {
            make.centerX.equalTo(self.backNoDeviceView.mas_centerX).offset(0);
        }else{
            make.centerX.equalTo(self.backNoDeviceView.mas_centerX).offset(-35);
        }
        make.bottom.equalTo(self.backNoDeviceView.mas_bottom).offset(-10);
    }];
    
    //商城按钮
    [self.backNoDeviceView addSubview:self.shopBtn];
    [self.shopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomTipLb.mas_centerY);
        if(isSimplifiedChinese){
            make.right.equalTo(self.bottomTipLb.mas_right).offset(-47);
        }else{
            make.left.equalTo(self.bottomTipLb.mas_right).offset(5);
        }
    }];
}
//【销毁】没有设备信息时候的页面
- (void)removeNoDevicePageIsRequestFailure
{
    self.backNoDeviceView.hidden = YES;
}


#pragma mark ------点击右上角加号方法扫描二维码
- (void)showQrcode
{
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SGScanningQRCodeVC *scanningQRCodeVC = [[SGScanningQRCodeVC alloc] init];
                        [self.navigationController pushViewController:scanningQRCodeVC animated:YES];
                        NSLog(@"主线程 - - %@", [NSThread currentThread]);
                    });
                    NSLog(@"当前线程 - - %@", [NSThread currentThread]);
                    
                    // 用户第一次同意了访问相机权限
                    NSLog(@"用户第一次同意了访问相机权限");
                    
                } else {
                    
                    // 用户第一次拒绝了访问相机权限
                    NSLog(@"用户第一次拒绝了访问相机权限");
                }
            }];
        } else if (status == AVAuthorizationStatusAuthorized) { // 用户允许当前应用访问相机
            [self setUpNavBack];
            SGScanningQRCodeVC *scanningQRCodeVC = [[SGScanningQRCodeVC alloc] init];
            [self.navigationController pushViewController:scanningQRCodeVC animated:YES];
        } else if (status == AVAuthorizationStatusDenied) { // 用户拒绝当前应用访问相机
            [unitl createAlertActionWithTitle:NSLocalizedString(@"已为“视频云眼”关闭相机", nil) message:NSLocalizedString(@"您可以在“设置”中为此应用打开相机", nil) andController:self];
        } else if (status == AVAuthorizationStatusRestricted) {
            NSLog(@"因为系统原因, 无法访问相册");
        }
    } else {
        [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"未检测到您的摄像头", nil)];
    }
}

-(void)clickShop{
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    tabVC.tabLastSelectedIndex = 0;
    tabVC.selectedIndex = 2;
    tabVC.tabSelectIndex = 2;
}

#pragma mark - 刷新封面代理协议
- (void)refreshCoverBtnViewClick
{
    NSIndexPath * indexPath = [self.tv_list indexPathForRowAtPoint:self.mytv_listPoint];
    DeviceDisPlayCell *cell = [self.tv_list cellForRowAtIndexPath:indexPath];
    dev_list *listModel = self.dataArr[indexPath.row];
    
    self.bIsEncrypt = listModel.enable_sec;
    self.key = listModel.dev_p_code;
    
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [postDic setObject:listModel.ID forKey:@"dev_id"];
    [postDic setObject:@"1" forKey:@"chan_id"];

    
    //    NSLog(@"刷新页面功能传给后台dic：%@===self.bIsEncrypt :%@===self.key:%@==userID:%@",postDic,self.bIsEncrypt?@"YES":@"NO",self.key,[unitl get_User_id]);
    [[HDNetworking sharedHDNetworking] POST:@"v1/device/capture" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            
            
            [cell.ima_photo setImage:[self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID]];
            NSDictionary * dic = responseObject[@"body"];
            NSString * urlStr = [dic objectForKey:@"pic_url"];
            NSURL * picUrl = [NSURL URLWithString:urlStr];
            if (self.bIsEncrypt) {
                NSURLRequest *request = [NSURLRequest requestWithURL:picUrl];
                __block UIImage * image;
                
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                    
                    const unsigned char *imageCharData=(const unsigned char*)[data bytes];
                    size_t len = [data length];
                    
                    unsigned char outImageCharData[len];
                    size_t outLen = len;
                    NSLog(@"收到图片的data：%@---长度：%zd===outLen:%zu",response,[data length],outLen);
                    
                    if (len %16 == 0 && [((NSHTTPURLResponse *)response) statusCode] == 200) {
                        int decrptImageSucceed = jw_cipher_decrypt(self.cipher,imageCharData,len,outImageCharData, &outLen);
                        NSLog(@"加密图片数据正确，进行解密:%d",decrptImageSucceed);
                        if (decrptImageSucceed == 1) {
                            NSData *imageData = [[NSData alloc]initWithBytes:outImageCharData length:outLen];
                            image  = [UIImage imageWithData:imageData];
                            if (image) {
                                cell.ima_photo.image = image;
                                [self saveSmallImageWithImage:image Url:@"" AtDirectory:saveCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                            }else{
                                dispatch_async(dispatch_get_main_queue(),^{
                                    UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                                    cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img1"];
                                });
                            }
                        }else{
                            dispatch_async(dispatch_get_main_queue(),^{
                                UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                                cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img1"];
                            });
                        }
                    }else{
                        dispatch_async(dispatch_get_main_queue(),^{
                            UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                            cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img1"];
                        });
                    }
                }];
            }else{
                NSLog(@"图片未加密，用sd请求");
                UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                if (cutIma) {
                    [cell.ima_photo sd_setImageWithURL:picUrl placeholderImage:cutIma];
                }else{
                    [cell.ima_photo sd_setImageWithURL:picUrl placeholderImage:[UIImage imageNamed:@"img1"]];
                }
            }
            
        }else{
            NSLog(@"【行：%ld】3.ret!=0,【第一次】抓图网络请求成功但没有图片",(long)indexPath.row);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                if (cutIma) {
                    cell.ima_photo.image = cutIma;
                }else{
                    cell.ima_photo.image = [UIImage imageNamed:@"img1"];
                }
                
            });
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"刷新封面失败");
        //注释：因为这边有个bug，我们在请求的时候，其实设备正在截图然后传给服务器，但是如果我们客户端这边网速很好，设备图片还没上传成功，所以，就会有，取不到图片的情况。所以，这边，延时1秒，再次做请求。
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[HDNetworking sharedHDNetworking] POST:@"v1/device/capture" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
                NSLog(@"responseObject:%@",responseObject);
                int ret = [responseObject[@"ret"]intValue];
                if (ret == 0) {
                    
                    
                    [cell.ima_photo setImage:[self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID]];
                    NSDictionary * dic = responseObject[@"body"];
                    NSString * urlStr = [dic objectForKey:@"pic_url"];
                    NSURL * picUrl = [NSURL URLWithString:urlStr];
                    if (self.bIsEncrypt) {
                        NSURLRequest *request = [NSURLRequest requestWithURL:picUrl];
                        __block UIImage * image;
                        
                        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                            
                            const unsigned char *imageCharData=(const unsigned char*)[data bytes];
                            size_t len = [data length];
                            
                            unsigned char outImageCharData[len];
                            size_t outLen = len;
                            NSLog(@"收到图片的data：%@---长度：%zd===outLen:%zu",response,[data length],outLen);
                            
                            if (len %16 == 0 && [((NSHTTPURLResponse *)response) statusCode] == 200) {
                                int decrptImageSucceed = jw_cipher_decrypt(self.cipher,imageCharData,len,outImageCharData, &outLen);
                                NSLog(@"加密图片数据正确，进行解密:%d",decrptImageSucceed);
                                if (decrptImageSucceed == 1) {
                                    NSData *imageData = [[NSData alloc]initWithBytes:outImageCharData length:outLen];
                                    image  = [UIImage imageWithData:imageData];
                                    if (image) {
                                        cell.ima_photo.image = image;
                                        [self saveSmallImageWithImage:image Url:@"" AtDirectory:saveCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                                    }else{
                                        dispatch_async(dispatch_get_main_queue(),^{
                                            UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                                            cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img1"];
                                        });
                                    }
                                }else{
                                    dispatch_async(dispatch_get_main_queue(),^{
                                        UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                                        cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img1"];
                                    });
                                }
                            }else{
                                dispatch_async(dispatch_get_main_queue(),^{
                                    UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                                    cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img1"];
                                });
                            }
                        }];
                    }else{
                        NSLog(@"图片未加密，用sd请求");
                        UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                        if (cutIma) {
                            [cell.ima_photo sd_setImageWithURL:picUrl placeholderImage:cutIma];
                        }else{
                            [cell.ima_photo sd_setImageWithURL:picUrl placeholderImage:[UIImage imageNamed:@"img1"]];
                        }
                    }
                    
                }else{
                    NSLog(@"【行：%ld】3.ret!=0,【第二次】抓图网络请求成功但没有图片",(long)indexPath.row);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                        if (cutIma) {
                            cell.ima_photo.image = cutIma;
                        }else{
                            cell.ima_photo.image = [UIImage imageNamed:@"img1"];
                        }
                        
                    });
                }
                
                
            } failure:^(NSError * _Nonnull error) {
                NSLog(@"延时 1s后，刷新封面再次失败，那即失败、");
            }];
        });
    }];
}

/*
#pragma mark ----- 刷新页面功能
-(void)refreshDevicePage:(DeviceDisPlayCell *)cell{
    
    NSIndexPath * indexPath = [self.tv_list indexPathForCell:cell];
    dev_list *listModel = self.dataArr[indexPath.row];
    
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [postDic setObject:listModel.ID forKey:@"dev_id"];
    [postDic setObject:@"1" forKey:@"chan_id"];
    
    [[HDNetworking sharedHDNetworking] POST:@"v1/device/capture" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:::%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            
            
            [cell.ima_photo setImage:[self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID]];
            NSDictionary * dic = responseObject[@"body"];
            NSString * urlStr = [dic objectForKey:@"pic_url"];
            NSURL * picUrl = [NSURL URLWithString:urlStr];
            if (self.bIsEncrypt) {
                NSURLRequest *request = [NSURLRequest requestWithURL:picUrl];
                __block UIImage * image;
                
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                    
                    NSLog(@"【行：%ld】收到图片的data：%@---长度：%zd",(long)indexPath.row,response,data.length);
                    
                    const unsigned char *imageCharData=(const unsigned char*)[data bytes];
                    size_t len = [data length];
                    
                    unsigned char outImageCharData[len];
                    size_t outLen = len;
                    
                    if (len %16 == 0 && [((NSHTTPURLResponse *)response) statusCode] == 200) {
                        int decrptImageSucceed = jw_cipher_decrypt(self.cipher,imageCharData,len,outImageCharData, &outLen);
                        NSLog(@"加密图片数据正确，进行解密:%d",decrptImageSucceed);
                        if (decrptImageSucceed == 1) {
                            NSData *imageData = [[NSData alloc]initWithBytes:outImageCharData length:outLen];
                            image  = [UIImage imageWithData:imageData];
                            if (image) {
                                cell.ima_photo.image = image;
                                [self saveSmallImageWithImage:image Url:@"" AtDirectory:saveCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                            }else{
                                dispatch_async(dispatch_get_main_queue(),^{
                                    UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                                    cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img1"];
                                });
                            }
                        }else{
                            dispatch_async(dispatch_get_main_queue(),^{
                                UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                                cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img1"];
                            });
                        }
                    }else{
                        dispatch_async(dispatch_get_main_queue(),^{
                            UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                            cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img1"];
                        });
                    }
                }];
            }else{
                NSLog(@"图片未加密，用sd请求");
                UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                if (cutIma) {
                    [cell.ima_photo sd_setImageWithURL:picUrl placeholderImage:cutIma];
                }else{
                    [cell.ima_photo sd_setImageWithURL:picUrl placeholderImage:[UIImage imageNamed:@"img1"]];
                }
            }
            
        }else{
            NSLog(@"【行：%ld】3.ret!=0,抓图网络请求成功但没有图片",(long)indexPath.row);
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                if (cutIma) {
                    cell.ima_photo.image = cutIma;
                }else{
                    cell.ima_photo.image = [UIImage imageNamed:@"img1"];
                }
                
            });
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"刷新封面失败");
    }];
}
*/

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

#pragma mark - 分享代理协议
- (void)shareBtnViewClick
{
//    [self.shareSheetView shareSheetViewShow];
    [XHToast showCenterWithText:@"分享功能暂不可用"];
}
/*
#pragma mark ----- 分享页面功能
-(void)sharedDevicePage:(DeviceDisPlayCell *)cell
{
    [self.shareSheetView shareSheetViewShow];
    self.deviceDisPlayTempCell = cell;
}
*/

#pragma mark - 分享的代理方法
//手机好友分享
- (void)sharetoPhoneClick
{
//    NSIndexPath *indexPath = [self.tv_list indexPathForCell:self.deviceDisPlayTempCell];
//    dev_list *listModel = self.dataArr[indexPath.row];
    NSIndexPath * indexPath = [self.tv_list indexPathForRowAtPoint:self.mytv_listPoint];
    dev_list *listModel = self.dataArr[indexPath.row];
    
    //先判断是不是分享设备
    if ([[unitl get_User_id] isEqualToString:listModel.owner_id]) {//自己设备self.listModel
        FriendsSharedVC *shareVC = [[FriendsSharedVC alloc]init];
        shareVC.dev_mList = listModel;
        [self.navigationController pushViewController:shareVC animated:YES];
    }else{
        [XHToast showCenterWithText:NSLocalizedString(@"您不是该设备的主人，暂时无法分享手机好友", nil)];
    }
}

//微信好友分享
- (void)sharetoWeChatClick
{
//    NSIndexPath *indexPath = [self.tv_list indexPathForCell:self.deviceDisPlayTempCell];
    
    NSIndexPath * indexPath = [self.tv_list indexPathForRowAtPoint:self.mytv_listPoint];
    DeviceDisPlayCell *cell = [self.tv_list cellForRowAtIndexPath:indexPath];
    dev_list *listModel = self.dataArr[indexPath.row];
    
    if (listModel.status == 0) {
        [XHToast showCenterWithText:NSLocalizedString(@"当前设备不在线，无法进行微信视频分享", nil)];
    }else{
        ShareVideoToWeixinVC * shareToweixinVC = [[ShareVideoToWeixinVC alloc]init];
        UIImage *ima ;
        ima = cell.ima_photo.image;
        shareToweixinVC.currentVideo_CutImage = ima;
        shareToweixinVC.dev_id = listModel.ID;//self.dev_id
        shareToweixinVC.devName = listModel.name;
        [self.navigationController pushViewController:shareToweixinVC animated:YES];
    }
}



#pragma mark - 购买云存代理协议
- (void)cloudBtnViewClick
{
    
    NSIndexPath * indexPath = [self.tv_list indexPathForRowAtPoint:self.mytv_listPoint];
    dev_list *listModel = self.dataArr[indexPath.row];
    [self setDeviceFeature:listModel];
    if (self.feature.isCloudStorage) {
        MyCloudStorageVC *myCloudVC = [[MyCloudStorageVC alloc]init];
        myCloudVC.deviceId = listModel.ID;
        if(![NSString isNull:listModel.name]){
            myCloudVC.deviceName = listModel.name;
        }else{
            myCloudVC.deviceName = listModel.type;
        }
        myCloudVC.deviceImgUrl = listModel.ext_info.dev_img;
        [self.navigationController pushViewController:myCloudVC animated:YES];
    }else{
        [XHToast showCenterWithText:NSLocalizedString(@"该设备不支持云存", nil)];
    }
}

/*
#pragma mark ----- 云存储页面功能
-(void)cloudStorageDevicePage:(DeviceDisPlayCell *)cell{
    NSIndexPath * indexPath = [self.tv_list indexPathForCell:cell];
    dev_list *listModel = self.dataArr[indexPath.row];
     [self setDeviceFeature:listModel];
    if (self.feature.isCloudStorage) {
        MyCloudStorageVC *myCloudVC = [[MyCloudStorageVC alloc]init];
        myCloudVC.deviceId = listModel.ID;
        if(![NSString isNull:listModel.name]){
            myCloudVC.deviceName = listModel.name;
        }else{
            myCloudVC.deviceName = listModel.type;
        }
        myCloudVC.deviceImgUrl = [listModel.ext_info objectForKey:@"dev_img"];
        [self.navigationController pushViewController:myCloudVC animated:YES];
    }else{
        [XHToast showCenterWithText:@"该设备不支持云存"];
    }
    
}
 */

#pragma mark - 设置按钮代理协议
- (void)setBtnViewClick
{
    NSIndexPath * indexPath = [self.tv_list indexPathForRowAtPoint:self.mytv_listPoint];
    //DeviceDisPlayCell *cell = [self.tv_list cellForRowAtIndexPath:indexPath];
    dev_list *listModel = self.dataArr[indexPath.row];
    //以下三个条件都归属于普通设备
    if (listModel.chanCount == 1 || listModel.chanCount == 0) {
        GeneralDeviceSettingVC *setVC = [[GeneralDeviceSettingVC alloc]init];
        setVC.dev_mList = listModel;
        setVC.currentIndex = indexPath;
        [self.navigationController pushViewController:setVC animated:YES];
    }else{
        SpecialDeviceSettingVC *setVC = [[SpecialDeviceSettingVC alloc]init];
        setVC.dev_mList = listModel;
        setVC.currentIndex = indexPath;
        [self.navigationController pushViewController:setVC animated:YES];
    }
}

#pragma mark - 时光相册点击事件
- (void)timeAlbumBtnViewClick
{
    NSIndexPath * indexPath = [self.tv_list indexPathForRowAtPoint:self.mytv_listPoint];
    dev_list *listModel = self.dataArr[indexPath.row];
    TimePhotoAlbumVC *albumVC = [[TimePhotoAlbumVC alloc]init];
    albumVC.listModel = listModel;
    [self.navigationController pushViewController:albumVC animated:YES];
}



#pragma mark - 警告框
- (void)createAlertActionWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertCtrl addAction:btnAction];
    [self presentViewController:alertCtrl animated:YES completion:nil];
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
//#pragma mark ------设置区头
////区头高度
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section == 0) {
//        return 0;
//    }
//    return 5;
//}
//
////区头视图
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 5)];
//    backView.backgroundColor = BG_COLOR;
//    return backView;
//}

//每行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (iPhoneWidth-10)*1.1/2+50;//倍率显示cell的高度
}
//每行的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceDisPlayCell *cell = [tableView dequeueReusableCellWithIdentifier:WEIClOUDCELLT];
    //长按编辑排序
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    longPressGesture.minimumPressDuration = 1; //长按等待时间
    [cell addGestureRecognizer:longPressGesture];
    
    if (self.dataArr.count!=0) {
         dev_list *listModel = self.dataArr[indexPath.row];
        //截图
        self.cutImage = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
        
        /* NSLog(@"【体验设备】设备列表==状态：%ld==密钥：%@==是否加密：%d==名称：【%@】",(long)listModel.status,listModel.dev_p_code,listModel.enable_sec,listModel.name);
         _bIsEncrypt = listModel.enable_sec;
         _key = listModel.dev_p_code;
         
         NSMutableDictionary * changeDic = [NSMutableDictionary dictionary];
         [changeDic setObject:listModel.ID forKey:@"dev_id"];
         [changeDic setObject:@"1" forKey:@"chan_id"];
    
         if (listModel.status == 1) {
             [[HDNetworking sharedHDNetworking]POST:@"v1/device/capture" parameters:changeDic IsToken:YES success:^(id  _Nonnull responseObject) {
                 NSLog(@"【行：%ld】1.抓图网络请求成功",(long)indexPath.row);
                 int ret = [responseObject[@"ret"]intValue];
                 NSLog(@"【行：%ld】2.ret=%d",(long)indexPath.row,ret);
                 if (ret == 0) {
                     [cell.ima_photo setImage:[self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID]];
                     NSDictionary * dic = responseObject[@"body"];
                     NSString * urlStr = [dic objectForKey:@"pic_url"];
                     NSURL * picUrl = [NSURL URLWithString:urlStr];
                     if (self.bIsEncrypt) {
                         NSURLRequest *request = [NSURLRequest requestWithURL:picUrl];
                         __block UIImage * image;
                         
                         [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                             
                             NSLog(@"cell【行：%ld】收到图片的data：%@---长度：%zd",(long)indexPath.row,response,data.length);
                             
                             const unsigned char *imageCharData=(const unsigned char*)[data bytes];
                             size_t len = [data length];
                             
                             unsigned char outImageCharData[len];
                             size_t outLen = len;
                             
                             if (len %16 == 0 && [((NSHTTPURLResponse *)response) statusCode] == 200) {
                                 int decrptImageSucceed = jw_cipher_decrypt(self.cipher,imageCharData,len,outImageCharData, &outLen);
                                 NSLog(@"加密图片数据正确，进行解密:%d",decrptImageSucceed);
                                 if (decrptImageSucceed == 1) {
                                     NSData *imageData = [[NSData alloc]initWithBytes:outImageCharData length:outLen];
                                     image  = [UIImage imageWithData:imageData];
                                     if (image) {
                                         cell.ima_photo.image = image;
                                     }else{
                                         dispatch_async(dispatch_get_main_queue(),^{
                                             UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                                             cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img1"];
                                         });
                                     }
                                 }else{
                                     dispatch_async(dispatch_get_main_queue(),^{
                                         UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                                         cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img1"];
                                     });
                                 }
                             }else{
                                 dispatch_async(dispatch_get_main_queue(),^{
                                     UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                                     cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img1"];
                                 });
                             }
                         }];
                     }else{
                         NSLog(@"图片未加密，用sd请求");
                         UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                         if (cutIma) {
                             [cell.ima_photo sd_setImageWithURL:picUrl placeholderImage:cutIma];
                         }else{
                             [cell.ima_photo sd_setImageWithURL:picUrl placeholderImage:[UIImage imageNamed:@"img1"]];
                         }
                     }
                     
                 }else{
                     NSLog(@"【行：%ld】3.ret!=0,抓图网络请求成功但没有图片",(long)indexPath.row);
                     dispatch_async(dispatch_get_main_queue(), ^{
                         UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                         if (cutIma) {
                             cell.ima_photo.image = cutIma;
                         }else{
                             cell.ima_photo.image = [UIImage imageNamed:@"img1"];
                         }
                         
                     });
                 }
             } failure:^(NSError * _Nonnull error) {
                 NSLog(@"【行：%ld】4.请求失败，抓图网络请求失败",(long)indexPath.row);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                     if (cutIma) {
                         cell.ima_photo.image = cutIma;
                     }else{
                         cell.ima_photo.image = [UIImage imageNamed:@"img1"];
                     }
                     
                 });
             }];
         }
        */
         cell.model = listModel;//model传值
     }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.cellDelegate = self;
    return cell;
}
//每一行的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.dataArr.count!= 0) {
        dev_list *listModel = self.dataArr[indexPath.row];
        
        //单屏
        self.tabBarController.tabBar.hidden=YES;
        RealTimeVideoVC * realTimeVC = [[RealTimeVideoVC alloc]init];
        realTimeVC.listModel = listModel;
        realTimeVC.chan_size = listModel.chan_size;
        realTimeVC.chan_alias = listModel.chan_alias;
        realTimeVC.bIsEncrypt = listModel.enable_sec;
        realTimeVC.key = listModel.dev_p_code;
        realTimeVC.selectedIndex = indexPath;
        realTimeVC.dev_id = listModel.ID;
        DeviceDisPlayCell *cell = [self.tv_list cellForRowAtIndexPath:indexPath];
        realTimeVC.titleName = cell.nameStr;
        
        //通过通道数目来判别是否是多通道【注：=0的判断是为了防止后台在搭建新的环境时，未设置通道数目字段】
        //此外还需判断listModel的chans属性的count来兼容老版本的多通道
        if (listModel.chans.count<=1 && listModel.chanCount <= 1) {
            realTimeVC.isMultiChannel = NO;
        }else{
            realTimeVC.isMultiChannel = YES;
        }
        
        
        [unitl saveDataWithKey:SCREENSTATUS Data:SHU_PING];
        [self.navigationController pushViewController:realTimeVC animated:YES];
        
        
        /*
        if (listModel.chan_size==1) {
            //单屏
            self.tabBarController.tabBar.hidden=YES;
            RealTimeVideoVC * realTimeVC = [[RealTimeVideoVC alloc]init];
            realTimeVC.listModel = listModel;
            realTimeVC.chan_size = listModel.chan_size;
            realTimeVC.chan_alias = listModel.chan_alias;
            realTimeVC.bIsEncrypt = listModel.enable_sec;
            realTimeVC.key = listModel.dev_p_code;
            realTimeVC.selectedIndex = indexPath;
            realTimeVC.dev_id = listModel.ID;
            DeviceDisPlayCell *cell = [self.tv_list cellForRowAtIndexPath:indexPath];
            realTimeVC.titleName = cell.nameStr;
            [self.navigationController pushViewController:realTimeVC animated:YES];
        }else{
            //四分屏
            self.tabBarController.tabBar.hidden=YES;
            MonitoringVCnew * monitorVC = [[MonitoringVCnew alloc]init];
            monitorVC.listModel = listModel;
            monitorVC.chan_size = listModel.chan_size;
            monitorVC.chan_alias = listModel.chan_alias;
            monitorVC.bIsEncrypt = listModel.enable_sec;
            monitorVC.key = listModel.dev_p_code;
            monitorVC.selectedIndex = indexPath;
            [self.navigationController pushViewController:monitorVC animated:YES];
        }
        */
        
    }else{
        [self loadPublicListData];
    }
}
#pragma mark -==== tableivew 的滑动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint vel = [scrollView.panGestureRecognizer velocityInView:scrollView];
    if (vel.y > 0) {
        //向下
        // 获取开始拖拽时tableview偏移量
        //        CGFloat _oldY = self.tv_list.contentOffset.y;
        //        NSLog(@"当前滑动是 【下】当前滑动是多少：%f===%f",_oldY,vel.y);
        [[NSNotificationCenter defaultCenter]postNotificationName:tableviewScrollow_down object:nil];
        NSString * nav_Status = [unitl getDataWithKey:NAV_Status];
        if ([nav_Status isEqualToString:@"NAV_Status_DOWN"]) {
            [UIView animateWithDuration:NavBarHeightChangge_duringTime animations:^{
                [self.view setFrame:CGRectMake(0, NavBarHeight_UserDefined, iPhoneWidth, iPhoneHeight -NavBarHeight_UserDefined_Up - iPhoneToolBarHeight)];
                
                [self.tv_list mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.view.mas_centerX);
                    make.top.mas_equalTo(self.view);
                    make.bottom.equalTo(self.view.mas_bottom).offset(0);
                    make.width.mas_equalTo(iPhoneWidth);
                }];
                [self.view layoutIfNeeded];
            }];
        }
    }else{
        //上拉
        //        CGFloat _oldY = self.tv_list.contentOffset.y;
        //        NSLog(@"当前滑动是 【上】 当前滑动是多少：%f===%f",_oldY,vel.y);
        if (vel.y != 0) {
            [[NSNotificationCenter defaultCenter]postNotificationName:tableviewScrollow_up object:nil];
            NSString * nav_Status = [unitl getDataWithKey:NAV_Status];
            if ([nav_Status isEqualToString:@"NAV_Status_UP"]) {
                [UIView animateWithDuration:NavBarHeightChangge_duringTime animations:^{
                    [self.view setFrame:CGRectMake(0, NavBarHeight_UserDefined_Up, iPhoneWidth, iPhoneHeight -NavBarHeight_UserDefined_Up - iPhoneToolBarHeight)];
                    
                    [self.tv_list mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.centerX.equalTo(self.view.mas_centerX);
                        make.top.mas_equalTo(self.view);
                        make.bottom.equalTo(self.view.mas_bottom).offset(0);
                        make.width.mas_equalTo(iPhoneWidth);
                    }];
                    
                    [self.view layoutIfNeeded];
                }];
            }
        }
    }
}

//=========================delegate=========================
#pragma mark ----- 设置按钮点击方法
//设置
- (void)DeviceDisPlayCellSettingClick:(DeviceDisPlayCell *)cell andEvent:(UIEvent *)event
{
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInView:keyWindow];//全屏所在的坐标点
    self.mytv_listPoint = [touch locationInView:self.tv_list];//给UICollectionView所在坐标点赋值
    NSLog(@"handleSingleTap!pointx:%f,y:%f",position.x,position.y);
    self.setPopUpView.touchPointX = position.x;
    self.setPopUpView.touchPointY = position.y;
    
    
    //多通道时直接进入设置
    if (cell.model.chanCount == 0 || cell.model.chanCount == 1) {
        if ([cell.model.enableCloud isEqualToString:@"1"]) {
            if (isSimplifiedChinese) {
                self.setPopUpView.cloudBtnView.IconView.image = [UIImage imageNamed:@"openCloud"];
            }else{
                self.setPopUpView.cloudBtnView.IconView.image = [UIImage imageNamed:@"EopenCloud"];
            }
        }else{
            if (isSimplifiedChinese) {
                self.setPopUpView.cloudBtnView.IconView.image = [UIImage imageNamed:@"unopenCloud"];
            }else{
                self.setPopUpView.cloudBtnView.IconView.image = [UIImage imageNamed:@"EunopenCloud"];
            }
        }
        
        [self.setPopUpView setPopUpViewShow];
    }else{
        [self setBtnViewClick];
    }
    
}

#pragma mark - sd卡录像点击事件代理方法
- (void)DeviceDisPlayCellSDVideoClick:(DeviceDisPlayCell *)cell
{
//    NSIndexPath * indexPath = [self.tv_list indexPathForCell:cell];
//    dev_list *listModel = self.dataArr[indexPath.row];
    //NSString *tempStr = [NSString stringWithFormat:@"我点击了%@的SD卡录像",listModel.name];
   // [XHToast showCenterWithText:tempStr];
    
    if (cell.model) {
        if ([cell.model.enableSD isEqualToString:@"1"]) {
            OnlyPlayBackVC * playbackVC = [[OnlyPlayBackVC alloc]init];
            playbackVC.titleName = cell.model.name;
            playbackVC.listModel = cell.model;
            playbackVC.bIsEncrypt = cell.model.enable_sec;
            playbackVC.key = cell.model.dev_p_code;
            playbackVC.isDeviceVideo = YES;
            [self.navigationController pushViewController:playbackVC animated:YES];
        }else{
            [XHToast showCenterWithText:NSLocalizedString(@"未检测到设备上的SD卡", nil)];
        }
    }
}

#pragma mark - 云端录像点击事件代理方法
- (void)DeviceDisPlayCellCloudVideoClick:(DeviceDisPlayCell *)cell
{
    
    if (cell.model) {
        if ([cell.model.enableCloud isEqualToString:@"1"]) {
            OnlyPlayBackVC * playbackVC = [[OnlyPlayBackVC alloc]init];
            // playbackVC.bIsAP = self.bIsAP;
            playbackVC.titleName = cell.model.name;
            playbackVC.listModel = cell.model;
            playbackVC.bIsEncrypt = cell.model.enable_sec;
            playbackVC.key = cell.model.dev_p_code;
            playbackVC.isDeviceVideo = NO;
            [self.navigationController pushViewController:playbackVC animated:YES];
        }else{
            [XHToast showCenterWithText:NSLocalizedString(@"未开通云存储功能，请先开通", nil)];
        }
    }
     
}

#pragma mark - 告警消息点击事件代理方法
- (void)DeviceDisPlayCellAlarmVideoClick:(DeviceDisPlayCell *)cell
{
    
    if (cell.model) {
        AlarmMsgVC *alarmVC = [[AlarmMsgVC alloc]init];
        alarmVC.homeDevID = cell.model.ID;
        [self.navigationController pushViewController:alarmVC animated:YES];
    }
}


//=========================lazy Loading=========================
#pragma mark -----懒加载
//解码器
- (JW_CIPHER_CTX)cipher
{
    if (self.key && self.bIsEncrypt) {
        size_t len = strlen([self.key cStringUsingEncoding:NSASCIIStringEncoding]);
        _cipher =  jw_cipher_create((const unsigned char*)[self.key cStringUsingEncoding:NSASCIIStringEncoding], len);
        NSLog(@"创建cipher：%p",&_cipher);
    }
    return _cipher;
}
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
        [_tv_list registerNib:[UINib nibWithNibName:@"DeviceDisPlayCell" bundle:nil] forCellReuseIdentifier:WEIClOUDCELLT];
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
//背景图（添加设备）
- (UIView *)backNoDeviceView{
    if (!_backNoDeviceView) {
        _backNoDeviceView = [[UIView alloc]init];
    }
    return _backNoDeviceView;
}
//无设备时的添加按钮
- (UIButton *)addDeviceBtn{
    if (!_addDeviceBtn) {
        _addDeviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _addDeviceBtn;
}

//无设备时的添加设备提示Label
- (UILabel *)tipLb{
    if (!_tipLb) {
        _tipLb = [[UILabel alloc]init];
    }
    return _tipLb;
}


//无设备时的底部的文字以及按钮
- (UILabel *)bottomTipLb{
    if (!_bottomTipLb) {
        _bottomTipLb = [[UILabel alloc]init];
        _bottomTipLb.text = NSLocalizedString(@"还没有设备？快去逛逛吧", nil);
        _bottomTipLb.font = FONT(15);
        _bottomTipLb.textColor = [UIColor grayColor];
        _bottomTipLb.textAlignment = NSTextAlignmentCenter;
    }
    return _bottomTipLb;
}

//商城按钮
- (UnderlineBtn *)shopBtn{
    if (!_shopBtn) {
        _shopBtn = [[UnderlineBtn alloc]init];
        _shopBtn.titleLabel.font = FONT(15);
        [_shopBtn setColor:MAIN_COLOR];
        [_shopBtn setTitle:NSLocalizedString(@"商城", nil) forState:UIControlStateNormal];
        [_shopBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        [_shopBtn addTarget:self action:@selector(clickShop) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shopBtn;
}


#pragma mark ----- 设置能力集合
///设置能力集合
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

//处理数据只拿到(自己的设备&&支持云存的)
- (NSMutableArray *)supportCloudofMine:(NSMutableArray *)tempArr{
    MySingleton *singleton = [MySingleton shareInstance];
    for(dev_list *listModel in tempArr){
        if (![listModel.owner_name isEqualToString:singleton.userNameStr]) {
            [tempArr removeObject:listModel];
        }
    }
    for (dev_list *listModel in tempArr) {
        [self setDeviceFeature:listModel];
        if (!self.feature.isCloudStorage) {
            [tempArr removeObject:listModel];
        }
    }
    return tempArr;
}


//头部视图懒加载
-(UIView *)headView{
    if (!_headView) {
        _headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, headViewHeight+14)];
        _headView.backgroundColor = BG_COLOR;
    }
    return _headView;
}

//点击设置按钮弹出框
- (DeviceSetPopUpView *)setPopUpView
{
    if (!_setPopUpView) {
        _setPopUpView = [[DeviceSetPopUpView alloc]initWithframe:CGRectZero];
        _setPopUpView.delegate = self;
    }
    return _setPopUpView;
}

#pragma mark - 分享的弹框
- (SharedSheetView *)shareSheetView
{
    if (!_shareSheetView) {
        _shareSheetView = [[SharedSheetView alloc]initWithframe:CGRectZero];
        _shareSheetView.delegate = self;
    }
    return _shareSheetView;
}

- (NSString *)xy_noDataViewMessage {
    return @"";
}


@end
