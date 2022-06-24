//
//  BindAccountVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/29.
//  Copyright © 2018年 张策. All rights reserved.
//
//图片尺寸
#define LOGOWIDTH iPhoneWidth/5.5
//文本尺寸
#define ACCOUNTWIDTH 0.9*iPhoneWidth
#define TopSpacingX iPhoneWidth/3
#import "BindAccountVC.h"
/*忘记密码*/
#import "ForgetPwdVC.h"
/*自定义按钮*/
#import "UnderlineBtn.h"
/*登录按钮样式*/
//#import "LYButton.h"
//#import "LoginButton.h"
#import "JWOpenSdk.h"
#import "ZCTabBarController.h"
//警告框类型
typedef NS_ENUM(NSInteger,AlertAction){
    AlertAction_phoneNull,//电话号码为空
    AlertAction_psdNull,//密码为空
    AlertAction_isPhone,//是否是正确的手机号
    AlertAction_netWork,//网络是否打开
    AlertAction_notLogin,//登录失败
    AlertAction_verifyNull,//验证码为空
    AlertAction_isVerify,//是否是正确的验证码
    AlertAction_verifyBusy,//验证码发送频繁
    AlertAction_failBind,//微信绑定失败
};
@interface BindAccountVC ()

/*提示*/
@property (nonatomic,strong) UILabel *tip_lb;
/*手机号View*/
@property (nonatomic,strong) UIView *accountView;
/*手机号文本框*/
@property (nonatomic,strong) UITextField *account_tf;
/*新密码View*/
@property (nonatomic,strong) UIView *verifyView;
/*新密码文本框*/
@property (nonatomic,strong) UITextField *verify_tf;
/*获取验证码的按钮*/
@property (nonatomic,strong) UIButton *verifyBtn;
/*账号绑定按钮*/
@property (nonatomic,strong) UIButton *bindBtn;
/*忘记密码按钮*/
@property (nonatomic,strong) UnderlineBtn *forgetPwdBtn;
@property (nonatomic,strong) UIButton *backBtn;//返回按钮
@property (nonatomic,strong) UILabel *titleLb;//标题
@end

@implementation BindAccountVC
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
    
    [self.view addSubview:self.tip_lb];
    [self.tip_lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.backBtn.mas_bottom).offset(30);
        make.width.mas_equalTo(ACCOUNTWIDTH);
    }];
    [self.view addSubview:self.accountView];
    [self.accountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tip_lb.mas_bottom).offset(15);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 35));
    }];
    //添加文本框
    [self.accountView addSubview:self.account_tf];
    [self.account_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.accountView.mas_centerY);
        make.left.equalTo(self.accountView.mas_left).offset(0);
        make.right.equalTo(self.accountView.mas_right);
    }];
    //添加密码View
    [self.view addSubview:self.verifyView];
    [self.verifyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.accountView.mas_bottom).offset(15);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 35));
    }];
    //验证码按钮
    [self.verifyView addSubview:self.verifyBtn];
    [self.verifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.verifyView.mas_centerY);
        make.right.equalTo(self.verifyView.mas_right).offset(-10);
    }];
    //添加验证码文本框
    [self.verifyView addSubview:self.verify_tf];
    [self.verify_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.verifyView.mas_centerY);
        make.left.equalTo(self.verifyView.mas_left).offset(0);
        make.right.equalTo(self.verifyBtn.mas_left).offset(-10);
    }];
    //绑定账号按钮
    [self.view addSubview:self.bindBtn];
    [self.bindBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.verifyView.mas_bottom).offset(40);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 45));
    }];
    //忘记密码按钮
    [self.view addSubview:self.forgetPwdBtn];
    [self.forgetPwdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bindBtn.mas_bottom).offset(15);
        make.left.equalTo(self.bindBtn.mas_left);
    }];
   
}
//==========================method==========================
#pragma mark - 返回方法
- (void)returnBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark ----- 清除文本数据和弹回键盘
-(void)resetTextData
{
    self.account_tf.text = @"";
    [self.account_tf resignFirstResponder];
    self.verify_tf.text = @"";
    [self.verify_tf resignFirstResponder];
}

#pragma mark ----- 忘记密码点击事件
-(void)forgetClick
{
    [self resetTextData];
    ForgetPwdVC *forgetVC = [[ForgetPwdVC alloc]init];
    [self.navigationController pushViewController:forgetVC animated:YES];
}

//绑定账号
- (void)bindAccountClick
{
    [self performSelector:@selector(JudgeConditions) withObject:nil afterDelay:0.3];
}
//判断各种满足条件
-(void)JudgeConditions
{
    /**
     *  description:
     *   1.判断手机号与密码都是不是为空(空:return)
     *   2.判断手机号是不是正确(错:return)
     *   3.请求(成功:登录；失败:弹框警告错误原因)
     */
    if ([NSString isNull:self.account_tf.text]) {
            //手机号是否为空
            [self LoginAlertAction:AlertAction_phoneNull];
        return;
    }
    if (![NSString validateMobile:self.account_tf.text]){
            //是否是正确的手机号
            [self LoginAlertAction:AlertAction_isPhone];
        return;
    }
    if ([NSString isNull:self.verify_tf.text]){
            //验证码是否为空
            [self LoginAlertAction:AlertAction_verifyNull];
        return;
    }
    if (self.verify_tf.text.length != 4){
            //验证码是否符合常规
            [self LoginAlertAction:AlertAction_isVerify];
        return;
    }
    [self beginWeixinBindingAndLogin];
//    [self bindingAccount];
    
}
- (void)bindingAccount
{
    //term_id
    NSString * uuid = [unitl getKeyChain];
    NSLog(@"uuid:%@",uuid);
    
    NSLog(@"账号：%@，验证码：%@，uuID：%@",self.account_tf.text,self.verify_tf.text,uuid);
        //登录
        [self didPresentControllerButtonTouch];
}
//登录成功条跳转的方法
- (void)didPresentControllerButtonTouch {
        [self resetTextData];
        [self runMainViewController];
}

#pragma mark ------进入主界面
- (void)runMainViewController
{
    //    WeakSelf(self);
    //    ZCTabBarController *mainTabVC = [[ZCTabBarController alloc]init];
    //    mainTabVC.tabSelectIndex = 0;
    //    weakSelf.definesPresentationContext = YES;
    //    [weakSelf presentViewController:mainTabVC animated:YES completion:^{
    //        BOOL isLogin = YES;
    //        NSNumber *loginNum = [NSNumber numberWithBool:isLogin];
    //        [[NSUserDefaults standardUserDefaults]setObject:loginNum forKey:ISLOGIN];
    //        [[NSUserDefaults standardUserDefaults] synchronize];
    //    }];
    ZCTabBarController *mainTabVC = [[ZCTabBarController alloc]init];
    mainTabVC.tabSelectIndex = 0;
    self.definesPresentationContext = YES;
    [self presentViewController:mainTabVC animated:YES completion:^{
        BOOL isLogin = YES;
        NSNumber *loginNum = [NSNumber numberWithBool:isLogin];
        [[NSUserDefaults standardUserDefaults]setObject:loginNum forKey:ISLOGIN];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

- (void)beginWeixinBindingAndLogin
{
    [Toast showLoading:self.view Tips:NSLocalizedString(@"正在绑定中，请稍候...", nil)];
    NSString * uuid = [unitl getKeyChain];
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    [postDic setObject:@"" forKey:@"wechat_code"];
    [postDic setObject:self.account_tf.text forKey:@"mobile"];
    [postDic setObject:self.weixinOpenId forKey:@"wechat_id"];
    [postDic setObject:self.verify_tf.text forKey:@"ver_code"];
    [postDic setObject:app_type forKey:@"app_type"];
    [postDic setObject:uuid forKey:@"term_id"];
    NSLog(@"postDic=======:%@",postDic);
    [[HDNetworking sharedHDNetworking] GET:@"v1/user/wechatlogin" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"微信登录回调code传给后台：返回：%@",responseObject);
        if ([responseObject[@"ret"] integerValue] == 0) {
            NSString * returnWeixinID = responseObject[@"body"][@"wechatId"];
            if ([NSString isNull:returnWeixinID]) {//空的话，不用跳绑定界面
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
                
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                dispatch_after(time, dispatch_get_main_queue(), ^(void){
                    [Toast dissmiss];
                    [XHToast showCenterWithText:NSLocalizedString(@"绑定成功", nil)];
                    //登录
                    [self didPresentControllerButtonTouch];
                });
                
            }else{
                [Toast dissmiss];
                //绑定失败
                [self LoginAlertAction:AlertAction_failBind];
                NSLog(@"绑定微信和手机界面，返回body为空");
            }
        }
//            }else{
////                WeChatVerifyVC *weChatVC = [[WeChatVerifyVC alloc]init];
////
////                ZCTabBarController *rootVC = [[ZCTabBarController alloc] init];
////                self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
////                [self.window setRootViewController:rootVC];
////                [self.window addSubview:rootVC.view];
////                [self.window makeKeyAndVisible];
////
////                ZCTabBarController *baseTabBar = (ZCTabBarController *)self.window.rootViewController;
////                [baseTabBar.viewControllers[baseTabBar.selectedIndex] pushViewController:weChatVC animated:NO];
//            }
//        }
    } failure:^(NSError * _Nonnull error) {
        [Toast dissmiss];
        //判断网络连接
        [self LoginAlertAction:AlertAction_netWork];
    }];
}


#pragma mark ----- 获取验证码点击事件
-(void)verifyClick{
    //在点击时,取消键盘
    [self.account_tf resignFirstResponder];
    [self.verify_tf resignFirstResponder];
    /**
     *  description:
     *   1.判断手机号是不是为空(空:return)
     *   2.判断手机号是不是正确(错:return)
     *   3.请求(成功:赋值；失败:弹框警告错误原因)
     */
    if ([NSString isNull:self.account_tf.text]) {
        //手机号是否为空
        [self LoginAlertAction:AlertAction_phoneNull];
        return;
    }else if (![NSString validateMobile:self.account_tf.text]){
        //是否是正确的手机号
        [self LoginAlertAction:AlertAction_isPhone];
        return;
    }
    NSString * uuid = [unitl getKeyChain];
    NSDictionary *postDic = @{@"mobile":self.account_tf.text,@"term_id":uuid};
    [[HDNetworking sharedHDNetworking]POST:@"v1/user/verify" parameters:postDic success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            [self codeBtnTimeBegin];
            [XHToast showCenterWithText:NSLocalizedString(@"验证码已发送", nil)];
        }else if(ret == 1100){
                //验证码发送频繁
                [self LoginAlertAction:AlertAction_verifyBusy];
        }else{
                //登录失败
                [self LoginAlertAction:AlertAction_notLogin];
            
        }
    } failure:^(NSError * _Nonnull error) {
            //判断网络连接
            [self LoginAlertAction:AlertAction_netWork];
    }];
}

#pragma mark ------ 验证码倒计时
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
                [self.verifyBtn setTitleColor:RGB(70, 70, 70) forState:UIControlStateNormal];
                self.verifyBtn.userInteractionEnabled = YES;
            });
            
        }else{
            
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置按钮显示读秒效果
                [self.verifyBtn setTitle:[NSString stringWithFormat:@"%.2dS", seconds] forState:UIControlStateNormal];
                [self.verifyBtn setTitleColor:RGB(160, 160, 160) forState:UIControlStateNormal];
                self.verifyBtn.userInteractionEnabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}

//警告框提醒
- (void)LoginAlertAction:(AlertAction)action
{
    switch (action) {
            //电话号码为空
        case AlertAction_phoneNull:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"手机号不能为空", nil)];
        }
            break;
            //密码为空
        case AlertAction_psdNull:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"密码不能为空", nil)];
        }
            break;
            //是否是正确的手机号
        case AlertAction_isPhone:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"请输入正确的手机号", nil)];
        }
            break;
            //网络是否打开
        case AlertAction_netWork:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"当前网络不可用，请检查您的网络", nil)];
        }
            break;
            //登录失败
        case AlertAction_notLogin:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"请输入正确的手机号或验证码", nil)];
        }
            break;
            //验证码为空
        case AlertAction_verifyNull:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"验证码不能为空", nil)];
        }
            break;
            //是否是正确的验证码
        case AlertAction_isVerify:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"请输入正确的验证码", nil)];
        }
            break;
            //验证码发送频繁
        case AlertAction_verifyBusy:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"验证码发送过于频繁，请稍候再试", nil)];
        }
            break;
        //微信绑定失败
        case AlertAction_failBind:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"微信绑定账号失败，请稍候再试", nil)];
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
        _titleLb.text = NSLocalizedString(@"绑定已有账号", nil);
        _titleLb.font = FONT(18);
    }
    return _titleLb;
}
//提示
- (UILabel *)tip_lb
{
    if (!_tip_lb) {
        _tip_lb = [[UILabel alloc]init];
        _tip_lb.font = FONT(14);
        _tip_lb.textColor = [UIColor lightGrayColor];
        _tip_lb.text = NSLocalizedString(@"请输入拾视频云眼账号和密码进行绑定", nil);
    }
    return _tip_lb;
}
//手机号View
-(UIView *)accountView{
    if (!_accountView) {
        _accountView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ACCOUNTWIDTH, 35)];
        _accountView.backgroundColor = [UIColor clearColor];
        CALayer *bottomBorder = [CALayer layer];
        float lineHeight = _accountView.frame.size.height-1.0f;
        float lineWidth = _accountView.frame.size.width;
        bottomBorder.frame = CGRectMake(0.0f, lineHeight, lineWidth, 1.0f);
        bottomBorder.backgroundColor = RGB(226, 226, 226).CGColor;
        [_accountView.layer addSublayer:bottomBorder];
    }
    return _accountView;
}
//账号文本框
-(UITextField *)account_tf
{
    if (!_account_tf) {
        _account_tf = [[UITextField alloc]init];
        _account_tf.font =FONT(17);
        _account_tf.placeholder = NSLocalizedString(@"请输入手机号码", nil);
        _account_tf.keyboardType = UIKeyboardTypeNumberPad;
        _account_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _account_tf;
}
//密码View
-(UIView *)verifyView
{
    if (!_verifyView) {
        _verifyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ACCOUNTWIDTH, 35)];
        _verifyView.backgroundColor = [UIColor clearColor];
        CALayer *bottomBorder = [CALayer layer];
        float lineHeight = _verifyView.frame.size.height-1.0f;
        float lineWidth = _verifyView.frame.size.width;
        bottomBorder.frame = CGRectMake(0.0f, lineHeight, lineWidth, 1.0f);
        bottomBorder.backgroundColor = RGB(226, 226, 226).CGColor;
        [_verifyView.layer addSublayer:bottomBorder];
    }
    return _verifyView;
}
//密码文本框
-(UITextField *)verify_tf
{
    if (!_verify_tf) {
        _verify_tf = [[UITextField alloc]init];
        _verify_tf.font =FONT(17);
        _verify_tf.placeholder = NSLocalizedString(@"请输入验证码", nil);
        _verify_tf.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _verify_tf;
}
//显示密码按钮
-(UIButton *)verifyBtn
{
    if (!_verifyBtn) {
        _verifyBtn = [[UIButton alloc]init];
        _verifyBtn.titleLabel.font = FONT(17);
        [_verifyBtn setTitleColor:RGB(70, 70, 70) forState:UIControlStateNormal];
        [_verifyBtn setTitle:NSLocalizedString(@"获取验证码", nil) forState:UIControlStateNormal];
        [_verifyBtn addTarget:self action:@selector(verifyClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _verifyBtn;
}
//绑定账号按钮
- (UIButton *)bindBtn
{
    if (!_bindBtn) {
        _bindBtn = [[UIButton alloc]initWithFrame:CGRectMake(0.15*iPhoneWidth/2, 0, ACCOUNTWIDTH, 45)];
        _bindBtn.backgroundColor = MAIN_COLOR;
        _bindBtn.layer.cornerRadius = 7.0f;
        [_bindBtn setTitle:NSLocalizedString(@"绑定", nil) forState:UIControlStateNormal];
        [_bindBtn addTarget:self action:@selector(bindAccountClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bindBtn;
}
//忘记密码
-(UnderlineBtn *)forgetPwdBtn
{
    if (!_forgetPwdBtn) {
        _forgetPwdBtn = [[UnderlineBtn alloc]init];
        _forgetPwdBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _forgetPwdBtn.titleLabel.font = FONT(17);
        [_forgetPwdBtn setColor:MAIN_COLOR];
        [_forgetPwdBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        [_forgetPwdBtn setTitle:NSLocalizedString(@"忘记密码", nil) forState:UIControlStateNormal];
        [_forgetPwdBtn addTarget:self action:@selector(forgetClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _forgetPwdBtn;
}
@end
