//
//  ForgetPwdVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/29.
//  Copyright © 2018年 张策. All rights reserved.
//
//图片尺寸
#define LOGOWIDTH iPhoneWidth/4
#define LeftSpacing 0.075*iPhoneWidth
#define TopSpacing iPhoneWidth/5.5
#define TopSpacingX iPhoneWidth/4.5
//文本尺寸
#define ACCOUNTWIDTH 0.85*iPhoneWidth
#import "ForgetPwdVC.h"
#import <QuartzCore/CoreAnimation.h>
#import "SmsVerifyVC.h"
#import "UnderlineBtn.h"
//警告框类型
typedef NS_ENUM(NSInteger,AlertAction){
    AlertAction_isPhone,//是否是正确的手机号
    AlertAction_isEmail,//是否是正确的邮箱
    AlertAction_verifyBusy,//验证码发送频繁
    AlertAction_netWork,//网络是否打开
    AlertAction_failVerify,//验证码发送失败
};
@interface ForgetPwdVC ()
<
    CAAnimationDelegate
>
@property (nonatomic,strong) UIButton *backBtn;//返回按钮
@property (nonatomic,strong) UILabel *forgetPwdTipLb;//忘记密码提示语
@property (nonatomic,strong) UILabel *locationLb;//电话区号(显示/隐藏)
@property (nonatomic,strong) UILabel *localNumLb;//地区/邮箱
@property (nonatomic,strong) UIView *accountView;//账号提示View
@property (nonatomic,strong) UITextField *account_tf;//账号文本框
@property (nonatomic,strong) UIButton *submitBtn;//获取短信验证码按钮
@property (nonatomic,strong) UnderlineBtn *otherForgetPwdBtn;// 手机忘记密码/邮箱忘记密码
@end

@implementation ForgetPwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpUI];
}

- (void)didReceiveMemoryWarning {
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
    //忘记密码提示语
    [self.view addSubview:self.forgetPwdTipLb];
    [self.forgetPwdTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(LeftSpacing);
        if (iPhone_X_) {
            make.top.equalTo(self.backBtn.mas_bottom).offset(TopSpacingX);
        }else{
            make.top.equalTo(self.backBtn.mas_bottom).offset(TopSpacing);
        }
        
    }];
    
    //国家/地区
    [self.view addSubview:self.locationLb];
    [self.locationLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.forgetPwdTipLb.mas_bottom).offset(TopSpacing);
        make.left.mas_equalTo(LeftSpacing);
    }];
    if (self.isEmail) {
        self.locationLb.hidden = YES;
    }else{
        self.locationLb.hidden = NO;
    }
    
    //账号View初始化
    [self.view addSubview:self.accountView];
    [self.accountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.locationLb.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 40));
    }];
    
    //+86
    [self.accountView addSubview:self.localNumLb];
    [self.localNumLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.accountView.mas_centerY);
        make.centerX.equalTo(self.locationLb.mas_centerX);
    }];
    //+86底部的line
    UILabel *numLineLb = [[UILabel alloc]init];
    numLineLb.backgroundColor = RGB(220, 220, 220);
    [self.accountView addSubview:numLineLb];
    [numLineLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.accountView.mas_bottom);
        make.left.equalTo(self.locationLb.mas_left).offset(0);
        make.right.equalTo(self.locationLb.mas_right).offset(0);
        make.height.mas_equalTo(@1);
    }];
    
    //View底部的line
    UIView *lineA = [[UIView alloc]init];
    lineA.backgroundColor = RGB(220, 220, 220);
    [self.accountView addSubview:lineA];
    [lineA mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(numLineLb.mas_right).offset(10);
        make.right.equalTo(self.accountView.mas_right).offset(0);
        make.bottom.equalTo(self.accountView.mas_bottom);
        make.height.mas_equalTo(@1);
    }];
    
    //账号文本
    [self.accountView addSubview:self.account_tf];
    [self.account_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.accountView.mas_centerY);
        make.left.equalTo(self.accountView.mas_left).offset(80);
        make.right.equalTo(self.accountView.mas_right).offset(0);
    }];
    
    //短信验证按钮
    [self.view addSubview:self.submitBtn];
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.accountView.mas_bottom).offset(TopSpacing);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 45));
    }];
    
    //其他注册方式的按钮
    [self.view addSubview:self.otherForgetPwdBtn];
    [self.otherForgetPwdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.forgetPwdTipLb.mas_bottom).offset(0);
        make.right.equalTo(self.view.mas_right).offset(-20);
    }];
    
}

//==========================method==========================
#pragma mark - 返回方法
- (void)returnBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

//手机忘记密码/邮箱忘记密码点击事件
- (void)otherWayForgetClick
{
    [self.account_tf resignFirstResponder];
    [self viewRotateAnimation];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        if (self.isEmail) {
            [self.otherForgetPwdBtn setTitle:NSLocalizedString(@"邮箱密码重置", nil) forState:UIControlStateNormal];
            self.locationLb.hidden = NO;
            self.localNumLb.text = @"+86";
            [self.submitBtn setTitle:NSLocalizedString(@"获取短信验证码", nil) forState:UIControlStateNormal];
            self.account_tf.placeholder = NSLocalizedString(@"请输入手机号码", nil);
            self.account_tf.keyboardType = UIKeyboardTypeNumberPad;
            self.forgetPwdTipLb.text = NSLocalizedString(@"验证手机号", nil);
            self.isEmail = NO;
        }else{
            [self.otherForgetPwdBtn setTitle:NSLocalizedString(@"手机密码重置", nil) forState:UIControlStateNormal];
            self.locationLb.hidden = YES;
            self.localNumLb.text = NSLocalizedString(@"邮箱", nil);
            [self.submitBtn setTitle:NSLocalizedString(@"获取邮箱验证码", nil) forState:UIControlStateNormal];
            self.account_tf.placeholder = NSLocalizedString(@"请输入邮箱账号", nil);
            self.account_tf.keyboardType = UIKeyboardTypeEmailAddress;
            self.forgetPwdTipLb.text = NSLocalizedString(@"验证邮箱", nil);
            self.isEmail = YES;
        }
    });
    
}

#pragma mark - 获取验证码
- (void)submitClick
{
    if (self.isEmail) {
        if (![NSString isValidateEmail:self.account_tf.text]) {
            [self LoginAlertAction:AlertAction_isEmail];//是否是正确的邮件
            return;
        }
        SmsVerifyVC *smsVC = [[SmsVerifyVC alloc]init];
        smsVC.verifyCodeStatus = 2;
        smsVC.isEmail = self.isEmail;
        smsVC.phoneStr = self.account_tf.text;
        [self.navigationController pushViewController:smsVC animated:YES];
    }else{
        if (![NSString validateMobile:self.account_tf.text]) {
            [self LoginAlertAction:AlertAction_isPhone];//是否是正确的手机号
            return;
        }
        
        [self.account_tf resignFirstResponder];
        //发送手机验证码
        NSString * uuid = [unitl getKeyChain];
        NSDictionary *postDic = @{@"mobile":self.account_tf.text,@"term_id":uuid};
        
        [[HDNetworking sharedHDNetworking]POST:@"v1/user/verify" parameters:postDic success:^(id  _Nonnull responseObject) {
            NSLog(@"responseObject:%@",responseObject);
            int ret = [responseObject[@"ret"] intValue];
            if (ret == 0) {
                SmsVerifyVC *smsVC = [[SmsVerifyVC alloc]init];
                smsVC.verifyCodeStatus = 2;
                smsVC.phoneStr = self.account_tf.text;
                [self.navigationController pushViewController:smsVC animated:YES];
                [XHToast showCenterWithText:NSLocalizedString(@"验证码已发送", nil)];
            }else if (ret == 1100){
                [self LoginAlertAction:AlertAction_verifyBusy];//验证码发送频繁
            }else{
                [self LoginAlertAction:AlertAction_failVerify];
            }
        } failure:^(NSError * _Nonnull error) {
            //判断网络连接
            [self LoginAlertAction:AlertAction_netWork];
        }];
        
    }

}


//警告框提醒
- (void)LoginAlertAction:(AlertAction)action
{
    switch (action) {
        //是否是正确的手机号
        case AlertAction_isPhone:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"请输入正确的手机号", nil)];
        }
            break;
        //是否是正确的邮箱
        case AlertAction_isEmail:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"请输入正确的邮箱", nil)];
        }
            break;
        //验证码发送频繁
        case AlertAction_verifyBusy:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"验证码发送过于频繁，请稍候再试", nil)];
        }
            break;
        //网络是否打开
        case AlertAction_netWork:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"当前网络不可用，请检查您的网络", nil)];
        }
            break;
        //验证码发送失败
        case AlertAction_failVerify:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"验证码发送失败，请稍候再试", nil)];
        }
            break;
        default:
            break;
    }
}

- (void)createAlertActionWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertCtrl addAction:btnAction];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

//==========================delegate==========================
-(void)textValueChanged{
    if (self.account_tf.text.length != 0) {
        self.submitBtn.backgroundColor = RGB(69, 135, 251);
        self.submitBtn.userInteractionEnabled = YES;
    }else{
        self.submitBtn.backgroundColor = RGB(220, 223, 230);
        self.submitBtn.userInteractionEnabled = NO;
    }
}
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

//注册提示语
- (UILabel *)forgetPwdTipLb
{
    if (!_forgetPwdTipLb) {
        _forgetPwdTipLb = [[UILabel alloc]init];
        if (self.isEmail) {
           _forgetPwdTipLb.text = NSLocalizedString(@"验证邮箱", nil);
        }else{
           _forgetPwdTipLb.text = NSLocalizedString(@"验证手机号", nil);
        }
        _forgetPwdTipLb.font = FONTB(28);
        _forgetPwdTipLb.textAlignment = NSTextAlignmentLeft;
    }
    return _forgetPwdTipLb;
}

//国家/地区
- (UILabel *)locationLb
{
    if (!_locationLb) {
        _locationLb = [[UILabel alloc]init];
        _locationLb.text = NSLocalizedString(@"国家/地区", nil);
        _locationLb.font = FONT(15);
    }
    return _locationLb;
}

//+86/邮箱
- (UILabel *)localNumLb
{
    if (!_localNumLb) {
        _localNumLb = [[UILabel alloc]init];
        NSString *lbTitle = self.isEmail?NSLocalizedString(@"邮箱", nil):@"+86";
        _localNumLb.text = lbTitle;
        _localNumLb.font = FONT(18);
    }
    return _localNumLb;
}

//账号提示View
-(UIView *)accountView{
    if (!_accountView) {
        _accountView = [[UIView alloc]init];
        _accountView.backgroundColor = [UIColor clearColor];
    }
    return _accountView;
}
//账号文本框
-(UITextField *)account_tf{
    if (!_account_tf) {
        _account_tf = [[UITextField alloc]init];
        _account_tf.font =FONT(17);
        if (self.isEmail) {
            _account_tf.placeholder = NSLocalizedString(@"请输入邮箱账号", nil);
            _account_tf.keyboardType = UIKeyboardTypeEmailAddress;
        }else{
            _account_tf.placeholder = NSLocalizedString(@"请输入手机号码", nil);
            _account_tf.keyboardType = UIKeyboardTypeNumberPad;
        }
        _account_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_account_tf addTarget:self action:@selector(textValueChanged) forControlEvents:UIControlEventEditingChanged];
    }
    return _account_tf;
}

//获取短信验证码按钮
- (UIButton *)submitBtn
{
    if (!_submitBtn) {
        _submitBtn = [[UIButton alloc]init];
        _submitBtn.userInteractionEnabled = NO;
        _submitBtn.layer.cornerRadius = 22.5f;
        if (self.isEmail) {
            [_submitBtn setTitle:NSLocalizedString(@"获取邮箱验证码", nil) forState:UIControlStateNormal];
        }else{
            [_submitBtn setTitle:NSLocalizedString(@"获取短信验证码", nil) forState:UIControlStateNormal];
        }
        
        _submitBtn.backgroundColor = RGB(220, 223, 230);
        _submitBtn.layer.cornerRadius = 20.0f;
        _submitBtn.layer.shadowColor = [UIColor grayColor].CGColor;
        _submitBtn.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        _submitBtn.layer.shadowRadius = 3.0;
        _submitBtn.layer.shadowOpacity = 0.3;
        [_submitBtn addTarget:self action:@selector(submitClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}

//手机忘记密码/邮箱忘记密码otherWayForgetClick
- (UnderlineBtn *)otherForgetPwdBtn
{
    if (!_otherForgetPwdBtn) {
        _otherForgetPwdBtn = [[UnderlineBtn alloc]init];
        NSString *btnTitle = self.isEmail?NSLocalizedString(@"手机密码重置", nil):NSLocalizedString(@"邮箱密码重置", nil);
        [_otherForgetPwdBtn setTitle:btnTitle forState:UIControlStateNormal];
        [_otherForgetPwdBtn setColor:MAIN_COLOR];
        [_otherForgetPwdBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        _otherForgetPwdBtn.titleLabel.font = FONT(16);
        [_otherForgetPwdBtn addTarget:self action:@selector(otherWayForgetClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _otherForgetPwdBtn;
}

#pragma mark - 点击按钮进行旋转动画
- (void)viewRotateAnimation{
    CAAnimation *myAnimationRotate = [self animationRotate];
    CAAnimationGroup* m_pGroupAnimation;
    m_pGroupAnimation = [CAAnimationGroup animation];
    m_pGroupAnimation.delegate = self;
    m_pGroupAnimation.removedOnCompletion = NO;
    m_pGroupAnimation.duration = 1.2;
    m_pGroupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    m_pGroupAnimation.repeatCount = 1;
    m_pGroupAnimation.fillMode = kCAFillModeForwards;
    m_pGroupAnimation.animations = [NSArray arrayWithObjects:myAnimationRotate, nil];
    [self.view.layer addAnimation:m_pGroupAnimation forKey:@"animationRotate"];
}
- (CAAnimation *)animationRotate {
    CATransform3D rotationTransform  = CATransform3DMakeRotation(M_PI/2 , 0 , 1 , 0 );
    CABasicAnimation* animation;
    animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:rotationTransform];
    animation.duration = 0.4;
    animation.autoreverses = YES;
    animation.cumulative = YES;
    animation.repeatCount = 1;
    animation.beginTime = 0;
    animation.delegate = self;
    return animation;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    //todo
}

@end
