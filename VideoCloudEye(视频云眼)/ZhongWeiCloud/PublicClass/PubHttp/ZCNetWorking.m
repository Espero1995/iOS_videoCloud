//
//  ZCNetWorking.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/3/30.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "ZCNetWorking.h"
static ZCNetWorking *instan = nil;

@implementation ZCNetWorking
+(instancetype) shareInstance
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instan = [[ZCNetWorking alloc]init];
    });
    return instan;
}
@end
