//
//  WiFiConfigurationProtocol.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/5/23.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WiFiConfigurationProtocol : NSObject

#pragma mark - 通过获取到WiFi的一些基本信息转二维码
+ (NSString *)base64WifiCalculate:(NSString *)ssidStr andPwd:(NSString *)pwdStr;
@end
