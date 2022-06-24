//
//  PlayBackViewController.m
//  ZhongWeiEyes
//
//  Created by 张策 on 16/12/7.
//  Copyright © 2016年 张策. All rights reserved.
//

#import "PlayBackViewController.h"
#import "ZCTabBarController.h"
#import "VideoPlayView.h"
#import "MoreChooseView.h"
#import "ZCVideoManager.h"
#import "ZCAudioManager.h"
#import "SZCalendarPicker.h"
#import "XHToast.h"
#import "VideoModel.h"
#import "TXHRrettyRuler.h"
#import "TimeView.h"
#import "ControlView.h"
#import "CenterTimeView.h"
#import "ZCVideoTimeModel.h"
#import "WeiCloudListModel.h"
#import "TimeListModel.h"


@interface PlayBackViewController ()
<
    MoreChooseViewDelegate,
    TXHRrettyRulerDelegate,
    ControlViewDelegate,
    CenterTimeViewDelegate,
    UIScrollViewDelegate
>
@property (weak, nonatomic)UIImageView *ima_videoView;
@property (nonatomic,weak)VideoPlayView *playView;

@property (weak, nonatomic) IBOutlet UIButton *view_playBackG;
@property (weak, nonatomic) IBOutlet UIView *btn_back;
@property (weak, nonatomic) IBOutlet UIButton *btn_start;//开始 暂停
@property (weak, nonatomic) IBOutlet UIButton *btn_stop;//停止
@property (weak, nonatomic) IBOutlet UIButton *btn_hd;//子码流主码流
@property (weak, nonatomic) IBOutlet UIButton *btn_full;//全屏
@property (weak, nonatomic) IBOutlet UIButton *btn_cam;//截图
@property (weak, nonatomic) IBOutlet UIButton *btn_sound;//声音
@property (weak, nonatomic) IBOutlet UIButton *btn_video;//录像
@property (weak, nonatomic) IBOutlet UIButton *btn_time;//日期
@property (weak, nonatomic) IBOutlet UIButton *btn_center;//中心录像
@property (weak, nonatomic) IBOutlet UIButton *btn_front;//前端录像
@property (weak, nonatomic) IBOutlet UILabel *lab_jieTu;


//频道列表选择
@property (nonatomic,strong)MoreChooseView *chooseTabView;
//滑动View
@property (nonatomic,strong)UIScrollView *bottowScrollerView;
//控制云台View
@property (nonatomic,strong)ControlView *controlView;
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
@property (nonatomic,strong)ZCVideoManager *videoManage;
//音频管理者
@property (nonatomic,strong)ZCAudioManager *audioManage;
//图片截图 保存录像
@property (nonatomic, strong)ALAssetsLibrary *assetsLibrary;
//是否中心录像
@property (nonatomic,assign)BOOL isCenter;

//播放速度
@property (nonatomic,assign)int speedInt;
//是否播放
@property (nonatomic,assign)BOOL isViewPlay;
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
//时间
@property (nonatomic,copy)NSString *timeStr;
//进度条定位的秒
@property (nonatomic,copy)NSString *secStr;
//操作异步串行队列
@property (nonatomic,strong)dispatch_queue_t myActionQueue;
//具体时间
@property (nonatomic,copy)NSString *timeMinStr;
@end

@implementation PlayBackViewController
{
    //全局旋转变量
    UIDeviceOrientation orientation;

}
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
//视频管理者
- (ZCVideoManager *)videoManage
{
    if (!_videoManage) {
        _videoManage = [[ZCVideoManager alloc]init];
        _videoManage.delegate = self;
    }
    return _videoManage;
}
//音频管理
- (ZCAudioManager *)audioManage
{
    if (!_audioManage) {
        _audioManage = [[ZCAudioManager alloc]init];
    }
    return _audioManage;
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
//中心日期View
- (CenterTimeView *)centerTimeView
{
    if (!_centerTimeView) {
        _centerTimeView = [CenterTimeView viewFromXib];
        _centerTimeView.frame = CGRectMake(iPhoneWidth, 0, iPhoneWidth, iPhoneWidth);
        _centerTimeView.delegate = self;
    }
    return _centerTimeView;
}
//滑动View
- (UIScrollView *)bottowScrollerView
{
    if (!_bottowScrollerView) {
        _bottowScrollerView = [[UIScrollView alloc]init];
        _bottowScrollerView.delegate = self;
        // 设置内容大小
        self.bottowScrollerView.contentSize = CGSizeMake(iPhoneWidth*2, 0);
        // 是否反弹
        _bottowScrollerView.bounces = NO;
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
        [_pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];  //
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpChildView];
}
- (void)setUpChildView
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    self.title = @"视频监控";
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    //初始化位全屏
    self.isFull = NO;
    //初始化是否直播
    self.isLive = YES;
    //初始化是否hd
    self.isHd = NO;
    //初始化未录制
    self.isRecord = NO;
    [self setUpBtn];
    [self addPlayVideoView];
    //添加滑动视图
    [self.view addSubview:self.bottowScrollerView];
    [self.bottowScrollerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lab_jieTu.mas_top).offset(35);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
    }];
    [self.bottowScrollerView addSubview:self.controlView];
    [self.bottowScrollerView addSubview:self.centerTimeView];
    //添加无视频图像
    [self.centerTimeView addSubview:self.noImageView];
    [self.view addSubview:self.pageControl];
    //播放实时视频
    [self getVideoAddress];
    self.timeStr = self.centerTimeView.btn_time.titleLabel.text;
}

#pragma mark ------按钮状态初始化
- (void)setUpBtn
{
    [self.btn_start setImage:[UIImage imageNamed:@"playback_play_h"] forState:UIControlStateHighlighted];
    [self.btn_start setImage:[UIImage imageNamed:@"playback_pause_n"] forState:UIControlStateSelected];
    [self.btn_stop setImage:[UIImage imageNamed:@"playback_stop_h"] forState:UIControlStateHighlighted];
    [self.btn_sound setImage:[UIImage imageNamed:@"sound_close_n"] forState:UIControlStateSelected];
    [self.btn_hd setImage:[UIImage imageNamed:@"hd_h"] forState:UIControlStateSelected];
    [self.btn_full setImage:[UIImage imageNamed:@"playback_full_h"] forState:UIControlStateHighlighted];
    
    [self.btn_cam setBackgroundImage:[UIImage imageNamed:@"screenshot_h"] forState:UIControlStateSelected];
    [self.btn_video setBackgroundImage:[UIImage imageNamed:@"video_close_h"] forState:UIControlStateSelected];
    
    
    //今日时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    [self.centerTimeView.btn_time setTitle:currentTime forState:UIControlStateNormal];
    //中心录像
    self.isCenter = NO;
    //是否播放
    self.isViewPlay = NO;
}

//添加视图
- (void)addPlayVideoView
{
    UIImageView *ima = [[UIImageView alloc]init];
    ima.image = [UIImage imageNamed:@"monitor_up"];
    ima.contentMode = UIViewContentModeCenter;
    [self.view_playBackG addSubview:ima];
    [ima mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view_playBackG.mas_left).offset(0);
        make.top.equalTo(self.view_playBackG.mas_top).offset(0);
        make.right.equalTo(self.view_playBackG.mas_right).offset(0);
        make.bottom.equalTo(self.view_playBackG.mas_bottom).offset(0);
    }];
    self.ima_videoView = ima;
    
    VideoPlayView *playView = [VideoPlayView viewFromXib];
    [self.view_playBackG addSubview:playView];
    [playView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view_playBackG.mas_left).offset(0);
        make.top.equalTo(self.view_playBackG.mas_top).offset(0);
        make.right.equalTo(self.view_playBackG.mas_right).offset(0);
        make.bottom.equalTo(self.view_playBackG.mas_bottom).offset(0);
    }];
    self.playView = playView;
    self.isViewPlay = NO;
}
#pragma mark ------获取实时音视频地址
- (void)getVideoAddress
{
    self.title = [NSString stringWithFormat:@"%@ %@",self.listModel.name,@"监控"];
    [self btnStopClick:self.btn_stop];
    self.isLive = YES;
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    [postDic setObject:self.listModel.ID forKey:@"dev_id"];
    NSNumber *boolNum = [NSNumber numberWithBool:self.isHd];
    [postDic setObject:boolNum forKey:@"video_type"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/play" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            VideoAddressModel *addModel = [VideoAddressModel mj_objectWithKeyValues:responseObject[@"body"]];
            self.videoManage.videoAddressModel = addModel;
            [self.videoManage startCloudPlay];
            [self.playView.openView setupGL];
            self.btn_start.selected = YES;
            //开始播放
            self.isViewPlay = YES;
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
#pragma mark ------请求是否有回放录像
- (void)getRecordVideo:(NSString *)timeStr
{
    self.title = [NSString stringWithFormat:@"%@ %@",self.listModel.name,@"回放"];
    [self btnStopClick:self.btn_stop];
    self.isLive = NO;
    //时间戳
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss "];
    //今日零点
    NSString *beginTimeStr =[NSString stringWithFormat:@"%@ %@",timeStr,@"00:00:00"];
    NSDate *date = [formatter dateFromString:beginTimeStr];
    NSLog(@"%@", date);// 这个时间是格林尼治时间
    NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    int beginTimeInt = [dateStr intValue];
    
    //今日235959
    NSString *endTimeStr =[NSString stringWithFormat:@"%@ %@",timeStr,@"23:59:59"];
    NSDate *endDate = [formatter dateFromString:endTimeStr];
    NSLog(@"%@", endDate);// 这个时间是格林尼治时间
    NSString *dateEndStr = [NSString stringWithFormat:@"%ld", (long)[endDate timeIntervalSince1970]];
    int endTimeInt = [dateEndStr intValue];
    
    
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    [postDic setObject:self.listModel.ID forKey:@"dev_id"];
    NSNumber *boolNum = [NSNumber numberWithBool:NO];
//    NSNumber *boolNum = [NSNumber numberWithBool:NO];
    [postDic setObject:boolNum forKey:@"rec_type"];
    NSNumber *beginTimeNum = [NSNumber numberWithInt:beginTimeInt];
    NSNumber *endTimeNum = [NSNumber numberWithInt:endTimeInt];
    //请求播放的字典
    NSMutableDictionary *postBackPlayDic = [NSMutableDictionary dictionaryWithDictionary:postDic];
    [postBackPlayDic setObject:beginTimeNum forKey:@"start_time"];
    [postBackPlayDic setObject:endTimeNum forKey:@"stop_time"];
    
    
    // 请求进度条数据
    [postDic setObject:beginTimeNum forKey:@"s_date"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/list" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            TimeListModel *listModel = [TimeListModel mj_objectWithKeyValues:responseObject[@"body"]];
            if (listModel.histList.count!=0) {
                //请求开始播放
                [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/playback" parameters:postBackPlayDic IsToken:YES success:^(id  _Nonnull responseObject) {
                    int ret = [responseObject[@"ret"]intValue];
                    if (ret == 0) {
                        VideoAddressModel *addModel = [VideoAddressModel mj_objectWithKeyValues:responseObject[@"body"]];
                        self.videoManage.videoAddressModel = addModel;
                        [self.videoManage startCloudBackPlay];
                        [XHToast showTopWithText:@"获取录像成功，准备开始播放" topOffset:160];
                        [self.playView.openView setupGL];
                        self.btn_start.selected = YES;
                        self.btn_hd.selected = NO;
                        //开始播放
                        self.isViewPlay = YES;
                    }
                    else{
                        [XHToast showTopWithText:@"当前日期暂无录像" topOffset:160];
                        self.isViewPlay = NO;
                    }
                } failure:^(NSError * _Nonnull error) {
                    [XHToast showTopWithText:@"当前日期暂无录像" topOffset:160];
                    self.isViewPlay = NO;
                }];
                for (int i = 0; i<listModel.histList.count; i++) {
                    HisTimeListModel *records = listModel.histList[i];
                    ZCVideoTimeModel *model = [[ZCVideoTimeModel alloc]init];
                    //起点距离今日00分钟
                    CGFloat beginMin = (records.uBeginTime-beginTimeInt)/60.00;
                    //终点距离今日00分钟
                    CGFloat endMin = (records.uEndTime-beginTimeInt)/60.00;
                    model.benginTime = beginMin;
                    model.endTime = endMin;
                    [self.videoTimeModelArr addObject:model];
                }  //添加进度条
                [self.centerTimeView addSubview:self.rulerView];
                self.rulerView.timeArr = [NSArray arrayWithArray:self. videoTimeModelArr];
                self.rulerView.levelCount = 0;
            }
            else{
                [XHToast showTopWithText:@"当前日期暂无录像" topOffset:160];
                self.isViewPlay = NO;
                //没有图像时 进度条隐藏
                [self disRulerViewAndTimeView];
            }
        }
        else{
            [XHToast showTopWithText:@"当前日期暂无录像" topOffset:160];
            self.isViewPlay = NO;
            //没有图像时 进度条隐藏
            [self disRulerViewAndTimeView];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [XHToast showTopWithText:@"当前日期暂无录像" topOffset:160];
        self.isViewPlay = NO;
        //没有图像时 进度条隐藏
        [self disRulerViewAndTimeView];
    }];
}




#pragma mark ------相应按钮点击方法
- (IBAction)btnStartClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (self.isViewPlay == NO) {
        if (self.isLive) {
            [self getVideoAddress];
        }
        else{
            [self getRecordVideo:self.timeStr];
        }
        return;
    }
    btn.selected = !btn.selected;
    if (btn.selected) {
        [XHToast showTopWithText:@"开始" topOffset:160];
        [self.videoManage suspendedPlayYes];
    }else{
        [XHToast showTopWithText:@"暂停" topOffset:160];
        [self.videoManage suspendedPlayNo];
    }
   
}


- (IBAction)btnStopClick:(id)sender {
    if (self.isViewPlay == NO) {
        return;
    }
        [self.videoManage stopCloudPlay];
        VideoAddressModel *model = self.videoManage.videoAddressModel;
        NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
        [postDic setObject:model.monitor_id forKey:@"monitor_id"];
    //如果正在录像就停止录制
    [self judgeIsRecord];
    //停止直播
    if (self.isLive) {
        [[HDNetworking sharedHDNetworking]POST:@"v1/media/stopplay" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        } failure:^(NSError * _Nonnull error) {
        }];
    }
    //停止回放
    else {
        [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/stop_playback" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        } failure:^(NSError * _Nonnull error) {
        }];
    }
        
        
        //    self.audioManage.isOpen = NO;
        [self.ima_videoView removeFromSuperview];
        self.ima_videoView = nil;
        [self.playView removeFromSuperview];
        self.playView = nil;
        //重新添加
        [self addPlayVideoView];
        self.btn_start.selected = NO;
        //进度条时间View隐藏
        [self disRulerViewAndTimeView];
}

//声音
- (IBAction)btnSoundClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    WeakSelf(self);
    if (btn.selected) {
        [XHToast showTopWithText:@"声音:关" topOffset:160];
        
        dispatch_async(weakSelf.myActionQueue, ^{
            //            [self.audioManage stopPlayRecordCenterAudio];
            
        });
    }else{
        [XHToast showTopWithText:@"声音:开" topOffset:160];
        dispatch_async(weakSelf.myActionQueue, ^{
            //            [weakSelf.audioManage startPlayRecordCenterAudio:weakSelf.isCenter TimeStr:weakSelf.timeStr];
        });
    }
}

//子码流主码流
- (IBAction)btnHdClick:(id)sender {
    if (!self.isViewPlay) {
        return;
    }
    if (self.isLive == NO) {
        [XHToast showTopWithText:@"当前模式下不支持该功能" topOffset:160];
        return;
    }
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    self.isHd = btn.selected;
        [self.videoManage stopCloudPlay];
        VideoAddressModel *model = self.videoManage.videoAddressModel;
        NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
        [postDic setObject:model.monitor_id forKey:@"monitor_id"];
        [[HDNetworking sharedHDNetworking]POST:@"v1/media/stopplay" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        } failure:^(NSError * _Nonnull error) {
        }];
        //    self.audioManage.isOpen = NO;
        [self.ima_videoView removeFromSuperview];
        self.ima_videoView = nil;
        [self.playView removeFromSuperview];
        self.playView = nil;
        //重新添加
        [self addPlayVideoView];
        if (self.isLive) {
            if (self.isHd) {
                [XHToast showTopWithText:@"高清" topOffset:160];
            }
            else{
                [XHToast showTopWithText:@"流畅" topOffset:160];
            }
            [self getVideoAddress];
        }
        //进度条时间View隐藏
        [self disRulerViewAndTimeView];
}

//全屏
- (IBAction)btnFullClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        self.isFull = YES;
        NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationLandscapeLeft];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        [self rightHengpinAction];

    }
    else{
        self.isFull = NO;
        NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        [self shupinAction];
    }
}
//截图
- (IBAction)btnCamClick:(id)sender {
    if (self.isViewPlay == NO) {
        [XHToast showBottomWithText:@"录像未播放,请选择通道"];
        return;
    }
    UIImage *ima = [self snapshot:self.playView.openView];
    [XHToast showBottomWithText:@"已保存截图到相册"];
    WeakSelf(self);
    dispatch_async(dispatch_queue_create("photoScreenshot", NULL), ^{
        @synchronized (self) {
            [weakSelf.assetsLibrary saveImage:ima toAlbum:PATHSCREENSHOT completion:nil failure:nil];
        }
    });
    
    
}

//录像
- (IBAction)btnVideoClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (self.isViewPlay == NO) {
        [XHToast showBottomWithText:@"监控未播放"];
        return;
    }
    btn.selected = !btn.selected;
    if (btn.selected) {
        [XHToast showBottomWithText:@"视频开始录制"];
        [self.videoManage startRecord];
        self.isRecord = YES;
    }else{
        [XHToast showBottomWithText:@"视频录制成功，已保存到相册"];
        [self.videoManage stopRecord];
        self.isRecord = NO;
    }
}
////日期日历
//- (IBAction)btnTimeClick:(id)sender {
//    UIButton *btn = (UIButton *)sender;
//    __weak typeof(btn) weakBtn = btn;
//    SZCalendarPicker *calendarPicker = [SZCalendarPicker showOnView:self.view];
//    calendarPicker.today = [NSDate date];
//    calendarPicker.date = calendarPicker.today;
//    calendarPicker.frame = CGRectMake(0, 308, self.view.frame.size.width, self.view.bounds.size.height-308);
//    calendarPicker.calendarBlock = ^(NSInteger day, NSInteger month, NSInteger year){
//        [weakBtn setTitle:[NSString stringWithFormat:@"%i-%i-%i", year,month,day] forState:UIControlStateNormal];
//    };
//    
//}
#pragma mark ------centerTimeViewDelegate
- (void)CenterTimeViewCenterBtnClick:(BOOL)isCenter TimeStr:(NSString *)timeStr
{
    self.timeStr = timeStr;
    self.isCenter = isCenter;
    [self getRecordVideo:self.timeStr];
}
#pragma mark ------软解代理
- (void)setUpImage:(UIImage *)newImage
{

}
#pragma mark ------硬解代理
- (void)setUpBuffer:(CVPixelBufferRef)buffer
{
    if(buffer)
    {
        NSLog(@"正在硬解码硬解码");
        [self.playView.openView displayPixelBuffer:buffer];
    }
}
#pragma mark ------保存录像代理
- (void)stopRecordBlockFunc
{
    NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.mov"];
    NSURL *urlPath = [NSURL fileURLWithPath:betaCompressionDirectory];
    [self.assetsLibrary saveVideo:urlPath toAlbum:PATHVIDEO completion:nil failure:nil];
}
#pragma mark ------控制云台代理
- (void)ControlViewBtnTopClick{
    
}
- (void)ControlViewBtnLeftClick{}
- (void)ControlViewBtnDownClick{}
- (void)ControlViewBtnRightClick{}

- (void)ControlFunc
{
}

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
    if (self.videoManage&&self.isViewPlay) {
        VideoAddressModel *model = self.videoManage.videoAddressModel;
        NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
        [postDic setObject:model.monitor_id forKey:@"monitor_id"];
        NSNumber *cmdNum = [NSNumber numberWithInt:0];
        [postDic setObject:cmdNum forKey:@"cmd"];
        [postDic setObject:@"POS" forKey:@"action"];
        
        //时间戳
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        //调整时间
        NSString *beginTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,self.timeMinStr];
        NSDate *date = [formatter dateFromString:beginTimeStr];
        NSLog(@"%@", date);// 这个时间是格林尼治时间
        NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
        [postDic setObject:dateStr forKey:@"param"];
        [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/playback_ctrl" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
            
        } failure:^(NSError * _Nonnull error) {
            
        }];

    }
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
    //更新UIPageControl的当前页
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.frame;
    [_pageControl setCurrentPage:offset.x / bounds.size.width];
    if (offset.x == 0) {
        [self getVideoAddress];
    }
    else if (offset.x == iPhoneWidth) {
        [self getRecordVideo:self.timeStr];
    }
}
#pragma mark ------pageControl点击方法
- (void)pageTurn:(UIPageControl*)sender
{
    //令UIScrollView做出相应的滑动显示
    CGPoint scrollerPoint =  CGPointMake(sender.currentPage *iPhoneWidth, 0);
    [self.bottowScrollerView setContentOffset:scrollerPoint animated:YES];
}

#pragma mark ------判断当前是否录制
- (void)judgeIsRecord
{
    if (self.isRecord) {
        [self btnVideoClick:self.btn_video];
    }
}
#pragma mark -横竖屏坐标事件
-(void)shupinAction
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view_playBackG mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(64);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.height.equalTo(@(200));
        }];
        [self.btn_back mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view_playBackG.mas_bottom).offset(0);
        }];
        
        [self.ima_videoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view_playBackG.mas_left).offset(0);
            make.top.equalTo(self.view_playBackG.mas_top).offset(0);
            make.right.equalTo(self.view_playBackG.mas_right).offset(0);
            make.bottom.equalTo(self.view_playBackG.mas_bottom).offset(0);
        }];
        [self.playView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view_playBackG.mas_left).offset(0);
            make.top.equalTo(self.view_playBackG.mas_top).offset(0);
            make.right.equalTo(self.view_playBackG.mas_right).offset(0);
            make.bottom.equalTo(self.view_playBackG.mas_bottom).offset(0);
        }];
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

        [self.view layoutIfNeeded];
    }];
}
-(void)rightHengpinAction
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view_playBackG mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(0);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(-44);
        }];
        [self.btn_back mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view_playBackG.mas_bottom).offset(0);
        }];
        [self.ima_videoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view_playBackG.mas_left).offset(0);
            make.top.equalTo(self.view_playBackG.mas_top).offset(0);
            make.right.equalTo(self.view_playBackG.mas_right).offset(0);
            make.bottom.equalTo(self.view_playBackG.mas_bottom).offset(0);
        }];
        [self.playView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view_playBackG.mas_left).offset(0);
            make.top.equalTo(self.view_playBackG.mas_top).offset(0);
            make.right.equalTo(self.view_playBackG.mas_right).offset(0);
            make.bottom.equalTo(self.view_playBackG.mas_bottom).offset(0);
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

        [self.view layoutIfNeeded];
    }];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskPortrait;
 
}
#pragma mark - 得到截图

- (UIImage *)snapshot:(UIView *)view

{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size,YES,0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //进度条Frame
//    self.rulerView.center = CGPointMake(self.view.center.x, self.btn_center.center.y+60);
    //没有视频图像的ViewFrame
//    self.noImageView.center = CGPointMake(self.centerTimeView.center.x+5, self.btn_center.center.y+60);
//    ;
    self.pageControl.frame = CGRectMake(0, iPhoneHeight-30, iPhoneWidth, 30);
  
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;

}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.videoManage stopCloudPlay];
    self.videoManage.delegate = nil;
    self.videoManage = nil;
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
}
- (void)dealloc
{
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
