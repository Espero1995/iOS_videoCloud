//
//  SXLReachability.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/3/21.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "SXLReachability.h"
#import "AFNetworkReachabilityManager.h"
#import <netdb.h>
#import <sys/socket.h>
#import <SystemConfiguration/SCNetworkReachability.h>

@implementation SXLReachability
+ (void)SXL_hasNetwork:(void(^)(ReachabilityStatus netStatus))netStatus
{
    //创建网络监听对象
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    //开始监听
    [manager startMonitoring];
    //监听改变
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                netStatus(ReachabilityStatusUnknown);
                break;
            case AFNetworkReachabilityStatusNotReachable:
                netStatus(ReachabilityStatusNotReachable);
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                netStatus(ReachabilityStatusReachableViaWWAN);
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                netStatus(ReachabilityStatusReachableViaWiFi);
                break;
        }
    }];
    //结束监听
    [manager stopMonitoring];
}

#pragma mark ------检查网络状态
+ (BOOL)isNetworkReachable{
    // Create zero addy

    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

@end
