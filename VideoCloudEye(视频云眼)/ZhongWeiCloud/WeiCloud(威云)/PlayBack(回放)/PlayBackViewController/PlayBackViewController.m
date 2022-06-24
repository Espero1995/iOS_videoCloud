//
//  PlayBackViewController.m
//  ZhongWeiEyes
//
//  Created by 张策 on 16/12/7.
//  Copyright © 2016年 张策. All rights reserved.
//

#import "PlayBackViewController.h"
#import "ZCTabBarController.h"
#import "MoreChooseView.h"
#import "SZCalendarPicker.h"
#import "XHToast.h"
#import "VideoModel.h"
#import "TXHRrettyRuler.h"
#import "TimeView.h"
#import "ControlView.h"//需要注释
#import "CenterTimeView.h"
#import "ZCVideoTimeModel.h"
#import "WeiCloudListModel.h"
#import "TimeListModel.h"
#import "PushMsgModel.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "LoadingHubView.h"

#import "JWOpenSdk.h"
#import "JWPlayerManage.h"
#import "JWDeviceRecordFile.h"
#import "ZCVideoManager.h"
#import "ZMRocker.h"



@interface PlayBackViewController ()
<
MoreChooseViewDelegate,
TXHRrettyRulerDelegate,
ControlViewDelegate,
CenterTimeViewDelegate,
UIScrollViewDelegate,
ZMRockerDelegate
>
//{
//    BOOL isAppear;
//    BOOL isCancel;
//}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *VideoViewBackLayout;
@property (weak, nonatomic)UIImageView *ima_videoView;
@property (nonatomic,weak)UIView *playView;
@property (nonatomic,weak)UIView *imaBankView;
@property (nonatomic,strong)UIView * ovreView;
@property (weak, nonatomic) IBOutlet UIView *VideoViewBank;

@property (nonatomic,strong)ZCVideoManager * videoManager;

@property (weak, nonatomic) IBOutlet UIView *btn_back;
@property (weak, nonatomic) IBOutlet UIButton *btn_start;//开始 暂停
@property (weak, nonatomic) IBOutlet UIButton *btn_stop;//停止
@property (weak, nonatomic) IBOutlet UIButton *btn_hd;//子码流主码流
@property (weak, nonatomic) IBOutlet UIButton *btn_full;//全屏
@property (weak, nonatomic) IBOutlet UIButton *btn_cam;//截图
@property (weak, nonatomic) IBOutlet UIButton *btn_voice;
@property (weak, nonatomic) IBOutlet UIButton *btn_sound;//声音
@property (weak, nonatomic) IBOutlet UIButton *btn_video;//录像
@property (weak, nonatomic) IBOutlet UIButton *btn_time;//日期
@property (weak, nonatomic) IBOutlet UIButton *btn_center;//中心录像
@property (weak, nonatomic) IBOutlet UIButton *btn_front;//前端录像
@property (weak, nonatomic) IBOutlet UILabel *lab_jieTu;
@property (nonatomic,strong)NSTimer *timer;

//视频无法播放时显示的画面
@property (strong, nonatomic)UIButton *failVideoBtn;
//加载动画
@property (nonatomic,strong)LoadingHubView *loadingHubView;
//频道列表选择
@property (nonatomic,strong)MoreChooseView *chooseTabView;
//滑动View
@property (nonatomic,strong)UIScrollView *bottowScrollerView;
//控制云台View
@property (nonatomic,strong)ControlView *controlView;//需要注释
//新写云台控制view
//@property (nonatomic,strong)ZMRocker * rocker;
//中心日期View
@property (nonatomic,strong)CenterTimeView *centerTimeView;
//进度条
@property (nonatomic,strong)TXHRrettyRuler *rulerView;
//当前暂无录像图片
@property (nonatomic,strong)UIImageView *noImageView;
//进度条时间显示
@property (nonatomic,strong)TimeView *timeViewnew;
//pagecontrol
@property (nonatomic,strong)UIPageControl *pageControl;
//视频管理者
@property (nonatomic,strong)JWPlayerManage *videoManage;

//图片截图 保存录像
@property (nonatomic, strong)ALAssetsLibrary *assetsLibrary;
//是否中心录像
@property (nonatomic,assign)BOOL isCenter;

//播放速度
@property (nonatomic,assign)int speedInt;
//是否播放
@property (nonatomic,assign)BOOL againPlay;
//是否可以截屏
@property (nonatomic,assign)BOOL isCanCut;
//是否全屏
@property (nonatomic,assign)BOOL isFull;
//是否为直播
@property (nonatomic,assign)BOOL isLive;
//是否hd
@property (nonatomic,assign)BOOL isHd;
//是否正在录像
@property (nonatomic,assign)BOOL isRecord;
//时间模型数组
@property (nonatomic,strong)NSMutableArray *videoTimeModelArr;
//进度条定位的秒
@property (nonatomic,copy)NSString *secStr;
//操作异步串行队列
@property (nonatomic,strong)dispatch_queue_t myActionQueue;
//具体时间
@property (nonatomic,copy)NSString *timeMinStr;

@property (nonatomic,assign) int control_num;
@property (nonatomic,assign) CGFloat heigh_v;
@property (nonatomic,assign) int playBack_h;
@property (nonatomic,assign) int playView_h;

@property (nonatomic,strong)NSTimer * dissTimer;//消失定时器。

@property  BOOL isAppear;
@property  BOOL isCancel;

@end

@implementation PlayBackViewController
{
    //全局旋转变量
    UIDeviceOrientation _orientation;
}
//----------------------------------------system----------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpChildView];
    //进入后台停止播放
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopAllVideo:) name:BEBACKGROUNDSTOP object:nil];
    //进入前台开始播放
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startAllVideo:) name:BEBEFORSTART object:nil];
    //码流连接失效停止播放
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notOnlineStopVideo:) name:ONLINESTREAM object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stop_LoadView) name:PLAYFAIL object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stop_PlayMovie) name:PLAYSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stop_PlayMovie) name:HIDELOADVIEW object:nil];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(PlayFaild) name:PLAYFAIL object:nil];//待做
    
//      [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTimeLabel:) name:RETURNTIMESTAMP object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;

    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    [[HDNetworking sharedHDNetworking]canleAllHttp];
    [self btnStopClick:self.btn_stop];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    //设置屏幕关闭常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//----------------------------------------init----------------------------------------
//时间模型数组
- (NSMutableArray *)videoTimeModelArr
{
    if (!_videoTimeModelArr) {
        _videoTimeModelArr = [NSMutableArray array];
    }
    return _videoTimeModelArr;
}

//频道选择列表
- (MoreChooseView *)chooseTabView
{
    if (!_chooseTabView) {
        _chooseTabView = [[MoreChooseView alloc]initWithFrame:CGRectMake(0, 64,iPhoneWidth-100 , iPhoneHeight-120)];
        _chooseTabView.isSingle = YES;
        _chooseTabView.moreDelegate = self;
    }
    return _chooseTabView;
}

//图片保存者
- (ALAssetsLibrary *)assetsLibrary
{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc]init];
    }
    return _assetsLibrary;
}
//进度条
- (TXHRrettyRuler *)rulerView
{
    if (!_rulerView) {
        _rulerView = [[TXHRrettyRuler alloc] initWithFrame:CGRectMake(20, 85, [UIScreen mainScreen].bounds.size.width - 20 * 2, 75)];
        _rulerView.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
//        _rulerView.backgroundColor = [UIColor greenColor];//待做
        _rulerView.rulerDeletate = self;
    }
    return _rulerView;
}
//没有视频图像
- (UIImageView *)noImageView
{
    if (!_noImageView) {
        _noImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"movie"]];
        _noImageView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-40)/2, 105, 45, 40);
    }
    return _noImageView;
}

//控制云台View
- (ControlView *)controlView
{
    if (!_controlView) {
        _controlView = [ControlView viewFromXib];
        _controlView.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight);
        _controlView.delegate = self;
    }
    return _controlView;
}
/*
- (ZMRocker *)rocker
{
    if (!_rocker) {
        _rocker =[[ZMRocker alloc]initWithFrame:CGRectMake(0, 0, 117, 117)];
        _rocker.hidden = NO;
        _rocker.delegate = self;
    }
    return _rocker;
}
 */

//中心日期View
- (CenterTimeView *)centerTimeView
{
    if (!_centerTimeView) {
        _centerTimeView = [CenterTimeView viewFromXib];
        _centerTimeView.frame = CGRectMake(iPhoneWidth, 0, iPhoneWidth, iPhoneWidth);
        _centerTimeView.delegate = self;
        _centerTimeView.userInteractionEnabled = YES;
    }
    return _centerTimeView;
}
//滑动View
- (UIScrollView *)bottowScrollerView
{
    if (!_bottowScrollerView) {
        _bottowScrollerView = [[UIScrollView alloc]init];
        _bottowScrollerView.delegate = self;
       // _bottowScrollerView.backgroundColor = [UIColor yellowColor];
        // 设置内容大小
        self.bottowScrollerView.contentSize = CGSizeMake(iPhoneWidth, 0);
        // 是否反弹
        _bottowScrollerView.bounces = NO;
        _bottowScrollerView.scrollEnabled = NO;
        // 是否分页
        _bottowScrollerView.pagingEnabled = YES;
        _bottowScrollerView.showsVerticalScrollIndicator = NO;
        // 提示用户,Indicators flash
        [_bottowScrollerView flashScrollIndicators];
        // 是否同时运动,lock
        _bottowScrollerView.directionalLockEnabled = YES;
    }
    return _bottowScrollerView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.numberOfPages = 2;//总的图片页数
        _pageControl.currentPage = 0; //当前页
        _pageControl.pageIndicatorTintColor = [UIColor colorWithHexString:@"dddddd"];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"aeaeae"];
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}

//日期
- (TimeView *)timeViewnew
{
    if (!_timeViewnew) {
        _timeViewnew = [TimeView viewFromXib];
    }
    return _timeViewnew;
}
- (dispatch_queue_t)myActionQueue
{
    if (!_myActionQueue) {
        _myActionQueue = dispatch_queue_create("actionQueue", NULL);
    }
    return _myActionQueue;
}

- (ZCVideoManager*)videoManager
{
    if (!_videoManager) {
        _videoManager = [[ZCVideoManager alloc]init];
        //_videoManager.delegate = self;
    }
    return _videoManager;
}



- (void)setUpChildView
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    self.title = @"视频监控";
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(panduanDevece:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    //导航栏按钮
    [self cteateNavBtn];
    //初始化位全屏
    self.isFull = NO;
    
    //初始化是否hd
    self.isHd = NO;
    //初始化未录制
    self.isRecord = NO;
    //初始化是否重新播放
    self.againPlay = NO;
    //创建按钮相关
    [self setUpBtn];
    //添加播放界面
    [self addPlayVideoView];
    
    //TODO
    //按钮背景消失
    [self performSelector:@selector(videoViewBackHidden) withObject:nil afterDelay:5];

    _isCancel = 1;
    _isAppear = 0;
    //添加按钮背景视图单击渐变效果
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectZhuangtai)];
    [self.VideoViewBank addGestureRecognizer:tap];
//    NSLog(@"打印下地址:%p",self.playView);
    
    
    //添加滑动视图
    [self.view addSubview:self.bottowScrollerView];
    [self.bottowScrollerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lab_jieTu.mas_top).offset(35);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
    }];
    [self.bottowScrollerView addSubview:self.controlView];
    /*
    [self.bottowScrollerView addSubview:self.rocker];
    [self.rocker mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.bottowScrollerView);
        make.height.equalTo(@117);
        make.width.equalTo(@117);
    }];
     */
    
    [self.bottowScrollerView addSubview:self.centerTimeView];
    //添加无视频图像
    [self.centerTimeView addSubview:self.noImageView];
    [self.view addSubview:self.pageControl];
    
    
    //得到日期
    self.timeStr = self.centerTimeView.btn_time.titleLabel.text;
    //如果是报警传进来就变成回放模式
    if (self.isWarning) {
        if (self.pushMsgModel) {
            [self getWarningRecordVideo:self.timeStr];
            [self.bottowScrollerView setContentOffset:CGPointMake(iPhoneWidth, 0) animated:YES];
        }
    }
    else{
        //正常状态播放实时视频
        [self getVideoAddress];
    }
    [self.videoManager returnTimeStamp:^(double showTime) {
        
        NSLog(@"根据后台来的时间，刷新当前播放时间轴上的时间显示 是 ：%f",showTime);
    }];
}

#pragma mark ------按钮状态初始化
- (void)setUpBtn
{
    [self.btn_start setImage:[UIImage imageNamed:@"暂停_h"] forState:UIControlStateHighlighted];
    [self.btn_start setImage:[UIImage imageNamed:@"暂停_n"] forState:UIControlStateSelected];
    [self.btn_sound setImage:[UIImage imageNamed:@"sound_open_n"] forState:UIControlStateSelected];
    [self.btn_hd setImage:[UIImage imageNamed:@"hd_h"] forState:UIControlStateSelected];
    [self.btn_cam setBackgroundImage:[UIImage imageNamed:@"screenshot1111_h"] forState:UIControlStateHighlighted];
    [self.btn_video setBackgroundImage:[UIImage imageNamed:@"video_h"] forState:UIControlStateSelected];
    
    //日历的按钮显示时间
    if (self.isWarning) {
        NSString * timeStr= [NSString stringWithFormat:@"%d",self.pushMsgModel.alarmTime];
        NSLog(@"日历时间：%@",timeStr);
        NSTimeInterval time=[timeStr doubleValue];
        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"yyyy-M-d"];
        
        NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
        [self.centerTimeView.btn_time setTitle:currentDateStr forState:UIControlStateNormal];
    }
    else{
        //今日时间
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-M-d"];
        NSString *currentTime = [formatter stringFromDate:[NSDate date]];
        [self.centerTimeView.btn_time setTitle:currentTime forState:UIControlStateNormal];
    }
    
    //中心录像
    self.isCenter = NO;
    //是否可以截屏
    self.isCanCut = NO;
}


//----------------------------------------method----------------------------------------
#pragma mark ------通知进入后台停止播放
-(void)stopAllVideo:(NSNotification *)noit
{
    [self btnStopClick:self.btn_stop];
}

#pragma mark ------通知进入前台开始重新播放
-(void)startAllVideo:(NSNotification *)noit
{
    //如果是直播就加载实时视频
    if (self.isLive) {
        [self getVideoAddress];
    }
    //如果是报警就重新播放报警视频
    if (self.isWarning) {
        if (self.pushMsgModel) {
            [self getWarningRecordVideo:self.timeStr];
            [self.bottowScrollerView setContentOffset:CGPointMake(iPhoneWidth, 0) animated:YES];
        }
        return;
    }
    //    //如果不是直播就回放
    if (self.isLive == NO) {
        [self getRecordVideo:self.timeStr];
    }
    
}
#pragma mark ------码流连接失效停止播放
-(void)notOnlineStopVideo:(NSNotification *)noit
{
    [self btnStopClick:self.btn_stop];
}

- (void)stop_LoadView
{
    self.loadingHubView.hidden = YES;
}

- (void)stop_PlayMovie{
    _timer =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hidden_loadview) userInfo:nil repeats:YES];
}

- (void)PlayFaild
{
    self.failVideoBtn.hidden = NO;
    self.loadingHubView.hidden = YES;
}

- (void)hidden_loadview
{
    self.loadingHubView.hidden = YES;
    [self stopTimer];
}

- (void)stopTimer
{
    [_timer invalidate];   // 将定时器从运行循环中移除，
    _timer = nil;
}






//TODO
//#pragma mark ------点击按钮背景渐变效果
//- (void)videoViewBackanimation
//{
//    NSLog(@"快速响应");
//
//    if (self.VideoViewBank.alpha == 1) {
//        [self videoViewBackHidden];
//    }else{
//        [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
//            self.VideoViewBank.alpha = 1;
//        } completion:^(BOOL finished) {
//        }];
//        //[self performSelector:@selector(videoViewBackHidden) withObject:nil afterDelay:5];
//        [self.dissTimer setFireDate:[NSDate distantFuture]];
//        self.dissTimer= [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(videoViewBackHidden) userInfo:nil repeats:NO];
//    }
//}
////TODO
//- (void)videoViewBackHidden
//{
//    [UIView animateWithDuration:0 animations:^{
//        self.VideoViewBank.alpha = 0;
//    }];
//}

#pragma mark ------点击按钮背景渐变效果
- (void)videoViewBackanimation
{
    //    NSLog(@"出现了");
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.btn_back.alpha = 1;
//        NSLog(@"出现啦！");
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
        self.btn_back.alpha = 0;
        _isAppear = 1;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
//        NSLog(@"消失啦！");
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

#pragma mark ------添加播放视图
- (void)addPlayVideoView
{
    
    //操作视图添加捏合移动手势
    //添加缩放手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchToVideoManage:)];
    [self.VideoViewBank addGestureRecognizer:pinch];
    
    //捏合手势
    UIPanGestureRecognizer *recognizer = [[ UIPanGestureRecognizer alloc] initWithTarget: self action: @selector (handleSwipeToManage:)];
    [self.VideoViewBank addGestureRecognizer:recognizer];
    
    //黑色背景
    UIView *ImaBank = [[UIView alloc]init];
    ImaBank.backgroundColor = [UIColor blackColor];
    [self.view insertSubview:ImaBank atIndex:0];
    [ImaBank mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.VideoViewBank.mas_left).offset(0);
        make.top.equalTo(self.VideoViewBank.mas_top).offset(0);
        make.right.equalTo(self.VideoViewBank.mas_right).offset(0);
        make.bottom.equalTo(self.VideoViewBank.mas_bottom).offset(0);
    }];
    self.imaBankView =ImaBank;
    //图片加到背景上
    UIImageView *ima = [[UIImageView alloc]init];
    ima.contentMode = UIViewContentModeCenter;
    ima.userInteractionEnabled = YES;
    [self.imaBankView addSubview:ima];
    [ima mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.VideoViewBank.mas_left).offset(0);
        make.top.equalTo(self.VideoViewBank.mas_top).offset(0);
        make.right.equalTo(self.VideoViewBank.mas_right).offset(0);
        make.bottom.equalTo(self.VideoViewBank.mas_bottom).offset(0);
    }];
    self.ima_videoView = ima;
    
    //播放界面
    if (self.isWarning) {
        JWPlayerManage *playerManage = [JWOpenSdk createPlayerManageWithDevidId:self.pushMsgModel.deviceId ChannelNo:1];
        _videoManage = playerManage;
        
    }else{
        JWPlayerManage *playerManage = [JWOpenSdk createPlayerManageWithDevidId:_listModel.ID ChannelNo:1];
        //            self.videoManage = playerManage;
        _videoManage = playerManage;
    }
    
    UIView *playView = [[UIView alloc]init];
    
    [self.view insertSubview:playView atIndex:1];
    [playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.VideoViewBank.mas_left).offset(0);
        make.top.equalTo(self.VideoViewBank.mas_top).offset(0);
        make.right.equalTo(self.VideoViewBank.mas_right).offset(0);
        make.bottom.equalTo(self.VideoViewBank.mas_bottom).offset(0);
    }];
    [self.videoManage JWPlayerManageSetPlayerView:playView];
    self.playView = playView;
    
    [self setLoadingView];
    self.isCanCut = NO;
    
        //TODO
    //添加按钮背景视图单击渐变效果
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(videoViewBackanimation)];
//    [self.playView addGestureRecognizer:tap];


    
}
//视频无法播放时显示的画面
-(UIButton *)failVideoBtn{
    if (!_failVideoBtn) {
        _failVideoBtn = [[UIButton alloc]init];
        [_failVideoBtn setImage:[UIImage imageNamed:@"PlayViedo"] forState:UIControlStateNormal];
        _failVideoBtn.hidden = YES;
    }
    [self.playView addSubview:_failVideoBtn];
    [_failVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.playView);
        make.size.mas_offset(CGSizeMake(30, 30));
    }];

    return _failVideoBtn;
}


- (void)setLoadingView{
    if (iPhone_5_Series) {
        _playView_h = 208;
    }
    _loadingHubView = [[LoadingHubView alloc] initWithFrame:CGRectMake(iPhoneWidth/2-25, _playView_h/2-9, 50, 18)];
    _loadingHubView.hudColor = UIColorFromRGB(0xF1F2F3);
    [self.playView addSubview:_loadingHubView];
    [_loadingHubView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.playView);
        make.centerY.mas_equalTo(self.playView);
        make.size.mas_equalTo(CGSizeMake(50, 18));
    }];
    [_loadingHubView showAnimated:YES];
}

#pragma mark ------获取实时音视频地址
- (void)getVideoAddress
{
    //    [[HDNetworking sharedHDNetworking]canleAllHttp];
    NSLog(@"打印看看设备在不在线：%ld",(long)self.listModel.status);
    
    if(self.listModel.status == 1){
         self.loadingHubView.hidden = NO;
    }else{
//        [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];//待做
        self.loadingHubView.hidden = YES;
    }
    
    self.isLive = YES;
    if (self.isWarning) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@",self.pushMsgModel.deviceName,@"监控"];
    }
    else{
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@",self.listModel.name,@"监控"];
    }
   
    [self btnStopClick:self.btn_stop];
    //是否重新播放标识
    self.againPlay = NO;
    //记住用户是否hd
    if ([[NSUserDefaults standardUserDefaults]objectForKey:ISHD]) {
        NSNumber *hdNubmer = [[NSUserDefaults standardUserDefaults]objectForKey:ISHD];
        self.isHd = [hdNubmer boolValue];
    }
    else{
        self.isHd = NO;
    }
    self.btn_hd.selected = self.isHd;
    
    //正在直播
    if (self.isHd) {
        
        //播放主码流
        [self.videoManage JWPlayerManageBeginPlayVideoWithVideoType:JWVideoTypeStatusHd BIsEncrypt:self.bIsEncrypt Key:self.key BIsAP:NO completionBlock:^(JWErrorCode errorCode) {
            [self.btn_hd setImage:[UIImage imageNamed:@"hd_h"] forState:UIControlStateNormal];
            if (errorCode == JW_SUCCESS) {
                self.btn_start.selected = YES;
                //播放成功可以截图
                self.isCanCut = YES;
                NSLog(@"成功了成功了");
            }if (errorCode == JW_FAILD) {
                [XHToast showTopWithText:@"获取视频失败" topOffset:160];
                self.isCanCut = NO;
                NSLog(@"失败了失败了");
//                 [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];//待做
            }
        }];
    }
    else if(self.isHd == NO){
        
        //播放子码流
        [self.videoManage JWPlayerManageBeginPlayVideoWithVideoType:JWVideoTypeStatusNomal BIsEncrypt:self.bIsEncrypt Key:self.key BIsAP:NO completionBlock:^(JWErrorCode errorCode) {
            [self.btn_hd setImage:[UIImage imageNamed:@"hd_n"] forState:UIControlStateNormal];
            if (errorCode == JW_SUCCESS) {
                self.btn_start.selected = YES;
                //播放成功可以截图
                self.isCanCut = YES;
                NSLog(@"成功了成功了");
            }if (errorCode == JW_FAILD) {
                [XHToast showTopWithText:@"获取视频失败" topOffset:160];
                self.isCanCut = NO;
                NSLog(@"失败了失败了");
//                 [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];//待做
            }
        }];
    }
}

#pragma mark ------请求是否有回放录像
- (void)getRecordVideo:(NSString *)timeStr
{
    //    [[HDNetworking sharedHDNetworking]canleAllHttp];
    self.isLive = NO;
    self.againPlay = NO;
    if (self.isWarning) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@",self.pushMsgModel.deviceName,@"回放"];
    }
    else{
        self.navigationItem.title =  [NSString stringWithFormat:@"%@ %@",self.listModel.name,@"回放"];
    }
    
    //时间戳
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss "];
    //今日零点
    NSString *beginTimeStr =[NSString stringWithFormat:@"%@ %@",timeStr,@"00:00:00"];
    NSDate *date = [formatter dateFromString:beginTimeStr];
    NSLog(@"%@", date);// 这个时间是格林尼治时间
    NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    int beginTimeInt = [dateStr intValue];
     [self.videoTimeModelArr removeAllObjects];
    //今日235959
    NSString *endTimeStr =[NSString stringWithFormat:@"%@ %@",timeStr,@"23:59:59"];
    NSDate *endDate = [formatter dateFromString:endTimeStr];
    NSLog(@"%@", endDate);// 这个时间是格林尼治时间
    NSString *dateEndStr = [NSString stringWithFormat:@"%ld", (long)[endDate timeIntervalSince1970]];
    int endTimeInt = [dateEndStr intValue];
    
    //当前时间戳给进度条
    NSDate* nowDate = [NSDate dateWithTimeIntervalSinceNow:10];
    NSTimeInterval a= [nowDate timeIntervalSince1970];
    NSString*nowTimeStr = [NSString stringWithFormat:@"%0.f", a];
    int nowTimeInt = [nowTimeStr intValue];
    //搜索是否有回放录像 但是不立刻播放
    
    if (self.isCenter == YES) {
        [self.videoManage searchRecordVideoWithDevidId:self.pushMsgModel.deviceId recVideoType:JWRecVideoTypeStatusCenter beginTime:date completionBlock:^(NSArray *recVideoTimeArr, JWErrorCode errorCode) {//原来listModel.ID
            if (errorCode == JW_SUCCESS) {
                //回放时间数组
                if (recVideoTimeArr.count>0) {
                    for (int i = 0; i<recVideoTimeArr.count; i++) {
                        JWDeviceRecordFile *records = recVideoTimeArr[i];
                        ZCVideoTimeModel *model = [[ZCVideoTimeModel alloc]init];
                        //起点距离今日00分钟
                        CGFloat beginMin = (records.start_time-beginTimeInt)/60.00;
                        //终点距离今日00分钟
                        CGFloat endMin = (records.stop_time-beginTimeInt)/60.00;
                        model.name = records.name;
                        model.benginTime = beginMin;
                        model.endTime = endMin;
                        [self.videoTimeModelArr addObject:model];
                    }  //添加进度条
                    [self.centerTimeView addSubview:self.rulerView];
                    self.rulerView.timeArr = [NSArray arrayWithArray:self.videoTimeModelArr];
                    
                    //当前时间指针起始位置
                    NSLog(@"当前时间是什么1：%d",nowTimeInt);
                    self.rulerView.timeMiao = nowTimeInt;
                    self.rulerView.levelCount = 0;
                }
                else{
                    [XHToast showTopWithText:@"当前日期暂无录像" topOffset:160];
                    self.isCanCut = NO;
                    //没有图像时 进度条隐藏
                    [self disRulerViewAndTimeView];
                }
            }
            if (errorCode == JW_FAILD) {
                [XHToast showTopWithText:@"当前日期暂无录像" topOffset:160];
                self.isCanCut = NO;
                //没有图像时 进度条隐藏
                [self disRulerViewAndTimeView];
            }
            
        }];
        
    }else{
        [self.videoManage searchRecordVideoWithDevidId:self.pushMsgModel.deviceId recVideoType:JWRecVideoTypeStatusLeading beginTime:date completionBlock:^(NSArray *recVideoTimeArr, JWErrorCode errorCode) {
            if (errorCode == JW_SUCCESS) {
                //回放时间数组
                if (recVideoTimeArr.count>0) {
                    for (int i = 0; i<recVideoTimeArr.count; i++) {
                        JWDeviceRecordFile *records = recVideoTimeArr[i];
                        ZCVideoTimeModel *model = [[ZCVideoTimeModel alloc]init];
                        //起点距离今日00分钟
                        CGFloat beginMin = (records.start_time-beginTimeInt)/60.00;
                        //终点距离今日00分钟
                        CGFloat endMin = (records.stop_time-beginTimeInt)/60.00;
                        model.name = records.name;
                        model.benginTime = beginMin;
                        model.endTime = endMin;
                        [self.videoTimeModelArr addObject:model];
                        
                    }  //添加进度条
                    [self.centerTimeView addSubview:self.rulerView];
                    self.rulerView.timeArr = [NSArray arrayWithArray:self.videoTimeModelArr];
                    
                    //当前时间指针起始位置
                    self.rulerView.timeMiao = nowTimeInt;
                    NSLog(@"当前时间是什么2：%d",nowTimeInt);
                    self.rulerView.levelCount = 0;
                }
                else{
                    [XHToast showTopWithText:@"当前日期暂无录像" topOffset:160];
                    self.isCanCut = NO;
                    //没有图像时 进度条隐藏
                    [self disRulerViewAndTimeView];
                }
            }
            if (errorCode == JW_FAILD) {
                [XHToast showTopWithText:@"当前日期暂无录像" topOffset:160];
                self.isCanCut = NO;
                //没有图像时 进度条隐藏
                [self disRulerViewAndTimeView];
            }
            
        }];
    }
}

#pragma mark ------警报是否有回放录像
- (void)getWarningRecordVideo:(NSString*)timeStr
{
    //    [[HDNetworking sharedHDNetworking]canleAllHttp];
    //各种回放都不截图
    self.isCanCut = NO;
    
    //小点位置
    [_pageControl setCurrentPage:1];
    if (self.isWarning) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@",self.pushMsgModel.deviceName,@"回放"];
    }
    //先停止播放
    [self btnStopClick:self.btn_stop];
    self.isLive = NO;
    //时间戳
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss "];
    //今日零点
    NSString *beginTimeStr =[NSString stringWithFormat:@"%@ %@",timeStr,@"00:00:00"];//注释：之前传进来的是日期，在这里在拼上时间。现在直接传进来准确的时间
    NSDate *date = [formatter dateFromString:beginTimeStr];
    //将转换回来的对象手动加上8小时，回到北京时间
    NSDate *date2 = [date dateByAddingTimeInterval:8 * 60 * 60];
    NSLog(@"%@", date2);// 这个时间是格林尼治时间，date2是北京时间
    NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[date2 timeIntervalSince1970]];
    int beginTimeInt = [dateStr intValue];
    
    //今日235959
    NSString *endTimeStr =[NSString stringWithFormat:@"%@ %@",timeStr,@"23:59:59"];
    NSDate *endDate = [formatter dateFromString:endTimeStr];
    //将转换回来的对象手动加上8小时，回到北京时间
    NSDate *endDate2 = [endDate dateByAddingTimeInterval:8 * 60 * 60];
    NSLog(@"%@", endDate2);// 这个时间是格林尼治时间 endDate2，北京时间
    NSString *dateEndStr = [NSString stringWithFormat:@"%ld", (long)[endDate2 timeIntervalSince1970]];
    int endTimeInt = [dateEndStr intValue];
    
    //当前时间戳给进度条
    NSDate* nowDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a= [nowDate timeIntervalSince1970];
    NSString*nowTimeStr = [NSString stringWithFormat:@"%0.f", a];
    int nowTimeInt = [nowTimeStr intValue];
    //搜索是否有录像
    [self.videoManage searchRecordVideoWithDevidId:self.pushMsgModel.deviceId recVideoType:JWRecVideoTypeStatusLeading beginTime:date2 completionBlock:^(NSArray *recVideoTimeArr, JWErrorCode errorCode) {
        if (errorCode == JW_SUCCESS) {
            if (recVideoTimeArr.count>0) {
                for (int i = 0; i<recVideoTimeArr.count; i++) {
                    JWDeviceRecordFile *records = recVideoTimeArr[i];
                    ZCVideoTimeModel *model = [[ZCVideoTimeModel alloc]init];
                    //起点距离今日00分钟
                    CGFloat beginMin = (records.start_time-beginTimeInt)/60.00;
                    //终点距离今日00分钟
                    CGFloat endMin = (records.stop_time-beginTimeInt)/60.00;
                    model.name = records.name;
                    model.benginTime = beginMin;
                    model.endTime = endMin;
                    [self.videoTimeModelArr addObject:model];
                    
                }  //添加进度条
                [self.centerTimeView addSubview:self.rulerView];
                self.rulerView.timeArr = [NSArray arrayWithArray:self.videoTimeModelArr];
                
                //当前时间指针起始位置
                self.rulerView.timeMiao = nowTimeInt;
//                 NSLog(@"当前时间是什么3：%d",nowTimeInt);
                self.rulerView.levelCount = 0;
                
                //开始播放
                [self.videoManage JWPlayerManageBeginPlayRecVideoWithVideoType:JWRecVideoTypeStatusLeading startTime:date endTime:endDate BIsEncrypt:_bIsEncrypt Key:_key completionBlock:^(JWErrorCode errorCode) {
                    if (errorCode == JW_SUCCESS) {
                        self.loadingHubView.hidden = YES;
                        [XHToast showTopWithText:@"获取录像成功，准备开始播放" topOffset:160];
                        self.btn_start.selected = YES;
                        self.btn_hd.selected = NO;
                        
                        NSLog(@"回放成功了");
                    }if (errorCode == JW_FAILD) {
                        self.loadingHubView.hidden = YES;
                        [XHToast showTopWithText:@"获取录像失败" topOffset:160];
                        self.isCanCut = NO;
                        NSLog(@"回放失败了");
                    }
                }];
            }
            else{
                [XHToast showTopWithText:@"当前日期暂无录像" topOffset:160];
                self.isCanCut = NO;
                self.loadingHubView.hidden = YES;
                //没有图像时 进度条隐藏
                [self disRulerViewAndTimeView];
            }
        }
        if (errorCode == JW_FAILD) {
            [XHToast showTopWithText:@"当前日期暂无录像~" topOffset:160];
            self.loadingHubView.hidden = YES;
            self.isCanCut = NO;
            //没有图像时 进度条隐藏
            [self disRulerViewAndTimeView];
        }
        
    }];
}



#pragma mark ------相应按钮点击方法
- (IBAction)btnStartClick:(id)sender {
    UIButton *btn =self.btn_start;
    //获取播放状态
    BOOL isPlay = [self.videoManage JWPlayerManageGetPlayState];
    if (!isPlay && self.againPlay == NO && btn.selected == NO) {
        //[XHToast showTopWithText:@"开始" topOffset:160];
        //[self.videoManage JWPlayerManageIsSuspendedPlay:NO];
        if (self.isLive) {
            [self getVideoAddress];
            self.againPlay = NO;
        }
        else{
            [self getRecordVideo:self.timeStr];
            self.againPlay = NO;
        }

        btn.selected = !btn.selected;
        return;
    }
    if (isPlay && self.againPlay == NO && btn.selected == YES)
    {
        //[XHToast showTopWithText:@"暂停" topOffset:160];
        [self.videoManage JWPlayerManageIsSuspendedPlay:YES];
        btn.selected = !btn.selected;
        return;
    }
    
    if (self.againPlay == YES && btn.selected == NO && !isPlay) {
        if (self.isLive) {
            [self getVideoAddress];
            self.againPlay = NO;
        }
        else{
            [self getRecordVideo:self.timeStr];
            self.againPlay = NO;
        }
    }
    
}


- (IBAction)btnStopClick:(id)sender {
    NSLog(@"btnStopClick=========停止了");
    [[HDNetworking sharedHDNetworking]canleAllHttp];
    //重新播放状态
    self.againPlay = YES;
    //如果正在录像就停止录制
    [self judgeIsRecord];
    //停止实时视频
    if (self.isLive) {
        //截取正在播放的视频保存到沙盒
        if (self.isCanCut) {
            [self backCutImage];
        }
        [self.videoManage JWPlayerManageEndPlayVideoWithBIsStop:NO CompletionBlock:^(JWErrorCode errorCode) {
            if (errorCode == JW_SUCCESS) {
                NSLog(@"停止按钮，关闭播放接口成功");
            }else{
                NSLog(@"停止按钮，关闭播放接口失败");
            }
        }];
    }else{
        //停止回放视频
        [self.videoManage JWStreamPlayerManageEndRecPlayVideoWithCompletionBlock:^(JWErrorCode errorCode) {
            
        }];
    }
    self.btn_start.selected = NO;
    //进度条时间View隐藏
    [self disRulerViewAndTimeView];
}

//- (void)vcStopBtnClick
//{
//    NSLog(@"vcStopBtnClick=========停止了");
//    [[HDNetworking sharedHDNetworking]canleAllHttp];
//    //重新播放状态
//    self.againPlay = YES;
//    //如果正在录像就停止录制
//    [self judgeIsRecord];
//    [self.videoManage JWPlayerManageEndPlayVideoWithCompletionBlock:^(JWErrorCode errorCode) {
//        if (errorCode == JW_SUCCESS) {
//        }else{
//        }
//
//    }];
//}

//声音
- (IBAction)btnSoundClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    if (btn.selected) {
       // [XHToast showTopWithText:@"声音:开" topOffset:160];
        [self.videoManage JWPlayerManageSetAudioIsOpen:YES];
        
    }else{
       // [XHToast showTopWithText:@"声音:关" topOffset:160];
        
        [self.videoManage JWPlayerManageSetAudioIsOpen:NO];
    }
}

//子码流主码流
- (IBAction)btnHdClick:(id)sender {
    
    if (self.isLive == NO) {
        [self createAlertController];
        return;
    }
    NSLog(@"btnHdClick=========开始了");
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    self.isHd = btn.selected;
    self.againPlay = NO;
    if (self.isLive) {
    if (self.isHd) {
        //[XHToast showTopWithText:@"高清" topOffset:160];
        [self.btn_hd setImage:[UIImage imageNamed:@"hd_h"] forState:UIControlStateSelected];
    }
    else{
        //[XHToast showTopWithText:@"流畅" topOffset:160];
        [self.btn_hd setImage:[UIImage imageNamed:@"hd_n"] forState:UIControlStateNormal];
    }
    // 保存是否hd
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:self.isHd] forKey:ISHD];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self getVideoAddress];
            }
    //进度条时间View隐藏
    [self disRulerViewAndTimeView];
}

//全屏
- (IBAction)btnFullClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (self.isFull == NO) {
        
        [self.btn_full setImage:[UIImage imageNamed:@"small_n"] forState:UIControlStateNormal];
        [self rightHengpinAction];
        //计算旋转角度
    }
    else{
        [self.btn_full setImage:[UIImage imageNamed:@"full_n"] forState:UIControlStateNormal];
        [self shupinAction];
        //计算旋转角度
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

//截图
- (IBAction)btnCamClick:(id)sender {
    //播放截图音效
    [self playSoundEffect:@"capture.caf"];
    UIImage *ima = [self snapshot:self.playView];
    [XHToast showBottomWithText:@"已保存截图到我的文件"];
    WeakSelf(self);
    dispatch_async(dispatch_queue_create("photoScreenshot", NULL), ^{
        @synchronized (self) {
            //            [weakSelf.assetsLibrary saveImage:ima toAlbum:PATHSCREENSHOT completion:nil failure:nil];
            if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
                NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
                UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                NSString *pathStr = [NSString stringWithFormat:@"/Documents/%@/image",userModel.mobile];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
                [formatter setTimeStyle:NSDateFormatterShortStyle];
                [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                NSDate *date = [NSDate date];
                NSString *DateTimeStr = [formatter stringFromDate:date];
                [weakSelf saveSmallImageWithImage:ima Url:@"" AtDirectory:pathStr ImaNameStr:DateTimeStr];
            }
        }
    });
}

//录像
- (IBAction)btnVideoClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    BOOL isplay = [self.videoManage JWPlayerManageGetPlayState];
    if (isplay == NO &&!self.isRecord) {
        [XHToast showBottomWithText:@"视频未播放"];
        return;
    }
    //播放录音音效
    [self playSoundEffect:@"record.caf"];
    if (!self.isRecord) {
        [XHToast showBottomWithText:@"视频开始录制"];
        btn.selected = YES;
        if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
            NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
            UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
            NSDate *date = [NSDate date];
            NSString *DateTimeStr = [formatter stringFromDate:date];
            NSString *videoNameStr = [NSString stringWithFormat:@"文件格式:mp4    录像时间:%@    关联设备通道:%@",DateTimeStr,self.navigationItem.title];
            [self.videoManage JWPlayerManageStartRecordWithPath:userModel.mobile fileName:videoNameStr];
        }
        self.isRecord = YES;
    }else{
        [XHToast showBottomWithText:@"视频录制成功，已保存到我的文件"];
        btn.selected = NO;
        UIImage *ima = [self snapshot:self.playView];
        [self.videoManage JWPlayerManageStopRecord];
        self.isRecord = NO;
    }
}

//对讲
- (IBAction)btn_voiceClick:(id)sender {
    [self.videoManage JWPlayerManageStartAudioTalkWithCompletionBlock:^(JWErrorCode errorCode) {
        if (errorCode == 0) {
            [self createOvreUI];
        }else{
            [XHToast showBottomWithText:[NSString stringWithFormat:@"开启对讲失败，错误码：%ld",(long)errorCode]];
        }
    }];
}

- (void)createAlertController
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"调节播放速度" message:@"请设置倍率" preferredStyle:UIAlertControllerStyleAlert];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"1/2X" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self.btn_hd setImage:[UIImage imageNamed:@"1-2X_n"] forState:UIControlStateNormal];
        NSLog(@"1/2倍速");
        
        [self postChangePlaySpeed:0.5];
        
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"1/4X" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self.btn_hd setImage:[UIImage imageNamed:@"1-4X_n"] forState:UIControlStateNormal];
        NSLog(@"1/4倍速");
        [self postChangePlaySpeed:0.25];
    }]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"1/8X" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self.btn_hd setImage:[UIImage imageNamed:@"1-8X_n"] forState:UIControlStateNormal];
        NSLog(@"1/8倍速");
        [self postChangePlaySpeed:0.125];
    }]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"1X" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self.btn_hd setImage:[UIImage imageNamed:@"1X_n"] forState:UIControlStateNormal];
        NSLog(@"1倍速");
        [self postChangePlaySpeed:1];
    }]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"2X" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self.btn_hd setImage:[UIImage imageNamed:@"2X_n"] forState:UIControlStateNormal];
        NSLog(@"2倍速");
        [self postChangePlaySpeed:2];
    }]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"4X" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self.btn_hd setImage:[UIImage imageNamed:@"4X_n"] forState:UIControlStateNormal];
        NSLog(@"4倍速");
        [self postChangePlaySpeed:4];
    }]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"8X" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self.btn_hd setImage:[UIImage imageNamed:@"8X_n"] forState:UIControlStateNormal];
        NSLog(@"8倍速");
        [self postChangePlaySpeed:8];
    }]];
    
    
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        
//        NSLog(@"添加一个textField就会调用 这个block");
//        
//    }];
    // 由于它是一个控制器 直接modal出来就好了
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)postChangePlaySpeed:(float)SpeedValue
{
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithFloat:SpeedValue] forKey:@"SpeedValue"];
    NSString * access_token;
    NSString * user_id;
    NSString * monitor_id;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        access_token = userModel.access_token;
        user_id = userModel.user_id;
    }

    NSNumber * cmd          = [NSNumber numberWithInt:0];
    NSString * action       = @"SPEED";
    NSString * param        = [NSString stringWithFormat:@"%.3f",SpeedValue];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"monitor_id"]) {
        monitor_id = [[NSUserDefaults standardUserDefaults]objectForKey:@"monitor_id"];
    }
    NSMutableDictionary * postDic = [NSMutableDictionary dictionary];
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:user_id forKey:@"user_id"];
    [postDic setObject:monitor_id forKey:@"monitor_id"];
    [postDic setObject:cmd forKey:@"cmd"];
    [postDic setObject:action forKey:@"action"];
    [postDic setObject:param forKey:@"param"];
    //先确认保证通道model是否有
    if ([MultiChannelDefaults getChannelModel]) {
        MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
        [postDic setObject:model.chanCode forKey:@"chan_code"];
    }
   // NSLog(@"变速播放参数：access_token:%@ === user_id:%@ == monitor_id:%@ === cmd:%@ == action:%@ == param:%@",access_token,user_id,monitor_id,cmd,action,param);
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/playback_ctrl" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        // NSLog(@"变速播放请求 ret:%d===responseObject:%@",ret,responseObject);
        
        if (ret == 0 ) {
            NSLog(@"变速播放请求成功了。");
            
            //completionBlock(JW_SUCCESS);
        }else{
           // completionBlock(JW_FAILD);
        }
    } failure:^(NSError * _Nonnull error) {

    }];
}

- (void)createOvreUI{
    
    _ovreView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-_playBack_h-64)];
    _ovreView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_ovreView];
    [_ovreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.VideoViewBank.mas_bottom).offset(0);
        make.left.equalTo(self.VideoViewBank.mas_left).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.right.equalTo(self.VideoViewBank.mas_right).offset(0);
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
    label.text = @"对讲中";
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
    [button setTitle:@"挂断" forState:UIControlStateNormal];
    [self.ovreView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.ovreView.mas_left).offset(iPhoneWidth/2-32.5);
        make.top.equalTo(label.mas_bottom).offset(65);
        make.right.equalTo(self.ovreView.mas_left).offset(iPhoneWidth/2+32.5);
    }];
    [button addTarget:self action:@selector(stopTalkWith) forControlEvents:UIControlEventTouchUpInside];
}

- (void)stopTalkWith{
    
    [self.videoManage JWPlayerManageEndAudioTalkWithCompletionBlock:^(JWErrorCode errorCode) {
        NSLog(@"停止对讲");
        [self.ovreView removeFromSuperview];
    }];
}
#pragma mark - - - 播放提示声
void soundCompleteCalllback(SystemSoundID soundID, void *clientData){
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
    
    //    // 如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
    //    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCalllback, NULL);
    
    // 2、播放音频
    AudioServicesPlaySystemSound(soundID); // 播放音效
}
/**
 *  播放完成回调函数
 *
 *  @param soundID    系统声音ID
 *  @param clientData 回调时传递的数据
 */

#pragma mark ------推出时截取图片//TODOING
- (void)backCutImage
{
    UIImage *ima = [self snapshot:self.playView];

    dispatch_async(dispatch_queue_create("backCutImage", NULL), ^{
        @synchronized (CUTLOCK) {
            if (_listModel.ID) {
                [self saveSmallImageWithImage:ima Url:@"" AtDirectory:saveCutImageBaseURLDirectory ImaNameStr:_listModel.ID];
                NSLog(@"【playbackVC】保存截图的id：%@",_listModel.ID);
                NSDictionary * dic = @{@"updataImageID":_listModel.ID,@"selectedIndex":self.selectedIndex};
                NSLog(@"更新cutimage的dic：%@",dic);
                [[NSNotificationCenter defaultCenter]postNotificationName:UpDataCutImageWithID object:nil userInfo:dic];
            }else{
                [self saveSmallImageWithImage:ima Url:@"" AtDirectory:saveCutImageBaseURLDirectory ImaNameStr:_pushMsgModel.deviceId];
                NSLog(@"【playbackVC】保存截图的id：%@",_pushMsgModel.deviceId);
                NSDictionary * dic = @{@"updataImageID":_pushMsgModel.deviceId,@"selectedIndex":self.selectedIndex};
                NSLog(@"更新cutimage的dic：%@",dic);
                [[NSNotificationCenter defaultCenter]postNotificationName:UpDataCutImageWithID object:nil userInfo:dic];
            }
        }
    });
}
//TODOING
- (void)saveSmallImageWithImage:(UIImage*)image Url:(NSString*)imageUrl AtDirectory:(NSString*)directory ImaNameStr:(NSString *)imaNameStr
{
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //1、拼接目录
    NSString *path = [NSHomeDirectory() stringByAppendingString:directory];
    NSString* savePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@.jpg",imaNameStr]];
    [fileManager changeCurrentDirectoryPath:savePath];
    NSLog(@"【playBackVC】截图保存路径savePath::::%@",savePath);
    
    [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    BOOL ret = [fileManager createFileAtPath:savePath contents:UIImagePNGRepresentation(image) attributes:nil];
    
    
    if (ret) {
        NSLog(@"【playBackVC】截图保存路径  推出时截取 图片 =====文件===== 创建成功");
    }else{
        NSLog(@"【playBackVC】截图保存路径推出时截取 图片 =====文件===== 创建失败");
    }
}

#pragma mark ------centerTimeViewDelegate
- (void)CenterTimeViewCenterBtnClick:(BOOL)isCenter TimeStr:(NSString *)timeStr
{
    //    [[HDNetworking sharedHDNetworking]canleAllHttp];
    
    [self disRulerViewAndTimeView];
    self.timeStr = timeStr;
    self.isCenter = isCenter;
    [self getRecordVideo:self.timeStr];
}
- (void)CenterTimeViewLeftBtnClick:(BOOL)isCenter TimeStr:(NSString *)timeStr{
    [self disRulerViewAndTimeView];
    self.timeStr = timeStr;
    self.isCenter = isCenter;
    [self getRecordVideo:self.timeStr];
    
}
-(void)CenterTimeViewRightBtnClick:(BOOL)isCenter TimeStr:(NSString *)timeStr{
    [self disRulerViewAndTimeView];
    self.timeStr = timeStr;
    self.isCenter = isCenter;
    [self getRecordVideo:self.timeStr];
}
#pragma mark ------软解代理
- (void)setUpImage:(UIImage *)newImage
{
    
}
#pragma mark ------硬解代理
//- (void)setUpBuffer:(CVPixelBufferRef)buffer
//{
//    if(buffer && !self.videoManage.isStop)
//    {
//        self.isCanCut = YES;
//        CGSize playViewSize = self.playView.bounds.size;
//        [self.playView.openView displayPixelBuffer:buffer playViewSize:playViewSize];
//
//    }
//}
#pragma mark ------保存录像代理
- (void)stopRecordBlockFunc
{
    //取消保存到相册功能
}

#pragma mark----------bottomview delegate------------
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



#pragma mark ------控制云台代理
/*
//向上
- (void)ControlViewBtnTopClick{
    _control_num = 1;
    [self ControlFunc];
}
//停止向上
- (void)ControlViewBtnTopInside{
    [self controlStop];
}
//向下
- (void)ControlViewBtnDownClick{
    _control_num = 2;
    [self ControlFunc];
    
}
//停止向下
- (void)ControlViewBtnDownInside{
    [self controlStop];
}
//向左
- (void)ControlViewBtnLeftClick{
    _control_num = 3;
    [self ControlFunc];
    
}
//停止向左
- (void)ControlViewBtnLeftInside{
    [self controlStop];
}
//向右
- (void)ControlViewBtnRightClick{
    _control_num = 4;
    [self ControlFunc];
    
}
//停止向右
- (void)ControlViewBtnRightInside{
    [self controlStop];
}
*/
- (void)ControlFunc
{
    NSNumber * cmd_num = [NSNumber numberWithInteger:_control_num];
    NSMutableDictionary * changeDic = [NSMutableDictionary dictionary];
    [changeDic setObject:self.listModel.ID forKey:@"dev_id"];
    [changeDic setObject:@"1" forKey:@"chan_id"];
    [changeDic setObject:cmd_num forKey:@"cmd"];
    [changeDic setObject:@"5" forKey:@"speed"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/ptz/start" parameters:changeDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSLog(@"控制成功");
            
        }
        NSLog(@"%d",ret);
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"失败了");
    }];
}
- (void)controlStop{
    NSMutableDictionary * changeDic = [NSMutableDictionary dictionary];
    [changeDic setObject:self.listModel.ID forKey:@"dev_id"];
    [changeDic setObject:@"1" forKey:@"chan_id"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/ptz/stop" parameters:changeDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSLog(@"控制成功");
            
        }
        NSLog(@"%d",ret);
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"失败了");
    }];
    
}
//- (void)refreshTimeLabel:(NSNotification *)noti
//{
////    if (noti) {
////        NSString * timeStampString = [NSString stringWithFormat:@"%@",[noti.userInfo objectForKey:@"TimeStamp"]];
////        
////        // iOS 生成的时间戳是10位
////        NSTimeInterval interval    = [timeStampString doubleValue] / 1000.0;
////        NSDate *date               = [NSDate dateWithTimeIntervalSince1970:interval];
////        
////        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
////        [formatter setDateFormat:@"HH:mm:ss"];//yyyy-MM-dd
////        NSString *dateString       = [formatter stringFromDate: date];
//////        self.timeViewnew.lab_time.text = dateString;
//////        self.timeMinStr = dateString;
////       // [self.timeViewnew.lab_time setText:dateString];
////        NSLog(@"服务器返回的时间戳对应的时间是:%@",dateString);
////        }
//}
#pragma mark ------进度条代理
- (void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView {

}
//输出时间
- (void)txhTimeStr:(NSString *)timeStr MinValue:(CGFloat)minValue
{
    NSString *str = [NSString stringWithFormat:@"%.2f",minValue];
    NSArray *arr = [str componentsSeparatedByString:@"."];
    NSString *min = arr[0];
    
    int secValue = [min intValue]*60;
    self.secStr = [NSString stringWithFormat:@"%d",secValue];
    
    //小时
    float hour = [min intValue]/60;
    int hourInt;
    hourInt = floor(hour);
    NSString *hourStr = [NSString stringWithFormat:@"%02d",hourInt];
    //分钟
    int minutes =floor(minValue);
    int minutesInt = minutes%60;
    NSString *minutesStr = [NSString stringWithFormat:@"%02d",minutesInt];
    
    //秒
    NSString *strArr = arr[1];
    int mouse = [strArr intValue]*0.6;
    NSString *mouseStr = [NSString stringWithFormat:@"%02d",mouse];
    NSString *strrrrrrr = [NSString stringWithFormat:@"%@:%@:%@",hourStr,minutesStr,mouseStr];
    self.timeViewnew.lab_time.text = strrrrrrr;
    self.timeMinStr = strrrrrrr;
    

}
//刷新播放时间
- (void)reloadTimePlay
{
    [[HDNetworking sharedHDNetworking]canleAllHttp];
    if (self.isWarning) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@",self.pushMsgModel.deviceName,@"回放"];
    }
    else{
        self.navigationItem.title =  [NSString stringWithFormat:@"%@ %@",self.listModel.name,@"回放"];
    }
    //如果正在录像就停止录制
   // [self judgeIsRecord];
    //切换为不是实时视频
    //self.isLive = NO;
    //停止回放视频
    //[self.videoManage JWPlayerManageEndRecPlayVideoWithCompletionBlock:^(JWErrorCode errorCode) {
      //  if (errorCode == JW_SUCCESS) {
            //时间戳
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
            //调整时间
            NSString *beginTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,self.timeMinStr];
            NSDate *date = [formatter dateFromString:beginTimeStr];
            //今日235959
            NSString *endTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,@"23:59:59"];
            NSDate *endDate = [formatter dateFromString:endTimeStr];
            
            //先停止播放
           [self.videoManage JWPlayerManageEndPlayVideoWithBIsStop:NO CompletionBlock:^(JWErrorCode errorCode) {
                if (errorCode == JW_SUCCESS) {
                }else{
                }
            }];
            //是中心录像
            if (self.isCenter == YES) {
                [self.videoManage JWPlayerManageBeginPlayRecVideoWithVideoType:JWRecVideoTypeStatusCenter startTime:date endTime:endDate BIsEncrypt:_bIsEncrypt Key:_key completionBlock:^(JWErrorCode errorCode) {
                    if (errorCode == JW_SUCCESS) {
                        self.loadingHubView.hidden = NO;
                        [XHToast showTopWithText:@"获取录像成功，准备开始播放" topOffset:160];
                        self.btn_start.selected = YES;
                        self.btn_hd.selected = NO;
                        [self.btn_hd setImage:[UIImage imageNamed:@"1X_n"] forState:UIControlStateNormal];
                        NSLog(@"回放成功了");
                    }if (errorCode == JW_FAILD) {
                        [XHToast showTopWithText:@"获取录像失败" topOffset:160];
                        self.isCanCut = NO;
                        NSLog(@"回放失败了");
                    }
                }];
            }
            //是前端录像
            if (self.isCenter == NO) {
                [self.videoManage JWPlayerManageBeginPlayRecVideoWithVideoType:JWRecVideoTypeStatusLeading startTime:date endTime:endDate BIsEncrypt:_bIsEncrypt Key:_key completionBlock:^(JWErrorCode errorCode) {
                    if (errorCode == JW_SUCCESS) {
                        self.loadingHubView.hidden = NO;
                        [XHToast showTopWithText:@"获取录像成功，准备开始播放" topOffset:160];
                        self.btn_start.selected = YES;
                        self.btn_hd.selected = NO;
                        NSLog(@"回放成功了");
                    }if (errorCode == JW_FAILD) {
                        [XHToast showTopWithText:@"获取录像失败" topOffset:160];
                        self.isCanCut = NO;
                        NSLog(@"回放失败了");
                    }
                }];
            }
     //   }
//        if (errorCode == JW_FAILD) {
//            [XHToast showTopWithText:@"获取录像失败" topOffset:160];
//            self.isCanCut = NO;
//            NSLog(@"回放失败了");
//        }
   // }];
}
#pragma mark - 单独的暂停播放
- (void)endPlaying
{
    //如果正在录像就停止录制
    [self judgeIsRecord];
    //切换为不是实时视频
    self.isLive = NO;
    //停止回放视频
    [self.videoManage JWStreamPlayerManageEndRecPlayVideoWithCompletionBlock:^(JWErrorCode errorCode) {
        if (errorCode == JW_SUCCESS) {
           NSLog(@"滑动先停止视频播放成功");
        }
        if (errorCode == JW_FAILD) {
           NSLog(@"滑动先停止视频播放失败");
        }
    }];
}

#pragma mark ------进度条和时间View消失
- (void)disRulerViewAndTimeView
{
    //没有图像时 进度条隐藏
    [self.rulerView removeFromSuperview];
    self.rulerView = nil;
    [self.timeViewnew removeFromSuperview];
    self.timeViewnew = nil;
}
#pragma mark ------ScrollerViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //     [[HDNetworking sharedHDNetworking]canleAllHttp];
    //更新UIPageControl的当前页
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.frame;
    [_pageControl setCurrentPage:offset.x / bounds.size.width];
    if (offset.x == 0 &&  !self.isLive) {
        //        self.videoManage.isStop = NO;
        [self getVideoAddress];
    }
    else if (offset.x == iPhoneWidth && self.isLive) {
        [self getRecordVideo:self.timeStr];
    }
}
//#pragma mark ------pageControl点击方法
//- (void)pageTurn:(UIPageControl*)sender
//{
//    //令UIScrollView做出相应的滑动显示
//    CGPoint scrollerPoint =  CGPointMake(sender.currentPage *iPhoneWidth, 0);
//    [self.bottowScrollerView setContentOffset:scrollerPoint animated:YES];
//}

#pragma mark ------判断当前是否录制
- (void)judgeIsRecord
{
    if (self.isRecord) {
        [self btnVideoClick:self.btn_video];
    }
}


#pragma mark-------手势操作
//捏合手势
- (void)pinchToVideoManage:(UIPinchGestureRecognizer *)recognizer
{
    if (self.videoManage) {
        [self.videoManage pinch:recognizer];
    }
    
    
}
//移动手势
- ( void )handleSwipeToManage:( UIPanGestureRecognizer *)gesture
{
    if (self.videoManage) {
        [self.videoManage handleSwipe:gesture];
    }
    
}


#pragma mark ------判断屏幕状态
-(void)panduanDevece:(NSNotification *)noit
{
    //    UIDevice *currentDevice = [UIDevice currentDevice];
    //    switch (currentDevice.orientation) {
    //        case UIDeviceOrientationUnknown:
    //            // 正常手持状态
    //            if (self.isFull == NO) {
    //                [self shupinAction];
    //            }
    //            if (self.isFull) {
    //                [self rightHengpinAction];
    //            }
    //            break;
    //        case UIDeviceOrientationPortrait :
    //            // 正常手持状态
    //            if (self.isFull == NO) {
    //                [self shupinAction];
    //            }
    //            if (self.isFull) {
    //                [self rightHengpinAction];
    //            }
    //            break;
    //        case UIDeviceOrientationPortraitUpsideDown:
    //            // 倒着
    ////            [self shupinAction];
    //            break;
    //        case UIDeviceOrientationLandscapeLeft:
    //            if (self.isFull) {
    //                [self rightHengpinAction];
    //            }
    //            break;
    //        case UIDeviceOrientationLandscapeRight:
    //            if (self.isFull) {
    //                [self rightHengpinAction];
    //            }
    //            break;
    //        case UIDeviceOrientationFaceUp:
    ////            [self shupinAction];
    //
    //            break;
    //        case UIDeviceOrientationFaceDown:
    ////            [self shupinAction];
    //
    //            break;
    //        default:
    //            break;
    //    }
}

#pragma mark -横竖屏坐标事件
-(void)shupinAction
{
    CGFloat bili = (CGFloat)(375.0000/244.000);
    
    CGFloat viewWidth;
    if (self.isFull == YES) {
        viewWidth  = (CGFloat)self.view.height;
    }else{
        viewWidth  = (CGFloat)self.view.width;
    }
    CGFloat h  = (CGFloat)viewWidth/bili;
    self.isFull = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [UIView animateWithDuration:0.25 animations:^{
        [self.VideoViewBank mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(64);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.height.equalTo(@(h));
        }];
        [self.btn_cam mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.VideoViewBank.mas_bottom).offset(30);
        }];
        [self.imaBankView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.VideoViewBank.mas_left).offset(0);
            make.top.equalTo(self.VideoViewBank.mas_top).offset(0);
            make.right.equalTo(self.VideoViewBank.mas_right).offset(0);
            make.bottom.equalTo(self.VideoViewBank.mas_bottom).offset(0);
        }];
        
        [self.ima_videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.VideoViewBank.mas_left).offset(0);
            make.top.equalTo(self.VideoViewBank.mas_top).offset(0);
            make.right.equalTo(self.VideoViewBank.mas_right).offset(0);
            make.bottom.equalTo(self.VideoViewBank.mas_bottom).offset(0);
        }];
        [self.playView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.VideoViewBank.mas_left).offset(0);
            make.top.equalTo(self.VideoViewBank.mas_top).offset(0);
            make.right.equalTo(self.VideoViewBank.mas_right).offset(0);
            make.bottom.equalTo(self.VideoViewBank.mas_bottom).offset(0);
        }];
        
        //        CGFloat layoutFloat = 375/244;
        //        [self.VideoViewBackLayout setConstant:layoutFloat];
        
        [self.bottowScrollerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lab_jieTu.mas_top).offset(35);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
        }];
        
        if (self.isLive) {
            [self.bottowScrollerView setContentOffset:CGPointMake(0, 0)];
        }else{
            [self.bottowScrollerView setContentOffset:CGPointMake(iPhoneWidth, 0)];
        }
        
        self.pageControl.hidden = NO;
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        float arch = 0;
        //对navigationController.view 进行强制旋转
        self.navigationController.view.transform = CGAffineTransformMakeRotation(arch);
        self.navigationController.view.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
}
-(void)rightHengpinAction
{
    self.isFull = YES;
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [UIView animateWithDuration:0.25 animations:^{
        [self.VideoViewBank mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(0);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
        }];
        [self.imaBankView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.VideoViewBank.mas_left).offset(0);
            make.top.equalTo(self.VideoViewBank.mas_top).offset(0);
            make.right.equalTo(self.VideoViewBank.mas_right).offset(0);
            make.bottom.equalTo(self.VideoViewBank.mas_bottom).offset(0);
        }];
        [self.ima_videoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.VideoViewBank.mas_left).offset(0);
            make.top.equalTo(self.VideoViewBank.mas_top).offset(0);
            make.right.equalTo(self.VideoViewBank.mas_right).offset(0);
            make.bottom.equalTo(self.VideoViewBank.mas_bottom).offset(0);
        }];
        [self.playView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.VideoViewBank.mas_left).offset(0);
            make.top.equalTo(self.VideoViewBank.mas_top).offset(0);
            make.right.equalTo(self.VideoViewBank.mas_right).offset(0);
            make.bottom.equalTo(self.VideoViewBank.mas_bottom).offset(0);
        }];
        
        [self.bottowScrollerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lab_jieTu.mas_top).offset(35);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
        }];
        if (self.isLive) {
            [self.bottowScrollerView setContentOffset:CGPointMake(0, 0)];
        }else{
            [self.bottowScrollerView setContentOffset:CGPointMake(iPhoneWidth, 0)];
        }
        self.pageControl.hidden = YES;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        float arch = M_PI_2;
        //对navigationController.view 进行强制旋转
        self.navigationController.view.transform = CGAffineTransformMakeRotation(arch);
        self.navigationController.view.bounds = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
    }];
}


#pragma mark - 得到截图

- (UIImage *)snapshot:(UIView *)view

{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    return image;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.pageControl.frame = CGRectMake(0, iPhoneHeight-30, iPhoneWidth, 30);
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

//- (BOOL)shouldAutorotate
//{
//    // 正常手持状态
//    if (self.isFull == NO) {
//        return NO;
//    }
//    else {
//        return YES;
//    }
//}
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    // 正常手持状态
//    if (self.isFull == NO) {
//        return UIInterfaceOrientationMaskPortrait;
//    }
//    else {
//        return UIInterfaceOrientationMaskLandscapeRight;
//    }
//}

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

@end
