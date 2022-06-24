//
//  WiFiSetController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/3/20.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "WiFiSetController.h"

//wifi
#import "BonjourBrowser.h"
#import "SimpleWifi.h"
#import <SystemConfiguration/CaptiveNetwork.h>

//sadp
#import "SadpNew.h"

@interface WiFiSetController ()
<
    BonjourBrowserDelegate
>
@property (nonatomic,strong)SimpleWifi *simpleWifi;
@property (nonatomic,strong)BonjourBrowser *bonjour;
@end

@implementation WiFiSetController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    self.title = @"Wi-Fi配置";
    [self createUI];
    
}
- (void)createUI{
    //图标
    UIImageView * logoImage = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 75, 75) imageName:@"wifi2"];
    [self.view addSubview:logoImage];
    [logoImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(101.5);
        make.left.equalTo(self.view.mas_left).offset(iPhoneWidth/2-37.5);
        make.right.equalTo(self.view.mas_left).offset(iPhoneWidth/2+37.5);
    }];
    //点1
    UIImageView * pointImage1 = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 6, 6) imageName:@"link1"];
    [self.view addSubview:pointImage1];
    [pointImage1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(iPhoneWidth/2-3);
        make.top.equalTo(logoImage.mas_bottom).offset(10);
    }];
    //点2
    UIImageView * pointImage2 = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 6, 6) imageName:@"link2"];
    [self.view addSubview:pointImage2];
    [pointImage2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(pointImage1.mas_left).offset(0);
        make.top.equalTo(pointImage1.mas_bottom).offset(5);
    }];
    //点3
    UIImageView * pointImage3 = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 6, 6) imageName:@"link1"];
    [self.view addSubview:pointImage3];
    [pointImage3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(pointImage2.mas_left).offset(0);
        make.top.equalTo(pointImage2.mas_bottom).offset(5);
    }];
    //图片
    UIImageView * pictureImage = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 75, 100) imageName:@"pic"];
    [self.view addSubview:pictureImage];
    [pictureImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(logoImage.mas_left).offset(0);
        make.top.equalTo(pointImage3.mas_bottom).offset(5);
    }];
    //提示信息
    UILabel * label = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 240, 40) text:nil font:[UIFont systemFontOfSize:16]];
    label.text = @"正在发送Wi-Fi信息,请耐心等待知道听到配置成功的语音提示";
    label.textColor = [UIColor colorWithHexString:@"#020202"];
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.numberOfLines = 2;
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(iPhoneWidth/2-120);
        make.top.equalTo(pictureImage.mas_bottom).offset(31);
        make.right.equalTo(self.view.mas_left).offset(iPhoneWidth/2+120);
        
        
    }];
    
    //按钮
    UIButton * button = [FactoryUI createButtonWithFrame:CGRectMake(0, 0, 240, 35) title:@"我已听到注册成功提示" titleColor:[UIColor whiteColor] imageName:nil backgroundImageName:nil target:self selector:nil];
    button.backgroundColor = [UIColor colorWithHexString:@"#38adff"];
    button.layer.cornerRadius = 17.5;
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(iPhoneWidth/2-120);
        make.top.equalTo(label.mas_bottom).offset(20);
        make.right.equalTo(self.view.mas_left).offset(iPhoneWidth/2+120);
        
        
    }];

}
#pragma mark ------smartWifi开始
- (void)startWifiWithPassStr:(NSString *)passStr{
    //wifi配置
        NSString *wifiStr = [self getWifiName];
        NSLog(@"wifiName=====%@",wifiStr);
        _simpleWifi = [[SimpleWifi alloc] init];
        [_simpleWifi StartWifiConfig:wifiStr andKey:passStr];
        _bonjour = [[BonjourBrowser alloc] initForType:@"_http._tcp." inDomain:@"local" timeout:BONJOURSEARCH_DEFAULT_TIMEOUT];	//这里的参数是有宏定义的
        _bonjour.delegate = self;
        [_bonjour startBonjour];
}
/**
 *   完成搜索
 *
 *  @param arrBonjourServer 设备信息集合
 */
- (void)finishSearchBonjourServer:(NSArray *)arrBonjourServer
{
        for (NSString * name in arrBonjourServer)
        {
            //        NSRange range = [name rangeOfString:self.strSn];
            NSRange range = [name rangeOfString:self.erialNumber];
    
            if (range.length != 0)
            {
                range = [name rangeOfString:@"&WIFI"];
                if (range.length != 0)
                {
                    // WIFI连接成功，关闭Wi-Fi配置，处理成功后续操作
                    [_simpleWifi StopWifiConfig];
                    [_bonjour stopBonjour];
                    [self successAdd];
                }
                else
                {
                    range = [name rangeOfString:@"&PLAT"];
                    if (range.length != 0)
                    {
                        // WIFI连接成功，关闭Wi-Fi配置，处理成功后续操作
                        [_simpleWifi StopWifiConfig];
                        [_bonjour stopBonjour];
                        [self successAdd];
                    }
                }
            }
        }
    
}

/**
 *  bonjour搜索超时
 */
- (void)TimeourSearchBonjourServer
{
    // 超时代表在时间内未收到设备返回，认为失败，显示失败界面
        [_simpleWifi StopWifiConfig];
        [_bonjour stopBonjour];
    [self failureAdd];
}

#pragma mark ------得到当前wifi名称
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
