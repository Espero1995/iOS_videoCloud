//
//  TransferDeviceVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/4/8.
//  Copyright © 2018年 张策. All rights reserved.
//
//文本尺寸
#define ACCOUNTWIDTH 0.9*iPhoneWidth
#import "TransferDeviceVC.h"
#import "TransferVerifyVC.h"
#import "MyShareModel.h"
//警告框类型
typedef NS_ENUM(NSInteger,AlertAction){
    AlertAction_PhoneorEmailNull,//电话号码/邮箱为空
    AlertAction_EmailNull,//邮箱为空
    AlertAction_isPhoneorEmail,//是否是正确的手机号或email
    AlertAction_isEmail,//请输入正确的邮箱
    AlertAction_netWork,//网络是否打开
    AlertAction_netWorkInit,//服务器连接失败
    AlertAction_isBelongtoOwn,//设备是否是该手机号用户
    AlertAction_isShared,//该设备是否分享过
    AlertAction_userUnregistered,//该用户未注册
};
@interface TransferDeviceVC ()
/*提示*/
@property (nonatomic,strong) UILabel *tip_lb;
/*手机号View*/
@property (nonatomic,strong) UIView *accountView;
/*手机号文本框*/
@property (nonatomic,strong) UITextField *account_tf;
/*下一步按钮*/
@property (nonatomic,strong) UIButton *stepBtn;
/*分享的人Arr*/
@property (nonatomic,strong) NSMutableArray *sharedArr;
@end

@implementation TransferDeviceVC
//==========================system==========================
#pragma mark ----- 生命周期 -----
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"转移设备", nil);
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
    [self.view addSubview:self.accountView];
    [self.accountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tip_lb.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 45));
    }];
    //添加文本框
    [self.accountView addSubview:self.account_tf];
    [self.account_tf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.accountView.mas_centerY);
        make.left.equalTo(self.accountView.mas_left).offset(10);
        make.right.equalTo(self.accountView.mas_right);
    }];
    //下一步按钮
    [self.view addSubview:self.stepBtn];
    [self.stepBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.accountView.mas_bottom).offset(30);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(ACCOUNTWIDTH, 45));
    }];
}
//==========================method==========================
#pragma mark ----- 方法 -----
//点击下一步按钮
- (void)stepAccountClick
{
    /**
     *  description:
     *   1.判断手机号是不是为空(空:return)
     *   2.判断手机号是不是正确(错:return)
     *   3.判断该设备所归属的用户手机号与输入的手机号是否一致
     *   4.判断该设备是否还存在分享的用户
     */
    //1.
    if (isOverSeas) {
        if ([NSString isNull:self.account_tf.text]) {
            [self LoginAlertAction:AlertAction_EmailNull];
            return ;
        }
    }else{
        if ([NSString isNull:self.account_tf.text]) {
            [self LoginAlertAction:AlertAction_PhoneorEmailNull];
            return ;
        }
    }
   
    //2.
    if (isOverSeas) {
        if (![NSString isValidateEmail:self.account_tf.text]){
            //是否是正确的手机号
            [self LoginAlertAction:AlertAction_isEmail];
            return;
        }
    }else{
        if ((![NSString validateMobile:self.account_tf.text]) && (![NSString isValidateEmail:self.account_tf.text])){
            //是否是正确的手机号/email
            [self LoginAlertAction:AlertAction_isPhoneorEmail];
            return;
        }
    }
    
    //3.
    UserModel *user = [unitl getUserModel];
    if ([unitl isEmailAccountType]) {
        if ([user.mail isEqualToString:self.account_tf.text]) {
            [self LoginAlertAction:AlertAction_isBelongtoOwn];
            return;
        }
    }else{
        if ([user.mobile isEqualToString:self.account_tf.text]) {
            [self LoginAlertAction:AlertAction_isBelongtoOwn];
            return;
        }
    }
    

    //4.
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/share/device-shared-info" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSLog(@"转移查询是否分享：responseObject54321:%@",responseObject);
            [self.sharedArr removeAllObjects];
            
            MyShareModel *listModel = [MyShareModel mj_objectWithKeyValues:responseObject[@"body"]];
            self.sharedArr = [shared mj_objectArrayWithKeyValuesArray:listModel.userList];
            
            if (self.sharedArr.count == 0) {
                [self checkTransferMobileHaveAlreadyRegistered];
            }else{
                [self LoginAlertAction:AlertAction_isShared];
            }
        }else{
            [self LoginAlertAction:AlertAction_netWorkInit];
        }
        
    } failure:^(NSError * _Nonnull error) {
       [self LoginAlertAction:AlertAction_netWork];
    }];

}
#pragma mark - 转移设备前，检查该手机号是否注册过
- (void)checkTransferMobileHaveAlreadyRegistered
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    //转移给手机还是邮箱
    if ([NSString validateMobile:self.account_tf.text]){
        [dic setObject:self.account_tf.text forKey:@"mobile"];
    }
    if ([NSString isValidateEmail:self.account_tf.text]) {
        [dic setObject:self.account_tf.text forKey:@"mail"];
    }
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/transfercheckNew" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        NSLog(@"转移检查mobile结果：responseObject:%@",responseObject);
        if (ret == 0) {
            [self.sharedArr removeAllObjects];
            [self.account_tf resignFirstResponder];
            TransferVerifyVC *transferVC = [[TransferVerifyVC alloc]init];
            transferVC.transDevId = self.dev_mList.ID;
            transferVC.transMobile = self.account_tf.text;
            [self.navigationController pushViewController:transferVC animated:YES];
        }else{
            [self LoginAlertAction:AlertAction_userUnregistered];
        }
    } failure:^(NSError * _Nonnull error) {
        [self LoginAlertAction:AlertAction_netWork];
    }];
}


//警告框提醒  请输入正确的邮箱
- (void)LoginAlertAction:(AlertAction)action
{
    switch (action) {
            //电话号码/邮箱为空
        case AlertAction_PhoneorEmailNull:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"手机号或邮箱不能为空", nil)];
        }
            break;
        case AlertAction_EmailNull:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"邮箱不能为空", nil)];
        }
            break;
            //是否是正确的手机号/邮箱
        case AlertAction_isPhoneorEmail:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"请输入正确的邮箱或手机号", nil)];
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
            //服务器连接失败
        case AlertAction_netWorkInit:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"服务器连接失败，请稍候再试", nil)];
        }
            break;
            //设备是否是该手机号用户
        case AlertAction_isBelongtoOwn:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"属于自己的设备不能再转移给自己", nil)];
        }
            break;
            //该设备是否分享过
        case AlertAction_isShared:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"转移设备需先关闭设备共享,您可在“我的界面”点击“设备共享”先关闭该设备分享的用户", nil)];
        }
            break;
            //该用户未注册
        case AlertAction_userUnregistered:
        {
            [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"您要分享的用户还未注册", nil)];
        }
            break;
            
        default:
            break;
    }
}
- (void)createAlertActionWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertCtrl addAction:btnAction];
    [self presentViewController:alertCtrl animated:YES completion:nil];
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
        _tip_lb.text = NSLocalizedString(@"您正在将此设备转移给其他用户使用，转移后对应的云存储服务也将会被转移。", nil);
    }
    return _tip_lb;
}

//手机号View
-(UIView *)accountView{
    if (!_accountView) {
        _accountView = [[UIView alloc] init];
        _accountView.backgroundColor = [UIColor whiteColor];
        _accountView.layer.cornerRadius = 7.0f;
        _accountView.layer.borderWidth = 1.0f;
        _accountView.layer.borderColor = RGB(231, 231, 231).CGColor;
    }
    return _accountView;
}
//账号文本框
-(UITextField *)account_tf
{
    if (!_account_tf) {
        _account_tf = [[UITextField alloc]init];
        _account_tf.font =FONT(17);
        if (isOverSeas) {
            _account_tf.placeholder = NSLocalizedString(@"请输入要转移用户的邮箱", nil);
        }else{
            _account_tf.placeholder = NSLocalizedString(@"请输入要转移用户的邮箱或手机号", nil);
        }
        _account_tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        _account_tf.keyboardType = UIKeyboardTypeEmailAddress;
    }
    return _account_tf;
}
//下一步按钮
- (UIButton *)stepBtn
{
    if (!_stepBtn) {
        _stepBtn = [[UIButton alloc]initWithFrame:CGRectMake(0.15*iPhoneWidth/2, 0, ACCOUNTWIDTH, 45)];
        _stepBtn.backgroundColor = MAIN_COLOR;
        _stepBtn.layer.cornerRadius = 7.0f;
        [_stepBtn setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
        [_stepBtn addTarget:self action:@selector(stepAccountClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stepBtn;
}
//分享的人Arr
- (NSMutableArray *)sharedArr
{
    if (!_sharedArr) {
        _sharedArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _sharedArr;
}
@end
