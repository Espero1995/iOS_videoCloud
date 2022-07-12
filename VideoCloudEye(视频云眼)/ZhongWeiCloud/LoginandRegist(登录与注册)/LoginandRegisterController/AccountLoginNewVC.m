//
//  AccountLoginNewVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/29.
//  Copyright © 2018年 张策. All rights reserved.
//
//图片尺寸
#define LeftSpacing 0.075*iPhoneWidth
#define TopSpacing iPhoneWidth/5.5
#define TopSpacingX iPhoneWidth/3
//图片尺寸
#define LOGOWIDTH iPhoneWidth/5
//文本尺寸
#define ACCOUNTWIDTH 0.85*iPhoneWidth
//ap模式下判断wifi是否是设备发出的wifi前缀
#define WIFI_SUFFIX @"JW_"
#define WIFI_PORT @"80"
#define RANDOM @"310000"
#define WIFI_IP @"192.168.1.1"//暂时这边ap模式连接的设备wifi—ip是固定的

#import "AccountLoginNewVC.h"
#import <QuartzCore/CoreAnimation.h>
#import "RegisterNewVC.h"//注册
#import "ForgetPwdVC.h"//忘记密码
#import "SmsVerifyVC.h"
#import "IPSettingVC.h"//IP设置
/*网络*/
#import "JWOpenSdk.h"
//推送
#import <CloudPushSDK/CloudPushSDK.h>
//指纹
#import "fingerPrintLoginManage.h"
#import "FingerPrintLoginVC.h"
//微信
#import "WXApi.h"
#import "WeChatVerifyVC.h"
//APView
#import "ApLoginView.h"
#import "RealTimeVideoVC.h"
#import "APModel.h"
#import "wifiInfoManager.h"
/*自定义按钮*/
#import "UnderlineBtn.h"
#import <SystemConfiguration/CaptiveNetwork.h>
//其他
#import "AppDelegate.h"
#import "ZCTabBarController.h"
#import "BaseNavigationViewController.h"
#import <CloudPushSDK/CloudPushSDK.h>


//警告框类型
typedef NS_ENUM(NSInteger,AlertAction){
    AlertAction_isPhone,//是否是正确的手机号
    AlertAction_isEmail,//是否是正确的邮箱
    AlertAction_netWork,//网络是否打开
    AlertAction_notLogin,//登录失败
    AlertAction_errorPhoneorPwd,//账号密码错误
    AlertAction_errorEmailorPwd,//邮箱账号密码错误
    AlertAction_verifyBusy,//验证码发送频繁
    AlertAction_failVerify,//验证码发送失败
};

@interface AccountLoginNewVC ()<WXDelegate,AploginViewDelegate,CAAnimationDelegate>
{
    //判断密码展示还是隐藏
    BOOL isOpenPwd;
    AppDelegate *appdelegate;
    BOOL isEmail;
}
@property (nonatomic,strong) UIImageView *logoImgView;//图标view
@property (nonatomic,strong) UIView *accountView;//账号提示View
@property (nonatomic,strong) UITextField *account_tf;//账号文本框
@property (nonatomic,strong) UIView *pwdView;//密码提示View
@property (nonatomic,strong) UITextField *pwd_tf;//密码文本框
@property (nonatomic,strong) UIButton *showPwdBtn;//查看密码的按钮
@property (nonatomic,strong) UnderlineBtn *ipSettingBtn;//设置ip按钮
//@property (nonatomic,strong) UIButton *registerBtn;//注册按钮
//@property (nonatomic,strong) UIButton *moreBtn;//更多按钮
//@property (nonatomic,strong) UIButton *forgetPwdBtn;//忘记密码按钮
@property (nonatomic,strong) UIButton *loginBtn;//登录按钮

@property (nonatomic, strong) ApLoginView* apLoginView;//apLogin的弹出框
@property (strong, nonatomic) UIWindow *window;


@property (nonatomic,strong) UIView *otherLoginView;//其他登录方式View
//@property (nonatomic,strong) UIButton *weChatLoginBtn;//微信登录按钮
//@property (nonatomic,strong) UIButton *otherLoginBtn;// 手机登录/邮箱登录
@end

@implementation AccountLoginNewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpUI];
    [self.navigationController setNavigationBarHidden:YES animated:YES]; //设置隐藏
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    if (self.account_tf.text.length == 0) {
        LoginAccountModel *loginModel = [LoginAccountDefaults getAccountModel];
        if (loginModel) {
            self.account_tf.text = loginModel.phoneStr;
        }else{
            loginModel = [[LoginAccountModel alloc]init];
            [LoginAccountDefaults setAccountModel:loginModel];
        }
    }
    
    
    /*
    if ([WXApi isWXAppInstalled]){
        self.weChatLoginBtn.hidden = NO;
    }else{
        self.weChatLoginBtn.hidden = YES;
    }
    */
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.account_tf resignFirstResponder];
    [self.pwd_tf resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//==========================init==========================
#pragma mark ----- 初始化布局
- (void)setUpUI
{
    //LOGO图标
    [self.view addSubview:self.logoImgView];
    [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (iPhone_X_) {
            make.top.mas_equalTo(TopSpacingX);
        }else{
            make.top.mas_equalTo(iPhoneWidth/4);
        }
        make.centerX.equalTo(self.view);
    }];
    
    //账号View初始化
    [self.view addSubview:self.accountView];
    [self.accountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoImgView.mas_bottom).offset(TopSpacing-25);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 40));
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
    //账号文本
    [self.accountView addSubview:self.account_tf];
    [self.account_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.accountView.mas_centerY);
        make.left.equalTo(self.accountView.mas_left).offset(0);
        make.right.equalTo(self.accountView.mas_right);
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
        make.left.equalTo(self.pwdView.mas_left).offset(0);
        make.right.equalTo(self.showPwdBtn.mas_left).offset(-5);
    }];
    //ip配置
    [self.view addSubview:self.ipSettingBtn];
    [self.ipSettingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(LeftSpacing);
        make.top.equalTo(self.pwdView.mas_bottom).offset(10);
    }];
    /*
    //注册按钮
    [self.view addSubview:self.registerBtn];
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(LeftSpacing);
        make.top.equalTo(self.pwdView.mas_bottom).offset(10);
    }];
    //竖线
    UIView *lineV = [[UIView alloc]init];
    lineV.backgroundColor = RGB(50, 50, 50);
    [self.view addSubview:lineV];
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.registerBtn.mas_right).offset(5);
        make.centerY.equalTo(self.registerBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(1.5, 15));
    }];
    //更多按钮
    [self.view addSubview:self.moreBtn];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lineV.mas_right).offset(5);
        make.centerY.equalTo(self.registerBtn.mas_centerY);
    }];
    //忘记密码
    [self.view addSubview:self.forgetPwdBtn];
    [self.forgetPwdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.accountView.mas_right).offset(0);
        make.centerY.equalTo(self.registerBtn.mas_centerY);
    }];
     */
    //登录按钮
    [self.view addSubview:self.loginBtn];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.ipSettingBtn.mas_bottom).offset(TopSpacing-20);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 45));
    }];
    
    [self.view addSubview:self.otherLoginView];
    [self.otherLoginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        if (iPhone_X_) {
            make.top.equalTo(self.view.mas_bottom).offset(-110);
        }else{
            make.top.equalTo(self.view.mas_bottom).offset(-90);
        }
        make.width.mas_equalTo(iPhoneWidth);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
    }];
    /*
    UILabel *otherLoginLb = [[UILabel alloc]initWithFrame:CGRectZero];
    otherLoginLb.font = FONT(16);
    otherLoginLb.textColor = [UIColor lightGrayColor];
    otherLoginLb.textAlignment = NSTextAlignmentCenter;
    otherLoginLb.text =NSLocalizedString(@"其他登录方式", nil) ;
    [self.otherLoginView addSubview:otherLoginLb];
    [otherLoginLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.otherLoginView.mas_centerX);
        make.top.equalTo(self.otherLoginView.mas_top);
        
        if (isSimplifiedChinese) {
            make.width.equalTo(@150);
        }else{
            make.width.equalTo(@180);
        }
        
    }];
    float width;
    if (isSimplifiedChinese) {
        width = (ACCOUNTWIDTH - 130)/2;
    }else{
        width = (ACCOUNTWIDTH - 150)/2;
    }
    UILabel *leftLineLb = [[UILabel alloc]init];
    leftLineLb.backgroundColor = [UIColor lightGrayColor];
    [self.otherLoginView addSubview:leftLineLb];
    [leftLineLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(otherLoginLb.mas_centerY);
        make.right.equalTo(otherLoginLb.mas_left).offset(0);
        make.height.mas_equalTo(@1);
        make.width.mas_equalTo(width);
    }];
    UILabel *rightLineLb = [[UILabel alloc]init];
    rightLineLb.backgroundColor = [UIColor lightGrayColor];
    [self.otherLoginView addSubview:rightLineLb];
    [rightLineLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(otherLoginLb.mas_centerY);
        make.left.equalTo(otherLoginLb.mas_right).offset(0);
        make.height.mas_equalTo(@1);
        make.width.mas_equalTo(width);
    }];
    
    //微信按钮
    [self.otherLoginView addSubview:self.weChatLoginBtn];
    [self.weChatLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.otherLoginView.mas_centerX).offset(30);
        if (iPhone_X_) {
            make.bottom.equalTo(self.otherLoginView.mas_bottom).offset(-35);
        }else{
            make.bottom.equalTo(self.otherLoginView.mas_bottom).offset(-20);
        }
    }];
     
    //其他登录方式按钮
    [self.otherLoginView addSubview:self.otherLoginBtn];
    [self.otherLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.otherLoginView.mas_centerX);
        if (iPhone_X_) {
            make.bottom.equalTo(self.otherLoginView.mas_bottom).offset(-35);
        }else{
            make.bottom.equalTo(self.otherLoginView.mas_bottom).offset(-20);
        }
    }];
     */
}
//==========================method==========================
#pragma mark - 注册按钮点击事件
- (void)registerClick
{
    RegisterNewVC *registerVC = [[RegisterNewVC alloc]init];
    registerVC.isEmail = isEmail;
    [self.navigationController pushViewController:registerVC animated:YES];
}
#pragma mark - 更多按钮点击事件
- (void)moreClick
{
    NSArray *arr=[[NSArray alloc]initWithObjects:NSLocalizedString(@"AP预览", nil), nil];
    [ChooseDialog createWithSystemStyle:self.navigationController Title:nil Message:nil Array:arr CallBack:^(NSInteger index) {
        if (index==0) {
            [self apLoginClick];//AP预览
        }
    }];
}
#pragma mark - 忘记密码点击事件
- (void)forgetPwdClick
{
    ForgetPwdVC *forgetpwdVC = [[ForgetPwdVC alloc]init];
    forgetpwdVC.isEmail = isEmail;
    [self.navigationController pushViewController:forgetpwdVC animated:YES];
}
#pragma mark - 登录按钮点击事件
- (void)loginClick
{
    [self.account_tf resignFirstResponder];
    [self.pwd_tf resignFirstResponder];
    //IP本地存储
    NSUserDefaults *ipDefault = [NSUserDefaults standardUserDefaults];
    NSString *ipStr = [ipDefault objectForKey:CURRENT_IP_KEY];
    if (!ipStr) {
        [XHToast showCenterWithText:@"请先进行云平台配置"];
        return ;
    }
    [Toast showLoading:self.view Tips:NSLocalizedString(@"登录中，请稍候...", nil)];
    [self beginLogin];
}
#pragma mark - 开始登录
- (void)beginLogin
{
    NSString *psdStr_MD5 = [NSString md5:self.pwd_tf.text];
    NSString *resultPsd = [NSString stringWithFormat:@"%@",psdStr_MD5];
    NSLog(@"密码是:%@",resultPsd);
    NSDictionary *postDic = @{@"account":self.account_tf.text,@"passwd":resultPsd};
    NSLog(@"postDic：登录给后台的dic是:%@",postDic);

    [[HDNetworking sharedHDNetworking] POST:@"open/user/login" parameters:postDic success:^(id  _Nonnull responseObject) {
        NSLog(@"登录responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            //jwsdk
            NSString *token = responseObject[@"body"][@"access_token"];
            NSString *userid = responseObject[@"body"][@"user_id"];
            [JWOpenSdk setAccessToken:token userid:userid];
            
            //写入数据到本地
            UserModel *userModel = [UserModel mj_objectWithKeyValues:responseObject[@"body"]];
            NSDictionary *bodyDic = responseObject[@"body"];
            NSString *nameStr = [NSString isNullToString:bodyDic[@"user_name"]];
            NSString *IDStr = [NSString isNullToString:bodyDic[@"user_id"]];
            NSString * pushStr = [NSString stringWithFormat:@"%@%@",nameStr,IDStr];
            NSLog(@"登录的时候，生成的根据不同id的推送key是~~~user_id_push：%@",pushStr);
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[NSString stringWithString:IDStr] forKey:@"user_id"];
            
            [defaults setObject:[NSString stringWithString:pushStr] forKey:@"user_id_push"];
            [defaults synchronize];

            MySingleton *singleton = [MySingleton shareInstance];
            if ([nameStr isEqualToString:@""]) {
                singleton.userNameStr = @"User";
            }else{
                singleton.userNameStr = nameStr;
            }
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userModel];
            [[NSUserDefaults standardUserDefaults]setObject:data forKey:USERMODEL];
            //用户登录的电话号码和手机号
            [[NSUserDefaults standardUserDefaults]setObject:postDic forKey:USERLOGINMES];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //用户手机号/邮箱保存本地=====================
            LoginAccountModel *loginModel = [LoginAccountDefaults getAccountModel];
            if (loginModel) {
                if (isEmail) {
                    loginModel.mailStr = self.account_tf.text;
                    loginModel.isPhoneLogin = NO;
                }else{
                    loginModel.phoneStr = self.account_tf.text;
                    loginModel.isPhoneLogin = YES;
                }
            }
            [LoginAccountDefaults setAccountModel:loginModel];
            //用户手机号/邮箱保存本地=====================
            
            [CloudPushSDK bindAccount:userModel.user_id withCallback:^(CloudPushCallbackResult *res) {
                NSLog(@"res:%@", res);
                if (res.success) {
                    NSLog(@"【阿里云推送】绑定成功");
                }else
                {
                    NSLog(@"【阿里云推送】绑定失败");
                }
            }];
            
            //登录中
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [Toast dissmiss];
                self.pwd_tf.text = @"";
                //登录
                [self runMainViewController];
            });
        }
        else if(ret == 1004){
            [Toast dissmiss];
            if (isEmail) {
                //邮箱账号密码错误
                [self LoginAlertAction:AlertAction_errorEmailorPwd];
            }else{
                //账号与密码不存在
                [self LoginAlertAction:AlertAction_errorPhoneorPwd];
            }
            
        }else if(ret == 1006){
            [Toast dissmiss];
            NSLog(@"该手机号第一次在该设备上登录，需要发送验证码确认");
            [self firstSendVerifyCode];
            
        }else{
            [Toast dissmiss];
            [self LoginAlertAction:AlertAction_notLogin];
        }
    }failure:^(NSError * _Nonnull error) {
        [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:error.userInfo[@"NSLocalizedDescription"]];
        [Toast dissmiss];
    }];
    
}
#pragma mark - 第一次发送验证码
- (void)firstSendVerifyCode
{
    //发送手机验证码
    NSString * uuid = [unitl getKeyChain];
    NSDictionary *postDic = @{@"mobile":self.account_tf.text,@"term_id":uuid};
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/user/verify" parameters:postDic success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            SmsVerifyVC *smsVC = [[SmsVerifyVC alloc]init];
            smsVC.verifyCodeStatus = 3;
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

#pragma mark ------进入主界面
- (void)runMainViewController
{
    ZCTabBarController *mainTabVC = [[ZCTabBarController alloc]init];
    [mainTabVC setVideoSdk];
    BOOL isLogin = YES;
    NSNumber *loginNum = [NSNumber numberWithBool:isLogin];
    [[NSUserDefaults standardUserDefaults]setObject:loginNum forKey:ISLOGIN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    mainTabVC.tabSelectIndex = 0;
    [self.view removeFromSuperview];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = mainTabVC;
    [self.window makeKeyAndVisible];
}


#pragma mark - 微信按钮点击事件
- (void)weChatLoginBtnClick
{
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq *req = [[SendAuthReq alloc]init];
        req.scope = @"snsapi_userinfo";
        APP_Environment environment = [unitl environment];
        NSString * weixinAppIDStr;
        switch (environment) {
            case Environment_official:
                weixinAppIDStr = weixinAppID_official;
                break;
            case Environment_test:
                weixinAppIDStr = weixinAppID_test;
                break;
            default:
                break;
        }
        req.openID = weixinAppIDStr;
        req.state = @"xiaoweiguanjia";
        appdelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        appdelegate.wxDelegate = self;
        [WXApi sendReq:req];
    }
}
/*
#pragma mark - 其他方式登录的点击事件(手机登录/邮箱登录)
- (void)otherWayLoginClick
{
    [self viewRotateAnimation];
    LoginAccountModel *loginModel = [LoginAccountDefaults getAccountModel];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        if (isEmail) {
            [self.otherLoginBtn setImage:[UIImage imageNamed:@"emailLogin"] forState:UIControlStateNormal];
            self.account_tf.text = loginModel.phoneStr;
            self.account_tf.placeholder = NSLocalizedString(@"请输入手机号码", nil);
            self.account_tf.keyboardType = UIKeyboardTypeNumberPad;
            isEmail = NO;
        }else{
            [self.otherLoginBtn setImage:[UIImage imageNamed:@"phoneLogin"] forState:UIControlStateNormal];
            self.account_tf.text = loginModel.mailStr;
            self.account_tf.placeholder = NSLocalizedString(@"请输入邮箱账号", nil);
            self.account_tf.keyboardType = UIKeyboardTypeEmailAddress;
            isEmail = YES;
        }
    });
}
*/
#pragma mark - AP预览
- (void)apLoginClick
{
    [[unitl mainWindow] addSubview:self.apLoginView];
    self.apLoginView.hidden= NO;
    [self.apLoginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo([unitl mainWindow]);
    }];
}

#pragma mark - IP设置
- (void)ipSettingClick
{
    IPSettingVC *setVC = [[IPSettingVC alloc]init];
    [self.navigationController pushViewController:setVC animated:YES];
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


//警告框提醒
- (void)LoginAlertAction:(AlertAction)action
{
    switch (action) {
        //是否是正确的手机号
        case AlertAction_isPhone:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"请输入正确的账号", nil)];
        }
            break;
        //是否是正确的邮箱
        case AlertAction_isEmail:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"请输入正确的邮箱", nil)];
        }
            break;
        //网络是否打开
        case AlertAction_netWork:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"当前网络不可用，请检查您的网络", nil)];
        }
            break;
        //账号密码错误
        case AlertAction_errorPhoneorPwd:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"请输入正确的账号或密码", nil)];
        }
            break;
        //邮箱账号密码错误
        case AlertAction_errorEmailorPwd:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"请输入正确的邮箱账号和密码；若已注册请确认是否在邮箱中已激活该账号", nil)];
        }
            break;
        //登录失败
        case AlertAction_notLogin:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"登录失败，请稍候再试", nil)];
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

#pragma mark ------得到当前wifi名称
- (const char *)getWifiName
{
    const char * wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            wifiName = [[networkInfo objectForKey:(__bridge NSString*)kCNNetworkInfoKeySSID] UTF8String];
            CFRelease(dictRef);
        }
    }
    CFRelease(wifiInterfaces);
    return wifiName;
}

//==========================delegate==========================
-(void)textValueChanged{
    if (self.account_tf.text.length != 0 && self.pwd_tf.text.length != 0) {
        self.loginBtn.backgroundColor = MAIN_COLOR;
        self.loginBtn.userInteractionEnabled = YES;
    }else{
        self.loginBtn.backgroundColor = RGB(220, 223, 230);
        self.loginBtn.userInteractionEnabled = NO;
    }
}

#pragma mark 微信登录回调。
-(void)loginSuccessByCode:(NSString *)code{
    NSLog(@"微信登录回调code: %@",code);
    NSString * uuid = [unitl getKeyChain];
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    [postDic setObject:code forKey:@"wechat_code"];
    [postDic setObject:@"" forKey:@"mobile"];
    [postDic setObject:@"" forKey:@"wechat_id"];
    [postDic setObject:@"" forKey:@"ver_code"];
    [postDic setObject:app_type forKey:@"app_type"];
    [postDic setObject:uuid forKey:@"term_id"];
    
    [[HDNetworking sharedHDNetworking] GET:@"v1/user/wechatlogin" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"微信登录回调code传给后台：返回：%@",responseObject);
        if ([responseObject[@"ret"] integerValue] == 0) {
            NSString *phoneNumStr = responseObject[@"body"][@"mobile"];
            if (![NSString isNull:phoneNumStr]) {//判断手机号是否为空：空表示未进行微信绑定；反之，则绑过微信号。
                //jwsdk
                NSString *token = responseObject[@"body"][@"access_token"];
                NSString *userid = responseObject[@"body"][@"user_id"];
                [JWOpenSdk setAccessToken:token userid:userid];
                
                //写入数据到本地
                UserModel *userModel = [UserModel mj_objectWithKeyValues:responseObject[@"body"]];
                NSDictionary *bodyDic = responseObject[@"body"];
                NSString *nameStr = [NSString isNullToString:bodyDic[@"user_name"]];
                NSString *IDStr = [NSString isNullToString:bodyDic[@"user_id"]];
                NSString * pushStr = [NSString stringWithFormat:@"%@%@",nameStr,IDStr];
                NSLog(@"登录的时候，生成的根据不同id的推送key是~~~user_id_push：%@",pushStr);
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[NSString stringWithString:IDStr] forKey:@"user_id"];
                [defaults setObject:[NSString stringWithString:pushStr] forKey:@"user_id_push"];
                [defaults synchronize];
                
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userModel];
                [[NSUserDefaults standardUserDefaults]setObject:data forKey:USERMODEL];
                //用户登录的电话号码和手机号
                [[NSUserDefaults standardUserDefaults]setObject:postDic forKey:USERLOGINMES];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //用户手机号保存本地=====================
//                NSData *phoneNumData = [NSKeyedArchiver archivedDataWithRootObject:responseObject[@"body"][@"mobile"]];
//                [[NSUserDefaults standardUserDefaults]setObject:phoneNumData forKey:LOGINPHONE];
//                [[NSUserDefaults standardUserDefaults]synchronize];
                //用户手机号保存本地=====================
                
                
                [self runMainViewController];
            }else{
                WeChatVerifyVC *weChatVC = [[WeChatVerifyVC alloc]init];
                weChatVC.hidesBottomBarWhenPushed = YES;
                weChatVC.weixinOpenId = responseObject[@"body"][@"wechat_id"];
                [self.navigationController pushViewController:weChatVC animated:YES];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


#pragma mark === ap模式view的代理事件
- (void)closeBtnClick:(UIButton *)btn
{
    // [self.apLoginView disappear];
    [self.apLoginView removeFromSuperview];
    self.apLoginView = nil;
}
#pragma mark == ap模式下，点击登录，开始预览
- (void)startBtnClick:(UIButton *)btn
{
    
    NSString * accountStr = self.apLoginView.accountTF.text;
    NSString * psdStr = self.apLoginView.psdTF.text;
    
    //获取wifi名称
    const char * wifiCharStr = [self getWifiName];
    if (wifiCharStr) {
        NSString * wifiStr = [[NSString alloc] initWithUTF8String:wifiCharStr];
        NSString * judgeStr = [wifiStr substringToIndex:3];
        if (![judgeStr isEqualToString:WIFI_SUFFIX]) {
            [XHToast showCenterWithText:NSLocalizedString(@"当前WiFi不是设备热点，请手动连接至设备的热点", nil)];
            return;
        }
    }else
    {
        [XHToast showCenterWithText:NSLocalizedString(@"当前没有连接到WiFi，请手动连接至设备的热点", nil)];
        return;
    }
    if ([NSString isNull:accountStr]) {
        [XHToast showCenterWithText:NSLocalizedString(@"账号不能为空", nil)];
        return;
    }
    if ([NSString isNull:psdStr]) {
        [XHToast showCenterWithText:NSLocalizedString(@"密码不能为空", nil)];
        return;
    }
    
    NSString * wifiIPStr = [wifiInfoManager getIPAddress];
    
    NSString *gatewayIp = [wifiInfoManager getGatewayIpForCurrentWiFi];
    NSLog(@"网关地址：%@", gatewayIp);
    
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    [postDic setObject:@0 forKey:@"session"];
    [postDic setObject:@2 forKey:@"id"];
    
    NSMutableDictionary *callDic = [NSMutableDictionary dictionary];
    [callDic setObject:@"rpc" forKey:@"service"];
    [callDic setObject:@"login" forKey:@"method"];
    
    /*随机数*/
    int a = arc4random() % 100000;
    NSString *randomStr = [NSString stringWithFormat:@"%06d", a];
    
    /*密码，两次哈希,MD5（md5(oldpassword)+random）*/
    /*
     NSString * psd_first_md5 = [NSString stringWithMd5:psdStr];
     NSString * tempPsdStr = [NSString stringWithFormat:@"%@%@",psd_first_md5,randomStr];
     NSString * psd_second_md5 = [NSString stringWithMd5:tempPsdStr];
     */
    //注释，不晓得为什么上面的md5方法出来的结果并不是32位的，并且也是错误的，后面要查证
    
    NSString * psdStr_MD5_first = [NSString md5:psdStr];
    NSString * tempPsdStr_ = [NSString stringWithFormat:@"%@%@",psdStr_MD5_first,randomStr];
    NSString * psd_md5_second = [NSString md5:tempPsdStr_];
    
    float  psd_second_md5_length = [psd_md5_second length];
    NSLog(@"加密后的密码长度:%f===%@",psd_second_md5_length,psd_md5_second);
    
    NSMutableDictionary *paramsDic = [NSMutableDictionary dictionary];
    [paramsDic setObject:accountStr forKey:@"userName"];
    [paramsDic setObject:psd_md5_second forKey:@"password"];
    [paramsDic setObject:randomStr forKey:@"random"];
    [paramsDic setObject:@"127.0.0.1" forKey:@"ip"];
    [paramsDic setObject:@80 forKey:@"port"];
    
    [postDic setObject:callDic forKey:@"call"];
    [postDic setObject:paramsDic forKey:@"params"];
    
    NSString * postJsonStr = [unitl dictionaryToJSONString:postDic];
    
    NSString * url = [NSString stringWithFormat:@"http://%@/%@",gatewayIp,WIFI_ADRESS];
    NSLog(@"点击了ap开始预览按钮,账号：%@====密码：%@==wifiip===%@====url:%@===========postDic：%@===postJsonStr:%@",accountStr,psdStr,wifiIPStr,url,postDic,postJsonStr);
    //VmNet_Connect
    
    [[HDNetworking sharedHDNetworking] AP_POST:url parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"ap模式登录：返回：%@",responseObject);
        
        self.apLoginView.hidden = YES;
        // [self.apLoginView disappear];
        [self.apLoginView removeFromSuperview];
        self.apLoginView = nil;
        
        [XHToast showCenterWithText:[NSString stringWithFormat:@"已经点击了预览%@",responseObject]];
        if ([responseObject[@"result"]boolValue] == true) {
            APModel * apModel = [[APModel alloc]init];
            apModel.result = responseObject[@"result"];
            apModel.ID = responseObject[@"id"];
            apModel.session = responseObject[@"session"];
            apModel.params = responseObject[@"params"];
            apModel.session_params = responseObject[@"params"][@"session"];
            
            [unitl saveNeedArchiverDataWithKey:@"apModel" Data:apModel];
            
            //直接进入ap播放界面
            RealTimeVideoVC *realVideVC = [[RealTimeVideoVC alloc] init];
            // messageVC.expertId = [userInfo objectForKey:@"message_id"];
            realVideVC.hidesBottomBarWhenPushed = YES;
            realVideVC.videoMode = VideoMode_AP;
            
            ZCTabBarController *rootVC = [[ZCTabBarController alloc] init];
            self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            [self.window setRootViewController:rootVC];
            [self.window addSubview:rootVC.view];
            [self.window makeKeyAndVisible];
            
            ZCTabBarController *baseTabBar = (ZCTabBarController *)self.window.rootViewController;
            [baseTabBar.viewControllers[baseTabBar.selectedIndex] pushViewController:realVideVC animated:NO];
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"ap模式登录失败:%@",error);
    }];
}

//==========================lazy loading==========================
#pragma mark - getter && setter
//图标View
- (UIImageView *)logoImgView
{
    if (!_logoImgView) {
        _logoImgView = [[UIImageView alloc]init];
        if (isSimplifiedChinese) {
            _logoImgView.image = [UIImage imageNamed:@"loginLogo"];
        }else{
            _logoImgView.image = [UIImage imageNamed:@"EloginLogo"];
        }
    }
    return _logoImgView;
}

//账号提示View
-(UIView *)accountView
{
    if (!_accountView) {
        _accountView = [[UIView alloc]init];
        _accountView.backgroundColor = [UIColor clearColor];
    }
    return _accountView;
}

//账号文本框
-(UITextField *)account_tf
{
    if (!_account_tf) {
        _account_tf = [[UITextField alloc]init];
        _account_tf.font =FONT(17);
        _account_tf.placeholder = NSLocalizedString(@"请输入账号", nil);
        _account_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_account_tf addTarget:self action:@selector(textValueChanged) forControlEvents:UIControlEventEditingChanged];
    }
    return _account_tf;
}

//密码提示View
-(UIView *)pwdView
{
    if (!_pwdView) {
        _pwdView = [[UIView alloc]init];
        _pwdView.backgroundColor = [UIColor clearColor];
    }
    return _pwdView;
}

//密码文本框
-(UITextField *)pwd_tf
{
    if (!_pwd_tf) {
        _pwd_tf = [[UITextField alloc]init];
        _pwd_tf.font =FONT(17);
        _pwd_tf.placeholder = NSLocalizedString(@"请输入登录密码", nil);
        _pwd_tf.secureTextEntry = YES;
        [_pwd_tf addTarget:self action:@selector(textValueChanged) forControlEvents:UIControlEventEditingChanged];
    }
    return _pwd_tf;
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

//设置ip按钮
- (UnderlineBtn *)ipSettingBtn
{
    if (!_ipSettingBtn) {
        _ipSettingBtn = [[UnderlineBtn alloc]init];
        _ipSettingBtn.titleLabel.font = FONT(14);
        _ipSettingBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_ipSettingBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        [_ipSettingBtn setColor:MAIN_COLOR];
        [_ipSettingBtn setTitle:NSLocalizedString(@"云平台配置", nil) forState:UIControlStateNormal];
        [_ipSettingBtn addTarget:self action:@selector(ipSettingClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ipSettingBtn;
}

/*
//注册按钮
- (UIButton *)registerBtn
{
    if (!_registerBtn) {
        _registerBtn = [[UIButton alloc]init];
        _registerBtn.titleLabel.font = FONT(14);
        _registerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_registerBtn setTitleColor:RGB(50, 50, 50) forState:UIControlStateNormal];
        [_registerBtn setTitle:NSLocalizedString(@"注册", nil) forState:UIControlStateNormal];
        [_registerBtn addTarget:self action:@selector(registerClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerBtn;
}

//更多按钮
- (UIButton *)moreBtn
{
    if (!_moreBtn) {
        _moreBtn = [[UIButton alloc]init];
        _moreBtn.titleLabel.font = FONT(14);
        _moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_moreBtn setTitleColor:RGB(50, 50, 50) forState:UIControlStateNormal];
        [_moreBtn setTitle:NSLocalizedString(@"更多", nil) forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

//忘记密码按钮
- (UIButton *)forgetPwdBtn
{
    if (!_forgetPwdBtn) {
        _forgetPwdBtn = [[UIButton alloc]init];
        _forgetPwdBtn.titleLabel.font = FONT(14);
        _forgetPwdBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_forgetPwdBtn setTitleColor:RGB(50, 50, 50) forState:UIControlStateNormal];
        [_forgetPwdBtn setTitle:NSLocalizedString(@"忘记密码", nil) forState:UIControlStateNormal];
        [_forgetPwdBtn addTarget:self action:@selector(forgetPwdClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _forgetPwdBtn;
}
*/
//登录按钮
- (UIButton *)loginBtn
{
    if (!_loginBtn) {
        _loginBtn = [[UIButton alloc]init];
        _loginBtn.userInteractionEnabled = NO;
        _loginBtn.layer.cornerRadius = 22.5f;
        [_loginBtn setTitle:NSLocalizedString(@"登录", nil) forState:UIControlStateNormal];
        _loginBtn.backgroundColor = RGB(220, 223, 230);
        _loginBtn.layer.cornerRadius = 20.0f;
        _loginBtn.layer.shadowColor = [UIColor grayColor].CGColor;
        _loginBtn.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        _loginBtn.layer.shadowRadius = 3.0;
        _loginBtn.layer.shadowOpacity = 0.3;
        [_loginBtn addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginBtn;
}

//ap预览的View
- (ApLoginView *)apLoginView
{
    if (!_apLoginView) {
        _apLoginView = [[ApLoginView alloc]init];
        _apLoginView.delegate = self;
        _apLoginView.hidden = YES;
    }
    return _apLoginView;
}

//其他登录方法
- (UIView *)otherLoginView
{
    if (!_otherLoginView) {
        _otherLoginView = [[UIView alloc]initWithFrame:CGRectZero];
        _otherLoginView.backgroundColor = [UIColor clearColor];
    }
    return _otherLoginView;
}

/*
//微信登录按钮
- (UIButton *)weChatLoginBtn
{
    if (!_weChatLoginBtn) {
        _weChatLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_weChatLoginBtn setImage:[UIImage imageNamed:@"weixinLogin"] forState:UIControlStateNormal];
        [_weChatLoginBtn addTarget:self action:@selector(weChatLoginBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _weChatLoginBtn;
}

//其他方式按钮
- (UIButton *)otherLoginBtn
{
    if (!_otherLoginBtn) {
        _otherLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        LoginAccountModel *loginModel = [LoginAccountDefaults getAccountModel];
        if (loginModel) {
            if (loginModel.isPhoneLogin) {
                isEmail = NO;
            }else{
                isEmail = YES;
            }
        }else{
            if (isSimplifiedChinese) {
                isEmail = NO;
            }else{
                isEmail = YES;
            }
        }
        
        NSString *imageName = isEmail?@"phoneLogin":@"emailLogin";
        [_otherLoginBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [_otherLoginBtn addTarget:self action:@selector(otherWayLoginClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _otherLoginBtn;
}
*/
#pragma mark - 点击按钮进行旋转动画
- (void)viewRotateAnimation{
    CAAnimation *myAnimationRotate = [self animationRotate];
    CAAnimationGroup* m_pGroupAnimation;
    m_pGroupAnimation = [CAAnimationGroup animation];
    m_pGroupAnimation.delegate = self;
    m_pGroupAnimation.removedOnCompletion = NO;
    m_pGroupAnimation.duration = 1.2;
    m_pGroupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
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
