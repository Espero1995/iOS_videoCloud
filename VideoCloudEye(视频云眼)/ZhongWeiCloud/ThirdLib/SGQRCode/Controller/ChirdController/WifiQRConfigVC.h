//
//  WifiQRCodeVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/5/28.
//  Copyright © 2018年 张策. All rights reserved.
//


@interface WifiQRConfigVC : BaseViewController
//获取到的ssid名称
@property (nonatomic,copy) NSString *ssidNameStr;
//密码
@property (nonatomic,copy) NSString *smartConfigWifiPwd;

//给WiFi网络配置方式要传递的参数
//设备型号
@property (nonatomic,copy)NSString *deveId;
//设备序列号
@property (nonatomic,copy)NSString *erialNumber;
//验证码
@property (nonatomic,copy)NSString *check_code;
//图片URL
@property (nonatomic,copy)NSString *device_imgUrl;

@end
