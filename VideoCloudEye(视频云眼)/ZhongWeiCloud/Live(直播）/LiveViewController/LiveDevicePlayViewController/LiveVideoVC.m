//
//  LiveVideoVC.m
//  ZhongWeiEyes
//
//  Created by 张策 on 16/12/7.
//  Copyright © 2016年 张策. All rights reserved.
//

#import "LiveVideoVC.h"
#import "ZCTabBarController.h"
#import "WeiCloudListModel.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "LoadingHubView.h"
#import "JWOpenSdk.h"
#import "JWPlayerManage.h"
#import "JWDeviceRecordFile.h"
#import "ZCVideoManager.h"
/*直播介绍View*/
#import "LiveDescView.h"
/*返回按钮视图*/
#import "BackBtnView.h"
/*标题名字显示*/
#import "DeviceTitleView.h"
@interface LiveVideoVC ()
<
    BackBtnViewDelegate//返回按钮代理协议
>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *VideoViewBackLayout;
@property (weak, nonatomic)UIImageView *ima_videoView;
@property (nonatomic,weak)UIView *playView;
@property (nonatomic,weak)UIView *imaBankView;
@property (weak, nonatomic) IBOutlet UIView *VideoViewBank;

@property (nonatomic,strong)ZCVideoManager * videoManager;

@property (weak, nonatomic) IBOutlet UIView *btn_back;

@property (weak, nonatomic) IBOutlet UIButton *btn_full;//全屏

@property (weak, nonatomic) IBOutlet UIButton *btn_sound;//声音
@property (strong, nonatomic) IBOutlet UIButton *btn_exit;//退出按钮

//视频无法播放时显示的画面
@property (strong, nonatomic)UIButton *failVideoBtn;
//加载动画
@property (nonatomic,strong)LoadingHubView *loadingHubView;
//视频管理者
@property (nonatomic,strong)JWPlayerManage *videoManage;
//图片截图 保存录像
@property (nonatomic, strong)ALAssetsLibrary *assetsLibrary;
//是否中心录像
//@property (nonatomic,assign)BOOL isCenter;

//播放速度
@property (nonatomic,assign)int speedInt;
//是否播放
@property (nonatomic,assign)BOOL againPlay;
//是否全屏
@property (nonatomic,assign)BOOL isFull;
//是否为直播
@property (nonatomic,assign)BOOL isLive;
//是否hd
@property (nonatomic,assign)BOOL isHd;
//是否正在录像
@property (nonatomic,assign)BOOL isRecord;


//操作异步串行队列
@property (nonatomic,strong)dispatch_queue_t myActionQueue;

@property (nonatomic,assign) int control_num;
@property (nonatomic,assign) CGFloat heigh_v;
@property (nonatomic,assign) int playBack_h;
@property (nonatomic,assign) int playView_h;
//@property (nonatomic,strong)NSTimer *timer;
//@property (nonatomic,strong)NSTimer * dissTimer;//消失定时器。

@property  BOOL isAppear;

/*直播介绍View*/
@property (nonatomic,strong) LiveDescView *liveDescView;
/*返回按钮视图*/
@property (nonatomic,strong) BackBtnView *BackBtnView1;
/*标题名字显示*/
@property (nonatomic,strong) DeviceTitleView *DeviceTitleView1;
@end

@implementation LiveVideoVC
{
    //全局旋转变量
    UIDeviceOrientation _orientation;
}
//----------------------------------------system----------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"description:%@",self.liveDesc);
    [self setUpChildView];
    //进入后台停止播放
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopAllVideo:) name:BEBACKGROUNDSTOP object:nil];
    //进入前台开始播放
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startAllVideo:) name:BEBEFORSTART object:nil];
    //已经开始解析I帧
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stop_PlayMovie) name:HIDELOADVIEW object:nil];
    //播放失败
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updatePlayImage) name:PLAYFAIL object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    //设置屏幕关闭常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    //关闭直播
    [self.videoManage JWPlayerManageEndPlayLiveVideoCompletionBlock:^(JWErrorCode errorCode) {
        if (errorCode == JW_SUCCESS) {
            NSLog(@"关闭直播成功");
        }else{
            NSLog(@"关闭直播失败");
        }
    }];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
//返回上一页
- (void)returnVC
{
    NSLog(@"关闭由h5界面到的直播界面");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)setUpChildView
{
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
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
    
    //按钮背景消失
    [self performSelector:@selector(videoViewBackHidden) withObject:nil afterDelay:5];

    _isAppear = 0;
    //添加按钮背景视图单击渐变效果
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectZhuangtai)];
    [self.VideoViewBank addGestureRecognizer:tap];
//    NSLog(@"打印下地址:%p",self.playView);
    
    //直播描述的View
    [self.view addSubview:self.liveDescView];
    self.liveDescView.liveName_lb.text = self.titleName;
    self.liveDescView.liveViewCount_lb.text = self.viewCount;
    self.liveDescView.liveDesc_tv.text = self.liveDesc;
    [self.liveDescView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.VideoViewBank.mas_bottom).offset(0);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(iPhoneWidth);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
    }];
    [SXLReachability SXL_hasNetwork:^(ReachabilityStatus netStatus) {
        if (netStatus == ReachabilityStatusReachableViaWWAN) {
           // [self netWorkAlert];
            [Toast showInfo:netWorkReminder];
            [self setLoadingView];
            //正常状态播放实时视频
            [self getVideoAddress];
        }
        else
        {
            [self setLoadingView];
            //正常状态播放实时视频
            [self getVideoAddress];
        }
    }];
   
}
#pragma 使用流量播放提醒
- (void)netWorkAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提醒", nil) message:NSLocalizedString(@"您确定使用移动流量观看视频？", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //关闭直播
        [self.videoManage JWPlayerManageEndPlayLiveVideoCompletionBlock:^(JWErrorCode errorCode) {
            if (errorCode == JW_SUCCESS) {
                NSLog(@"关闭直播成功");
            }else{
            }
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
          [self getVideoAddress];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark ------按钮状态初始化
- (void)setUpBtn
{
    [self.btn_sound setImage:[UIImage imageNamed:@"liveVoice"] forState:UIControlStateSelected];
    [self.btn_full setImage:[UIImage imageNamed:@"liveFull"] forState:UIControlStateHighlighted];
}


//----------------------------------------method----------------------------------------
#pragma mark ------通知进入后台停止播放
-(void)stopAllVideo:(NSNotification *)noit
{
//    [self btnStopClick:self.btn_stop];
}

#pragma mark ------通知进入前台开始重新播放
-(void)startAllVideo:(NSNotification *)noit
{
    if ([[unitl currentTopViewController]isKindOfClass:[LiveVideoVC class]]) {
        //如果是直播就加载实时视频
        if (self.isLive) {
            [self getVideoAddress];
        }
    }else{
        NSLog(@"进入前台，当前不是LiveVideoVC，不播放~");
    }
}

#pragma mark ------点击按钮背景渐变效果
- (void)videoViewBackanimation
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.btn_back.alpha = 1;
        self.BackBtnView1.alpha = 1;
        self.DeviceTitleView1.alpha = 1;
        self.btn_exit.alpha = 1;
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
        self.BackBtnView1.alpha = 0;
        self.DeviceTitleView1.alpha = 0;
        self.btn_exit.alpha = 0;
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

#pragma mark - 关闭加载视频动画
- (void)stop_PlayMovie{
    dispatch_async(dispatch_get_main_queue(),^{
        [self cannelLodingView];
    });
}
- (void)updatePlayImage
{
#warning todo
    //重新播放按钮显现
    
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
    
    JWPlayerManage *playerManage = [JWOpenSdk createPlayerManageWithDevidId:_listModel.ID ChannelNo:1];
    _videoManage = playerManage;
    
    UIView *playView = [[UIView alloc]init];
    playView.backgroundColor = [UIColor blackColor];
    [self.view insertSubview:playView atIndex:1];
    [playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.VideoViewBank.mas_left).offset(0);
        make.top.equalTo(self.VideoViewBank.mas_top).offset(0);
        make.right.equalTo(self.VideoViewBank.mas_right).offset(0);
        make.bottom.equalTo(self.VideoViewBank.mas_bottom).offset(0);
    }];
    [self.videoManage JWPlayerManageSetPlayerView:playView];
    self.playView = playView;
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

#pragma mark - 视频加载动画 【消失】和【出现】 方法
//视频加载动画
- (void)setLoadingView
{
    [self.loadingHubView showAnimated:YES];
}
//隐藏视频动画
- (void)cannelLodingView
{
    [self.loadingHubView showAnimated:NO];
}

#pragma mark ------获取实时音视频地址
- (void)getVideoAddress
{
    //    [[HDNetworking sharedHDNetworking]canleAllHttp];
    
    self.isLive = YES;
    if (self.titleName) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@%@",self.titleName,NSLocalizedString(@"直播", nil)];
    }else{
        self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"直播", nil)];
    }

//    [self btnStopClick:self.btn_stop];
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
    
    NSString * url = [self.play_info objectForKey:@"rtmp_uri"];
    
    [self.videoManage JWPlayerManageBeginPlayLiveVideoWithUrl:url completionBlock:^(JWErrorCode errorCode) {
        if (errorCode == JW_SUCCESS) {
            NSLog(@"【直播】播放成功");
        }else{
            NSLog(@"【直播】播放失败");
        }
    }];
}

//声音
- (IBAction)btnSoundClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self.videoManage JWPlayerManageSetAudioIsOpen:YES];
    }else{
        [self.videoManage JWPlayerManageSetAudioIsOpen:NO];
    }
}

//全屏
- (IBAction)btnFullClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (self.isFull == NO) {
       
        [self.btn_full setImage:[UIImage imageNamed:@"livesmallFull"] forState:UIControlStateNormal];
        [self rightHengpinAction];
        //计算旋转角度
    }
    else{
        
        [self.btn_full setImage:[UIImage imageNamed:@"liveFull"] forState:UIControlStateNormal];
        [self shupinAction];
        //计算旋转角度
        //移除全屏时屏幕上的控件
        [self removeFullScreenControls];
    }
    [self setNeedsStatusBarAppearanceUpdate];

}

- (IBAction)returnBackClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - - - 播放提示声
/*
void soundCompleteCalllback(SystemSoundID soundID, void *clientData){
    NSLog(@"播放完成...");
}
 */
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
    /*
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCalllback, NULL);
    */
    // 2、播放音频
    AudioServicesPlaySystemSound(soundID); // 播放音效
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

#pragma mark -横竖屏坐标事件
-(void)shupinAction
{
    self.btn_exit.hidden = NO;
    CGFloat bili = (CGFloat)(375.0000/244.000);
    CGFloat viewWidth;
    if (self.isFull == YES) {
        viewWidth  = (CGFloat)self.view.height;
    }else{
        viewWidth  = (CGFloat)self.view.width;
    }
    CGFloat h  = (CGFloat)viewWidth/bili;
    self.isFull = NO;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [UIView animateWithDuration:0.25 animations:^{
        [self.VideoViewBank mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(64);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.height.equalTo(@(h));
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
        
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        float arch = 0;
        //对navigationController.view 进行强制旋转
        self.navigationController.view.transform = CGAffineTransformMakeRotation(arch);
        self.navigationController.view.bounds = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight);
    }];
}
-(void)rightHengpinAction
{
    self.isFull = YES;
    self.btn_exit.hidden = YES;
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
        
        [self createFullScreenBackControls];

        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        float arch = M_PI_2;
        //对navigationController.view 进行强制旋转
        self.navigationController.view.transform = CGAffineTransformMakeRotation(arch);
        self.navigationController.view.bounds = CGRectMake(0, 0, iPhoneHeight, iPhoneWidth);
    }];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
    else{
        return NO;// 返回NO表示要显示，返回YES将hiden
    }
}


#pragma mark getter && setter
//----------------------------------------init----------------------------------------
//图片保存者
- (ALAssetsLibrary *)assetsLibrary
{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc]init];
    }
    return _assetsLibrary;
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

- (NSMutableDictionary *)play_info
{
    if (!_play_info) {
        _play_info = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _play_info;
}
//直播介绍view的懒加载
- (LiveDescView *)liveDescView{
    if (!_liveDescView) {
        _liveDescView = [[LiveDescView alloc]init];
//        _liveDescView.backgroundColor = [UIColor cyanColor];
    }
    return _liveDescView;
}
//返回按钮的懒加载
-(BackBtnView *)BackBtnView1{
    if (!_BackBtnView1) {
        _BackBtnView1 = [[BackBtnView alloc]init];
        _BackBtnView1.backgroundColor = [UIColor redColor];
        _BackBtnView1.delegate = self;
    }
    return _BackBtnView1;
}
//标题名字显示
- (DeviceTitleView *)DeviceTitleView1{
    if (!_DeviceTitleView1) {
        _DeviceTitleView1 = [[DeviceTitleView alloc]init];
    }
    return _DeviceTitleView1;
}
#pragma mark ----- 创建全屏时的返回控件
- (void)createFullScreenBackControls{
    //返回按钮
    [self.view addSubview:self.BackBtnView1];
    [self.BackBtnView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    //标题
    self.DeviceTitleView1.deviceTitleName_lb.text = [NSString stringWithFormat:@"%@%@",self.titleName,NSLocalizedString(@"直播", nil)];
    [self.view addSubview:self.DeviceTitleView1];
    [self.DeviceTitleView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(200, 15));
    }];
}
#pragma mark ----- 退出全屏时移除返回控件
- (void)removeFullScreenControls{
    [self.BackBtnView1 removeFromSuperview];
    [self.DeviceTitleView1 removeFromSuperview];
}

#pragma mark ----- 返回按钮的代理方法
- (void)backBtnClick{
    [self removeFullScreenControls];
    [self.btn_full setImage:[UIImage imageNamed:@"liveFull"] forState:UIControlStateNormal];
     [self shupinAction];
}

//网络加载动画
- (LoadingHubView *)loadingHubView
{
    if (iPhone_5_Series) {
        _playView_h = 208;
    }
    if (_loadingHubView == nil) {
        _loadingHubView = [[LoadingHubView alloc] initWithFrame:CGRectMake(iPhoneWidth/2-20, _playView_h/2-9, 40, 10)];
        _loadingHubView.hudColor = UIColorFromRGB(0xF1F2F3);
        [self.playView addSubview:_loadingHubView];
        [_loadingHubView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.playView);
            make.centerY.mas_equalTo(self.playView);
            make.size.mas_equalTo(CGSizeMake(40, 10));
        }];
    }
    return _loadingHubView;
}

@end
