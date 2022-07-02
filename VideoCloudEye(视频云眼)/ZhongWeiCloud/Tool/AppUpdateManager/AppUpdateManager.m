//
//  AppUpdateManager.m
//  ZhongWeiCloud
//
//  Created by 王攀登 on 2022/7/2.
//  Copyright © 2022 苏旋律. All rights reserved.
//

#import "AppUpdateManager.h"
#import "NSStringEX.h"

@implementation AppUpdateManager

+ (void)checkAppUpdateComplete:(void(^)(void))complete {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:app_type forKey:@"app_type"];
    [dic setObject:APPVERSION forKey:@"app_ver"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/app/checkversion" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSDictionary *updataBody = responseObject[@"body"];

        if (updataBody && [updataBody isKindOfClass:NSDictionary.class]) {
            NSString *version = updataBody[@"version"];
            if (![version isEmpty]) {
                NSArray *arr = [version componentsSeparatedByString:@"("];
                if (arr.count > 0) {
                    version = arr.firstObject;
                }
                version = [version stringByReplacingOccurrencesOfString:@"." withString:@""];
                NSString *currentV = [APPVERSION stringByReplacingOccurrencesOfString:@"." withString:@""];
                if (version.integerValue > currentV.integerValue) {
                    complete();
                }
            }
        }
 
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"网络正在开小差...");
    }];
}

@end
