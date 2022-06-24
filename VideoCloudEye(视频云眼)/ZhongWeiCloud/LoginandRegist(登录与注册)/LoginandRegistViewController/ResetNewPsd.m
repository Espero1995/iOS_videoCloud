//
//  ResetNewPsd.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/2/6.
//  Copyright © 2018年 张策. All rights reserved.
//
//图片尺寸
#define LOGOWIDTH iPhoneWidth/5.5
//文本尺寸
#define ACCOUNTWIDTH 0.85*iPhoneWidth
#import "ResetNewPsd.h"

@interface ResetNewPsd ()
{
    //判断密码是明文还是密文
    BOOL isOpenPsd;
}
/*logo图片*/
@property (nonatomic,strong) UIImageView *logoImg;
/*logo下方的提示*/
@property (nonatomic,strong) UILabel *logotip_lb;
/*新密码View*/
@property (nonatomic,strong) UIView *resetPsdView;
/*新密码文本框*/
@property (nonatomic,strong) UITextField *resetPsd_tf;
/*查看密码的按钮*/
@property (nonatomic,strong) UIButton *showPasBtn;
/*重置按钮*/
@property (nonatomic,strong) UIButton *resetBtn;
@end

@implementation ResetNewPsd
//==========================system==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置新密码";
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
    //手机号View
    [self.view addSubview:self.resetPsdView];
    [self.resetPsdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logotip_lb.mas_bottom).offset(LOGOWIDTH);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 42));
    }];
    //显示密码的按钮
    [self.resetPsdView addSubview:self.showPasBtn];
    [self.showPasBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.resetPsdView.mas_centerY);
        make.right.equalTo(self.resetPsdView.mas_right).offset(-15);
    }];
    //添加文本框
    [self.resetPsdView addSubview:self.resetPsd_tf];
    [self.resetPsd_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.resetPsdView.mas_centerY);
        make.left.equalTo(self.resetPsdView.mas_left).offset(15);
        make.right.equalTo(self.showPasBtn.mas_left).offset(-5);
    }];
    
    //重置按钮
    [self.view addSubview:self.resetBtn];
    [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.resetPsdView.mas_bottom).offset(40);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 45));
    }];
}
//==========================method==========================
#pragma mark -----重置按钮点击事件
-(void)resetClick{
    [self resetTextData];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
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
#pragma mark ----- 清除文本数据和弹回键盘
-(void)resetTextData{
    self.resetPsd_tf.text = @"";
    [self.resetPsd_tf resignFirstResponder];
}
//==========================delegate==========================

//==========================lazy loading==========================
#pragma mark -----懒加载
//logo图片
-(UIImageView *)logoImg{
    if (!_logoImg) {
        _logoImg = [[UIImageView alloc]init];
        _logoImg.image = [UIImage imageNamed:@"success_logo"];
    }
    return _logoImg;
}
//logo下方的提示
-(UILabel *)logotip_lb{
    if (!_logotip_lb) {
        _logotip_lb = [[UILabel alloc]init];
        _logotip_lb.font = FONT(14);
        _logotip_lb.textColor = [UIColor lightGrayColor];
        _logotip_lb.text = @"验证身份通过,请设置密码";
    }
    return _logotip_lb;
}
//新密码View
-(UIView *)resetPsdView{
    if (!_resetPsdView) {
        _resetPsdView = [[UIView alloc]init];
        _resetPsdView.layer.cornerRadius = 5.0f;
        _resetPsdView.layer.borderWidth = 1.0f;
        _resetPsdView.layer.borderColor = RGB(215, 215, 215).CGColor;
    }
    return _resetPsdView;
}
//重置按钮
-(UIButton *)resetBtn{
    if (!_resetBtn) {
        _resetBtn = [[UIButton alloc]init];
        _resetBtn.backgroundColor = MAIN_COLOR;
        _resetBtn.layer.cornerRadius = 7.0f;
        [_resetBtn setTitle:@"重置" forState:UIControlStateNormal];
        [_resetBtn addTarget:self action:@selector(resetClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetBtn;
}
//新密码文本框
-(UITextField *)resetPsd_tf{
    if (!_resetPsd_tf) {
        _resetPsd_tf = [[UITextField alloc]init];
        _resetPsd_tf.font =FONT(17);
        _resetPsd_tf.placeholder = @"请填写您的新密码";
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
@end
