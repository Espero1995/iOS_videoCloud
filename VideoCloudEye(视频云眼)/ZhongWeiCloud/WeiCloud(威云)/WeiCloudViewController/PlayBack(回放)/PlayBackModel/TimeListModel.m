//
//  TimeListModel.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/22.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "TimeListModel.h"

@implementation TimeListModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"histList": @"his_recs"};
}
+ (NSDictionary *)objectClassInArray
{
    return @{
             @"histList" : @"HisTimeListModel"
             };
}
@end

@implementation HisTimeListModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"uBeginTime": @"start_time",
             @"uEndTime": @"stop_time"};
}


@end
