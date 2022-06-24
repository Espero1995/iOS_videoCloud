//
//  RealTimeVideoVC.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/13.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "RealTimeVideoVC.h"
#import "PassageWay_t.h"
#import "MoveCollectionView.h"
#import "ZCTabBarController.h"
#import "SZCalendarPicker.h"
#import "XHToast.h"
#import "VideoModel.h"
#import "ZCVideoTimeModel.h"
#import "WeiCloudListModel.h"
#import "TimeListModel.h"
#import "PushMsgModel.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "SegmentViewController.h"

#import "JWOpenSdk.h"
#import "JWPlayerManage.h"
#import "JWDeviceRecordFile.h"
/*单屏幕view*/
#import "OnlyPlayBackVC.h"
/*返回按钮视图*/
#import "BackBtnView.h"

/*滚轮按钮显示*/
#import "ZMRocker.h"
/*工具条显示*/
#import "controlViewInFullScreen.h"
/*云存储界面*/
#import "MyCloudStorageVC.h"
/*能力集信息*/
#import "FeatureModel.h"
#import "FileVideoController.h"
#import "FileImageController.h"
#import "FileVC.h"
/*分享视频到微信*/
#import "ShareVideoToWeixinVC.h"
#import "FriendsSharedVC.h"
#import "AccountLoginNewVC.h"
#import "BaseNavigationViewController.h"
//警告框
#import "SGAlertView.h"
//设置界面
#import "GeneralDeviceSettingVC.h"
#import "SpecialDeviceSettingVC.h"
#import "CancelShareSettingVC.h"
//分享的弹框
#import "SharedSheetView.h"
//录像回放界面
#import "OnlyPlayBackVC.h"
#import "FileModel.h"
#import "electronicControlView.h"

//多通道选择
#import "MultiChannelView.h"
#import "MultiChannelModel.h"
#import "chansModel.h"

static const CGFloat MinimumPressDuration = 0.3;
#define InitScreenNum_4 4
#define InitScreenNum_1 1

@interface RealTimeVideoVC ()
<
    MoveCollectionViewDelegate,
    MoveViewCell_cDelegete,
    MoveCollectionCellViewDelegete,
    MoveCollectionCellViewDataSoure,
    UIScrollViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UIGestureRecognizerDelegate,
    BackBtnViewDelegate,//返回按钮代理协议
    controlViewInFullScreenDelegate,//工具栏的代理协议
    ZMRockerDelegate,//滚轮按钮显示协议
    SharedSheetViewDelegate,
    electronicControlViewDelegate,
    MultiChannelViewDelegate
>
@property (weak, nonatomic) IBOutlet UIView *btnBack;
@property (weak, nonatomic) IBOutlet UIView *VideoViewBack;
@property (weak, nonatomic) IBOutlet UIButton *btn_stop;
@property (weak, nonatomic) IBOutlet UIButton *btn_sound;
@property (weak, nonatomic) IBOutlet UIButton *btn_screen;//中间的分屏按钮
@property (weak, nonatomic) IBOutlet UIButton *btn_hd;
/*三码流选择框*/
@property (strong, nonatomic) IBOutlet UIView *threeStreamView;
/*全屏时的三码流选择框*/
@property (nonatomic,strong) UIView *fullScreenthreeStreamView;
/*全屏的流畅按钮*/
@property (nonatomic,strong) UIButton *fd_fullBtn;
/*全屏的标清按钮*/
@property (nonatomic,strong) UIButton *sd_fullBtn;
/*全屏的高清按钮*/
@property (nonatomic,strong) UIButton *hd_fullBtn;
@property (weak, nonatomic) IBOutlet UIButton *btn_full;

/*截图按钮*/
@property (strong, nonatomic) IBOutlet UIButton *cameraBtn;
/*录像按钮*/
@property (strong, nonatomic) IBOutlet UIButton *videoBtn;
/*对讲按钮*/
@property (strong, nonatomic) IBOutlet UIButton *talkBtn;
/*sd卡存储按钮*/
@property (strong, nonatomic) IBOutlet UIButton *sdBtn;
/*云存按钮*/
@property (strong, nonatomic) IBOutlet UIButton *cloudBtn;

@property (weak, nonatomic) IBOutlet MoveCollectionView *collectionView;
@property (nonatomic,strong) NSIndexPath *selectIndexPath;//这个是在播放器里面，标记的是cell的index，selectIndex，标记的是这个在视频列表进来的时候index
@property (nonatomic,strong) NSArray *dataArr;

@property (nonatomic,assign) int cellTag;

@property (nonatomic,assign) int control_num;
/*列表消失的背景按钮*/
@property (nonatomic,strong)UIButton *disBtn;

/*通道列表选择*/
@property (nonatomic,strong)MultiChannelView *multiTabView;
/*播放速度*/
@property (nonatomic,assign)int speedInt;
/*是否播放*/
@property (nonatomic,assign)BOOL againPlay;
/*是否可以截屏*/
@property (nonatomic,assign)BOOL isCanCut;
/*是否全屏*/
@property (nonatomic,assign)BOOL isFull;
/*是否为直播*/
@property (nonatomic,assign)BOOL isLive;
/*是否正在录像*/
@property (nonatomic,assign)BOOL isRecord;

/*进度条定位的秒*/
@property (nonatomic,copy)NSString *secStr;
/*操作异步串行队列*/
@property (nonatomic,strong)dispatch_queue_t myActionQueue;
/*具体时间*/
@property (nonatomic,copy)NSString *timeMinStr;

@property (nonatomic,strong)NSMutableDictionary *tagDic;

@property (nonatomic,assign)CGRect oldRect;

@property (nonatomic,assign)NSIndexPath *clickAddBtnIndexPath;

@property (nonatomic,strong)MoveViewCell_c *clickCell;

@property (nonatomic, strong)UIView *deleteBgView;

@property (nonatomic, strong)UIImageView *deleteImageV;

@property (nonatomic, assign)CGRect  normalCellRect;
/*通道名称*/
@property (nonatomic, strong) NSMutableArray *chanName_arr;
/*返回按钮视图*/
@property (nonatomic,strong) BackBtnView *BackBtnView1;

/*滚轮按钮显示*/
@property (nonatomic,strong) ZMRocker *ZMRocker1;
/*工具条显示*/
@property (nonatomic,strong) controlViewInFullScreen *controlFunctionView;
@property (nonatomic, strong) electronicControlView* electronicControlV;/**< 电子控制view */

/*获取到录制的那个button*/
@property (nonatomic,strong) UIButton *recordBtn;
/*设备列表数组*/
@property (nonatomic,strong) NSMutableArray *deviceData;
@property (nonatomic,strong) dev_list *VideolistModel;

/*对讲的overView*/
@property (nonatomic,strong) UIView *ovreView;
@property (nonatomic,assign) CGFloat heigh_v;
@property (nonatomic,assign) int playBack_h;
/*当前选择的通道*/
@property (nonatomic,strong) NSIndexPath *currentSelectIndexPath;

@property  BOOL isAppear;//用来显示工具条是否显示
@property (nonatomic,assign)BOOL IsRockLock;

@property (nonatomic,copy)NSString *cutImageID;//截取当前正确的cell的id的图片

/*能力集信息的model*/
@property (nonatomic,strong)FeatureModel *feature;

@property (nonatomic,strong)NSTimer *timer;

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSTimer *shortCutShowTimer;/**< 截屏或录像缩略图消失的定时器 */

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIImageView *cutImage;
/** 标识视频快捷的背景 */
@property (nonatomic, strong) UIView *videoBgView;
/** video图片 */
@property (nonatomic, strong) UIImageView *videoLogo;

@property (nonatomic, strong) UIImageView *animationImageView;/**< 半双通对讲动画 */

@property (nonatomic, strong)UIView *imageBgView;/**< 对讲背景图 */

@property (nonatomic, assign) BOOL bIsPortraitScreen;/**< 用来标记当前是否是横屏状态还是竖屏，yes:竖屏 */

@property (nonatomic,assign) JWVideoTypeStatus videoTypeStatus;//当前是什么清晰度

@property (nonatomic, assign) BOOL bIsStratPlaying;/**< 用来标记当前录像是否已经开始播放。取流不算，正在解码成功才算。 */

@property (nonatomic, assign) BOOL bIsAP;/**< ap模式播放 */

@property (nonatomic, assign) BOOL b_I_Frame_Start;/**< I帧已经开始播放 */

@property (nonatomic, assign) BOOL b_Video_Play_fail;/**< 视频播放失败，退出不截图 */

@property (nonatomic,strong) SharedSheetView *shareSheetView;//分享的弹框
//底部的增值服务View
@property (strong, nonatomic) IBOutlet UIView *ValueAddedServiceView;
//分享者的名字
@property (strong, nonatomic) IBOutlet UILabel *sharedNameLb;
//红点闪烁
@property (nonatomic,strong) UIView *redDotView;
@property (strong, nonatomic) IBOutlet UIButton *AddValueBtn;

/**
 * @brief 记录当前页面下的临时 MultiChannelModel
 * @discussion 使用该字段的目的：因为此处做法是通道通过选择后，保存到本地的方法将model传值(主要这两个字段传入chanCode和chanId)到SDK库里，这样就能保证我选择是哪个通道了(cell里记录了对应的channelModel属性)；然后进入录像回放后，业务要求上是仍可以选择自己想要的通道【也是通过选择保存本地的方式传值】，那么我返回到实时界面时【此界面】，会导致播放的就是刚才在录像回放里的ChanCode和chanId了,所以才引入该字段来保存这个界面上的通道Model
 */
@property (nonatomic, strong) MultiChannelModel *tempChannelModel;

@end

@implementation RealTimeVideoVC
{
    /*移动删除*/
    BOOL delete;
    /*判断是否开启声音*/
    BOOL isCloseSound;
    /*判断是否开启对讲功能*/
    BOOL isCloseTalk;
}

//=========================system=========================
#pragma mark - VC的生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    self.selectIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];//默认选中的是00.，并且横屏单屏播放
    [UIApplication sharedApplication].idleTimerDisabled = YES;//设置屏幕常亮
    
    [MultiChannelDefaults clearChannelModel];
    //判断是否是多通道的。
    if (!self.isMultiChannel) {
        _chanName_arr = [NSMutableArray array];
        if ([[self.chan_alias allKeys] count] > 0) {
            int num = (int)[[self.chan_alias allKeys] count];
            for (int i = 0; i < num; i++) {
                NSString * key = [NSString stringWithFormat:@"%d",i];
                NSString * str = [self.chan_alias objectForKey:key];
                [_chanName_arr addObject:str];
            }
        }
        self.btn_sound.jp_acceptEventInterval = 0.5f;
        self.videoBtn.jp_acceptEventInterval = 1.0f;
        if (self.videoMode == VideoMode_AP) {
            self.bIsAP = YES;
        }else{
            self.bIsAP = NO;
        }
        self.b_I_Frame_Start = NO;
        self.b_Video_Play_fail = NO;
        
        NSString * screenStausStr = [unitl getDataWithKey:SCREENSTATUS];
        if ([screenStausStr isEqualToString:SHU_PING]) {//竖屏
            [SXLReachability SXL_hasNetwork:^(ReachabilityStatus netStatus) {
                if (netStatus == ReachabilityStatusReachableViaWWAN) {
                    [Toast showInfo:netWorkReminder];
                    [self automaticPlay];
                }
                else
                {
                    [self automaticPlay];
                }
            }];
        }else{//横屏
            [self.btn_full setImage:[UIImage imageNamed:@"small_n"] forState:UIControlStateNormal];
            self.threeStreamView.hidden = YES;
            self.btnBack.hidden = YES;
            self.bIsPortraitScreen = NO;
            [self rightHengpinAction_xiugai];
            [self automaticPlay];
        }
        
    }else{
        [self automaticPlay];
    }
    
    
    
    
}
//销毁通知
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark ------------ view将要显示消失
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   // [self btnStopClick:self.btn_stop];
    if (self.isCanCut) {
        [self backCutImage];
    }
    [self saveVideoPlayerParameters];//保存播放器的声音与清晰度等参数状态
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    [UIApplication sharedApplication].idleTimerDisabled = NO;//设置屏幕关闭常亮
    [self destroyVideoAudio];
}


#pragma mark - 保存播放器的声音与清晰度等参数状态
- (void)saveVideoPlayerParameters
{
    NSString *isCloseSoundStr = [NSString stringWithFormat:@"%d",isCloseSound];
    NSString *videoClarity;
    if (self.videoTypeStatus == JWVideoTypeStatusHd) {
        videoClarity = @"JWVideoTypeStatusHd";
    }else if (self.videoTypeStatus == JWVideoTypeStatusFluency){
        videoClarity = @"JWVideoTypeStatusFluency";
    }else{
        videoClarity = @"JWVideoTypeStatusNomal";
    }
    NSDictionary * dic = @{@"isCloseSound":isCloseSoundStr,@"videoClarity":videoClarity};
    [unitl saveDataWithKey:VideoPlayerParameters Data:dic];
}

#pragma mark  --------------  UI
- (void)viewDidLoad {
    [super viewDidLoad];
    //是否开启功能点
    [self initIsOpenFunction];
    //能力集合model初始化
    self.feature = [[FeatureModel alloc]init];
    //设置能力集合
    [self setDeviceFeature:self.listModel];
    [self setUpUI];
    [self setCollectionViewParameters];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.isAppear = 0;
    self.IsRockLock = NO;
    self.bIsPortraitScreen = YES;
    self.bIsStratPlaying = NO;
    [self addObserver];
    [self loadPublicListData];
    
    //为了使得选择三码流的view消失
    UITapGestureRecognizer *threeStreamTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(threeStreamViewTapped:)];
    threeStreamTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:threeStreamTap];
    
    if (isSimplifiedChinese) {
        [self.AddValueBtn setImage:[UIImage imageNamed:@"ValueAddedServices"] forState:UIControlStateNormal];
    }else{
        [self.AddValueBtn setImage:[UIImage imageNamed:@"EValueAddedServices"] forState:UIControlStateNormal];
    }
    
}

-(void)threeStreamViewTapped:(UITapGestureRecognizer*)tap
{
    self.threeStreamView.hidden = YES;
    self.fullScreenthreeStreamView.hidden = YES;
}

- (void)automaticPlay
{
    [self automaticPlayStart];
}

#pragma mark 【自动播放】自动根据点击来的cell的model信息，进行播放
- (void)automaticPlayStart
{
    [self getVideoAddress];
}

//=========================init=========================
#pragma mark ----- 创建全屏时的控件
- (void)createFullScreenControls{
    //工具条的显示
    [self.view addSubview:self.controlFunctionView];
    [self.controlFunctionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-16);
        make.right.equalTo(self.view.mas_right).offset(-30);
        make.size.mas_equalTo(CGSizeMake(0.7*iPhoneHeight, 0.7*iPhoneHeight/9));
    }];
    [self.view addSubview:self.electronicControlV];
    [self.electronicControlV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(16);
        make.right.equalTo(self.view.mas_right).offset(-30);
        make.size.mas_equalTo(CGSizeMake(150, 0.6*iPhoneHeight/9));
    }];
    
    //返回按钮
    [self.view addSubview:self.BackBtnView1];
    [self.BackBtnView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];

    //滚轮按钮显示2.0
    [self.view addSubview:self.ZMRocker1];
    [self.ZMRocker1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).offset(-156);
        if (iPhone_X_TO_Xs) {
            make.left.equalTo(self.view.mas_left).offset(50);
        }else{
            make.left.equalTo(self.view.mas_left).offset(25);
        }
        make.size.mas_equalTo(CGSizeMake(117, 117));
    }];
}

//更新横屏大屏模式的界面的UI
- (void)updateUI_FullScreen
{
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
    self.normalCellRect = cell.frame;
    [unitl saveDataWithKey:SCREENSTATUS Data:HENG_PING];
    
    //声音
    if (isCloseSound) {
        [self.controlFunctionView.voiceBtn setBackgroundImage:[UIImage imageNamed:@"realTimejingyin_n"] forState:UIControlStateNormal];
    }else{
        [self.controlFunctionView.voiceBtn setBackgroundImage:[UIImage imageNamed:@"realTimeShengyin_n"] forState:UIControlStateNormal];
    }
    
    if(self.videoTypeStatus == JWVideoTypeStatusHd){
        [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_hd", nil)] forState:UIControlStateNormal];
    }else if (self.videoTypeStatus == JWVideoTypeStatusNomal){
        [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_sd", nil)] forState:UIControlStateNormal];
    }else if (self.videoTypeStatus == JWVideoTypeStatusFluency){
        [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_fd", nil)] forState:UIControlStateNormal];
    }
    //判断是否关闭视频播放
    if (cell.isPlay == YES) {
        [self.controlFunctionView.suspendBtn setBackgroundImage:[UIImage imageNamed:@"realTimePause_n"] forState:UIControlStateNormal];
    }
    //判断是否对讲
    if (isCloseTalk == YES) {
        [self.controlFunctionView.talkBtn setBackgroundImage:[UIImage imageNamed:@"realTimeTalk_n"] forState:UIControlStateNormal];
    }else{
        [self.controlFunctionView.talkBtn setBackgroundImage:[UIImage imageNamed:@"realTimeTalk_n"] forState:UIControlStateNormal];//realTimeTalk_close
    }
    //判断是否在录制
    if (self.isRecord == YES) {
        [self.controlFunctionView.videoBtn setBackgroundImage:[UIImage imageNamed:@"zirealTimeVideo_close"] forState:UIControlStateNormal];
    }else{
        [self.controlFunctionView.videoBtn setBackgroundImage:[UIImage imageNamed:@"zirealTimeVideo_n"] forState:UIControlStateNormal];
    }
}

#pragma mark ----- 退出全屏时移除控件
- (void)removeFullScreenControls{
    [self.controlFunctionView removeFromSuperview];
    [self.electronicControlV removeFromSuperview];
    [self.BackBtnView1 removeFromSuperview];
    [self.ZMRocker1 removeFromSuperview];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

//通知
- (void)addObserver
{
    //进入后台停止播放
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopAllVideo:) name:BEBACKGROUNDSTOP object:nil];
    //进入前台开始播放
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startAllVideo:) name:BEBEFORSTART object:nil];
    //码流连接失效停止播放
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notOnlineStopVideo:) name:ONLINESTREAM object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updatePlayImage) name:PLAYFAIL object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopPlayMovie) name:PLAYSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeScreenNumValue:) name:DOUBLETAPNOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeSelectedIndex:) name:MOVEINDEXNOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(LongPressGestureChangeSelectedIndex:) name:CHANGGESELECTEDVALUE object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moveToDelete:) name:MOVETODELETENOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stop_PlayMovie) name:HIDELOADVIEW object:nil];
}

//设置页面UI样式
- (void)setUpUI
{
    [UIApplication sharedApplication].statusBarHidden = NO;
    if (!self.titleName) {
        self.title = @"视频监控";
    }else{
        self.title = self.titleName;
    }
    

    //设置按钮
    if (!self.isMultiChannel) {
        UIButton *setBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        [setBtn setImage:[UIImage imageNamed:@"realTimeSet"] forState:UIControlStateNormal];
        [setBtn setImage:[UIImage imageNamed:@"realTimeSet"] forState:UIControlStateHighlighted];
        [setBtn addTarget:self action:@selector(jumpToSetting) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* setRightItem = [[UIBarButtonItem alloc]initWithCustomView:setBtn];
        
        //设置2个按钮之间的间距
        UIBarButtonItem *itemSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        itemSpace.width = 15;
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: setRightItem,itemSpace,nil]];
    }
    
    
    if (self.bIsAP) {
        //      self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"device_share"] style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
    }
    
    
    //导航栏按钮
    [self cteateNavBtn];
    //初始化位全屏
    self.isFull = NO;
    //初始化未录制
    self.isRecord = NO;
    //初始化是否重新播放
    self.againPlay = NO;
    //创建按钮相关
    [self setUpBtn];
    //添加播放界面
   // [self addPlayVideoView];
    
    //将垃圾桶（删除）加到视图中
    [self.view addSubview:self.deleteBgView];
    [self.deleteBgView addSubview:self.deleteImageV];
    [self.deleteBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.top.mas_equalTo(self.view.mas_top).offset(20);
        make.height.mas_equalTo(@44);
    }];
    [self.deleteImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.deleteBgView.center);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    UILongPressGestureRecognizer * longGestture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(talkWithLongPress:)];
    longGestture.minimumPressDuration = 0.5f;
    [self.talkBtn addGestureRecognizer:longGestture];
}

#pragma mark ------通知进入后台停止播放
-(void)stopAllVideo:(NSNotification *)noit
{
    [self btnStopClick:self.btn_stop];
}

#pragma mark ------通知进入前台开始重新播放
-(void)startAllVideo:(NSNotification *)noit
{
    if ([[unitl currentTopViewController]isKindOfClass:[RealTimeVideoVC class]]) {
        [self getVideoAddress];
    }else{
        NSLog(@"进入前台，当前不是RVC，不播放~");
    }
}
#pragma mark ------码流连接失效停止播放
-(void)notOnlineStopVideo:(NSNotification *)noit
{
    [self btnStopClick:self.btn_stop];
}

#pragma mark ------ collectionview 和代理方法
- (void)setCollectionViewParameters{
    _dataArr = @[@"1",@"2",@"3",@"4"];
    _collectionView.moveDelegate = self;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.shakeLevel = 0.5f;
    _collectionView.cellCount = InitScreenNum_4;
    _collectionView.backgroundColor = RGB(50, 50, 50);
    _collectionView.scrollEnabled = NO;
    _collectionView.currentState = MoveCellStateOneScreen;//默认，竖屏单屏播放
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.VideoViewBack.mas_top).offset(0);
        make.left.equalTo(self.VideoViewBack.mas_left).offset(0);
        make.right.equalTo(self.VideoViewBack.mas_right).offset(0);
        make.bottom.equalTo(self.VideoViewBack.mas_bottom).offset(-44);
    }];
    [_collectionView setMinimumPressDuration:MinimumPressDuration];
}
#pragma mark ==== 返回按钮
- (void)returnVC
{
    if (self.bIsAP) {
        //调用的退出登录
        ZCTabBarController *tab = (ZCTabBarController *)self.tabBarController;
        [tab stopTimer];
        [tab deallocVideoSdk];
        BOOL isLogin = NO;
        NSNumber *isLoginNum = [NSNumber numberWithBool:isLogin];
        [[NSUserDefaults standardUserDefaults]setObject:isLoginNum forKey:ISLOGIN];
        [[NSUserDefaults standardUserDefaults] synchronize];

        //判断根式图是哪一个
        UIWindow *window =  [[UIApplication sharedApplication] keyWindow];
        if ([window.rootViewController isKindOfClass:[BaseNavigationViewController class]]) {
            [self.tabBarController dismissViewControllerAnimated:YES completion:^{
                AccountLoginNewVC *loginVC = [[AccountLoginNewVC alloc]init];
                BaseNavigationViewController *NVC = [[BaseNavigationViewController alloc]initWithRootViewController:loginVC];
                window.rootViewController = NVC;
            }];
        }
        else{
            //LoginViewController *loginVC = [[LoginViewController alloc]init];
            AccountLoginNewVC *loginVC = [[AccountLoginNewVC alloc]init];
            BaseNavigationViewController *NVC = [[BaseNavigationViewController alloc]initWithRootViewController:loginVC];
            window.rootViewController = NVC;
        }
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//=========================method=========================
#pragma mark ----- 添加播放视图
- (void)addPlayVideoView
{
    self.isCanCut = NO;
}

#pragma mark ------获取实时音视频地址
- (void)getVideoAddress
{
    NSLog(@"设备在不在线：%@",self.listModel.status == 1 ? @"在线":@"不在线");
    [[HDNetworking sharedHDNetworking]canleAllHttp];
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.selectIndexPath];
    
    JWPlayerManage * playerManage = [JWOpenSdk createPlayerManageWithDevidId:self.listModel.ID ChannelNo:cell.chan_way];
    cell.videoManage = playerManage;
    [cell.videoManage JWPlayerManageSetPlayerView:cell.playView];
    [cell.loadView showAnimated:YES];
    cell.isPlay = YES;
    if (self.listModel.status == 1) {
        cell.addBtn.hidden = YES;
        cell.addBtn_new.hidden = YES;
        cell.reStartBtn.hidden = YES;
        cell.loadView.hidden = NO;
    }else{
        if (!self.bIsAP) {//注释：这边的ap模式下，我们获取到的status的状态是不在线，所以特别判断了。
            [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
            cell.loadView.hidden = YES;
        }else{
            cell.loadView.hidden = YES;
            cell.addBtn.hidden = YES;
            cell.addBtn_new.hidden = YES;
            cell.reStartBtn.hidden = YES;
        }
    }
    self.cutImageID = self.listModel.ID;
    cell.chan_id = cell.chan_way;
    cell.closeBtn.hidden = YES;
    
    //视图和model绑定
    cell.listModel = self.listModel;
    NSLog(@"【绑定】测试cellTag=== 0 updatePlayImage === self.selectIndexPath==%@==cell.listModel:%@===self.listModel:%@",self.selectIndexPath,cell.listModel,self.listModel);
    
    
    NSLog(@"chanId:%d=====chanWay:%d",cell.chan_id,cell.chan_way);
    
    //正在直播
    self.isLive = YES;
    self.videoMode  = VideoMode_Normal;
    
    switch (self.videoTypeStatus) {
        case JWVideoTypeStatusHd:
        {
            cell.videoTypeStatus = JWVideoTypeStatusHd;
        }
            break;
        case JWVideoTypeStatusNomal:
        {
            cell.videoTypeStatus = JWVideoTypeStatusNomal;
        }
            break;
        case JWVideoTypeStatusFluency:
        {
            cell.videoTypeStatus = JWVideoTypeStatusFluency;
        }
            break;
            
        default:
            break;
    }
    
    [cell.videoManage JWStreamPlayerManagePlayVideoWithVideoType:cell.videoTypeStatus BIsEncrypt:cell.listModel.enable_sec Key:cell.listModel.dev_p_code BIsAP: self.bIsAP completionBlock:^(JWErrorCode errorCode) {
        if (errorCode == JW_SUCCESS) {
            self.isCanCut = YES;//播放成功可以截图
            NSLog(@"播放视频成功");
        }else
        {
            [self stop_PlayMovie];
            if (errorCode == JW_FAILD) {
                NSLog(@"播放视频失败");
            }if (errorCode == JW_PLAY_NO_PERMISSION) {
                NSLog(@"实时录像无权限");
                [XHToast showCenterWithText:NSLocalizedString(@"非分享时间段内无法观看", nil)];
            }
            self.isCanCut = NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
        }
    }];
    //重新取流时声音开关的判断
    if (isCloseSound == NO) {
        [cell.videoManage JWPlayerManageSetAudioIsOpen:YES];
    }else{
        [cell.videoManage JWPlayerManageSetAudioIsOpen:NO];
    }
}

#pragma mark - 关闭加载视频动画
- (void)stop_PlayMovie{
    _timer =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hidden_loadview) userInfo:nil repeats:YES];
    [self hidden_loadview];
    self.b_I_Frame_Start = YES;
}
- (void)hidden_loadview
{
    self.bIsStratPlaying = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.selectIndexPath];
        [cell.loadView hide];
    });
    [self stopTimer];
}
- (void)stopTimer
{
    [_timer invalidate];   // 将定时器从运行循环中移除，
    _timer = nil;
}

#pragma mark ------获取实时音视频地址【由原来的只单屏播放变为四分屏播放】
- (void)getVideoAddressNewWithDeviceID:(NSString *)deviceID ChannelNo:(NSInteger)channelNo
{
    NSLog(@"【点击+号】获取实时音视频地址【由原来的只单屏播放变为四分屏播放】：deviceID:%@===channelNo:%ld==self.bIsEncrypt:%@===self.key:%@",deviceID,(long)channelNo,self.bIsEncrypt?@"YES":@"NO",self.key);
//    [[HDNetworking sharedHDNetworking]canleAllHttp];
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.selectIndexPath];
    
    [cell.loadView showAnimated:YES];
    JWPlayerManage * playerManage = [JWOpenSdk createPlayerManageWithDevidId:deviceID ChannelNo:channelNo];
    cell.videoManage = playerManage;
    [cell.videoManage JWPlayerManageSetPlayerView:cell.playView];
    cell.isPlay = YES;

    if (self.listModel.status == 1) {
        cell.addBtn.hidden = YES;
        cell.addBtn_new.hidden = YES;
        cell.reStartBtn.hidden = YES;
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
    }
    
    cell.chan_id = cell.chan_way;
    cell.closeBtn.hidden = YES;
    self.isLive = YES;//正在直播
    
    self.videoMode  = VideoMode_Normal;//后期有ap，这边用来判断的
    switch (self.videoTypeStatus) {
        case JWVideoTypeStatusHd:
        {
            cell.videoTypeStatus = JWVideoTypeStatusHd;
        }
            break;
        case JWVideoTypeStatusNomal:
        {
            cell.videoTypeStatus = JWVideoTypeStatusNomal;
        }
            break;
        case JWVideoTypeStatusFluency:
        {
            cell.videoTypeStatus = JWVideoTypeStatusFluency;
        }
            break;
            
        default:
            break;
    }
    
    [cell.videoManage JWStreamPlayerManagePlayVideoWithVideoType:cell.videoTypeStatus BIsEncrypt:cell.listModel.enable_sec Key:cell.listModel.dev_p_code BIsAP:self.bIsAP completionBlock:^(JWErrorCode errorCode) {
        if (errorCode == JW_SUCCESS) {
            self.isCanCut = YES;//播放成功可以截图
            NSLog(@"播放视频成功");
        }else
        {
            if (errorCode == JW_FAILD) {
                NSLog(@"播放视频失败");
                [cell.loadView hide];
            }if (errorCode == JW_PLAY_NO_PERMISSION) {
                NSLog(@"实时录像无权限");
                [cell.loadView hide];
                [XHToast showCenterWithText:NSLocalizedString(@"非分享时间段内无法观看", nil)];
            }
            self.isCanCut = NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
        }
    }];
    //重新取流时声音开关的判断
    if (isCloseSound == NO) {
        [cell.videoManage JWPlayerManageSetAudioIsOpen:YES];
    }else{
        [cell.videoManage JWPlayerManageSetAudioIsOpen:NO];
    }
}

#pragma mark - 切换主子码
- (void)changeVideoDefinition
{
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.selectIndexPath];
    cell.isPlay = YES;
    
    switch (self.videoTypeStatus) {
        case JWVideoTypeStatusHd:
        {
            cell.videoTypeStatus = JWVideoTypeStatusHd;
        }
            break;
        case JWVideoTypeStatusNomal:
        {
            cell.videoTypeStatus = JWVideoTypeStatusNomal;
        }
            break;
        case JWVideoTypeStatusFluency:
        {
            cell.videoTypeStatus = JWVideoTypeStatusFluency;
        }
            break;
            
        default:
            break;
    }
    [cell.videoManage JWPlayerManageChangePlayVideoVideoType:cell.videoTypeStatus completionBlock:^(JWErrorCode errorCode) {
        if (errorCode == JW_SUCCESS) {
            self.isCanCut = YES;//播放成功可以截图
            [cell.videoManage JWPlayerManageEmptyVideoDataCompletionBlock:^(JWErrorCode errorCode) {
                if (errorCode == JW_SUCCESS) {
                    NSLog(@"切换码率成功后，清空视频缓存【成功】");
                }else{
                    NSLog(@"切换码率成功后，清空视频缓存【失败】");
                }
            }];
            NSLog(@"切换视频码率成功");
        }if (errorCode == JW_FAILD) {
            self.isCanCut = NO;
            NSLog(@"切换视频码率失败");
            [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
        }if (errorCode == JW_PLAY_NO_PERMISSION) {
            self.isCanCut = NO;
            [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
            NSLog(@"切换视频码率失败，实时录像无权限");
            [XHToast showCenterWithText:NSLocalizedString(@"非分享时间段内无法观看", nil)];
        }
    }];
}

//=========================delegate=========================
#pragma mark ----- UICollectionViewDelegate
- (NSArray *)dataSourceArrayOfCollectionView:(MoveCollectionView *)collectionView{
    return _dataArr;
}
- (void)dragCellCollectionView:(MoveCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray{
    _dataArr = newDataArray;
}
//最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

//最小列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark ------ UICollectionView代理方法
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
   return [self currentStateCellSize];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//分组数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//每组cell个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _collectionView.cellCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    // 每次先从字典中根据IndexPath取出唯一标识符
    NSString *identifier = _dataArr[indexPath.row];
    [collectionView registerNib:[UINib nibWithNibName:@"MoveViewCell_c" bundle:nil] forCellWithReuseIdentifier:identifier];
    MoveViewCell_c *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.delegete = self;
    cell.cellTag = (int)indexPath.row;
     //调试用
//     if (indexPath.row == 0) {
//     cell.backgroundColor = [UIColor redColor];
//     }else if (indexPath.row == 1)
//     {
//     cell.backgroundColor = [UIColor orangeColor];
//     }
//     else if (indexPath.row == 2)
//     {
//     cell.backgroundColor = [UIColor purpleColor];
//     }else if (indexPath.row == 3)
//     {
//       cell.backgroundColor = [UIColor lightGrayColor];
//     }
    return cell;
}

#pragma mark collectionView 点击方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MoveViewCell_c *cell = (MoveViewCell_c *)[collectionView cellForItemAtIndexPath:indexPath];
    NSLog(@"调试：collectionView单击的点击方法indexPath:%@ ====self.selectIndexPath：%@===通道名称：%@",indexPath,self.selectIndexPath,cell.channelModel.chanName);
    [self selectZhuangtai];
    if (self.isFull) {
        //修改工具栏布局
        [self setDeviceFeature:cell.listModel];//todo
        [self.controlFunctionView changeLayoutOfFeature:self.feature.isTalk andCloudDeck:self.feature.isCloudDeck];
    }else{
        [self setDeviceFeature:cell.listModel];//todo
    }
    if (indexPath == self.selectIndexPath) {
        NSLog(@"collection didSelectItem方法index和当前index一样，return");
        return;
    }else{
        if (self.collectionView.currentState == MoveCellStateOneScreen ||
            self.collectionView.currentState == MoveCellStateOneScreen_HengPing) {
            NSLog(@"didSelectItem方法 大屏不加边框");
        }else{
            for (int i = 0; i < 4; i++) {
                NSIndexPath * index = [NSIndexPath indexPathForItem:i inSection:0];
                MoveViewCell_c * tempCell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:index];
                [tempCell.layer setBorderColor:[UIColor clearColor].CGColor];
                if (tempCell.isPlay == YES) {
                    [tempCell.videoManage JWPlayerManageSetAudioIsOpen:NO];
                }
            }
            [cell.layer setBorderColor:MAIN_COLOR.CGColor];
            [cell.layer setBorderWidth:0.5];
            [cell.layer setMasksToBounds:YES];
        }
        self.btn_sound.selected = NO;
        self.btn_hd.selected = NO;
    }
    if (!isCloseSound) {//如果声音按钮打开
        //声音播放
        if (cell.isPlay == YES) {
            [cell.videoManage JWPlayerManageSetAudioIsOpen:YES];
        }else{
            [cell.videoManage JWPlayerManageSetAudioIsOpen:NO];
        }
    }

    
    if (cell.isPlay == YES) {
        //        if (cell.HD == YES) {////需要同步修改
        //            self.btn_hd.selected = YES;
        //        }else{
        //            self.btn_hd.selected = NO;
        //        }
        if (cell.videoTypeStatus == JWVideoTypeStatusNomal) {
            [self.btn_hd setTitle:NSLocalizedString(@"标清", nil) forState:UIControlStateNormal];
            [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_sd", nil)] forState:UIControlStateNormal];
            self.videoTypeStatus = JWVideoTypeStatusNomal;
        }else if (cell.videoTypeStatus == JWVideoTypeStatusHd){
            [self.btn_hd setTitle:NSLocalizedString(@"高清", nil) forState:UIControlStateNormal];
            [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_hd", nil)] forState:UIControlStateNormal];
            self.videoTypeStatus = JWVideoTypeStatusHd;
        }else if (cell.videoTypeStatus == JWVideoTypeStatusFluency){
            [self.btn_hd setTitle:NSLocalizedString(@"流畅", nil) forState:UIControlStateNormal];
            [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_fd", nil)] forState:UIControlStateNormal];
            self.videoTypeStatus = JWVideoTypeStatusFluency;
        }
    }
    self.selectIndexPath = indexPath;
    self.collectionView.selectIndexPath = indexPath;
    NSLog(@"点击section%ld的第%ld个cell===self.selectIndexPath：%@====cell.cellTag:%d===cell.tag:%ld",(long)indexPath.section,indexPath.row,self.selectIndexPath,cell.cellTag,(long)cell.tag);
}

#pragma mark ------工具条隐藏消失
- (void)videoViewBackanimation
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.controlFunctionView.alpha = 1;
        self.electronicControlV.alpha = 1;
        self.BackBtnView1.alpha = 1;
        
    } completion:^(BOOL finished) {
        if (finished) {
            [self performSelector:@selector(videoViewBackHidden) withObject:nil afterDelay:5];
            _isAppear = 0;
        }
    }];
}
- (void)videoViewBackHidden
{
    [UIView animateWithDuration:0.3 animations:^{
        self.controlFunctionView.alpha = 0;
        self.electronicControlV.alpha = 0;
        self.BackBtnView1.alpha = 0;
        self.fullScreenthreeStreamView.hidden = YES;
        if (self.IsRockLock) {
            self.ZMRocker1.hidden = NO;
        }else{
            self.ZMRocker1.hidden = YES;
        }
        _isAppear = 1;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }];
}

- (void)selectZhuangtai{
    if (_isAppear) {
        [self videoViewBackanimation];
        _isAppear = 0;
    }else{
        [self videoViewBackHidden];
        _isAppear = 1;
    }
}

#pragma mark - 通知实现
- (void)updatePlayImage
{
    /*
     NSIndexPath * indexPath = [NSIndexPath indexPathForItem:_cellTag inSection:0];
     NSLog(@"测试cellTag=== 1 updatePlayImage ===cellTag：%d",self.cellTag);
     MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:indexPath];
     cell.reStartBtn.hidden = NO;
     */
   
    if (!self.selectIndexPath) {
        
    }else{
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.selectIndexPath];
        cell.reStartBtn.hidden = NO;
        cell.addBtn.hidden = YES;
        cell.addBtn_new.hidden = YES;
        self.b_Video_Play_fail = YES;
       // [self btnStopClick:self.btn_stop];
    }
}

- (void)stopPlayMovie{
    self.clickCell.loadView.hidden = YES;
}

- (void)changeScreenNumValue:(NSNotification*)noti
{
    if (noti.userInfo) {
        NSString * str = [noti.userInfo objectForKey:@"isBig"];
        NSIndexPath * selecedIndex = [noti.userInfo objectForKey:@"selectIndexPath"];
        self.selectIndexPath = selecedIndex;
        NSLog(@"调试，双击的手势，通知给实时界面当前选中的index==selectIndexPath：%@",self.selectIndexPath);
        if ([str  isEqualToString:@"YES"]) {
            self.btn_screen.selected = YES;
        }else{
            self.btn_screen.selected = NO;
        }
    }
}

#pragma mark - cell被移动后，cell.indexPath 的变化
- (void)changeSelectedIndex:(NSNotification*)noti
{
    if (noti.userInfo) {
        NSIndexPath * moveToIndex = [noti.userInfo objectForKey:@"moveToIndex"];
        self.selectIndexPath = moveToIndex;
        self.cellTag = (int)moveToIndex.row;
        NSLog(@"改变cell位置之后，新的moveindex：%@===self.cellTag:%d",self.selectIndexPath,self.cellTag);
    }
}
//代替didSelected的点击选中改变self.selectIndexPath
- (void)LongPressGestureChangeSelectedIndex:(NSNotification *)noti
{
    if (noti.userInfo) {
        self.selectIndexPath = [noti.userInfo objectForKey:@"selectIndexPath"];
    }
}

- (void)moveToDelete:(NSNotification *)noti//修改过
{
    NSLog(@"通知信息：%@",noti);
    if (noti.userInfo) {
        if (self.isFull) {
            [self refreshMoveTodeleteViewFrameWhenHengPing];
        }else{
            [self refreshMoveTodeleteViewFrameWhenshuPing];
        }
        if ([[noti.userInfo objectForKey:@"message"]isEqualToString:@"delete"]) {
            
            if (self.isFull) {
                self.navigationController.navigationBarHidden = YES;
            }else{
                self.navigationController.navigationBarHidden = NO;
            }
            self.deleteImageV.hidden = NO;
            self.deleteBgView.hidden = NO;
            delete = YES;
            self.deleteBgView.backgroundColor = [UIColor redColor];
            self.deleteImageV.image = [UIImage imageNamed:@"delete_open"];
            
        }else if([[noti.userInfo objectForKey:@"message"]isEqualToString:@"undelete"]){
            
            if (self.isFull) {
                self.navigationController.navigationBarHidden = YES;
            }else{
                self.navigationController.navigationBarHidden = NO;
            }
            self.deleteImageV.hidden = NO;
            self.deleteBgView.hidden = NO;
            delete = NO;
            self.deleteBgView.backgroundColor = MAIN_COLOR;
            self.deleteImageV.image = [UIImage imageNamed:@"delete_close"];
        }
        else
        {
            if (delete) {
                self.title = NSLocalizedString(@"视频监控", nil);
                MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.selectIndexPath];
                cell.listModel = nil;
                cell.channelModel = nil;
                [[NSNotificationCenter defaultCenter]postNotificationName:DELETEPLAYCELL object:nil userInfo:@{@"":@""}];
            }
            if (!self.isFull) {
                self.navigationController.navigationBarHidden = NO;
            }
            self.deleteImageV.hidden = YES;
            self.deleteBgView.hidden = YES;
        }
    }
}
//横屏，全屏的时候
- (void)refreshMoveTodeleteViewFrameWhenHengPing
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];//修改过的删除
    [self.deleteBgView removeFromSuperview];
    [self.deleteImageV removeFromSuperview];
    [self.view addSubview:self.deleteBgView];
    
    [self.deleteBgView addSubview:self.deleteImageV];
    
    [self.deleteBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.top.mas_equalTo(self.view.mas_top).offset(0);
        make.height.mas_equalTo(@44);
    }];
    
    [self.deleteImageV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.deleteBgView.mas_top);
        make.centerX.mas_equalTo(self.deleteBgView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}
//竖屏，正常的时候
- (void)refreshMoveTodeleteViewFrameWhenshuPing
{
    [self.deleteBgView removeFromSuperview];
    [self.deleteImageV removeFromSuperview];
    //    [self.view addSubview:self.deleteBgView];
    [self.navigationController.navigationBar addSubview:self.deleteBgView];
    [self.deleteBgView addSubview:self.deleteImageV];
    [self.deleteBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.top.mas_equalTo(self.view.mas_top).offset(-44);
        make.height.mas_equalTo(@44);
    }];
    
    [self.deleteImageV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.deleteBgView.mas_top);
        make.centerX.mas_equalTo(self.deleteBgView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
}
#pragma mark ====== 根据当前的状态，返回cellsize
- (CGSize)currentStateCellSize
{
    if (self.collectionView.currentState == MoveCellStateFourScreen)
    {
        if (iPhone_6_TO_8 || iPhone_X_TO_Xs) return CGSizeMake(iPhoneWidth/2-0.5,99.5);
        if (iPhone_5_Series) return CGSizeMake(iPhoneWidth/2-0.5,81.5);
        return CGSizeMake(iPhoneWidth/2-0.5,112.33);
    }
    else if(self.collectionView.currentState == MoveCellStateFourScreen_HengPing)
    {
        return CGSizeMake(iPhoneHeight/2-0.5,iPhoneWidth/2);
    }
    else if(self.collectionView.currentState == MoveCellStateOneScreen)
    {
        if (iPhone_6_TO_8 || iPhone_X_TO_Xs) return CGSizeMake(iPhoneWidth-0.5,200);
        if (iPhone_5_Series) return CGSizeMake(iPhoneWidth-0.5,164);
        return CGSizeMake(iPhoneWidth,225);
    }
    else//MoveCellStateOneScreen_HengPing
    {
        //因为这里是横竖屏切换，所以本来是width，height。现在变为height，width。
        return CGSizeMake(iPhoneHeight,iPhoneWidth);
    }
}

#pragma mark ------------- 选择通道按钮和双击放大
#pragma mark - cell上 + 号
- (void)MoveViewCell_cAddBtnClick:(MoveViewCell_c *)cell{
    
    NSIndexPath * indexPath = [_collectionView indexPathForCell:cell];
    self.clickAddBtnIndexPath = indexPath;
    // self.clickCell = cell;
    self.selectIndexPath = self.clickAddBtnIndexPath;
    [self showTableView];
    if (indexPath == self.selectIndexPath) {
        NSLog(@"cell + 号，重复点击，return");
        return;
    }else
    {
        for (int i = 0; i < 4; i++) {
            NSIndexPath * index = [NSIndexPath indexPathForItem:i inSection:0];
            MoveViewCell_c * tempCell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:index];
            [tempCell.layer setBorderColor:[UIColor clearColor].CGColor];
        }
        if (self.collectionView.currentState == MoveCellStateOneScreen ||
            self.collectionView.currentState == MoveCellStateOneScreen_HengPing) {
            NSLog(@"大屏不加边框");
        }else{
            [cell.layer setBorderColor:MAIN_COLOR.CGColor];
            [cell.layer setBorderWidth:1];
            [cell.layer setMasksToBounds:YES];
        }
        // _cellTag = cell.cellTag;//注释：这里的cell.cellTag因为是indexpath.row来的，所以cell移动过后，还是默认为3.
        NSLog(@"测试cellTag=== 2 cell.tag:%d=====indexPath:%@ ===indexPath_test:%@",cell.cellTag,_clickAddBtnIndexPath,indexPath);
    }
}
#pragma mark - 双击图像变大
- (void)cellFullPlay:(VideoModel *)videoModel
{
    [self btnScreenClick:self.btn_screen];
}

#pragma mark - 播放失败，不用选择，直接播放当前通道视频
- (void)MoveViewCell_cReStartBtnClick:(MoveViewCell_c *)cell
{
    NSIndexPath * indexPath = [_collectionView indexPathForCell:cell];
    [self.controlFunctionView.suspendBtn setBackgroundImage:[UIImage imageNamed:@"realTimePause_n"] forState:UIControlStateNormal];
    self.clickAddBtnIndexPath = indexPath;
    self.selectIndexPath = self.clickAddBtnIndexPath;
    NSLog(@"点击cell屏幕了  测试cellTag=== 2【新+号】indexPath：%@",indexPath);
    [self getVideoAddress];
}

#pragma  mark - ------------- 删除过cell，新的选择通道btn
- (void)MoveViewCell_caddBtn_new_Click:(MoveViewCell_c *)cell
{
    for (int i = 0; i<4; i++) {
        NSIndexPath * index = [NSIndexPath indexPathForItem:i inSection:0];
        MoveViewCell_c * newCell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:index];
        [newCell.layer setBorderColor:[UIColor clearColor].CGColor];
    }
    if (self.collectionView.currentState == MoveCellStateOneScreen ||
        self.collectionView.currentState == MoveCellStateOneScreen_HengPing) {
        NSLog(@"大屏不加边框");
    }else{
        [cell.layer setBorderColor:MAIN_COLOR.CGColor];
        [cell.layer setBorderWidth:1];
        [cell.layer setMasksToBounds:YES];
    }
    NSIndexPath * indexPath = [_collectionView indexPathForCell:cell];
    self.clickAddBtnIndexPath = indexPath;
    self.selectIndexPath = self.clickAddBtnIndexPath;
    NSLog(@"测试cellTag=== 2 【新】cell.tag:%d=====indexPath:%@ ===indexPath_test:%@",cell.cellTag,_clickAddBtnIndexPath,indexPath);
    [self showTableView];
}

#pragma mark 删除cell
- (void)MoveViewCell_deleteClick:(MoveViewCell_c *)cell
{
    NSIndexPath * currentIndexPath = [_collectionView indexPathForCell:cell];
    NSDictionary * dic = @{@"currentIndexPath":currentIndexPath};
    self.title = NSLocalizedString(@"视频监控", nil);
    MoveViewCell_c * newCell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.selectIndexPath];
    newCell.listModel = nil;
    newCell.channelModel = nil;
    [[NSNotificationCenter defaultCenter]postNotificationName:DELETEPLAYCELL object:nil userInfo:dic];
}

#pragma mark - 列表展示消失
//展示频道列表
- (void)showTableView
{
    
    [self.view addSubview:self.disBtn];
    [self.view addSubview:self.multiTabView];
    if (self.isFull == YES) {
        [self.multiTabView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset((iPhoneHeight-iPhoneWidth)/2);
            make.top.equalTo(self.view.mas_top).offset(0);
            make.right.equalTo(self.view.mas_right).offset(-(iPhoneHeight-iPhoneWidth)/2);
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
        }];
    }else{
        [self.multiTabView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.btnBack.mas_top).offset(0);
            make.width.mas_equalTo(0.8*iPhoneWidth);
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        }];
    }
    
    
    
}
- (void)disBtnClick
{
    [self.multiTabView removeFromSuperview];
    self.multiTabView = nil;
    
    [self.disBtn removeFromSuperview];
    self.disBtn = nil;
}


#pragma mark - 第二个通道列表的代理
- (void)didSelectedCellIndex:(NSIndexPath *)index WithDeviceModel:(dev_list *)deviceModel isNVR:(BOOL)isNvr
{

    if (isNvr) _chan_way = (int)index.row + 1;
    else _chan_way = 0;//现在会上改成只有ipc类型的设备，没有nvr
    MoveViewCell_c * cell = (MoveViewCell_c *)[self.collectionView cellForItemAtIndexPath:self.selectIndexPath];
    cell.chan_way = (int)index.row + 1;
    cell.listModel = deviceModel;//播放cell和播放的model绑定
    [self setDeviceFeature:cell.listModel];
    NSLog(@"【绑定】的cell index：%@=== cell.listModel：%@=== deviceModel：%@",index,cell.listModel,deviceModel);
    [self disBtnClick];
    self.videoTypeStatus = JWVideoTypeStatusNomal;
    [SXLReachability SXL_hasNetwork:^(ReachabilityStatus netStatus) {
        if (netStatus == ReachabilityStatusReachableViaWWAN) {
            [Toast showInfo:netWorkReminder];
            [self getVideoAddressNewWithDeviceID:deviceModel.ID ChannelNo:_chan_way];
        }
        else
        {
            [self getVideoAddressNewWithDeviceID:deviceModel.ID ChannelNo:_chan_way];
        }
    }];
}

//通道选择代理(单设备多通道)
- (void)didSelectedCellIndex:(NSIndexPath *)index withChannelModel:(MultiChannelModel *)channelModel
{
    [self disBtnClick];
 
    MoveViewCell_c * cell = (MoveViewCell_c *)[self.collectionView cellForItemAtIndexPath:self.selectIndexPath];
    cell.chan_way = (int)index.row + 1;
    cell.channelModel = channelModel;
    [self setDeviceFeature:cell.listModel];
    NSLog(@"【绑定】的cell index：%@=== cell.listModel：%@",index,cell.listModel);
    
    self.title = channelModel.chanName;
    
    [MultiChannelDefaults clearChannelModel];
    [MultiChannelDefaults setChannelModel:channelModel];
    
    [self getVideoAddressNewWithDeviceID:self.dev_id ChannelNo:channelModel.chanId];
}

//该列表下的多通道【区别于上面的方法：此处的多通道时由在获取设备列表时获得】
- (void)didSelectedCellIndex:(NSIndexPath *)index withChansModel:(chansModel *)model
{
    [self disBtnClick];
    
    
    MoveViewCell_c * cell = (MoveViewCell_c *)[self.collectionView cellForItemAtIndexPath:self.selectIndexPath];
//    cell.chan_way = (int)index.row + 1;
    cell.chan_way = (int)model.chan_id;
    
    //设置成与MultiChannelModel一样的数据格式，为了兼容以前的通道【无奈之举】
    MultiChannelModel *tempChannelModel = [[MultiChannelModel alloc]init];
    tempChannelModel.chanId = (int)model.chan_id;
    tempChannelModel.chanCode = @"";
    [MultiChannelDefaults clearChannelModel];
    [MultiChannelDefaults setChannelModel:tempChannelModel];
    cell.channelModel = tempChannelModel;
    
//    cell.chansModel = chansModel;
    [self setDeviceFeature:cell.listModel];
    NSLog(@"【绑定】的cell index：%@=== cell.listModel：%@",index,cell.listModel);
    self.title = model.name;
    [self getVideoAddress];
//    [self getVideoAddressNewWithDeviceID:self.dev_id ChannelNo:0];
}


#pragma mark ------------ 按钮状态初始化
- (void)setUpBtn
{
    [self.btn_screen setImage:[UIImage imageNamed:@"one_n"] forState:UIControlStateSelected];
    
//    [self.cameraBtn setImage:[UIImage imageNamed:@"takePhoto_able"] forState:UIControlStateNormal];
//    [self.videoBtn setImage:[UIImage imageNamed:@"shootVideo_able"] forState:UIControlStateNormal];
//    [self.talkBtn setImage:[UIImage imageNamed:@"talkback_able"] forState:UIControlStateNormal];
    //是否可以截屏
    self.isCanCut = NO;
}

#pragma mark - 云台控制
- (void)ControlFunc
{
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
    NSNumber * chan_num = [NSNumber numberWithInteger:cell.chan_id];
    NSNumber * cmd_num = [NSNumber numberWithInteger:_control_num];
    NSMutableDictionary * changeDic = [NSMutableDictionary dictionary];
    [changeDic setObject:self.listModel.ID forKey:@"dev_id"];
    [changeDic setObject:chan_num forKey:@"chan_id"];
    [changeDic setObject:cmd_num forKey:@"cmd"];
    [changeDic setObject:@"5" forKey:@"speed"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/ptz/start" parameters:changeDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSLog(@"开始控制成功");
        }else{
            [XHToast showCenterWithText:NSLocalizedString(@"云台控制开启失败，请稍候再试", nil)];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [XHToast showCenterWithText:NSLocalizedString(@"云台控制开启失败，请检查您的网络", nil)];
    }];
}
#pragma mark - 云台控制--停止
static void extracted(NSMutableDictionary *changeDic) {
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/ptz/stop" parameters:changeDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSLog(@"停止控制成功");
        }else
        {
            [XHToast showCenterWithText:NSLocalizedString(@"云台控制关闭失败，请稍候再试", nil)];
        }
    } failure:^(NSError * _Nonnull error) {
        [XHToast showCenterWithText:NSLocalizedString(@"云台控制关闭失败，请检查您的网路", nil)];
    }];
}

- (void)controlStop{
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
    NSNumber * chan_num = [NSNumber numberWithInteger:cell.chan_id];
    NSMutableDictionary * changeDic = [NSMutableDictionary dictionary];
    [changeDic setObject:self.listModel.ID forKey:@"dev_id"];
    [changeDic setObject:chan_num forKey:@"chan_id"];
    extracted(changeDic);
}

#pragma mark - 停止按钮的响应方法和触发事件
//停止按钮
- (IBAction)btnStopClick:(id)sender {
    
    if (_selectIndexPath == nil) {
        NSLog(@"停止播放按钮的选择index == nil ，return");
        return;
    }else{
        NSLog(@"停止");
        self.clickCell.loadView.hidden = YES;
        // [[HDNetworking sharedHDNetworking]canleAllHttp];//注释，这里不能打开，因为这样的话，到下个界面的第一时间的请求就会报-999的错误。因为是取消了这次请求
        //如果正在录像就停止录制
        [self judgeIsRecord];
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        cell.loadView.hidden = YES;
        UIButton *btn = (UIButton *)sender;
        btn.selected = !btn.selected;
        if (cell.isPlay == YES) {
            //截取正在播放的视频保存到沙盒
            if (self.isCanCut) [self backCutImage];
            cell.isPlay = NO;
            [cell.videoManage JWStreamPlayerManageEndPlayLiveVideoIsStop:YES CompletionBlock:^(JWErrorCode errorCode) {
                if (errorCode == JW_SUCCESS) {
                    cell.addBtn.hidden = YES;
                    cell.reStartBtn.hidden = NO;
                    cell.closeBtn.hidden = NO;
                    NSLog(@"停止成功");
                }else{
                    NSLog(@"停止失败");
                    [cell.videoManage JWPlayerManageSetAudioIsOpen:NO];//这里因为偶现码流停止失败，故先采取关闭声音的方式来规避bug，后期应该让码流停止。
                }
            }];
        }
        else{
            cell.isPlay = NO;
            [cell.videoManage JWStreamPlayerManageEndPlayLiveVideoIsStop:YES CompletionBlock:^(JWErrorCode errorCode) {
                if (errorCode == JW_SUCCESS) {
                    cell.addBtn.hidden = YES;
                    cell.reStartBtn.hidden = NO;
                    cell.closeBtn.hidden = NO;
                    NSLog(@"停止成功");
                }else{
                    NSLog(@"停止失败");
                    [cell.videoManage JWPlayerManageSetAudioIsOpen:NO];//这里因为偶现码流停止失败，故先采取关闭声音的方式来规避bug，后期应该让码流停止。
                }
            }];
        }
    }
}

#pragma mark - 界面退出时候，关闭当前所有音频、视频窗口
- (void)destroyVideoAudio
{
    MoveCellState tempCurrent = self.collectionView.currentState;
    switch (self.collectionView.currentState) {
        case MoveCellStateFourScreen:
        {
            [self.collectionView layoutIfNeeded];
        }
            break;
        case MoveCellStateOneScreen:
        {
            _collectionView.currentState = MoveCellStateFourScreen;
            [self.collectionView reloadData];
            [self.collectionView layoutIfNeeded];
        }
            break;
        default:
            break;
    }
   
    for (int i = 0; i < 4; i++) {
        NSIndexPath * index = [NSIndexPath indexPathForItem:i inSection:0];
        MoveViewCell_c * tempCell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:index];
       // NSLog(@"退出界面【关闭当前所有音频、视频窗口 index:%ld cell:%@ === isPlay:%@",(long)index.row,tempCell,tempCell.isPlay?@"YES":@"NO");
        if (tempCell.isPlay == YES) {
            //JWPlayerManageEndPlayVideoWithBIsStop
            [tempCell.videoManage JWStreamPlayerManageEndPlayLiveVideoIsStop:YES CompletionBlock:^(JWErrorCode errorCode) {
                if (errorCode == JW_SUCCESS) {
                    NSLog(@"退出界面【关闭当前所有音频、视频窗口】 停止成功 index:%ld",(long)index.row);
                }else{
                    NSLog(@"退出界面【关闭当前所有音频、视频窗口】停止失败 index:%ld",(long)index.row);
                }
            }];
        }
    }
    switch (tempCurrent) {
        case MoveCellStateFourScreen:
        {
            _collectionView.currentState = MoveCellStateFourScreen;
            [self.collectionView reloadData];
        }
            break;
        case MoveCellStateOneScreen:
        {
            _collectionView.currentState = MoveCellStateOneScreen;
            [self.collectionView reloadData];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark  -------------- 声音按钮的响应方法
//声音按钮
- (IBAction)btnSoundClick:(id)sender {
    
    if (_selectIndexPath == nil) {
        NSLog(@"停止声音按钮的选择index == nil ，return");
        return;
    }else{
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        
        //        UIButton *btn = (UIButton *)sender;
        //        btn.selected = !btn.selected;
        //判断声音按钮的状态
        [self judgeIsCloseSound];
        
        
        if (cell.isPlay == YES) {
            if (isCloseSound == NO) {
                [XHToast showTopWithText:NSLocalizedString(@"声音:开", nil) topOffset:160];
                [cell.videoManage JWPlayerManageSetAudioIsOpen:YES];
            }else{
                [XHToast showTopWithText:NSLocalizedString(@"声音:关", nil) topOffset:160];
                [cell.videoManage JWPlayerManageSetAudioIsOpen:NO];
            }
        }
    }
}

#pragma mark  -------------- 分屏按钮的相应事件
//分屏按钮
- (IBAction)btnScreenClick:(id)sender {
    
    if (self.selectIndexPath == nil) {
        NSLog(@"分屏按钮的选择index == nil ，return");
        return;
    }else{
        UIButton * btn = (UIButton *)sender;
        btn.selected= !btn.selected;
        if (btn.selected) {
            self.screenNum = 1;
        }else{
            self.screenNum = 4;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:SPLITSCREENNOTIFICATION object:nil];
    }
    
}

#pragma mark  --- 高清按钮的响应事件【小屏状态】

//三码流切换按钮
- (IBAction)btnHdClick:(id)sender {
    
    if (_selectIndexPath == nil) {
        [XHToast showTopWithText:NSLocalizedString(@"请选择您想要的通道列表", nil) topOffset:160];
        return;
    }else{
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        if (cell.isPlay == YES) {
            if ([cell.listModel.type isEqualToString:@"GB"]) {
                [XHToast showTopWithText:NSLocalizedString(@"该设备不支持清晰度切换", nil) topOffset:160];
            }else{
                self.threeStreamView.hidden = NO;
            }
            
        }else{
            [XHToast showTopWithText:NSLocalizedString(@"视频未播放", nil) topOffset:160];
        }
    }
}

//流畅
- (IBAction)fluentDClick:(id)sender {
    if (self.videoTypeStatus == JWVideoTypeStatusFluency) {
        return;
    }
    self.videoTypeStatus = JWVideoTypeStatusFluency;
    [self.btn_hd setTitle:NSLocalizedString(@"流畅", nil) forState:UIControlStateNormal];
    [XHToast showTopWithText:NSLocalizedString(@"流畅", nil) topOffset:160];
    [self judgeIsRecord];//如果正在录像就停止录制
   // MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
   // [self getVideoAddressNewWithDeviceID:cell.listModel.ID ChannelNo:_chan_way];
    [self changeVideoDefinition];
}

//标清
- (IBAction)sdClick:(id)sender {
    if (self.videoTypeStatus == JWVideoTypeStatusNomal) {
        return;
    }
    self.videoTypeStatus = JWVideoTypeStatusNomal;
    [self.btn_hd setTitle:NSLocalizedString(@"标清", nil) forState:UIControlStateNormal];
    [XHToast showTopWithText:NSLocalizedString(@"标清", nil) topOffset:160];
    [self judgeIsRecord];//如果正在录像就停止录制
   // MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
    //[self getVideoAddressNewWithDeviceID:cell.listModel.ID ChannelNo:_chan_way];
    [self changeVideoDefinition];
}

//高清
- (IBAction)hdClick:(id)sender {
    if (self.videoTypeStatus == JWVideoTypeStatusHd) {
        return;
    }
    self.videoTypeStatus = JWVideoTypeStatusHd;
    [self.btn_hd setTitle:NSLocalizedString(@"高清", nil) forState:UIControlStateNormal];
    [XHToast showTopWithText:NSLocalizedString(@"高清", nil) topOffset:160];
    [self judgeIsRecord];//如果正在录像就停止录制
   // MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
    //[self getVideoAddressNewWithDeviceID:cell.listModel.ID ChannelNo:_chan_way];
    [self changeVideoDefinition];
}

#pragma mark - 全屏按钮的响应事件
//全屏按钮
- (IBAction)btnFullClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (self.isFull == NO) {
        [self.btn_full setImage:[UIImage imageNamed:@"small_n"] forState:UIControlStateNormal];
        self.threeStreamView.hidden = YES;
        self.btnBack.hidden = YES;
        self.bIsPortraitScreen = NO;
        [self rightHengpinAction_xiugai];
 
    }else{
        //移除全屏时屏幕上的控件
        [self removeFullScreenControls];
        self.btnBack.hidden = NO;
        self.bIsPortraitScreen = YES;
        [self.btn_full setImage:[UIImage imageNamed:@"full_n"] forState:UIControlStateNormal];
        [self shupinAction_xiugai];
    }
 
}
#pragma mark ----- 返回按钮的代理方法
- (void)backBtnClick{
    //移除全屏时屏幕上的所有控件
    [self removeFullScreenControls];
    
    //判断是否关闭声音
    if (isCloseSound) {
        [self.btn_sound setImage:[UIImage imageNamed:@"sound_close_n"] forState:UIControlStateNormal];
    }else{
        [self.btn_sound setImage:[UIImage imageNamed:@"sound_open_n"] forState:UIControlStateNormal];
    }
    
    //判断是否关闭高清
    if (self.videoTypeStatus == JWVideoTypeStatusHd)
    {
        [self.btn_hd setTitle:NSLocalizedString(@"高清", nil) forState:UIControlStateNormal];
    }
    else if(self.videoTypeStatus == JWVideoTypeStatusNomal)
    {
        [self.btn_hd setTitle:NSLocalizedString(@"标清", nil) forState:UIControlStateNormal];
    }
    else if (self.videoTypeStatus == JWVideoTypeStatusFluency)
    {
        [self.btn_hd setTitle:NSLocalizedString(@"流畅", nil) forState:UIControlStateNormal];
    }
    //判断是否关闭录制
    if (self.isRecord) {
        [self.videoBtn setImage:[UIImage imageNamed:@"shootVideo_redable"] forState:UIControlStateNormal];
    }else{
        [self.videoBtn setImage:[UIImage imageNamed:@"shootVideo_able"] forState:UIControlStateNormal];
    }
    
    [self.btn_full setImage:[UIImage imageNamed:@"full_n"] forState:UIControlStateNormal];
    
    [self shupinAction_xiugai];
    self.btnBack.hidden = NO;
}

#pragma mark  -----------以下修改，还没有全部修复完成。
#pragma mark  -------------- 横屏
-(void)rightHengpinAction_xiugai
{
    self.isFull = YES;
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self createFullScreenControls];
    [self updateUI_FullScreen];
    
    [UIView animateWithDuration:0.25 animations:^{

        float arch = M_PI_2;
        self.navigationController.view.transform = CGAffineTransformMakeRotation(arch);
        self.navigationController.view.bounds = CGRectMake(0, 0,iPhoneHeight, iPhoneWidth);//这里是旋转后的，3，为宽，4为高。因为旋转后，参数互调。
        [self.VideoViewBack mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(0);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
        }];
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.VideoViewBack.mas_top).offset(0);
            make.left.equalTo(self.VideoViewBack.mas_left).offset(0);
            make.bottom.equalTo(self.VideoViewBack.mas_bottom).offset(0);
            make.right.equalTo(self.VideoViewBack.mas_right).offset(0);
        }];
    }];
    if (self.collectionView.currentState == MoveCellStateOneScreen) {//_screenNum == 1
        self.collectionView.currentState = MoveCellStateOneScreen_HengPing;
        self.collectionView.lastState = MoveCellStateOneScreen;
        [self.collectionView reloadData];
        [self.collectionView layoutIfNeeded];
        switch (self.selectIndexPath.row) {
            case 0:
            {
                [self.collectionView setContentOffset:CGPointMake(0, 0)];
            }
                break;
            case 1:
            {
                [self.collectionView setContentOffset:CGPointMake(0, iPhoneWidth)];
            }
                break;
            case 2:
            {
                [self.collectionView setContentOffset:CGPointMake(0, iPhoneWidth * 2)];
            }
                break;
            case 3:
            {
                [self.collectionView setContentOffset:CGPointMake(0, iPhoneWidth * 3)];
            }
                break;
                
            default:
                break;
        }
        //注释：这里应该是强制旋转了屏幕，所以滚动到第几个方法有点不准确。self。selectiIndexPath是正确的情况下。
        //[self.collectionView scrollToItemAtIndexPath:self.selectIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        NSDictionary * dic = @{@"hasHengPing":@"YES"};
        [[NSNotificationCenter defaultCenter]postNotificationName:HASHENGPING object:nil userInfo:dic];
        
    }else if(self.collectionView.currentState == MoveCellStateFourScreen){
        self.collectionView.currentState = MoveCellStateFourScreen_HengPing;
        [self.collectionView reloadData];
    }
}

#pragma mark  -------------- 竖屏
-(void)shupinAction_xiugai
{
    [unitl saveDataWithKey:SCREENSTATUS Data:SHU_PING];
    CGFloat bili = (CGFloat)(375.0000/244.000);
    CGFloat viewWidth;
    if (self.isFull == YES) {
        viewWidth  = (CGFloat)self.view.height;
    }else{
        viewWidth  = (CGFloat)self.view.width;
    }
    CGFloat h  = (CGFloat)viewWidth/bili;
    self.isFull = NO;
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [UIView animateWithDuration:0.25 animations:^{
        float arch = 0;
        //对navigationController.view 进行强制旋转
        self.navigationController.view.transform = CGAffineTransformMakeRotation(arch);
        self.navigationController.view.bounds = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight);
        
        [self.VideoViewBack mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(64);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.height.equalTo(@(h));
        }];
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.VideoViewBack.mas_top).offset(0);
            make.left.equalTo(self.VideoViewBack.mas_left).offset(0);
            make.bottom.equalTo(self.VideoViewBack.mas_bottom).offset(-44);
            make.right.equalTo(self.VideoViewBack.mas_right).offset(0);
        }];
    }];
    
    if (self.collectionView.currentState == MoveCellStateOneScreen_HengPing) {
        self.collectionView.currentState = MoveCellStateOneScreen;
        self.collectionView.lastState = MoveCellStateOneScreen_HengPing;
        [self.collectionView reloadData];
        [self.collectionView layoutIfNeeded];
        switch (self.selectIndexPath.row) {
            case 0:
            {
                [self.collectionView setContentOffset:CGPointMake(0, 0)];
            }
                break;
            case 1:
            {
                [self.collectionView setContentOffset:CGPointMake(0, [self currentStateCellSize].height)];
            }
                break;
            case 2:
            {
                [self.collectionView setContentOffset:CGPointMake(0, [self currentStateCellSize].height * 2)];
            }
                break;
            case 3:
            {
                [self.collectionView setContentOffset:CGPointMake(0, [self currentStateCellSize].height * 3 + 6)];
            }
                break;
                
            default:
                break;
        }
    }else if(self.collectionView.currentState == MoveCellStateFourScreen_HengPing){
        self.collectionView.currentState = MoveCellStateFourScreen;
        [self.collectionView reloadData];
    }
//    _collectionView.currentState = MoveCellStateFourScreen;
//    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];

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
    NSLog(@"【RealTimeVideoVC】截图保存路径：%@",savePath);
    
    [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    BOOL ret = [fileManager createFileAtPath:savePath contents:UIImagePNGRepresentation(image) attributes:nil];
    if (!ret) {
        NSLog(@"【RealTimeVideoVC】截图保存路径 文件 创建失败");
    }
}
#pragma mark  - 竖屏截图点击事件 TESTDemo
- (IBAction)cameraBtnVerticalClick:(id)sender
{
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        
        BOOL isplay = [cell.videoManage JWPlayerManageGetPlayState];
        if (isplay == YES) {
            //播放截图音效
            [self playSoundEffect:@"capture.caf"];
            UIImage *ima = [self snapshot:cell.playView];
            [XHToast showBottomWithText:NSLocalizedString(@"已保存截图到我的文件", nil)];
            [self createShortcutPicToFilebIsVideo:NO shortCutImage:ima bIsFullScreen:NO];
            dispatch_async(dispatch_queue_create("photoScreenshot", NULL), ^{
                @synchronized (self) {
                    
                    
                    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
                        //创建文件名称
                        NSString *fileName = [NSString stringWithFormat:@"/%@/file",[unitl get_user_mobile]];
                        [FileTool createRootFilePath:fileName];
                        //创建文件路径
                        NSString *modelfileName = [FileTool createFileName];
                        NSString *filePath = [FileTool getFilePath:modelfileName];
                        //创建文件管理器
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        BOOL ret = [fileManager createFileAtPath:[NSString stringWithFormat:@"%@.jpg",filePath] contents:UIImagePNGRepresentation(ima) attributes:nil];
                        if (ret) {
                            [self saveFileModel:ima andPath:[NSString stringWithFormat:@"%@.jpg",modelfileName]andType:1];
                        }else{
                            NSLog(@"截图保存失败");
                        }
                        
                    }
                    
                }
            });
        }else{
            [XHToast showBottomWithText:NSLocalizedString(@"视频未播放", nil)];
        }
    }else{
        [XHToast showCenterWithText:NSLocalizedString(@"请先单击选中您想要截图的视频窗口", nil) duration:1.0f];
    }
}

#pragma mark - 存储文件model(type:1是图片)
- (void)saveFileModel:(UIImage *)coverImg andPath:(NSString *)filePath andType:(int)type
{
    NSString *fileKey = [unitl getKeyWithSuffix:[unitl get_User_id] Key:@"MYFILE"];
    if ([unitl getNeedArchiverDataWithKey:fileKey]) {
        NSLog(@"数组已经有了，我们下载第二个了哦");
        NSMutableArray *tempArr = [unitl getNeedArchiverDataWithKey:fileKey];
        FileModel *model = [[FileModel alloc]init];
        dispatch_async(dispatch_get_main_queue(), ^{
            //主线程执行
            model.name = self.navigationItem.title;
        });
        model.date = [self getFileCreateTime:NO];
        model.createTime = [self getFileNameandType:type];
        model.type = type;
        model.filePath = filePath;
        [tempArr addObject:model];
        [unitl saveNeedArchiverDataWithKey:fileKey Data:tempArr];
    }else{
        NSLog(@"数组还没有，第一次我还不存在，现在创建哦");
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        FileModel *model = [[FileModel alloc]init];
        dispatch_async(dispatch_get_main_queue(), ^{
            //主线程执行
            model.name = self.navigationItem.title;
        });
        model.date = [self getFileCreateTime:NO];
        model.createTime = [self getFileNameandType:type];
        model.type = type;
        model.filePath = filePath;
        [tempArr addObject:model];
        [unitl saveNeedArchiverDataWithKey:fileKey Data:tempArr];
    }
}

#pragma mark - 获取创建文件的时间
- (NSString *)getFileNameandType:(int)type
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *date = [NSDate date];
    NSString *DateTimeStr = [formatter stringFromDate:date];
    return DateTimeStr;
}

#pragma mark - 获取当前时间
-(NSString *)getFileCreateTime:(BOOL)isDesc
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    if (isDesc) {
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }else{
        [formatter setDateFormat:@"YYYY.MM.dd"];
    }
    NSDate *date = [NSDate date];
    NSString *dateTimeStr = [formatter stringFromDate:date];
    return dateTimeStr;
}



#pragma mark - 截图则在右下角出现的缩略图，可以点击进入相应的文件列表
- (void)createShortcutPicToFilebIsVideo:(BOOL)isVideo shortCutImage:(UIImage *)image bIsFullScreen:(BOOL)fullscreen
{
    self.bgView.hidden = NO;
    self.cutImage.hidden = NO;
    if (isVideo) {
        self.videoBgView.hidden = NO;
        self.videoLogo.hidden = NO;
    }else{
        self.videoBgView.hidden = YES;
        self.videoLogo.hidden = YES;
    }
    self.bgView.tag = isVideo? 1001:1002;
    CGFloat videoHeight = CGRectGetHeight(self.VideoViewBack.frame);
    CGFloat videoWidth = CGRectGetWidth(self.VideoViewBack.frame);
    NSLog(@"变为全屏后，播放器界面的大小：%f===%f",videoHeight,videoWidth);
    [self.cutImage setImage:image];
    
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.VideoViewBack).offset(10);
        make.bottom.mas_equalTo(self.VideoViewBack.mas_bottom).offset(-54);
        make.height.mas_equalTo(videoHeight/3);
        make.width.mas_equalTo(videoWidth/3);
        [self.bgView layoutIfNeeded];
    }];
    [self.cutImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(_bgView).offset(1);
        make.bottom.right.mas_equalTo(_bgView).offset(-1);
        [self.cutImage layoutIfNeeded];
    }];
    
    _shortCutShowTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hideShortcutPic) userInfo:nil repeats:NO];
    
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    singleFingerOne.delegate = self;
    [_bgView addGestureRecognizer:singleFingerOne];
}


- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor lightGrayColor];
        [self.VideoViewBack addSubview:_bgView];
        CGFloat videoHeight = CGRectGetHeight(self.VideoViewBack.frame);
        CGFloat videoWidth = CGRectGetWidth(self.VideoViewBack.frame);
        [_bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.VideoViewBack);
            make.bottom.mas_equalTo(self.VideoViewBack);
            make.height.mas_equalTo(videoHeight);
            make.width.mas_equalTo(videoWidth);
            // [_bgView layoutIfNeeded];
        }];
    }
    return _bgView;
}
- (UIImageView *)cutImage{
    if (!_cutImage) {
        _cutImage = [[UIImageView alloc]init];
        [_bgView addSubview:_cutImage];
        [_cutImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(_bgView).offset(1);
            make.bottom.right.mas_equalTo(_bgView).offset(-1);
            //  [_cutImage layoutIfNeeded];
        }];
    }
    return _cutImage;
}
- (UIView *)videoBgView
{
    if (!_videoBgView) {
        _videoBgView = [[UIView alloc]init];
        _videoBgView.backgroundColor = [UIColor blackColor];
        _videoBgView.alpha = 0.7;
        [_cutImage addSubview:_videoBgView];
        [_videoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(_cutImage);
            make.bottom.mas_equalTo(_cutImage);
            make.height.mas_equalTo(@15);
        }];
        _videoBgView.hidden = YES;
    }
    return _videoBgView;
}
- (UIImageView *)videoLogo
{
    if (!_videoLogo) {
        _videoLogo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"videoLogo"]];
        [_videoBgView addSubview:_videoLogo];
        [_videoLogo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_videoBgView.mas_left).offset(4);
            make.top.bottom.mas_equalTo(_videoBgView);
            make.width.mas_equalTo(@20);
        }];
        _videoLogo.hidden = YES;
    }
    return _videoLogo;
}

#pragma mark 使得截图快速进入文件夹，3秒消失
- (void)hideShortcutPic
{
    self.bgView.hidden = YES;
    self.cutImage.hidden = YES;
}

//处理单指事件
- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)sender
{
    NSLog(@"点击快速跳转到文件：%ld",sender.view.tag);
    float arch = 0;
    self.navigationController.view.transform = CGAffineTransformMakeRotation(arch);
    self.navigationController.view.bounds = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight);
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    FileVC *fileVC = [[FileVC alloc]init];
    [self.navigationController pushViewController:fileVC animated:YES];
}

#pragma mark  - 竖屏录制点击事件 Testdemo
- (IBAction)videoBtnVerticalClick:(id)sender
{
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        UIButton *btn = (UIButton *)sender;
        BOOL isplay = [cell.videoManage JWPlayerManageGetPlayState];
        
        if (!self.isRecord && !self.bIsStratPlaying && self.b_I_Frame_Start == NO) {
            [XHToast showBottomWithText:NSLocalizedString(@"视频未播放", nil)];
            return;
        }
        if (!self.isRecord) {
            //判断视频是否播放
            if (isplay == NO ) {
                [XHToast showBottomWithText:NSLocalizedString(@"视频未播放", nil)];
                return;
            }
            //播放录音音效
            [self playSoundEffect:@"record.caf"];
            [XHToast showBottomWithText:NSLocalizedString(@"视频开始录制", nil)];
            self.redDotView.hidden = NO;
            btn.selected = YES;
            if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
                //创建文件名称
                NSString *fileName = [NSString stringWithFormat:@"/%@/file",[unitl get_user_mobile]];
                [FileTool createRootFilePath:fileName];
                //创建文件路径
                NSString *modelfileName = [FileTool createFileName];
                NSString *filePath = [FileTool getFilePath:modelfileName];
                [cell.videoManage JWPlayerManageStartRecordWithPath:filePath];
                UIImage *ima = [self snapshot:cell.playView];
                [self saveFileModel:ima andPath:[NSString stringWithFormat:@"%@.mp4",modelfileName]andType:0];
                
            }
            self.isRecord = YES;
            [self.videoBtn setImage:[UIImage imageNamed:@"shootVideo_redable"] forState:UIControlStateNormal];
        }else{
            //播放录音音效
            [self playSoundEffect:@"record.caf"];
            [XHToast showBottomWithText:NSLocalizedString(@"视频录制成功，已保存到我的文件", nil)];
            self.redDotView.hidden = YES;
            btn.selected = NO;
            [cell.videoManage JWPlayerManageStopRecord];
            UIImage *ima = [self snapshot:cell.playView];
            [self createShortcutPicToFilebIsVideo:YES shortCutImage:ima bIsFullScreen:NO];
            self.isRecord = NO;
            [self.videoBtn setImage:[UIImage imageNamed:@"shootVideo_able"] forState:UIControlStateNormal];
        }
    }else{
        [XHToast showCenterWithText:NSLocalizedString(@"请先单击选中您想要截图的视频窗口", nil) duration:1.0f];
    }
}



#pragma mark  -------------- 竖屏对讲按钮【正常小屏状态】
- (IBAction)btnTalkClick:(id)sender {
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        BOOL isplay = [cell.videoManage JWPlayerManageGetPlayState];
        if (isplay == NO) {
            [XHToast showBottomWithText:NSLocalizedString(@"视频未播放", nil)];
            return;
        }else{
            self.talkBtn.userInteractionEnabled = NO;
            [cell.videoManage JWPlayerManageStartAudioTalkWithCompletionBlock:^(JWErrorCode errorCode) {
                if (errorCode == 0) {
                    [XHToast showTopWithText:NSLocalizedString(@"麦克风:开", nil) topOffset:160];
                    isCloseTalk = NO;
                    [self createOvreUI];
                    self.currentSelectIndexPath = _selectIndexPath;
                }else{
                    [XHToast showBottomWithText:[NSString stringWithFormat:@"%@",NSLocalizedString(@"开启对讲失败", nil)]];
                }
            }];
        }
    }else{
        [XHToast showCenterWithText:NSLocalizedString(@"请先单击选中您想要对讲的视频窗口", nil) duration:1.0f];
    }
}

#pragma mark - 半双通 对讲【大屏状态】
- (void)LongPress_full_target:(UILongPressGestureRecognizer *)longPress
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        if (granted) {//允许麦克风
            if (longPress.minimumPressDuration < 1.0f) {
                [XHToast showCenterWithText:NSLocalizedString(@"按住时间太短", nil) duration:1.0f];
            }else
            {
                if (longPress.state == UIGestureRecognizerStateBegan) {
                    NSLog(@"按住对讲");
                    if (_selectIndexPath) {
                        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
                        BOOL isplay = [cell.videoManage JWPlayerManageGetPlayState];
                        if (isplay == NO) {
                            [XHToast showBottomWithText:NSLocalizedString(@"视频未播放", nil)];
                            return;
                        }else{
                            self.talkBtn.userInteractionEnabled = NO;
                            // [CircleLoading showCircleInView:self.view andTip:@"正在开启对讲~"];
                            [cell.videoManage JWPlayerManageStartAudioTalkWithCompletionBlock:^(JWErrorCode errorCode) {
                                if (errorCode == 0) {
                                    // [XHToast showTopWithText:@"麦克风:开" topOffset:160];
                                    isCloseTalk = NO;
                                    // [CircleLoading hideCircleInView:self.view];
                                    // [self createOvreUI];
                                    if (!isCloseSound) {//如果当前声音开启的话需要关闭，否则不需要任何操作
                                        [cell.videoManage JWPlayerManageSetAudioIsOpen:NO];
                                    }
                                    [self createPressTalkUI];
                                    self.currentSelectIndexPath = _selectIndexPath;
                                }else{
                                    [XHToast showBottomWithText:[NSString stringWithFormat:@"%@",NSLocalizedString(@"开启对讲失败", nil)]];
                                }
                            }];
                        }
                    }else{
                        [XHToast showCenterWithText:NSLocalizedString(@"请先单击选中您想要对讲的视频窗口", nil) duration:1.0f];
                    }
                }
                else if (longPress.state == UIGestureRecognizerStateEnded)
                {
                    NSLog(@"松开对讲");
                    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
                    if (!isCloseSound) {//如果当前声音开启的话需要关闭，否则不需要任何操作
                        [cell.videoManage JWPlayerManageSetAudioIsOpen:YES];
                    }
                    [self stopTalkWith];
                }
            }
            
        }else{//禁止麦克风
       
        }
    }];
}

#pragma mark - 半双通 对讲【小屏状态】
- (void)talkWithLongPress:(UILongPressGestureRecognizer *)LongPress
{
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
    
    //多通道设备进入时就是默许不支持对讲功能
    if (self.isMultiChannel) {
        [XHToast showCenterWithText:NSLocalizedString(@"该设备不支持对讲功能", nil)];
        return;
    }
    
    if ([[unitl get_User_id] isEqualToString:cell.listModel.owner_id]) {//自己设备
        [self setDeviceFeature:cell.listModel];
        if (self.feature.isTalk == 1) {
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (granted) {//允许麦克风
                    if (LongPress.minimumPressDuration < 0.5f) {
                        [XHToast showCenterWithText:NSLocalizedString(@"按住时间太短", nil) duration:1.0f];
                    }else{
                        if (LongPress.state == UIGestureRecognizerStateBegan) {
                            NSLog(@"按住对讲");
                            if (_selectIndexPath) {
                                
                                BOOL isplay = [cell.videoManage JWPlayerManageGetPlayState];
                                if (isplay == NO) {
                                    [XHToast showBottomWithText:NSLocalizedString(@"视频未播放", nil)];
                                    return;
                                }else{
                                    self.talkBtn.userInteractionEnabled = NO;
                                    [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在开启对讲", nil)];
                                    [cell.videoManage JWPlayerManageStartAudioTalkWithCompletionBlock:^(JWErrorCode errorCode) {
                                        if (errorCode == 0) {
                                            // [XHToast showTopWithText:@"麦克风:开" topOffset:160];
                                            isCloseTalk = NO;
                                            [CircleLoading hideCircleInView:self.view];
                                            
                                            if (!isCloseSound) {//如果当前声音开启的话需要关闭，否则不需要任何操作
                                                [cell.videoManage JWPlayerManageSetAudioIsOpen:NO];
                                            }
                                            
                                            // [self createOvreUI];
                                            [self createPressTalkUI];
                                            self.currentSelectIndexPath = _selectIndexPath;
                                        }else{
                                            [CircleLoading hideCircleInView:self.view];
                                            [XHToast showBottomWithText:[NSString stringWithFormat:@"%@",NSLocalizedString(@"开启对讲失败", nil)]];
                                        }
                                    }];
                                }
                            }else{
                                [XHToast showCenterWithText:NSLocalizedString(@"请先单击选中您想要对讲的视频窗口", nil) duration:1.0f];
                            }
                        }
                        else if (LongPress.state == UIGestureRecognizerStateEnded)
                        {
                            [[HDNetworking sharedHDNetworking]canleAllHttp];
                            NSLog(@"松开对讲");
                            MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
                            if (!isCloseSound) {//如果当前声音开启的话需要关闭，否则不需要任何操作
                                [cell.videoManage JWPlayerManageSetAudioIsOpen:YES];
                            }
                            [self stopTalkWith];
                        }
                    }
                    
                }else{//未允许麦克风
                    [unitl createAlertActionWithTitle:NSLocalizedString(@"已为“视频云眼”关闭麦克风", nil) message:NSLocalizedString(@"您可以在“设置”中为此应用打开麦克风", nil) andController:self];
                }
            }];
            
        }else{
            [XHToast showCenterWithText:NSLocalizedString(@"该设备不支持对讲功能", nil)];
        }
        
    }else{//分享的设备
        
        if (isNodeTreeMode) {
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (granted) {//允许麦克风
                    if (LongPress.minimumPressDuration < 0.5f) {
                        [XHToast showCenterWithText:NSLocalizedString(@"按住时间太短", nil) duration:1.0f];
                    }else{
                        if (LongPress.state == UIGestureRecognizerStateBegan) {
                            NSLog(@"按住对讲");
                            if (_selectIndexPath) {
                                
                                BOOL isplay = [cell.videoManage JWPlayerManageGetPlayState];
                                if (isplay == NO) {
                                    [XHToast showBottomWithText:NSLocalizedString(@"视频未播放", nil)];
                                    return;
                                }else{
                                    self.talkBtn.userInteractionEnabled = NO;
                                    [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在开启对讲", nil)];
                                    [cell.videoManage JWPlayerManageStartAudioTalkWithCompletionBlock:^(JWErrorCode errorCode) {
                                        if (errorCode == 0) {
                                            // [XHToast showTopWithText:@"麦克风:开" topOffset:160];
                                            isCloseTalk = NO;
                                            [CircleLoading hideCircleInView:self.view];
                                            
                                            if (!isCloseSound) {//如果当前声音开启的话需要关闭，否则不需要任何操作
                                                [cell.videoManage JWPlayerManageSetAudioIsOpen:NO];
                                            }
                                            
                                            // [self createOvreUI];
                                            [self createPressTalkUI];
                                            self.currentSelectIndexPath = _selectIndexPath;
                                        }else{
                                            [CircleLoading hideCircleInView:self.view];
                                            [XHToast showBottomWithText:[NSString stringWithFormat:@"%@",NSLocalizedString(@"开启对讲失败", nil)]];
                                        }
                                    }];
                                }
                            }else{
                                [XHToast showCenterWithText:NSLocalizedString(@"请先单击选中您想要对讲的视频窗口", nil) duration:1.0f];
                            }
                        }
                        else if (LongPress.state == UIGestureRecognizerStateEnded)
                        {
                            [[HDNetworking sharedHDNetworking]canleAllHttp];
                            NSLog(@"松开对讲");
                            MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
                            if (!isCloseSound) {//如果当前声音开启的话需要关闭，否则不需要任何操作
                                [cell.videoManage JWPlayerManageSetAudioIsOpen:YES];
                            }
                            [self stopTalkWith];
                        }
                    }
                    
                }else{//未允许麦克风
                    [unitl createAlertActionWithTitle:NSLocalizedString(@"已为“视频云眼”关闭麦克风", nil) message:NSLocalizedString(@"您可以在“设置”中为此应用打开麦克风", nil) andController:self];
                }
            }];
            
        }else{
            shareFeature *shareFeature = cell.listModel.ext_info.shareFeature;
            if ([shareFeature.talk intValue] == 1) {
                if (cell.listModel.enableOperator == 1) {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                        if (granted) {//允许麦克风
                            if (LongPress.minimumPressDuration < 0.5f) {
                                [XHToast showCenterWithText:NSLocalizedString(@"按住时间太短", nil) duration:1.0f];
                            }else{
                                if (LongPress.state == UIGestureRecognizerStateBegan) {
                                    NSLog(@"按住对讲");
                                    if (_selectIndexPath) {
                                        BOOL isplay = [cell.videoManage JWPlayerManageGetPlayState];
                                        if (isplay == NO) {
                                            [XHToast showBottomWithText:NSLocalizedString(@"视频未播放", nil)];
                                            return;
                                        }else{
                                            self.talkBtn.userInteractionEnabled = NO;
                                            [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在开启对讲", nil)];
                                            [cell.videoManage JWPlayerManageStartAudioTalkWithCompletionBlock:^(JWErrorCode errorCode) {
                                                if (errorCode == 0) {
                                                    // [XHToast showTopWithText:@"麦克风:开" topOffset:160];
                                                    isCloseTalk = NO;
                                                    [CircleLoading hideCircleInView:self.view];
                                                    if (!isCloseSound) {//如果当前声音开启的话需要关闭，否则不需要任何操作
                                                        [cell.videoManage JWPlayerManageSetAudioIsOpen:NO];
                                                    }
                                                    // [self createOvreUI];
                                                    [self createPressTalkUI];
                                                    self.currentSelectIndexPath = _selectIndexPath;
                                                }else{
                                                    [CircleLoading hideCircleInView:self.view];
                                                    [XHToast showBottomWithText:[NSString stringWithFormat:@"%@",NSLocalizedString(@"开启对讲失败", nil)]];
                                                }
                                            }];
                                        }
                                    }else{
                                        [XHToast showCenterWithText:NSLocalizedString(@"请先单击选中您想要对讲的视频窗口", nil) duration:1.0f];
                                    }
                                }
                                else if (LongPress.state == UIGestureRecognizerStateEnded)
                                {
                                    [[HDNetworking sharedHDNetworking]canleAllHttp];
                                    NSLog(@"松开对讲");
                                    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
                                    if (!isCloseSound) {//如果当前声音开启的话需要关闭，否则不需要任何操作
                                        [cell.videoManage JWPlayerManageSetAudioIsOpen:YES];
                                    }
                                    [self stopTalkWith];
                                }
                            }
                        }else{//未允许麦克风
                            [unitl createAlertActionWithTitle:NSLocalizedString(@"已为“视频云眼”关闭麦克风", nil) message:NSLocalizedString(@"您可以在“设置”中为此应用打开麦克风", nil) andController:self];
                        }
                    }];
                }else{
                    [XHToast showCenterWithText:NSLocalizedString(@"非分享时间段内无法对讲", nil)];
                }
            }else{
                [XHToast showCenterWithText:NSLocalizedString(@"您的好友未将对讲权限分享给您", nil)];
            }
        }
        
        
    }
}
#pragma mark ===== 创建对讲UI
- (void)createPressTalkUI
{
    [self.view addSubview:self.imageBgView];
    [self.imageBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        if (self.bIsPortraitScreen) {
            make.centerY.mas_equalTo(self.view).offset(-130);//
        }else{
            make.centerY.mas_equalTo(self.view.mas_centerY);//.offset(-55)
        }
        make.size.mas_equalTo(CGSizeMake(150, 150));
    }];
    [self.imageBgView addSubview:self.animationImageView];
    [self.animationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.imageBgView);
        make.size.mas_equalTo(CGSizeMake(80,88));
    }];
    [self.animationImageView setImage:[UIImage imageNamed:@"talk_voice_0"]];
    NSMutableArray *ary=[NSMutableArray new];
    for(int I = 0;I < 8;I++){
        NSString *imageName=[NSString stringWithFormat:@"talk_voice_%d",I];
        UIImage *image=[UIImage imageNamed:imageName];
        [ary addObject:image];
    }
    self.animationImageView.animationImages = ary;
    self.animationImageView.animationRepeatCount = 10;
    self.animationImageView.animationDuration= 5.0;
    [self.animationImageView startAnimating];
}

- (UIImageView *)animationImageView
{
    if (_animationImageView == nil) {
        _animationImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    }
    return _animationImageView;
}

- (UIView *)imageBgView
{
    if (_imageBgView == nil){
        _imageBgView = [[UIView alloc]initWithFrame:CGRectZero];
        _imageBgView.backgroundColor = [UIColor blackColor];
        _imageBgView.alpha = 0.6;
        _imageBgView.layer.cornerRadius = 5;
        _imageBgView.layer.masksToBounds = YES;
    }
    return _imageBgView;
}


#pragma mark - 竖屏SD录像回放点击事件
- (IBAction)sdBtnVerticalClick:(id)sender
{
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.selectIndexPath];
        
        if (cell.listModel) {
            if ([[unitl get_User_id] isEqualToString:cell.listModel.owner_id]) {//自己设备
                    [self setDeviceFeature:cell.listModel];
                    if ([cell.listModel.enableSD isEqualToString:@"1"]) {
                        OnlyPlayBackVC * playVC = [[OnlyPlayBackVC alloc]init];
                        playVC.titleName = cell.listModel.name;
                        playVC.listModel = cell.listModel;
                        playVC.bIsEncrypt = cell.listModel.enable_sec;
                        playVC.key = cell.listModel.dev_p_code;
                        playVC.isDeviceVideo = YES;
                        playVC.bIsAP = self.bIsAP;
                        [self.navigationController pushViewController:playVC animated:YES];
                    }else{
                        [XHToast showCenterWithText:NSLocalizedString(@"未检测到设备上的SD卡", nil)];
                    }
            }else{//好友分享
                shareFeature *shareFeature = cell.listModel.ext_info.shareFeature;
                
                //途虎子账号直接过去
                if (!isNodeTreeMode) {
                    if ([shareFeature.hp intValue]== 1) {
                        if (cell.listModel.enableOperator == 1) {
                            if ([cell.listModel.enableSD isEqualToString:@"1"]) {
                                OnlyPlayBackVC * playVC = [[OnlyPlayBackVC alloc]init];
                                playVC.titleName = cell.listModel.name;
                                playVC.listModel = cell.listModel;
                                playVC.bIsEncrypt = cell.listModel.enable_sec;
                                playVC.key = cell.listModel.dev_p_code;
                                playVC.isDeviceVideo = YES;
                                playVC.bIsAP = self.bIsAP;
                                [self.navigationController pushViewController:playVC animated:YES];
                            }else{
                                [XHToast showCenterWithText:NSLocalizedString(@"未检测到设备上的SD卡", nil)];
                            }
                        }else{
                            [XHToast showCenterWithText:NSLocalizedString(@"非分享时间段内无法查看设备录像", nil)];
                        }
                    }else{
                        [XHToast showCenterWithText:NSLocalizedString(@"您的好友未将设备录像权限分享给您", nil)];
                    }
                }else{
                    if ([cell.listModel.enableSD isEqualToString:@"1"]) {
                        OnlyPlayBackVC * playVC = [[OnlyPlayBackVC alloc]init];
                        playVC.titleName = cell.listModel.name;
                        playVC.listModel = cell.listModel;
                        playVC.bIsEncrypt = cell.listModel.enable_sec;
                        playVC.key = cell.listModel.dev_p_code;
                        playVC.isDeviceVideo = YES;
                        playVC.bIsAP = self.bIsAP;
                        [self.navigationController pushViewController:playVC animated:YES];
                    }else{
                        [XHToast showCenterWithText:NSLocalizedString(@"未检测到设备上的SD卡", nil)];
                    }
                    
                }
                
                
        }
        }else{
            
            
            //判断是否是多通道设备
            if (cell.channelModel) {
                
                OnlyPlayBackVC * playVC = [[OnlyPlayBackVC alloc]init];
                playVC.titleName = cell.channelModel.chanName;//cell.listModel.name;
                playVC.listModel = self.listModel;
                playVC.bIsEncrypt = cell.listModel.enable_sec;
                playVC.key = cell.listModel.dev_p_code;
                playVC.isDeviceVideo = YES;
                playVC.bIsAP = self.bIsAP;
                playVC.channelModel = cell.channelModel;
                [self.navigationController pushViewController:playVC animated:YES];
                
                
            }else{
                [XHToast showTopWithText:NSLocalizedString(@"请选择您想要的通道列表(设备)", nil) topOffset:160];
            }
            
        }

    }else{
        [XHToast showTopWithText:NSLocalizedString(@"请先选择您想观看的相机(设备)", nil) topOffset:160];
    }
}

#pragma mark - 竖屏云存录像回放点击事件
- (IBAction)cloudBtnVerticalClick:(id)sender
{
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.selectIndexPath];
        if (cell.listModel) {
            if ([[unitl get_User_id] isEqualToString:cell.listModel.owner_id]) {//自己设备
                [self setDeviceFeature:cell.listModel];
                if ([cell.listModel.enableCloud isEqualToString:@"1"]) {
                    OnlyPlayBackVC * playVC = [[OnlyPlayBackVC alloc]init];
                    playVC.titleName = cell.listModel.name;
                    playVC.listModel = cell.listModel;
                    playVC.bIsEncrypt = cell.listModel.enable_sec;
                    playVC.key = cell.listModel.dev_p_code;
                    playVC.isDeviceVideo = NO;
                    playVC.bIsAP = self.bIsAP;
                    [self.navigationController pushViewController:playVC animated:YES];
                }else{
                    [XHToast showCenterWithText:NSLocalizedString(@"未开通云存储功能，请先开通", nil)];
                }
            }else{//好友分享
                
                if (!isNodeTreeMode) {
                    shareFeature *shareFeature = cell.listModel.ext_info.shareFeature;
                    if ([shareFeature.hp intValue] == 1) {
                        if (cell.listModel.enableOperator == 1) {
                            if ([cell.listModel.enableCloud isEqualToString:@"1"]) {
                                OnlyPlayBackVC * playVC = [[OnlyPlayBackVC alloc]init];
                                playVC.titleName = cell.listModel.name;
                                playVC.listModel = cell.listModel;
                                playVC.bIsEncrypt = cell.listModel.enable_sec;
                                playVC.key = cell.listModel.dev_p_code;
                                playVC.isDeviceVideo = NO;
                                playVC.bIsAP = self.bIsAP;
                                [self.navigationController pushViewController:playVC animated:YES];
                            }else{
                                [XHToast showCenterWithText:NSLocalizedString(@"未开通云存储功能，请先开通", nil)];
                            }
                        }else{
                            [XHToast showCenterWithText:NSLocalizedString(@"非分享时间段内无法查看设备录像", nil)];
                        }
                    }else{
                        [XHToast showCenterWithText:NSLocalizedString(@"您的好友未将录像回放权限分享给您", nil)];
                    }
                }else{
                    //子账号(途虎)
                    if ([cell.listModel.enableCloud isEqualToString:@"1"]) {
                        OnlyPlayBackVC * playVC = [[OnlyPlayBackVC alloc]init];
                        playVC.titleName = cell.listModel.name;
                        playVC.listModel = cell.listModel;
                        playVC.bIsEncrypt = cell.listModel.enable_sec;
                        playVC.key = cell.listModel.dev_p_code;
                        playVC.isDeviceVideo = NO;
                        playVC.bIsAP = self.bIsAP;
                        [self.navigationController pushViewController:playVC animated:YES];
                    }else{
                        [XHToast showCenterWithText:NSLocalizedString(@"未开通云存储功能，请先开通", nil)];
                    }
                }
                
            }
            
        }else{
            
            //判断是否是多通道设备
            if (cell.channelModel) {
                
                OnlyPlayBackVC * playVC = [[OnlyPlayBackVC alloc]init];
                playVC.titleName = cell.channelModel.chanName;//cell.listModel.name;
                playVC.listModel = self.listModel;
                playVC.bIsEncrypt = cell.listModel.enable_sec;
                playVC.key = cell.listModel.dev_p_code;
                playVC.isDeviceVideo = NO;
                playVC.bIsAP = self.bIsAP;
                playVC.channelModel = cell.channelModel;
                [self.navigationController pushViewController:playVC animated:YES];
                
                
            }else{
                [XHToast showTopWithText:NSLocalizedString(@"请选择您想要的通道列表(设备)", nil) topOffset:160];
            }
            
            
        }
        
    }else{
        [XHToast showTopWithText:NSLocalizedString(@"请先选择您想观看的相机(设备)", nil) topOffset:160];
    }
     
}

#pragma mark - 购买云存方法
- (IBAction)cloudSaveClick:(id)sender
{
    /*
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.selectIndexPath];
        if ([[unitl get_User_id] isEqualToString:self.listModel.owner_id]) {
            if (cell.listModel) {
                [self setDeviceFeature:cell.listModel];
                if (self.feature.isCloudStorage) {
                    MyCloudStorageVC *myCloudVC = [[MyCloudStorageVC alloc]init];
                    myCloudVC.deviceId = cell.listModel.ID;
                    myCloudVC.deviceImgUrl = cell.listModel.ext_info.dev_img;
                    if(![NSString isNull:cell.listModel.name]){
                        myCloudVC.deviceName = cell.listModel.name;
                    }else{
                        myCloudVC.deviceName = cell.listModel.type;
                    }
                    [self.navigationController pushViewController:myCloudVC animated:YES];
                }else{
                    [XHToast showBottomWithText:NSLocalizedString(@"该设备不支持云存功能", nil)];
                }
            }else{
                [XHToast showTopWithText:NSLocalizedString(@"请选择您想要的通道列表(设备)", nil) topOffset:160];
            }
        }else{
            [XHToast showBottomWithText:NSLocalizedString(@"该设备为分享设备无法购买云存", nil)];
        }
    }else{
        [XHToast showTopWithText:NSLocalizedString(@"请先选择您想观看的相机(设备)", nil) topOffset:160];
    }
     */
}

#pragma mark - - - 播放提示声
void soundCompleteCallbackRealTime(SystemSoundID soundID, void *clientData){
    NSLog(@"播放完成...");
}

/** 播放音效文件 */
- (void)playSoundEffect:(NSString *)name{
    // 获取音效
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    // 1、获得系统声音ID
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    //// 如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
    // AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallbackRealTime, NULL);
    // 2、播放音频
    AudioServicesPlaySystemSound(soundID); // 播放音效
}

#pragma mark - 得到截图
- (UIImage *)snapshot:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size,YES,0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark ------退出当前界面时截取图片
- (void)backCutImage
{
    UIImage *ima ;
    [self.collectionView layoutIfNeeded];
    for (int i = 0; i < 4; i++) {
        NSIndexPath * tempIndex = [NSIndexPath indexPathForItem:i inSection:0];
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:tempIndex];//_selectIndexPath
        if ([cell.listModel.ID isEqualToString:self.cutImageID]) {
            ima = [self snapshot:cell.playView];
            NSLog(@"截图cell：%@ tempIndex:%@ ima:%@",cell,tempIndex,ima);
        }
    }
    dispatch_async(dispatch_queue_create("backCutImage", NULL), ^{
        @synchronized (CUTLOCK) {
            if (self.cutImageID && self.selectIndexPath && self.b_I_Frame_Start && !self.b_Video_Play_fail) {
                [self saveSmallImageWithImage:ima Url:@"" AtDirectory:saveCutImageBaseURLDirectory ImaNameStr:self.cutImageID];//_listModel.ID
            // NSLog(@"【moitoringVC】保存截图的id：%@==self.selectedIndex:%@",self.cutImageID,self.selectIndexPath);
//            NSLog(@"播==self.b_I_Frame_Start:%@==self.b_Video_Play_fail:%@",self.b_I_Frame_Start?@"YES":@"NO",self.b_Video_Play_fail?@"YES":@"NO");
                if (ima) {
                    NSDictionary * dic = @{@"updataImageID":self.cutImageID,@"selectedIndex":self.selectedIndex};
                    [[NSNotificationCenter defaultCenter]postNotificationName:UpDataCutImageWithID object:nil userInfo:dic];
                }
            }
        }
    });
}

#pragma mark ------------ collectionView的代理方法
- (void)cellSelectClick:(BOOL)isPlay
{
    if (isPlay) {
        NSLog(@"播放中,单击");
    }
    else{
        NSLog(@"没有播放,单机");
    }
}

#pragma mark ------判断屏幕状态
-(void)panduanDevece_nvr:(NSNotification *)noit{
    
}
- (void)stopMainBtnStop
{
    //    [self btnStopClick:self.btn_stop];
    self.isLive = NO;
}

#pragma mark ------保存录像代理
- (void)stopRecordBlockFunc
{
    
}
#pragma mark ------判断当前是否录制
- (void)judgeIsRecord
{
    if (self.isRecord) {
        [self videoBtnVerticalClick:self.videoBtn];
    }
}
- (void)judgeIsRecord1
{
    if (self.isRecord) {
        [self videoBtnClick:self.recordBtn];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden
{
    if (self.isFull) {
        return YES;
    }
    else
        return NO;
    // 返回NO表示要显示，返回YES将hiden
}
#pragma mark - 电子控制相关功能
- (void)electronicControlVCAction:(UIButton *)btn
{
    NSInteger control_num;
    if (btn.tag == electronicControlBtnType_subtract) {//焦距减
        control_num = 31;
      //  NSLog(@"开始电子放大缩小成功【-】");
    }else
    {
        control_num = 30;
       // NSLog(@"开始电子放大缩小成功【+】");
    }
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
    NSNumber * chan_num = [NSNumber numberWithInteger:cell.chan_id];
    NSNumber * cmd_num = [NSNumber numberWithInteger:control_num];
    NSMutableDictionary * changeDic = [NSMutableDictionary dictionary];
    [changeDic setObject:self.listModel.ID forKey:@"dev_id"];
    [changeDic setObject:chan_num forKey:@"chan_id"];
    [changeDic setObject:cmd_num forKey:@"cmd"];
    [changeDic setObject:@"2" forKey:@"speed"];
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/ptz/start" parameters:changeDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSLog(@"开始电子放大缩小成功");
        }else{
           // [XHToast showCenterWithText:NSLocalizedString(@"云台控制开启失败，请稍候再试", nil)];
        }
        
    } failure:^(NSError * _Nonnull error) {
       // [XHToast showCenterWithText:NSLocalizedString(@"云台控制开启失败，请检查您的网络", nil)];
    }];
}

- (void)electronicControlVCStopAction:(UIButton*)btn
{
    NSLog(@"停止【电子】成功111");
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
    NSNumber * chan_num = [NSNumber numberWithInteger:cell.chan_id];
    NSMutableDictionary * changeDic = [NSMutableDictionary dictionary];
    [changeDic setObject:self.listModel.ID forKey:@"dev_id"];
    [changeDic setObject:chan_num forKey:@"chan_id"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/ptz/stop" parameters:changeDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSLog(@"停止【电子】成功");
        }else
        {
         //   [XHToast showCenterWithText:NSLocalizedString(@"云台控制关闭失败，请稍候再试", nil)];
        }
    } failure:^(NSError * _Nonnull error) {
       // [XHToast showCenterWithText:NSLocalizedString(@"云台控制关闭失败，请检查您的网路", nil)];
    }];
}

#pragma mark ----- 暂停按钮点击事件【大屏状态】
- (void)suspendBtnClick:(id)sender{
    if (_selectIndexPath == nil) {
        NSLog(@"暂停【大屏状态】播放按钮的选择index == nil ，return");
        return;
    }else{
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        UIButton *btn = (UIButton *)sender;
        btn.selected = !btn.selected;
        if (cell.isPlay) {//btn.selected
            [XHToast showTopWithText:NSLocalizedString(@"视频停止", nil) topOffset:160];
            [self stopVideo];//视频停止播放
        }
    }
}

#pragma mark ----- 音量按钮点击事件【大屏状态】
- (void)voiceBtnClick:(id)sender{
    if (_selectIndexPath == nil) {
        NSLog(@"声音【大屏状态】播放按钮的选择index == nil ，return");
        return;
    }else{
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        UIButton *btn = (UIButton *)sender;
        //        btn.selected = !btn.selected;
        
        if (isCloseSound) {
            [btn setBackgroundImage:[UIImage imageNamed:@"realTimeShengyin_n"] forState:UIControlStateNormal];
            isCloseSound = NO;
        }else{
            [btn setBackgroundImage:[UIImage imageNamed:@"realTimejingyin_n"] forState:UIControlStateNormal];
            isCloseSound = YES;
        }

        if (cell.isPlay == YES) {
            if (!isCloseSound) {//btn.selected
                [XHToast showTopWithText:NSLocalizedString(@"声音:开", nil) topOffset:160];
                [cell.videoManage JWPlayerManageSetAudioIsOpen:YES];
            }else{
                [XHToast showTopWithText:NSLocalizedString(@"声音:关", nil) topOffset:160];
                [cell.videoManage JWPlayerManageSetAudioIsOpen:NO];
            }
        }
    }
}

#pragma mark ----- 锁定滚轮按钮点击事件【大屏状态】
- (void)lockRockerBtnClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [XHToast showTopWithText:NSLocalizedString(@"滚轮已锁定", nil) topOffset:160];
        self.ZMRocker1.hidden = NO;
        self.IsRockLock = YES;
    }else{
        [XHToast showTopWithText:NSLocalizedString(@"滚轮已解锁", nil) topOffset:160];
        self.IsRockLock = NO;
        self.ZMRocker1.hidden = YES;
    }
}

#pragma mark ----- 对讲按钮【大屏状态】
- (void)pressTalkClick:(id)sender forEvent:(UIEvent *)event{
    UITouchPhase phase = event.allTouches.anyObject.phase;
    if (phase == UITouchPhaseBegan) {
        if (_selectIndexPath) {
            MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
            self.currentSelectIndexPath = _selectIndexPath;
            [CircleLoading showCircleInView:self.view andTipH:NSLocalizedString(@"正在开启对讲", nil)];
            [cell.videoManage JWPlayerManageStartAudioTalkWithCompletionBlock:^(JWErrorCode errorCode) {
                if (errorCode == 0) {
                    [CircleLoading hideCircleInView:self.view];
                    [self createPressTalkUI];
                }else{
                    [XHToast showBottomWithText:[NSString stringWithFormat:@"%@",NSLocalizedString(@"开启对讲失败", nil)]];
                }
            }];
        }else{
            [XHToast showTopWithText:NSLocalizedString(@"请先单击选中您想要对讲的视频窗口", nil) topOffset:160 duration:1.0f];
        }
    }else if(phase == UITouchPhaseEnded)
    {
        NSLog(@"大屏松开对讲");
        [self stopTalkWith];
    }
}
#pragma mark ----- 截图按钮点击事件【大屏状态】testDemo
- (void)screenshotBtnClick:(id)sender{
    
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        
        BOOL isplay = [cell.videoManage JWPlayerManageGetPlayState];
        if (isplay == YES) {
            //    播放截图音效
            [self playSoundEffect:@"capture.caf"];
            UIImage *ima = [self snapshot:cell.playView];
            [XHToast showTopWithText:NSLocalizedString(@"已保存截图到我的文件", nil) topOffset:160];
            WeakSelf(self);
            [weakSelf createShortcutPicToFilebIsVideo:NO shortCutImage:ima bIsFullScreen:YES];
            dispatch_async(dispatch_queue_create("photoScreenshot", NULL), ^{
                @synchronized (self) {
                    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
                        //创建文件名称
                        NSString *fileName = [NSString stringWithFormat:@"/%@/file",[unitl get_user_mobile]];
                        [FileTool createRootFilePath:fileName];
                        //创建文件路径
                        NSString *modelfileName = [FileTool createFileName];
                        NSString *filePath = [FileTool getFilePath:modelfileName];
                        //创建文件管理器
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        BOOL ret = [fileManager createFileAtPath:[NSString stringWithFormat:@"%@.jpg",filePath] contents:UIImagePNGRepresentation(ima) attributes:nil];
                        if (ret) {
                            [self saveFileModel:ima andPath:[NSString stringWithFormat:@"%@.jpg",modelfileName]andType:1];
                        }else{
                            NSLog(@"截图保存失败");
                        }
                        
                    }
                }
            });
        }else{
            [XHToast showTopWithText:NSLocalizedString(@"视频未播放", nil) topOffset:160];
        }
    }else{
        [XHToast showTopWithText:NSLocalizedString(@"请先单击选中您想要截图的视频窗口", nil) topOffset:160 duration:1.0f];
    }
}
#pragma mark ----- 录屏按钮点击事件【大屏状态】testDemo
- (void)videoBtnClick:(id)sender{
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        //        UIButton *btn = (UIButton *)sender;
        self.recordBtn = (UIButton *)sender;
        
        BOOL isplay = [cell.videoManage JWPlayerManageGetPlayState];
        
        
        if (!self.isRecord && !self.bIsStratPlaying) {
            [XHToast showTopWithText:NSLocalizedString(@"视频未播放", nil) topOffset:160];
            return;
        }
        //判断是否在录制(图标的设置)
        if (self.isRecord == NO) {
            if (isplay == NO) {
                [self.recordBtn setBackgroundImage:[UIImage imageNamed:@"zirealTimeVideo_n"] forState:UIControlStateNormal];
            }else{
                [self.recordBtn setBackgroundImage:[UIImage imageNamed:@"zirealTimeVideo_close"] forState:UIControlStateNormal];
            }
        }else{
            [self.recordBtn setBackgroundImage:[UIImage imageNamed:@"zirealTimeVideo_n"] forState:UIControlStateNormal];
        }
        
        if (!self.isRecord) {
            //判读视频是否播放
            if (isplay == NO) {
                [XHToast showTopWithText:NSLocalizedString(@"视频未播放", nil) topOffset:160];
                return;
            }
            //播放录音音效
            [self playSoundEffect:@"record.caf"];
            [XHToast showTopWithText:NSLocalizedString(@"视频开始录制", nil) topOffset:160];
            self.redDotView.hidden = NO;
            self.recordBtn.selected = YES;
            if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
                //创建文件名称
                NSString *fileName = [NSString stringWithFormat:@"/%@/file",[unitl get_user_mobile]];
                [FileTool createRootFilePath:fileName];
                //创建文件路径
                NSString *modelfileName = [FileTool createFileName];
                NSString *filePath = [FileTool getFilePath:modelfileName];
                [cell.videoManage JWPlayerManageStartRecordWithPath:filePath];
                UIImage *ima = [self snapshot:cell.playView];
                [self saveFileModel:ima andPath:[NSString stringWithFormat:@"%@.mp4",modelfileName]andType:0];
                
            }
            self.isRecord = YES;
        }else{
            //播放录音音效
            [self playSoundEffect:@"record.caf"];
            [XHToast showTopWithText:NSLocalizedString(@"视频录制成功，已保存到我的文件", nil) topOffset:160];
            self.redDotView.hidden = YES;
            self.recordBtn.selected = NO;
            [cell.videoManage JWPlayerManageStopRecord];
            UIImage *ima = [self snapshot:cell.playView];
            [self createShortcutPicToFilebIsVideo:YES shortCutImage:ima bIsFullScreen:YES];
            self.isRecord = NO;
        }
    }else{
        [XHToast showTopWithText:NSLocalizedString(@"请先单击选中您想要录制的视频窗口", nil) topOffset:160 duration:1.0f];
    }
}

#pragma mark ----- 创建三码流大屏选择View
- (void)createFullScreenThreeStreamView{
    [self.view addSubview:self.fullScreenthreeStreamView];
    [self.fullScreenthreeStreamView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30);
        make.bottom.equalTo(self.view.mas_bottom).offset(-(0.7*iPhoneHeight/9+30));
        make.size.mas_equalTo(CGSizeMake(0.7*iPhoneHeight/9, 0.7*iPhoneHeight/3+15));
    }];
    //流畅按钮
    [self.fullScreenthreeStreamView addSubview:self.fd_fullBtn];
    [self.fd_fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.fullScreenthreeStreamView.mas_bottom).offset(0);
        make.centerX.equalTo(self.fullScreenthreeStreamView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(0.7*iPhoneHeight/9, 0.7*iPhoneHeight/9));
    }];
    //标清按钮
    [self.fullScreenthreeStreamView addSubview:self.sd_fullBtn];
    [self.sd_fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.fullScreenthreeStreamView.mas_centerY);
        make.centerX.equalTo(self.fullScreenthreeStreamView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(0.7*iPhoneHeight/9, 0.7*iPhoneHeight/9));
    }];
    //高清按钮
    [self.fullScreenthreeStreamView addSubview:self.hd_fullBtn];
    [self.hd_fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fullScreenthreeStreamView.mas_top).offset(0);
        make.centerX.equalTo(self.fullScreenthreeStreamView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(0.7*iPhoneHeight/9, 0.7*iPhoneHeight/9));
    }];
}

//大屏三码流切换按钮
- (void)hdBtnClick:(id)sender{
    if (_selectIndexPath == nil) {
        [XHToast showTopWithText:NSLocalizedString(@"请选择您想要的通道列表", nil) topOffset:160];
        return;
    }else{
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        if (cell.isPlay == YES){
            if ([cell.listModel.type isEqualToString:@"GB"]) {
                [XHToast showTopWithText:NSLocalizedString(@"该设备不支持清晰度切换", nil) topOffset:160];
            }else{
                [self createFullScreenThreeStreamView];
                self.fullScreenthreeStreamView.hidden = NO;
            }
            
        }else{
            [XHToast showTopWithText:NSLocalizedString(@"视频未播放", nil) topOffset:160];
        }
    }
}

//流畅
- (void)fdFullClick{
    if (self.videoTypeStatus == JWVideoTypeStatusFluency) {
        return;
    }
    [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_fd", nil)] forState:UIControlStateNormal];
    [XHToast showTopWithText:NSLocalizedString(@"流畅", nil) topOffset:160];
    [self judgeIsRecord1];//如果正在录像就停止录制
    self.videoTypeStatus = JWVideoTypeStatusFluency;
    //[self getVideoAddress];
    [self changeVideoDefinition];
}

//标清
- (void)sdFullClick{
    if (self.videoTypeStatus == JWVideoTypeStatusNomal) {
        return;
    }
    [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_sd", nil)] forState:UIControlStateNormal];
    [XHToast showTopWithText:NSLocalizedString(@"标清", nil) topOffset:160];
    [self judgeIsRecord1];//如果正在录像就停止录制
    self.videoTypeStatus = JWVideoTypeStatusNomal;
    //[self getVideoAddress];
    [self changeVideoDefinition];
}

//高清
- (void)hdFullClick{
    if (self.videoTypeStatus == JWVideoTypeStatusHd) {
        return;
    }
    [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_hd", nil)] forState:UIControlStateNormal];
    [XHToast showTopWithText:NSLocalizedString(@"高清", nil) topOffset:160];
    [self judgeIsRecord1];//如果正在录像就停止录制
    self.videoTypeStatus = JWVideoTypeStatusHd;
    //[self getVideoAddress];
    [self changeVideoDefinition];
}

#pragma mark----------滚轮的代理协议-----------
-(void)rockerDidChangeDirection:(ZMRocker *)rocker{
    //    up down left right   1-2-3-4   center-0
    // MM_Log_AndLine(@"%ld",(long)rocker.direction);
    switch (rocker.direction) {
        case 1:
        {
            _control_num = 1;
            [self ControlFunc];
        }
            break;
        case 2:
        {
            _control_num = 2;
            [self ControlFunc];
        }
            break;
        case 3:
        {
            _control_num = 3;
            [self ControlFunc];
        }
            break;
        case 4:
        {
            _control_num = 4;
            [self ControlFunc];
        }
            break;
        case 0:
        {
            [self controlStop];
        }
            break;
        default:
            break;
    }
}

#pragma mark - 加载设备列表数据
- (void)loadPublicListData
{
    self.deviceData =(NSMutableArray *)[unitl getCameraModel];
}

//=========================lazy loading=========================
#pragma mark  -------------- 懒加载成员变量
//新增 ，用来显示设备列表数组
- (NSMutableArray *)deviceData
{
    if (!_deviceData) {
        _deviceData = [NSMutableArray arrayWithCapacity:0];
    }
    return _deviceData;
}

//列表消失背景按钮
- (UIButton *)disBtn
{
    if (self.isFull == YES) {
        if (!_disBtn) {
            _disBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, iPhoneHeight, iPhoneWidth)];
            _disBtn.backgroundColor = [UIColor lightGrayColor];
            _disBtn.alpha = 0.5;
            [_disBtn addTarget:self action:@selector(disBtnClick) forControlEvents:UIControlEventTouchUpInside];
        }
    }else{
        if (!_disBtn) {
            _disBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
            _disBtn.backgroundColor = [UIColor lightGrayColor];
            _disBtn.alpha = 0.5;
            [_disBtn addTarget:self action:@selector(disBtnClick) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _disBtn;
}

//通道列表选择
- (MultiChannelView *)multiTabView
{
    if (self.isFull == YES) {
        if (!_multiTabView) {
            _multiTabView = [[MultiChannelView alloc]initWithFrame:CGRectMake(0, 0,iPhoneWidth, iPhoneHeight/2+60) isMultiChannel:self.isMultiChannel devId:self.dev_id andDevModel:self.listModel];
            _multiTabView.channelDelegate = self;
        }
    }else{
        if (!_multiTabView) {
           float height = iPhoneHeight-CGRectGetMaxY(self.btnBack.frame)-20-iPhoneNav_StatusHeight+44;
            _multiTabView = [[MultiChannelView alloc]initWithFrame:CGRectMake(0, iPhoneHeight/2-50, 0.8*iPhoneWidth, height) isMultiChannel:self.isMultiChannel devId:self.dev_id andDevModel:self.listModel];
            _multiTabView.channelDelegate = self;
        }
    }
    
    
    return _multiTabView;
}


- (dispatch_queue_t)myActionQueue
{
    if (!_myActionQueue) {
        _myActionQueue = dispatch_queue_create("actionQueue", NULL);
    }
    return _myActionQueue;
}

- (UIView *)deleteBgView
{
    if (!_deleteBgView) {
        _deleteBgView = [[UIView alloc]initWithFrame:CGRectZero];
        _deleteBgView.hidden = YES;
        _deleteBgView.backgroundColor = [UIColor colorWithRed:6.0/255.0 green:120.0/255.0 blue:239.0/255.0 alpha:1.0];
    }
    return _deleteBgView;
}

- (UIImageView *)deleteImageV
{
    if (!_deleteImageV) {
        _deleteImageV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"delete_close"]];
        _deleteImageV.hidden = YES;
    }
    return _deleteImageV;
}

//工具栏的懒加载
-(controlViewInFullScreen *)controlFunctionView{
    if (!_controlFunctionView) {
        _controlFunctionView = [[controlViewInFullScreen alloc]initLayoutOfFeature:self.feature.isTalk andCloudDeck:self.feature.isCloudDeck];
        _controlFunctionView.delegate = self;
    }
    return _controlFunctionView;
}

//电子缩放
-(electronicControlView *)electronicControlV{
    if (!_electronicControlV) {
        _electronicControlV = [[electronicControlView alloc]initWithFrame:CGRectMake(0, 0,150, 0.6*iPhoneHeight/9)];
        _electronicControlV.delegate = self;
    }
    return _electronicControlV;
}

//返回按钮的懒加载
-(BackBtnView *)BackBtnView1{
    if (!_BackBtnView1) {
        _BackBtnView1 = [[BackBtnView alloc]init];
        _BackBtnView1.delegate = self;
    }
    return _BackBtnView1;
}

//滚轮按钮显示2.0
- (ZMRocker *)ZMRocker1
{
    if (!_ZMRocker1) {
        _ZMRocker1 =[[ZMRocker alloc]initWithFrame:CGRectMake(0, 0, 117, 117)];
        _ZMRocker1.hidden = YES;
        _ZMRocker1.delegate = self;
    }
    return _ZMRocker1;
}

#pragma mark ----- 大屏三码流选择View
-(UIView *)fullScreenthreeStreamView{
    if (!_fullScreenthreeStreamView) {
        _fullScreenthreeStreamView = [[UIView alloc]init];
        _fullScreenthreeStreamView.backgroundColor = [UIColor clearColor];
        _fullScreenthreeStreamView.hidden = YES;
    }
    return _fullScreenthreeStreamView;
}

#pragma mark ----- 全屏流畅按钮懒加载
-(UIButton *)fd_fullBtn{
    if (!_fd_fullBtn) {
        _fd_fullBtn = [[UIButton alloc]init];
        [_fd_fullBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_fd", nil)] forState:UIControlStateNormal];
        [_fd_fullBtn addTarget:self action:@selector(fdFullClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fd_fullBtn;
}
#pragma mark ----- 全屏标清按钮懒加载
-(UIButton *)sd_fullBtn{
    if (!_sd_fullBtn) {
        _sd_fullBtn = [[UIButton alloc]init];
        [_sd_fullBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_sd", nil)] forState:UIControlStateNormal];
        [_sd_fullBtn addTarget:self action:@selector(sdFullClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sd_fullBtn;
}
#pragma mark ----- 全屏高清按钮懒加载
-(UIButton *)hd_fullBtn{
    if (!_hd_fullBtn) {
        _hd_fullBtn = [[UIButton alloc]init];
        [_hd_fullBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_hd", nil)] forState:UIControlStateNormal];
        [_hd_fullBtn addTarget:self action:@selector(hdFullClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hd_fullBtn;
}

#pragma mark ----- 停止视频播放的按钮
- (void)stopVideo{
    if (_selectIndexPath == nil) {
        NSLog(@"stopVideo 停止播放按钮的选择index == nil ，return");
        return;
    }else{
        NSLog(@"停止");
        self.clickCell.loadView.hidden = YES;
        [[HDNetworking sharedHDNetworking]canleAllHttp];
        //如果正在录像就停止录制
        if (self.isFull) {
            [self judgeIsRecord1];
        }else{
            [self judgeIsRecord];
        }
        
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        
        cell.loadView.hidden = YES;
        
        if (cell.isPlay == YES) {
            //截取正在播放的视频保存到沙盒
            if (self.isCanCut) {
                [self backCutImage];
            }
            cell.isPlay = NO;
            [cell.videoManage JWPlayerManageEndPlayVideoWithBIsStop:YES CompletionBlock:^(JWErrorCode errorCode) {
                if (errorCode == JW_SUCCESS) {
                    cell.addBtn.hidden = YES;
                    cell.reStartBtn.hidden = NO;
                    cell.closeBtn.hidden = NO;
                    NSLog(@"停止成功");
                }else{
                    NSLog(@"停止失败");
                }
            }];
        }else{
            cell.isPlay = NO;
            [cell.videoManage JWPlayerManageEndPlayVideoWithBIsStop:YES CompletionBlock:^(JWErrorCode errorCode) {
                if (errorCode == JW_SUCCESS) {
                    cell.addBtn.hidden = YES;
                    cell.reStartBtn.hidden = NO;
                    cell.closeBtn.hidden = NO;
                    NSLog(@"停止成功");
                }else{
                    NSLog(@"停止失败");
                }
            }];
        }
    }
}


- (void)createOvreUI{
    _ovreView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-_playBack_h-64)];
    _ovreView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_ovreView];
    [_ovreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.VideoViewBack.mas_bottom).offset(0);
        make.left.equalTo(self.VideoViewBack.mas_left).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.right.equalTo(self.VideoViewBack.mas_right).offset(0);
    }];
    
    //创建UIImageView，添加到界面
    if (iPhone_5_Series) {
        _heigh_v = 100;
    }else{
        _heigh_v = 150;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(iPhoneWidth/2-115, _heigh_v, 230, 40)];
    [self.ovreView addSubview:imageView];
    //创建一个数组，数组中按顺序添加要播放的图片（图片为静态的图片）
    NSMutableArray *imgArray = [NSMutableArray array];
    for (int i=1; i<3; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"duijiang%d.png",i]];
        [imgArray addObject:image];
    }
    //把存有UIImage的数组赋给动画图片数组
    imageView.animationImages = imgArray;
    //设置执行一次完整动画的时长
    imageView.animationDuration = 6*0.15;
    //动画重复次数 （0为重复播放）
    imageView.animationRepeatCount = 0;
    //开始播放动画
    [imageView startAnimating];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(iPhoneWidth/2-50, 150, 54, 21)];
    label.text = NSLocalizedString(@"对讲中", nil);
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    [self.ovreView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.ovreView.mas_left).offset(iPhoneWidth/2-27);
        make.bottom.equalTo(imageView.mas_bottom).offset(0);
    }];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 65, 65);
    button.backgroundColor = [UIColor redColor];
    button.layer.cornerRadius = 32.5;
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setBackgroundImage:[UIImage imageNamed:@"redyuan"] forState:UIControlStateNormal];
    [button setTitle:NSLocalizedString(@"挂断", nil) forState:UIControlStateNormal];
    [self.ovreView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.ovreView.mas_left).offset(iPhoneWidth/2-32.5);
        make.top.equalTo(label.mas_bottom).offset(65);
        make.right.equalTo(self.ovreView.mas_left).offset(iPhoneWidth/2+32.5);
    }];
    [button addTarget:self action:@selector(stopTalkWith) forControlEvents:UIControlEventTouchUpInside];
}

- (void)stopTalkWith{
    //self.currentSelectIndexPath = _selectIndexPath;
    if (self.currentSelectIndexPath == _selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        [cell.videoManage JWPlayerManageEndAudioTalkWithCompletionBlock:^(JWErrorCode errorCode) {
            NSLog(@"对讲：errorCode：%ld",(long)errorCode);
            // [XHToast showTopWithText:@"麦克风:关" topOffset:160];
            isCloseTalk = YES;
            self.talkBtn.userInteractionEnabled = YES;
            [self.ovreView removeFromSuperview];
            
            [self.imageBgView removeFromSuperview];
            self.imageBgView = nil;
            [self.animationImageView removeFromSuperview];
            self.animationImageView = nil;
        }];
    }else{
        //        [XHToast showTopWithText:@"请选择您之前所选择的通道" topOffset:160];
        isCloseTalk = YES;
        self.talkBtn.userInteractionEnabled = YES;
        [self.ovreView removeFromSuperview];
        
        [self.imageBgView removeFromSuperview];
        self.imageBgView = nil;
        [self.animationImageView removeFromSuperview];
        self.animationImageView = nil;
    }
}

#pragma mark ----- 设置能力集合
///设置能力集合
- (void)setDeviceFeature:(dev_list*)listModel{
    
    //先判断是不是分享设备
    if ([[unitl get_User_id] isEqualToString:listModel.owner_id]) {//自己设备
        //1.判断Feature这个key到底在不在
        if (!listModel.ext_info.Feature) {
            NSLog(@"不存在Feature");
            self.feature.isWiFi = 0;
            self.feature.isTalk = 0;
            self.feature.isCloudDeck = 0;
            self.feature.isCloudStorage = 0;
            self.feature.isP2P = 0;
        }else{
            //NSLog(@"存在Feature");
            NSString *featureStr = listModel.ext_info.Feature;
            self.feature.isWiFi = [[featureStr substringWithRange:NSMakeRange(0,1)] intValue];
            self.feature.isTalk = [[featureStr substringWithRange:NSMakeRange(2,1)] intValue];
            self.feature.isCloudDeck = [[featureStr substringWithRange:NSMakeRange(4,1)] intValue];
            self.feature.isCloudStorage = [[featureStr substringWithRange:NSMakeRange(6,1)] intValue];
            self.feature.isP2P = [[featureStr substringWithRange:NSMakeRange(8,1)] intValue];
            
        }
    }else{//分享设备
        
        if (!listModel.ext_info.shareFeature) {
            if (isNodeTreeMode) {
                self.feature.isWiFi = 1;
                self.feature.isTalk = 1;
                self.feature.isCloudDeck = 0;
                self.feature.isCloudStorage = 1;
                self.feature.isP2P = 0;
            }
        }else{
            shareFeature *shareFeature = listModel.ext_info.shareFeature;
            self.feature.isWiFi = 0;
            self.feature.isCloudStorage = 0;
            
            self.feature.isP2P = 0;
            self.feature.isTalk = [shareFeature.talk intValue];
            self.feature.isCloudDeck = [shareFeature.ptz intValue];
        }
        
        
    }
    [self judgeVerticalBtnDisplayStatus:listModel];//判断竖屏下按钮的显示状态
    
    //焦距功能根据是否有云台而出现
    if (self.feature.isCloudDeck == 0) {
        self.electronicControlV.hidden = YES;
        self.controlFunctionView.lockRockerBtn.hidden = YES;
        self.ZMRocker1.hidden = YES;
    }else{
        self.electronicControlV.hidden = NO;
        self.controlFunctionView.lockRockerBtn.hidden = NO;
        if (self.controlFunctionView.lockRockerBtn.selected) {
            self.ZMRocker1.hidden = NO;
        }else
        {
            self.ZMRocker1.hidden = YES;
        }
    }
          //  NSLog(@"self.feature.isWiFi:%d,%d,%d,%d,%d",self.feature.isWiFi,self.feature.isTalk,self.feature.isCloudDeck,self.feature.isCloudStorage,self.feature.isP2P);
}

//初始化是否开启功能点
- (void)initIsOpenFunction{
    NSDictionary *dic = [unitl getDataWithKey:VideoPlayerParameters];//获取播放器的声音与清晰度等参数状态
    NSLog(@"播放器的各项参数值%@",dic);
    if (dic) {
        //声音
        NSString *isCloseSoundStr = [dic objectForKey:@"isCloseSound"];
        if ([isCloseSoundStr boolValue] == YES) {//表示声音关闭
            //声音关闭
            isCloseSound = YES;
            [self.btn_sound setImage:[UIImage imageNamed:@"sound_close_n"] forState:UIControlStateNormal];
        }else{
            //声音开启
            isCloseSound = NO;
            [self.btn_sound setImage:[UIImage imageNamed:@"sound_open_n"] forState:UIControlStateNormal];
        }
        
        //清晰度
        NSString *videoClarity = [dic objectForKey:@"videoClarity"];
        if ([videoClarity isEqualToString:@"JWVideoTypeStatusHd"]) {//高清
            self.videoTypeStatus = JWVideoTypeStatusHd;
            [self.btn_hd setTitle:NSLocalizedString(@"高清", nil) forState:UIControlStateNormal];
        }else if ([videoClarity isEqualToString:@"JWVideoTypeStatusFluency"]){//流畅
            self.videoTypeStatus = JWVideoTypeStatusFluency;
            [self.btn_hd setTitle:NSLocalizedString(@"流畅", nil) forState:UIControlStateNormal];
        }else{//标清
            self.videoTypeStatus = JWVideoTypeStatusNomal;
            [self.btn_hd setTitle:NSLocalizedString(@"标清", nil) forState:UIControlStateNormal];
        }
        
    }else{//默认状态
        //声音的关闭与开启
        isCloseSound = YES;
        [self.btn_sound setImage:[UIImage imageNamed:@"sound_close_n"] forState:UIControlStateNormal];
        //高清的关闭与开启
        self.videoTypeStatus = JWVideoTypeStatusNomal;//默认标清JWVideoTypeStatusHd
        [self.btn_hd setTitle:NSLocalizedString(@"标清", nil) forState:UIControlStateNormal];//高清
    }
    //对讲的关闭与开启
    isCloseTalk = YES;
    [self.talkBtn setImage:[UIImage imageNamed:@"talkback_able"] forState:UIControlStateNormal];
    //录像的关闭与开启
    [self.videoBtn setImage:[UIImage imageNamed:@"shootVideo_able"] forState:UIControlStateNormal];
    
}

//判断是否关闭声音
- (void)judgeIsCloseSound{
    if (isCloseSound) {//判断是否关闭声音
        [self.btn_sound setImage:[UIImage imageNamed:@"sound_open_n"] forState:UIControlStateNormal];
        isCloseSound = NO;
    }else{
        [self.btn_sound setImage:[UIImage imageNamed:@"sound_close_n"] forState:UIControlStateNormal];
        isCloseSound = YES;
    }
}

#pragma mark - 跳转设置界面
- (void)jumpToSetting
{
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.selectIndexPath];
        if (cell.listModel) {
            
            //先判断是不是分享设备
            if ([[unitl get_User_id] isEqualToString:cell.listModel.owner_id]) {//自己设备self.listModel
                if (cell.listModel.device_class == 1) {//普通设备
                    GeneralDeviceSettingVC *setVC = [[GeneralDeviceSettingVC alloc]init];
                    setVC.dev_mList = cell.listModel;
                    setVC.currentIndex = self.selectedIndex;
                    [self.navigationController pushViewController:setVC animated:YES];
                }else{//安全网关【NT4、J3】
                    SpecialDeviceSettingVC *setVC = [[SpecialDeviceSettingVC alloc]init];
                    setVC.dev_mList = cell.listModel;
                    setVC.currentIndex = self.selectedIndex;
                    [self.navigationController pushViewController:setVC animated:YES];
                }
            }else{
                CancelShareSettingVC *setVC = [[CancelShareSettingVC alloc]init];
                setVC.dev_mList = cell.listModel;
                UIImage *ima;
                ima = [self snapshot:cell.playView];
                setVC.currentVideo_CutImage = ima;
                [self.navigationController pushViewController:setVC animated:YES];
            }
        }else{
            [XHToast showTopWithText:NSLocalizedString(@"请选择您想要的通道列表(设备)", nil) topOffset:160];
        }
    }else{
        [XHToast showTopWithText:NSLocalizedString(@"请先选择您想观看的相机(设备)", nil) topOffset:160];
    }

}

#pragma makr === 分享功能视频到微信
- (void)shareVideoFunc
{
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.selectIndexPath];
            if (cell.listModel) {
                [self.shareSheetView shareSheetViewShow];
            }else{
                [XHToast showTopWithText:NSLocalizedString(@"请选择您想要的通道列表(设备)", nil) topOffset:160];
            }
    }else{
        [XHToast showTopWithText:NSLocalizedString(@"请先选择您想观看的相机(设备)", nil) topOffset:160];
    }
}

#pragma mark - 分享的代理方法
//手机好友分享
- (void)sharetoPhoneClick
{
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.selectIndexPath];
    //先判断是不是分享设备
    if ([[unitl get_User_id] isEqualToString:cell.listModel.owner_id]) {//自己设备self.listModel
        FriendsSharedVC *shareVC = [[FriendsSharedVC alloc]init];
        shareVC.dev_mList = self.listModel;
        [self.navigationController pushViewController:shareVC animated:YES];
    }else{
        [XHToast showCenterWithText:NSLocalizedString(@"您不是该设备的主人，暂时无法分享手机好友", nil)];
    }
}

//微信好友分享
- (void)sharetoWeChatClick
{
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.selectIndexPath];
    if (cell.listModel.status == 0) {//self.listModel
        [XHToast showCenterWithText:NSLocalizedString(@"当前设备不在线，无法进行微信视频分享", nil)];
    }else{
        ShareVideoToWeixinVC * shareToweixinVC = [[ShareVideoToWeixinVC alloc]init];
        UIImage *ima ;
        ima = [self snapshot:cell.playView];
        shareToweixinVC.currentVideo_CutImage = ima;
        shareToweixinVC.dev_id = cell.listModel.ID;//self.dev_id
        shareToweixinVC.devName = cell.listModel.name;
        NSLog(@"大屏的devID估计是不存在：%@",self.dev_id);
        [self.navigationController pushViewController:shareToweixinVC animated:YES];
    }
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

#pragma mark - 判断竖屏下按钮的显示状态
- (void)judgeVerticalBtnDisplayStatus:(dev_list*)listModel
{
    //cell方式获取到的model不准【后期得修改问题会产生bug】
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
   // NSLog(@"cell的modelName:%@ =====  listModel的modelName：%@",cell.listModel.name,listModel.name);
    //先判断是不是分享设备
    if ([[unitl get_User_id] isEqualToString:listModel.owner_id]) {//自己设备
        
        //对讲
        if (self.feature.isTalk == 1) {
            [self.talkBtn setImage:[UIImage imageNamed:@"talkback_able"] forState:UIControlStateNormal];
        }else{
            [self.talkBtn setImage:[UIImage imageNamed:@"talkback_unable"] forState:UIControlStateNormal];
        }
        //cell.listModel.enableCloud TODO11
        //云存储(自己的设备SD卡界面是能进去的)
        if (self.feature.isCloudStorage == 1) {
            if ([listModel.enableCloud isEqualToString:@"1"]) {
                [self.cloudBtn setImage:[UIImage imageNamed:@"cloudVideo_able"] forState:UIControlStateNormal];
            }else{
                [self.cloudBtn setImage:[UIImage imageNamed:@"cloudVideo_unable"] forState:UIControlStateNormal];
            }
        }else{
            if ([listModel.enableCloud isEqualToString:@"1"]) {
                [self.cloudBtn setImage:[UIImage imageNamed:@"cloudVideo_able"] forState:UIControlStateNormal];
            }else{
                [self.cloudBtn setImage:[UIImage imageNamed:@"cloudVideo_unable"] forState:UIControlStateNormal];
            }
            
        }
        
        if ([listModel.enableSD isEqualToString:@"1"]) {
            [self.sdBtn setImage:[UIImage imageNamed:@"sdVideo_able"] forState:UIControlStateNormal];
        }else{
            [self.sdBtn setImage:[UIImage imageNamed:@"sdVideo_unable"] forState:UIControlStateNormal];
        }
        //底部的增值服务模块
        self.ValueAddedServiceView.hidden = NO;
        self.sharedNameLb.hidden = YES;
        
    }else{
        //对讲
        if (self.feature.isTalk == 1) {
            if (listModel.enableOperator == 1) {
                [self.talkBtn setImage:[UIImage imageNamed:@"talkback_able"] forState:UIControlStateNormal];
            }else{
                [self.talkBtn setImage:[UIImage imageNamed:@"talkback_unable"] forState:UIControlStateNormal];
                self.feature.isTalk = 0;
            }
        }else{
            [self.talkBtn setImage:[UIImage imageNamed:@"talkback_unable"] forState:UIControlStateNormal];
        }
        //sd卡/云存储
        shareFeature *shareFeature = listModel.ext_info.shareFeature;
         if ([shareFeature.hp intValue] == 1) {
             if (listModel.enableOperator == 1) {
                 if ([listModel.enableSD isEqualToString:@"1"]) {
                     [self.sdBtn setImage:[UIImage imageNamed:@"sdVideo_able"] forState:UIControlStateNormal];
                 }else{
                     [self.sdBtn setImage:[UIImage imageNamed:@"sdVideo_unable"] forState:UIControlStateNormal];
                 }
                 if ([listModel.enableCloud isEqualToString:@"1"]) {
                     [self.cloudBtn setImage:[UIImage imageNamed:@"cloudVideo_able"] forState:UIControlStateNormal];
                 }else{
                     [self.cloudBtn setImage:[UIImage imageNamed:@"cloudVideo_unable"] forState:UIControlStateNormal];
                 }
             }else{
                 [self.cloudBtn setImage:[UIImage imageNamed:@"cloudVideo_unable"] forState:UIControlStateNormal];
                 [self.sdBtn setImage:[UIImage imageNamed:@"sdVideo_unable"] forState:UIControlStateNormal];
             }
         }else{
             
             if (!isNodeTreeMode) {
                 [self.cloudBtn setImage:[UIImage imageNamed:@"cloudVideo_unable"] forState:UIControlStateNormal];
                 [self.sdBtn setImage:[UIImage imageNamed:@"sdVideo_unable"] forState:UIControlStateNormal];
             }else{
                 [self.cloudBtn setImage:[UIImage imageNamed:@"cloudVideo_able"] forState:UIControlStateNormal];
                 [self.sdBtn setImage:[UIImage imageNamed:@"sdVideo_able"] forState:UIControlStateNormal];
             }
             
             
         }
        //底部的增值服务模块
        self.ValueAddedServiceView.hidden = YES;
        if (listModel) {
            self.sharedNameLb.hidden = NO;
            self.sharedNameLb.text = [NSString stringWithFormat:@"%@ %@%@",NSLocalizedString(@"来自", nil),listModel.owner_name,NSLocalizedString(@"的分享", nil)];
        }else{
            self.sharedNameLb.hidden = YES;
        }
    }
}

// 录像的时候的红点跳动动画
- (UIView *)redDotView
{
    if (!_redDotView) {
        _redDotView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, 8, 8)];
        _redDotView.backgroundColor = [UIColor redColor];
        _redDotView.layer.masksToBounds = YES;
        _redDotView.layer.cornerRadius = 4.f;
        [self.VideoViewBack addSubview:_redDotView];
        [_redDotView.layer addAnimation:[self opacityForever_Animation:1.5] forKey:nil];
    }
    return _redDotView;
}

-(CABasicAnimation *)opacityForever_Animation:(float)time
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];//这是透明度。
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];///没有的话是均匀的动画。
    return animation;
}


@end
