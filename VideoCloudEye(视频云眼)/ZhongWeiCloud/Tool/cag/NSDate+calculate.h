//
//  NSDate+calculate.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/22.
//  Copyright © 2018年 张策. All rights reserved.
//



@interface NSDate (calculate)
//显示连续几天的方法

/**
 日期计算，返回当天的前某一天或者后某一天

 @param offset 偏移天数
 @param date 当前时间
 @return 当前时间之前或者之后的时间
 */
+ (NSDate *)offsetDay:(NSInteger)offset Date:(NSDate *)date;

/**
 当天时间归零方法(获取当天的零点零分)

 @return 返回当天的零点零分
 */
+ (NSDate *)zeroOfDate;

/**
 指定时间归零方法（获取指定时间的零点零分）

 @return 返回指定时间的零点零分
 */
+ (NSDate *)zeroOfSelectDate:(NSDate *)date;
@end
