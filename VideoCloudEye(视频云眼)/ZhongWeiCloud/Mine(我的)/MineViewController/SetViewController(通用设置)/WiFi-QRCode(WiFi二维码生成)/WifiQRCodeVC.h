//
//  WifiQRCodeVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/5/28.
//  Copyright © 2018年 张策. All rights reserved.
//


@interface WifiQRCodeVC : BaseViewController
//获取到的ssid名称
@property (nonatomic,copy) NSString *ssidNameStr;
//根据长度修改过的ssid名称
@property (nonatomic,copy) NSString *ModifySSIDNameStr;
//这个是从smartConfig配置过来的参数
@property (nonatomic,copy) NSString *smartConfigWifiPwd;
@end
