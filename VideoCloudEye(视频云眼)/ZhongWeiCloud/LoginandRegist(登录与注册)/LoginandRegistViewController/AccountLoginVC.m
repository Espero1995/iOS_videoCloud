//
//  AccountLoginVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/2/6.
//  Copyright © 2018年 张策. All rights reserved.
//
//图片尺寸
#define LOGOWIDTH iPhoneWidth/5.5
//文本尺寸
#define ACCOUNTWIDTH 0.85*iPhoneWidth
#import "AccountLoginVC.h"
/*自定义按钮*/
#import "UnderlineBtn.h"
/*短信快捷登录*/
#import "PhoneLoginVC.h"
/*忘记密码*/
#import "ForgotPsdVC.h"
/*注册新账号*/
#import "RegisterVC.h"
/*登录按钮样式*/
#import "LYButton.h"
#import "LoginButton.h"
@interface AccountLoginVC ()
/*logo图片*/
@property (nonatomic,strong) UIImageView *logoImg;
/*账号提示View*/
@property (nonatomic,strong) UIView *accountView;
/*账号文本框*/
@property (nonatomic,strong) UITextField *account_tf;
/*密码提示View*/
@property (nonatomic,strong) UIView *psdView;
/*密码文本框*/
@property (nonatomic,strong) UITextField *psd_tf;
/*短信快捷登录按钮*/
@property (nonatomic,strong) UIButton *smsLoginBtn;
/*登录按钮*/
@property (nonatomic,strong) LoginButton *loginBtn;
/*忘记密码按钮*/
@property (nonatomic,strong) UnderlineBtn *forgetPsdBtn;
/*注册按钮*/
@property (nonatomic,strong) UnderlineBtn *registerBtn;
@end

@implementation AccountLoginVC
//==========================system==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"登录";
    self.view.backgroundColor = RGB(255, 255, 255);
    [self setUpUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//==========================init==========================
#pragma mark ----- 初始化布局
- (void)setUpUI{
    //logo图片
    [self.view addSubview:self.logoImg];
    [self.logoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(LOGOWIDTH/1.5);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(LOGOWIDTH, LOGOWIDTH));
    }];
    //账号View初始化
    [self.view addSubview:self.accountView];
    [self.accountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoImg.mas_bottom).offset(LOGOWIDTH/1.5);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 40));
    }];
    //账号提示
    UILabel *tipALb = [[UILabel alloc]init];
    tipALb.font = FONT(17);
    tipALb.text = @"账号";
    [self.accountView addSubview:tipALb];
    [tipALb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.accountView.mas_left);
        make.centerY.equalTo(self.accountView.mas_centerY);
    }];
    //账号文本
    [self.accountView addSubview:self.account_tf];
    [self.account_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.accountView.mas_centerY);
        make.left.equalTo(tipALb.mas_right).offset(15);
        make.right.equalTo(self.accountView.mas_right);
    }];
    //View底部的line
    UIView *lineA = [[UIView alloc]init];
    lineA.backgroundColor = RGB(220, 220, 220);
    [self.accountView addSubview:lineA];
    [lineA mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.accountView.mas_centerX);
        make.bottom.equalTo(self.accountView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 1));
    }];
    
    //密码View初始化
    [self.view addSubview:self.psdView];
    [self.psdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.accountView.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 40));
    }];
    //密码提示
    UILabel *tipPLb = [[UILabel alloc]init];
    tipPLb.font = FONT(17);
    tipPLb.text = @"密码";
    [self.psdView addSubview:tipPLb];
    [tipPLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.psdView.mas_left);
        make.centerY.equalTo(self.psdView.mas_centerY);
    }];
    //密码文本
    [self.psdView addSubview:self.psd_tf];
    [self.psd_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.psdView.mas_centerY);
        make.left.equalTo(tipPLb.mas_right).offset(15);
        make.right.equalTo(self.psdView.mas_right);
    }];
    //View底部的line
    UIView *lineP = [[UIView alloc]init];
    lineP.backgroundColor = RGB(220, 220, 220);
    [self.psdView addSubview:lineP];
    [lineP mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.psdView.mas_centerX);
        make.bottom.equalTo(self.psdView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 1));
    }];
    
    //短信登录按钮初试化
    [self.view addSubview:self.smsLoginBtn];
    [self.smsLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.psdView.mas_bottom).offset(20);
        make.left.equalTo(self.psdView.mas_left).offset(0);
        make.size.mas_equalTo(CGSizeMake(120, 20));
        }];
    //登录按钮
    [self.view addSubview:self.loginBtn];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.smsLoginBtn.mas_bottom).offset(30);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 45));
    }];
    //忘记密码按钮
    [self.view addSubview:self.forgetPsdBtn];
    [self.forgetPsdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginBtn.mas_bottom).offset(15);
        make.left.equalTo(self.loginBtn.mas_left);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    //注册新账号按钮
    [self.view addSubview:self.registerBtn];
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginBtn.mas_bottom).offset(15);
        make.right.equalTo(self.loginBtn.mas_right);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    
}
//==========================method==========================
#pragma mark ----- 短信快捷登录点击事件
-(void)smsLoginClick{
    [self resetTextData];
    
    PhoneLoginVC *phoneVC = [[PhoneLoginVC alloc]init];
    
    [self.navigationController pushViewController:phoneVC animated:NO];
    // 设置翻页动画为从右边翻上来
    [UIView transitionWithView:self.navigationController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight animations:nil completion:nil];

}
#pragma mark ----- 忘记密码点击事件
-(void)forgetClick{
    [self resetTextData];
    ForgotPsdVC *forgetVC = [[ForgotPsdVC alloc]init];
    [self.navigationController pushViewController:forgetVC animated:YES];
}
#pragma mark ----- 注册新账号
-(void)registerClick{
    [self resetTextData];
    RegisterVC *registVC = [[RegisterVC alloc]init];
    [self.navigationController pushViewController:registVC animated:YES];
}

#pragma mark ----- 登录按钮点击事件
-(void)loginClick{
    [self resetTextData];
    [self huanYuanKeybord];
    [self performSelector:@selector(loginBtnAction) withObject:nil afterDelay:0.3];
    /**
     *  description:
     *   1.判断账号与密码都是不是为空(空:return)
     *   2.判断手机号是不是正确(错:return)
     *   3.请求(成功:登录；失败:弹框警告错误原因)
     */
}
//登录按钮
-(void)loginBtnAction{
    [self.loginBtn ErrorRevertAnimationCompletion:^{
        [Toast showInfo:@"登录~"];
    }];
}
#pragma mark ----- 清除文本数据和弹回键盘
-(void)resetTextData{
    self.account_tf.text = @"";
    [self.account_tf resignFirstResponder];
    self.psd_tf.text = @"";
    [self.psd_tf resignFirstResponder];
}

#pragma mark ------正则判断电话号正确格式
- (BOOL)validateMobile:(NSString *)mobile
{
    // 130-139  150-153,155-159  180-189  145,147  170,171,173,176,177,178
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0-9])|(14[57])|(17[013678]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

//=================样式方法=================
- (void)huanYuanKeybord
{
    [UIView animateWithDuration:0.3 animations:^{
        // 重置了view的frame
        self.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    }];
    [self.account_tf resignFirstResponder];
    [self.psd_tf resignFirstResponder];
    
}

//==========================delegate==========================


//==========================lazy loading==========================
#pragma mark -----懒加载
//logo图片
-(UIImageView *)logoImg{
    if (!_logoImg) {
        _logoImg = [[UIImageView alloc]init];
        _logoImg.image = [UIImage imageNamed:@"login-logo"];
    }
    return _logoImg;
}
//账号提示View
-(UIView *)accountView{
    if (!_accountView) {
        _accountView = [[UIView alloc]init];
        _accountView.backgroundColor = [UIColor clearColor];
    }
    return _accountView;
}
//密码提示View
-(UIView *)psdView{
    if (!_psdView) {
        _psdView = [[UIView alloc]init];
        _psdView.backgroundColor = [UIColor clearColor];
    }
    return _psdView;
}
//短信快捷登录按钮
-(UIButton *)smsLoginBtn{
    if (!_smsLoginBtn) {
        _smsLoginBtn = [[UIButton alloc]init];
        _smsLoginBtn.titleLabel.font = FONT(17);
        _smsLoginBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_smsLoginBtn setTitleColor:RGB(82, 126, 150) forState:UIControlStateNormal];
        [_smsLoginBtn setTitle:@"短信快捷登录" forState:UIControlStateNormal];
        [_smsLoginBtn addTarget:self action:@selector(smsLoginClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _smsLoginBtn;
}
//登录按钮
-(LoginButton *)loginBtn{
    if (!_loginBtn) {
        _loginBtn = [[LoginButton alloc]initWithFrame:CGRectMake(0.15*iPhoneWidth/2, 0, ACCOUNTWIDTH, 45)];
        _loginBtn.backgroundColor = MAIN_COLOR;
        _loginBtn.layer.cornerRadius = 7.0f;
        [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [_loginBtn addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginBtn;
}
//忘记密码
-(UnderlineBtn *)forgetPsdBtn{
    if (!_forgetPsdBtn) {
        _forgetPsdBtn = [[UnderlineBtn alloc]init];
        _forgetPsdBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _forgetPsdBtn.titleLabel.font = FONT(17);
        [_forgetPsdBtn setColor:MAIN_COLOR];
        [_forgetPsdBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        [_forgetPsdBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
        [_forgetPsdBtn addTarget:self action:@selector(forgetClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _forgetPsdBtn;
}
//注册新账号
-(UnderlineBtn *)registerBtn{
    if (!_registerBtn) {
        _registerBtn = [[UnderlineBtn alloc]init];
        _registerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _registerBtn.titleLabel.font = FONT(17);
        [_registerBtn setColor:MAIN_COLOR];
        [_registerBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        [_registerBtn setTitle:@"注册新账号" forState:UIControlStateNormal];
        [_registerBtn addTarget:self action:@selector(registerClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerBtn;
}
//账号文本框
-(UITextField *)account_tf{
    if (!_account_tf) {
        _account_tf = [[UITextField alloc]init];
        _account_tf.font =FONT(17);
        _account_tf.placeholder = @"请填写您的账号";
        _account_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _account_tf;
}
//密码文本框
-(UITextField *)psd_tf{
    if (!_psd_tf) {
        _psd_tf = [[UITextField alloc]init];
        _psd_tf.font =FONT(17);
        _psd_tf.placeholder = @"请填写您的密码";
        _psd_tf.secureTextEntry = YES;
        _psd_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _psd_tf;
}
@end
