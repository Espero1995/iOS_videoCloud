//
//  JWGuardConfigList.m
//  ZWCloudSdk
//
//  Created by 张策 on 17/4/13.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "JWGuardConfigList.h"
#import "MJExtension.h"
@implementation JWGuardConfigList
+ (NSDictionary *)mj_objectClassInArray{
    return @{ @"guardConfigList" : @"JWGuardPlanInfo"
              };
}
@end
