//
//  TYVideoPlayerController.m
//  TYVideoPlayerDemo
//
//  Created by tany on 16/7/6.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYVideoPlayerController.h"
#import "TYVideoPlayer.h"
#import "TYVideoPlayerView.h"
#import "TYVideoControlView.h"
#import "TYLoadingView.h"
#import "TYVideoErrorView.h"
#import "AppDelegate.h"
#import "ZCTabBarController.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface TYVideoPlayerController () <TYVideoPlayerDelegate, TYVideoControlViewDelegate,UIAlertViewDelegate>
{
    float _volume; // 音量
    NSInteger _curAutoRetryCount; // 当前重试次数
    BOOL _isDraging; // 正在拖拽
}

// 播放视图层
@property (nonatomic, weak) TYVideoPlayerView *playerView;
// 播放控制层
@property (nonatomic, weak) TYVideoControlView *controlView;
// 播放loading
@property (nonatomic, weak) TYLoadingView *loadingView;
// 播放错误view
@property (nonatomic, weak) TYVideoErrorView *errorView;
// 播放器
@property (nonatomic, strong) TYVideoPlayer *videoPlayer;

@end

@implementation TYVideoPlayerController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self configrePropertys];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self configrePropertys];
    }
    return self;
}

- (void)configrePropertys
{
    _shouldAutoplayVideo = YES;
    _failedToAutoRetryCount = 2;
    _videoGravity = AVLayerVideoGravityResizeAspect;
}

#pragma mark - life cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    AppDelegate *appdelegete = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegete.allowRotation = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    AppDelegate *appdelegete = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegete.allowRotation = NO;;
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    AppDelegate *appdelegete = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegete.allowRotation = YES;
    
    [self addPlayerView];
    
    [self addLoadingView];
    
    [self addVideoControlView];
    
    [self addSingleTapGesture];
    
    [self addVideoPlayer];
    
    if (_streamURL) {
        [self loadVideoWithStreamURL:_streamURL];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _playerView.frame = self.view.bounds;
    _loadingView.center = _playerView.center;
    _controlView.frame = self.view.bounds;
    [_controlView setFullScreen:self.isFullScreen];
}

- (BOOL)prefersStatusBarHidden
{
    if (!self.isFullScreen) {
        return NO;
    }
    return [self isControlViewHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation )preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

#pragma mark - add subview

- (void)addPlayerView
{
    TYVideoPlayerView *playerView = [[TYVideoPlayerView alloc]init];
    playerView.backgroundColor = [UIColor blackColor];
    playerView.playerLayer.videoGravity = _videoGravity;
    [self.view addSubview:playerView];
    _playerView = playerView;
}

- (void)addVideoControlView
{
    TYVideoControlView *controlView = [[TYVideoControlView alloc]init];
    
    /*
    NSString * result;
    if (isSimplifiedChinese) {
        NSRange range = [self.videoInfo rangeOfString:@"关联设备通道:"]; //现获取要截取的字符串位置]
        result = [self.videoInfo substringFromIndex:range.location+7];
    }else{
        NSRange range = [self.videoInfo rangeOfString:@"Device Name:"]; //现获取要截取的字符串位置
        result = [self.videoInfo substringFromIndex:range.location+12];
    }
      result = [NSString stringWithFormat:@"%@",result];
     */
    
    [controlView setTitle:self.titleName];
    [controlView setViedoInfoTitle:self.videoInfo];
    [controlView setViedoToolBarView:self.videoInfo];
    controlView.delegate = self;
    [self.view addSubview:controlView];
    _controlView = controlView;
}

- (void)addLoadingView
{
    TYLoadingView *loadingView = [[TYLoadingView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    loadingView.lineWidth = 1.5;
    [self.view addSubview:loadingView];
    _loadingView = loadingView;
}

- (void)addSingleTapGesture
{
    UITapGestureRecognizer *hideTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];
    [_controlView addGestureRecognizer:hideTap];
}

#pragma mark - getter

- (BOOL)isFullScreen
{
    return [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight;
}

- (void)setVideoGravity:(NSString *)videoGravity
{
    _videoGravity = videoGravity;
    
    if (_playerView) {
        _playerView.playerLayer.videoGravity = videoGravity;
    }
}

- (float)volume {
    return _videoPlayer.volume;
}

- (void)setVolume:(float)volume {
    _volume = volume;
    
    if (!_videoPlayer.player) {
        return;
    }
    
    _videoPlayer.volume = volume;
}

#pragma mark - video player

- (void)addVideoPlayer
{
    TYVideoPlayer *videoPlayer = [[TYVideoPlayer alloc]initWithPlayerLayerView:_playerView];
    videoPlayer.delegate = self;
    _videoPlayer = videoPlayer;
}

#pragma mark - player control

- (void)loadVideoWithStreamURL:(NSURL *)streamURL
{
    _streamURL = streamURL;
    
    [_videoPlayer loadVideoWithStreamURL:streamURL];
}

- (void)play
{
    [_videoPlayer play];
}

- (void)pause
{
    [_videoPlayer pause];
}

- (void)stop
{
    [_videoPlayer stop];
}

#pragma mark - show & hide view

// show loadingView
- (void)showLoadingView
{
    if (!_loadingView.isAnimating && _videoPlayer.track.videoType != TYVideoPlayerTrackLocal) {
        [_controlView setPlayBtnHidden:YES];
        [_loadingView startAnimation];
    }
}

- (void)stopLoadingView
{
    if (_loadingView.isAnimating) {
        [_controlView setPlayBtnHidden:NO];
        [_loadingView stopAnimation];
    }
}

// show ControlView
- (void)showControlViewWithAnimation:(BOOL)animation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            [self setControlViewHidden:NO];
        }];
    }else {
        [self setControlViewHidden:NO];
    }
    [_controlView setPlayBtnHidden:[_loadingView isAnimating]];
}

- (void)hideControlViewWithAnimation:(BOOL)animation
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            [self setControlViewHidden:YES];
        }];
    }else {
        [self setControlViewHidden:YES];
    }
}

- (void)setControlViewHidden:(BOOL)hidden
{
    [_controlView setContentViewHidden:hidden];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)isControlViewHidden
{
    return [_controlView contentViewHidden];
}

- (void)hideControlViewWithDelay:(CGFloat)delay
{
    if (delay > 0) {
        [self performSelector:@selector(hideControlView) withObject:nil afterDelay:delay];
    }else {
        [self hideControlView];
    }
}

- (void)hideControlView
{
    if (![self isControlViewHidden]  && !_isDraging) {
        [self hideControlViewWithAnimation:YES];
    };
}

// show errorView
- (void)showErrorViewWithTitle:(NSString *)title actionHandle:(void (^)(void))actionHandle
{
    if (!_errorView) {
        TYVideoErrorView *errorView = [[TYVideoErrorView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        errorView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [self.view addSubview:errorView];
        [errorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(0);
            make.top.equalTo(self.view.mas_top).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
        }];
        
        _errorView = errorView;
    }
    
    __weak typeof(self) weakSelf = self;
    [_errorView setTitle:title];
    [_errorView setEventActionHandle:^(TYVideoErrorEvent event) {
        switch (event) {
            case TYVideoErrorEventBack:
                [weakSelf goBackAction];
                break;
            case TYVideoErrorEventReplay:
                if (actionHandle) {
                    actionHandle();
                }
                break;
            default:
                break;
        }
    }];
}

- (void)hideErrorView
{
    if (_errorView) {
        [_errorView removeFromSuperview];
    }
}

#pragma mark - private

- (BOOL)autoRetryLoadCurrentVideo
{
    if (_curAutoRetryCount++ < _failedToAutoRetryCount) {
        NSLog(@"autoRetryLoadCurrentVideoCount %ld",(long)_curAutoRetryCount);
        [self reloadCurrentVideo];
        return YES;
    }
    return NO;
}

- (void)playerViewDidChangeToState:(TYVideoPlayerState)state
{
    switch (state) {
        case TYVideoPlayerStateRequestStreamURL:
            [self hideErrorView];
            [self showLoadingView];
            if (_shouldAutoplayVideo) {
                [self hideControlViewWithAnimation:NO];
            }
            [_controlView setSliderProgress:0];
            [_controlView setBufferProgress:0];
            [_controlView setCurrentVideoTime:@"00:00"];
            [_controlView setTotalVideoTime:@"00:00"];
            break;
        case TYVideoPlayerStateContentReadyToPlay:
        {
            NSString *totalTime = [self covertToStringWithTime:[_videoPlayer duration]];
            NSString *currentTime = [self covertToStringWithTime:[_videoPlayer currentTime]];
            [_controlView setTotalVideoTime:totalTime];
            [_controlView setCurrentVideoTime:currentTime];
            [_controlView setSliderProgress:[_videoPlayer currentTime]/[_videoPlayer duration]];
            [_controlView setTimeSliderHidden:_videoPlayer.track.videoType == TYVideoPlayerTrackLIVE];
            if (_shouldAutoplayVideo) {
                [self hideControlViewWithDelay:5.0];
            }else {
                [self stopLoadingView];
            }
            break;
        }
        case TYVideoPlayerStateContentPlaying:
            [self hideErrorView];
            [_controlView setPlayBtnState:NO];
            [_controlView setPlayBtnHidden:NO];
            [self stopLoadingView];
            break;
        case TYVideoPlayerStateContentPaused:
            [_controlView setPlayBtnState:YES];
            break;
        case TYVideoPlayerStateSeeking:
            [self showLoadingView];
            break;
        case TYVideoPlayerStateBuffering:
            [self showLoadingView];
            break;
        case TYVideoPlayerStateStopped:
            [self stopLoadingView];
            [_controlView setPlayBtnHidden:YES];
            break;
        case TYVideoPlayerStateError:
            [self stopLoadingView];
            [_controlView setPlayBtnHidden:YES];
            break;
        default:
            break;
    }
}

- (void)player:(TYVideoPlayer*)videoPlayer didChangeToState:(TYVideoPlayerState)state
{
    // player control
    switch (state) {
        case TYVideoPlayerStateContentReadyToPlay:
            if (_shouldAutoplayVideo) {
                [videoPlayer play];
            }
            if ([_delegate respondsToSelector:@selector(videoPlayerController:readyToPlayURL:)]) {
                [_delegate videoPlayerController:self readyToPlayURL:videoPlayer.track.streamURL];
            }
            break;
        case TYVideoPlayerStateContentPlaying:
            _curAutoRetryCount = 0;
            break;
        case TYVideoPlayerStateError:
            if (![self autoRetryLoadCurrentVideo]) {
                __weak typeof(self) weakSelf = self;
                [self showErrorViewWithTitle:NSLocalizedString(@"视频播放失败,重试", nil) actionHandle:^{
                    [weakSelf reloadCurrentVideo];
                }];
            }
            break;
        default:
            break;
    }
}

- (void)handelControllerEvent:(TYVideoPlayerControllerEvent)event
{
    if ([_delegate respondsToSelector:@selector(videoPlayerController:handleEvent:)]) {
        [_delegate videoPlayerController:self handleEvent:event];
    }
}

- (NSString *)covertToStringWithTime:(NSInteger)time
{
    NSInteger seconds = time % 60;
    NSInteger minutes = time / 60;
    return [NSString stringWithFormat:@"%02ld:%02ld",(long)minutes,(long)seconds];
}

#pragma mark - action

- (void)reloadVideo
{
    [self loadVideoWithStreamURL:_streamURL];
    [self hideErrorView];
}

- (void)reloadCurrentVideo
{
    self.videoPlayer.track.continueLastWatchTime = YES;
    [self.videoPlayer reloadCurrentVideoTrack];
    [self hideErrorView];
}

- (void)singleTapAction:(UITapGestureRecognizer *)tap
{
    if ([self isControlViewHidden]) {
        [self showControlViewWithAnimation:YES];
    }else {
        [self hideControlViewWithAnimation:YES];
    }
    [self handelControllerEvent:TYVideoPlayerControllerEventTapScreen];
}

- (void)goBackAction
{
    //改动的
//    [self goBack];
//原来的
    if (self.isFullScreen){
        [self changeToOrientation:UIInterfaceOrientationPortrait];
    }else {
        [self goBack];
    }
}

- (void)goBack
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlView) object:nil];
    [self stop];
    
    if ([_delegate respondsToSelector:@selector(videoPlayerControllerShouldCustomGoBack:)]
         && [_delegate videoPlayerControllerShouldCustomGoBack:self]) {
        return;
    }
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
#pragma mark - TYVideoPlayerDelegate

// 状态改变
- (void)videoPlayer:(TYVideoPlayer*)videoPlayer track:(id<TYVideoPlayerTrack>)track didChangeToState:(TYVideoPlayerState)toState fromState:(TYVideoPlayerState)fromState
{
    // update UI
    [self playerViewDidChangeToState:toState];
    
    // player control
    [self player:videoPlayer didChangeToState:toState];
}

// 更新时间
- (void)videoPlayer:(TYVideoPlayer *)videoPlayer track:(id<TYVideoPlayerTrack>)track didUpdatePlayTime:(NSTimeInterval)playTime
{
    if (_isDraging) {
        return;
    }
    
    NSString *time = [self covertToStringWithTime:playTime];
    [_controlView setCurrentVideoTime:time];
    NSTimeInterval duration = [videoPlayer duration];
    NSTimeInterval availableDuration = [videoPlayer availableDuration];
    if (duration <= 0) {
        [_controlView setSliderProgress:0];
        [_controlView setBufferProgress:0];
    }else {
        [_controlView setSliderProgress:playTime/duration];
        [_controlView setBufferProgress:MIN(availableDuration/duration, 1.0)];
    }
}

// 播放结束
- (void)videoPlayer:(TYVideoPlayer *)videoPlayer didEndToPlayTrack:(id<TYVideoPlayerTrack>)track
{
    NSLog(@"播放完成！");
    
    [_controlView setPlayBtnHidden:YES];
    
    __weak typeof(self) weakSelf = self;
    [self showErrorViewWithTitle:NSLocalizedString(@"重播", nil) actionHandle:^{
        [weakSelf reloadVideo];
    }];
    
    if ([_delegate respondsToSelector:@selector(videoPlayerController:endToPlayURL:)]) {
        [_delegate videoPlayerController:self endToPlayURL:videoPlayer.track.streamURL];
    }
}

// 播放错误
- (void)videoPlayer:(TYVideoPlayer *)videoPlayer track:(id<TYVideoPlayerTrack>)track receivedErrorCode:(TYVideoPlayerErrorCode)errorCode error:(NSError *)error
{
    NSLog(@"videoPlayer receivedErrorCode %@",error);
    
    if ([self autoRetryLoadCurrentVideo]) {
        return;
    }
    [_loadingView stopAnimation];
    [_controlView setPlayBtnHidden:YES];
    
    __weak typeof(self) weakSelf = self;
    [self showErrorViewWithTitle:NSLocalizedString(@"视频播放失败,重试", nil) actionHandle:^{
        [weakSelf reloadCurrentVideo];
    }];
}

// 播放超时
- (void)videoPlayer:(TYVideoPlayer *)videoPlayer track:(id<TYVideoPlayerTrack>)track receivedTimeout:(TYVideoPlayerTimeOut)timeout
{
    NSLog(@"videoPlayer receivedTimeout %ld",(unsigned long)timeout);
    
    if ([self autoRetryLoadCurrentVideo]) {
        return;
    }
    [_loadingView stopAnimation];
    [_controlView setPlayBtnHidden:YES];
    
    __weak typeof(self) weakSelf = self;
    [self showErrorViewWithTitle:NSLocalizedString(@"视频播放超时,重试", nil) actionHandle:^{
        [weakSelf reloadCurrentVideo];
    }];
}

#pragma mark - TYVideoControlViewDelegate

- (BOOL)videoControlView:(TYVideoControlView *)videoControlView shouldResponseControlEvent:(TYVideoControlEvent)event
{
     switch (event) {
         case TYVideoControlEventPlay:
             return _videoPlayer.state == TYVideoPlayerStateContentPaused || _videoPlayer.state == TYVideoPlayerStateContentReadyToPlay;
         case TYVideoControlEventSuspend:
             return [_videoPlayer isPlaying];
         default:
             return YES;
     }
}

- (void)videoControlView:(TYVideoControlView *)videoControlView recieveControlEvent:(TYVideoControlEvent)event
{
    switch (event) {
        case TYVideoControlEventBack:
            [self goBackAction];
            break;
        case TYVideoControlEventFullScreen:
            [self changeToOrientation:UIInterfaceOrientationLandscapeRight];
            [self handelControllerEvent:TYVideoPlayerControllerEventRotateScreen];
            break;
        case TYVideoControlEventNormalScreen:
            [self changeToOrientation:UIInterfaceOrientationPortrait];
            [self handelControllerEvent:TYVideoPlayerControllerEventRotateScreen];
            break;
        case TYVideoControlEventPlay:
            [self play];
            [self handelControllerEvent:TYVideoPlayerControllerEventPlay];
            break;
        case TYVideoControlEventSuspend:
            [self pause];
            [self handelControllerEvent:TYVideoPlayerControllerEventSuspend];
            break;
        default:
            break;
    }
}

- (void)videoControlView:(TYVideoControlView *)videoControlView state:(TYSliderState)state sliderToProgress:(CGFloat)progress
{
    switch (state) {
        case TYSliderStateBegin:
            _isDraging = YES;
            break;
        case TYSliderStateDraging:
        {
            NSTimeInterval sliderTime = floor([_videoPlayer duration]*progress);
            NSString *time = [self covertToStringWithTime:sliderTime];
            [_controlView setCurrentVideoTime:time];
            break;
        }
        case TYSliderStateEnd:
        {
            _isDraging = NO;
            NSTimeInterval sliderTime = floor([_videoPlayer duration]*progress);
            NSString *time = [self covertToStringWithTime:sliderTime];
            [_videoPlayer seekToTime:sliderTime];
            [_controlView setCurrentVideoTime:time];
            [self hideControlViewWithAnimation:YES];
            break;
        }
        default:
            break;
    }
}

- (void)downloadViedo
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            switch (status) {
                case PHAuthorizationStatusAuthorized: //已获取权限
                    //                    NSLog(@"有权限");
                {
                    //下载视频
                    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                    [library writeVideoAtPathToSavedPhotosAlbum:self.streamURL
                                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                                    if (error) {
                                                        NSLog(@"Save video fail:%@",error);
                                                    } else {
                                                        [XHToast showCenterWithText:NSLocalizedString(@"保存成功", nil)];
                                                    }
                                                }];
                }
                    break;
                    
                case PHAuthorizationStatusDenied: //用户已经明确否认了这一照片数据的应用程序访问
                    //                    NSLog(@"无权限1");
                    {
                        // 创建一个UIAlertView并显示出来
                        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"已为“视频云眼”关闭照片", nil) message:NSLocalizedString(@"您可以在“设置”中为此应用打开照片", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"设置", nil) otherButtonTitles:NSLocalizedString(@"好", nil),nil];
                        [alertview show];
                    }
                    
                    break;
                    
                case PHAuthorizationStatusRestricted://此应用程序没有被授权访问的照片数据。可能是家长控制权限
                    //                    NSLog(@"无权限2");
                    {
                        // 创建一个UIAlertView并显示出来
                        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"已为“视频云眼”关闭照片", nil) message:NSLocalizedString(@"您可以在“设置”中为此应用打开照片", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"设置", nil) otherButtonTitles:NSLocalizedString(@"好", nil),nil];
                        [alertview show];
                    }
                    
                    break;
                    
                default://其他。。。
                    break;
            }
        });
    }];
}

- (void)loadLocVideo
{
    //下载视频
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:self.streamURL
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (error) {
                                        NSLog(@"Save video fail:%@",error);
                                    } else {
                                        [XHToast showCenterWithText:NSLocalizedString(@"保存成功", nil)];
                                    }
                                }];
}

#pragma mark - Autorotate

- (void)changeToOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        UIInterfaceOrientation val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self stop];
}

//监听点击事件 代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([btnTitle isEqualToString:NSLocalizedString(@"设置", nil)]) {
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }
}

@end
