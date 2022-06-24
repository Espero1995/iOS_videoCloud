//
//  OtherShareModel.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/10.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "OtherShareModel.h"

@implementation OtherShareModel

+ (NSDictionary *)objectClassInArray
{
    return @{
             @"others_shared" : @"others_shared"
             };
}

@end
@implementation others_shared


+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"ID": @"id"};
}


@end
