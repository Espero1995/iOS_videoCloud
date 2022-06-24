//
//  CloudStorageValueModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/25.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudStorageValueModel : NSObject
/*套餐计划ID*/
@property(nonatomic,copy) NSString *ID;
/*通道数*/
@property (nonatomic,assign)int chan_id;
/*套餐信息*/
@property(nonatomic,copy) NSString *plan_info;
/*套餐ID*/
@property(nonatomic,copy) NSString *plan_id;
/*套餐开始时间*/
@property(nonatomic,copy) NSString *start_date;
/*套餐结束时间*/
@property(nonatomic,copy) NSString *stop_date;
/*用户id*/
@property(nonatomic,copy) NSString *user_id;
/*订单id*/
@property(nonatomic,copy) NSString *order_id;
/*推荐方法*/
@property(nonatomic,copy) NSString *rec_method;
/*保存天数*/
@property(nonatomic,assign) int saving_days;
/*图片*/
@property(nonatomic,copy) NSString *dev_image;
/*设备id*/
@property(nonatomic,copy) NSString *device_id;
/*设备名*/
@property(nonatomic,copy) NSString *dev_name;
/*通道ID*/
@property(nonatomic,copy) NSString *chan_code;
@end
