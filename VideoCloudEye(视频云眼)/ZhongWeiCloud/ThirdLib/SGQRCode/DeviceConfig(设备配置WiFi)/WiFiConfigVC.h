//
//  WiFiConfigVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2019/3/18.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceConfigModel.h"//设备配置model
NS_ASSUME_NONNULL_BEGIN

@interface WiFiConfigVC : BaseViewController
/**
 * @brief 是否为二维码配置方式进行配置
 */
@property (nonatomic, assign) BOOL isQRCode;
/**
 * @brief 设备配置model
 */
@property (nonatomic, strong) DeviceConfigModel *configModel;

//=============仅smartConfig配置使用
/**
 * @brief wifi名称
 */
@property (nonatomic, strong) NSString *wifiNameStr;
/**
 * @brief wifi密码
 */
@property (nonatomic, strong) NSString *wifiPwdStr;


@end

NS_ASSUME_NONNULL_END
