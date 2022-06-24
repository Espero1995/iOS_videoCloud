//
//  TransferVerifyVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/4/8.
//  Copyright © 2018年 张策. All rights reserved.
//
//文本尺寸
#define ACCOUNTWIDTH 0.9*iPhoneWidth
#import "TransferVerifyVC.h"
#import "myDeviceDisplayVC.h"

@interface TransferVerifyVC ()
/*提示*/
@property (nonatomic,strong) UILabel *tip_lb;
/*手机号View*/
@property (nonatomic,strong) UIView *verityView;
/*手机号文本框*/
@property (nonatomic,strong) UITextField *verity_tf;
/*完成按钮*/
@property (nonatomic,strong) UIButton *completeBtn;
@end

@implementation TransferVerifyVC
//==========================system==========================
#pragma mark ----- 生命周期 -----
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"输入验证码", nil);
    self.view.backgroundColor = BG_COLOR;
    [self cteateNavBtn];
    [self setUpUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//==========================init==========================
#pragma mark ----- 页面初始化的一些方法 -----
- (void)setUpUI
{
    [self.view addSubview:self.tip_lb];
    [self.tip_lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(15);
        make.width.mas_equalTo(ACCOUNTWIDTH);
    }];
    [self.view addSubview:self.verityView];
    [self.verityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tip_lb.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 45));
    }];
    //添加文本框
    [self.verityView addSubview:self.verity_tf];
    [self.verity_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.verityView.mas_centerY);
        make.left.equalTo(self.verityView.mas_left).offset(10);
        make.right.equalTo(self.verityView.mas_right);
    }];
    //下一步按钮
    [self.view addSubview:self.completeBtn];
    [self.completeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.verityView.mas_bottom).offset(30);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 45));
    }];
}
//==========================method==========================
#pragma mark ----- 方法 -----
//点击完成按钮
- (void)completeClick
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //转移给手机还是邮箱
    if ([NSString validateMobile:self.transMobile]){
        [postDic setObject:self.transMobile forKey:@"mobile"];
    }
    if ([NSString isValidateEmail:self.transMobile]) {
        [postDic setObject:self.transMobile forKey:@"mail"];
    }
    [postDic setObject:self.transDevId forKey:@"dev_id"];
    [postDic setObject:self.verity_tf.text forKey:@"check_code"];
    NSLog(@"转移上传dic：%@",postDic);
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/transferNew" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"转移结果：responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            [XHToast showCenterWithText:NSLocalizedString(@"转移设备成功", nil)];
            [[NSNotificationCenter defaultCenter] postNotificationName:ADDORDELETEDEVICE object:nil userInfo:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else if (ret == 1102){
            [XHToast showCenterWithText:NSLocalizedString(@"转移设备失败", nil)];
        }else
        {
           [XHToast showCenterWithText:NSLocalizedString(@"转移设备失败", nil)];
        }
    } failure:^(NSError * _Nonnull error) {
        [XHToast showCenterWithText:NSLocalizedString(@"转移设备失败", nil)];
    }];
}

//==========================delegate==========================

//==========================lazy loading==========================
#pragma mark ----- getter&setter
//提示
- (UILabel *)tip_lb
{
    if (!_tip_lb) {
        _tip_lb = [[UILabel alloc]init];
        _tip_lb.font = FONT(14);
        _tip_lb.textColor = [UIColor lightGrayColor];
        _tip_lb.numberOfLines = 0;
        _tip_lb.lineBreakMode = NSLineBreakByCharWrapping;
        _tip_lb.text = NSLocalizedString(@"请输入设备验证码，验证码位于机身标签上(验证码为大写)", nil);
    }
    return _tip_lb;
}

//手机号View
-(UIView *)verityView{
    if (!_verityView) {
        _verityView = [[UIView alloc] init];
        _verityView.backgroundColor = [UIColor whiteColor];
        _verityView.layer.cornerRadius = 7.0f;
        _verityView.layer.borderWidth = 1.0f;
        _verityView.layer.borderColor = RGB(231, 231, 231).CGColor;
    }
    return _verityView;
}
//账号文本框
-(UITextField *)verity_tf
{
    if (!_verity_tf) {
        _verity_tf = [[UITextField alloc]init];
        _verity_tf.font =FONT(17);
        _verity_tf.placeholder = NSLocalizedString(@"请输入设备验证码", nil);
        //_verity_tf.keyboardType = UIKeyboardTypeNumberPad;
        _verity_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _verity_tf;
}
//下一步按钮
- (UIButton *)completeBtn
{
    if (!_completeBtn) {
        _completeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0.15*iPhoneWidth/2, 0, ACCOUNTWIDTH, 45)];
        _completeBtn.backgroundColor = MAIN_COLOR;
        _completeBtn.layer.cornerRadius = 7.0f;
        [_completeBtn setTitle:NSLocalizedString(@"完成", nil) forState:UIControlStateNormal];
        [_completeBtn addTarget:self action:@selector(completeClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _completeBtn;
}
@end
