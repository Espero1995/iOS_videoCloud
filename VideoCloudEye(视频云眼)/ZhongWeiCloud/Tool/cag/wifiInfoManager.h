//
//  wifiInfoManager.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/5/15.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface wifiInfoManager : NSObject
//iOS获取当前手机WIFI名称信息
+ (NSString *)fetchSSIDInfo;
//获取网关等信息
+ (NSString *)getGatewayIpForCurrentWiFi;
/// 获取本机DNS服务器
+ (NSString *)outPutDNSServers;
//获取当前wifi ip地址
+ (NSString *)getIPAddress;

@end
