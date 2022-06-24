//
//  ModifyPwdVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/23.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "ModifyPwdVC.h"
#import "ZCTabBarController.h"
//警告框类型
typedef NS_ENUM(NSInteger,AlertAction){
    AlertAction_phoneNull,//电话号码为空
    AlertAction_verifyNull,//验证码为空
    AlertAction_isPhone,//是否是正确的手机号
    AlertAction_isVerify,//是否是正确的验证码
    AlertAction_netWork,//网络是否打开
    AlertAction_netWorkInit,//服务器连接失败
    AlertAction_pwdNull,//密码为空
    AlertAction_isPwd,//是否是合格的密码
    AlertAction_verifyBusy,//验证码发送频繁
    AlertAction_notChangePwd,//修改密码失败
    AlertAction_errorOldPwd,//旧密码错误
};
@interface ModifyPwdVC ()


@property (nonatomic,strong) UIView *oldPwdView;//旧密码View
@property (nonatomic,strong) UITextField *oldPwd_tf;//旧密码文本框

@property (nonatomic,strong) UIView *resetPwdView;//新密码View
@property (nonatomic,strong) UITextField *resetPwd_tf;//新密码文本框
@property (nonatomic,strong) UILabel *tipLb;//提示语
@end

@implementation ModifyPwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"密码修改", nil);
    self.view.backgroundColor = BG_COLOR;
    [self setButtonitem];
    [self setUpUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

//==========================init==========================
#pragma mark ----- 初始化布局
- (void)setUpUI
{
    //旧密码View
    [self.view addSubview:self.oldPwdView];
    [self.oldPwdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 44));
    }];

    //旧密码添加密码输入框
    [self.oldPwdView addSubview:self.oldPwd_tf];
    [self.oldPwd_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.oldPwdView.mas_centerY);
        make.left.equalTo(self.oldPwdView.mas_left).offset(15);
        make.right.equalTo(self.oldPwdView.mas_right).offset(-5);
    }];
    
    
    //密码View
    [self.view addSubview:self.resetPwdView];
    [self.resetPwdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.oldPwdView.mas_bottom).offset(10);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 44));
    }];
    //添加密码输入框
    [self.resetPwdView addSubview:self.resetPwd_tf];
    [self.resetPwd_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.resetPwdView.mas_centerY);
        make.left.equalTo(self.resetPwdView.mas_left).offset(15);
        make.right.equalTo(self.resetPwdView.mas_right).offset(-5);
    }];
    //提示语
    [self.view addSubview:self.tipLb];
    [self.tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-5);
        make.top.equalTo(self.resetPwdView.mas_bottom).offset(10);
    }];
}

#pragma mark ------设置导航栏按钮和响应事件
- (void)setButtonitem
{
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 40, 15)];
    [backBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backBtn.highlighted = YES;
    backBtn.userInteractionEnabled = YES;
    [backBtn addTarget:self action:@selector(cancelModifyClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    UIBarButtonItem * leftSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    self.navigationItem.leftBarButtonItems = @[leftSpace,leftItem];
    UIButton *completeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [completeBtn setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateNormal];
    [completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [completeBtn addTarget:self action:@selector(completeClick) forControlEvents:UIControlEventTouchUpInside];
    completeBtn.highlighted = YES;
    completeBtn.userInteractionEnabled = YES;
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:completeBtn];
    UIBarButtonItem * rightSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    rightSpace.width = -10;
    self.navigationItem.rightBarButtonItems = @[rightItem,rightSpace];
}

//=========================method=========================
//取消返回
- (void)cancelModifyClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

//确定按钮
- (void)completeClick
{
    [self.oldPwd_tf resignFirstResponder];
    [self.resetPwd_tf resignFirstResponder];
    
    if ([NSString isNull:self.oldPwd_tf.text]) {
        [self LoginAlertAction:AlertAction_pwdNull];
        return;
    }
    
    if ([NSString isNull:self.resetPwd_tf.text]) {
        [self LoginAlertAction:AlertAction_pwdNull];
        return;
    }
    
    if (self.oldPwd_tf.text.length < 6 || self.oldPwd_tf.text.length > 16) {//[NSString checkPassWord:self.resetPsd_tf.text]
        //密码是否合格
        [self LoginAlertAction:AlertAction_isPwd];
        return;
    }
    
    if (self.resetPwd_tf.text.length < 6 || self.resetPwd_tf.text.length > 16) {//[NSString checkPassWord:self.resetPsd_tf.text]
        //密码是否合格
        [self LoginAlertAction:AlertAction_isPwd];
        return;
    }
    
    [self changePwd];
}

//修改密码
-(void)changePwd
{
    LoginAccountModel *loginModel = [LoginAccountDefaults getAccountModel];
    NSString *accountStr = loginModel.phoneStr;
    
    NSString *oldPsdStr_MD5 = [NSString md5:self.oldPwd_tf.text];
    NSString *resetPsdStr_MD5 = [NSString md5:self.resetPwd_tf.text];

    //NSDictionary *postDic = @{@"account":accountStr,@"oldPasswd":oldPsdStr_MD5,@"newPasswd":resetPsdStr_MD5};
    
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    [postDic setObject:accountStr forKey:@"account"];
    [postDic setObject:oldPsdStr_MD5 forKey:@"oldPasswd"];
    [postDic setObject:resetPsdStr_MD5 forKey:@"newPasswd"];
    
    [[HDNetworking sharedHDNetworking] POST:@"open/user/resetPasswd" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"response:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            //注册
            [XHToast showCenterWithText:NSLocalizedString(@"修改密码成功", nil)];
            [self.navigationController popViewControllerAnimated:YES];
        }else if(ret == 1007){
            [self LoginAlertAction:AlertAction_isVerify];
        }else if (ret == 1008){
            [self LoginAlertAction:AlertAction_errorOldPwd];
        }
        else{
            [self LoginAlertAction:AlertAction_notChangePwd];
        }
    } failure:^(NSError * _Nonnull error) {
        [self LoginAlertAction:AlertAction_netWork];
    }];
    
    /*
    [[HDNetworking sharedHDNetworking] POST:@"open/user/resetPasswd" parameters:postDic success:^(id  _Nonnull responseObject) {
        NSLog(@"response:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            //注册
            [XHToast showCenterWithText:NSLocalizedString(@"修改密码成功", nil)];
            [self.navigationController popViewControllerAnimated:YES];
        }else if(ret == 1007){
            [self LoginAlertAction:AlertAction_isVerify];
        }else{
            [self LoginAlertAction:AlertAction_notChangePwd];
        }
        
        
    }failure:^(NSError * _Nonnull error) {
        [self LoginAlertAction:AlertAction_netWork];
    }];
     */
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
            //验证码为空
        case AlertAction_verifyNull:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"验证码不能为空", nil)];
        }
            break;
            //是否是正确的手机号
        case AlertAction_isPhone:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"请输入正确的手机号", nil)];
        }
            break;
            //是否是正确的验证码
        case AlertAction_isVerify:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"请输入正确的验证码", nil)];
        }
            break;
            //网络是否打开
        case AlertAction_netWork:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"当前网络不可用，请检查您的网络", nil)];
        }
            break;
            //服务器连接失败
        case AlertAction_netWorkInit:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"验证码发送失败，请稍候再试", nil)];
        }
            break;
            //密码为空
        case AlertAction_pwdNull:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"密码不能为空", nil)];
        }
            break;
            //是否是合格的密码
        case AlertAction_isPwd:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"密码必须在6-20位之间", nil)];
        }
            break;
            //验证码发送频繁
        case AlertAction_verifyBusy:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"验证码发送过于频繁，请稍候再试", nil)];
        }
            break;
        case AlertAction_notChangePwd:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"修改密码失败，请稍候再试", nil)];
        }
            break;
        case AlertAction_errorOldPwd:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"旧密码错误", nil)];
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

#pragma mark - getter && setter
//新密码View
-(UIView *)oldPwdView
{
    if (!_oldPwdView) {
        _oldPwdView = [[UIView alloc]init];
        _oldPwdView.backgroundColor = [UIColor whiteColor];
        _oldPwdView.layer.borderWidth = .5f;
        _oldPwdView.layer.borderColor = RGB(240, 240, 240).CGColor;
    }
    return _oldPwdView;
}

//新密码文本框
-(UITextField *)oldPwd_tf
{
    if (!_oldPwd_tf) {
        _oldPwd_tf = [[UITextField alloc]init];
        _oldPwd_tf.font =FONT(17);
        _oldPwd_tf.placeholder = NSLocalizedString(@"设置旧密码", nil);
        _oldPwd_tf.secureTextEntry = YES;
        _oldPwd_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _oldPwd_tf;
}


//新密码View
-(UIView *)resetPwdView
{
    if (!_resetPwdView) {
        _resetPwdView = [[UIView alloc]init];
        _resetPwdView.backgroundColor = [UIColor whiteColor];
        _resetPwdView.layer.borderWidth = .5f;
        _resetPwdView.layer.borderColor = RGB(240, 240, 240).CGColor;
    }
    return _resetPwdView;
}

//新密码文本框
-(UITextField *)resetPwd_tf
{
    if (!_resetPwd_tf) {
        _resetPwd_tf = [[UITextField alloc]init];
        _resetPwd_tf.font =FONT(17);
        _resetPwd_tf.placeholder = NSLocalizedString(@"设置新密码", nil);
        _resetPwd_tf.secureTextEntry = YES;
        _resetPwd_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _resetPwd_tf;
}

//提示语
- (UILabel *)tipLb
{
    if (!_tipLb) {
        _tipLb = [[UILabel alloc]init];
        _tipLb.text = NSLocalizedString(@"密码需由6-16位数字、字母或符号组成", nil);
        _tipLb.font = FONT(12);
        _tipLb.numberOfLines = 0;
        _tipLb.lineBreakMode = NSLineBreakByCharWrapping;
        _tipLb.textColor = RGB(160, 160, 160);
    }
    return _tipLb;
}


@end
