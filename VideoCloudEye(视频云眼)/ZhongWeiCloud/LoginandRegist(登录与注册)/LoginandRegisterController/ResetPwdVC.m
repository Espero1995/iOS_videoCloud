//
//  ResetPwdVC.m
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
#import "ResetPwdVC.h"
//警告框类型
typedef NS_ENUM(NSInteger,AlertAction){
    AlertAction_netWork,//网络是否打开
    AlertAction_isPwd,//是否是合格的密码
    AlertAction_isSamePwd,//是否是一致的密码
    AlertAction_notChangePwd,//修改密码失败
    AlertAction_errorVerifyCode,//错误的验证码
};
@interface ResetPwdVC ()
{
    //判断密码展示还是隐藏
    BOOL isOpenPwd;
    BOOL isOpenConfirmPwd;
}
@property (nonatomic,strong) UIButton *backBtn;//返回按钮
@property (nonatomic,strong) UILabel *resetPwdTipLb;//重置密码提示语
@property (nonatomic,strong) UIView *pwdView;//密码提示View
@property (nonatomic,strong) UITextField *pwd_tf;//密码文本框
@property (nonatomic,strong) UIView *confirmPwdView;//确认密码View
@property (nonatomic,strong) UITextField *confirmPwd_tf;//确认密码文本框
@property (nonatomic,strong) UIButton *showPwdBtn;//查看密码的按钮
@property (nonatomic,strong) UIButton *showConfirmPwdBtn;//确认密码的查看密码的按钮
@property (nonatomic,strong) UIButton *submitBtn;//完成按钮
@end

@implementation ResetPwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpUI];
    NSLog(@"获取到的验证码是：%@,电话号码：%@",self.verifyCode,self.phoneStr);
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
    //重置密码提示语
    [self.view addSubview:self.resetPwdTipLb];
    [self.resetPwdTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(LeftSpacing);
        if (iPhone_X_) {
            make.top.equalTo(self.backBtn.mas_bottom).offset(TopSpacingX);
        }else{
            make.top.equalTo(self.backBtn.mas_bottom).offset(TopSpacing);
        }
    }];
    //密码View初始化
    [self.view addSubview:self.pwdView];
    [self.pwdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.resetPwdTipLb.mas_bottom).offset(TopSpacing);
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
        make.left.equalTo(self.confirmPwdView.mas_left).offset(0);
        make.right.equalTo(self.showConfirmPwdBtn.mas_left).offset(-5);
    }];
    //完成按钮
    [self.view addSubview:self.submitBtn];
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.confirmPwdView.mas_bottom).offset(TopSpacing);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 45));
    }];
    
    
}

//==========================method==========================
#pragma mark - 返回方法
- (void)returnBack
{
   [self.navigationController popViewControllerAnimated:YES];
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
        isOpenPwd=NO;
    }else{//现在是闭眼状态
        [self.showPwdBtn setImage:[UIImage imageNamed:@"showPwdeye"] forState:UIControlStateNormal];
        // 明文
        NSString *tempPwdStr = self.pwd_tf.text;
        self.pwd_tf.text = @""; // 可以防止切换的时候光标偏移
        self.pwd_tf.secureTextEntry = NO;
        self.pwd_tf.text = tempPwdStr;
        isOpenPwd=YES;
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
        isOpenConfirmPwd=NO;
    }else{//现在是闭眼状态
        [self.showConfirmPwdBtn setImage:[UIImage imageNamed:@"showPwdeye"] forState:UIControlStateNormal];
        // 明文
        NSString *tempPwdStr = self.confirmPwd_tf.text;
        self.confirmPwd_tf.text = @""; // 可以防止切换的时候光标偏移
        self.confirmPwd_tf.secureTextEntry = NO;
        self.confirmPwd_tf.text = tempPwdStr;
        isOpenConfirmPwd=YES;
    }
}

#pragma mark - 获取验证码
- (void)submitClick
{
    [self.pwd_tf resignFirstResponder];
    [self.confirmPwd_tf resignFirstResponder];
    if (self.pwd_tf.text.length < 6 || self.pwd_tf.text.length > 16) {
        //密码是否合格
        [self LoginAlertAction:AlertAction_isPwd];
        return;
    }
    if (self.confirmPwd_tf.text.length<6) {
        //密码是否合格
        [self LoginAlertAction:AlertAction_isPwd];
        return;
    }
    if (![self.pwd_tf.text isEqualToString:self.confirmPwd_tf.text]) {
        [self LoginAlertAction:AlertAction_isSamePwd];
        return;
    }
    [Toast showLoading:self.view Tips:NSLocalizedString(@"重置密码中，请稍候...", nil)];
    [self changePwd];
}

#pragma mark - 修改密码
- (void)changePwd
{
    NSString *psdStr = @"";
    psdStr = [NSString stringWithFormat:@"%@%@",self.pwd_tf.text,PSDSUFFIX];
    NSString * psdStr_MD5 = [NSString md5:psdStr];
    NSString *resultPsd = [psdStr_MD5 uppercaseString];
    NSLog(@"%@",resultPsd);
    
    //term_id
//    NSString * uuid = [unitl getKeyChain];
    
    //修改密码的相关类型
    NSNumber *accountType;
    NSString *mobileorEmailKey;
    if (self.isEmail) {
        accountType = [NSNumber numberWithInt:2];
        mobileorEmailKey = @"mail";
    }else{
        accountType = [NSNumber numberWithInt:1];
        mobileorEmailKey = @"mobile";
    }
    //,@"app_type":@"200"
    NSDictionary *postDic = @{mobileorEmailKey:self.phoneStr,@"verfiyCode":self.verifyCode,@"passwd":resultPsd,@"accountType":accountType};//200表示iOS
    NSLog(@"postDic:%@",postDic);
    [[HDNetworking sharedHDNetworking] POST:@"v1/user/setpasswdNew" parameters:postDic success:^(id  _Nonnull responseObject) {

        int ret = [responseObject[@"ret"] intValue];
        NSLog(@"response:%@",responseObject);
        if (ret == 0) {
            //用户手机号/邮箱保存本地=====================
            LoginAccountModel *loginModel = [LoginAccountDefaults getAccountModel];
            if (loginModel) {
                if (self.isEmail) {
                    loginModel.mailStr = self.phoneStr;
                }else{
                    loginModel.phoneStr = self.phoneStr;
                }
            }
            [LoginAccountDefaults setAccountModel:loginModel];
            //用户手机号/邮箱保存本地=====================
            //修改密码
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [Toast dissmiss];
                [XHToast showCenterWithText:NSLocalizedString(@"修改密码成功", nil)];
                [self.navigationController popToRootViewControllerAnimated:YES];
            });
            
        }else if (ret == 1007){
            [Toast dissmiss];
            //错误的验证码
            [self LoginAlertAction:AlertAction_errorVerifyCode];
        }else{
            [Toast dissmiss];
            //修改密码失败
            [self LoginAlertAction:AlertAction_notChangePwd];
        }
    }failure:^(NSError * _Nonnull error) {
        [Toast dissmiss];
        //判断网络连接
        [self LoginAlertAction:AlertAction_netWork];
    }];
}



//警告框提醒
- (void)LoginAlertAction:(AlertAction)action
{
    switch (action) {
        //网络是否打开
        case AlertAction_netWork:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"当前网络不可用，请检查您的网络", nil)];
        }
            break;
        //是否是一致的密码
        case AlertAction_isSamePwd:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"两次输入的密码不一致", nil)];
        }
            break;
        //是否是合格的密码
        case AlertAction_isPwd:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"密码必须在6-20位之间", nil)];
        }
            break;
        //修改密码失败
        case AlertAction_notChangePwd:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"修改密码失败，请稍候再试", nil)];
        }
            break;
        //错误的验证码
        case AlertAction_errorVerifyCode:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"请输入正确的验证码", nil)];
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
    if (self.pwd_tf.text.length != 0 && self.confirmPwd_tf.text.length != 0) {
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
- (UILabel *)resetPwdTipLb
{
    if (!_resetPwdTipLb) {
        _resetPwdTipLb = [[UILabel alloc]init];
        _resetPwdTipLb.text = NSLocalizedString(@"设置新密码", nil);
        _resetPwdTipLb.font = FONTB(28);
        _resetPwdTipLb.textAlignment = NSTextAlignmentLeft;
    }
    return _resetPwdTipLb;
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
        _pwd_tf.placeholder = NSLocalizedString(@"请输入新的密码", nil);
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
        _confirmPwd_tf.placeholder = NSLocalizedString(@"请确认新的密码", nil);
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
        [_submitBtn setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
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

@end
