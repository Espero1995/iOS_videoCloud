//
//  YZSDK.h
//  YZBaseSDK
//
//  Created by Pan on 2017/10/26.
//  Copyright © 2017年 Youzan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YZConfig, YZSDK;

NS_ASSUME_NONNULL_BEGIN

@protocol YZSDKDelegate <NSObject>

- (void)yzsdk:(YZSDK *)sdk needInitToken:(void (^)(NSString *_Nullable token))callback;

@end

/*!
 有赞云 AppSDK 通用信息管理。以及 cookie 和 token 的设置。
 */
@interface YZSDK : NSObject

@property (class, readonly, strong) YZSDK *shared;/**< 使用单例访问接口*/
@property (nonatomic, weak) id<YZSDKDelegate> delegate;

@property (nonatomic, readonly, nullable) NSString *accessToken; /**< 正在使用的 access_token */
@property (nonatomic, readonly) YZConfig *config; /**< SDK 的配置*/
@property (nonatomic, readonly) NSString *version;/**< SDK 版本号*/

/**
 初始化 SDK.
 使用 SDK 前必须先初始化 SDK.
 
 @param config 初始化配置。
 @see YZSDKConfig
 */
- (void)initializeSDKWithConfig:(YZConfig *)config;

/*!
 同步授权信息。
 
 在推荐的认证模型中，您向您的 App 服务器发起登陆请求，您的 App 服务器向有赞服务器发起 sso 登陆请求.
 有赞服务器处理后，将相关信息返回到您的 App 服务器，您的 App 服务器再将相关信息返回给您的 App.
 当 App 拿到这些信息后，需要调用此接口，将授权信息同步给 SDK.
 
 @see https://www.youzanyun.com/docs/guide/appsdk/683

 @param token access_token
 @param key cookie_key
 @param value cookie_value
 */
- (void)synchronizeAccessToken:(NSString *)token
                     cookieKey:(nullable NSString *)key
                   cookieValue:(nullable NSString *)value;

/*!
 APP用户登出,清除token、cookie等
 */
- (void)logout;

/*!
 预加载 html、 资源文件等，优化首屏打开时间。需要在初始化 SDK 后调用。
 
 @param urls 希望预加载的页面
 */
- (void)preloadURLs:(NSArray<NSURL *> *)urls;

@end

NS_ASSUME_NONNULL_END
