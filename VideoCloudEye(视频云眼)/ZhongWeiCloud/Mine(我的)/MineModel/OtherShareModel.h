//
//  OtherShareModel.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/10.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OtherShareModel : NSObject

@property (nonatomic,copy)NSArray * others_shared;

@end
@interface others_shared : NSObject

@property (nonatomic,copy)NSString * ID;//id
@property (nonatomic,copy)NSString * chan_size;//通道数
@property (nonatomic,copy)NSString * name;//设备名称
@property (nonatomic,copy)NSString * status;//设备状态
@property (nonatomic,copy)NSString * owner_id;//共享用户的id
@property (nonatomic,copy)NSString * owner_name;//共享用户的用户名
@property (nonatomic,copy)NSString * vsample;//设备图片
@property (nonatomic,copy)NSString * type;//设备型号

@end
