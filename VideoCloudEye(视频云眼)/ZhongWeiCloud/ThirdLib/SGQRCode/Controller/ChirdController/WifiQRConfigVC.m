//
//  WifiQRCodeVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/5/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "WifiQRConfigVC.h"
#import "ZCTabBarController.h"
#import "SGQRCodeTool.h"
#import "WiFiConfigurationProtocol.h"
#import "ZJImageMagnification.h"

#import "WiFiSetController.h"
#import "RcodeShowController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "HelpVC.h"
@interface WifiQRConfigVC ()
{
    double currentLight;
    BOOL isBack;
}
@property (strong, nonatomic) IBOutlet UIImageView *QRCodeImg;
@property (strong, nonatomic) IBOutlet UIView *QRCodeView;
//操作步骤
@property (strong, nonatomic) IBOutlet UILabel *stepsContentLb;
@property (strong, nonatomic) IBOutlet UILabel *stepsContentLb1;
@property (strong, nonatomic) IBOutlet UILabel *stepsContentLb2;
@property (strong, nonatomic) IBOutlet UILabel *stepsContentLb3;
//操作步骤提示语
@property (strong, nonatomic) IBOutlet UILabel *stepsTipLb;
@property (strong, nonatomic) IBOutlet UILabel *enlargeQRCodeTipLb;

@property (strong, nonatomic) IBOutlet UIButton *wifiConfigBtn;
@property (strong, nonatomic) IBOutlet UIButton *qrCodeSucBtn;
@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,strong)NSTimer *actionTimer;
@property (nonatomic,assign)int i;
@end

@implementation WifiQRConfigVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"配置方式", nil);
    [self createNavEmptyBtn];
    isBack = NO;
    self.qrCodeSucBtn.layer.cornerRadius = 20.f;
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"设备通电后，听到“设备启动完成，请使用手机客户端软件进行WiFi配置”提示音后，请将二维码对准摄像头", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"我知道了", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"wifiName :%@;wifiPwd:%@",self.ssidNameStr,self.smartConfigWifiPwd);
        [self setConfigUI];//配置方式样式
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    
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

#pragma mark - 得到当前wifi名称
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
}

#pragma mark - 亮屏
- (void)lightScreen
{
    [ZJImageMagnification scanBigImageWithImageView:self.QRCodeImg alpha:1.0];
}

- (void)reloadQRCode
{
    /**
     * description: GET v1/device/getQRcode（配二维码）
     * access_token=<令牌> & user_id =<用户ID>&ssid=<名称 >& password=<密码 >
     */
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *ssidNameStr = [self getWifiName];
    if (ssidNameStr) {
        [postDic setObject:ssidNameStr forKey:@"ssid"];
    }
    if (self.smartConfigWifiPwd) {
        [postDic setObject:self.smartConfigWifiPwd forKey:@"password"];
    }
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/getQRcode" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSString *base64EncryptedStr = responseObject[@"body"][@"imageData"];
            [self setUpQRCode:base64EncryptedStr];//根据字符串生成二维码
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lightScreen)];
            [self.QRCodeView addGestureRecognizer:tapGesture];
        }else{
            self.QRCodeImg.image = [UIImage imageNamed:@"InvalidQRCode"];
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadQRCode)];
            [self.QRCodeView addGestureRecognizer:tapGesture];
        }
        
    } failure:^(NSError * _Nonnull error) {
        self.QRCodeImg.image = [UIImage imageNamed:@"InvalidQRCode"];
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadQRCode)];
        [self.QRCodeView addGestureRecognizer:tapGesture];
    }];
}

#pragma mark - 通过smartConfig过来的样式
- (void)setConfigUI
{
//    NSString *base64EncryptedStr = [WiFiConfigurationProtocol base64WifiCalculate:self.ssidNameStr andPwd:self.smartConfigWifiPwd];
//    self.qrCodeSucBtn.layer.cornerRadius = 20.f;
//    self.stepsContentLb.text = @"设备通电，听到“请为设备配置无线网络”提示音后，请将二维码对准摄像头；";
    self.stepsContentLb.text = NSLocalizedString(@"①保持约20cm的距离，等待扫描；", nil);
    self.stepsContentLb1.text = NSLocalizedString(@"②听到“扫描二维码成功”提示音后移开手机；", nil);
    self.stepsContentLb2.text = NSLocalizedString(@"③听到“WiFi连接成功”提示音后表示设备Wi-Fi配置已完成；", nil);
    self.stepsContentLb3.text = NSLocalizedString(@"④听到“成功接入云平台，配置完成，欢迎使用”提示音后表示设备添加成功。", nil);

    /**
     * description: GET v1/device/getQRcode（配二维码）
     * access_token=<令牌> & user_id =<用户ID>&ssid=<名称 >& password=<密码 >
     */
    
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    if (self.ssidNameStr) {
        [postDic setObject:self.ssidNameStr forKey:@"ssid"];
    }
    if (self.smartConfigWifiPwd) {
        [postDic setObject:self.smartConfigWifiPwd forKey:@"password"];
    }
    NSLog(@"postDic:%@",postDic);
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/getQRcode" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSString *base64EncryptedStr = responseObject[@"body"][@"imageData"];
            [self setUpQRCode:base64EncryptedStr];//根据字符串生成二维码
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lightScreen)];
            [self.QRCodeView addGestureRecognizer:tapGesture];
//            [self codeBtnTimeBegin];
            _timer =  [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(getDevStates) userInfo:nil repeats:YES];
            _actionTimer =  [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(actionBegin) userInfo:nil repeats:YES];
        }else{
            self.QRCodeImg.image = [UIImage imageNamed:@"InvalidQRCode"];
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadQRCode)];
            [self.QRCodeView addGestureRecognizer:tapGesture];
        }
        
    } failure:^(NSError * _Nonnull error) {
        self.QRCodeImg.image = [UIImage imageNamed:@"InvalidQRCode"];
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadQRCode)];
        [self.QRCodeView addGestureRecognizer:tapGesture];
    }];
    
    
//    [self setUpQRCode:base64EncryptedStr];//根据字符串生成二维码
}

- (IBAction)wifiConfigClick:(id)sender
{
//    [XHToast showCenterWithText:@"跳转至无线网络进行配置"];
    
     //开始配置去配置wifi
     WiFiSetController *wifiVc = [[WiFiSetController alloc]init];
     wifiVc.deveId = self.deveId;
     wifiVc.erialNumber = self.erialNumber;
     wifiVc.check_code = self.check_code;
     wifiVc.passStr = self.smartConfigWifiPwd;
     wifiVc.wifiName = self.ssidNameStr;
     wifiVc.device_imgUrl = self.device_imgUrl;
     [self.navigationController pushViewController:wifiVc animated:YES];
    
}

- (IBAction)qrCodeSucClick:(id)sender
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"是否已听到成功接入云平台？", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"否", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"是", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
//        [self.navigationController popToRootViewControllerAnimated:YES];

        RcodeShowController *RcodeShowVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
//        NSLog(@"self.navigationController.viewControllers.count:%lu",self.navigationController.viewControllers.count);
        RcodeShowVC.deveId = self.deveId;
        RcodeShowVC.erialNumber = self.erialNumber;
        RcodeShowVC.check_code = self.check_code;
        
        
        [self.navigationController popToViewController:RcodeShowVC animated:YES];
        
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (IBAction)connectFailClick:(id)sender
{
    HelpVC *helpVC = [[HelpVC alloc]init];
    BaseUrlModel *urlModel = [BaseUrlDefaults geturlModel];
    helpVC.url = urlModel.appHelpUrl;
    [self.navigationController pushViewController:helpVC animated:YES];
}


#pragma mark - 根据字符串生成二维码
- (void)setUpQRCode:(NSString *)Base64EncryptedStr
{
    self.QRCodeImg.image = [SGQRCodeTool SG_generateWithDefaultQRCodeData:Base64EncryptedStr imageViewWidth:1000.f];
}

#pragma mark ------ 验证码倒计时
- (void)codeBtnTimeBegin
{
    __block NSInteger time = 60; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(time <= 0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置按钮的样式
                [self.qrCodeSucBtn setTitle:NSLocalizedString(@"已使用二维码完成Wi-Fi配置", nil) forState:UIControlStateNormal];
                [self.qrCodeSucBtn setTitleColor:RGB(255, 255, 255) forState:UIControlStateNormal];
                self.qrCodeSucBtn.userInteractionEnabled = YES;
            });
            
        }else{
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置按钮显示读秒效果
                [self.qrCodeSucBtn setTitle:[NSString stringWithFormat:@"%ds", seconds] forState:UIControlStateNormal];
                [self.qrCodeSucBtn setTitleColor:RGB(255, 255, 255) forState:UIControlStateNormal];
                self.qrCodeSucBtn.userInteractionEnabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}


#pragma mark - 获取设备在线状态
- (void)getDevStates
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.erialNumber forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/getstatus" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"获取设备在线状态responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSDictionary *bodyDic = responseObject[@"body"];
            int isLine = [bodyDic[@"status"]intValue];
            if (isLine == 0) {
            }else{
                //在线了
                [self stopTimer];
                //设置按钮的样式
                [self.qrCodeSucBtn setTitle:NSLocalizedString(@"已使用二维码完成Wi-Fi配置", nil) forState:UIControlStateNormal];
                [self.qrCodeSucBtn setTitleColor:RGB(255, 255, 255) forState:UIControlStateNormal];
                self.qrCodeSucBtn.userInteractionEnabled = YES;
                [self cteateNavBtn];
                isBack = YES;
            }
        }
        
    } failure:^(NSError * _Nonnull error) {
    
    }];
}

- (void)actionBegin
{
    _i ++;
    if (_i/5 <= 60) {
        NSString * seconds = [NSString stringWithFormat:@"%d",60-_i/5];
        if ([seconds intValue] == 0) {
            //设置按钮的样式
            [self.qrCodeSucBtn setTitle:NSLocalizedString(@"已使用二维码完成Wi-Fi配置", nil) forState:UIControlStateNormal];
            [self.qrCodeSucBtn setTitleColor:RGB(255, 255, 255) forState:UIControlStateNormal];
            self.qrCodeSucBtn.userInteractionEnabled = YES;
            [self cteateNavBtn];
            isBack = YES;
        }else{
            //设置按钮显示读秒效果
            [self.qrCodeSucBtn setTitle:[NSString stringWithFormat:@"%@s",seconds] forState:UIControlStateNormal];
            [self.qrCodeSucBtn setTitleColor:RGB(255, 255, 255) forState:UIControlStateNormal];
            self.qrCodeSucBtn.userInteractionEnabled = NO;
        }
        
    }
}

#pragma mark - 结束定时器
- (void)stopTimer
{
    [_timer invalidate];   // 将定时器从运行循环中移除，
    _timer = nil;
    [_actionTimer invalidate];
    _actionTimer = nil;
}

- (void)returnVC
{
    if (isBack == YES) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
