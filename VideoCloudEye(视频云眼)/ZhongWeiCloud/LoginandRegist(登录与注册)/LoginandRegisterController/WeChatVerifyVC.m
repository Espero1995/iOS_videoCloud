//
//  weChatVerifyVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/29.
//  Copyright © 2018年 张策. All rights reserved.
//
//图片尺寸
#define LOGOWIDTH iPhoneWidth/5.5
//文本尺寸
#define ACCOUNTWIDTH 0.85*iPhoneWidth
#import "WeChatVerifyVC.h"
/*注册新账号*/
#import "RegisterNewVC.h"
/*绑定账号*/
#import "BindAccountVC.h"
@interface WeChatVerifyVC ()
/*linker图片*/
@property (nonatomic,strong) UIImageView *linkerImg;
/*微信图片*/
@property (nonatomic,strong) UIImageView *weChatImg;
/*logo图片*/
@property (nonatomic,strong) UIImageView *logoImg;
/*logo下方的提示*/
@property (nonatomic,strong) UILabel *logotip_lb;
/*账号绑定按钮*/
@property (nonatomic,strong) UIButton *bindBtn;
/*注册新账号按钮*/
@property (nonatomic,strong) UIButton *registerBtn;
@property (nonatomic,strong) UIButton *backBtn;//返回按钮
@property (nonatomic,strong) UILabel *titleLb;//标题
@end

@implementation WeChatVerifyVC
//==========================system==========================
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = RGB(255, 255, 255);
    [self createNavBlackBtn];
    [self setUpUI];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//==========================init==========================
#pragma mark ----- 初始化布局
- (void)setUpUI
{
    //返回按钮
    [self.view addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(20);
        if (iPhone_X_) {
            make.top.equalTo(self.view.mas_top).offset(50);
        }else{
            make.top.equalTo(self.view.mas_top).offset(30);
        }
    }];
    //标题
    [self.view addSubview:self.titleLb];
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    //linker图片
    [self.view addSubview:self.linkerImg];
    [self.linkerImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backBtn.mas_bottom).offset(LOGOWIDTH);
        make.centerX.equalTo(self.view);
    }];
    //微信图片
    [self.view addSubview:self.weChatImg];
    [self.weChatImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.linkerImg.mas_centerY);
        make.right.equalTo(self.linkerImg.mas_left).offset(-15);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    //logo图片
    [self.view addSubview:self.logoImg];
    [self.logoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.linkerImg.mas_centerY);
        make.left.equalTo(self.linkerImg.mas_right).offset(15);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    //logo下方的提示
    [self.view addSubview:self.logotip_lb];
    [self.logotip_lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.linkerImg.mas_centerX);
        make.top.equalTo(self.logoImg.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(0.8*iPhoneWidth, 60));
    }];
    //绑定账号按钮
    [self.view addSubview:self.bindBtn];
    [self.bindBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logotip_lb.mas_bottom).offset(40);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 45));
    }];
    //注册新账号按钮
    [self.view addSubview:self.registerBtn];
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bindBtn.mas_bottom).offset(20);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 45));
    }];
    
}

//==========================method==========================
#pragma mark - 返回方法
- (void)returnBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

//绑定账号
- (void)bindAccountClick
{
    
    BindAccountVC *bindVC = [[BindAccountVC alloc]init];
    bindVC.weixinOpenId = self.weixinOpenId;
    [self.navigationController pushViewController:bindVC animated:YES];
}
//注册新账号
- (void)registerBtnClick
{
    RegisterNewVC *registVC = [[RegisterNewVC alloc]init];
    [self.navigationController pushViewController:registVC animated:YES];
}
//==========================delegate==========================

//==========================lazy loading==========================
#pragma mark -----懒加载
//返回按钮
- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.titleLabel.font = FONT(18);
        [_backBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
        [_backBtn setTitleColor:RGB(50, 50, 50) forState:UIControlStateNormal];
        [_backBtn setTitle:NSLocalizedString(@"返回", nil) forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(returnBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}
//标题
- (UILabel *)titleLb
{
    if (!_titleLb) {
        _titleLb = [[UILabel alloc]init];
        _titleLb.text = NSLocalizedString(@"账号验证", nil);
        _titleLb.font = FONT(18);
    }
    return _titleLb;
}
//logo图片
-(UIImageView *)linkerImg
{
    if (!_linkerImg) {
        _linkerImg = [[UIImageView alloc]init];
        _linkerImg.image = [UIImage imageNamed:@"login-link"];
    }
    return _linkerImg;
}
//logo图片
-(UIImageView *)weChatImg
{
    if (!_weChatImg) {
        _weChatImg = [[UIImageView alloc]init];
        _weChatImg.image = [UIImage imageNamed:@"login_weChat"];
    }
    return _weChatImg;
}
//logo图片
-(UIImageView *)logoImg
{
    if (!_logoImg) {
        _logoImg = [[UIImageView alloc]init];
        _logoImg.image = [UIImage imageNamed:@"logoNew"];
    }
    return _logoImg;
}
//logo下方的提示
-(UILabel *)logotip_lb
{
    if (!_logotip_lb) {
        _logotip_lb = [[UILabel alloc]init];
        _logotip_lb.font = FONT(15);
        _logotip_lb.textColor = [UIColor lightGrayColor];
        _logotip_lb.text = NSLocalizedString(@"第一次使用微信账号登录，需绑定视频云眼账号", nil);
        if (isSimplifiedChinese) {
            _logotip_lb.textAlignment = NSTextAlignmentCenter;
        }else{
            _logotip_lb.textAlignment = NSTextAlignmentLeft;
        }
        
        _logotip_lb.numberOfLines = 0;
        _logotip_lb.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _logotip_lb;
}
//绑定账号按钮
- (UIButton *)bindBtn
{
    if (!_bindBtn) {
        _bindBtn = [[UIButton alloc]init];
        _bindBtn.backgroundColor = MAIN_COLOR;
        _bindBtn.layer.cornerRadius = 7.0f;
        [_bindBtn setTitle:NSLocalizedString(@"绑定账号", nil) forState:UIControlStateNormal];
        [_bindBtn addTarget:self action:@selector(bindAccountClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bindBtn;
}

- (UIButton *)registerBtn
{
    if (!_registerBtn) {
        _registerBtn = [[UIButton alloc]init];
        _registerBtn.layer.cornerRadius = 7.0f;
        _registerBtn.layer.borderWidth = 1.0f;
        _registerBtn.layer.borderColor = RGB(220, 220, 220).CGColor;
        [_registerBtn setTitle:NSLocalizedString(@"注册新账号", nil) forState:UIControlStateNormal];
        [_registerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_registerBtn addTarget:self action:@selector(registerBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerBtn;
}

@end
