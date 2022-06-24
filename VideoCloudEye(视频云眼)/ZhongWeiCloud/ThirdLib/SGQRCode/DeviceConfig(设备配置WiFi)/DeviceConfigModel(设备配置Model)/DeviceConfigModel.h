//
//  DeviceConfigModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2019/3/20.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceConfigModel : NSObject
/**
 * @brief 设备ID
 */
@property (nonatomic,copy)NSString *deviceId;
/**
 * @brief 设备类型
 */
@property (nonatomic,copy)NSString *deviceType;
/**
 * @brief 设备验证码
 */
@property (nonatomic,copy)NSString *checkCode;
/**
 * @brief 设备图片URL
 */
@property (nonatomic,copy)NSString *devImgURL;
/**
 * @brief 是否支持WiFi配置 1:表示支持l；其余均不支持
 */
@property (nonatomic,assign)int enableWifi;
@end

NS_ASSUME_NONNULL_END
