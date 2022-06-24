
//
//  LXAVPlayView.m
//  LXPlayer
//
//  Created by chenergou on 2017/12/4.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#define MaxSCale 6.0  //最大缩放比例
#define MinScale 1.0  //最小缩放比例

#import "LXAVPlayView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LXAVPlayControllView.h"
@interface LXAVPlayView()<UIGestureRecognizerDelegate>
// 播放器的几种状态
typedef NS_ENUM(NSInteger, LXPlayerState) {
    LXPlayerStateFailed,     // 播放失败
    LXPlayerStateBuffering,  // 缓冲中
    LXPlayerStatePlaying,    // 播放中
    LXPlayerStateStopped,    // 停止播放
    LXPlayerStatePause,       // 暂停播放
    LXPlayerStateEnd         // 播放完成
};

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved, // 横向移动
    PanDirectionVerticalMoved    // 纵向移动
};
/*播放器*/
@property(nonatomic,strong)AVPlayer *player;
/**playerLayer*/
@property (nonatomic, strong) AVPlayerLayer     *playerLayer;

/**播放器item*/
@property (nonatomic, strong) AVPlayerItem      *playerItem;



@property(nonatomic,strong)LXAVPlayControllView *contollView;//控制层+

@property(nonatomic,assign)LXPlayerState         playState;//播放状态

@property(nonatomic,strong)UITapGestureRecognizer         *singleTap;//单击

@property(nonatomic,strong)UITapGestureRecognizer         *doubleTap;//双点击

@property(nonatomic,strong)UIPinchGestureRecognizer       *pinchTap;//捏合手势

@property (nonatomic, assign) NSInteger                seekTime;/** 从xx秒开始播放视频 */

@property(nonatomic,assign)   CGFloat sumTime;
@property (nonatomic, strong) id           timeObserve;//定时观察者

@property(nonatomic,assign)BOOL            isDragged;//slider上有手势在作用

@property(nonatomic,assign)BOOL            isVolume;//音量调节

@property(nonatomic,assign)BOOL            isFullScreen;//是否是全屏

@property(nonatomic,assign)BOOL            isEnd;//播放结束

@property(nonatomic,assign)BOOL            isFullScreenByUser;//用户全屏

@property(nonatomic,strong)UIPanGestureRecognizer *panRecognizer; //平移手势
@property (nonatomic, strong) UISlider      *volumeViewSlider;/** 滑杆 */


@property (nonatomic, assign) PanDirection  panDirection;/** 定义一个实例变量，保存枚举值 */

@property(nonatomic,assign)UIInterfaceOrientation currentOrientation;//当前的方向；

@property(nonatomic,assign)UIInterfaceOrientation beforeEnterBackgoundOrientation;//进入后台之前的方向


//缩放比例
@property (nonatomic,assign) CGFloat lastScale;

@end
@implementation LXAVPlayView
-(void)destroyPlayer{
    
    [self pause];
    [self removeObserver];
    [self removeNsnotification];
    
    [self cancelHideSelector];
    
    [self.playerLayer removeFromSuperlayer];
    [self removeFromSuperview];
    
    self.playerLayer = nil;
    self.player = nil;
    self.contollView = nil;
}

-(void)dealloc{
    NSLog(@"%@销毁了",self.class);
    
}
#pragma mark---移除通知----
-(void)removeNsnotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}
#pragma mark---移除观察者--
-(void)removeObserver{
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];

    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    if (self.timeObserve) {
        self.timeObserve = nil;
    }
}

#pragma mark---初始化---
-(instancetype)init{
    self  = [super init];
    
    if (self) {
        //控件
        [self setUp];
        // 获取系统音量
        [self configureVolume];
        //添加手势
        [self createGestures];
        
        //APP运行状态通知，将要被挂起
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterBackground:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        // app进入前台
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterPlayground:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    return self;
}

-(void)setCurrentModel:(LXPlayModel *)currentModel{
    _currentModel = currentModel;
    self.contollView.playTitle = _currentModel.videoTitle;
    [self addPlayerToFatherView:_currentModel.fatherView];
    self.backgroundColor = [UIColor blackColor];
    //播放前测试链接是否有效
    [self testNetMethod];
}

#pragma mark - 测试网络播放情况
- (void)testNetMethod
{
    //1.确定请求路径
        NSURL *url = [NSURL URLWithString:self.currentModel.playUrl];
        //2.创建一个请求对象
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        //3.把请求发送给服务器，发送一个异步请求
        /*
        第一个参数：请求对象
        第二个参数：回调方法在哪个线程中执行，如果是主队列则block在主线程中执行，非主队列则在子线程中执行
        第三个参数：completionHandlerBlock块：接受到响应的时候执行该block中的代码
           response：响应头信息
           data：响应体
           connectionError：错误信息，如果请求失败，那么该参数有值
        */
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            //4.转换并打印响应头信息
            NSHTTPURLResponse *r = (NSHTTPURLResponse *)response;
            if (r.statusCode == 200) {
                [self readyToPlay];
            }else{
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UILabel *tipLb = [[UILabel alloc]init];
                        tipLb.text = @"视频链接已失效 >_<";
                        tipLb.textColor = [UIColor whiteColor];
                        [self addSubview:tipLb];
                        [tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.center.equalTo(self);
                        }];
                        
                    });
                });
                
                
            }
        }];
}


#pragma mark - 播放前的准备
-(void)readyToPlay{
    self.playerItem =[AVPlayerItem playerItemWithAsset:[AVAsset assetWithURL:[NSURL URLWithString:self.currentModel.playUrl]]];
    [self.contollView showLoadingAnimation:YES];
}
-(void)setPlayerItem:(AVPlayerItem *)playerItem{
    
    if (_playerItem) {
        //移除观察者
        [self removeObserver];
        
        //重置播放器
        [self resetPlayer];
        
        self.panRecognizer.enabled = NO;
    }
    _playerItem = playerItem;
    
    self.player =[AVPlayer playerWithPlayerItem:_playerItem];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.playerLayer.videoGravity =  AVLayerVideoGravityResizeAspect;
    
    
    //设置静音模式播放声音
    //      AVAudioSession * session  = [AVAudioSession sharedInstance];
    //    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    //    [session setActive:YES error:nil];
    
    
    [self addNotificationAndObserver];
    
    
}
#pragma mark--重置播放器---
-(void)resetPlayer{
    
    self.playState = LXPlayerStateStopped;
    
    self.isEnd = NO;
    
    
    [self.playerLayer removeFromSuperlayer];
    
    self.player = nil;
    
    [self.contollView resetPlayState];
    
    [self recoveryHideSelector];
}
#pragma mark---添加观察者，通知---
- (void)addNotificationAndObserver{
    
    if (self.playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区空了，需要等待数据
        [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        // 缓冲区有足够数据可以播放了
        [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
        
        __weak typeof(self) weakSelf = self;
        
        //添加系统吗观察者，观察播放进度
        self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time){
            AVPlayerItem *currentItem = weakSelf.playerItem;
            NSArray *loadedRanges = currentItem.seekableTimeRanges;
            if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
                NSInteger currentTime = (NSInteger)CMTimeGetSeconds([currentItem currentTime]);
                CGFloat totalTime     = (CGFloat)currentItem.duration.value / currentItem.duration.timescale;
                CGFloat value         = CMTimeGetSeconds([currentItem currentTime]) / totalTime;
                
                if (!weakSelf.isDragged) {
                
                    weakSelf.contollView.startTime =[LXAVPlayView durationStringWithTime:(NSInteger)currentTime];
                    weakSelf.contollView.endTime =[LXAVPlayView durationStringWithTime:(NSInteger)totalTime];
                    //设置播放进度
                    weakSelf.contollView.slideValue = value;

                }
            }
        }];
        
    }
    
}

#pragma mark---KVO ---
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if (object == _playerItem) {
        
        if ([keyPath isEqualToString:@"status"]) {
            
            if (_playerItem.status == AVPlayerItemStatusReadyToPlay){
                
                [self setNeedsLayout];
                [self layoutIfNeeded];
                [self.layer insertSublayer:self.playerLayer atIndex:0];
                
                self.playState = LXPlayerStatePlaying;
                
                // 加载完成后，再添加平移手势
                // 添加平移手势，用来控制音量、亮度、快进快退
                self.panRecognizer.enabled = YES;
                
            }
        }
        if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            
            // 计算缓冲进度
            NSTimeInterval timeInterval = [self availableDuration];
            CMTime duration             = self.playerItem.duration;
            CGFloat totalDuration       = CMTimeGetSeconds(duration);
            if (isnan(timeInterval)) {
                timeInterval = 0;
            }
            if (totalDuration) {
                self.contollView.cacheValue  =  timeInterval / totalDuration;
            }
            
            
        }
        if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            // 当缓冲是空的时候
            if (self.playerItem.playbackBufferEmpty) {
                [self bufferingSomeSecond];
            }

        }
        if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            
            // 当缓冲好的时候
            if (self.playerItem.playbackLikelyToKeepUp && self.playState == LXPlayerStateBuffering){
                self.playState = LXPlayerStatePlaying;
            }
            
        }
    }
}
#pragma mark--手势种种--
-(void)createGestures{
    
    self.lastScale = 1.0;
    
    [self addGestureRecognizer:self.singleTap];
    [self addGestureRecognizer:self.doubleTap];
    // 解决点击当前view时候响应其他控件事件
    [self.singleTap setDelaysTouchesBegan:YES];
    [self.doubleTap setDelaysTouchesBegan:YES];
    // 双击失败响应单击事件
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    [self performSelector:@selector(hideControllView) withObject:nil afterDelay:3];
    
    //捏合手势
//    [self.contollView addGestureRecognizer:self.pinchTap];
}


-(void)setPlayState:(LXPlayerState)playState{
    
    _playState = playState;
    
    if (_playState == LXPlayerStatePlaying) {
        [self play];
        [self.contollView showLoadingAnimation:NO];
        
    }else if(_playState == LXPlayerStateBuffering){
        [self.contollView showLoadingAnimation:YES];
        
    }else{
        [self.contollView showLoadingAnimation:NO];
        [self pause];
    }
    
}
#pragma mark ----添加通知----
-(void)moviePlayDidEnd:(NSNotification *)noti{
    
    self.isEnd = YES;
    
    //如果需要重播这里需要添加判断
    [self pause];
    if (self.isAutoReplay) {
        [self resetPlay];
    }else{
        [self.contollView showPlayEnd]; //播放结束
    }
    
}

#pragma mark - APP活动通知
- (void)appDidEnterBackground:(NSNotification *)note{
    //将要挂起，停止播放
    [self pause];
   
}
- (void)appDidEnterPlayground:(NSNotification *)note{
    //继续播放
    [self play];
}
#pragma mark---私有方法---

#pragma mark - 重新开始播放
- (void)resetPlay{
    _isEnd = NO;
    [self seekToTime:0 completionHandler:nil];
}
/**
 *  player添加到fatherView上
 */
- (void)addPlayerToFatherView:(UIView *)view {
    // 这里应该添加判断，因为view有可能为空，当view为空时[view addSubview:self]会crash
    if (view) {
        [self removeFromSuperview];
        [view addSubview:self];
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_offset(UIEdgeInsetsZero);
        }];
    }
}
/**
 *  获取系统音量
 */
- (void)configureVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    
    if (!success) { /* handle the error in setCategoryError */ }
    
}

#pragma mark--隐藏控制层--
-(void)hideControllView{
    
    [self.contollView hidIsAnimated:YES];
    
}
#pragma mark--恢复定时器--
-(void)recoveryHideSelector{
    [self performSelector:@selector(hideControllView) withObject:nil afterDelay:10];
}
#pragma mark---取消定时器
-(void)cancelHideSelector{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControllView) object:nil];
}
#pragma mark--控件---
-(void)setUp{
    
    [self addSubview:self.contollView];
    
    [self.contollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    //播放回调
    LXWS(weakSelf);
    self.contollView.playCallBack = ^(BOOL isPlay) {
        
        if (isPlay) {
            [weakSelf play];
        }else{
            [weakSelf pause];
        }
    };
    
    //slide平移手势的回调
    self.contollView.panBegin = ^{
        
        weakSelf.isDragged = YES;
        if (!weakSelf.contollView) {
            weakSelf.contollView.isShow = YES;
        }
        [weakSelf cancelHideSelector];
        
    };
    
    self.contollView.getSlideValue = ^(CGFloat value) {
        
        // 当前frame宽度 * 总时长 / 总frame长度 = 当前时间
        CGFloat duration = CMTimeGetSeconds([weakSelf.player.currentItem duration]);
        int time = duration * value;
        // 更新时间
        weakSelf.contollView.startTime = [LXAVPlayView durationStringWithTime:(NSInteger) time];
    };
    
    
    self.contollView.panEnd = ^(CGFloat value) {
        CGFloat duration = CMTimeGetSeconds([weakSelf.player.currentItem duration]);
        int time = duration * value;
        
        weakSelf.isDragged = YES;
        [weakSelf seekToTime:time completionHandler:nil];
    };
    
    
    self.contollView.tapSlider = ^(CGFloat value) {
        // 当前frame宽度 * 总时长 / 总frame长度 = 当前时间
        weakSelf.isDragged = YES;
        CGFloat duration = CMTimeGetSeconds([weakSelf.player.currentItem duration]);
        int time = duration * value;
        // 更新时间
        weakSelf.contollView.startTime = [LXAVPlayView durationStringWithTime:(NSInteger) time];
        [weakSelf seekToTime:time completionHandler:nil];
    };
    
    self.contollView.fullScreenBlock = ^(BOOL isFullScreen) {
        weakSelf.isFullScreen = isFullScreen;
        
        weakSelf.isFullScreenByUser = YES;
        [weakSelf fullScreenAction];
        weakSelf.isFullScreenByUser = NO;
    };
    
    self.contollView.backBlock = ^{
        
        if (weakSelf.isFullScreen) {
            weakSelf.isFullScreenByUser = YES;
            [weakSelf fullScreenAction];
            weakSelf.isFullScreenByUser = NO;
            weakSelf.contollView.isFullScreen = weakSelf.isFullScreen;
        }else{
            
            if (weakSelf.backBlock) {
                weakSelf.backBlock();
            }
        }
    };
    
    self.contollView.replayBlock = ^(BOOL isReplay) {
         [weakSelf resetPlay];
    };
    
    [self addGestureRecognizer:self.panRecognizer];
}

#pragma mark---单击手势--
-(void)singleTap:(UITapGestureRecognizer *)tap{
    
    
    if (self.contollView.isShow) {
        [self.contollView hidIsAnimated:YES];
        
    }else{
        [self.contollView showIsAnimated:YES];
        
    }
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (touch.view) {
        [self cancelHideSelector];
        [self recoveryHideSelector];
    }
    return YES;
}

#pragma mark---双击手势--
-(void)doubleTap:(UITapGestureRecognizer *)tap{
    
    //先判断缓存 然后在暂停
    if (self.playState == LXPlayerStatePause) {
        self.playState = LXPlayerStatePlaying;
    }else{
        self.playState = LXPlayerStatePause;
    }
}

/** 全屏 */
- (void)fullScreenAction {
    if ([self.delegate respondsToSelector:@selector(fullScreenOrNormalSizeWithFlag:)])
    {
        [self.delegate fullScreenOrNormalSizeWithFlag:self.isFullScreen];
        self.isFullScreen = !self.isFullScreen;
    }
}


/**
 *  从xx秒开始播放视频跳转
 *
 *  @param dragedSeconds 视频跳转的秒数
 */
- (void)seekToTime:(NSInteger)dragedSeconds completionHandler:(void (^)(BOOL finished))completionHandler
{
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        // seekTime:completionHandler:不能精确定位
        // 如果需要精确定位，可以使用seekToTime:toleranceBefore:toleranceAfter:completionHandler:
        // 转换成CMTime才能给player来控制播放进度
        
        [self pause];
        self.playState = LXPlayerStateBuffering;
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1); //kCMTimeZero
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:dragedCMTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:^(BOOL finished) {
            
            // 视频跳转回调
            if (completionHandler) { completionHandler(finished); }
            
            weakSelf.seekTime = 0;
            
            weakSelf.isDragged = NO;
            
            //            //开始播放
            //            if (!weakSelf.isPauseByUser) {
            //                [weakSelf videoPlay];
            //            }
            [weakSelf play];
            

            [weakSelf recoveryHideSelector];
            if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp ){ weakSelf.playState = LXPlayerStateBuffering;
                
            }else{
                weakSelf.playState = LXPlayerStatePlaying;
            }
            
            weakSelf.sumTime = 0;
            
        }];
    }
}
#pragma mark - 当前时间换算
+ (NSString *)durationStringWithTime:(NSInteger)time
{
    // 获取分
    NSString *m = [NSString stringWithFormat:@"%02ld",(long)(time/60)];
    // 获取秒
    NSString *s = [NSString stringWithFormat:@"%02ld",(long)(time%60)];
    
    return [NSString stringWithFormat:@"%@:%@",m,s];
}
#pragma mark---屏幕的平移手势
-(void)panDirection:(UIPanGestureRecognizer *)pan{
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [pan locationInView:self];
    
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self];
    
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                // 取消隐藏
                self.panDirection = PanDirectionHorizontalMoved;
                // 给sumTime初值
                CMTime time    = self.player.currentTime;
                self.sumTime      = time.value/time.timescale;
            }
            else if (x < y){ // 垂直移动
                self.panDirection = PanDirectionVerticalMoved;
                // 开始滑动的时候,状态改为正在控制音量
                if (locationPoint.x > self.bounds.size.width / 2) {
                    self.isVolume = YES;
                }else { // 状态改为显示亮度调节
                    self.isVolume = NO;
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                case PanDirectionVerticalMoved:{
                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
//                    self.isPauseByUser = NO;
                    
                    [self seekToTime:self.sumTime completionHandler:nil];
                    // 把sumTime滞空，不然会越加越多
                    self.sumTime = 0;
                    break;
                }
                case PanDirectionVerticalMoved:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    self.isVolume = NO;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

/**
 *  pan垂直移动的方法
 *
 *  @param value void
 */
- (void)verticalMoved:(CGFloat)value {
    self.isVolume ? (self.volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}
/**
 *  pan水平移动的方法
 *
 *  @param value void
 */
- (void)horizontalMoved:(CGFloat)value {
    // 每次滑动需要叠加时间
    self.sumTime += value / 150;
    
    // 需要限定sumTime的范围
    CMTime totalTime           = self.playerItem.duration;
    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    if (self.sumTime > totalMovieDuration) { self.sumTime = totalMovieDuration;}
    if (self.sumTime < 0) { self.sumTime = 0; }
    
    self.isDragged = YES;
    
    CGFloat  draggedValue  = (CGFloat)self.sumTime/(CGFloat)totalMovieDuration;
    
     self.contollView.startTime = [LXAVPlayView durationStringWithTime:(NSInteger) self.sumTime];
    self.contollView.slideValue = draggedValue;

}
/**
 *  缓冲较差时候回调这里
 */
- (void)bufferingSomeSecond {
    self.playState = LXPlayerStateBuffering;
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    __block BOOL isBuffering = NO;
    if (isBuffering) return;
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.player pause];
    LXWS(weakSelf);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 如果此时用户已经暂停了，则不再需要开启播放了
//        if (self.isPauseByUser) {
//            isBuffering = NO;
//            return;
//        }
//
        weakSelf.playState  = LXPlayerStatePlaying;
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp) { [weakSelf bufferingSomeSecond]; }
        
    });
}


#pragma mark - 捏合手势（放大缩小画面）
- (void)pinch:(UIPinchGestureRecognizer *)recognizer
{
    NSLog(@"我在做捏合手势");
    UIGestureRecognizerState state = [recognizer state];
    if (state == UIGestureRecognizerStateBegan) {
        [self correctAnchorPointBaseOnGestureRecognizer:recognizer];
        _lastScale = [recognizer scale];
    }
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        // Constants to adjust the max/min values of zoom
        CGFloat currentScale = [[self.contollView.layer valueForKeyPath:@"transform.scale"] floatValue];
        CGFloat newScale = 1.0 - (_lastScale - [recognizer scale]);
        newScale = MIN(newScale, MaxSCale / currentScale);
        newScale = MAX(newScale, MinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([self.contollView transform], newScale, newScale);
        self.contollView.transform = transform;
        //Store the previous scale factor for the next pinch gesture call
        _lastScale = [recognizer scale];
    }
    if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateFailed || state == UIGestureRecognizerStateCancelled) {
           [self setDefaultAnchorPointforView:self.contollView];
       }
       if (state == UIGestureRecognizerStateEnded) {
           
           CGRect newRect1 = [self convertRect:self.bounds toView:self.contollView];
           BOOL canRect =  CGRectContainsRect(self.contollView.frame, newRect1);
           if (canRect) {
               
           }else{
               CGPoint CenterPoint = self.center;
               [self.contollView setCenter:CenterPoint];
           }
       }
    
}


//获取两指中心点
- (void)correctAnchorPointBaseOnGestureRecognizer:(UIGestureRecognizer *)gr
{
    CGPoint onoPoint = [gr locationOfTouch:0 inView:gr.view];
    CGPoint twoPoint = [gr locationOfTouch:1 inView:gr.view];
    
    CGPoint anchorPoint;
    anchorPoint.x = (onoPoint.x + twoPoint.x) / 2 / gr.view.bounds.size.width;
    anchorPoint.y = (onoPoint.y + twoPoint.y) / 2 / gr.view.bounds.size.height;
    
    [self setAnchorPoint:anchorPoint forView:self];
}
//设置变换中心点
- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint oldOrigin = view.frame.origin;
    view.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin = view.frame.origin;
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    
    view.center = CGPointMake (view.center.x - transition.x, view.center.y - transition.y);
}
//还原中心点
- (void)setDefaultAnchorPointforView:(UIView *)view
{
    [self setAnchorPoint:CGPointMake(0.5f, 0.5f) forView:view];
}


#pragma mark - 计算缓冲进度
/**
 *  计算缓冲进度
 *
 *  @return 缓冲进度
 */
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}
-(void)layoutSubviews{
    [super layoutSubviews];
     self.playerLayer.frame = self.bounds;
//    NSLog(@"%@",NSStringFromCGRect(self.bounds));
}

#pragma mark---点击事件---
#pragma mark---播放
-(void)play{
    
    [self.contollView IsPlaying:YES];
    [self.player play];
    
}
#pragma mark---暂停---
-(void)pause{
    [self.contollView IsPlaying:NO];

    [self.player pause];
}



#pragma mark----setter method --
-(void)setIsLandScape:(BOOL)isLandScape{
    _isLandScape = isLandScape;
}

-(void)setIsAutoReplay:(BOOL)isAutoReplay{
    _isAutoReplay = isAutoReplay;
    
}
-(void)setIsFullScreen:(BOOL)isFullScreen{
    _isFullScreen = isFullScreen;
    self.contollView.isFullScreen = isFullScreen;
}
#pragma mark----getter method ---
-(UITapGestureRecognizer *)singleTap{
    if (!_singleTap) {
        _singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
        _singleTap.delegate =  self;
        _singleTap.numberOfTapsRequired = 1;
        _singleTap.numberOfTouchesRequired = 1;
    }
    return _singleTap;
}
-(UITapGestureRecognizer *)doubleTap{
    if (!_doubleTap) {
        _doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        _doubleTap.numberOfTapsRequired = 2;
        _doubleTap.numberOfTouchesRequired = 1;
        _doubleTap.delegate =  self;
       
    }
    return _doubleTap;
}

- (UIPinchGestureRecognizer *)pinchTap{
    if (!_pinchTap) {
        _pinchTap = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinch:)];
    }
    return _pinchTap;
}

-(LXAVPlayControllView *)contollView{
    if (!_contollView) {
        _contollView = [[LXAVPlayControllView alloc]init];
    }
    return _contollView;
}

-(UIPanGestureRecognizer *)panRecognizer{
    if (!_panRecognizer) {
        
        
        _panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
        _panRecognizer.delegate = self;
        [_panRecognizer setMaximumNumberOfTouches:1];
        [_panRecognizer setDelaysTouchesBegan:YES];
        [_panRecognizer setDelaysTouchesEnded:YES];
        [_panRecognizer setCancelsTouchesInView:YES];
        _panRecognizer.enabled = NO;
    }
    return _panRecognizer;
}



@end
