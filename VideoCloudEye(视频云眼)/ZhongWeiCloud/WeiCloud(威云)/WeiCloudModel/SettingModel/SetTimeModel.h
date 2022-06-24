//
//  SetTimeModel.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/3/2.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetTimeModel : NSObject

@property (nonatomic,copy) NSArray * guardConfigList;

@end

@interface guardConfigList : NSObject

@property (nonatomic,assign) int  alarmType;

@property (nonatomic,assign) int  enable;

@property (nonatomic,copy) NSString * start_time;

@property (nonatomic,copy) NSString * stop_time;

@property (nonatomic,copy) NSString * period;

@property (nonatomic, copy) NSString* silentMode;/**< 标记是否在家模式 */


@end
