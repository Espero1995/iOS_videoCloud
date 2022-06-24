//
//  MealTypeModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2017/12/4.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MealTypeModel : NSObject
//套餐id
@property (nonatomic,copy) NSString *Pid;
//费用
@property (nonatomic,copy) NSString *fee;
//打折后的费用
@property (nonatomic,copy) NSString *discount_fee;
//套餐信息
@property (nonatomic,copy) NSString *plan_info;
//套餐类型 1:月套餐   2：年套餐
@property (nonatomic,assign) int plan_type;
//录像保留天数
@property (nonatomic,assign) int saving_days;
//状态
@property (nonatomic,assign) int status;
//subject？？？
@property (nonatomic,copy) NSString *subject;

@end
