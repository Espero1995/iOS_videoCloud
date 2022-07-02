//
//  AppUpdateManager.h
//  ZhongWeiCloud
//
//  Created by 王攀登 on 2022/7/2.
//  Copyright © 2022 苏旋律. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppUpdateManager : NSObject

// 检查版本更新
+ (void)checkAppUpdateComplete:(void(^)(void))complete;

@end

NS_ASSUME_NONNULL_END
