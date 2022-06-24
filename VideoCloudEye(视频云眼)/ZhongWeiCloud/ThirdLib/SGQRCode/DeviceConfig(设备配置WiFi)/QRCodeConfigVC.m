//
//  QRCodeConfigVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/3/18.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import "QRCodeConfigVC.h"
#import "WiFiConfigVC.h"//WiFi连接界面
#import "ZJImageMagnification.h"//二维码放大方法
#import "SGQRCodeTool.h"//生成二维码的工具
@interface QRCodeConfigVC ()

/**
 * @brief 二维码图片
 */
@property (strong, nonatomic) IBOutlet UIImageView *QRCodeImageView;
/**
 * @brief 提交按钮
 */
@property (strong, nonatomic) IBOutlet UIButton *submitBtn;
/**
 * @breif 菊花状等待图标
 */
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
/**
 * @breif 等待提示
 */
@property (nonatomic, strong) UILabel *tipLb;
@end

@implementation QRCodeConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    //生成二维码(交给后台生成)
    [self generatedQRCode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - setUI
- (void)setUpUI
{
    self.navigationItem.title = NSLocalizedString(@"步骤(2/3)", nil);
    [self cteateNavBtn];
    //连接网络 submitBtn Style
    self.submitBtn.layer.cornerRadius = 22.5f;
    
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY).offset(-15);
    }];
    [self.view addSubview:self.tipLb];
    [self.tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.activityIndicator.mas_bottom).offset(10);
    }];
}

#pragma mark - 返回点击事件
- (void)returnVC
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"正在为您添加设备，您确定要退出\"添加设备\"操作吗？", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertCtrl addAction:btnAction];
    [alertCtrl addAction:cancelAction];
    
    [self presentViewController:alertCtrl animated:YES completion:nil];
}


#pragma mark - 无声音时点击事件
- (IBAction)noSoundClick:(id)sender
{
    [self createAlertActionWithTitle:NSLocalizedString(@"没有听到任何声音？", nil) message:NSLocalizedString(@"1.请确保您已经接通设备电源\n2.请确保二维码和设备之间的距离在10-20cm", nil)];
}

#pragma mark - 扫描成功后的点击事件
- (IBAction)submitClick:(id)sender
{
    WiFiConfigVC *wifiVC = [[WiFiConfigVC alloc]init];
    wifiVC.isQRCode = YES;
    wifiVC.configModel = self.configModel;
    [self.navigationController pushViewController:wifiVC animated:YES];
}


#pragma mark - 生成二维码(交给后台生成)
- (void)generatedQRCode
{
    self.QRCodeImageView.hidden = YES;
    [self.activityIndicator startAnimating];
    self.tipLb.hidden = NO;
    
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    if (self.wifiNameStr) {
        [postDic setObject:self.wifiNameStr forKey:@"ssid"];
    }
    if (self.wifiPwdStr) {
        [postDic setObject:self.wifiPwdStr forKey:@"password"];
    }
    NSLog(@"postDic:%@",postDic);
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/getQRcode" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"获取wifi密码:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^(void){
            [self.activityIndicator stopAnimating];
            self.tipLb.hidden = YES;
            self.QRCodeImageView.hidden = NO;
        });
        
        
        if (ret == 0) {
            NSString *base64EncryptedStr = responseObject[@"body"][@"imageData"];
            [self setUpQRCode:base64EncryptedStr];//根据字符串生成二维码
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lightScreen)];
            [self.QRCodeImageView addGestureRecognizer:tapGesture];
        }else{
            self.QRCodeImageView.image = [UIImage imageNamed:@"InvalidQRCode"];
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadQRCode)];
            [self.QRCodeImageView addGestureRecognizer:tapGesture];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
        dispatch_after(time, dispatch_get_main_queue(), ^(void){
            [self.activityIndicator stopAnimating];
            self.tipLb.hidden = YES;
            self.QRCodeImageView.hidden = NO;
        });
        
        self.QRCodeImageView.image = [UIImage imageNamed:@"InvalidQRCode"];
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadQRCode)];
        [self.QRCodeImageView addGestureRecognizer:tapGesture];
    }];
}

#pragma mark - 重新生成
- (void)reloadQRCode
{
    [self generatedQRCode];
}

#pragma mark - 根据字符串生成二维码
- (void)setUpQRCode:(NSString *)Base64EncryptedStr
{
    self.QRCodeImageView.image = [SGQRCodeTool SG_generateWithDefaultQRCodeData:Base64EncryptedStr imageViewWidth:1000.f];
}

#pragma mark - 亮屏
- (void)lightScreen
{
    [ZJImageMagnification scanBigImageWithImageView:self.QRCodeImageView alpha:1.0];
}

#pragma mark - 警告框
- (void)createAlertActionWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
        UIAlertAction *btnAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"我知道了", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alertCtrl addAction:btnAction];
    
    [self presentViewController:alertCtrl animated:YES completion:nil];
}


//菊花状等待图标
- (UIActivityIndicatorView *)activityIndicator
{
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _activityIndicator;
}

//等待提示
- (UILabel *)tipLb
{
    if (!_tipLb) {
        _tipLb = [[UILabel alloc]init];
        _tipLb.hidden = YES;
        _tipLb.text = NSLocalizedString(@"二维码正在生成中…", nil);
        _tipLb.font = FONT(16);
        _tipLb.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLb;
}

@end
