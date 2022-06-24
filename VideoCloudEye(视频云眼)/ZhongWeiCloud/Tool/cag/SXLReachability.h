//
//  SXLReachability.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/3/21.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, ReachabilityStatus) {
    ReachabilityStatusUnknown          = -1, //无网
    ReachabilityStatusNotReachable     = 0,  //无网
    ReachabilityStatusReachableViaWWAN = 1,  //流量
    ReachabilityStatusReachableViaWiFi = 2,  //wifi
};
@interface SXLReachability : NSObject
+ (void)SXL_hasNetwork:(void(^)(ReachabilityStatus netStatus))netStatus;

/**
 判断是否有网络

 @return 是：有网络  否：无网络
 */
+ (BOOL)isNetworkReachable;
@end

