//
//  JWGuardPlan.h
//  ZWCloudSdk
//
//  Created by 张策 on 17/4/12.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JWConstants.h"
/// 此类为布防信息对象
@interface JWGuardPlanInfo : NSObject
/// 告警类型
@property (nonatomic, assign) JWAlarmTypesStatus alarmType;
/// 布防、撤防类型
@property (nonatomic, assign) JWDefenceStatus enable;
/// 布防开始时间 格式HH:MM 如08:30
@property (nonatomic, copy) NSString *start_time;
/// 布防结束时间 格式HH:MM 如16:30
@property (nonatomic, copy) NSString *stop_time;
/// 布防周期 重复周期，如”1,2,3,4,5”， 表示周一到周五
@property (nonatomic, copy) NSString *period;

@end
