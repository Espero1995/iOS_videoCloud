//
//  PushMsgModel.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/24.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushMsgModel : NSObject<NSCoding>
@property (nonatomic,copy)NSString *alarmId;//警告id
@property (nonatomic,copy)NSString *deviceId;//设备id
@property (nonatomic,copy)NSString *deviceName;//设备名
@property (nonatomic,assign)int alarmType;//警告类型
@property (nonatomic,assign)int alarmTime;//警告时间
@property (nonatomic,copy)NSString *alarmPic;//警告图片
@property (nonatomic,assign)BOOL markread;//是否已读
@property (nonatomic,copy)NSString *alarmVideo;//视频url
@end
