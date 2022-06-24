//
//  ConnectWiFiVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2019/3/18.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceConfigModel.h"//设备配置model
NS_ASSUME_NONNULL_BEGIN

@interface ConnectWiFiVC : BaseViewController
/**
 * @brief 是否为二维码配置方式进行配置
 */
@property (nonatomic, assign) BOOL isQRCode;
/**
 * @brief 设备配置model
 */
@property (nonatomic, strong) DeviceConfigModel *configModel;
@end

NS_ASSUME_NONNULL_END
