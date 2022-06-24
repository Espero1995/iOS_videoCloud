//
//  UserInfo.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/9/17.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
+(UserInfo *)sharedInstance
{
    //声明一个静态变量，确保单例类的实例在整个APP中只有一个，而且是唯一的
    static UserInfo *_sharedInstance = nil;
    //声明一个静态变量，确保这个类的实例创建过程只创建一次
    static dispatch_once_t onceToken;
    //通过Grand Central Dispatch（GCD），执行一个Block，用来初始化单例类的实例
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[UserInfo alloc]init];
    });
    return _sharedInstance;
}
@end
