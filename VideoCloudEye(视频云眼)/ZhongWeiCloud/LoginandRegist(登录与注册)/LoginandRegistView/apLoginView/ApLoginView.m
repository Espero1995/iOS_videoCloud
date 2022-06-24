//
//  ApLoginView.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/5/7.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "ApLoginView.h"
#define semicircleViewHeightOrWidth 150
#define cornerRadius_semicircleView 75

@interface ApLoginView ()<UITextFieldDelegate>
/**
 * 整个半透明的黑色背景
 */
@property (nonatomic, strong) UIView* bgView;
/**
 * 半圆view
 */
@property (nonatomic, strong) UIView* semicircleView;
/**
 * 白色弹出框view
 */
@property (nonatomic, strong) UIView* popView;
/**
 * 类型图标
 */
@property (nonatomic, strong) UIImageView* apIV;
/**
 * titleLabel
 */
@property (nonatomic, strong) UILabel* titleLabel;
/**
 * 关闭按钮
 */
@property (nonatomic, strong) UIButton* closeBtn;
/**
 * 开始预览btn
 */
@property (nonatomic, strong) UIButton* startBtn;
@end

@implementation ApLoginView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.popView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@32);
        make.right.mas_equalTo(@-32);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(320);
    }];
    
    [self.semicircleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY).offset(-123);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.height.width.mas_equalTo(semicircleViewHeightOrWidth);
    }];
    
    [self.apIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.semicircleView.mas_centerY).offset(-10);
        make.centerX.mas_equalTo(self.semicircleView.mas_centerX);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self.popView).offset(70);
    }];
    
    CGFloat TFmargin = 25;
    CGFloat TFHeigt = 45;
    [self.accountTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.popView).offset(TFmargin);
        make.right.mas_equalTo(self.popView).offset(-TFmargin);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(25);
        make.height.mas_equalTo(TFHeigt);
    }];
    
    [self.psdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.popView).offset(TFmargin);
        make.right.mas_equalTo(self.popView).offset(-TFmargin);
        make.top.mas_equalTo(self.accountTF.mas_bottom).offset(20);
        make.height.mas_equalTo(TFHeigt);
    }];

    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.popView).offset(TFmargin);
        make.right.mas_equalTo(self.popView).offset(-TFmargin);
        make.top.mas_equalTo(self.psdTF.mas_bottom).offset(25);
        make.height.mas_equalTo(TFHeigt);
    }];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.popView.mas_centerX);
        make.top.mas_equalTo(self.popView.mas_bottom);
    }];
}

- (void)createUI
{
    [self addSubview:self.bgView];
    [self addSubview:self.semicircleView];
    [self addSubview:self.popView];
    [self addSubview:self.apIV];
    [self addSubview:self.titleLabel];
    [self addSubview:self.accountTF];
    [self addSubview:self.psdTF];
    [self addSubview:self.startBtn];
    [self addSubview:self.closeBtn];
}

#pragma mark === target
- (void)closeBtnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeBtnClick:)]) {
        [self.delegate closeBtnClick:btn];
    }
}
- (void)startBtnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(startBtnClick:)]) {
        [self.delegate startBtnClick:btn];
    }
}

- (void)disappear
{
    [self.bgView removeFromSuperview];
    [self.semicircleView removeFromSuperview];
    [self.popView removeFromSuperview];
    [self.apIV removeFromSuperview];
    [self.titleLabel removeFromSuperview];
    [self.accountTF removeFromSuperview];
    [self.psdTF removeFromSuperview];
    [self.startBtn removeFromSuperview];
    [self.closeBtn removeFromSuperview];
}

#pragma mark - 代理
#pragma mark  UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //NSLog(@"textField - 开始编辑");
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    //NSLog(@"textField - 结束编辑");
    if (self.accountTF.text.length > 0 && self.psdTF.text.length > 0) {
        [self.startBtn setBackgroundColor:[UIColor colorWithHexString:@"#4888ff"]];
    }
    if (self.accountTF.text.length == 0 || self.psdTF.text.length == 0) {
        [self.startBtn setBackgroundColor:[UIColor colorWithHexString:@"#c6c6c6"]];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
   // NSLog(@"textField - 正在编辑, 当前输入框内容为: %@",textField.text);
    return YES;
}

#pragma mark ======== getter && setter
- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc]initWithFrame:CGRectZero];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0.75f;
    }
    return _bgView;
}

- (UIView *)semicircleView
{
    if (!_semicircleView) {
        _semicircleView = [[UIView alloc]initWithFrame:CGRectZero];
        _semicircleView.backgroundColor = [UIColor whiteColor];
        _semicircleView.layer.masksToBounds = YES;
        _semicircleView.layer.cornerRadius = cornerRadius_semicircleView;
    }
    return _semicircleView;
}

- (UIView *)popView
{
    if (!_popView) {
        _popView = [[UIView alloc]initWithFrame:CGRectZero];
        _popView.backgroundColor = [UIColor whiteColor];
        _popView.layer.masksToBounds = YES;
        _popView.layer.cornerRadius = 20.f;
    }
    return _popView;
}

- (UIImageView *)apIV
{
    if (!_apIV) {
        _apIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"APmodel"]];
    }
    return _apIV;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.text = NSLocalizedString(@"请输入账号密码", nil);
        _titleLabel.textColor = [UIColor colorWithHexString:@"#3c3c3c"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:18];
    }
    return _titleLabel;
}

- (UITextField *)accountTF
{
    if (!_accountTF) {
        _accountTF = [[CustomTextField alloc]initWithPlaceholder:NSLocalizedString(@"请输入账号", nil)];
        _accountTF.delegate = self;
        _accountTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _accountTF;
}

- (UITextField *)psdTF
{
    if (!_psdTF) {
        _psdTF = [[CustomTextField alloc]initWithPlaceholder:NSLocalizedString(@"请输入AP密码", nil)];
        _psdTF.secureTextEntry = YES;
        _psdTF.delegate = self;
        _psdTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _psdTF;
}

- (UIButton *)startBtn
{
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _startBtn.backgroundColor = [UIColor colorWithHexString:@"#c6c6c6"];
        _startBtn.layer.masksToBounds = YES;
        _startBtn.layer.cornerRadius = 8.0f;
        _startBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_startBtn setTitle: NSLocalizedString(@"开始预览", nil) forState: UIControlStateNormal];
        _startBtn.titleLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _startBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_startBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"closeApView"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

@end
