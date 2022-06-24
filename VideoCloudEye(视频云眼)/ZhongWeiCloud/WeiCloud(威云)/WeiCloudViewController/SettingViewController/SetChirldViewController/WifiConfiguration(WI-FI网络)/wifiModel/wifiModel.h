//
//  wifiModel.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/4/13.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface wifiModel : NSObject
/**
 * password
 */
@property (nonatomic, copy) NSString* password;
/**
 * wifi名称
 */
@property (nonatomic, copy) NSString* ssid;
/**
 * 信号强度
 ntensity： 信号强度，5档，从低到高依次为1-5
 */
@property (nonatomic, copy) NSString* intensity;
/**
 * 认证模式
 Auth： 认证模式，分为：0 - OPEN，1 - WEP，2 - WPA PSK/WPA2 PSK，3 - WPA/WPA2 WEP模式下，密码有效长度应为5-13，如果是2、3，密码长度是8-63
 
 注释：0是未加密，其他都是各种加密模式。
 */
@property (nonatomic, copy) NSString* auth;

/**
 * 该wifi是否正在使用中
 */
@property (nonatomic, copy) NSString* inuse;


- (void)setValue:(id)value forUndefinedKey:(NSString *)key;
@end
