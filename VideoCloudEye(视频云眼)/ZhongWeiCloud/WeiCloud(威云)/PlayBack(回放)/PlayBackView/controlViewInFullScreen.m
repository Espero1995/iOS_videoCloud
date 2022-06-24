//
//  controlViewInFullScreen.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/1/22.
//  Copyright © 2018年 张策. All rights reserved.
//
#define FunctionViewWidth  self.frame.size.width
#define spacing FunctionViewWidth/27
#define BtnW FunctionViewWidth/9
#import "controlViewInFullScreen.h"

@interface controlViewInFullScreen()
@property (nonatomic,assign) int isCloudDeck;
@property (nonatomic,assign) int isTalk;
@property (nonatomic,assign) int remake;
@end

@implementation controlViewInFullScreen

-(id)initLayoutOfFeature:(int)isTalk andCloudDeck:(int)isCloudDeck
{
    //调用父类的init方法进行初始化，将初始化得到的对象赋值给self对象
    //如果self对象不为nil，表明父类init方法初始化成功
    if (self = [super init]) {
        //对该对象进行赋初始值
        _isCloudDeck = isCloudDeck;
        _isTalk = isTalk;
    }

    return self;
}



 -(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];//clearColor
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.remake == 0) {
        [self initFunctionViewLayout:0];//功能按钮的视图布局
    }else{
        [self initFunctionViewLayout:1];//功能按钮的视图布局
    }
//    [self initFunctionViewLayout:0];//功能按钮的视图布局
}

//==========================init==========================
#pragma mark ----- 功能按钮的视图布局
- (void)initFunctionViewLayout:(int)isRemake{
    [self addSubview:self.functionView];
    [self.functionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(0);
        make.top.equalTo(self.mas_top).offset(0);
        make.size.mas_equalTo(CGSizeMake(FunctionViewWidth, FunctionViewWidth/9));
    }];

    //1.暂停按钮
    [self.functionView addSubview:self.suspendBtn];
    [self.suspendBtn addTarget:self action:@selector(suspendClick:) forControlEvents:UIControlEventTouchUpInside];
    if (isRemake == 0) {
        [self.suspendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.functionView.mas_centerY);
            if (_isCloudDeck == 1 && _isTalk == 1) { //2个均不消失
                self.lockRockerBtn.hidden = NO;
                self.talkBtn.hidden = NO;
                make.left.equalTo(self.functionView.mas_left).offset(0);
            }else if (_isCloudDeck == 0 && _isTalk == 1){//云台消失，对讲不消失
                self.lockRockerBtn.hidden = YES;
                self.talkBtn.hidden = NO;
                make.left.equalTo(self.functionView.mas_left).offset(spacing+BtnW);
            }else if (_isCloudDeck == 1 &&_isTalk == 0){//云台不消失，对讲消失
                self.lockRockerBtn.hidden = NO;
                self.talkBtn.hidden = YES;
                make.left.equalTo(self.functionView.mas_left).offset(spacing+BtnW);
            }else{//2个均消失
                self.lockRockerBtn.hidden = YES;
                self.talkBtn.hidden = YES;
                make.left.equalTo(self.functionView.mas_left).offset(2*spacing+2*BtnW);
            }
            make.size.mas_equalTo(CGSizeMake(BtnW, BtnW));
        }];
    }else{
        [self.suspendBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.functionView.mas_centerY);
            if (_isCloudDeck == 1 && _isTalk == 1) { //2个均不消失
                self.lockRockerBtn.hidden = NO;
                self.talkBtn.hidden = NO;
                make.left.equalTo(self.functionView.mas_left).offset(0);
            }else if (_isCloudDeck == 0 && _isTalk == 1){//云台消失，对讲不消失
                self.lockRockerBtn.hidden = YES;
                self.talkBtn.hidden = NO;
                make.left.equalTo(self.functionView.mas_left).offset(spacing+BtnW);
            }else if (_isCloudDeck == 1 &&_isTalk == 0){//云台不消失，对讲消失
                self.lockRockerBtn.hidden = NO;
                self.talkBtn.hidden = YES;
                make.left.equalTo(self.functionView.mas_left).offset(spacing+BtnW);
            }else{//2个均消失
                self.lockRockerBtn.hidden = YES;
                self.talkBtn.hidden = YES;
                make.left.equalTo(self.functionView.mas_left).offset(2*spacing+2*BtnW);
            }
            make.size.mas_equalTo(CGSizeMake(BtnW, BtnW));
        }];
    }
    
    //2.音量按钮
    [self.functionView addSubview:self.voiceBtn];
    [self.voiceBtn addTarget:self action:@selector(voiceClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.voiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.functionView.mas_centerY);
        make.left.equalTo(self.suspendBtn.mas_right).offset(spacing);
        make.size.mas_equalTo(CGSizeMake(BtnW, BtnW));
    }];
    
    //3.锁定滚轮按钮
    [self.functionView addSubview:self.lockRockerBtn];
    [self.lockRockerBtn addTarget:self action:@selector(lockRockerClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.lockRockerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.functionView.mas_centerY);
        make.left.equalTo(self.voiceBtn.mas_right).offset(spacing);
        make.size.mas_equalTo(CGSizeMake(BtnW, BtnW));
    }];

    
   /*
    *  description : 以下四个按钮根据高清按钮从右向左布局
    */
    
    //7.高清
    [self.functionView addSubview:self.hdBtn];
    [self.hdBtn addTarget:self action:@selector(hdClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.hdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.functionView.mas_centerY);
        make.right.equalTo(self.functionView.mas_right).offset(0);
        make.size.mas_equalTo(CGSizeMake(BtnW, BtnW));
    }];
    
    //6.录屏
    [self.functionView addSubview:self.videoBtn];
    [self.videoBtn addTarget:self action:@selector(videoClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.functionView.mas_centerY);
        make.right.equalTo(self.hdBtn.mas_left).offset(-spacing);
        make.size.mas_equalTo(CGSizeMake(BtnW, BtnW));
    }];
    
    //5.截图
    [self.functionView addSubview:self.screenshotBtn];
    [self.screenshotBtn addTarget:self action:@selector(screenshotClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.screenshotBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.functionView.mas_centerY);
        make.right.equalTo(self.videoBtn.mas_left).offset(-spacing);
        make.size.mas_equalTo(CGSizeMake(BtnW, BtnW));
    }];
    
    //4.麦克风
    [self.functionView addSubview:self.talkBtn];
    [self.talkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.functionView.mas_centerY);
        make.right.equalTo(self.screenshotBtn.mas_left).offset(-spacing);
        make.size.mas_equalTo(CGSizeMake(BtnW, BtnW));
    }];
}



//==========================method==========================
- (void)changeLayoutOfFeature:(int)isTalk andCloudDeck:(int)isCloudDeck{
    //对该对象进行赋初始值
    _isCloudDeck = isCloudDeck;
    _isTalk = isTalk;
    //功能按钮的视图布局
    [self initFunctionViewLayout:1];
    self.remake = 1;
}


#pragma mark ----- 曝露按钮接口
//暂停按钮的点击事件
- (void)suspendClick:(id)sender{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(suspendBtnClick:)]) {
        [self.delegate suspendBtnClick:sender];
    }
}
//音量按钮的点击事件
- (void)voiceClick:(id)sender{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(voiceBtnClick:)]) {
        [self.delegate voiceBtnClick:sender];
    }
}
//锁定滚轮按钮的点击事件
- (void)lockRockerClick:(id)sender{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(lockRockerBtnClick:)]) {
        [self.delegate lockRockerBtnClick:sender];
    }
}
//麦克风按钮的点击事件
- (void)LongPress_full_target:(UILongPressGestureRecognizer *)longPress{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(LongPress_full_target:)]) {
        [self.delegate LongPress_full_target:longPress];
    }
}
//截图按钮的点击事件
- (void)screenshotClick:(id)sender{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(screenshotBtnClick:)]) {
        [self.delegate screenshotBtnClick:sender];
    }
}
//录屏按钮的点击事件
- (void)videoClick:(id)sender{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(videoBtnClick:)]) {
        [self.delegate videoBtnClick:sender];
    }
}
//高清切换按钮的点击事件
- (void)hdClick:(id)sender{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(hdBtnClick:)]) {
        [self.delegate hdBtnClick:sender];
    }
}
//==========================lazy loading==========================
#pragma mark -getter && setter
//容纳以下控件的View
-(UIView *)functionView{
    if (!_functionView) {
        _functionView = [[UIView alloc]init];
        _functionView.backgroundColor = [UIColor clearColor];
    }
    return _functionView;
}
//1.暂停按钮
-(UIButton *)suspendBtn{
    if (!_suspendBtn) {
        _suspendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_suspendBtn setBackgroundImage:[UIImage imageNamed:@"realTimePause_n"] forState:UIControlStateNormal];
    }
    return _suspendBtn;
}

//2.音量
-(UIButton *)voiceBtn{
    if (!_voiceBtn) {
        _voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_voiceBtn setBackgroundImage:[UIImage imageNamed:@"realTimejingyin_n"] forState:UIControlStateNormal];
    }
    return _voiceBtn;
}

//3.锁定滚轮按钮
-(UIButton *)lockRockerBtn{
    if (!_lockRockerBtn) {
        _lockRockerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockRockerBtn setBackgroundImage:[UIImage imageNamed:@"yuntai_n"] forState:UIControlStateNormal];
        [_lockRockerBtn setBackgroundImage:[UIImage imageNamed:@"yuntai_h"] forState:UIControlStateHighlighted];
        [_lockRockerBtn setBackgroundImage:[UIImage imageNamed:@"yuntai_h"] forState:UIControlStateSelected];
    }
    return _lockRockerBtn;
}

//4.麦克风
-(UIButton *)talkBtn{
    if (!_talkBtn) {
        _talkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_talkBtn setBackgroundImage:[UIImage imageNamed:@"realTimeTalk_n"] forState:UIControlStateNormal];
       // [_talkBtn addTarget:self action:@selector(talkWithLongPress:) forControlEvents:UIControlEventAllEvents];
        UILongPressGestureRecognizer * longPress_Full = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(LongPress_full_target:)];
        longPress_Full.minimumPressDuration = 1.0f;
        [_talkBtn addGestureRecognizer:longPress_Full];
    }
    return _talkBtn;
}

//5.截图
-(UIButton *)screenshotBtn{
    if (!_screenshotBtn) {
        _screenshotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_screenshotBtn setBackgroundImage:[UIImage imageNamed:@"realTimeShotscreenshot_n"] forState:UIControlStateNormal];
        [_screenshotBtn setBackgroundImage:[UIImage imageNamed:@"realTimeShotscreenshot_h"] forState:UIControlStateHighlighted];
    }
    return _screenshotBtn;
}

//6.录屏
-(UIButton *)videoBtn{
    if (!_videoBtn) {
        _videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoBtn setBackgroundImage:[UIImage imageNamed:@"zirealTimeVideo_n"] forState:UIControlStateNormal];
    }
    return _videoBtn;
}

//7.高清
-(UIButton *)hdBtn{
    if (!_hdBtn) {
        _hdBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_hd", nil)] forState:UIControlStateNormal];
    }
    return _hdBtn;
}

@end
