//
//  NSDate+calculate.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/22.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "NSDate+calculate.h"

@implementation NSDate (calculate)

+ (NSDate *)offsetDay:(NSInteger)offset Date:(NSDate *)date
{
    NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
    dateComponents.day = offset;
    NSDate* newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

+ (NSDate *)zeroOfDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:[NSDate date]];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    // components.nanosecond = 0 not available in iOS
    NSTimeInterval ts = (double)(int)[[calendar dateFromComponents:components] timeIntervalSince1970];
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:ts];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return localeDate;
}

+ (NSDate *)zeroOfSelectDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:date];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    // components.nanosecond = 0 not available in iOS
    NSTimeInterval ts = (double)(int)[[calendar dateFromComponents:components] timeIntervalSince1970];
    NSDate * date1 = [NSDate dateWithTimeIntervalSince1970:ts];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date1];
    NSDate *localeDate = [date1  dateByAddingTimeInterval: interval];
    return localeDate;
}
@end
