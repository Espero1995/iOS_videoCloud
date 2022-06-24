//
//  RcodeShowController.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/24.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "BaseViewController.h"

@interface RcodeShowController : BaseViewController
//设备型号
@property (weak, nonatomic) IBOutlet UILabel *lab_deveId;
//设备序列号
@property (weak, nonatomic) IBOutlet UILabel *lab_erialNumber;

@property (nonatomic,copy)NSString *deveId;
@property (nonatomic,copy)NSString *erialNumber;
//验证码
@property (nonatomic,copy)NSString *check_code;
@end
