//
//  FingerPrintLoginVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/29.
//  Copyright © 2018年 张策. All rights reserved.
//
//图片尺寸
//#define LOGOWIDTH iPhoneWidth/5
#define TopSpacing iPhoneWidth/4
#define TopSpacingX iPhoneWidth/2.5
#import "FingerPrintLoginVC.h"
#import "AccountLoginNewVC.h"
#import "fingerPrintLoginManage.h"
#import "ZCTabBarController.h"
#import "WebViewController.h"
@interface FingerPrintLoginVC ()
/*logo图片*/
@property (nonatomic,strong) UIImageView *logoImg;
/*指纹按钮*/
@property (nonatomic,strong) UIButton *fingerPrintBtn;
/*指纹提示语*/
@property (nonatomic,strong) UILabel *fingertipLb;
/*账号密码登录按钮*/
@property (nonatomic,strong) UIButton *accountLoginBtn;
@property (strong, nonatomic) UIWindow *window;
@end

@implementation FingerPrintLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpUI];
    [self.navigationController setNavigationBarHidden:YES animated:YES]; //设置隐藏
    
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
        if (iPhone_X_) {
            make.top.mas_equalTo(TopSpacingX);
        }else{
            make.top.mas_equalTo(TopSpacing);
        }
        make.centerX.equalTo(self.view);
    }];
    //指纹按钮
    [self.view addSubview:self.fingerPrintBtn];
    [self.fingerPrintBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    //指纹提示语
    [self.view addSubview:self.fingertipLb];
    [self.fingertipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.fingerPrintBtn.mas_bottom).offset(10);
    }];
    //账号密码登录按钮
    [self.view addSubview:self.accountLoginBtn];
    [self.accountLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        if (iPhone_X_) {
            make.bottom.equalTo(self.view.mas_bottom).offset(-30);
        }else{
            make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        }
    }];
}
//==========================method==========================
#pragma mark - 指纹/面容ID 登录点击事件
- (void)faceIDLoginClick
{
    [fingerPrintLoginManage fingerPrintLoginResult:^(fingerLoginResult LoginResult) {
            NSLog(@"指纹结果：%lu",(unsigned long)LoginResult);
            if (LoginResult == fingerLoginResultSuccess) {//【可加动画】
                dispatch_async(dispatch_get_main_queue(),^{
                    NSLog(@"指纹登录成功");
                    ZCTabBarController *mainTabVC = [[ZCTabBarController alloc]init];
                    [mainTabVC setVideoSdk];
                    mainTabVC.tabSelectIndex = 0;
                    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                    self.window.rootViewController = mainTabVC;
                    [self.window makeKeyAndVisible];
                });
            }else if (LoginResult == fingerLoginResultErrorTouchIDLockout){
                if (iPhone_X_) {
                    [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"面容 ID 暂时不可用，您可以通过输入账号密码解锁", nil)];
                }else{
                    [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"触控 ID 暂时不可用，您可以通过输入账号密码解锁", nil)];
                }
            }else{
//                NSLog(@"指纹登录失败");
            }
       
    }];
}

#pragma mark - 指纹/面容ID 主动调用回调结果
- (void)faceIDLoginResult:(ReturnLoginResultBlock)result
{
    //[XHToast showCenterWithText:@"面容ID登录"];
    [fingerPrintLoginManage fingerPrintLoginResult:^(fingerLoginResult LoginResult) {
        dispatch_async(dispatch_get_main_queue(),^{
            NSLog(@"面容ID结果：%lu",(unsigned long)LoginResult);
            if (LoginResult == fingerLoginResultSuccess) {//【可加动画】
                NSLog(@"面容ID登录成功");
                result(fingerLoginResultSuccess);
            }else if (LoginResult == fingerLoginResultErrorTouchIDLockout){
                [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"面容 ID 暂时不可用，您可以通过输入账号密码解锁", nil)];
                //                [self createAlertActionWithTitle:@"温馨提示" message:@"触控 ID 不能识别，您可以通过输入账号密码解锁或再次尝试！"];
                result(fingerLoginResultErrorTouchIDLockout);
            }else{
                NSLog(@"面容ID失败");
                result(fingerLoginResultErrorTouchIDLockout);
            }
        });
    }];
}

#pragma mark - 账号密码登录点击事件
- (void)accountLoginClick
{
    AccountLoginNewVC *loginVC = [[AccountLoginNewVC alloc]init];
    [self.navigationController pushViewController:loginVC animated:YES];
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
//logo图片
-(UIImageView *)logoImg{
    if (!_logoImg) {
        _logoImg = [[UIImageView alloc]init];
        if (isSimplifiedChinese) {
            _logoImg.image = [UIImage imageNamed:@"loginLogo"];
        }else{
            _logoImg.image = [UIImage imageNamed:@"EloginLogo"];
        }
    }
    return _logoImg;
}
//指纹按钮
- (UIButton *)fingerPrintBtn
{
    if (!_fingerPrintBtn) {
        _fingerPrintBtn = [[UIButton alloc]init];
        if (iPhone_X_) {
            [_fingerPrintBtn setBackgroundImage:[UIImage imageNamed:@"faceID"] forState:UIControlStateNormal];
        }else{
            [_fingerPrintBtn setBackgroundImage:[UIImage imageNamed:@"fingerPrintLogo"] forState:UIControlStateNormal];
        }
        [_fingerPrintBtn addTarget:self action:@selector(faceIDLoginClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fingerPrintBtn;
}
//指纹提示语
- (UILabel *)fingertipLb
{
    if (!_fingertipLb) {
        _fingertipLb = [[UILabel alloc]init];
        if (iPhone_X_) {
            _fingertipLb.text = NSLocalizedString(@"点击进行面容ID登录", nil);
        }else{
            _fingertipLb.text = NSLocalizedString(@"点击进行触控ID登录", nil);
        }
        _fingertipLb.font = FONT(16);
        _fingertipLb.textColor = RGB(69, 135, 251);
        _fingertipLb.textAlignment = NSTextAlignmentCenter;
    }
    return _fingertipLb;
}
//账号登录按钮
- (UIButton *)accountLoginBtn
{
    if (!_accountLoginBtn) {
        _accountLoginBtn = [[UIButton alloc]init];
        [_accountLoginBtn setTitle:NSLocalizedString(@"账号密码登录", nil) forState:UIControlStateNormal];
        [_accountLoginBtn setTitleColor:RGB(100, 100, 100) forState:UIControlStateNormal];
            [_accountLoginBtn addTarget:self action:@selector(accountLoginClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _accountLoginBtn;
}

@end
