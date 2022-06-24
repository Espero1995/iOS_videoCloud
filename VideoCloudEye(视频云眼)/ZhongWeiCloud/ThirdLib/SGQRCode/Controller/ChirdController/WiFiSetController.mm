//
//  WiFiSetController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/3/20.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "WiFiSetController.h"
#import "ZCTabBarController.h"
#import "RegisterController.h"
#import "BindingController.h"
#import "MSWeakTimer.h"

#import <SystemConfiguration/CaptiveNetwork.h>

//sadp
#import "Sadp.h"

//smart_config
#import "jw_smart_config.h"

#import "device_discovery.h"

#define countTimeText @"120";
//序列号
const char *charErialNumber;
//密码
const char *sCommand;
//cself
static WiFiSetController *cSelf = nil;

@interface WiFiSetController ()
{
    int secondsCountDown; //倒计时总时长
    NSTimer *countDownTimer;
}
@property (nonatomic,strong)MSWeakTimer *actionTimer;
@property (nonatomic,strong)UIImageView * pointImage1;
@property (nonatomic,strong)UIImageView * pointImage2;
@property (nonatomic,strong)UIImageView * pointImage3;
@property (nonatomic,assign)int i;
@property (nonatomic,strong)UIView  * bgView;//倒计时圆点背景
@property (nonatomic,strong)UILabel * countTime;//倒计时

@end

@implementation WiFiSetController



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    cSelf = self;
//    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"vender"]) {
//        NSInteger  str = [[[NSUserDefaults standardUserDefaults]objectForKey:@"vender"] integerValue];
//        if (str == 1) {// 0 海康  1 自研
//            cSelf.bIsOwnDevice = YES;
//        }
//    }
    JWDeviceDiscovery_setAutoRequestInterval(5);
//    JWDeviceDiscovery_start(deviceFindCallBack);
    
    _actionTimer = [MSWeakTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(actionBegin) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
   
    [self startWifiWithPassStr:self.passStr];
    
    
    //设置倒计时总时长
    secondsCountDown = 120;
    //开始倒计时
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES]; //启动倒计时后会每秒钟调用一次方法 timeFireMethod

}
-(void)timeFireMethod{
    //倒计时-1
    secondsCountDown--;
    dispatch_async(dispatch_get_main_queue(),^{
        self.countTime.text = [NSString stringWithFormat:@"%d",secondsCountDown];
    });
    //当倒计时到0时，做需要的操作，比如验证码过期不能提交
    if(secondsCountDown==0){
        [countDownTimer invalidate];
        [self TimeourSearchBonjourServer];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    [self stopTimer];
    
    JWSmart_stop();
    JWDeviceDiscovery_stop();
    JWDeviceDiscovery_clearup();
}
//void deviceFindCallBack (const JWDeviceInfo& deviceInfo){
//    
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"erialNumber"]) {
//        const char * erialNumberCharStr = [[[NSUserDefaults standardUserDefaults] objectForKey:@"erialNumber"] UTF8String];
//        const char * lpDeviceInfoNumberCharStr = deviceInfo.serial;
//        
//        NSString * erialNumberStr = [[NSString alloc] initWithUTF8String:erialNumberCharStr];
//        NSString * lpDeviceInfoNumberStr = [[NSString alloc] initWithUTF8String:lpDeviceInfoNumberCharStr];
//        
//        NSLog(@"自研对比设备序列号：扫码：%@ ===函数回调：%@",erialNumberStr,lpDeviceInfoNumberStr);
//        if ([erialNumberStr isEqualToString: lpDeviceInfoNumberStr]) {
//               dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    [cSelf activeDevce];
//                });
//        }
//    }
//}

/*
void sadpCallFunc(const SADP_DEVICE_INFO *lpDeviceInfo, void *pUserData){
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"erialNumber"]) {
        const char * erialNumberCharStr = [[[NSUserDefaults standardUserDefaults] objectForKey:@"erialNumber"] UTF8String];
        const char * lpDeviceInfoNumberCharStr = lpDeviceInfo->szSerialNO;
        
        NSString * erialNumberStr = [[NSString alloc] initWithUTF8String:erialNumberCharStr];
        NSString * lpDeviceInfoNumberStr = [[NSString alloc] initWithUTF8String:lpDeviceInfoNumberCharStr];

        NSLog(@"对比设备序列号：扫码：%@ ===函数回调：%@",erialNumberStr,lpDeviceInfoNumberStr);
        if ([erialNumberStr isEqualToString: lpDeviceInfoNumberStr]) {
            charErialNumber = lpDeviceInfo->szSerialNO;
            if (lpDeviceInfo->byActivated == 1) {
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [cSelf activeDevce];
                });
            }
            if (lpDeviceInfo->byActivated == 0) {
                
                SADP_Stop();
            }
        }
    }
}
 */

- (void)activeDevce
{
    JWDeviceDiscovery_stop();
    JWDeviceDiscovery_clearup();
    dispatch_sync(dispatch_get_main_queue(), ^{
        RegisterController *regisVc = [[RegisterController alloc]init];
        regisVc.passStr = self.passStr;
        regisVc.deveId = self.deveId;
        regisVc.erialNumber = self.erialNumber;
        regisVc.check_code = self.check_code;
        regisVc.device_imgUrl = self.device_imgUrl;//图片url
        [self.navigationController pushViewController:regisVc animated:YES];
    });
}

- (void)pushRegistVc
{
    RegisterController *regisVc = [[RegisterController alloc]init];
    regisVc.passStr = self.passStr;
    regisVc.deveId = self.deveId;
    regisVc.erialNumber = self.erialNumber;
    regisVc.check_code = self.check_code;
    regisVc.device_imgUrl = self.device_imgUrl;//图片url
    [self.navigationController pushViewController:regisVc animated:YES];
     JWDeviceDiscovery_stop();
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    self.title = NSLocalizedString(@"正在配置Wi-Fi", nil);
    sCommand =[self.check_code cStringUsingEncoding:NSASCIIStringEncoding];
    [self cteateNavBtn];
    [self createUI];
    JWDeviceDiscovery_init();
}

//
- (void)returnVC
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"配置设备时间较长，请耐心等待", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"继续等待", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"仍然退出", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}



- (void)createUI{

    //图标
    UIImageView * logoImage = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 75, 75) imageName:@"wifi2"];
    [self.view addSubview:logoImage];
    [logoImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(100);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    //点1
    _pointImage1 = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 6, 6) imageName:@"link1"];
    [self.view addSubview:_pointImage1];
    [_pointImage1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(iPhoneWidth/2-3);
        make.top.equalTo(logoImage.mas_bottom).offset(10);
    }];
    //点2
    _pointImage2 = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 6, 6) imageName:@"link1"];
    [self.view addSubview:_pointImage2];
    [_pointImage2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_pointImage1.mas_left).offset(0);
        make.top.equalTo(_pointImage1.mas_bottom).offset(5);
    }];
    //点3
    _pointImage3 = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 6, 6) imageName:@"link1"];
    [self.view addSubview:_pointImage3];
    [_pointImage3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_pointImage2.mas_left).offset(0);
        make.top.equalTo(_pointImage2.mas_bottom).offset(5);
    }];
    //图片
    UIImageView *pictureImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    [pictureImage sd_setImageWithURL:[NSURL URLWithString:self.device_imgUrl] placeholderImage:[UIImage imageNamed:@"CloudPic"]];
    
    [self.view addSubview:pictureImage];
    [pictureImage mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(logoImage.mas_left).offset(0);
        make.top.equalTo(_pointImage3.mas_bottom).offset(5);
        make.centerX.equalTo(_pointImage3.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    //提示信息
    UILabel * label = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 240, 40) text:nil font:[UIFont systemFontOfSize:16]];
    label.text = NSLocalizedString(@"正在配置Wi-Fi信息,请耐心等待...", nil);
    label.textColor = [UIColor colorWithHexString:@"#020202"];
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.numberOfLines = 2;
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(iPhoneWidth/2-120);
        make.top.equalTo(pictureImage.mas_bottom).offset(31);
        make.right.equalTo(self.view.mas_left).offset(iPhoneWidth/2+120);
    }];
    
    [self.view addSubview:self.bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(label.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [self.bgView addSubview:self.countTime];
    [self.countTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.bgView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
//    //按钮
//    UIButton * button = [FactoryUI createButtonWithFrame:CGRectMake(0, 0, 240, 35) title:@"我已听到注册成功提示" titleColor:[UIColor whiteColor] imageName:nil backgroundImageName:nil target:self selector:nil];
//    button.backgroundColor = [UIColor colorWithHexString:@"#38adff"];
//    button.layer.cornerRadius = 17.5;
//    button.titleLabel.font = [UIFont systemFontOfSize:16];
//    [self.view addSubview:button];
//    [button mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view.mas_left).offset(iPhoneWidth/2-120);
//        make.top.equalTo(label.mas_bottom).offset(20);
//        make.right.equalTo(self.view.mas_left).offset(iPhoneWidth/2+120); 
//    }];

}
- (void)actionBegin{
    _i ++;
    if (_i%3 == 1) {
        _pointImage1.image = [UIImage imageNamed:@"link2"];
        _pointImage2.image = [UIImage imageNamed:@"link1"];
        _pointImage3.image = [UIImage imageNamed:@"link1"];
    }else if (_i%3 == 2){
        _pointImage2.image = [UIImage imageNamed:@"link2"];
        _pointImage1.image = [UIImage imageNamed:@"link1"];
        _pointImage3.image = [UIImage imageNamed:@"link1"];
    }else if (_i%3 == 0){
        _pointImage3.image = [UIImage imageNamed:@"link2"];
        _pointImage1.image = [UIImage imageNamed:@"link1"];
        _pointImage2.image = [UIImage imageNamed:@"link1"];
    }
}
#pragma mark ------smartWifi开始
- (void)startWifiWithPassStr:(NSString *)passStr{
    //wifi配置
        const char * wifiStr = [self getWifiName];
    NSLog(@"wifiName=====%s  wifi密码：%@",wifiStr,passStr);
//    NSLog(@"wifiName16jinzhi :%s",wifiStr);
  
    size_t str_len = strlen(wifiStr);
    for (int i = 0; i < str_len; ++i) {
        NSLog(@"wifiName16jinzhi :%x",wifiStr[i]);
    }
    // const char * wifiCharStr = [wifiStr UTF8String];
    const char * passCharStr = [passStr UTF8String];
    
    NSLog(@"smartConfig配置const char * passCharStr：%s==",passCharStr);
    BOOL ConfigSuccess = JWSmart_config(wifiStr,passCharStr,5,0);
    if (ConfigSuccess) {
        NSLog(@"smartConfig配置成功");
    }else{
        NSLog(@"smartConfig配置失败");
    }
}
/**
 *   完成搜索
 *
 *  @param arrBonjourServer 设备信息集合
 */
//- (void)finishSearchBonjourServer:(NSArray *)arrBonjourServer
//{
//        for (NSString * name in arrBonjourServer)
//        {
//            //        NSRange range = [name rangeOfString:self.strSn];
//            NSRange range = [name rangeOfString:self.erialNumber];
//
//            if (range.length != 0)
//            {
//                range = [name rangeOfString:@"&WIFI"];
//                if (range.length != 0)
//                {
//                    // WIFI连接成功，关闭Wi-Fi配置，处理成功后续操作
//                    [_simpleWifi StopWifiConfig];
//                    [_bonjour stopBonjour];
//                }
//                else
//                {
//                    range = [name rangeOfString:@"&PLAT"];
//                    if (range.length != 0)
//                    {
//                        // WIFI连接成功，关闭Wi-Fi配置，处理成功后续操作
//                        [_simpleWifi StopWifiConfig];
//                        [_bonjour stopBonjour];
//                    }
//                }
//            }
//        }
//}

/**
 *  bonjour搜索超时
 */
- (void)TimeourSearchBonjourServer
{
    // 超时代表在时间内未收到设备返回，认为失败，显示  A失败界面
    JWDeviceDiscovery_stop();
    JWDeviceDiscovery_clearup();
    JWSmart_stop();
    [self failureAdd];
}

- (void)failureAdd
{
    BindingController *bindVc = [[BindingController alloc]init];
    bindVc.device_imgUrl = self.device_imgUrl;//图片url
    bindVc.wifiPwd = self.passStr;
    bindVc.deviceTypeName = self.deveId;
    bindVc.wifiName = self.wifiName;
    [self.navigationController pushViewController:bindVc animated:YES];
}

#pragma mark ------得到当前wifi名称
- (const char *)getWifiName
{
    const char * wifiName = nil;
    
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
            wifiName = [[networkInfo objectForKey:(__bridge NSString*)kCNNetworkInfoKeySSID] UTF8String];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark ------结束定时器
- (void)stopTimer
{
    [_actionTimer invalidate];
    _actionTimer = nil;
}

- (void)dealloc{

}

- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = MAIN_COLOR;
        _bgView.layer.masksToBounds = YES;
        _bgView.layer.cornerRadius = 20;
    }
    return _bgView;
}

- (UILabel *)countTime
{
    if (!_countTime) {
        _countTime = [[UILabel alloc]init];
        _countTime.text = countTimeText;
        _countTime.textAlignment = NSTextAlignmentCenter;
        _countTime.textColor = [UIColor whiteColor];
    }
    return _countTime;
}

@end
