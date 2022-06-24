//
//  ChangePwdVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/4.
//  Copyright © 2018年 张策. All rights reserved.
//
//图片尺寸
#define LOGOWIDTH iPhoneWidth/5.5
//文本尺寸
#define ACCOUNTWIDTH 0.85*iPhoneWidth
#import "ChangePwdVC.h"
#import "ZCTabBarController.h"
//警告框类型
typedef NS_ENUM(NSInteger,AlertAction){
    AlertAction_phoneNull,//电话号码为空
    AlertAction_verifyNull,//验证码为空
    AlertAction_isPhone,//是否是正确的手机号
    AlertAction_isVerify,//是否是正确的验证码
    AlertAction_netWork,//网络是否打开
    AlertAction_netWorkInit,//服务器连接失败
    AlertAction_psdNull,//密码为空
    AlertAction_isPsd,//是否是合格的密码
    AlertAction_verifyBusy,//验证码发送频繁
    AlertAction_notChangePsd,//修改密码失败
};
@interface ChangePwdVC ()
{
    //判断密码是明文还是密文
    BOOL isOpenPsd;
}
/*手机号View*/
@property (nonatomic,strong) UIView *accountView;
/*手机号文本框*/
@property (nonatomic,strong) UITextField *account_tf;
/*验证码View*/
@property (nonatomic,strong) UIView *verifyView;
/*验证码文本框*/
@property (nonatomic,strong) UITextField *verify_tf;
/*获取验证码的按钮*/
@property (nonatomic,strong) UIButton *verifyBtn;
/*新密码View*/
@property (nonatomic,strong) UIView *resetPsdView;
/*新密码文本框*/
@property (nonatomic,strong) UITextField *resetPsd_tf;
/*查看密码的按钮*/
@property (nonatomic,strong) UIButton *showPasBtn;
/*重置按钮*/
@property (nonatomic,strong) UIButton *resetBtn;
@end

@implementation ChangePwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"修改密码";
    self.view.backgroundColor = BG_COLOR;
    [self cteateNavBtn];
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
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
}



//==========================init==========================
#pragma mark ----- 初始化布局
- (void)setUpUI{
    
    //手机号View
    [self.view addSubview:self.accountView];
    [self.accountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(LOGOWIDTH/1.5);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 40));
    }];
    //添加文本框
    [self.accountView addSubview:self.account_tf];
    [self.account_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.accountView.mas_centerY);
        make.left.equalTo(self.accountView.mas_left).offset(20);
        make.right.equalTo(self.accountView.mas_right);
    }];
    
    //验证码View
    [self.view addSubview:self.verifyView];
    [self.verifyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.accountView.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 40));
    }];
    
    //验证码按钮
    [self.verifyView addSubview:self.verifyBtn];
    [self.verifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.verifyView.mas_centerY);
        make.right.equalTo(self.verifyView.mas_right).offset(-10);
    }];
    //验证码文本
    [self.verifyView addSubview:self.verify_tf];
    [self.verify_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.verifyView.mas_centerY);
        make.left.equalTo(self.verifyView.mas_left).offset(20);
        make.right.equalTo(self.verifyBtn.mas_left).offset(-10);
    }];
    
    //密码View
    [self.view addSubview:self.resetPsdView];
    [self.resetPsdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.verifyView.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 40));
    }];
    //显示密码的按钮
    [self.resetPsdView addSubview:self.showPasBtn];
    [self.showPasBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.resetPsdView.mas_centerY);
        make.right.equalTo(self.resetPsdView.mas_right).offset(0);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    //添加文本框
    [self.resetPsdView addSubview:self.resetPsd_tf];
    [self.resetPsd_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.resetPsdView.mas_centerY);
        make.left.equalTo(self.resetPsdView.mas_left).offset(15);
        make.right.equalTo(self.showPasBtn.mas_left).offset(-5);
    }];
    
    
    //完成按钮
    [self.view addSubview:self.resetBtn];
    [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.resetPsdView.mas_bottom).offset(40);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 45));
    }];
}



//==========================method==========================
#pragma mark -----判断密文还是明文
-(void)isOpenPsdClick{
    //现在是睁眼状态
    if (isOpenPsd) {
        [self.showPasBtn setImage:[UIImage imageNamed:@"closePsdeye"] forState:UIControlStateNormal];
        // 按下去了就是密文
        NSString *tempPwdStr = self.resetPsd_tf.text;
        self.resetPsd_tf.text = @"";
        self.resetPsd_tf.secureTextEntry = YES;
        self.resetPsd_tf.text = tempPwdStr;
        isOpenPsd=NO;
    }else{//现在是闭眼状态
        [self.showPasBtn setImage:[UIImage imageNamed:@"showPsdeye"] forState:UIControlStateNormal];
        // 明文
        NSString *tempPwdStr = self.resetPsd_tf.text;
        self.resetPsd_tf.text = @""; // 可以防止切换的时候光标偏移
        self.resetPsd_tf.secureTextEntry = NO;
        self.resetPsd_tf.text = tempPwdStr;
        isOpenPsd=YES;
    }
}


#pragma mark ----- 获取验证码点击事件
-(void)verifyClick{
    //在点击时,取消键盘
    [self.verify_tf resignFirstResponder];
    [self.resetPsd_tf resignFirstResponder];
    NSString * uuid = [unitl getKeyChain];
    NSDictionary *postDic = @{@"mobile":self.account_tf.text,@"term_id":uuid};
    NSLog(@"postDic:%@",postDic);
    /**
     *  description:
     *   请求(成功:赋值；失败:弹框警告错误原因)
     */
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/user/verify" parameters:postDic success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            [self codeBtnTimeBegin];
            [XHToast showCenterWithText:@"验证码已发送"];
        }else if (ret == 1100){
            [self LoginAlertAction:AlertAction_verifyBusy];//验证码发送频繁
        }
        else{
            [self LoginAlertAction:AlertAction_netWorkInit];
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
                [self.verifyBtn setTitle:@"重新发送" forState:UIControlStateNormal];
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


#pragma mark - 修改密码点击事件
-(void)resetPsdClick{
    [self.verify_tf resignFirstResponder];
    [self.resetPsd_tf resignFirstResponder];
    
    if ([NSString isNull:self.verify_tf.text]){
        [self LoginAlertAction:AlertAction_verifyNull];
        return;
    }
    if (self.verify_tf.text.length != 4){
        [self LoginAlertAction:AlertAction_isVerify];
        return;
    }
    
    if ([NSString isNull:self.resetPsd_tf.text]) {
        [self LoginAlertAction:AlertAction_psdNull];
        return;
    }
    if (self.resetPsd_tf.text.length<6) {//[NSString checkPassWord:self.resetPsd_tf.text]
        //密码是否合格
        [self LoginAlertAction:AlertAction_isPsd];
        return;
    }
    [self changePsd];
}

//修改密码
-(void)changePsd{
    
    NSString *psdStr = @"";
    psdStr = [NSString stringWithFormat:@"%@%@",self.resetPsd_tf.text,PSDSUFFIX];
    NSString * psdStr_MD5 = [NSString md5:psdStr];
    NSString *resultPsd = [psdStr_MD5 uppercaseString];
    NSLog(@"%@",resultPsd);
    
    //term_id
    NSString * uuid = [unitl getKeyChain];
    
    NSDictionary *postDic = @{@"mobile":self.account_tf.text,@"ver_code":self.verify_tf.text,@"term_id":uuid,@"app_type":@"200",@"passwd":resultPsd};//200表示iOS
    [[HDNetworking sharedHDNetworking] POST:@"v1/user/setpasswd" parameters:postDic success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            NSLog(@"response:%@",responseObject);

            //注册
            [XHToast showCenterWithText:@"修改密码成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }else if(ret == 1007){
            [self LoginAlertAction:AlertAction_isVerify];
        }else{
            [self LoginAlertAction:AlertAction_notChangePsd];
        }
        
        
    }failure:^(NSError * _Nonnull error) {
        [self LoginAlertAction:AlertAction_netWork];
    }];
}





//警告框提醒
- (void)LoginAlertAction:(AlertAction)action
{
    switch (action) {
            //电话号码为空
        case AlertAction_phoneNull:
        {
            [self createAlertActionWithTitle:@"温馨提示" message:@"手机号不得为空哦~"];
        }
            break;
            //验证码为空
        case AlertAction_verifyNull:
        {
            [self createAlertActionWithTitle:@"温馨提示" message:@"验证码不得为空哦~"];
        }
            break;
            //是否是正确的手机号
        case AlertAction_isPhone:
        {
            [self createAlertActionWithTitle:@"温馨提示" message:@"请输入正确的手机号"];
        }
            break;
            //是否是正确的验证码
        case AlertAction_isVerify:
        {
            [self createAlertActionWithTitle:@"温馨提示" message:@"请输入正确的验证码"];
        }
            break;
            //网络是否打开
        case AlertAction_netWork:
        {
            [self createAlertActionWithTitle:@"温馨提示" message:@"当前网络不可用，请检查您的网络"];
        }
            break;
            //服务器连接失败
        case AlertAction_netWorkInit:
        {
            [self createAlertActionWithTitle:@"温馨提示" message:@"发送验证码失败，请稍后尝试~"];
        }
            break;
            //密码为空
        case AlertAction_psdNull:
        {
            [self createAlertActionWithTitle:@"温馨提示" message:@"密码不得为空哦~"];
        }
            break;
            //是否是合格的密码
        case AlertAction_isPsd:
        {
            [self createAlertActionWithTitle:@"温馨提示" message:@"请输入6位或以上的密码"];
        }
            break;
            //验证码发送频繁
        case AlertAction_verifyBusy:
        {
            [self createAlertActionWithTitle:@"温馨提示" message:@"验证码发送过于频繁,请稍后再试~"];
        }
            break;
        case AlertAction_notChangePsd:
        {
            [self createAlertActionWithTitle:@"温馨提示" message:@"修改密码失败~"];
        }
            break;
            
        default:
            break;
    }
}

- (void)createAlertActionWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertCtrl addAction:btnAction];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}



#pragma mark - getter&&setter
//手机号View
-(UIView *)accountView{
    if (!_accountView) {
        _accountView = [[UIView alloc]init];
        _accountView.backgroundColor = [UIColor whiteColor];
        _accountView.layer.cornerRadius = 5.0f;
        _accountView.layer.borderWidth = 1.0f;
        _accountView.layer.borderColor = RGB(215, 215, 215).CGColor;
    }
    return _accountView;
}
//验证码View
-(UIView *)verifyView{
    if (!_verifyView) {
        _verifyView = [[UIView alloc]init];
        _verifyView.backgroundColor = [UIColor whiteColor];
        _verifyView.layer.cornerRadius = 5.0f;
        _verifyView.layer.borderWidth = 1.0f;
        _verifyView.layer.borderColor = RGB(215, 215, 215).CGColor;
    }
    return _verifyView;
}
//账号文本框
-(UITextField *)account_tf{
    if (!_account_tf) {
        _account_tf = [[UITextField alloc]init];
        _account_tf.font = FONT(17);
        _account_tf.text = self.phoneNumStr;
        _account_tf.enabled = NO;
    }
    return _account_tf;
}
//验证码文本框
-(UITextField *)verify_tf{
    if (!_verify_tf) {
        _verify_tf = [[UITextField alloc]init];
        _verify_tf.font =FONT(17);
        _verify_tf.keyboardType = UIKeyboardTypeNumberPad;
        _verify_tf.placeholder = @"验证码";
    }
    return _verify_tf;
}
//发送验证码按钮
-(UIButton *)verifyBtn{
    if (!_verifyBtn) {
        _verifyBtn = [[UIButton alloc]init];
        _verifyBtn.titleLabel.font = FONT(17);
        [_verifyBtn setTitleColor:RGB(70, 70, 70) forState:UIControlStateNormal];
        [_verifyBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_verifyBtn addTarget:self action:@selector(verifyClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _verifyBtn;
}

//新密码View
-(UIView *)resetPsdView{
    if (!_resetPsdView) {
        _resetPsdView = [[UIView alloc]init];
        _resetPsdView.backgroundColor = [UIColor whiteColor];
        _resetPsdView.layer.cornerRadius = 5.0f;
        _resetPsdView.layer.borderWidth = 1.0f;
        _resetPsdView.layer.borderColor = RGB(215, 215, 215).CGColor;
    }
    return _resetPsdView;
}
//新密码文本框
-(UITextField *)resetPsd_tf{
    if (!_resetPsd_tf) {
        _resetPsd_tf = [[UITextField alloc]init];
        _resetPsd_tf.font =FONT(17);
        _resetPsd_tf.placeholder = @"输入6位及以上密码";
        _resetPsd_tf.secureTextEntry = YES;
        _resetPsd_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _resetPsd_tf;
}
//显示密码按钮
-(UIButton *)showPasBtn{
    if (!_showPasBtn) {
        _showPasBtn = [[UIButton alloc]init];
        [_showPasBtn setImage:[UIImage imageNamed:@"closePsdeye"] forState:UIControlStateNormal];
        [_showPasBtn addTarget:self action:@selector(isOpenPsdClick) forControlEvents:UIControlEventTouchUpInside];
        //默认显示闭眼
        isOpenPsd = NO;
    }
    return _showPasBtn;
}


//重置密码按钮
-(UIButton *)resetBtn{
    if (!_resetBtn) {
        _resetBtn = [[UIButton alloc]initWithFrame:CGRectMake(0.15*iPhoneWidth/2, 0, ACCOUNTWIDTH, 45)];
        _resetBtn.backgroundColor = MAIN_COLOR;
        _resetBtn.layer.cornerRadius = 7.0f;
        [_resetBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_resetBtn addTarget:self action:@selector(resetPsdClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetBtn;
}

@end
