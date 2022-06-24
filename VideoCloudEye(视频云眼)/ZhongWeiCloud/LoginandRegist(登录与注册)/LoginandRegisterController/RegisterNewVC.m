//
//  RegisterNewVC.m
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
#import "RegisterNewVC.h"
#import <QuartzCore/CoreAnimation.h>
#import "UnderlineBtn.h"
#import "SmsVerifyVC.h"
#import "UserAgreementVC.h"//用户协议
//警告框类型
typedef NS_ENUM(NSInteger,AlertAction){
    AlertAction_isPhone,//是否是正确的手机号
    AlertAction_isPwd,//是否是合格的密码
    AlertAction_isSamePwd,//是否是一致的密码
    AlertAction_verifyBusy,//验证码发送频繁
    AlertAction_failVerify,//验证码发送失败
    AlertAction_netWork,//网络是否打开
    AlertAction_isEmail,//是否是正确的Email
    AlertAction_notRegister,//注册失败
    AlertAction_EmailExist,//邮箱已被注册
    AlertAction_waitActivation,//等待激活
};
@interface RegisterNewVC ()
<
    CAAnimationDelegate
>
{
    //判断密码展示还是隐藏
    BOOL isOpenPwd;
    BOOL isOpenConfirmPwd;
}
@property (nonatomic,strong) UIButton *backBtn;//返回按钮
@property (nonatomic,strong) UILabel *registerTipLb;//注册提示语
@property (nonatomic,strong) UIImageView *registerIcon;//注册图标
@property (nonatomic,strong) UILabel *locationLb;//电话区号(显示/隐藏)
@property (nonatomic,strong) UILabel *localNumLb;//地区/邮箱
@property (nonatomic,strong) UIView *accountView;//账号提示View
@property (nonatomic,strong) UITextField *account_tf;//账号文本框
@property (nonatomic,strong) UIView *pwdView;//密码提示View
@property (nonatomic,strong) UITextField *pwd_tf;//密码文本框
@property (nonatomic,strong) UIView *confirmPwdView;//确认密码View
@property (nonatomic,strong) UITextField *confirmPwd_tf;//确认密码文本框

@property (nonatomic,strong) UIButton *showPwdBtn;//查看密码的按钮
@property (nonatomic,strong) UIButton *showConfirmPwdBtn;//确认密码的查看密码的按钮

@property (nonatomic,strong) UIButton *submitBtn;//获取短信验证码按钮

@property (nonatomic,strong) UILabel *bottomTipLb;//底部的提示文字
@property (nonatomic,strong) UnderlineBtn *bottomTipBtn;//底部的提示按钮
@property (nonatomic,strong) UnderlineBtn *otherRegisterBtn;//其他注册方式的按钮
@end

@implementation RegisterNewVC

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
    //注册提示语
    [self.view addSubview:self.registerTipLb];
    [self.registerTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(LeftSpacing);
        if (iPhone_X_) {
            make.top.equalTo(self.backBtn.mas_bottom).offset(TopSpacingX);
        }else{
            make.top.equalTo(self.backBtn.mas_bottom).offset(TopSpacing);
        }
    }];
    //注册图标
    [self.view addSubview:self.registerIcon];
    [self.registerIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.registerTipLb.mas_centerY);
        make.left.equalTo(self.registerTipLb.mas_right).offset(5);
    }];
    
    
    //账号View初始化
    [self.view addSubview:self.accountView];
    [self.accountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.registerTipLb.mas_bottom).offset(TopSpacing);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 40));
    }];
    
    //国家/地区
    [self.view addSubview:self.locationLb];
    [self.locationLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.accountView.mas_top).offset(-10);
        make.left.mas_equalTo(LeftSpacing);
    }];
    if (self.isEmail) {
        self.locationLb.hidden = YES;
    }else{
        self.locationLb.hidden = NO;
    }
    
    //+86/邮箱
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
    
    //密码View初始化
    [self.view addSubview:self.pwdView];
    [self.pwdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.accountView.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 40));
    }];
    //密码View底部的line
    UIView *lineP = [[UIView alloc]init];
    lineP.backgroundColor = RGB(220, 220, 220);
    [self.pwdView addSubview:lineP];
    [lineP mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.pwdView.mas_centerX);
        make.bottom.equalTo(self.pwdView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 1));
    }];
    
    //密码文本提示
    UILabel *pwdTipLb = [[UILabel alloc]init];
    pwdTipLb.text = NSLocalizedString(@"输入密码", nil);
    pwdTipLb.font = FONT(17);
    [self.pwdView addSubview:pwdTipLb];
    [pwdTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.pwdView.mas_centerY);
        make.left.equalTo(self.pwdView.mas_left).offset(0);
    }];
    //显示密码的按钮
    [self.pwdView addSubview:self.showPwdBtn];
    [self.showPwdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.pwdView.mas_centerY);
        make.right.equalTo(self.pwdView.mas_right).offset(-5);
    }];
    //密码文本
    [self.pwdView addSubview:self.pwd_tf];
    [self.pwd_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.pwdView.mas_centerY);
        make.left.equalTo(self.pwdView.mas_left).offset(80);
        make.right.equalTo(self.showPwdBtn.mas_left).offset(-5);
    }];
    
    //确认密码View
    [self.view addSubview:self.confirmPwdView];
    [self.confirmPwdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pwdView.mas_bottom).offset(20);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 40));
    }];
    //确认密码View底部的line
    UIView *lineCP = [[UIView alloc]init];
    lineCP.backgroundColor = RGB(220, 220, 220);
    [self.confirmPwdView addSubview:lineCP];
    [lineCP mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.confirmPwdView.mas_centerX);
        make.bottom.equalTo(self.confirmPwdView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 1));
    }];
    
    //确认密码文本提示
    UILabel *confirmPwdTipLb = [[UILabel alloc]init];
    confirmPwdTipLb.text = NSLocalizedString(@"确认密码", nil);
    confirmPwdTipLb.font = FONT(17);
    [self.confirmPwdView addSubview:confirmPwdTipLb];
    [confirmPwdTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.confirmPwdView.mas_centerY);
        make.left.equalTo(self.confirmPwdView.mas_left).offset(0);
    }];
    
    //显示密码的按钮
    [self.confirmPwdView addSubview:self.showConfirmPwdBtn];
    [self.showConfirmPwdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.confirmPwdView.mas_centerY);
        make.right.equalTo(self.confirmPwdView.mas_right).offset(-5);
    }];
    
    //确认密码文本框
    [self.confirmPwdView addSubview:self.confirmPwd_tf];
    [self.confirmPwd_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.confirmPwdView.mas_centerY);
        make.left.equalTo(self.confirmPwdView.mas_left).offset(80);
        make.right.equalTo(self.showConfirmPwdBtn.mas_left).offset(-5);
    }];
    
    //短信验证按钮
    [self.view addSubview:self.submitBtn];
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.confirmPwdView.mas_bottom).offset(TopSpacing);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 45));
    }];
    
    
    if (isSimplifiedChinese) {
        //底部的提示文字
        [self.view addSubview:self.bottomTipLb];
        [self.bottomTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX).offset(-40);
            make.top.equalTo(self.submitBtn.mas_bottom).offset(50);
        }];
        
        //底部的提示按钮
        [self.view addSubview:self.bottomTipBtn];
        [self.bottomTipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bottomTipLb.mas_right).offset(3);
            make.centerY.equalTo(self.bottomTipLb.mas_centerY);
        }];
    }else{
        //底部的提示文字
        [self.view addSubview:self.bottomTipLb];
        [self.bottomTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX).offset(-60);
            make.top.equalTo(self.submitBtn.mas_bottom).offset(50);
        }];
        
        //底部的提示按钮
        [self.view addSubview:self.bottomTipBtn];
        [self.bottomTipBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bottomTipLb.mas_right).offset(5);
            make.centerY.equalTo(self.bottomTipLb.mas_centerY);
        }];
    }
    
    //其他注册方式的按钮
    [self.view addSubview:self.otherRegisterBtn];
    [self.otherRegisterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.registerTipLb.mas_bottom).offset(0);
        make.right.equalTo(self.view.mas_right).offset(-20);
    }];
    
}

//==========================method==========================
#pragma mark - 返回方法
- (void)returnBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 其他方式注册的点击事件(手机注册/邮箱注册)
- (void)otherWayRegisterClick
{
    [self.account_tf resignFirstResponder];
    [self.pwd_tf resignFirstResponder];
    [self.confirmPwd_tf resignFirstResponder];
    
    [self viewRotateAnimation];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        if (self.isEmail) {
            [self.otherRegisterBtn setTitle:NSLocalizedString(@"邮箱注册", nil) forState:UIControlStateNormal];
            self.locationLb.hidden = NO;
            self.localNumLb.text = @"+86";
            [self.submitBtn setTitle:NSLocalizedString(@"获取短信验证码", nil) forState:UIControlStateNormal];
            self.account_tf.placeholder = NSLocalizedString(@"请输入手机号码", nil);
            self.account_tf.keyboardType = UIKeyboardTypeNumberPad;
            self.isEmail = NO;
        }else{
            [self.otherRegisterBtn setTitle:NSLocalizedString(@"手机注册", nil) forState:UIControlStateNormal];
            self.locationLb.hidden = YES;
            self.localNumLb.text = NSLocalizedString(@"邮箱", nil);
            [self.submitBtn setTitle:NSLocalizedString(@"注册", nil) forState:UIControlStateNormal];
            self.account_tf.placeholder = NSLocalizedString(@"请输入邮箱账号", nil);
            self.account_tf.keyboardType = UIKeyboardTypeEmailAddress;
            self.isEmail = YES;
        }
    });
}

#pragma mark - 视频云眼用户协议按钮
- (void)agreementClick
{
//    NSLog(@"用户协议");
    UserAgreementVC *webVC = [[UserAgreementVC alloc]init];
    BaseUrlModel *urlModel = [BaseUrlDefaults geturlModel];
    webVC.url = urlModel.userAgreementUrl;
    [self.navigationController pushViewController:webVC animated:YES];
}
#pragma mark -----判断闭眼还是睁眼
-(void)isOpenPwdClick{
    //现在是睁眼状态
    if (isOpenPwd) {
        [self.showPwdBtn setImage:[UIImage imageNamed:@"closePwdeye"] forState:UIControlStateNormal];
        // 按下去了就是密文
        NSString *tempPwdStr = self.pwd_tf.text;
        self.pwd_tf.text = @"";
        self.pwd_tf.secureTextEntry = YES;
        self.pwd_tf.text = tempPwdStr;
        isOpenPwd = NO;
    }else{//现在是闭眼状态
        [self.showPwdBtn setImage:[UIImage imageNamed:@"showPwdeye"] forState:UIControlStateNormal];
        // 明文
        NSString *tempPwdStr = self.pwd_tf.text;
        self.pwd_tf.text = @""; // 可以防止切换的时候光标偏移
        self.pwd_tf.secureTextEntry = NO;
        self.pwd_tf.text = tempPwdStr;
        isOpenPwd = YES;
    }
}
#pragma mark -----确认密码判断闭眼还是睁眼
- (void)isOpenConfirmPwdClick
{
    //现在是睁眼状态
    if (isOpenConfirmPwd) {
        [self.showConfirmPwdBtn setImage:[UIImage imageNamed:@"closePwdeye"] forState:UIControlStateNormal];
        // 按下去了就是密文
        NSString *tempPwdStr = self.confirmPwd_tf.text;
        self.confirmPwd_tf.text = @"";
        self.confirmPwd_tf.secureTextEntry = YES;
        self.confirmPwd_tf.text = tempPwdStr;
        isOpenConfirmPwd = NO;
    }else{//现在是闭眼状态
        [self.showConfirmPwdBtn setImage:[UIImage imageNamed:@"showPwdeye"] forState:UIControlStateNormal];
        // 明文
        NSString *tempPwdStr = self.confirmPwd_tf.text;
        self.confirmPwd_tf.text = @""; // 可以防止切换的时候光标偏移
        self.confirmPwd_tf.secureTextEntry = NO;
        self.confirmPwd_tf.text = tempPwdStr;
        isOpenConfirmPwd = YES;
    }
}

#pragma mark - 获取验证码
- (void)submitClick
{
    [self.account_tf resignFirstResponder];
    [self.pwd_tf resignFirstResponder];
    [self.confirmPwd_tf resignFirstResponder];
    
    if (self.isEmail) {
        if (![NSString isValidateEmail:self.account_tf.text]) {
            [self LoginAlertAction:AlertAction_isEmail];//是否是正确的邮件
            return;
        }
    }else{
        if (![NSString validateMobile:self.account_tf.text]) {
            [self LoginAlertAction:AlertAction_isPhone];//是否是正确的手机号
            return;
        }
    }
    
    
    if (self.pwd_tf.text.length < 6 || self.pwd_tf.text.length > 16) {
        //密码是否合格
        [self LoginAlertAction:AlertAction_isPwd];
        return;
    }
    if (self.confirmPwd_tf.text.length < 6 || self.pwd_tf.text.length > 16) {
        //密码是否合格
        [self LoginAlertAction:AlertAction_isPwd];
        return;
    }
    if (![self.pwd_tf.text isEqualToString:self.confirmPwd_tf.text]) {
        [self LoginAlertAction:AlertAction_isSamePwd];
        return;
    }
    if (self.isEmail) {
        [self registerEmail];//邮箱注册
    }else{
        [self getVerifyCode];//获取验证码
    }
    
}

#pragma mark - 获取验证码
- (void)getVerifyCode
{
    [self.account_tf resignFirstResponder];
    [self.pwd_tf resignFirstResponder];
    [self.confirmPwd_tf resignFirstResponder];
    
    //发送手机验证码
    NSString * uuid = [unitl getKeyChain];
    NSDictionary *postDic = @{@"mobile":self.account_tf.text,@"term_id":uuid};
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/user/verify" parameters:postDic success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            SmsVerifyVC *smsVC = [[SmsVerifyVC alloc]init];
            smsVC.verifyCodeStatus = 1;
            smsVC.phoneStr = self.account_tf.text;
            smsVC.pwdStr = self.pwd_tf.text;
            [self.navigationController pushViewController:smsVC animated:YES];
            [XHToast showCenterWithText:NSLocalizedString(@"验证码已发送", nil)];
        }else if (ret == 1100){
            [self LoginAlertAction:AlertAction_verifyBusy];//验证码发送频繁
        }else{
            [self LoginAlertAction:AlertAction_failVerify];//验证码发送失败
        }
    } failure:^(NSError * _Nonnull error) {
        //判断网络连接
        [self LoginAlertAction:AlertAction_netWork];
    }];
    
}

#pragma mark - 邮箱注册
- (void)registerEmail
{
    [Toast showLoading:self.view Tips:NSLocalizedString(@"正在注册中，请稍候...", nil)];
    NSString *psdStr = @"";
    psdStr = [NSString stringWithFormat:@"%@%@",self.pwd_tf.text,PSDSUFFIX];
    NSString * psdStr_MD5 = [NSString md5:psdStr];
    NSString *resultPsd = [psdStr_MD5 uppercaseString];
    
    //term_id
    NSString * uuid = [unitl getKeyChain];
    NSNumber *accountType = [NSNumber numberWithInt:2];
    NSDictionary *postDic = @{@"mail":self.account_tf.text,@"term_id":uuid,@"app_type":@"200",@"passwd":resultPsd,@"accountType":accountType};//200表示iOS
    [[HDNetworking sharedHDNetworking] POST:@"v1/user/registerNew" parameters:postDic success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            //用户手机号/邮箱保存本地=====================
            LoginAccountModel *loginModel = [LoginAccountDefaults getAccountModel];
            if (loginModel) {
                if (self.isEmail) {
                    loginModel.mailStr = self.account_tf.text;
                }else{
                    loginModel.phoneStr = self.account_tf.text;
                }
            }
            [LoginAccountDefaults setAccountModel:loginModel];
            //用户手机号/邮箱保存本地=====================
            
            //注册
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [Toast dissmiss];
                UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"注册成功！若登录需激活账号，激活链接已发送到您的注册邮箱,请您在24小时内激活!", nil) preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *btnAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }];
                [alertCtrl addAction:btnAction];
                [self presentViewController:alertCtrl animated:YES completion:nil];
            });
            
        }else if (ret == 1005){
            [Toast dissmiss];
            [self LoginAlertAction:AlertAction_EmailExist];
        }else if (ret == 1701){
            [Toast dissmiss];
            [self LoginAlertAction:AlertAction_waitActivation];
        }else{
            [Toast dissmiss];
            [self LoginAlertAction:AlertAction_notRegister];
        }
    } failure:^(NSError * _Nonnull error) {
        [Toast dissmiss];
        //判断网络连接
        [self LoginAlertAction:AlertAction_netWork];
    }];
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
        case AlertAction_isEmail:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"请输入正确的邮箱", nil)];
        }
            break;
        //是否是合格的密码
        case AlertAction_isPwd:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"密码必须在6-20位之间", nil)];
        }
            break;
        //是否是一致的密码
        case AlertAction_isSamePwd:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"两次输入的密码不一致", nil)];
        }
            break;
        //验证码发送频繁
        case AlertAction_verifyBusy:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"验证码发送过于频繁，请稍候再试", nil)];
        }
            break;
            
        //验证码发送失败
        case AlertAction_failVerify:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"验证码发送失败，请稍候再试", nil)];
        }
            break;
        //网络是否打开
        case AlertAction_netWork:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"当前网络不可用，请检查您的网络", nil)];
        }
            break;
        //注册失败
        case AlertAction_notRegister:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"注册失败，请重新注册", nil)];
        }
            break;
        //用户已经注册过
        case AlertAction_EmailExist:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"该邮箱已被注册", nil)];
        }
            break;
        //已经注册需要激活
        case AlertAction_waitActivation:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"您已注册，请您在24小时内激活,过期或激活后链接自动失效!", nil)];
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
    if (self.account_tf.text.length != 0 && self.pwd_tf.text.length != 0 && self.confirmPwd_tf.text.length != 0) {
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
- (UILabel *)registerTipLb
{
    if (!_registerTipLb) {
        _registerTipLb = [[UILabel alloc]init];
        _registerTipLb.text = NSLocalizedString(@"注册账号", nil);
        _registerTipLb.font = FONTB(28);
        _registerTipLb.textAlignment = NSTextAlignmentLeft;
    }
    return _registerTipLb;
}

//注册图标
- (UIImageView *)registerIcon
{
    if (!_registerIcon) {
        _registerIcon = [[UIImageView alloc]init];
        _registerIcon.image = [UIImage imageNamed:@"registerLogo"];
    }
    return _registerIcon;
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

//密码提示View
-(UIView *)pwdView{
    if (!_pwdView) {
        _pwdView = [[UIView alloc]init];
        _pwdView.backgroundColor = [UIColor clearColor];
    }
    return _pwdView;
}

//密码文本框
-(UITextField *)pwd_tf{
    if (!_pwd_tf) {
        _pwd_tf = [[UITextField alloc]init];
        _pwd_tf.font =FONT(17);
        _pwd_tf.placeholder = NSLocalizedString(@"请输入密码", nil);
        _pwd_tf.secureTextEntry = YES;
        [_pwd_tf addTarget:self action:@selector(textValueChanged) forControlEvents:UIControlEventEditingChanged];
    }
    return _pwd_tf;
}

//确认密码View
- (UIView *)confirmPwdView
{
    if (!_confirmPwdView) {
        _confirmPwdView = [[UIView alloc]init];
        _confirmPwdView.backgroundColor = [UIColor clearColor];
    }
    return _confirmPwdView;
}

//确认密码文本框
- (UITextField *)confirmPwd_tf
{
    if (!_confirmPwd_tf) {
        _confirmPwd_tf = [[UITextField alloc]init];
        _confirmPwd_tf.font =FONT(17);
        _confirmPwd_tf.placeholder = NSLocalizedString(@"请确认密码", nil);
        _confirmPwd_tf.secureTextEntry = YES;
        [_confirmPwd_tf addTarget:self action:@selector(textValueChanged) forControlEvents:UIControlEventEditingChanged];
    }
    return _confirmPwd_tf;
}

//获取短信验证码按钮
- (UIButton *)submitBtn
{
    if (!_submitBtn) {
        _submitBtn = [[UIButton alloc]init];
        _submitBtn.userInteractionEnabled = NO;
        _submitBtn.layer.cornerRadius = 22.5f;
        if (self.isEmail) {
            [_submitBtn setTitle:NSLocalizedString(@"注册", nil) forState:UIControlStateNormal];
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

//底部的提示文字
- (UILabel *)bottomTipLb
{
    if (!_bottomTipLb) {
        _bottomTipLb = [[UILabel alloc]init];
        _bottomTipLb.text = NSLocalizedString(@"我已阅读并同意", nil);
        _bottomTipLb.font = FONT(13);
        _bottomTipLb.textColor = RGB(50, 50, 50);
    }
    return _bottomTipLb;
}

//底部的提示按钮
- (UnderlineBtn *)bottomTipBtn
{
    if (!_bottomTipBtn) {
        _bottomTipBtn = [[UnderlineBtn alloc]init];
        [_bottomTipBtn setTitle:NSLocalizedString(@"拾光云服务协议", nil) forState:UIControlStateNormal];
        [_bottomTipBtn setColor:RGB(160, 173, 220)];
        [_bottomTipBtn setTitleColor:RGB(160, 173, 220) forState:UIControlStateNormal];
        _bottomTipBtn.titleLabel.font = FONT(13);
        [_bottomTipBtn addTarget:self action:@selector(agreementClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomTipBtn;
}

//查看密码的按钮
- (UIButton *)showPwdBtn
{
    if (!_showPwdBtn) {
        _showPwdBtn = [[UIButton alloc]init];
        [_showPwdBtn setImage:[UIImage imageNamed:@"closePwdeye"] forState:UIControlStateNormal];
        [_showPwdBtn addTarget:self action:@selector(isOpenPwdClick) forControlEvents:UIControlEventTouchUpInside];
        //默认显示闭眼
        isOpenPwd = NO;
    }
    return _showPwdBtn;
}

//确认密码的查看密码的按钮
- (UIButton *)showConfirmPwdBtn
{
    if (!_showConfirmPwdBtn) {
        _showConfirmPwdBtn = [[UIButton alloc]init];
        [_showConfirmPwdBtn setImage:[UIImage imageNamed:@"closePwdeye"] forState:UIControlStateNormal];
        [_showConfirmPwdBtn addTarget:self action:@selector(isOpenConfirmPwdClick) forControlEvents:UIControlEventTouchUpInside];
        //默认显示闭眼
        isOpenConfirmPwd = NO;
    }
    return _showConfirmPwdBtn;
}

//其他注册方式的按钮
- (UnderlineBtn *)otherRegisterBtn
{
    if (!_otherRegisterBtn) {
        _otherRegisterBtn = [[UnderlineBtn alloc]init];
        NSString *btnTitle = self.isEmail?NSLocalizedString(@"手机注册", nil):NSLocalizedString(@"邮箱注册", nil);
        [_otherRegisterBtn setTitle:btnTitle forState:UIControlStateNormal];
        [_otherRegisterBtn setColor:MAIN_COLOR];
        [_otherRegisterBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        _otherRegisterBtn.titleLabel.font = FONT(16);
        [_otherRegisterBtn addTarget:self action:@selector(otherWayRegisterClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _otherRegisterBtn;
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
