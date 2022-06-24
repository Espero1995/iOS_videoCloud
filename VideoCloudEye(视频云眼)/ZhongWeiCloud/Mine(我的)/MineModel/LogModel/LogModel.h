//
//  LogModel.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/9/26.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogModel : NSObject
@property (nonatomic,copy)NSArray * opLogList;
@end
@interface opLogList : NSObject;

@property (nonatomic,copy)NSString * user_id;//id
@property (nonatomic,copy)NSString * op;//操作名称
@property (nonatomic,copy)NSString * content;//操作内容
@property (nonatomic,copy)NSString * ip;//访问ip
@property (nonatomic,copy)NSString * log_time;//操作时间

@end
