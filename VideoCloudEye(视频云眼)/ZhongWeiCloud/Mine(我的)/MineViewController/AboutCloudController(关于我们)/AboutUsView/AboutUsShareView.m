//
//  AboutUsShareView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/11/21.
//  Copyright © 2018 张策. All rights reserved.
//
#define ShareViewWidth 0.9*iPhoneWidth
#define ShareViewHeight (0.8*ShareViewWidth+100)
#import "AboutUsShareView.h"
@interface AboutUsShareView ()
@property (nonatomic,strong) UIView *shareQRCodeView;
@property (nonatomic,strong) UILabel *tipLb;//提示
@property (nonatomic,strong) UIView *lineView;//线条
@property (nonatomic,strong) UIImageView *qrCodeImgView;//二维码
@property (nonatomic,strong) UILabel *bottomtipLb;//底部提示语
@end

@implementation AboutUsShareView

- (instancetype)initWithframe:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.shareQRCodeView];
        
        [self.shareQRCodeView addSubview:self.tipLb];
        [self.tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.shareQRCodeView.mas_centerX);
            make.top.equalTo(self.shareQRCodeView.mas_top).offset(10);
        }];
        [self.shareQRCodeView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.shareQRCodeView.mas_centerX);
            make.top.equalTo(self.tipLb.mas_bottom).offset(10);
            make.size.mas_equalTo(CGSizeMake(ShareViewWidth, 0.5));
        }];
        [self.shareQRCodeView addSubview:self.qrCodeImgView];
        [self.qrCodeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.shareQRCodeView.mas_centerX);
            make.top.equalTo(self.lineView.mas_bottom).offset(20);
            make.size.mas_equalTo(CGSizeMake(0.8*ShareViewWidth, 0.8*ShareViewWidth));
        }];
        [self.shareQRCodeView addSubview:self.bottomtipLb];
        [self.bottomtipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.shareQRCodeView.mas_centerX);
            make.top.equalTo(self.qrCodeImgView.mas_bottom).offset(10);
        }];
        
        
    }
    return self;
}

#pragma mark - 手势触控
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.shareQRCodeView];
    if (![self.shareQRCodeView.layer containsPoint:point]) {
        [self setAboutUsShareViewDismiss];
    }
}


#pragma mark - 显示
- (void)setAboutUsShareViewShow
{
    self.qrCodeImgView.image = self.shareImg;
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
    self.shareQRCodeView.frame = CGRectMake((iPhoneWidth-ShareViewWidth)/2, (iPhoneHeight-ShareViewHeight)/2, ShareViewWidth, ShareViewHeight);//0.9*iPhoneWidth+50
}

#pragma mark - 消失
- (void)setAboutUsShareViewDismiss{
    [self removeFromSuperview];
}


#pragma mark - getter&&setter
- (UIView *)shareQRCodeView
{
    if (!_shareQRCodeView) {
        _shareQRCodeView = [[UIView alloc]init];
        _shareQRCodeView.backgroundColor = [UIColor whiteColor];
        _shareQRCodeView.layer.cornerRadius = 5.f;
    }
    return _shareQRCodeView;
}
//提示语
- (UILabel *)tipLb
{
    if (!_tipLb) {
        _tipLb = [[UILabel alloc]init];
        _tipLb.text = NSLocalizedString(@"扫码下载APP", nil);
        _tipLb.font = FONT(16);
        _tipLb.textColor = RGB(80, 80, 80);
    }
    return _tipLb;
}
//线条
- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc]init];
        _lineView.backgroundColor = RGB(220, 220, 220);
    }
    return _lineView;
}
//二维码
- (UIImageView *)qrCodeImgView
{
    if (!_qrCodeImgView) {
        _qrCodeImgView = [[UIImageView alloc]init];
    }
    return _qrCodeImgView;
}
//底部提示语
- (UILabel *)bottomtipLb
{
    if (!_bottomtipLb) {
        _bottomtipLb = [[UILabel alloc]init];
        _bottomtipLb.text = NSLocalizedString(@"邀请好友扫一扫分享给TA", nil);
        _bottomtipLb.font = FONT(12);
        _bottomtipLb.textColor = RGB(80, 80, 80);
    }
    return _bottomtipLb;
}

@end
