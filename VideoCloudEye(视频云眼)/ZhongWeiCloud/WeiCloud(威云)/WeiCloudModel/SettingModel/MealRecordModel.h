//
//  MealRecordModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2017/12/6.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MealRecordModel : NSObject
//套餐记录id
@property (nonatomic,copy) NSString *Oid;
//保留时间
@property (nonatomic,assign) int saving_days;
//id ？？
@property (nonatomic,copy) NSString *Uid;
//设备id
@property (nonatomic,copy) NSString *device_id;
//套餐信息
@property (nonatomic,copy) NSString *plan_info;
//套餐id
@property (nonatomic,copy) NSString *plan_id;
//起始时间
@property (nonatomic,assign) int start_date;
//截止时间
@property (nonatomic,assign) int stop_date;
@end
