//
//  QRCodeConfigVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2019/3/18.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceConfigModel.h"//设备配置model
NS_ASSUME_NONNULL_BEGIN

@interface QRCodeConfigVC : BaseViewController
/**
 * @brief 设备配置model
 */
@property (nonatomic, strong) DeviceConfigModel *configModel;
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
