//
//  UserInfo.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/9/17.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject
@property (nonatomic,copy) NSString *userName;//用户名
//单例类方法，称之为构造方法
+ (UserInfo *)sharedInstance;
@end
