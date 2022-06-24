//
//  SmsVerityVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/29.
//  Copyright © 2018年 张策. All rights reserved.
//
//图片尺寸
#define LeftSpacing 0.075*iPhoneWidth
#define TopSpacing iPhoneWidth/4
#define TopSpacingX iPhoneWidth/4.5
//文本尺寸
#define ACCOUNTWIDTH 0.85*iPhoneWidth
#import "SmsVerifyVC.h"
#import "VerifyCodeInputView.h"
#import "ResetPwdVC.h"//2.重置密码

//其他
#import "ZCTabBarController.h"
#import "UserModel.h"
#import "JWOpenSdk.h"
//警告框类型
typedef NS_ENUM(NSInteger,AlertAction){
    AlertAction_verifyBusy,//验证码发送频繁
    AlertAction_netWork,//网络是否打开
    AlertAction_failVerify,//验证码发送失败
    AlertAction_userExist,//用户已经注册过了
    AlertAction_notRegister,//注册失败
    AlertAction_errorVerifyCode,//是否是正确的验证码
    AlertAction_notLogin,//登录失败
};
@interface SmsVerifyVC ()
<
    getTextFieldContentDelegate
>

@property (nonatomic,strong) UIButton *backBtn;//返回按钮
@property (nonatomic,strong) UILabel *smsTipLb;//验证码提示语
@property (nonatomic,strong) UILabel *phoneNumLb;//电话号码
@property (nonatomic,strong) VerifyCodeInputView *verifyCodeInputView;//输入框
@property (nonatomic,strong) UIButton *verifyBtn;//获取验证码按钮
@end

@implementation SmsVerifyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpUI];
    if (self.isEmail) {
        [self sendEmailCode];
    }else{
        [self codeBtnTimeBegin];
    }
    
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
    //验证码提示语
    [self.view addSubview:self.smsTipLb];
    [self.smsTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(LeftSpacing);
        if (iPhone_X_) {
            make.top.equalTo(self.backBtn.mas_bottom).offset(TopSpacingX);
        }else{
            make.top.equalTo(self.backBtn.mas_bottom).offset(TopSpacing);
        }
    }];
    //短信号码
    [self.view addSubview:self.phoneNumLb];
    [self.phoneNumLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(LeftSpacing);
        make.right.equalTo(self.view.mas_right).offset(-LeftSpacing);
        make.top.equalTo(self.smsTipLb.mas_bottom).offset(10);
    }];
    [self.view addSubview:self.verifyCodeInputView];
    [self.verifyCodeInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(LeftSpacing);
        make.top.equalTo(self.smsTipLb.mas_bottom).offset(TopSpacing);
        make.size.mas_equalTo(CGSizeMake(250, 45));
    }];
    [self.view addSubview:self.verifyBtn];
    [self.verifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(LeftSpacing);
        make.top.equalTo(self.verifyCodeInputView.mas_bottom).offset(15);
    }];
}

//==========================method==========================
#pragma mark - 返回方法
- (void)returnBack
{
    [self createAlert];
}
#pragma mark ----- 获取验证码点击事件
-(void)verifyClick
{
    //发送手机验证码
    NSString * uuid = [unitl getKeyChain];
    NSDictionary *postDic = @{@"mobile":self.phoneStr,@"term_id":uuid};
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/user/verify" parameters:postDic success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            [XHToast showCenterWithText:NSLocalizedString(@"验证码已发送", nil)];
            [self codeBtnTimeBegin];
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

#pragma mark - 验证码倒计时
- (void)codeBtnTimeBegin
{
    __block NSInteger time = 59; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(time <= 0){ //倒计时结束，关闭
            
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置按钮的样式
                [self.verifyBtn setTitle:NSLocalizedString(@"重新发送", nil) forState:UIControlStateNormal];
                [self.verifyBtn setTitleColor:RGB(69, 135, 251) forState:UIControlStateNormal];
                self.verifyBtn.userInteractionEnabled = YES;
            });
            
        }else{
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置按钮显示读秒效果
                if (isSimplifiedChinese) {
                    [self.verifyBtn setTitle:[NSString stringWithFormat:@"%dS%@", seconds,NSLocalizedString(@"后重新发送", nil)] forState:UIControlStateNormal];
                }else{
                    [self.verifyBtn setTitle:[NSString stringWithFormat:@"%@ %dS",NSLocalizedString(@"后重新发送", nil),seconds] forState:UIControlStateNormal];
                }
                [self.verifyBtn setTitleColor:RGB(160, 160, 160) forState:UIControlStateNormal];
                self.verifyBtn.userInteractionEnabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}

#pragma mark - 发送邮件验证码
- (void)sendEmailCode
{
    //发送邮件验证码
    NSDictionary *postDic = @{@"mail":self.phoneStr};
    [[HDNetworking sharedHDNetworking]POST:@"v1/user/verifyMail" parameters:postDic success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            self.phoneNumLb.text = [NSString stringWithFormat:@"%@ %@%@",NSLocalizedString(@"验证码邮件已发送至", nil),self.phoneStr,NSLocalizedString(@"请在10分钟内完成验证", nil)];
            self.phoneNumLb.textColor = RGB(160, 160, 160);
        }else if (ret == 1100){
            self.phoneNumLb.text = NSLocalizedString(@"您已发送过验证码，且验证码未失效，请及时到邮箱查收", nil);
            self.phoneNumLb.textColor = [UIColor redColor];
        }else{
            self.phoneNumLb.text = NSLocalizedString(@"该邮箱还未被注册", nil);
            self.phoneNumLb.textColor = [UIColor redColor];
        }
    } failure:^(NSError * _Nonnull error) {
        //判断网络连接
        [self LoginAlertAction:AlertAction_netWork];
    }];
}


//警告框提醒
- (void)LoginAlertAction:(AlertAction)action
{
    switch (action) {
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
        //用户已经注册过
        case AlertAction_userExist:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"该手机号已被注册", nil)];
        }
            break;
        //注册失败
        case AlertAction_notRegister:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"注册失败，请重新注册", nil)];
        }
            break;
        //是否是正确的验证码
        case AlertAction_errorVerifyCode:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"请输入正确的验证码", nil)];
        }
            break;
        //登录失败
        case AlertAction_notLogin:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"登录失败，请稍候再试", nil)];
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


//提醒框
- (void)createAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"该操作可能会造成您的验证码失效，您确定退出吗？", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

//==========================delegate==========================
#pragma mark - 获取验证码
-(void)returnTextFieldContent:(NSString *)content{
    NSLog(@"%@================验证码",content);
    [self.verifyCodeInputView resignFirstResponder];
    
    if (self.verifyCodeStatus == 1) {//1:注册方式进入
        [self gotoRegisterFunc:content];
    }else if (self.verifyCodeStatus == 2){//2:忘记密码进入
        [self gotoResetPwdFunc:content];
    }else{//3:二次验证进入
        [self gotoSecondVerifyFunc:content];
    }
}


#pragma mark - 注册
- (void)gotoRegisterFunc:(NSString *)code
{
    [Toast showLoading:self.view Tips:NSLocalizedString(@"正在注册中，请稍候...", nil)];
    
    NSString *psdStr = @"";
    psdStr = [NSString stringWithFormat:@"%@%@",self.pwdStr,PSDSUFFIX];
    
    NSString * psdStr_MD5 = [NSString md5:psdStr];
    NSString *resultPsd = [psdStr_MD5 uppercaseString];
    
    //term_id
    NSString * uuid = [unitl getKeyChain];
    
    NSDictionary *postDic = @{@"mobile":self.phoneStr,@"ver_code":code,@"term_id":uuid,@"app_type":app_type,@"passwd":resultPsd};
    
    [[HDNetworking sharedHDNetworking] POST:@"v1/user/register" parameters:postDic success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            
            //用户手机号/邮箱保存本地=====================
            LoginAccountModel *loginModel = [LoginAccountDefaults getAccountModel];
            if (loginModel) {
                if (self.isEmail) {
                    loginModel.mailStr = self.phoneStr;
                    loginModel.isPhoneLogin = NO;
                }else{
                    loginModel.phoneStr = self.phoneStr;
                    loginModel.isPhoneLogin = YES;
                }
            }
            [LoginAccountDefaults setAccountModel:loginModel];
            //用户手机号/邮箱保存本地=====================
            
            //注册
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [Toast dissmiss];
                [XHToast showCenterWithText:NSLocalizedString(@"注册成功", nil)];
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
            
        }else if (ret == 1005){
            [Toast dissmiss];
            [self LoginAlertAction:AlertAction_userExist];
        }else if (ret == 1007){
            [Toast dissmiss];
            //错误的验证码
            [self LoginAlertAction:AlertAction_errorVerifyCode];
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

#pragma mark - 重置密码
//在跳转到重置密码之前，先校验验证码是否正确，正确则跳到重置密码界面；否则提示请输入正确的验证码
- (void)gotoResetPwdFunc:(NSString *)code
{
    if (self.isEmail) {
        NSDictionary *postDic = @{@"mail":self.phoneStr,@"verify_code":code};
        [[HDNetworking sharedHDNetworking] POST:@"v1/user/verifyCodeByMail" parameters:postDic success:^(id  _Nonnull responseObject) {
            NSLog(@"responseObject:%@",responseObject);
            int ret = [responseObject[@"ret"] intValue];
            if (ret == 0) {
                ResetPwdVC *resetPwdVC = [[ResetPwdVC alloc]init];
                resetPwdVC.verifyCode = code;
                resetPwdVC.phoneStr = self.phoneStr;
                resetPwdVC.isEmail = self.isEmail;
                [self.navigationController pushViewController:resetPwdVC animated:YES];
            }else{
                //错误的验证码
                [self LoginAlertAction:AlertAction_errorVerifyCode];
            }
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"失败了！！！");
            //错误的验证码
            [self LoginAlertAction:AlertAction_errorVerifyCode];
        }];
    }else{
        NSDictionary *postDic = @{@"mobile":self.phoneStr,@"verify_code":code};
        [[HDNetworking sharedHDNetworking] POST:@"v1/user/verifymobile" parameters:postDic success:^(id  _Nonnull responseObject) {
            NSLog(@"responseObject:%@",responseObject);
            int ret = [responseObject[@"ret"] intValue];
            if (ret == 0) {
                ResetPwdVC *resetPwdVC = [[ResetPwdVC alloc]init];
                resetPwdVC.verifyCode = code;
                resetPwdVC.phoneStr = self.phoneStr;
                resetPwdVC.isEmail = self.isEmail;
                [self.navigationController pushViewController:resetPwdVC animated:YES];
            }else{
                //错误的验证码
                [self LoginAlertAction:AlertAction_errorVerifyCode];
            }
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"失败了！！！");
            //错误的验证码
            [self LoginAlertAction:AlertAction_errorVerifyCode];
        }];
    }
    
}

#pragma mark - 二次验证
- (void)gotoSecondVerifyFunc:(NSString *)code
{
//    [XHToast showCenterWithText:@"二次验证"];
    [Toast showLoading:self.view Tips:NSLocalizedString(@"登录中，请稍候...", nil)];
    [self beginLogin:code];
}
#pragma mark - 开始登录
- (void)beginLogin:(NSString *)code
{
    NSString * uuid = [unitl getKeyChain];
    
    NSDictionary *postDic = @{@"mobile":self.phoneStr,@"ver_code":code,@"term_id":uuid,@"app_type":app_type};
    
    [[HDNetworking sharedHDNetworking] POST:@"v1/user/login" parameters:postDic success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
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
                if (self.isEmail) {
                    loginModel.mailStr = self.phoneStr;
                    loginModel.isPhoneLogin = NO;
                }else{
                    loginModel.phoneStr = self.phoneStr;
                    loginModel.isPhoneLogin = YES;
                }
            }
            [LoginAccountDefaults setAccountModel:loginModel];
            //用户手机号/邮箱保存本地=====================
            
            //登录中
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [Toast dissmiss];
                //登录
                [self runMainViewController];
            });
            
        }else if (ret == 1007){
            [Toast dissmiss];
            //错误的验证码
            [self LoginAlertAction:AlertAction_errorVerifyCode];
        }else{
            [Toast dissmiss];
            [self LoginAlertAction:AlertAction_notLogin];
        }

        
    } failure:^(NSError * _Nonnull error) {
        [Toast dissmiss];
        [self LoginAlertAction:AlertAction_netWork];
    }];
}

- (void)runMainViewController
{
    ZCTabBarController *mainTabVC = [[ZCTabBarController alloc]init];
    mainTabVC.tabSelectIndex = 0;
    self.definesPresentationContext = YES;
    [mainTabVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:mainTabVC animated:YES completion:^{
        BOOL isLogin = YES;
        NSNumber *loginNum = [NSNumber numberWithBool:isLogin];
        [[NSUserDefaults standardUserDefaults]setObject:loginNum forKey:ISLOGIN];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
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

//验证码提示语
- (UILabel *)smsTipLb
{
    if (!_smsTipLb) {
        _smsTipLb = [[UILabel alloc]init];
        if (self.verifyCodeStatus == 3) {//二次验证的提示语不一样
            _smsTipLb.text = NSLocalizedString(@"第一次登录需短信验证", nil);
            _smsTipLb.font = FONTB(25);
        }else{
            if (self.isEmail) {
                _smsTipLb.text = NSLocalizedString(@"输入邮箱验证码", nil);
                _smsTipLb.font = FONTB(28);
            }else{
                _smsTipLb.text = NSLocalizedString(@"输入短信验证码", nil);
                _smsTipLb.font = FONTB(28);
            }
        }
        
        _smsTipLb.textAlignment = NSTextAlignmentLeft;
    }
    return _smsTipLb;
}
//电话号码/邮箱
- (UILabel *)phoneNumLb
{
    if (!_phoneNumLb) {
        _phoneNumLb = [[UILabel alloc]init];
        _phoneNumLb.font = FONT(15);
        _phoneNumLb.textColor = RGB(160, 160, 160);
        _phoneNumLb.numberOfLines = 0;
        _phoneNumLb.lineBreakMode = NSLineBreakByCharWrapping;
        if ([NSString validateMobile:self.phoneStr]) {
            NSString *numberString = [self.phoneStr stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
            NSMutableString* tempStr=[[NSMutableString alloc]initWithString:numberString];//存在堆区，可变字符串
            [tempStr insertString:@" "atIndex:3];//把一个字符串插入另一个字符串中的某一个位置
            [tempStr insertString:@" "atIndex:8];//把一个字符串插入另一个字符串中的某一个位置
            _phoneNumLb.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"短信验证码发送至", nil),tempStr];//@"短信验证码发送至178 2680 5984";
        }
    }
    return _phoneNumLb;
}

- (VerifyCodeInputView *)verifyCodeInputView
{
    if (!_verifyCodeInputView) {
        _verifyCodeInputView = [[VerifyCodeInputView alloc]initWithFrame:CGRectMake(0,0,250,45)];
        _verifyCodeInputView.delegate = self;
        /****** 设置验证码/密码的位数默认为四位 ******/
        _verifyCodeInputView.numberOfVerifyCode = 4;
        /*********验证码（显示数字）YES,隐藏形势 NO，数字形式**********/
        _verifyCodeInputView.secureTextEntry = NO;
        [_verifyCodeInputView becomeFirstResponder];
    }
    return _verifyCodeInputView;
}
//验证码按钮
- (UIButton *)verifyBtn
{
    if (!_verifyBtn) {
        _verifyBtn = [[UIButton alloc]init];
        _verifyBtn.titleLabel.font = FONT(16);
        [_verifyBtn setTitleColor:RGB(69, 135, 251) forState:UIControlStateNormal];
        [_verifyBtn addTarget:self action:@selector(verifyClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _verifyBtn;
}

@end
