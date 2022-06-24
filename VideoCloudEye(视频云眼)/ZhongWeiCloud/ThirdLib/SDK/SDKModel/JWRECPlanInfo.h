//
//  JWRECPlanInfo.h
//  ZWCloudSdk
//
//  Created by 张策 on 17/4/12.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JWConstants.h"
/// 此类为录像计划对象
@interface JWRECPlanInfo : NSObject
/// 录像类型
@property (nonatomic, assign) JWRecVideoTypeStatus recViewoType;
/// 开始，停止录像状态
@property (nonatomic, assign) JWRecVideoEnableTypeStatus enable;
/// 录像开始时间 格式HH:MM 如08:30
@property (nonatomic, copy) NSString *start_time;
/// 录像结束时间 格式HH:MM 如16:30
@property (nonatomic, copy) NSString *stop_time;
/// 录像周期 重复周期，如”1,2,3,4,5”， 表示周一到周五
@property (nonatomic, copy) NSString *period;
@end
