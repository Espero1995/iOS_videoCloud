//
//  ConfigOccupiedVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2019/3/20.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import "BaseViewController.h"
#import "DeviceConfigModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ConfigOccupiedVC : BaseViewController
/**
 * @brief 设备配置model
 */
@property (nonatomic, strong) DeviceConfigModel *configModel;
@end

NS_ASSUME_NONNULL_END
