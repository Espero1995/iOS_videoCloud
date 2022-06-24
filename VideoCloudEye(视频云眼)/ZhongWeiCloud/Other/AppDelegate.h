//
//  AppDelegate.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/9.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
@protocol WXDelegate <NSObject>

/**
 微信登录回调

 @param code 微信授权之后获得的code
 */
-(void)loginSuccessByCode:(NSString *)code;
@end
@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,assign)BOOL allowRotation;
/**
 * appdelegate的代理指针
 */
@property (nonatomic, assign) id<WXDelegate>wxDelegate;

@end

