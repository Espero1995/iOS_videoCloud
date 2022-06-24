//
//  fingerPrintLoginManage.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/3/22.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * 指纹登录结果枚举
 */
typedef NS_ENUM(NSUInteger, fingerLoginResult) {
    fingerLoginResultSuccess,
    fingerLoginResultErrorAuthenticationFailed,
    fingerLoginResultErrorUserCancel,
    fingerLoginResultErrorUserFallback,
    fingerLoginResultErrorSystemCancel,
    fingerLoginResultErrorPasscodeNotSet,
    fingerLoginResultErrorTouchIDNotAvailable,
    fingerLoginResultErrorTouchIDNotEnrolled,
    fingerLoginResultErrorTouchIDLockout,
    fingerLoginResultErrorAppCancel,
    fingerLoginResultErrorInvalidContext,
};
typedef void (^ReturnLoginResultBlock)(fingerLoginResult LoginResult);
@interface fingerPrintLoginManage : NSObject
@property (nonatomic, copy) ReturnLoginResultBlock returnLoginResultBlock;
+ (BOOL)supportFingerPrint;
+ (void)fingerPrintLoginResult:(ReturnLoginResultBlock)result;
@end
