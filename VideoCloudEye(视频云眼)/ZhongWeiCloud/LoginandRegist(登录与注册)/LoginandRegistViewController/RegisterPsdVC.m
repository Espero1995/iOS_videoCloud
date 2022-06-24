//
//  RegisterPsdVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/2/6.
//  Copyright © 2018年 张策. All rights reserved.
//
//图片尺寸
#define LOGOWIDTH iPhoneWidth/5.5
//文本尺寸
#define ACCOUNTWIDTH 0.85*iPhoneWidth
#import "RegisterPsdVC.h"

@interface RegisterPsdVC ()
{
    //判断密码是明文还是密文
    BOOL isOpenPsd;
}
/*logo图片*/
@property (nonatomic,strong) UIImageView *logoImg;
/*logo下方的提示*/
@property (nonatomic,strong) UILabel *logotip_lb;
/*验证码View*/
@property (nonatomic,strong) UIView *verifyView;
/*验证码文本框*/
@property (nonatomic,strong) UITextField *verify_tf;
/*新密码View*/
@property (nonatomic,strong) UIView *registerPsdView;
/*新密码文本框*/
@property (nonatomic,strong) UITextField *registerPsd_tf;
/*获取验证码的按钮*/
@property (nonatomic,strong) UIButton *verifyBtn;
/*查看密码的按钮*/
@property (nonatomic,strong) UIButton *showPasBtn;
/*完成按钮*/
@property (nonatomic,strong) UIButton *completeBtn;
@end

@implementation RegisterPsdVC
//==========================system==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"注册";
    self.view.backgroundColor = RGB(255, 255, 255);
    [self createNavBlackBtn];
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
    }];
    //logo下方的提示
    [self.view addSubview:self.logotip_lb];
    [self.logotip_lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.logoImg);
        make.top.equalTo(self.logoImg.mas_bottom).offset(10);
    }];
    //验证码View
    [self.view addSubview:self.verifyView];
    [self.verifyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logotip_lb.mas_bottom).offset(LOGOWIDTH/1.5);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 42));
    }];
    //验证码提示
    UILabel *tipVLb = [[UILabel alloc]init];
    tipVLb.textColor = RGB(164, 164, 164);
    tipVLb.font = FONT(17);
    tipVLb.text = @"验证码";
    [self.verifyView addSubview:tipVLb];
    [tipVLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.verifyView.mas_left).offset(15);
        make.centerY.equalTo(self.verifyView.mas_centerY);
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
        make.left.equalTo(tipVLb.mas_right).offset(15);
        make.right.equalTo(self.verifyBtn.mas_left).offset(-10);
    }];
    
    //新密码View
    [self.view addSubview:self.registerPsdView];
    [self.registerPsdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.verifyView.mas_bottom).offset(25);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 42));
    }];
    //新密码提示
    UILabel *tipPLb = [[UILabel alloc]init];
    tipPLb.textColor = RGB(164, 164, 164);
    tipPLb.font = FONT(17);
    tipPLb.text = @"新密码";
    [self.registerPsdView addSubview:tipPLb];
    [tipPLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.registerPsdView.mas_left).offset(15);
        make.centerY.equalTo(self.registerPsdView.mas_centerY);
    }];
    //显示密码的按钮
    [self.registerPsdView addSubview:self.showPasBtn];
    [self.showPasBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.registerPsdView.mas_centerY);
        make.right.equalTo(self.registerPsdView.mas_right).offset(-15);
    }];
    //新密码文本框
    [self.registerPsdView addSubview:self.registerPsd_tf];
    [self.registerPsd_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.registerPsdView.mas_centerY);
        make.left.equalTo(tipPLb.mas_right).offset(15);
        make.right.equalTo(self.showPasBtn.mas_left).offset(-5);
    }];
    
    
    //完成按钮
    [self.view addSubview:self.completeBtn];
    [self.completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.registerPsdView.mas_bottom).offset(40);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 45));
    }];
}
//==========================method==========================
#pragma mark ----- 完成按钮点击事件
-(void)completeClick{
    [self resetTextData];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark ----- 获取验证码点击事件
-(void)verifyClick{
    [Toast showInfo:@"验证码已发送"];
    [self codeBtnTimeBegin];
}
#pragma mark -----判断密文还是明文
-(void)isOpenPsdClick{
    //现在是睁眼状态
    if (isOpenPsd) {
        [self.showPasBtn setImage:[UIImage imageNamed:@"closePsdeye"] forState:UIControlStateNormal];
        // 按下去了就是密文
        NSString *tempPwdStr = self.registerPsd_tf.text;
        self.registerPsd_tf.text = @"";
        self.registerPsd_tf.secureTextEntry = YES;
        self.registerPsd_tf.text = tempPwdStr;
        isOpenPsd=NO;
    }else{//现在是闭眼状态
        [self.showPasBtn setImage:[UIImage imageNamed:@"showPsdeye"] forState:UIControlStateNormal];
        // 明文
        NSString *tempPwdStr = self.registerPsd_tf.text;
        self.registerPsd_tf.text = @""; // 可以防止切换的时候光标偏移
        self.registerPsd_tf.secureTextEntry = NO;
        self.registerPsd_tf.text = tempPwdStr;
        isOpenPsd=YES;
    }
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

#pragma mark ----- 清除文本数据和弹回键盘
-(void)resetTextData{
    self.registerPsd_tf.text = @"";
    [self.registerPsd_tf resignFirstResponder];
    self.verify_tf.text = @"";
    [self.verify_tf resignFirstResponder];
}
//==========================delegate==========================

//==========================lazy loading==========================
#pragma mark -----懒加载
//logo图片
-(UIImageView *)logoImg{
    if (!_logoImg) {
        _logoImg = [[UIImageView alloc]init];
        _logoImg.image = [UIImage imageNamed:@"verify_logo"];
    }
    return _logoImg;
}
//logo下方的提示
-(UILabel *)logotip_lb{
    if (!_logotip_lb) {
        _logotip_lb = [[UILabel alloc]init];
        _logotip_lb.font = FONT(14);
        _logotip_lb.textColor = [UIColor lightGrayColor];
        _logotip_lb.text = @"注册新账号";
    }
    return _logotip_lb;
}
//验证码View
-(UIView *)verifyView{
    if (!_verifyView) {
        _verifyView = [[UIView alloc]init];
        _verifyView.layer.cornerRadius = 5.0f;
        _verifyView.layer.borderWidth = 1.0f;
        _verifyView.layer.borderColor = RGB(215, 215, 215).CGColor;
    }
    return _verifyView;
}
//新密码View
-(UIView *)registerPsdView{
    if (!_registerPsdView) {
        _registerPsdView = [[UIView alloc]init];
        _registerPsdView.layer.cornerRadius = 5.0f;
        _registerPsdView.layer.borderWidth = 1.0f;
        _registerPsdView.layer.borderColor = RGB(215, 215, 215).CGColor;
    }
    return _registerPsdView;
}
//注册成功按钮
-(UIButton *)completeBtn{
    if (!_completeBtn) {
        _completeBtn = [[UIButton alloc]init];
        _completeBtn.backgroundColor = MAIN_COLOR;
        _completeBtn.layer.cornerRadius = 7.0f;
        [_completeBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_completeBtn addTarget:self action:@selector(completeClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeBtn;
}
//验证码文本框
-(UITextField *)verify_tf{
    if (!_verify_tf) {
        _verify_tf = [[UITextField alloc]init];
        _verify_tf.font =FONT(17);
        _verify_tf.keyboardType = UIKeyboardTypeNumberPad;
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
//新密码文本框
-(UITextField *)registerPsd_tf{
    if (!_registerPsd_tf) {
        _registerPsd_tf = [[UITextField alloc]init];
        _registerPsd_tf.font =FONT(17);
        _registerPsd_tf.placeholder = @"请填写您的新密码";
        _registerPsd_tf.secureTextEntry = YES;
        _registerPsd_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _registerPsd_tf;
}
//查看密码的按钮
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
@end
