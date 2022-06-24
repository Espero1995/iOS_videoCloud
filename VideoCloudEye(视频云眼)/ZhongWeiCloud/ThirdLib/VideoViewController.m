//
//  VideoViewController.m
//  SRVideoPlayerDemo
//
//  Created by 郭伟林 on 17/1/5.
//  Copyright © 2017年 SR. All rights reserved.
//

#import "VideoViewController.h"
#import "ZCTabBarController.h"
#import "TYVideoPlayerController.h"
#import "AppDelegate.h"

@interface VideoViewController ()<TYVideoPlayerControllerDelegate>
@property (nonatomic, weak) TYVideoPlayerController *playerController;

@end

@implementation VideoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self addVideoPlayerController];
//    [self showVideoPlayer];
    [self loadLocalVideo];
}
- (void)addVideoPlayerController
{
    TYVideoPlayerController *playerController = [[TYVideoPlayerController alloc]init];
    //playerController.shouldAutoplayVideo = NO;
    playerController.delegate = self;
    [self addChildViewController:playerController];
    [self.view addSubview:playerController.view];
    _playerController = playerController;
}
- (void)loadLocalVideo
{
    // 本地播放
//    NSString* path = [[NSBundle mainBundle] pathForResource:@"test_264" ofType:@"mp4"];
//    if (!path) {
//        UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"本地文件不存在！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alerView show];
//        return;
//    }
//    NSURL* streamURL = [NSURL fileURLWithPath:path];
    [_playerController loadVideoWithStreamURL:self.videoURL];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
            AppDelegate *appdelegete = (AppDelegate *)[UIApplication sharedApplication].delegate;
            appdelegete.allowRotation = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    AppDelegate *appdelegete = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegete.allowRotation = NO;;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect frame = self.view.frame;
    if (_playerController.isFullScreen) {
        _playerController.view.frame = CGRectMake(0, 0, MAX(CGRectGetHeight(frame), CGRectGetWidth(frame)), MIN(CGRectGetHeight(frame), CGRectGetWidth(frame)));
    }else {
        _playerController.view.frame = CGRectMake(0, 0, MIN(CGRectGetHeight(frame), CGRectGetWidth(frame)), MIN(CGRectGetHeight(frame), CGRectGetWidth(frame))*9/16);
    }
}

- (BOOL)prefersStatusBarHidden
{
    if (!_playerController || !_playerController.isFullScreen) {
        return NO;
    }
    return [_playerController isControlViewHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation )preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}
#pragma mark - delegate

- (void)videoPlayerController:(TYVideoPlayerController *)videoPlayerController readyToPlayURL:(NSURL *)streamURL
{
    
}

- (void)videoPlayerController:(TYVideoPlayerController *)videoPlayerController endToPlayURL:(NSURL *)streamURL
{
    
}

- (void)videoPlayerController:(TYVideoPlayerController *)videoPlayerController handleEvent:(TYVideoPlayerControllerEvent)event
{
    switch (event) {
        case TYVideoPlayerControllerEventTapScreen:
            [self setNeedsStatusBarAppearanceUpdate];
            break;
        default:
            break;
    }
}

#pragma mark - rotate

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //发生在翻转开始之前
    CGRect bounds = self.view.frame;
    [UIView animateWithDuration:duration animations:^{
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            _playerController.view.frame = CGRectMake(0, 0, MAX(CGRectGetHeight(bounds), CGRectGetWidth(bounds)), MIN(CGRectGetHeight(bounds), CGRectGetWidth(bounds)));
        }else {
            _playerController.view.frame = CGRectMake(0, 0, MIN(CGRectGetHeight(bounds), CGRectGetWidth(bounds)), MIN(CGRectGetHeight(bounds), CGRectGetWidth(bounds))*9/16);
        }
    }];
}

@end
