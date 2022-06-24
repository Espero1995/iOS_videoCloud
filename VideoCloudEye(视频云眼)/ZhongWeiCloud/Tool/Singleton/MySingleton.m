//
//  MySingleton.m
//  app
//
//  Created by 张策 on 16/1/11.
//  Copyright © 2016年 ZC. All rights reserved.
//

#import "MySingleton.h"

static MySingleton *instan = nil;
@implementation MySingleton
+(instancetype) shareInstance
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instan = [[MySingleton alloc]init];
    });
    return instan;
}

@end
