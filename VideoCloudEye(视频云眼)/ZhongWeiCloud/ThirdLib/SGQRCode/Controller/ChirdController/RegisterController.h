//
//  RegisterController.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/3/17.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "BaseViewController.h"

@interface RegisterController : BaseViewController
//wifi密码
@property (nonatomic,copy)NSString *passStr;
//设备型号
@property (nonatomic,copy)NSString *deveId;
//设备序列号
@property (nonatomic,copy)NSString *erialNumber;
//验证码
@property (nonatomic,copy)NSString *check_code;
//图片URL
@property (nonatomic,copy)NSString *device_imgUrl;
@end
