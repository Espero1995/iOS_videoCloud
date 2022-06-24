//
//  UserModel.m
//  YouzaniOSDemo
//
//  Created by 可乐 on 16/10/13.
//  Copyright © 2016年 Youzan. All rights reserved.
//

#import "yzUserModel.h"

static NSString *userA = @"123456";
static NSString *userB = @"1234567";

@implementation yzUserModel

+ (instancetype)sharedManage {
    static yzUserModel *shareManage = nil;
    static dispatch_once_t once;
    dispatch_once(&once,^{
        shareManage = [[self alloc] init];
        [shareManage resetUserValue];
    });
    return shareManage;
}

- (void)resetUserValue {
    self.userId = userA;
}

+ (void)changeUserId {
    yzUserModel *model = [yzUserModel sharedManage];
    if ([model.userId isEqualToString:userA]) {
        model.userId = userB;
    } else {
        model.userId = userA;
    }
}


@end

