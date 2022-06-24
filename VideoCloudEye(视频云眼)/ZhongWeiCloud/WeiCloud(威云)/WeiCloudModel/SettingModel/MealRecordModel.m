//
//  MealRecordModel.m
//  ZhongWeiCloud
//
//  Created by Espero on 2017/12/6.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "MealRecordModel.h"

@implementation MealRecordModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"Uid": @"id"};
}
@end
