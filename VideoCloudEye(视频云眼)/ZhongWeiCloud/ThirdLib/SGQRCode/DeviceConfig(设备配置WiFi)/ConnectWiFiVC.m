//
//  ConnectWiFiVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/3/18.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import "ConnectWiFiVC.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CoreLocation.h>
#import "WiFiRequiredVC.h"//WiFi要求界面
#import "QRCodeConfigVC.h"//二维码配置界面
#import "WiFiConfigVC.h"//WiFi配置并连接网络界面
@interface ConnectWiFiVC ()
<
    CLLocationManagerDelegate
>
/**
 * @brief WiFi名称框
 */
@property (strong, nonatomic) IBOutlet UITextField *wifiName_tf;

/**
 * @brief WiFi密码框
 */
@property (strong, nonatomic) IBOutlet UITextField *wifiPwd_tf;

/**
 * @brief 显示密码按钮
 */
@property (strong, nonatomic) IBOutlet UIButton *showPwdBtn;

/**
 * @brief 下一步提交按钮
 */
@property (strong, nonatomic) IBOutlet UIButton *submitBtn;

/**
 * @brief 定位属性
 */
@property (nonatomic, strong) CLLocationManager *locManager;

@end

@implementation ConnectWiFiVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkNetStatusClick) name:RECHECKNETSTATUS object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - setUI
- (void)setUpUI
{
    self.navigationItem.title = NSLocalizedString(@"步骤(1/3)", nil);
    [self cteateNavBtn];
    
    //连接网络 submitBtn Style
    self.submitBtn.layer.cornerRadius = 22.5f;
    
   //iOS 13以后的
    if (@available(iOS 13.0, *)) {
        [self getcurrentLocation];
    }else{
        NSString *str = [self getWiFiStatus];
        if ([str isEqualToString:@"WIFI"] || [str isEqualToString:@"HOTSPOT"]) {
            //获取WiFi名称
            [self checkNetStatusClick];
        }
        else{
            //请链接WiFi
            [self createAlertActionWithTitle:NSLocalizedString(@"网络提醒", nil) message:NSLocalizedString(@"设备必须在Wi-Fi网络环境中才能接入网络", nil) isCancelBtn:NO];
        }
        
        
    }
    
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

#pragma mark - 修改WiFi点击事件
- (IBAction)changeWifi:(id)sender
{
    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString]; 
    if([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
    
    
}

#pragma mark - 显示Wi-Fi密码
- (IBAction)showPwdClick:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        NSString *tempPwdStr = self.wifiPwd_tf.text;
        self.wifiPwd_tf.text = @""; // 可以防止切换的时候光标偏移
        self.wifiPwd_tf.secureTextEntry = NO;
        self.wifiPwd_tf.text = tempPwdStr;
    }else{
        // 按下去了就是密文
        NSString *tempPwdStr = self.wifiPwd_tf.text;
        self.wifiPwd_tf.text = @"";
        self.wifiPwd_tf.secureTextEntry = YES;
        self.wifiPwd_tf.text = tempPwdStr;
    }
}

#pragma mark - WiFi连接要求点击事件
- (IBAction)wifiRequiredClick:(id)sender
{
    WiFiRequiredVC *requireVC = [[WiFiRequiredVC alloc]init];
    [self.navigationController pushViewControllerFromTop:requireVC];
}

#pragma mark - “下一步”点击事件
- (IBAction)submitClick:(id)sender
{
    if ([NSString isNull:self.wifiName_tf.text]) {
        [XHToast showCenterWithText:NSLocalizedString(@"请输入Wi-Fi名称", nil)];
        return ;
    }
    if ([NSString isNull:self.wifiPwd_tf.text]) {
        [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"确认该Wi-Fi是否未设置密码？", nil) isCancelBtn:YES];
    }else{
        [self nextPageClick];
    }
}

#pragma mark - 进入下一个界面
- (void)nextPageClick
{
    [self.wifiName_tf resignFirstResponder];
    [self.wifiPwd_tf resignFirstResponder];
    
    if (self.isQRCode) {
        QRCodeConfigVC *qrcodeVC = [[QRCodeConfigVC alloc]init];
        qrcodeVC.configModel = self.configModel;
        qrcodeVC.wifiNameStr = self.wifiName_tf.text;
        qrcodeVC.wifiPwdStr = self.wifiPwd_tf.text;
        [self.navigationController pushViewController:qrcodeVC animated:YES];
    }else{
        WiFiConfigVC *wifiVC = [[WiFiConfigVC alloc]init];
        wifiVC.isQRCode = NO;
        wifiVC.configModel = self.configModel;
        wifiVC.wifiNameStr = self.wifiName_tf.text;
        wifiVC.wifiPwdStr = self.wifiPwd_tf.text;
        [self.navigationController pushViewController:wifiVC animated:YES];
    }
}

#pragma mark - 检测Wi-Fi状态点击事件
- (void)checkNetStatusClick
{
    [self getcurrentLocation];
    self.wifiName_tf.text = [self getWifiName];
    
}


#pragma mark - 获取网络状态
- (NSString *)getWiFiStatus
{
    // 状态栏是由当前app控制的，首先获取当前app
    UIApplication *app = [UIApplication sharedApplication];
    id statusBar = [app valueForKeyPath:@"statusBar"];
    NSString *network = @"";
    if (iPhone_X_) {
        id statusBarView = [statusBar valueForKeyPath:@"statusBar"];
        UIView *foregroundView = [statusBarView valueForKeyPath:@"foregroundView"];
        
        NSArray *subviews = [[foregroundView subviews][2] subviews];
        
        for (id subview in subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                network = @"WIFI";
            }else if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarStringView")]) {
                network = [subview valueForKeyPath:@"originalText"];
            }
        }
    }else{
        CGFloat x_height = iPhoneHeight;
        CGFloat x_widith = iPhoneWidth;
        NSLog(@"屏幕尺寸：%ff==%ff",x_height,x_widith);
        NSArray *children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
        int type = 0;
        for (id child in children) {
            if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
                type = [[child valueForKeyPath:@"dataNetworkType"] intValue];
            }
        }
        switch (type) {
            case 1:
                network = @"2G";
                break;
            case 2:
                network = @"3G";
                break;
            case 3:
                network = @"4G";
                break;
            case 5:
                network = @"WIFI";
                break;
            case 6:
                network = @"HOTSPOT";//热点
                break;
            default:
                network = @"NO-WIFI";//代表未知网络
                break;
        }
    }
    if ([network isEqualToString:@""]) {
        network = @"NO DISPLAY";
    }
    return network;
}


#pragma mark - 获取当前wifi名称
- (NSString *)getWifiName
{
    
    NSString *wifiName = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString*)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiName;
    
    
    
    /*
    NSString *ssid = nil;
    NSArray *ifs = (__bridge  id)CNCopySupportedInterfaces();
    for (NSString *ifname in ifs) {
        NSDictionary *info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
        if (info[@"SSIDD"])
        {
            ssid = info[@"SSID"];
        }
    }
    return ssid;
    */
    
}

#pragma mark - 警告框
- (void)createAlertActionWithTitle:(NSString *)title message:(NSString *)message isCancelBtn:(BOOL)isCancelBtn
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    if (isCancelBtn) {
        UIAlertAction *btnAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self nextPageClick];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"输入密码", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.wifiPwd_tf becomeFirstResponder];
        }];
        [alertCtrl addAction:btnAction];
        [alertCtrl addAction:cancelAction];
    }else{
        UIAlertAction *btnAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"我知道了", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertCtrl addAction:btnAction];
    }
    
    [self presentViewController:alertCtrl animated:YES completion:nil];
}


//iOS 13需要使用定位才能获取到WiFi状态
- (void)getcurrentLocation {
    if (@available(iOS 13.0, *)) {
        //用户明确拒绝，可以弹窗提示用户到设置中手动打开权限
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            //使用下面接口可以打开当前应用的设置页面
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        
        self.locManager = [[CLLocationManager alloc] init];
        self.locManager.delegate = self;
        if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
            //弹框提示用户是否开启位置权限
            [self.locManager requestWhenInUseAuthorization];
        }
    }
}

//定位的相关代理
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways) {
        //再重新获取ssid
        self.wifiName_tf.text = [self getWifiName];
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
