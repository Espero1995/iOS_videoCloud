//
//  TYPlayerControlView.m
//  TYVideoPlayerDemo
//
//  Created by tany on 16/7/5.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYVideoControlView.h"
#import "TYVideoTitleView.h"
#import "TYVideoInfoView.h"
#import "TYVideoBottomView.h"
#import "TYViedoToolBarView.h"
#define kBackBtnHeight 35
#define kBackBtnTopEdage 12
#define kBackBtnLeftEdage 10
#define kTitleViewTopEdge 20
#define kTitleViewHight 28
#define kBottomViewBottomEdge 4
#define kBottomViewHeight 26
#define kSuspendBtnHeight 60

@interface TYVideoControlView ()

@property (nonatomic, weak) UIView *contentView;

@property (nonatomic, weak) TYVideoTitleView *titleView;

@property (nonatomic, weak) TYVideoInfoView *videoInfoView;

@property (nonatomic, weak) TYVideoBottomView *bottomView;

@property (nonatomic, weak) UIButton *suspendBtn;

@property (nonatomic, weak) UILabel *viedoInfoLabel;

@property (nonatomic, strong) TYViedoToolBarView *toolBarView;
@end

@implementation TYVideoControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addContentView];
        
        [self addTitleView];
        
        [self addVideoInfoView];
        
        [self addBottomView];
        
        [self addSuspendButton];
        
        [self addToolBarView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self addContentView];
        
        [self addTitleView];
        
        [self addVideoInfoView];
        
        [self addBottomView];
        
        [self addSuspendButton];
    }
    return self;
}

#pragma mark - add subvuew

- (void)addContentView
{
    UIView *contentView = [[UIView alloc]init];
    [self addSubview:contentView];
    _contentView = contentView;
}

- (void)addTitleView
{
    TYVideoTitleView *titleView = [[TYVideoTitleView alloc]init];
    [titleView.backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:titleView];
    _titleView = titleView;
}

- (void)addVideoInfoView
{
    TYVideoInfoView *videoInfoView = [[TYVideoInfoView alloc]init];
    [videoInfoView setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.5]];
    [_contentView addSubview:videoInfoView];
    _videoInfoView = videoInfoView;
}

- (void)addBottomView
{
    TYVideoBottomView *bottomView = [[TYVideoBottomView alloc]init];
    bottomView.curTimeLabel.text = @"00:00";
    bottomView.totalTimeLabel.text = @"00:00";
    [bottomView.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView.progressSlider addTarget:self action:@selector(sliderBeginDraging:) forControlEvents:UIControlEventTouchDown];
    [bottomView.progressSlider addTarget:self action:@selector(sliderIsDraging:) forControlEvents:UIControlEventValueChanged];
    [bottomView.progressSlider addTarget:self action:@selector(sliderEndDraging:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
    [_contentView addSubview:bottomView];
    _bottomView = bottomView;
}
//工具栏
- (void)addToolBarView
{
    TYViedoToolBarView *toolBarView = [[TYViedoToolBarView alloc]init];
    [toolBarView.saveBtn addTarget:self action:@selector(saveVideoAction) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:toolBarView];
    _toolBarView = toolBarView;
}

- (void)addSuspendButton
{
    UIButton *suspendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    suspendBtn.selected = YES;
    suspendBtn.frame = CGRectMake(0, 0, kSuspendBtnHeight, kSuspendBtnHeight);
    suspendBtn.adjustsImageWhenHighlighted = NO;
    [suspendBtn setBackgroundImage:[UIImage imageNamed:@"TYVideoPlayer.bundle/player_pauseBig"] forState:UIControlStateNormal];
    [suspendBtn setBackgroundImage:[UIImage imageNamed:@"TYVideoPlayer.bundle/player_playBig"] forState:UIControlStateSelected];
    [suspendBtn addTarget:self action:@selector(suspendAction:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:suspendBtn];
    _suspendBtn = suspendBtn;
}

#pragma mark - pravite

- (BOOL)isOrientationPortrait
{
    return [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown;
}

- (void)recieveControlEvent:(TYVideoControlEvent)event
{
    if ([_delegate respondsToSelector:@selector(videoControlView:shouldResponseControlEvent:)]
        && ![_delegate videoControlView:self shouldResponseControlEvent:event]) {
        
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(videoControlView:recieveControlEvent:)]) {
        [_delegate videoControlView:self recieveControlEvent:event];
    }
}

#pragma mark - public

- (void)setTitle:(NSString *)title
{
    _titleView.titleLabel.text = title;
}

- (void)setViedoInfoTitle:(NSString *)title
{
//    _videoInfoView.viedoInfoLabel.text = title;
    
}

- (void)setViedoToolBarView:(NSString *)title
{
    _toolBarView.viedoInfoLabel.text = title;
}

- (void)setCurrentVideoTime:(NSString *)time
{
    _bottomView.curTimeLabel.text = time;
}

- (void)setTotalVideoTime:(NSString *)time
{
    _bottomView.totalTimeLabel.text = time;
}

- (void)setSliderProgress:(CGFloat)progress
{
    _bottomView.progressSlider.value = progress;
}

- (void)setBufferProgress:(CGFloat)progress
{
    [_bottomView.progressView setProgress:progress animated:YES];
}

- (void)setFullScreen:(BOOL)fullScreen
{
    _bottomView.fullScreenBtn.hidden = fullScreen;
}

- (void)setPlayBtnState:(BOOL)isPlayState
{
    _suspendBtn.selected = isPlayState;
}

- (void)setPlayBtnHidden:(BOOL)hidden
{
    _suspendBtn.hidden = hidden;
}

- (BOOL)contentViewHidden
{
    return _contentView.hidden;
}

- (void)setContentViewHidden:(BOOL)hidden
{
    _contentView.hidden = hidden;
}

- (void)setTimeSliderHidden:(BOOL)hidden
{
    _bottomView.curTimeLabel.hidden = hidden;
    _bottomView.totalTimeLabel.hidden = hidden;
    _bottomView.progressSlider.hidden = hidden;
    _bottomView.progressView.hidden = hidden;
}

#pragma mark - action

- (void)sliderBeginDraging:(UISlider *)sender
{
    if ([_delegate respondsToSelector:@selector(videoControlView:state:sliderToProgress:)]) {
        
        [_delegate videoControlView:self state:TYSliderStateBegin sliderToProgress:sender.value];
    }
}

- (void)sliderIsDraging:(UISlider *)sender
{
    if ([_delegate respondsToSelector:@selector(videoControlView:state:sliderToProgress:)]) {
        [_delegate videoControlView:self state:TYSliderStateDraging sliderToProgress:sender.value];
    }
}

- (void)sliderEndDraging:(UISlider *)sender
{
    if ([_delegate respondsToSelector:@selector(videoControlView:state:sliderToProgress:)]) {
        [_delegate videoControlView:self state:TYSliderStateEnd sliderToProgress:sender.value];
    }
}

- (void)fullScreenAction:(UIButton *)sender
{
    [self recieveControlEvent:[self isOrientationPortrait] ? TYVideoControlEventFullScreen : TYVideoControlEventNormalScreen];
}

- (void)backAction:(UIButton *)sender
{
    [self recieveControlEvent:TYVideoControlEventBack];
}

- (void)suspendAction:(UIButton *)sender
{
    [self recieveControlEvent:sender.isSelected ? TYVideoControlEventPlay:TYVideoControlEventSuspend];
}

- (void)saveVideoAction
{//downloadViedo
    NSLog(@"保存录像");
//    if ([_delegate respondsToSelector:@selector(downloadViedo)]) {
//        [_delegate downloadViedo];
//    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadViedo)]) {
        [self.delegate downloadViedo];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _contentView.frame = self.bounds;
    if (iPhone_X_) {
        _titleView.frame = CGRectMake(0, 50, CGRectGetWidth(_contentView.frame), kTitleViewHight);
    }else{
        _titleView.frame = CGRectMake(0, 30, CGRectGetWidth(_contentView.frame), kTitleViewHight);
    }
    
//    _videoInfoView.frame = CGRectMake(0, CGRectGetMaxY(_contentView.frame)-70, CGRectGetWidth(_contentView.frame), 40);//TODO
//    _bottomView.frame = CGRectMake(0, CGRectGetHeight(_contentView.frame) - kBottomViewHeight - kBottomViewBottomEdge, CGRectGetWidth(_contentView.frame), kBottomViewHeight);
    _bottomView.frame = CGRectMake(0, CGRectGetHeight(_contentView.frame) - kBottomViewHeight - kBottomViewBottomEdge - 70, CGRectGetWidth(_contentView.frame), kBottomViewHeight);
    _suspendBtn.center = _contentView.center;
    _toolBarView.frame = CGRectMake(0, CGRectGetHeight(_contentView.frame) - 70, CGRectGetWidth(_contentView.frame), 70);
}

@end
