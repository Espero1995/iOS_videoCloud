//
//  BindingController.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/3/20.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "BaseViewController.h"

@interface BindingController : BaseViewController
//图片URL
@property (nonatomic,copy) NSString *device_imgUrl;
//wifiPwd
@property (nonatomic,copy) NSString *wifiPwd;
//设备类型名称
@property (nonatomic,copy) NSString *deviceTypeName;
//WiFi名称
@property (nonatomic,copy) NSString *wifiName;
@end
