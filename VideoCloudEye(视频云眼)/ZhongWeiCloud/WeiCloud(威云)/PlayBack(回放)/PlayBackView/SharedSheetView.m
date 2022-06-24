//
//  SharedSheetView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/12.
//  Copyright © 2018年 张策. All rights reserved.
//
#define ActionSheetHeight 0.3*iPhoneHeight
#define BtnWidthAndHeight 0.2*iPhoneWidth
#import "SharedSheetView.h"
@interface SharedSheetView ()
@property (nonatomic,strong) UIView *actionSheetView;
@property (nonatomic,strong) UIButton *phoneBtn;//手机按钮
@property (nonatomic,strong) UIButton *weChatBtn;//微信按钮
@property (nonatomic,strong) UIButton *cancelBtn;//取消按钮
@end

@implementation SharedSheetView
- (instancetype)initWithframe:(CGRect) frame
{
    self = [super initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.actionSheetView];
        [self.actionSheetView addSubview:self.cancelBtn];
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.actionSheetView.mas_centerX);
            make.bottom.equalTo(self.actionSheetView.mas_bottom).offset(-0.1*ActionSheetHeight);
            make.size.mas_equalTo(CGSizeMake(0.85*iPhoneWidth, 45));
        }];
        [self.actionSheetView addSubview:self.phoneBtn];
        [self.phoneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.actionSheetView.mas_centerY).offset(-30);
            make.left.equalTo(self.actionSheetView.mas_left).offset(0.17*iPhoneWidth);
            make.size.mas_equalTo(CGSizeMake(0.2*iPhoneWidth+30, BtnWidthAndHeight+10));
        }];
        //手机好友标题的偏移量
        self.phoneBtn.titleEdgeInsets = UIEdgeInsetsMake(self.phoneBtn.imageView.frame.size.height+5, -self.phoneBtn.imageView.bounds.size.width, 0, 0);
        //手机好友按钮图片的偏移量
        self.phoneBtn.imageEdgeInsets = UIEdgeInsetsMake(0, self.phoneBtn.titleLabel.frame.size.width/2, self.phoneBtn.titleLabel.frame.size.height+5, -self.phoneBtn.titleLabel.frame.size.width/2);
        
        [self.actionSheetView addSubview:self.weChatBtn];
        [self.weChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.actionSheetView.mas_centerY).offset(-30);
            make.right.equalTo(self.actionSheetView.mas_right).offset(-0.17*iPhoneWidth);
            make.size.mas_equalTo(CGSizeMake(0.2*iPhoneWidth+30, BtnWidthAndHeight+10));
        }];
        //微信好友标题的偏移量
        self.weChatBtn.titleEdgeInsets = UIEdgeInsetsMake(self.weChatBtn.imageView.frame.size.height+5, -self.weChatBtn.imageView.bounds.size.width, 0, 0);
        //微信好友按钮图片的偏移量
        self.weChatBtn.imageEdgeInsets = UIEdgeInsetsMake(0, self.weChatBtn.titleLabel.frame.size.width/2, self.weChatBtn.titleLabel.frame.size.height+5, -self.weChatBtn.titleLabel.frame.size.width/2);
        
    }
    return self;
}
#pragma mark - 手势触控
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.actionSheetView];
    if (![self.actionSheetView.layer containsPoint:point]) {
        [self shareSheetViewDismiss];
    }
}

#pragma mark - 显示
- (void)shareSheetViewShow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [UIView animateWithDuration:0.3 animations:^{
        self.actionSheetView.frame = CGRectMake(0, iPhoneHeight-ActionSheetHeight, iPhoneWidth, ActionSheetHeight);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - 消失
- (void)shareSheetViewDismiss{
    //动画效果淡出
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        self.actionSheetView.frame = CGRectMake(0, iPhoneHeight, iPhoneWidth, ActionSheetHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


#pragma mark - 手机好友点击事件
- (void)phoneBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sharetoPhoneClick)]) {
        [self shareSheetViewDismiss];
        [self.delegate sharetoPhoneClick];
    }
}

#pragma mark - 微信好友点击事件
- (void)weChatBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sharetoWeChatClick)]) {
        [self shareSheetViewDismiss];
        [self.delegate sharetoWeChatClick];
    }
}

#pragma mark - 取消点击事件
- (void)cancelBtnClick
{
    [self shareSheetViewDismiss];
}

#pragma mark - getter && setter
- (UIView *)actionSheetView
{
    if (!_actionSheetView) {
        _actionSheetView = [[UIView alloc]initWithFrame:CGRectMake(0, iPhoneHeight, iPhoneWidth, ActionSheetHeight)];
        _actionSheetView.backgroundColor = [UIColor whiteColor];
    }
    return _actionSheetView;
}
//手机好友按钮
- (UIButton *)phoneBtn
{
    if (!_phoneBtn) {
        _phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _phoneBtn.backgroundColor = [UIColor clearColor];
        [_phoneBtn setImage:[UIImage imageNamed:@"phoneShare"] forState:UIControlStateNormal];
        [_phoneBtn setTitle:NSLocalizedString(@"设备分享", nil) forState:UIControlStateNormal];
        [_phoneBtn setTitleColor:RGB(0, 0, 0) forState:UIControlStateNormal];
        _phoneBtn.titleLabel.font = FONT(14);
        [_phoneBtn addTarget:self action:@selector(phoneBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _phoneBtn;
}

//微信好友按钮
- (UIButton *)weChatBtn
{
    if (!_weChatBtn) {
        _weChatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _weChatBtn.backgroundColor = [UIColor clearColor];
        [_weChatBtn setImage:[UIImage imageNamed:@"wechatShare"] forState:UIControlStateNormal];
        [_weChatBtn setTitle:NSLocalizedString(@"视频分享", nil) forState:UIControlStateNormal];
        [_weChatBtn setTitleColor:RGB(0, 0, 0) forState:UIControlStateNormal];
        _weChatBtn.titleLabel.font = FONT(14);
        [_weChatBtn addTarget:self action:@selector(weChatBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _weChatBtn;
}

//取消按钮
- (UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:RGB(0, 0, 0) forState:UIControlStateNormal];
        _cancelBtn.layer.cornerRadius = 22.5f;
        _cancelBtn.layer.borderColor = RGB(200, 200, 200).CGColor;
        _cancelBtn.layer.borderWidth = 1.f;
        [_cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}


@end
