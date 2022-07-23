//
//  OnlyPlayBackVC.m
//  ZhongWeiEyes
//
//  Created by 张策 on 16/12/7.
//  Copyright © 2016年 张策. All rights reserved.
//

#define PAGESIZE 50 //每一页的报警条目的个数
#define POSSTEP 10 //录像回放前进或者后退秒数

#import "OnlyPlayBackVC.h"
#import "ZCTabBarController.h"
#import "MoreChooseView.h"
#import "SZCalendarPicker.h"
#import "XHToast.h"
#import "VideoModel.h"
#import "TXHRrettyRuler.h"
#import "TimeView.h"
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
//警告框
#import "customAlertView.h"
#import "animationView.h"

#import "FileVideoController.h"
#import "FileImageController.h"
#import "SegmentViewController.h"
#import "FileVC.h"
#import "FileModel.h"
#import "wifiInfoManager.h"
#import "APModel.h"
/*返回按钮视图*/
#import "BackBtnView.h"
//新写时间轴
#import "GLFRulerControl.h"
#import "NSDate+calculate.h"
#import "AlarmNewCell.h"
//倍速调节控件
#import "RatioSlider.h"
/*放大图片*/
#import "EnlargeimageView.h"
//无时间轴的model
#import "NoTimeShaftRulerModel.h"
//无时间轴的View
#import "NoTimeShaftRulerView.h"
//通道View
#import "MultiChannelView.h"

@interface OnlyPlayBackVC ()
<
    CenterTimeViewDelegate,
    UIScrollViewDelegate,
    ZMRockerDelegate,
    customAlertViewDelegate,//警告框点击代理协议
    UIGestureRecognizerDelegate,
    GLFRulerControlDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    AlarmCell_tDelegete,
    ZCVideoManageDelegate,
    NoTimeShaftRulerViewDelegate,
    MultiChannelViewDelegate
>
{
    BOOL isQueryVideo;//是否正在查询录像
    int nowRecordSlidingTime;
    BOOL isStop;//判断是否按了停止按钮
    NSMutableArray * _arrayM;/*本地数据*/
    NSInteger pageNum;/*页数*/
    BOOL isTimeRulerShow;//判断当前的时间轴是否查询到，查询到代表有录像可以播放，下面列表可以点击播放，如果不能，则点击不查询，直接提示播放失败、
    NSMutableArray *tempArr;//临时数组
    NSString *tempTimeStr;//临时时间字符串
    float radio; // 总秒数 / 总长度
    BOOL isDefaultMode;//是否是默认模式
}
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
@property (nonatomic,strong)NSTimer *timer;
//视频无法播放时显示的画面
@property (strong, nonatomic)UIButton *failVideoBtn;
//加载动画
@property (nonatomic,strong)LoadingHubView *loadingHubView;
//新写云台控制view
@property (nonatomic,strong)ZMRocker * rocker;
//放时间轴和时间选择器的view
@property (nonatomic,strong)CenterTimeView *centerTimeView;
//当前暂无录像图片
@property (nonatomic,strong)UIImageView *noImageView;
//视频管理者
@property (nonatomic,strong)JWPlayerManage *videoManage;
//是否中心录像
@property (nonatomic,assign)BOOL isCenter;
//是否重新播放
@property (nonatomic,assign)BOOL againPlay;
//是否可以截屏
@property (nonatomic,assign)BOOL isCanCut;
//是否全屏
@property (nonatomic,assign)BOOL isFull;
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
@property (nonatomic,assign) CGFloat heigh_v;
@property (nonatomic,assign) int playBack_h;
@property (nonatomic,assign) int playView_h;
@property (nonatomic,strong)NSTimer * dissTimer;//消失定时器。
@property  BOOL isAppear;
@property  BOOL isCancel;
@property (nonatomic,strong)NSTimer * shortCutShowTimer;
@property (nonatomic,strong) UIView * bgView;
@property (nonatomic,strong) UIImageView * cutImage;
@property (nonatomic, strong) UIView* videoBgView;/** 标识视频快捷的背景 */
@property (nonatomic, strong) UIImageView* videoLogo;/** video图片 */
@property (nonatomic,copy)NSString * suspendTime;//记录暂停时候的时间
@property (nonatomic, assign) NSInteger seartVideoResultCount ;/**< ap模式下，搜索的video个数 */
@property (nonatomic, assign) BOOL firstRememder;/**< 只提醒一次的网络流量播放提示标记 */
@property (nonatomic, strong) GLFRulerControl* timeRuler;/**< 新写：时间轴 */
@property (nonatomic, strong) NoTimeShaftRulerView *noTimeShaftRuler;/**< 新写：无时间轴尺子 */

@property (weak, nonatomic) IBOutlet UIButton *onlyPlayBackBtn;//在视频播放界面上的回退按钮
@property (nonatomic,strong) UITableView * tableView;/*表视图*/
@property (nonatomic,strong) RatioSlider *slider;/*自定义滑块*/
@property (nonatomic, copy) NSString* currentDateTimeStr;/**< 用于日期选择器之后，记录当前选择的日期，初始化时候为当天日期。用于请求报警数据 */
@property (nonatomic,strong) UIView *redDotView;//红点闪烁
@property (nonatomic,strong) EnlargeimageView *enlarge;//放大图片View
@property (nonatomic, copy) NSString* refreshTimeStemp;/**< 当前视频播放时间戳 */


/**
 * 尺子上的数据段model的数组
 */
@property (nonatomic, strong) NSMutableArray *rulerModelArr;

/*通道列表选择*/
@property (nonatomic,strong)MultiChannelView *multiTabView;
/*列表消失的背景按钮*/
@property (nonatomic,strong)UIButton *disBtn;

@end

@implementation OnlyPlayBackVC
{
    UIDeviceOrientation _orientation;//全局旋转变量
}

#pragma mark ================================ Action ================================
- (IBAction)onlyPlayBackBtnClick:(id)sender {
    if (self.isFull == YES) {
        [self.btn_full setImage:[UIImage imageNamed:@"全屏_h"] forState:UIControlStateNormal];
        [self shupinAction];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark ================================ 生命周期 ================================

- (void)viewDidLoad {
    [super viewDidLoad];
    isDefaultMode = isNodeTreeMode;
    [self setDefaultParameters_DidLoad];
    [self setUpChildView];
    [self addObserver];
    [self createTableView];
    [self reloadTimePlay];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setDefaultParameters_WillAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self setDefaultParameters_WillDisappear];
    
    [[HDNetworking sharedHDNetworking]canleAllHttp];
    [self btnStopClick:self.btn_stop];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)setDefaultParameters_DidLoad
{
    //如果是多通道则用多通道的名称，否则就是用设备的名称
    if (self.channelModel) {
        self.navigationItem.title = self.channelModel.chanName;
    }else{
        self.navigationItem.title = self.listModel.name;
    }
    
    _arrayM = [[NSMutableArray alloc]init];

    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    self.currentDateTimeStr = [dateFormatter stringFromDate:currentDate];
    
    //设置按钮
    if (self.channelModel) {
        UIButton *setBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        [setBtn setImage:[UIImage imageNamed:@"plusBtn"] forState:UIControlStateNormal];
        [setBtn setImage:[UIImage imageNamed:@"plusBtn"] forState:UIControlStateHighlighted];
        [setBtn addTarget:self action:@selector(showTableView) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* setRightItem = [[UIBarButtonItem alloc]initWithCustomView:setBtn];
        
        //设置2个按钮之间的间距
        UIBarButtonItem *itemSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        itemSpace.width = 15;
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: setRightItem,itemSpace,nil]];
    }
    
    
    self.onlyPlayBackBtn.hidden = YES;
}

- (void)setDefaultParameters_WillAppear
{
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [UIApplication sharedApplication].idleTimerDisabled = YES;//设置屏幕常亮
    
    self.btn_video.jp_acceptEventInterval = 1.0f;
    self.btn_sound.jp_acceptEventInterval = 1.0f;
    self.btn_stop.jp_acceptEventInterval = 1.0f;
    self.btn_start.jp_acceptEventInterval = 1.0f;
    
    self.firstRememder = YES;
    isStop = NO;
    isQueryVideo = NO;
    self.isFull = NO;//初始化位全屏
    self.isHd = NO;//初始化是否hd
    self.isRecord = NO;//初始化未录制
    self.againPlay = NO;//初始化是否重新播放
    isTimeRulerShow = NO;
    [self postChangePlaySpeed:1];//默认1倍速播放
}

- (void)setDefaultParameters_WillDisappear
{
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    [UIApplication sharedApplication].idleTimerDisabled = NO;//设置屏幕关闭常亮
    
}

- (void)addObserver
{
    //进入后台停止播放
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopAllVideo:) name:BEBACKGROUNDSTOP object:nil];
    //进入前台开始播放
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startAllVideo:) name:BEBEFORSTART object:nil];
    //码流连接失效停止播放
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notOnlineStopVideo:) name:ONLINESTREAM object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stop_LoadView) name:PLAYFAIL object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stop_PlayMovie) name:PLAYSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stop_PlayMovie) name:HIDELOADVIEW object:nil];
    //播放失败
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(PlayFaild) name:PLAYFAIL object:nil];//待做
    //播放的时候，时刻刷新当前播放时间，联动时间轴
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTimeLabel:) name:RETURNTIMESTAMP object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTimeRuler:) name:RETURNTIMESTAMP_TIMERULER object:nil];
   
}

- (void)setUpChildView
{
    [self cteateNavBtn];//导航栏按钮
    [self setUpBtn];//创建按钮相关
    [self addPlayVideoView];//添加播放界面
    [self.view addSubview:self.slider];//添加自定义滑块
    [self.centerTimeView addSubview:self.noImageView];//添加无视频图像
    /*
    //按钮背景消失
    [self performSelector:@selector(videoViewBackHidden) withObject:nil afterDelay:5];
    */
    [self.btn_hd setImage:[UIImage imageNamed:@"倍速1x_h"] forState:UIControlStateNormal];
    [self.view addSubview:self.centerTimeView];
    [self.centerTimeView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.playView.mas_bottom);
        if (iPhone_X_TO_Xs) make.height.mas_equalTo(127);
        else if (iPhone_6Plus_TO_8Plus) make.height.mas_equalTo(127);
        else if (iPhone_6_TO_8) make.height.mas_equalTo(127);
        else make.height.mas_equalTo(122);
        [self.centerTimeView layoutIfNeeded];
    }];
    self.timeStr = self.centerTimeView.btn_time.titleLabel.text;//得到日期
    
    //判断是否是文件夹模式
    [self autoSearchAndPlayVideoIsDeviceVideo:self.isDeviceVideo TimeStr:self.timeStr];
    
    NSLog(@"开始创建的时间是:%@",self.timeStr);
    
    [self.videoManager returnTimeStamp:^(double showTime) {
        NSLog(@"根据后台来的时间，刷新当前播放时间轴上的时间显示 是 ：%f",showTime);
    }];
}
//标尺移动时候返回的时间
- (void)weightChanged:(GLFRulerControl *)ruler {
    NSLog(@"还有showTime不存在的？：%@",ruler.showTime);
    if (ruler.showTime) {
        self.timeMinStr = [NSString stringWithFormat:@"%@:00",ruler.showTime];
        NSLog(@"【调试】更新self.timeMinStr的值是：self.timeMinStr:%@=======ruler.showTime:%@",self.timeMinStr,ruler.showTime);
    }
}

#pragma mark - 按钮状态初始化
- (void)setUpBtn
{
    [self.btn_start setImage:[UIImage imageNamed:@"暂停_h"] forState:UIControlStateSelected];
    [self.btn_sound setImage:[UIImage imageNamed:@"声音_h"] forState:UIControlStateSelected];
    [self.btn_hd setImage:[UIImage imageNamed:@"hd_h"] forState:UIControlStateSelected];
    [self.btn_video setImage:[UIImage imageNamed:@"摄像_light"] forState:UIControlStateSelected];

    //今日时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    [self.centerTimeView.btn_time setTitle:currentTime forState:UIControlStateNormal];

    self.isCanCut = NO;    //是否可以截屏
}

#pragma mark - 创建tableview并设置分区和高度
// 创建tableView
-(void)createTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    //设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = RGB(245, 245, 245);
    UIView *footView = [[UIView alloc]init];
    self.tableView.tableFooterView = footView;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.centerTimeView.mas_bottom);
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view);
    }];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullDownMethod)];
    [header beginRefreshing];
    self.tableView.mj_header = header;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];//上拉加载
}

//下拉刷新
- (void)pullDownMethod
{
    pageNum = 0;
    [self queryAlarmMessageFromServerWithDateStr:self.currentDateTimeStr];
}
//上拉加载
- (void)loadMoreData
{
    pageNum ++;
    [self queryAlarmMessageFromServerWithDateStr:self.currentDateTimeStr];
}

#pragma mark ================================ tableview 代理方法 ================================
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  _arrayM.count;
}

//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

//head的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    UILabel *dateTipLb1 = [[UILabel alloc]init];
    dateTipLb1.frame = CGRectMake(10, 0, self.view.frame.size.width, 44);
    dateTipLb1.text = NSLocalizedString(@"设备消息", nil);
    [headView addSubview:dateTipLb1];
    
    headView.backgroundColor = BG_COLOR;
    
    return headView;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, 0.001)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * str = @"MyCell";
    AlarmNewCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(cell == nil){
        cell = [[AlarmNewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    cell.indexPath = indexPath;
    cell.delegete = self;
    if (_arrayM.count != 0) {
        //根据已读未读显示红点
        PushMsgModel * model = _arrayM[indexPath.row];
        cell.alermModel = model;
        
    }
    return cell;
}


#pragma mark - 点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!isTimeRulerShow) {
        [XHToast showCenterWithText:NSLocalizedString(@"未能查到可播放视频，播放失败！", nil)];
        return;
    }
   // [self tableView_down];
    
    PushMsgModel * model = _arrayM[indexPath.row];
    if (model.markread == NO) {
        model.markread = YES;
    }
    AlarmNewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.attentionView.hidden = YES;
    [cell configRedPointHidden:YES];
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* userID = [defaults objectForKey:@"user_id"];
    [dic setObject:userID forKey:@"user_id"];
    [dic setObject:model.alarmId forKey:@"alarm_id"];
    [[HDNetworking sharedHDNetworking] POST:@"v1/alarm/markread" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"告警消息已读 responseObject：%@",responseObject);
    } failure:^(NSError * _Nonnull error) {
    }];
    
    
    NSString * alarmTimeStr = [unitl timeStampSwitchTime:model.alarmTime andFormatter:@"YYYY-MM-dd" IsTenBit:YES];
    NSString * alarmtimeMinStr = [unitl timeStampSwitchTime:model.alarmTime andFormatter:@"HH:mm:ss" IsTenBit:YES];
    
    NSLog(@"日期：%@===%@",alarmTimeStr,alarmtimeMinStr);
    
    self.timeMinStr = alarmtimeMinStr;
    
    self.timeStr = alarmTimeStr;
    self.timeRuler.indicatorCurrentTime = model.alarmTime;
    NSLog(@"【调试】didSelected 报警时间：alarmTimeStr：%@===alarmtimeMinStr：%@===self.timeMinStr：%@===self.timeStr:%@",alarmTimeStr,alarmtimeMinStr,self.timeMinStr,self.timeStr);
    [self reloadTimePlay_didSelectedTimeStr:alarmTimeStr TimeMinStr:alarmtimeMinStr];//调用滚动时间轴这边的方法。
}

#pragma mark - 放大告警消息图片代理方法
- (void)Alarmcell_tPictureImageClick:(AlarmNewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    [self removeMarkReadClick:cell];
    [self.view addSubview:self.enlarge];
    //根据已读未读显示红点
    PushMsgModel * model = _arrayM[indexPath.row];
    if (![NSString isNull:model.alarmPic]) {
        NSURL *imaUrl = [NSURL URLWithString:model.alarmPic];
        NSURLRequest *request = [NSURLRequest requestWithURL:imaUrl];
        __block UIImage *image;
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *_Nullable response, NSData *_Nullable data, NSError *_Nullable connectionError) {
            //设备图片展示时所需解密的东西
            dev_list *devModel;
            NSMutableArray *devArr = (NSMutableArray *)[unitl getAllDeviceCameraModel];
            for (int i = 0; i < devArr.count; i++) {
                if ([((dev_list *)(devArr[i])).ID isEqualToString:model.deviceId]) {
                    devModel = ((dev_list *)(devArr[i]));
                    break;
                }
            }

            self.key = devModel.dev_p_code;
            self.bIsEncrypt = devModel.enable_sec;

            const unsigned char *imageCharData = (const unsigned char *)[data bytes];
            size_t len = [data length];

            unsigned char outImageCharData[len];
            size_t outLen = len;
            //        NSLog(@"收到图片的data：%@---长度：%zd",response,[data length]);
            if (len % 16 == 0 && [((NSHTTPURLResponse *)response) statusCode] == 200 && self.key.length > 0 && self.bIsEncrypt) {
                int decrptImageSucceed = jw_cipher_decrypt(self.cipher, imageCharData, len, outImageCharData, &outLen);
                //            NSLog(@"报警界面，收到加密图片数据正确，进行解密:%d",decrptImageSucceed);
                if (decrptImageSucceed == 1) {
                    NSData *imageData = [[NSData alloc]initWithBytes:outImageCharData length:outLen];
                    image = [UIImage imageWithData:imageData];

                    if (image) {
//                        cell.pictureImage.image = image;
                        self.enlarge.enlargeImage = image;
                    } else {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                                           [cell.pictureImage sd_setImageWithURL:imaUrl placeholderImage:[UIImage imageNamed:@"img2"]];
//                                       });
                        self.enlarge.imageUrl = model.alarmPic;
                    }
                } else {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                                       [cell.pictureImage sd_setImageWithURL:imaUrl placeholderImage:[UIImage imageNamed:@"img2"]];
//                                   });
                    self.enlarge.imageUrl = model.alarmPic;
                }
            } else {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                                   [cell.pictureImage sd_setImageWithURL:imaUrl placeholderImage:[UIImage imageNamed:@"img2"]];
//                               });
                self.enlarge.imageUrl = model.alarmPic;
            }
        }];
    } else {
        self.enlarge.enlargeImage = [UIImage imageNamed:@"alerm"];
    }
    [self.enlarge enlargeImageClick];
}

#pragma mark - 放大图片去掉红点
- (void)removeMarkReadClick:(AlarmNewCell *)cell
{
    NSIndexPath *IndexPath = [self.tableView indexPathForCell:cell];
    PushMsgModel * model = _arrayM[IndexPath.row];
    if (model.markread == NO) {
        model.markread = YES;
//        cell.attentionView.hidden = YES;
        [cell configRedPointHidden:YES];
        
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* userID = [defaults objectForKey:@"user_id"];
        [dic setObject:userID forKey:@"user_id"];
        [dic setObject:model.alarmId forKey:@"alarm_id"];
        [[HDNetworking sharedHDNetworking] POST:@"v1/alarm/markread" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
            NSLog(@"responseObject：%@",responseObject);
        } failure:^(NSError * _Nonnull error) {
        }];
    }
    [self.tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint vel = [scrollView.panGestureRecognizer velocityInView:scrollView];
    if (vel.y > 0) {//下拉
        [self tableView_down];
    }else{//上拉
        if (vel.y != 0) {
            [self tableView_up];
        }
    }
}

#pragma mark - tableView 上滑或者下滑动
- (void)tableView_up
{
    [UIView animateWithDuration:NavBarHeightChangge_duringTime animations:^{
        [self.centerTimeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            NSInteger viewHeight;
            if (iPhone_X_TO_Xs) viewHeight = 127;
            else if (iPhone_6Plus_TO_8Plus) viewHeight = 127;
            else if (iPhone_6_TO_8) viewHeight = 127;
            else viewHeight = 122;
            make.left.right.mas_equalTo(self.view);
            make.top.mas_equalTo(self.playView.mas_bottom).offset( -viewHeight + 10);
            make.height.mas_equalTo(viewHeight);
        }];
        [self.view sendSubviewToBack:self.centerTimeView];
        [self.view layoutIfNeeded];
    }];
}

- (void)tableView_down
{
    [UIView animateWithDuration:NavBarHeightChangge_duringTime animations:^{
        [self.centerTimeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.view);
            make.top.mas_equalTo(self.playView.mas_bottom);
            if (iPhone_X_TO_Xs) make.height.mas_equalTo(127);
            else if (iPhone_6Plus_TO_8Plus) make.height.mas_equalTo(127);
            else if (iPhone_6_TO_8) make.height.mas_equalTo(127);
            else  make.height.mas_equalTo(122);
        }];
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - 时间查询按钮点击事件-当天的是否有录像以及录像时间轴上的时间录像展现
- (void)searchVideoAndshowTimeRulerWithDateStr:(NSString *)dateStr
{
    self.timeMinStr = nil;//切换日期时，将时间重置
    [self autoSearchAndPlayVideoIsDeviceVideo:self.isDeviceVideo TimeStr:dateStr];
    [self reloadTimePlay];
}

#pragma mark - 从服务器主动查询推送过来的报警信息
- (void)queryAlarmMessageFromServer
{
    NSDate * date = [NSDate date];
    NSDate* lastDay = [NSDate zeroOfDate];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    
    //选中日期的0点0分的时间戳
    NSString *startTime = [NSString stringWithFormat:@"%ld", (long)[lastDay timeIntervalSince1970]];
    //选中日期的当前时间
    NSString *stopTime = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    NSLog(@"从服务器主动查询推送过来的报警信息【开始时间】%@===【结束时间】：%@",startTime,stopTime);
    [self queryAlarmMessageFromServerStopTime:stopTime StartTime:startTime];
}

- (void)queryAlarmMessageFromServerWithDateStr:(NSString *)datestr
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSDate * selectedDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",datestr]];
    NSDate * stopDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ 23:59:59",datestr]];

    //选中日期的0点0分的时间戳
    NSString * startTime = [NSString stringWithFormat:@"%ld", (long)[selectedDate timeIntervalSince1970]];
    //选中日期的23:59:59的时间戳
    NSString * stopTime = [NSString stringWithFormat:@"%ld", (long)[stopDate timeIntervalSince1970]];
    NSLog(@"传给服务器主动查询推送过来的报警信息【指定日期的时间】【开始时间】%@===【结束时间】：%@",startTime,stopTime);
    [self queryAlarmMessageFromServerStopTime:stopTime StartTime:startTime];
}

- (void)queryAlarmMessageFromServerStopTime:(NSString *)stopTime StartTime:(NSString *)startTime
{
//    [_arrayM removeAllObjects];
    NSMutableDictionary * postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [postDic setObject:self.listModel.ID forKey:@"dev_id"];
    [postDic setObject:stopTime forKey:@"stop_time"];
    [postDic setObject:startTime forKey:@"start_time"];
    [postDic setObject:[NSString stringWithFormat:@"%ld",(long)pageNum*PAGESIZE] forKey:@"offset"];//代表分页 * 每一页的条数 的 乘积
    [postDic setObject:[NSString stringWithFormat:@"%d",PAGESIZE] forKey:@"limit"];
    [postDic setObject:@"100" forKey:@"alarmType"];//alarmType传100就是查询所有报警的,否则是过滤报警
    [[HDNetworking sharedHDNetworking] GET:@"v1/alarm/list" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
//        NSLog(@"only查到的报警信息:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
          //  NSLog(@"从服务器主动查询推送过来的报警信息responseObject:%@",responseObject);
            tempArr = [PushMsgModel  mj_objectArrayWithKeyValuesArray:responseObject[@"body"][@"alarmList"]];

            if ([self.tableView.mj_header isRefreshing]) {
                [_arrayM removeAllObjects];
            }
            
            if (tempArr.count != 0) {
                [_arrayM addObjectsFromArray:tempArr];
            }
            
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }else{
            NSLog(@"从服务器主动查询推送过来的报警信息【失败】:%@",responseObject);
            [XHToast showCenterWithText:NSLocalizedString(@"查询告警消息失败，请稍候再试", nil)];
            [self.tableView.mj_header endRefreshing];
        }
        
        if ([self.tableView.mj_header isRefreshing]) {
            [self.tableView.mj_header endRefreshing];
        }
        if (_arrayM.count < PAGESIZE) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [self.tableView.mj_footer resetNoMoreData];
        }
        
    }failure:^(NSError * _Nonnull error) {
        NSLog(@"从服务器主动查询推送过来的报警信息【失败~~】");
        [XHToast showCenterWithText:NSLocalizedString(@"查询告警消息失败，请检查您的网络", nil)];
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark - 添加播放视图
- (void)addPlayVideoView
{
    //操作视图添加捏合移动手势
    //添加缩放手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchToVideoManage:)];
    [self.VideoViewBank addGestureRecognizer:pinch];
    
    //拖动手势
    UIPanGestureRecognizer *Pan = [[UIPanGestureRecognizer alloc] initWithTarget: self action: @selector (handleSwipeToManage:)];
    Pan.minimumNumberOfTouches = 2;
    [self.VideoViewBank addGestureRecognizer:Pan];
    
    _isAppear = 0;
    //添加点击手势 消失工具条
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectZhuangtai)];
    [self.VideoViewBank addGestureRecognizer:tap];
    
    //轻扫【左滑、右滑】
    NSArray * array = @[@(UISwipeGestureRecognizerDirectionLeft),@(UISwipeGestureRecognizerDirectionRight)];
    UISwipeGestureRecognizer * swipe;
    for (NSNumber * number in array) {
        swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
        swipe.direction = [number integerValue];
        [self.VideoViewBank addGestureRecognizer:swipe];
    }
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
    JWPlayerManage *playerManage = [JWOpenSdk createPlayerManageWithDevidId:_listModel.ID ChannelNo:1];
    // self.videoManage = playerManage;
    _videoManage = playerManage;
    
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
    //设置拉伸模式
    self.playView.contentMode = UIViewContentModeScaleAspectFit;
    self.isCanCut = NO;
}

//视频无法播放时显示的画面
-(UIButton *)failVideoBtn{
    if (!_failVideoBtn) {
        _failVideoBtn = [[UIButton alloc]init];
        [_failVideoBtn setImage:[UIImage imageNamed:@"PlayViedo"] forState:UIControlStateNormal];
        [_failVideoBtn addTarget:self action:@selector(reStartBtn) forControlEvents:UIControlEventTouchUpInside];
        _failVideoBtn.hidden = YES;
    }
    [self.playView addSubview:_failVideoBtn];
    [_failVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.playView);
        make.size.mas_offset(CGSizeMake(30, 30));
    }];
    return _failVideoBtn;
}

#pragma mark - 播放失败，再次播放
- (void)reStartBtn
{
    
    
}

#pragma mark - 录像加载动画 【消失】和【出现】 方法
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

#pragma mark - 获取实时音视频地址
- (void)getVideoAddress
{
    //[[HDNetworking sharedHDNetworking]canleAllHttp];
    NSLog(@"【onlyPlayBackVC】打印看看设备在不在线：%ld",(long)self.listModel.status);
    
    if(self.listModel.status == 1){
        [self setLoadingView];
    }else{
        //[[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
        [self cannelLodingView];
    }
    
    if (self.listModel.name) {
        self.navigationItem.title = self.listModel.name;
    }else{
        self.navigationItem.title = self.channelModel.chanName;
    }
    
    [self btnStopClick:self.btn_stop];
    self.againPlay = NO; //是否重新播放标识
    //记住用户是否hd
    if ([[NSUserDefaults standardUserDefaults]objectForKey:ISHD]) {
        NSNumber *hdNubmer = [[NSUserDefaults standardUserDefaults]objectForKey:ISHD];
        self.isHd = [hdNubmer boolValue];
    }else{
        self.isHd = NO;
    }
    self.btn_hd.selected = self.isHd;

    JWVideoTypeStatus  videoTypeStatus;
    if (self.isHd) videoTypeStatus = JWVideoTypeStatusHd;
    else videoTypeStatus = JWVideoTypeStatusNomal;
    [self.videoManage JWPlayerManageBeginPlayVideoWithVideoType:videoTypeStatus BIsEncrypt:self.bIsEncrypt Key:self.key BIsAP:NO completionBlock:^(JWErrorCode errorCode) {
        if (self.isHd) [self.btn_hd setImage:[UIImage imageNamed:@"hd_h"] forState:UIControlStateNormal];
        else [self.btn_hd setImage:[UIImage imageNamed:@"hd_n"] forState:UIControlStateNormal];
        if (errorCode == JW_SUCCESS) {
            self.btn_start.selected = YES;
            self.isCanCut = YES;//播放成功可以截图
            NSLog(@"成功!");
        }if (errorCode == JW_FAILD) {
            [XHToast showTopWithText:NSLocalizedString(@"获取视频失败", nil) topOffset:160];
            self.isCanCut = NO;
            NSLog(@"失败!");
            //[[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];//待做
        }
    }];
}

#pragma mark - 请求是否有回放录【点击云端和设备录像按钮调用方法】

//传进来timeStr是当前的  【年月日】 就好了，会拼接成当天的【0点0分】。
- (void)getRecordVideo_TimeStr_Zero:(NSString *)timeStr
{
    
}
//传进来就是  【年月日 时分秒】
- (void)getRecordVideo_TimeStr:(NSString *)timeStr
{
    
}

- (void)getRecordVideo:(NSString *)timeStr//获取的是日期
{
    isQueryVideo = YES;
    if (self.bIsAP) {
        [self.videoManage searchRecordVideoBIsAp:YES beginTime:timeStr completionBlock:^(NSArray *recVideoTimeArr, JWErrorCode errorCode) {
            //时间戳
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
            //今日零点
            NSString *beginTimeStr =[NSString stringWithFormat:@"%@ %@",timeStr,@"00:00:00"];
            NSDate *date = [formatter dateFromString:beginTimeStr];
            NSLog(@"DATE:%@", date);// 这个时间是格林尼治时间
            // NSDate *date2 = [date dateByAddingTimeInterval:8 * 60 * 60];
            NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
            int beginTimeInt = [dateStr intValue];
            
            //当前时间
            NSDate *nowDate = [NSDate date];
            NSTimeInterval a= [nowDate timeIntervalSince1970];
            NSString*nowTimeStr = [NSString stringWithFormat:@"%0.f", a];
            int nowTimeInt = [nowTimeStr intValue];
            nowRecordSlidingTime = nowTimeInt;
            NSMutableArray * recVideoTimeArr_ap = [NSMutableArray arrayWithCapacity:0];
            recVideoTimeArr_ap = [recVideoTimeArr mutableCopy];
            if (recVideoTimeArr_ap.count>0) {
                for (int i = 0; i < recVideoTimeArr_ap.count; i++) {
                    //JWDeviceRecordFile *records = recVideoTimeArr_ap[i];
                    int startTimeStr = [recVideoTimeArr_ap[i][@"startTime"]intValue];
                    int stopTimeStr = [recVideoTimeArr_ap[i][@"stopTime"]intValue];
                    ZCVideoTimeModel *model = [[ZCVideoTimeModel alloc]init];
                    //起点距离今日00分钟
                    CGFloat beginMin = (startTimeStr - beginTimeInt);
                    //终点距离今日00分钟
                    CGFloat endMin = (stopTimeStr - beginTimeInt);
                    model.benginTime = beginMin;
                    model.endTime = endMin;
                    NSLog(@"model.endTime:%f====model.benginTime:%f",endMin,beginMin);
                    [self.videoTimeModelArr addObject:model];
                }
                [animationView dismiss];
                ZCVideoTimeModel *model = [[ZCVideoTimeModel alloc]init];
                model = (ZCVideoTimeModel *)[self.videoTimeModelArr lastObject];
                NSInteger endSecond = model.endTime;
                [unitl saveTimeRulerLastVideoTimeBySecond:endSecond];

                if (self.isFull) {
                    [self showTimeRulerWithFullScreen:YES];
                    if (self.timeMinStr) {
                        NSString *alarmTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,self.timeMinStr];
                        NSInteger alarmIntTime= [unitl timeSwitchTimeStamp:alarmTimeStr andFormatter:@"YYYY-MM-dd HH:mm:ss"];
                        self.timeRuler.indicatorCurrentTime = (int)alarmIntTime;
                    }else{
                        //尺子初始化是默认展示在第一条数据上的位置
                        [self defaultTimeRulerPosition];
                    }
                    [self.timeRuler drawVideoBgViewWithArray:self.videoTimeModelArr];
                    self.timeRuler.backgroundColor = [UIColor colorWithWhite:0.93 alpha:0.8];
                }else{
                    //添加新时间轴
                    [self showTimeRulerWithFullScreen:NO];
                    if (self.timeMinStr) {
                        NSString *alarmTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,self.timeMinStr];
                        NSInteger alarmIntTime= [unitl timeSwitchTimeStamp:alarmTimeStr andFormatter:@"YYYY-MM-dd HH:mm:ss"];
                        self.timeRuler.indicatorCurrentTime = (int)alarmIntTime;
                    }else{
                        //尺子初始化是默认展示在第一条数据上的位置
                        [self defaultTimeRulerPosition];
                    }
                    [self.timeRuler drawVideoBgViewWithArray:self.videoTimeModelArr];
                }
                isQueryVideo = NO;
            }
            else{
                [animationView dismiss];
                self.isCanCut = NO;
                //没有图像时 进度条隐藏
                [self dismissTimeRuler];
                self.noImageView.hidden = NO;
                isQueryVideo = NO;
            }
        }];
    }else{
        [animationView showInView:self.centerTimeView];
        self.noImageView.hidden = YES;
        self.againPlay = NO;
        //时间戳
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        //今日零点
        NSString *beginTimeStr =[NSString stringWithFormat:@"%@ %@",timeStr,@"00:00:00"];
        NSDate *date = [formatter dateFromString:beginTimeStr];
        NSLog(@"DATE:%@", date);// 这个时间是格林尼治时间
        // NSDate *date2 = [date dateByAddingTimeInterval:8 * 60 * 60];
        NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
        int beginTimeInt = [dateStr intValue];
        
        //当前时间戳给进度条
        //    NSDate* nowDate = [NSDate dateWithTimeIntervalSinceNow:8*60*60];
        NSDate *nowDate = [NSDate date];
        NSTimeInterval a= [nowDate timeIntervalSince1970];
        NSString*nowTimeStr = [NSString stringWithFormat:@"%0.f", a];
        int nowTimeInt = [nowTimeStr intValue];
        nowRecordSlidingTime = nowTimeInt;
        [self.videoTimeModelArr removeAllObjects];
        //搜索是否有回放录像 但是不立刻播放
        
        if (self.isDeviceVideo == NO) {
            [self.videoManage searchRecordVideoWithDevidId:self.listModel.ID recVideoType:JWRecVideoTypeStatusCenter beginTime:date completionBlock:^(NSArray *recVideoTimeArr, JWErrorCode errorCode) {//原来listModel.ID
                
                if (errorCode == JW_SUCCESS || errorCode == JW_SUCCESS_SEARCH_VIDEO_LIST) {
                    //回放时间数组
                    if (recVideoTimeArr.count > 0) {
                        
                        if (isDefaultMode) {
                            
                            [self.rulerModelArr removeAllObjects];
                            self.timeRuler.hidden = YES;
                            self.noTimeShaftRuler.hidden = YES;
                            int sumTime = 0;
                            for (int i = 0; i<recVideoTimeArr.count; i++) {
                                JWDeviceRecordFile *records = recVideoTimeArr[i];
                                //                        NSLog(@"开始时间:%d===与结束时间:%d",records.start_time,records.stop_time);
                                sumTime += records.stop_time - records.start_time;
                            }
                            
                            if (self.isFull) {
                                radio = sumTime*1.0/iPhoneHeight;
                            }else{
                                radio = sumTime*1.0/iPhoneWidth;
                            }
                            
                            NSLog(@"比例:%f",radio);
                            
                            float startSumLoc = 0.f;
                            
                            for (int i = 0; i<recVideoTimeArr.count; i++) {
                                JWDeviceRecordFile *records = recVideoTimeArr[i];
                                
                                NoTimeShaftRulerModel *model = [[NoTimeShaftRulerModel alloc]init];
                                model.startTimestamp = records.start_time;
                                model.endTimestamp = records.stop_time;
                                model.timeInterval = model.endTimestamp - model.startTimestamp;
                                model.startLoc = startSumLoc;
                                startSumLoc += model.timeInterval/radio;
                                model.endLoc = model.startLoc + model.timeInterval/radio;
                                
                                [self.rulerModelArr addObject:model];
                                
                                //                        NSLog(@"开始时间戳：%d    \n结束时间戳：%d\n时间差：%d\n起始位置：%f\n结束位置：%f",model.startTimestamp,model.endTimestamp,model.timeInterval,model.startLoc,model.endLoc);
                            }
                            
                            
                            NoTimeShaftRulerModel *model = self.rulerModelArr[0];
                            self.noTimeShaftRuler.timeLb.text = [unitl timeStampSwitchTime:model.startTimestamp andFormatter:@"HH:mm:ss" IsTenBit:YES];
                            
                            [animationView dismiss];
                            //================
                            self.noTimeShaftRuler.hidden = NO;
                            [self timestampTransformAxisDistance];
                            //================
                            
                            
                        }else{
                            
                            for (int i = 0; i<recVideoTimeArr.count; i++) {
                                JWDeviceRecordFile *records = recVideoTimeArr[i];
                                ZCVideoTimeModel *model = [[ZCVideoTimeModel alloc]init];
                                //起点距离今日00分钟
                                CGFloat beginMin = (records.start_time - beginTimeInt);
                                //终点距离今日00分钟
                                CGFloat endMin = (records.stop_time - beginTimeInt);
                                model.name = records.name;
                                model.benginTime = beginMin;
                                model.endTime = endMin;
                                [self.videoTimeModelArr addObject:model];
                            }
                            ZCVideoTimeModel *model = [[ZCVideoTimeModel alloc]init];
                            model = (ZCVideoTimeModel *)[self.videoTimeModelArr lastObject];
                            NSInteger endSecond = model.endTime;
                            [unitl saveTimeRulerLastVideoTimeBySecond:endSecond];
                            [animationView dismiss];
                            //================
                            self.timeRuler.hidden = NO;
                            //================
                            
                            if (self.isFull) {
                                [self showTimeRulerWithFullScreen:YES];
                                if (self.timeMinStr) {
                                    NSString *alarmTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,self.timeMinStr];
                                    NSInteger alarmIntTime= [unitl timeSwitchTimeStamp:alarmTimeStr andFormatter:@"YYYY-MM-dd HH:mm:ss"];
                                    self.timeRuler.indicatorCurrentTime = (int)alarmIntTime;
                                }else{
                                    //尺子初始化是默认展示在第一条数据上的位置
                                    [self defaultTimeRulerPosition];
                                }
                                [self.timeRuler drawVideoBgViewWithArray:self.videoTimeModelArr];
                                self.timeRuler.backgroundColor = [UIColor colorWithWhite:0.93 alpha:0.8];
                            }else{
                                [self showTimeRulerWithFullScreen:NO];
                                if (self.timeMinStr) {
                                    NSString *alarmTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,self.timeMinStr];
                                    NSInteger alarmIntTime= [unitl timeSwitchTimeStamp:alarmTimeStr andFormatter:@"YYYY-MM-dd HH:mm:ss"];
                                    self.timeRuler.indicatorCurrentTime = (int)alarmIntTime;
                                }else{
                                    //尺子初始化是默认展示在第一条数据上的位置
                                    [self defaultTimeRulerPosition];
                                }
                                [self.timeRuler drawVideoBgViewWithArray:self.videoTimeModelArr];
                            }
                            
                            
                        }
                        
                        
                        
                        isQueryVideo = NO;
                    }
                    else{
                        //   [XHToast showTopWithText:@"当前日期暂无录像" topOffset:160];
                        [self noPlayBackVideo];
                    }
                }
                if (errorCode == JW_FAILD) {
                    //  [XHToast showTopWithText:@"当前日期暂无录像" topOffset:160];
                    [self noPlayBackVideo];
                }
                if (errorCode == JW_PLAYBACK_NO_PERMISSION || errorCode == JW_SEARCH_PLAYBACK_NO_PERMISSION) {//录像回放无权限
                    [self noPlayBackVideo];
                    [XHToast showCenterWithText:NSLocalizedString(@"非分享时间段内无法观看", nil)];
                }
            }];
        }else{//设备录像
            [self.videoManage searchRecordVideoWithDevidId:self.listModel.ID recVideoType:JWRecVideoTypeStatusLeading beginTime:date completionBlock:^(NSArray *recVideoTimeArr, JWErrorCode errorCode) {
                
                NSLog(@"datedatedate:%@",date);
                
                if (errorCode == JW_SUCCESS || errorCode == JW_SUCCESS_SEARCH_VIDEO_LIST) {
                    //回放时间数组
                    if (recVideoTimeArr.count>0) {
                        for (int i = 0; i < recVideoTimeArr.count; i++) {
                            JWDeviceRecordFile *records = recVideoTimeArr[i];
                            ZCVideoTimeModel *model = [[ZCVideoTimeModel alloc]init];
                            //起点距离今日00分钟
                            CGFloat beginMin = (records.start_time-beginTimeInt);
                            //终点距离今日00分钟
                            CGFloat endMin = (records.stop_time-beginTimeInt);
                            model.name = records.name;
                            model.benginTime = beginMin;
                            model.endTime = endMin;
                            // NSLog(@"model.endTime:%f====model.benginTime:%f",endMin,beginMin);
                            [self.videoTimeModelArr addObject:model];
                        }
                        ZCVideoTimeModel *model = [[ZCVideoTimeModel alloc]init];
                        model = (ZCVideoTimeModel *)[self.videoTimeModelArr lastObject];
                        NSInteger endSecond = model.endTime;
                        [unitl saveTimeRulerLastVideoTimeBySecond:endSecond];
                        [animationView dismiss];
                        
                        if (self.isFull) {
                            [self showTimeRulerWithFullScreen:YES];//横屏时标尺的显示
                            if (self.timeMinStr) {
                                NSString *alarmTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,self.timeMinStr];
                                NSInteger alarmIntTime= [unitl timeSwitchTimeStamp:alarmTimeStr andFormatter:@"YYYY-MM-dd HH:mm:ss"];
                                self.timeRuler.indicatorCurrentTime = (int)alarmIntTime;
                            }else{
                                //尺子初始化是默认展示在第一条数据上的位置
                                [self defaultTimeRulerPosition];
                            }
                            
                            [self.timeRuler drawVideoBgViewWithArray:self.videoTimeModelArr];
                            self.timeRuler.backgroundColor = [UIColor colorWithWhite:0.93 alpha:0.8];
                        }else{
                            [self showTimeRulerWithFullScreen:NO];
                            if (self.timeMinStr) {
                                NSString *alarmTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,self.timeMinStr];
                                NSInteger alarmIntTime= [unitl timeSwitchTimeStamp:alarmTimeStr andFormatter:@"YYYY-MM-dd HH:mm:ss"];
                                self.timeRuler.indicatorCurrentTime = (int)alarmIntTime;
                            }else{
                                //尺子初始化是默认展示在第一条数据上的位置
                                [self defaultTimeRulerPosition];
                            }
                            [self.timeRuler drawVideoBgViewWithArray:self.videoTimeModelArr];
                        }
                        isQueryVideo = NO;
                    }
                    else{
                       [self noPlayBackVideo];
                    }
                }
                if (errorCode == JW_FAILD) {
                    [self noPlayBackVideo];
                    [self dismissTimeRulerAndshowTip];
                }
                if (errorCode == JW_PLAYBACK_NO_PERMISSION || errorCode == JW_SEARCH_PLAYBACK_NO_PERMISSION) {//录像回放无权限
                    [self noPlayBackVideo];
                    [XHToast showCenterWithText:NSLocalizedString(@"非分享时间段内无法观看", nil)];
                }
            }];
        }
    }
}
//没有录像的时候
- (void)noPlayBackVideo
{
    isQueryVideo = NO;
    [animationView dismiss];
    self.isCanCut = NO;
    [self dismissTimeRulerAndshowTip];
}

#pragma mark - 由主界面列表根据isDeviceVideo属性选择【云端】或者【设备】进入，显示当前可播放的时间轴
- (void)autoSearchAndPlayVideoIsDeviceVideo:(BOOL)isDeviceVideo TimeStr:(NSString *)timeStr
{
    NSLog(@"由主界面列表直接选择【云端】或者【设备】进入，直接播放当前视频:isDeviceVideo:%@===timeStr:%@",isDeviceVideo?@"YES":@"NO",timeStr);
    [animationView showInView:self.centerTimeView];
    self.noImageView.hidden = YES;
    self.againPlay = NO;
    
    //时间戳
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //今日零点
    NSString *beginTimeStr =[NSString stringWithFormat:@"%@ %@",timeStr,@"00:00:00"];
    NSDate *date = [formatter dateFromString:beginTimeStr];// 这个时间是格林尼治时间
    // NSDate *date2 = [date dateByAddingTimeInterval:8 * 60 * 60];
    NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    int beginTimeInt = [dateStr intValue];
    
    NSDate *nowDate = [NSDate date];
    NSTimeInterval a= [nowDate timeIntervalSince1970];
    NSString *nowTimeStr = [NSString stringWithFormat:@"%0.f", a];
    int nowTimeInt = [nowTimeStr intValue];
    nowRecordSlidingTime = nowTimeInt;
    
    
    [self.videoManage searchRecordVideoWithDevidId:self.listModel.ID recVideoType:isDeviceVideo ? JWRecVideoTypeStatusLeading :JWRecVideoTypeStatusCenter beginTime:date completionBlock:^(NSArray *recVideoTimeArr, JWErrorCode errorCode) {
        NSLog(@"录像报警界面查询错误码是：%ld",(long)errorCode);
        //注释：因为之前错误码没有区分是 录像列表没有查询成功还是录像查询成功但是录像播放失败的情况。故添加错误码，并判断实现。
        switch (errorCode) {
            case JW_SUCCESS://能够有这个【视频信息成功】回调，代表，查询录像也是成功的。
            {
                [self.videoTimeModelArr removeAllObjects];
                for (int i = 0; i<recVideoTimeArr.count; i++) {
                    JWDeviceRecordFile *records = recVideoTimeArr[i];
                    ZCVideoTimeModel *model = [[ZCVideoTimeModel alloc]init];
                    //起点距离今日00分钟
                    CGFloat beginMin = (records.start_time - beginTimeInt);
                    //终点距离今日00分钟
                    CGFloat endMin = (records.stop_time - beginTimeInt);
                    model.name = records.name;
                    model.benginTime = beginMin;
                    model.endTime = endMin;
                    [self.videoTimeModelArr addObject:model];
                }
                ZCVideoTimeModel *model = [[ZCVideoTimeModel alloc]init];
                model = (ZCVideoTimeModel *)[self.videoTimeModelArr lastObject];
                NSInteger endSecond = model.endTime;
                [unitl saveTimeRulerLastVideoTimeBySecond:endSecond];
                [animationView dismiss];
                
                [self showTimeRulerWithFullScreen:NO];
                if (self.timeMinStr) {
                    NSString *alarmTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,self.timeMinStr];
                    NSInteger alarmIntTime= [unitl timeSwitchTimeStamp:alarmTimeStr andFormatter:@"YYYY-MM-dd HH:mm:ss"];
                    self.timeRuler.indicatorCurrentTime = (int)alarmIntTime;
                }else{
                    //尺子初始化是默认展示在第一条数据上的位置
                    [self defaultTimeRulerPosition];
                }
                if (self.isFull) {//全屏
                    [self showTimeRulerWithFullScreen:YES];
                    self.timeRuler.backgroundColor = [UIColor colorWithWhite:0.93 alpha:0.8];
                }else{//竖屏
                    //竖屏不用做任何事
                }
                [self.timeRuler drawVideoBgViewWithArray:self.videoTimeModelArr];
                isQueryVideo = NO;
            }
                break;
            case JW_FAILD://能够有这个【视频信息失败】回调，代表，查询录像也是成功的。
            {
                self.isCanCut = NO;
                //[self dismissTimeRulerAndshowTip];
                [animationView dismiss];
                isQueryVideo = NO;
            }
                break;
            case JW_SUCCESS_SEARCH_VIDEO_LIST://代表【查询录像列表成功】回调，代表，视频播放肯定成功
            {
//                NSLog(@"后台拿到的时间数组:%@",recVideoTimeArr);
                [self.videoTimeModelArr removeAllObjects];
                if (isDefaultMode) {
                    [self.rulerModelArr removeAllObjects];
                    self.timeRuler.hidden = YES;
                    self.noTimeShaftRuler.hidden = YES;
                    int sumTime = 0;
                    for (int i = 0; i<recVideoTimeArr.count; i++) {
                        JWDeviceRecordFile *records = recVideoTimeArr[i];
//                        NSLog(@"开始时间:%d===与结束时间:%d",records.start_time,records.stop_time);
                        sumTime += records.stop_time - records.start_time;
                    }
                    
                    if (self.isFull) {
                        radio = sumTime*1.0/iPhoneHeight;
                    }else{
                        radio = sumTime*1.0/iPhoneWidth;
                    }
                    NSLog(@"比例:%f",radio);
                    
                    
                    float startSumLoc = 0.f;
                    
                    for (int i = 0; i<recVideoTimeArr.count; i++) {
                        JWDeviceRecordFile *records = recVideoTimeArr[i];
                        
                        NoTimeShaftRulerModel *model = [[NoTimeShaftRulerModel alloc]init];
                        model.startTimestamp = records.start_time;
                        model.endTimestamp = records.stop_time;
                        model.timeInterval = model.endTimestamp - model.startTimestamp;
                        model.startLoc = startSumLoc;
                        startSumLoc += model.timeInterval/radio;
                        model.endLoc = model.startLoc + model.timeInterval/radio;
                        
                        [self.rulerModelArr addObject:model];
                        
//                        NSLog(@"开始时间戳：%d    \n结束时间戳：%d\n时间差：%d\n起始位置：%f\n结束位置：%f",model.startTimestamp,model.endTimestamp,model.timeInterval,model.startLoc,model.endLoc);
                    }
                    
                    
                    NoTimeShaftRulerModel *model = self.rulerModelArr[0];
                    self.noTimeShaftRuler.timeLb.text = [unitl timeStampSwitchTime:model.startTimestamp andFormatter:@"HH:mm:ss" IsTenBit:YES];
                    
                    [animationView dismiss];
                    //================
                    self.noTimeShaftRuler.hidden = NO;
                    [self timestampTransformAxisDistance];
                    //================
                }else{
                    self.timeRuler.hidden = YES;
                    self.noTimeShaftRuler.hidden = YES;
                    for (int i = 0; i<recVideoTimeArr.count; i++) {
                        JWDeviceRecordFile *records = recVideoTimeArr[i];
                        ZCVideoTimeModel *model = [[ZCVideoTimeModel alloc]init];
                        //起点距离今日00分钟
                        CGFloat beginMin = (records.start_time - beginTimeInt);
                        //终点距离今日00分钟
                        CGFloat endMin = (records.stop_time - beginTimeInt);
//                        NSLog(@"拿到后台的划线的时间段区间：【%f,%f】不减当天凌晨0000的时间：start:%d  stop:%d  当天00时间：%d====名字是:%@",beginMin,endMin,records.start_time,records.stop_time,beginTimeInt,records.name);
                        model.name = records.name;
                        model.benginTime = beginMin;
                        model.endTime = endMin;
                        [self.videoTimeModelArr addObject:model];
                    }
                    ZCVideoTimeModel *model = [[ZCVideoTimeModel alloc]init];
                    model = (ZCVideoTimeModel *)[self.videoTimeModelArr lastObject];
                    NSInteger endSecond = model.endTime;
                    [unitl saveTimeRulerLastVideoTimeBySecond:endSecond];
                    [animationView dismiss];
                    //================
                    self.timeRuler.hidden = NO;
                    //================
                    
                    [self showTimeRulerWithFullScreen:NO];
                    if (self.timeMinStr) {
                        NSString *alarmTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,self.timeMinStr];
                        NSInteger alarmIntTime= [unitl timeSwitchTimeStamp:alarmTimeStr andFormatter:@"YYYY-MM-dd HH:mm:ss"];
                        self.timeRuler.indicatorCurrentTime = (int)alarmIntTime;
                    }else{
                    
                        //尺子初始化是默认展示在第一条数据上的位置
                        [self defaultTimeRulerPosition];
                        
                    }
                    if (self.isFull) {//全屏、大屏
                        [self showTimeRulerWithFullScreen:YES];
                        self.timeRuler.backgroundColor = [UIColor colorWithWhite:0.93 alpha:0.8];
                    }else{//竖屏
                        //竖屏不用做任何事
                    }
                    [self.timeRuler drawVideoBgViewWithArray:self.videoTimeModelArr];
                    
                }
                
                
                isQueryVideo = NO;
                
                
            }
                break;
            case JW_FAILD_SEARCH_VIDEO_LIST://代表【查询录像列表失败】回调，代表，视频播放肯定失败
            {
                self.isCanCut = NO;
                [self dismissTimeRulerAndshowTip];
                isQueryVideo = NO;
                [animationView dismiss];
            }
                break;
            case JW_PLAYBACK_NO_PERMISSION:
            {
                isQueryVideo = NO;
                [animationView dismiss];
                self.isCanCut = NO;
                [self dismissTimeRulerAndshowTip];
                [animationView dismiss];
                [XHToast showCenterWithText:NSLocalizedString(@"非分享时间段内无法观看", nil)];
            }
                break;
//            case JW_SEARCH_PLAYBACK_NO_PERMISSION:
//            {
//                isQueryVideo = NO;
//                [animationView dismiss];
//                self.isCanCut = NO;
//                [self dismissTimeRulerAndshowTip];
//                [animationView dismiss];
//                [XHToast showCenterWithText:@"非分享时间段内无法观看"];
//            }
//                break;
                
            default:
                break;
        }
    }];
}

#pragma mark - 相应按钮点击方法
#pragma mark - 播放【开始】按钮
- (IBAction)btnStartClick:(id)sender {
   
    UIButton *btn = self.btn_start;
    //获取播放状态
    BOOL isPlay = [self.videoManage JWPlayerManageGetPlayState];
    if (!isPlay && self.againPlay == NO && btn.selected == NO) {
        [self reloadTimePlay];//重写时间轴之后修改
        self.againPlay = NO;
        btn.selected = !btn.selected;
        NSLog(@"btnStopClick=========【重新播放】且self.videoManage的delegate:%@",self.videoManager.delegate);
        return;
    }
    if (isPlay && self.againPlay == NO && btn.selected == YES)
    {
        //[self.videoManage JWPlayerManageIsSuspendedPlay:YES];
        self.videoManage.isSuspend = YES;
        [self extracted];
        btn.selected = !btn.selected;
        NSLog(@"btnStopClick=========【暂停】");
        return;
    }
    
    //视频停止后点击播放
    if (self.againPlay == YES && btn.selected == NO && !isPlay) {
        isStop = NO;
        [self getRecordVideo:self.timeStr];
        self.againPlay = NO;
        NSLog(@"btnStopClick=========【停止后重新开始播放】");
    }
    
    
}

#pragma mark - 播放【停止】按钮
- (NSOperationQueue *)extracted {
    return [self.videoManage JWStreamPlayerManageEndRecPlayVideoWithCompletionBlock:^(JWErrorCode errorCode) {
        if (errorCode == JW_SUCCESS) {
            NSLog(@"停止按钮，关闭播放接口成功");
            NSLog(@"停止的时间在：%@",self.centerTimeView.btn_time.titleLabel.text);

        }else{
            NSLog(@"停止按钮，关闭播放接口失败");
        }
    }];
}

- (IBAction)btnStopClick:(id)sender {
    isStop = YES;
    self.timeMinStr = nil;//点击停止按钮后，该属性将重置
    
    NSLog(@"btnStopClick=========停止了");
    //[[HDNetworking sharedHDNetworking]canleAllHttp];
    //重新播放状态
    self.againPlay = YES;
    
    //如果正在录像就停止录制
    [self judgeIsRecord];
    
    //截取正在播放的视频保存到沙盒
    if (self.isCanCut) {
        [self backCutImage];
    }
    
    //停止回放视频
    self.videoManage.isSuspend = NO;
    tempTimeStr = nil;
    [self extracted];
    [self.videoManage JWPlayerManageSetAudioIsOpen:NO];
    self.btn_start.selected = NO;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    [self.centerTimeView.btn_time setTitle:currentTime forState:UIControlStateNormal];
    
    if (isDefaultMode) {
        self.noTimeShaftRuler.hidden = YES;
    }else{
        [self dismissTimeRulerAndshowTip];//暂停就不让时间轴消失
    }
    
    
}

- (void)stopCurrentVideo
{
    self.videoManage.isSuspend = NO;
    [self extracted];
    //[self.videoManage JWPlayerManageIsSuspendedPlay:YES];
    NSLog(@"btnStopClick=========【暂停】了22");
}

- (void)stopReceiveRefreshTimeNoti
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:RETURNTIMESTAMP_TIMERULER object:nil];
}

#pragma mark - 声音【开启关闭】按钮
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

#pragma mark -【倍速切换】按钮
//倍速切换
- (IBAction)btnRatioClick:(id)sender
{
    self.slider.hidden = NO;
    
    if (self.isFull == YES) {
        self.slider.frame = CGRectMake((iPhoneHeight - 0.9*iPhoneWidth)/2, iPhoneWidth -44-44, 0.9*iPhoneWidth, 44);
    }else{
        self.slider.frame = CGRectMake(0.05*iPhoneWidth, iPhoneWidth/375*244-44-44, 0.9*iPhoneWidth, 44);
    }
    
    __block OnlyPlayBackVC *blockSelf = self;
    _slider.block=^(int index){
        NSLog(@"现在滑到的是第%d个",index+1);//index表示第几个(实际情况需+1)
        [blockSelf downOutViewSelectRowAtIndex:index];
    };
    /*
    return;
    NSLog(@"btnHdClick=========开始了");
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    self.isHd = btn.selected;
    self.againPlay = NO;
    
    //进度条时间View隐藏
    [self dismissTimeRuler];
     */
}
#pragma mark - 全屏按钮
//全屏
- (IBAction)btnFullClick:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    
    if (self.isFull == NO) {
        [self.btn_full setImage:[UIImage imageNamed:@"zoomScreen"] forState:UIControlStateNormal];
        [self rightHengpinAction];
    }
    else{
        [self.btn_full setImage:[UIImage imageNamed:@"全屏_h"] forState:UIControlStateNormal];
        [self shupinAction];
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - 截图和录像功能
//截图 testDemo
- (IBAction)btnCamClick:(id)sender {
    BOOL isplay = [self.videoManage JWPlayerManageGetPlayState];
    if (isplay == YES) {
        //播放截图音效
        [self playSoundEffect:@"capture.caf"];
        UIImage *ima = [self snapshot:self.playView];
        [XHToast showBottomWithText:NSLocalizedString(@"已保存截图到我的文件", nil)];
        [self createShortcutPicToFilebIsVideo:NO shortCutImage:ima];
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
}

//录像 testDemo
- (IBAction)btnVideoClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    BOOL isplay = [self.videoManage JWPlayerManageGetPlayState];
    if (isplay == NO &&!self.isRecord) {
        [XHToast showBottomWithText:NSLocalizedString(@"视频未播放", nil)];
        return;
    }
    NSInteger SpeedValue = [[unitl getDataWithKey:@"SpeedValue"] integerValue];
    if (SpeedValue != 1) {
        [XHToast showCenterWithText:NSLocalizedString(@"暂不支持多倍速视频录制", nil)];
    }else
    {
        //播放录音音效
        [self playSoundEffect:@"record.caf"];
        
        if (!self.isRecord) {
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
                [self.videoManage JWPlayerManageStartRecordWithPath:filePath];
                UIImage *ima = [self snapshot:self.playView];
                [self saveFileModel:ima andPath:[NSString stringWithFormat:@"%@.mp4",modelfileName]andType:0];
            }
            self.isRecord = YES;
        }else{
            UIImage *ima = [self snapshot:self.playView];
            [self createShortcutPicToFilebIsVideo:YES shortCutImage:ima];
            [XHToast showBottomWithText:NSLocalizedString(@"视频录制成功，已保存到我的文件", nil)];
            self.redDotView.hidden = YES;
            btn.selected = NO;
            [self.videoManage JWPlayerManageStopRecord];
            self.isRecord = NO;
        }
    }
}

#pragma mark - 截图则在右下角出现的缩略图，可以点击进入相应的文件列表
- (void)createShortcutPicToFilebIsVideo:(BOOL)isVideo shortCutImage:(UIImage *)image
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
    CGFloat videoHeight = CGRectGetHeight(self.VideoViewBank.frame);
    CGFloat videoWidth = CGRectGetWidth(self.VideoViewBank.frame);
    
    [self.cutImage setImage:image];
    
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.VideoViewBank).offset(10);
        make.bottom.mas_equalTo(self.VideoViewBank.mas_bottom).offset(-54);
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
        [self.VideoViewBank addSubview:_bgView];
        CGFloat videoHeight = CGRectGetHeight(self.VideoViewBank.frame);
        CGFloat videoWidth = CGRectGetWidth(self.VideoViewBank.frame);
        [_bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.VideoViewBank);
            make.bottom.mas_equalTo(self.VideoViewBank);
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

#pragma mark - 使得截图快速进入文件夹，3秒消失
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
    self.navigationController.view.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    FileVC *fileVC = [[FileVC alloc]init];
    [self.navigationController pushViewController:fileVC animated:YES];
}

- (void)createAlertController
{
    NSArray *arr=@[@"1/8X",@"1/4X",@"1/2X",@"1X",@"2X",@"4X",@"8X"];
    //每个cell的高度
    float cellheight = 44;
    //headView(标题view的高度)
    float headTitleHeight = 88;
    if(self.isFull){
        customAlertView *customV = [[customAlertView alloc]initWithDataArr:arr origin:CGPointMake(iPhoneHeight/2, 20) width:0.75*iPhoneWidth Singleheight:cellheight title:NSLocalizedString(@"调节播放速度", nil) message:NSLocalizedString(@"请设置倍率", nil) isRolling:YES headTitleHeight:headTitleHeight];
        customV.delegate=self;
        float arch = M_PI_2;
        //对navigationController.view 进行强制旋转
        customV.transform = CGAffineTransformMakeRotation(arch);
        customV.bounds = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
        [customV customAlertViewShow];
    }else{
        customAlertView *customV = [[customAlertView alloc]initWithDataArr:arr origin:CGPointMake(iPhoneWidth/2, (iPhoneHeight-cellheight*7-headTitleHeight)/2) width:0.7*iPhoneWidth Singleheight:cellheight title:NSLocalizedString(@"调节播放速度", nil) message:NSLocalizedString(@"请设置倍率", nil) isRolling:NO headTitleHeight:headTitleHeight];
        customV.delegate=self;
        [customV customAlertViewShow];
    }
}

#pragma mark - customAlertViewDelegate(警告框代理协议)
- (void)downOutViewSelectRowAtIndex:(NSInteger)index
{
    if(index==0){
        [self.btn_hd setImage:[UIImage imageNamed:@"18X_h"] forState:UIControlStateNormal];
        [self postChangePlaySpeed:0.125];
    }
    if(index==1){
        [self.btn_hd setImage:[UIImage imageNamed:@"14X_h"] forState:UIControlStateNormal];
        [self postChangePlaySpeed:0.25];
    }
    if(index==2){
        [self.btn_hd setImage:[UIImage imageNamed:@"12X_h"] forState:UIControlStateNormal];
        [self postChangePlaySpeed:0.5];
    }
    if(index==3){
        [self.btn_hd setImage:[UIImage imageNamed:@"倍速1x_h"] forState:UIControlStateNormal];
        [self postChangePlaySpeed:1];
    }
    if(index==4){
        [self.btn_hd setImage:[UIImage imageNamed:@"2XX_h"] forState:UIControlStateNormal];
        [self postChangePlaySpeed:2];
    }
    if(index==5){
        [self.btn_hd setImage:[UIImage imageNamed:@"4XX_h"] forState:UIControlStateNormal];
        [self postChangePlaySpeed:4];
    }
    if(index==6){
        [self.btn_hd setImage:[UIImage imageNamed:@"8XX_h"] forState:UIControlStateNormal];
        [self postChangePlaySpeed:8];
    }
    
    self.slider.hidden = YES;
}

#pragma - 切换录像回放倍数方法
- (void)postChangePlaySpeed:(float)SpeedValue
{
    //如果正在录像就停止录制
    [self judgeIsRecord];
    //截取正在播放的视频保存到沙盒
    if (self.isCanCut) {
        [self backCutImage];
    }
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
    if (monitor_id) {
         [postDic setObject:monitor_id forKey:@"monitor_id"];
    }
    [postDic setObject:cmd forKey:@"cmd"];
    [postDic setObject:action forKey:@"action"];
    [postDic setObject:param forKey:@"param"];
    //先确认保证通道model是否有
    if ([MultiChannelDefaults getChannelModel]) {
        MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
        NSLog(@"我传过来的chanCode111:%@",model.chanCode);
        [postDic setObject:model.chanCode forKey:@"chan_code"];
    }
   // NSLog(@"变速播放参数：access_token:%@ === user_id:%@ == monitor_id:%@ === cmd:%@ == action:%@ == param:%@",access_token,user_id,monitor_id,cmd,action,param);
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/playback_ctrl" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        // NSLog(@"变速播放请求 ret:%d===responseObject:%@",ret,responseObject);
        
        if (ret == 0 ) {
            NSLog(@"变速播放请求成功了。");
            [self.videoManager changePlayVideoFrequencyMultiple:(NSInteger)SpeedValue];
            //completionBlock(JW_SUCCESS);
        }else{
           // completionBlock(JW_FAILD);
        }
    } failure:^(NSError * _Nonnull error) {
       // [XHToast showCenterWithText:@"切换倍率失败，请检查您的网络"];
    }];
}

#pragma mark - 播放提示声
/*
void soundCompleteCalllback(SystemSoundID soundID, void *clientData){
    NSLog(@"播放完成...");
}*/
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

/**
 *  播放完成回调函数
 *
 *  @param soundID    系统声音ID
 *  @param clientData 回调时传递的数据
 */

#pragma mark - 推出时截取图片
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

- (NSString *)getDateYearMonth
{
    NSDate *newDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:newDate];
    NSInteger year = [dateComponent year];
    NSInteger month = [dateComponent month];
    return [NSString stringWithFormat:@"%ld%02ld",(long)year,(long)month];
}

#pragma mark - 点击事件选择器
- (void)DateSelectionClick:(UIButton*)dateBtn isCenter:(BOOL)isCenter
{
    //isCenter是无用的参数
    if (isQueryVideo == NO) {
        WeakSelf(self);
        __weak typeof(dateBtn) weakBtn = dateBtn;
        SZCalendarPicker *calendarPicker = [SZCalendarPicker showOnView:weakSelf.view.superview];
        calendarPicker.isDeviceVideo = self.isDeviceVideo;
        
        calendarPicker.dev_ID = self.listModel.ID;
        calendarPicker.today = [NSDate date];
        calendarPicker.date = calendarPicker.today;
        
        CGFloat bili = (CGFloat)(375.0000/244.000);
        CGFloat h  = (CGFloat)iPhoneWidth/bili+64;
        [self.videoManage JWStreamPlayerManageEndRecPlayVideoWithCompletionBlock:^(JWErrorCode errorCode) {
            if (errorCode == JW_SUCCESS)
            {
                NSLog(@"日期选择器，选中，【关闭】之前的播放视频【成功】");
            }else
            {
              NSLog(@"日期选择器，选中，【关闭】之前的播放视频【失败】");
            }
        }];
        [self.videoManage JWPlayerManageSetAudioIsOpen:NO];
        calendarPicker.frame = CGRectMake(0, h, self.view.frame.size.width, self.view.superview.bounds.size.height-h);
        calendarPicker.calendarBlock = ^(NSInteger day, NSInteger month, NSInteger year){
            [weakBtn setTitle:[NSString stringWithFormat:@"%li-%li-%li", (long)year,(long)month,(long)day] forState:UIControlStateNormal];
            [weakSelf CenterTimeViewCenterBtnClick:isCenter TimeStr:[NSString stringWithFormat:@"%li-%li-%li", (long)year,(long)month,(long)day]];
            [weakSelf queryAlarmMessageFromServerWithDateStr:[NSString stringWithFormat:@"%li-%li-%li", (long)year,(long)month,(long)day]];
            self.currentDateTimeStr = [NSString stringWithFormat:@"%li-%li-%li", (long)year,(long)month,(long)day];
            //NSLog(@"当前日期选择器选择后的时间是：%@",self.currentDateTimeStr);
            [weakSelf searchVideoAndshowTimeRulerWithDateStr:[NSString stringWithFormat:@"%li-%li-%li", (long)year,(long)month,(long)day]];
            [_arrayM removeAllObjects];//重新选择时间后需重新拉取数据
        };
    }else{
        [XHToast showBottomWithText:NSLocalizedString(@"正在查询中，请稍候再试", nil)];
    }
}


#pragma mark - centerTimeViewDelegate
- (void)CenterTimeViewCenterBtnClick:(BOOL)isCenter TimeStr:(NSString *)timeStr
{
    [self dismissTimeRuler];
    self.timeStr = timeStr;
//    [self getRecordVideo:self.timeStr];
}

#pragma mark - 云端录像
- (void)CenterTimeViewLeftBtnClick:(BOOL)isCenter TimeStr:(NSString *)timeStr
{
    [self dismissTimeRuler];
    self.timeStr = timeStr;
   // [self getRecordVideo:self.timeStr];
}

#pragma mark - 设备录像
-(void)CenterTimeViewRightBtnClick:(BOOL)isCenter TimeStr:(NSString *)timeStr
{
    [self dismissTimeRuler];
    self.timeStr = timeStr;
   // [self getRecordVideo:self.timeStr];
}

#pragma mark - 软解代理
- (void)setUpImage:(UIImage *)newImage
{
    
}

#pragma mark - 硬解代理
- (void)setUpBuffer:(CVPixelBufferRef)buffer
{
//    if(buffer && !self.videoManage.isStop)
//    {
//        self.isCanCut = YES;
//        CGSize playViewSize = self.playView.bounds.size;
//        [self.playView.openView displayPixelBuffer:buffer playViewSize:playViewSize];
//
//    }
}

#pragma mark - 保存录像代理
- (void)stopRecordBlockFunc
{
    //取消保存到相册功能
}

#pragma mark - bottomview delegate
-(void)rockerDidChangeDirection:(ZMRocker *)rocker{
    //    up down left right   1-2-3-4   center-0
    switch (rocker.direction) {
        case 1: [self ControlFunc:1];
            break;
        case 2: [self ControlFunc:2];
            break;
        case 3: [self ControlFunc:3];
            break;
        case 4: [self ControlFunc:4];
            break;
        case 0: [self controlStop];
            break;
        default:
            break;
    }
}

#pragma makr - 云台代理方法
- (void)ControlFunc:(NSInteger)control_num
{
    NSNumber * cmd_num = [NSNumber numberWithInteger:control_num];
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

#pragma mark - 进度条代理
#pragma mark - 拉动时间轴，触发播放方法
//刷新播放时间
- (void)reloadTimePlay
{
    BOOL isPlay = [self.videoManage JWPlayerManageGetPlayState];
    if (isPlay) {
        [self setLoadingView];
        NSString *beginTimeStr = [NSString stringWithFormat:@"%@ %@",self.timeStr,self.timeMinStr];
        //NSLog(@"TimeStr:%@====MinStr:%@",self.timeStr,self.timeMinStr);
        NSInteger beginStamp = [unitl timeSwitchTimeStamp:beginTimeStr andFormatter:@"YYYY-MM-dd HH:mm:ss"];
        NSLog(@"传给后台让去播放的时间是：%@ == self.timeStr:%@ === self.timeMinStr:%@",beginTimeStr,self.timeStr,self.timeMinStr);
        
        [self requestWithAdvanceOrRetreatUTCTime:beginStamp Advance:NO isPOS:YES Recognizer:nil];
    }else
    {
        [self setLoadingView];
        NSLog(@"【调试】滑动时间轴");
        [SXLReachability SXL_hasNetwork:^(ReachabilityStatus netStatus) {
            if (netStatus == ReachabilityStatusReachableViaWWAN) {
                if (self.firstRememder) {
                    [Toast showInfo:netWorkReminder];
                    self.firstRememder = NO;
                }
            }
        }];
        self.failVideoBtn.hidden = YES;
        [self judgeIsRecord]; //如果正在录像就停止录制
        //停止回放视频
        if (self.bIsAP) {
            //20180517T081953Z
            //时间戳
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYY-MM-dd"];
            //    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            NSDate *date = [formatter dateFromString:self.timeStr];
            NSString *tempBeginTimeString = [formatter stringFromDate:date];
            
            NSString *tempStartTimeStr =[NSString stringWithFormat:@"%@T%@Z",tempBeginTimeString,self.timeMinStr];
            NSString *tempBeginTimeStr =[NSString stringWithFormat:@"%@T%@Z",tempBeginTimeString,@"235959"];
            
            NSString *tempstartTimeStr = [tempStartTimeStr stringByReplacingOccurrencesOfString:@":" withString:@""];
            NSString *StartTimeStr = [tempstartTimeStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            NSString *endTimeStr = [tempBeginTimeStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            [self.videoManage JWPlayerManageBeginPlay_AP_RecVideoWithStartTime:StartTimeStr endTime:endTimeStr completionBlock:^(JWErrorCode errorCode) {
                if (errorCode == JW_SUCCESS) {
                    self.btn_start.selected = YES;
                    self.btn_hd.selected = NO;
                    [self.btn_hd setImage:[UIImage imageNamed:@"倍速1x_h"] forState:UIControlStateNormal];
                    NSLog(@"回放成功了-ap");
                }if (errorCode == JW_FAILD) {
                    [XHToast showTopWithText:NSLocalizedString(@"获取录像失败", nil) topOffset:160];
                    [animationView dismiss];
                    self.isCanCut = NO;
                    NSLog(@"回放失败了-ap");
                }
            }];
        }else{//不是ap模式下
            NSLog(@"reloadTimePlay停止回放视频 成功");
            //时间戳
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
            //调整时间
//            NSString *beginTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,self.timeMinStr];
           // NSDate *date = [formatter dateFromString:beginTimeStr];
            //今日235959
            NSString *endTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,@"23:59:59"];
            NSDate *endDate = [formatter dateFromString:endTimeStr];
            
            NSString *startTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,@"00:00:01"];
            NSDate *startDate = [formatter dateFromString:startTimeStr];
            NSLog(@"【调试】滑动时间轴，得到播放的【开始】时间是：%@===【结束】时间:%@",startTimeStr,endTimeStr);
            
            JWRecVideoTypeStatus videoType;
            if (self.isDeviceVideo == NO)//是云端录像
            {
                videoType = JWRecVideoTypeStatusCenter;
            }
            else//是设备录像
            {
                videoType = JWRecVideoTypeStatusLeading;
            }
            [self.videoManage JWStreamPlayerManageBeginPlayRecVideoWithVideoType:videoType startTime:startDate endTime:endDate BIsEncrypt:_bIsEncrypt Key:_key completionBlock:^(JWErrorCode errorCode) {
                if (errorCode == JW_SUCCESS) {
                    //注意：这里不是逻辑错误。
                    
                    NSString *beginTimeStr;
                    
                    if (tempTimeStr) {
                        tempTimeStr = self.centerTimeView.btn_time.titleLabel.text;
                        beginTimeStr = tempTimeStr;
                        
                    }else{
                        beginTimeStr = [NSString stringWithFormat:@"%@ %@",self.timeStr,self.timeMinStr];
                        tempTimeStr = beginTimeStr;
                    }
                    
                    NSLog(@"LB:%@=====%@",self.centerTimeView.btn_time.titleLabel.text,tempTimeStr); NSLog(@"【调试】滑动时间轴，得到播放的【开始】:%@===%@",beginTimeStr,self.videoManager.delegate);
                    
                    
                    NSInteger beginStamp = [unitl timeSwitchTimeStamp:beginTimeStr andFormatter:@"YYYY-MM-dd HH:mm:ss"];
                    [self requestWithAdvanceOrRetreatUTCTime:beginStamp Advance:NO isPOS:YES Recognizer:nil];
                    self.btn_start.selected = YES;
                    self.btn_hd.selected = NO;
                    NSLog(@"回放成功了【云端】");
                }if (errorCode == JW_FAILD) {
                    self.isCanCut = NO;
                    NSLog(@"回放失败了【云端】");
                }
                if (errorCode == JW_PLAYBACK_NO_PERMISSION) {//录像回放无权限
                    self.isCanCut = NO;
                    [XHToast showCenterWithText:NSLocalizedString(@"非分享时间段内无法观看", nil)];
                }
            }];
        }
    }
}

- (void)reloadTimePlay_didSelectedTimeStr:(NSString *)timeStr TimeMinStr:(NSString *)timeMinStr
{
    BOOL isPlay = [self.videoManage JWPlayerManageGetPlayState];
    if (isPlay) {
        NSString *beginTimeStr =[NSString stringWithFormat:@"%@ %@",timeStr,timeMinStr];
        NSInteger beginStamp = [unitl timeSwitchTimeStamp:beginTimeStr andFormatter:@"YYYY-MM-dd HH:mm:ss"];
        [self requestWithAdvanceOrRetreatUTCTime:beginStamp Advance:NO isPOS:YES Recognizer:nil];
    }else
    {
        [self setLoadingView];
        NSLog(@"【调试】滑动时间轴");
        [SXLReachability SXL_hasNetwork:^(ReachabilityStatus netStatus) {
            if (netStatus == ReachabilityStatusReachableViaWWAN) {
                if (self.firstRememder) {
                    [Toast showInfo:netWorkReminder];
                    self.firstRememder = NO;
                }
            }
        }];
        self.failVideoBtn.hidden = YES;
        [self judgeIsRecord];//如果正在录像就停止录制
        //停止回放视频
        if (self.bIsAP) {
            //20180517T081953Z
            //时间戳
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYY-MM-dd"];
            //    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            NSDate *date = [formatter dateFromString:timeStr];
            NSString *tempBeginTimeString = [formatter stringFromDate:date];
            
            NSString *tempStartTimeStr =[NSString stringWithFormat:@"%@T%@Z",tempBeginTimeString,timeMinStr];
            NSString *tempBeginTimeStr =[NSString stringWithFormat:@"%@T%@Z",tempBeginTimeString,@"235959"];
            
            NSString *tempstartTimeStr = [tempStartTimeStr stringByReplacingOccurrencesOfString:@":" withString:@""];
            NSString *StartTimeStr = [tempstartTimeStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            NSString *endTimeStr = [tempBeginTimeStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            [self.videoManage JWPlayerManageBeginPlay_AP_RecVideoWithStartTime:StartTimeStr endTime:endTimeStr completionBlock:^(JWErrorCode errorCode) {
                if (errorCode == JW_SUCCESS) {
                    self.btn_start.selected = YES;
                    self.btn_hd.selected = NO;
                    [self.btn_hd setImage:[UIImage imageNamed:@"倍速1x_h"] forState:UIControlStateNormal];
                    NSLog(@"回放成功了-ap");
                }if (errorCode == JW_FAILD) {
                    [XHToast showTopWithText:NSLocalizedString(@"获取录像失败", nil) topOffset:160];
                    [animationView dismiss];
                    self.isCanCut = NO;
                    NSLog(@"回放失败了-ap");
                }
            }];
        }else{//不是ap模式下
            NSLog(@"reloadTimePlay停止回放视频 成功");
            //时间戳
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
//            //调整时间
//            NSString *beginTimeStr =[NSString stringWithFormat:@"%@ %@",timeStr,timeMinStr];
//            NSDate *date = [formatter dateFromString:beginTimeStr];
            //今日235959
            NSString *endTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,@"23:59:59"];
            NSDate *endDate = [formatter dateFromString:endTimeStr];
            
            NSString *startTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,@"00:00:01"];
            NSDate *startDate = [formatter dateFromString:startTimeStr];
            NSLog(@"【调试】滑动时间轴，得到播放的【开始】时间是：%@===【结束】时间:%@",startTimeStr,endTimeStr);

            JWRecVideoTypeStatus VideoType;
            if (self.isDeviceVideo == NO) {//是云端录像
                VideoType = JWRecVideoTypeStatusCenter;
            }else//是设备录像
            {
                VideoType = JWRecVideoTypeStatusLeading;
            }
            [self.videoManage JWStreamPlayerManageBeginPlayRecVideoWithVideoType:VideoType startTime:startDate endTime:endDate BIsEncrypt:_bIsEncrypt Key:_key completionBlock:^(JWErrorCode errorCode) {
                
                if (errorCode == JW_SUCCESS) {
                    //注意：这里不是逻辑错误。
                    NSString *beginTimeStr =[NSString stringWithFormat:@"%@ %@",timeStr,timeMinStr];
                    NSInteger beginStamp = [unitl timeSwitchTimeStamp:beginTimeStr andFormatter:@"YYYY-MM-dd HH:mm:ss"];
                    [self requestWithAdvanceOrRetreatUTCTime:beginStamp Advance:NO isPOS:YES Recognizer:nil];
                    
                    self.btn_start.selected = YES;
                    self.btn_hd.selected = NO;
                    NSLog(@"回放成功了【云端/设备】");
                }if (errorCode == JW_FAILD) {
                        self.isCanCut = NO;
                        NSLog(@"回放失败了【云端/设备】");
                }
                if (errorCode == JW_PLAYBACK_NO_PERMISSION) {//录像回放无权限
                    self.isCanCut = NO;
                    [XHToast showCenterWithText:NSLocalizedString(@"非分享时间段内无法观看", nil)];
                }
            }];
        }
    }
}

#pragma 使用流量播放提醒
- (void)netWorkAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"您确定使用移动流量观看视频？", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self reloadTimePlay];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 时间轴的【消失】与【出现】系列方法
//时间轴【消失】
- (void)dismissTimeRuler
{
    [self.timeRuler removeFromSuperview];
    self.timeRuler = nil;
    isTimeRulerShow = NO;
}

// 时间轴【消失】提示或提示图展现以及动画
- (void)dismissTimeRulerAndshowTip
{
    [self dismissTimeRuler];//时间轴消失
    self.noImageView.hidden = NO;//提示图出现
}

//时间轴【出现】==== 尺子添加的位置(有时间轴)
- (void)showTimeRulerWithFullScreen:(BOOL)fullScreen
{
    if (fullScreen) {
        [self.VideoViewBank addSubview:self.timeRuler];
        CGFloat timeRulerHeight = iPhone_X_TO_Xs ? iPhoneWidth - 44 - 80 + 10 :iPhoneWidth - 44 - 80;
        self.timeRuler.frame = CGRectMake(0, timeRulerHeight,  [UIScreen mainScreen].bounds.size.height, 70);
    }else
    {
        [self.centerTimeView addSubview:self.timeRuler];
    }
    isTimeRulerShow = YES;
}

//时间轴【出现】==== 尺子添加的位置(无时间轴)
- (void)shownoTimeShaftRulerWithFullScreen:(BOOL)fullScreen
{
    if (fullScreen) {
        [self.VideoViewBank addSubview:self.noTimeShaftRuler];
        CGFloat timeRulerHeight = iPhone_X_TO_Xs ? iPhoneWidth - 44 - 80 + 10 :iPhoneWidth - 44 - 80;
        self.noTimeShaftRuler.frame = CGRectMake(0, timeRulerHeight,  [UIScreen mainScreen].bounds.size.height, 70);
        self.noTimeShaftRuler.backgroundColor = [UIColor colorWithWhite:0.93 alpha:0.8];
        [self.noTimeShaftRuler fullScreenSettingScrollView:YES];
        
    }else{
        self.noTimeShaftRuler.hidden = NO;
        float height;
        if (iPhoneWidth == 320) height = 45;
        else if (iPhoneWidth == 375) height = 50;
        else height = 50;
        self.noTimeShaftRuler.frame = CGRectMake(0, height, iPhoneWidth, 70);
        [self.centerTimeView addSubview:self.noTimeShaftRuler];
        self.noTimeShaftRuler.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        [self.noTimeShaftRuler fullScreenSettingScrollView:NO];
    }
    isTimeRulerShow = YES;
}

//时间轴【出现】提示或提示图消失以及动画
- (void)showTimeRulerAndDismissTip
{
    
}

#pragma mark - ScrollerViewDelegate 滑动代理
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

#pragma mark - 判断当前是否录制
- (void)judgeIsRecord
{
    if (self.isRecord) {
        [self btnVideoClick:self.btn_video];
    }
}

#pragma mark ==================== 【手势操作】
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

//点击手势
- (void)selectZhuangtai{
    if (_isAppear) {
        [self videoViewBackanimation];
        _isAppear = 0;
        
    }else{
        [self videoViewBackHidden];
        _isAppear = 1;
    }
}

#pragma mark - 点击按钮背景渐变效果
- (void)videoViewBackanimation
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.btn_back.alpha = 1;
        self.onlyPlayBackBtn.alpha = 1;
        if (self.isFull) {
            if (isDefaultMode) {
                self.noTimeShaftRuler.alpha = 1;
            }else{
                self.timeRuler.alpha = 1;
            }
            
        }
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
        self.slider.hidden = YES;
        self.btn_back.alpha = 0;
        self.onlyPlayBackBtn.alpha = 0;
        if (self.isFull) {
            if (isDefaultMode) {
                self.noTimeShaftRuler.alpha = 0;
            }else{
                self.timeRuler.alpha = 0;
            }
        }
        _isAppear = 1;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }];
}

#pragma mark -【左滑】【右滑】手势
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer.enabled) {
        recognizer.enabled = NO;
        NSString * nowTimeTimeStampStr = self.refreshTimeStemp;
        int64_t nowTimeStamp = [nowTimeTimeStampStr intValue];
        if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
            //NSLog(@"在视频上向【左】滑动，视频后退10s！");
            int64_t utcTime = nowTimeStamp - POSSTEP;
            [self requestWithAdvanceOrRetreatUTCTime:utcTime Advance:NO isPOS:NO Recognizer:recognizer];
        }
        if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
            //NSLog(@"在视频上向【右】滑动，视频前进10s！");
            int64_t utcTime = nowTimeStamp + POSSTEP;
            [self requestWithAdvanceOrRetreatUTCTime:utcTime Advance:YES isPOS:NO Recognizer:recognizer];
        }
    }
}

//向后或者向前跳10s的接口
- (void)requestWithAdvanceOrRetreatUTCTime:(int64_t)utcTime Advance:(BOOL)advance isPOS:(BOOL)pos Recognizer:(UISwipeGestureRecognizer *)recognizer
{
    NSLog(@"传给后台的utcTime:%lld",utcTime);
    //如果正在录像就停止录制
    [self judgeIsRecord];
    //截取正在播放的视频保存到沙盒
    if (self.isCanCut) {
        [self backCutImage];
    }
    NSString * access_token = [unitl get_accessToken];
    NSString * user_id = [unitl get_User_id];
    NSString * monitor_id;
    NSNumber * cmd          = [NSNumber numberWithInt:0];
    NSString * action       = @"POS";
    NSString * param        = [NSString stringWithFormat:@"%lld",utcTime];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"monitor_id"]) {
        monitor_id = [[NSUserDefaults standardUserDefaults]objectForKey:@"monitor_id"];
    }
    NSMutableDictionary * postDic = [NSMutableDictionary dictionary];
    [postDic setObject:access_token forKey:@"access_token"];

    [postDic setObject:user_id forKey:@"user_id"];
    if (monitor_id) {
        [postDic setObject:monitor_id forKey:@"monitor_id"];
    }
    
    [postDic setObject:cmd forKey:@"cmd"];
    [postDic setObject:action forKey:@"action"];
    [postDic setObject:param forKey:@"param"];
    //先确认保证通道model是否有
    if ([MultiChannelDefaults getChannelModel]) {
        MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
        NSLog(@"我传过来的chanCode222:%@",model.chanCode);
        [postDic setObject:model.chanCode forKey:@"chan_code"];
    }
    
     NSLog(@"时间轴滑动 / 前或后跳10s 播放参数：access_token:%@ === user_id:%@ == monitor_id:%@ === cmd:%@ == action:%@ == param:%@",access_token,user_id,monitor_id,cmd,action,param);
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/playback_ctrl" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        recognizer.enabled = YES;
        if (ret == 0 ) {
            if (pos) {//时间轴定位调用
                NSLog(@"时间轴定位成功~！");
//                [self.videoManage JWPlayerManageEmptyVideoDataCompletionBlock:^(JWErrorCode errorCode) {
//                    if (errorCode == JW_SUCCESS) {
//                        NSLog(@"pos定位后，清空视频缓存【成功】");
//                    }else{
//                         NSLog(@"pos定位后，清空视频缓存【失败】");
//                    }
//                }];
                [self cannelLodingView];
            }else//手势，前进、后退 10秒
            {
                if (advance) {//前进
                    if (self.isFull) [XHToast showCenterWithText:NSLocalizedString(@"▶▶ 前进10s", nil) duration:0.5f];
                    else [XHToast showTopWithText:NSLocalizedString(@"▶▶ 前进10s", nil) duration:0.5f];
                    NSLog(@"视频【前进】10s，成功了。");
                }else//后退
                {
                    if (self.isFull) [XHToast showCenterWithText:NSLocalizedString(@"◀◀ 后退10s", nil) duration:0.5f];
                    else [XHToast showTopWithText:NSLocalizedString(@"◀◀ 后退10s", nil) duration:0.5f];
                    NSLog(@"视频【后退】10s，成功了。");
                }
            }
        }else{//ret == -1
             NSLog(@"视频【前进、后退】10s失败，ret == -1");
        }
    } failure:^(NSError * _Nonnull error) {
        [XHToast showCenterWithText:NSLocalizedString(@"请求失败，请检查您的网络", nil)];
        recognizer.enabled = YES;
    }];
}


#pragma mark -横竖屏坐标事件
//竖屏
-(void)shupinAction
{
    self.slider.hidden = YES;
    self.onlyPlayBackBtn.hidden = YES;
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    
    self.isFull = NO;
    [UIView animateWithDuration:0.25 animations:^{
        
        //竖屏时标尺恢复
        [self dismissTimeRuler];
        
        if (isStop == NO) {
            
            if (isDefaultMode) {
                [self autoSearchAndPlayVideoIsDeviceVideo:self.isDeviceVideo TimeStr:self.timeStr];
                [self shownoTimeShaftRulerWithFullScreen:NO];
            }else{
                
                [self showTimeRulerWithFullScreen:NO];
                if (self.timeMinStr) {
                    NSString *alarmTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,self.timeMinStr];
                    NSInteger alarmIntTime= [unitl timeSwitchTimeStamp:alarmTimeStr andFormatter:@"YYYY-MM-dd HH:mm:ss"];
                    self.timeRuler.indicatorCurrentTime = (int)alarmIntTime;
                }else{
                    //尺子初始化是默认展示在第一条数据上的位置
                    [self defaultTimeRulerPosition];
                }
                [self.timeRuler drawVideoBgViewWithArray:self.videoTimeModelArr];
            }
            
        }
        
        CGFloat tempWidth = iPhoneWidth;
        CGFloat bili = 268.33/414;
        CGFloat videoViewBankWidth = tempWidth * bili;
        [self.VideoViewBank mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.right.mas_equalTo(self.view);
            make.height.mas_equalTo(videoViewBankWidth);
        }];
        float arch = 0;
        //对navigationController.view 进行强制旋转
        self.navigationController.view.transform = CGAffineTransformMakeRotation(arch);
        self.navigationController.view.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
}

//横屏
-(void)rightHengpinAction
{
    self.slider.hidden = YES;
    self.isFull = YES;
    self.onlyPlayBackBtn.hidden = NO;
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [UIView animateWithDuration:0.25 animations:^{
        if (isStop == NO) {
            
            
            if (isDefaultMode) {
                [self autoSearchAndPlayVideoIsDeviceVideo:self.isDeviceVideo TimeStr:self.timeStr];
                [self shownoTimeShaftRulerWithFullScreen:YES];
            }else{
                [self showTimeRulerWithFullScreen:YES];
                if (self.timeMinStr) {
                    NSString *alarmTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,self.timeMinStr];
                    NSInteger alarmIntTime= [unitl timeSwitchTimeStamp:alarmTimeStr andFormatter:@"YYYY-MM-dd HH:mm:ss"];
                    self.timeRuler.indicatorCurrentTime = (int)alarmIntTime;
                }else{
                    //尺子初始化是默认展示在第一条数据上的位置
                    [self defaultTimeRulerPosition];
                }
                
                [self.timeRuler drawVideoBgViewWithArray:self.videoTimeModelArr];
                self.timeRuler.backgroundColor = [UIColor colorWithWhite:0.93 alpha:0.8];
            }
            
            
        }
        
        [self.VideoViewBank mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(self.view);
        }];
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

#pragma mark - 通知所有实现方法
#pragma mark - 通知进入后台停止播放
-(void)stopAllVideo:(NSNotification *)noit
{
    [self btnStopClick:self.btn_stop];
}

#pragma mark - 通知进入前台开始重新播放
-(void)startAllVideo:(NSNotification *)noit
{
    if ([[unitl currentTopViewController]isKindOfClass:[OnlyPlayBackVC class]]) {
       [self getRecordVideo:self.timeStr];
    }else{
        NSLog(@"进入前台，当前不是OnlyPlayBackVC，不播放~");
    }
}

#pragma mark - 码流连接失效停止播放
-(void)notOnlineStopVideo:(NSNotification *)noit
{
    [self btnStopClick:self.btn_stop];
}

- (void)stop_LoadView
{
    [self cannelLodingView];
}

- (void)PlayFaild
{
    self.failVideoBtn.hidden = NO;
    [self cannelLodingView];
}

#pragma mark - 关闭加载视频动画
- (void)stop_PlayMovie{
    _timer =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hidden_loadview) userInfo:nil repeats:YES];
    [self hidden_loadview];
}

- (void)hidden_loadview
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.collectionView.selectIndexPath];
        //        cell.loadView.hidden = YES;
        [self cannelLodingView];
    });
    [self stopTimer];
}

- (void)stopTimer
{
    [_timer invalidate];// 将定时器从运行循环中移除，
    _timer = nil;
}

#pragma mark 服务器录像返回时间戳 通知
#pragma mark - 更新显示时间
- (void)refreshTimeLabel:(NSNotification *)noti
{
    if (noti) {
        
        NSString * PlayingTimeStampStr = [NSString stringWithFormat:@"%@",[noti.userInfo objectForKey:@"TimeStamp"]];
//        NSLog(@"更新时间TTTT:%@",PlayingTimeStampStr);
        NSString * tempTimeToSwitch = [PlayingTimeStampStr substringToIndex:10];
        self.refreshTimeStemp = [tempTimeToSwitch mutableCopy];
        NSString * playingTimeStr = [unitl timeStampSwitchTime:[tempTimeToSwitch intValue] andFormatter:@"YYYY-MM-dd HH:mm:ss" IsTenBit:YES];
        NSString * tempJudge1970Str = [playingTimeStr substringToIndex:4];
        if ([tempJudge1970Str isEqualToString:@"1970"]) {
//            NSLog(@"后台返回的是1970的时间，return，具体时间：%@ ==后台来的时间：%@",playingTimeStr,PlayingTimeStampStr);
            return;
        }
        NSString * timeShowStr = [NSString stringWithFormat:@"%@",playingTimeStr];
        
        dispatch_async(dispatch_get_main_queue(),^{
            self.noTimeShaftRuler.timeLb.hidden = YES;
            [self.centerTimeView.btn_time setTitle:timeShowStr forState:UIControlStateNormal];

        });
        
        
        
    }
}
#pragma mark - 更新时间轴时间
- (void)refreshTimeRuler:(NSNotification *)noti
{
    if (noti) {
        NSString * PlayingTimeStampStr = [NSString stringWithFormat:@"%@",[noti.userInfo objectForKey:@"TimeStamp"]];
        NSString * tempTimeToSwitch = [PlayingTimeStampStr substringToIndex:10];
        self.refreshTimeStemp = [tempTimeToSwitch mutableCopy];
        NSString * playingTimeStr = [unitl timeStampSwitchTime:[tempTimeToSwitch intValue] andFormatter:@"YYYY-MM-dd HH:mm:ss" IsTenBit:YES];
        NSInteger RefreshTimeStamp = [unitl timeSwitchTimeStamp:playingTimeStr andFormatter:@"YYYY-MM-dd HH:mm:ss"];
       // NSString * timeShowStr = [NSString stringWithFormat:@"%@",playingTimeStr];
        dispatch_async(dispatch_get_main_queue(),^{
            self.timeRuler.indicatorCurrentTime = (int)RefreshTimeStamp;
        });
    }
}

#pragma mark - getter && setter
//时间模型数组
- (NSMutableArray *)videoTimeModelArr
{
    if (!_videoTimeModelArr) {
        _videoTimeModelArr = [NSMutableArray array];
    }
    return _videoTimeModelArr;
}


 - (GLFRulerControl *)timeRuler
{
    if (!_timeRuler) {
        float height;
        if (iPhoneWidth == 320) height = 45;
        else if (iPhoneWidth == 375) height = 50;
        else height = 50;
        
        _timeRuler = [[GLFRulerControl alloc] initWithFrame:CGRectMake(0, height, [UIScreen mainScreen].bounds.size.width , 70)];
        _timeRuler.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];
        [_timeRuler addTarget:self action:@selector(weightChanged:) forControlEvents:UIControlEventValueChanged];
        _timeRuler.minValue = 0;// 最小值
        _timeRuler.maxValue = 120;// 最大值
        _timeRuler.valueStep = 5;// 数值步长 【一小格代表的分钟数】【注】：这里的maxValue/valueStep 应该=24小时、
        _timeRuler.stepPerHour = 60 /_timeRuler.valueStep;
       // _timeRuler.selectedValue = 66;// 设置默认值
        _timeRuler.GlfRulerDelegate = self;
    }
    return _timeRuler;
}

//没有视频图像
- (UIImageView *)noImageView
{
    if (!_noImageView) {
        _noImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"movie"]];
        float height;
        if (iPhoneWidth == 320) height = 60;
        else if (iPhoneWidth == 375) height = 65;
        else height = 65;
        _noImageView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-50)/2, height, 50, 40);
    }
    return _noImageView;
}

- (ZMRocker *)rocker
{
    if (!_rocker) {
        _rocker =[[ZMRocker alloc]initWithFrame:CGRectMake(0, 0, 117, 117)];
        _rocker.hidden = NO;
        _rocker.delegate = self;
    }
    return _rocker;
}

//放时间轴和时间选择器的view
- (CenterTimeView *)centerTimeView
{
    if (!_centerTimeView) {
        _centerTimeView = [CenterTimeView viewFromXib];
        _centerTimeView.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneWidth);
        _centerTimeView.delegate = self;
        _centerTimeView.backgroundColor = [UIColor whiteColor];
        _centerTimeView.userInteractionEnabled = YES;
    }
    return _centerTimeView;
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
        _videoManager.delegate = self;
    }
    return _videoManager;
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

- (JW_CIPHER_CTX)cipher
{
        if (self.key && self.bIsEncrypt) {
            size_t len = strlen([self.key cStringUsingEncoding:NSASCIIStringEncoding]);
            _cipher =  jw_cipher_create((const unsigned char*)[self.key cStringUsingEncoding:NSASCIIStringEncoding], len);
           // NSLog(@"报警界面创建cipher：%p",&_cipher);
        }
    return _cipher;
}

- (RatioSlider *)slider
{
    if (!_slider) {
        _slider = [[RatioSlider alloc] initWithFrame:CGRectMake(0.05*iPhoneWidth, 150, 0.9*iPhoneWidth, 44) titles:@[@"1/8X",@"1/4X",@"1/2X",@"1X",@"2X",@"4X",@"8X"] defaultIndex:3 sliderImage:[UIImage imageNamed:@"ratioCircle"]];
        _slider.hidden = YES;
    }
    return _slider;
}

//可放大的图片
- (EnlargeimageView *)enlarge
{
    if (!_enlarge) {
        _enlarge = [[EnlargeimageView alloc]initWithframe:CGRectZero];
    }
    return _enlarge;
}

#pragma mark - TableView 占位图
- (UIImage *)xy_noDataViewImage {
    return [UIImage imageNamed:@"noMsg"];
}

- (NSString *)xy_noDataViewMessage {
     if ([self.listModel.owner_id isEqualToString:[unitl get_User_id]]) {
         return NSLocalizedString(@"暂无告警消息", nil);
     }else{
         shareFeature *shareModel = self.listModel.ext_info.shareFeature;
         if (shareModel.alarm == 0) {
             return NSLocalizedString(@"好友未分享告警权限", nil);
         }
     }
    return NSLocalizedString(@"暂无告警消息", nil);
}

- (NSNumber *)xy_noDataViewCenterYOffset
{
    return @10;
}

//录屏时左上角的红点
- (UIView *)redDotView
{
    if (!_redDotView) {
        _redDotView = [[UIView alloc]initWithFrame:CGRectMake(10, 10, 8, 8)];
        _redDotView.backgroundColor = [UIColor redColor];
        _redDotView.layer.masksToBounds = YES;
        _redDotView.layer.cornerRadius = 4.f;
        [self.VideoViewBank addSubview:_redDotView];
        [_redDotView.layer addAnimation:[self opacityForever_Animation:1.0] forKey:nil];
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

#pragma mark - 存储文件model(type:1是图片)
- (void)saveFileModel:(UIImage *)coverImg andPath:(NSString *)filePath andType:(int)type
{
    NSString *fileKey = [unitl getKeyWithSuffix:[unitl get_User_id] Key:@"MYFILE"];
    if ([unitl getNeedArchiverDataWithKey:fileKey]) {
        NSLog(@"数组已经有了，我们下载第二个了哦");
        NSMutableArray *tempArr = [unitl getNeedArchiverDataWithKey:fileKey];
        
        FileModel *model = [[FileModel alloc]init];
        model.name = self.navigationItem.title;
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
        model.name = self.navigationItem.title;
        model.date = [self getFileCreateTime:NO];
        model.createTime = [self getFileNameandType:type];
        model.type = type;
        model.filePath = filePath;
        [tempArr addObject:model];
        [unitl saveNeedArchiverDataWithKey:fileKey Data:tempArr];
    }
}

#pragma mark - 获取文件的描述信息
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


#pragma mark - 将当前时间转成时间戳 并转换成无时间轴标尺上的距离位置
- (void)timestampTransformAxisDistance
{
    if (self.timeMinStr) { //存在即切换，否则默认为拉取的时间列表的第一条数据位置
        NSString *alarmTimeStr = [NSString stringWithFormat:@"%@ %@",self.timeStr,self.timeMinStr];
        
        NSInteger alarmTimeStamp = [unitl timeSwitchTimeStamp:alarmTimeStr andFormatter:@"YYYY-MM-dd HH:mm:ss"];
        int timeStamp = [[NSString stringWithFormat:@"%ld",alarmTimeStamp] intValue];
        for (int i = 0; i<self.rulerModelArr.count; i++) {
            NoTimeShaftRulerModel *model = self.rulerModelArr[i];
            if (timeStamp >= model.startTimestamp && timeStamp <= model.endTimestamp) {
                int offTimeStamp = (int)timeStamp - model.startTimestamp;
                float offset = offTimeStamp / radio;
                
                float offDistance = model.startLoc + offset;
                [self.noTimeShaftRuler scrollFrameSetting:offDistance];
            }
        }
    }else{
        NoTimeShaftRulerModel *model = self.rulerModelArr[0];
        [self.noTimeShaftRuler scrollFrameSetting:model.startLoc];
    }
    
    
}


#pragma mark - 切换尺子模式代理方法
- (void)switchRulerMode:(BOOL)isDefault
{
    isDefaultMode = !isDefaultMode;
    if (!isDefaultMode) {
        NSLog(@"我是正常模式");
        self.timeRuler.hidden = NO;
        self.noTimeShaftRuler.hidden = YES;
    }else{
        NSLog(@"我是新模式");
        self.timeRuler.hidden = YES;
        self.noTimeShaftRuler.hidden = NO;
    }
    
    [self autoSearchAndPlayVideoIsDeviceVideo:self.isDeviceVideo TimeStr:self.timeStr];
}


#pragma mark - 滑动尺子代理事件
- (void)timeShaftRulerViewScrollOffSet:(float)offset untilEnd:(BOOL)isComplete
{
    float currentLoc = offset;
    self.noTimeShaftRuler.timeLb.hidden = NO;
    for (int i = 0; i<self.rulerModelArr.count; i++) {
        NoTimeShaftRulerModel *model = self.rulerModelArr[i];
        if ( (model.startLoc <= currentLoc) && (model.endLoc >= currentLoc) ) {
            //计算在该区域下的时刻
            //滑块滑动到的位置与该范围下的开始位置的差值
            float offsetLoc = currentLoc - model.startLoc;
            int offTime = [[NSString stringWithFormat:@"%f",offsetLoc*radio] intValue];
            int currentTimestamp = model.startTimestamp + offTime;
            self.noTimeShaftRuler.timeLb.text = [unitl timeStampSwitchTime:currentTimestamp andFormatter:@"HH:mm:ss" IsTenBit:YES];
        }
        /*表示最后一次，因为考虑到，换算比例，会导致最后其值小于控件自身的最大值，为了保证超过的部分也有效，所以我将其作为最后一次范围处理*/
        if (i == self.rulerModelArr.count-1) {
            if (model.endLoc < currentLoc) {
                
                int currentTimestamp = model.endTimestamp;
                
                self.noTimeShaftRuler.timeLb.text = [unitl timeStampSwitchTime:currentTimestamp andFormatter:@"HH:mm:ss" IsTenBit:YES];
            }
        }
    }
    
    if (isComplete) {
        self.timeMinStr = self.noTimeShaftRuler.timeLb.text;
        [self reloadTimePlay];
    }
    
}


//无时间轴标尺
- (NoTimeShaftRulerView *)noTimeShaftRuler
{
    if (!_noTimeShaftRuler) {
        float height;
        if (iPhoneWidth == 320) height = 45;
        else if (iPhoneWidth == 375) height = 50;
        else height = 50;
        _noTimeShaftRuler = [[NoTimeShaftRulerView alloc]initWithFrame:CGRectMake(0, height, iPhoneWidth, 70)];
        _noTimeShaftRuler.delegate = self;
        [self.centerTimeView addSubview:_noTimeShaftRuler];
    }
    return _noTimeShaftRuler;
}

//尺子上的数据段model的数组
- (NSMutableArray *)rulerModelArr
{
    if (!_rulerModelArr) {
        _rulerModelArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _rulerModelArr;
}


//尺子初始化是默认展示在第一条数据上的位置
- (void)defaultTimeRulerPosition
{
//    NSLog(@"后台返回的时间段数组：%@",self.videoTimeModelArr);
    if (self.videoTimeModelArr.count != 0) {
        ZCVideoTimeModel *model = self.videoTimeModelArr[0];
        int offTimeStamp = [[NSString stringWithFormat:@"%f",model.benginTime] intValue];
        int nowDayTimeStampInt = [unitl getNowadaysZeroTimeStamp];
        
        int beginTimeStamp = nowDayTimeStampInt + offTimeStamp;
        NSLog(@"今天的时间戳：%d",beginTimeStamp);
        self.timeRuler.indicatorCurrentTime = beginTimeStamp;
    }else{
        self.timeRuler.indicatorCurrentTime = nowRecordSlidingTime;
    }
}


#pragma mark - 展示频道列表
- (void)showTableView
{
    [self.view addSubview:self.disBtn];
    [self.view addSubview:self.multiTabView];
    [self.multiTabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.btn_back.mas_top).offset(0);
        make.width.mas_equalTo(0.8*iPhoneWidth);
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
    }];
}


#pragma makr - 通道列表View
- (MultiChannelView *)multiTabView
{
    if (!_multiTabView) {
        float height = iPhoneHeight-CGRectGetMaxY(self.btn_back.frame)-20-iPhoneNav_StatusHeight+44;
        _multiTabView = [[MultiChannelView alloc]initWithFrame:CGRectMake(0, 0, 0.8*iPhoneWidth, height) isMultiChannel:YES devId:self.listModel.ID andDevModel:self.listModel];
        _multiTabView.channelDelegate = self;
    }
    return _multiTabView;
}

//列表消失背景按钮
- (UIButton *)disBtn
{
    if (!_disBtn) {
        _disBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
        _disBtn.backgroundColor = [UIColor lightGrayColor];
        _disBtn.alpha = 0.5;
        [_disBtn addTarget:self action:@selector(disBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _disBtn;
}

- (void)disBtnClick
{
    [self.multiTabView removeFromSuperview];
    self.multiTabView = nil;
    [self.disBtn removeFromSuperview];
    self.disBtn = nil;
}

#pragma mark - 通道选择代理
- (void)didSelectedCellIndex:(NSIndexPath *)index withChannelModel:(MultiChannelModel *)channelModel
{
    [self disBtnClick];
    [MultiChannelDefaults clearChannelModel];
    [MultiChannelDefaults setChannelModel:channelModel];
    [self btnStopClick:self.btn_stop];
    self.title = channelModel.chanName;
    [self autoSearchAndPlayVideoIsDeviceVideo:self.isDeviceVideo TimeStr:self.timeStr];
}

@end
