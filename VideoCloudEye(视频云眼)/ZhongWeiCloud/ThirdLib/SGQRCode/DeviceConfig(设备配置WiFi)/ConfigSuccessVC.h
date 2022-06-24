//
//  ConfigSuccessVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2019/3/19.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceConfigModel.h"//设备配置model
NS_ASSUME_NONNULL_BEGIN

@interface ConfigSuccessVC : BaseViewController
/**
 * @brief 设备配置model
 */
@property (nonatomic, strong) DeviceConfigModel *configModel;

@end

NS_ASSUME_NONNULL_END
