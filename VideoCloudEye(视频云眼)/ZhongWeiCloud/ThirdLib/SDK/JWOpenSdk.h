//
//  ZWOpenSdk.h
//  ZWCloudSdk
//
//  Created by 张策 on 17/4/11.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JWConstants.h"
///主要的sdk 请求 通信

@class JWGuardPlanInfo;
@class JWRECPlanInfo;
@class JWPlayerManage;
@class JWDeviceInfo;
@class JWVideoAddressInfo;
//
//typedef void (^ _Nullable Success)(id  responseObject);     // 成功Block
//typedef void (^ _Nullable Failure)(NSError *error);
@interface JWOpenSdk : NSObject

#pragma mark ------实例化sdk相关



/**
 *  @since 1.0.0
 *  获取SDK版本号接口
 *
 *  @return 版本号
 */
+ (NSString *)getVersion;

#pragma mark ------用户信息相关

/**
 *  @since 1.0.0
 *  OpenSDK设置accessToken接口
 *
 *  @param accessToken 授权登录获取的accessToken
 */
+ (void)setAccessToken:(NSString *)accessToken userid:(NSString *)userid;

/**
 * 获取访问令牌
 *
 * @return 访问令牌
 */
+ (NSString *)getAccessToken;


#pragma mark ------释放sdk
+ (void)deallocSdk;

#pragma mark ------功能接口

/**
 * 添加设备
 *
 * @param deviceId  设备序列号
 * @param checkCode 验证码
 * @return operation
 */
+(NSOperationQueue *)addDeviceWithDeviceId:(NSString *)deviceId
                            checkCode:(NSString *)checkCode
                      completionBlock:(void (^)(JWErrorCode errorCode))completionBlock;
/**
 * 删除设备
 *
 * @param deviceId 设备序列号
 * @return operation
 */
+(NSOperationQueue *)deleteDeviceWithDeviceId:(NSString *)deviceId
                         completionBlock:(void (^)(JWErrorCode errorCode))completionBlock;

/**
 * 设置设备名称
 *
 * @param deviceName 设备名称
 * @param deviceId   设备序列号
 * @return operation
 */
+(NSOperationQueue *)setDeviceName:(NSString *)deviceName
                     deviceId:(NSString *)deviceId
              completionBlock:(void (^)(JWErrorCode errorCode))completionBlock;

/**
 * 设置布防计划
 *
 * @param deviceId  设备序列号
 * @param jwGuardPlanInfo 布防相关信息
 * @return operation
 */
+(NSOperationQueue *)setGuardPlanWithDevidId:(NSString *)deviceId
                        jwGuardPlanInfo:(JWGuardPlanInfo *)jwGuardPlanInfo
                        completionBlock:(void (^)(JWErrorCode errorCode))completionBlock;

/**
 * 获取布防计划
 *
 * @param deviceId 设备序列号
 * @return operation
 */
+(NSOperationQueue *)getGuardPlanWithDevidId:(NSString *)deviceId
                        completionBlock:(void (^)(NSArray *jwGuardConfigList,JWErrorCode errorCode))completionBlock;

/**
 * 获取设备版本信息
 *
 * @param deviceId 设备序列号
 * @return operation
 */
+(NSOperationQueue *)getDeviceVersionWithDevidId:(NSString *)deviceId
                            completionBlock:(void (^)(JWDeviceInfo *jwDeviceInfo,JWErrorCode errorCode))completionBlock;

/**
 * 升级设备
 *
 * @param deviceId 设备序列号
 * @return operation
 */
+(NSOperationQueue *)upgradeDeviceWithDevidId:(NSString *)deviceId
                         completionBlock:(void (^)(JWErrorCode errorCode))completionBlock;
/**
 * 获取设备升级状态
 *
 * @param deviceId 设备序列号
 * @return operation
 */
+(NSOperationQueue *)getDeviceUpgradeStatusWithDevidId:(NSString *)deviceId
                                  completionBlock:(void (^)(JWDeviceInfo *jwDeviceInfo,JWErrorCode errorCode))completionBlock;






/**
 *  @since 1.0.0
 *  根据设备id查询录像播放接口
 *  @param deviceId 设备id
 *  @param recVideoType   录像视频类型
 *  @param beginTime   开始时间
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考ZWConstants头文件中的ZWErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperationQueue *)searchRecordVideoWithDevidId:(NSString *)deviceId
                            recVideoType:(JWRecVideoTypeStatus)recVideoType
                                   beginTime:(NSDate *)beginTime
                            completionBlock:(void (^)(NSArray *recVideoTimeArr,JWErrorCode errorCode))completionBlock;






/**
 * 设置录像计划
 *
 * @param deviceId   设备序列号
 * @param jwRecPlanInfo 录像计划
 * @return operation
 */
+ (NSOperationQueue *)setRecordPlanWithDevidId:(NSString *)deviceId
                            jwRecPlanInfo:(JWRECPlanInfo *)jwRecPlanInfo
                          completionBlock:(void (^)(JWErrorCode errorCode))completionBlock;

/**
 * 获取录像计划
 *
 * @param deviceId 设备序列号
 * @param videoType 录像类型
 * @return operation
 */
+ (NSOperationQueue *)getRecordPlanWithDevidId:(NSString *)deviceId
                     jWRecVideoTypeStatus:(JWRecVideoTypeStatus)videoType
                          completionBlock:(void (^)(NSArray *jwRecPlanInfo,JWErrorCode errorCode))completionBlock;

#pragma mark ------wifi
/**
 *  @since 1.0.0
 *  WiFi配置开始接口
 *
 *  @param ssid         连接WiFi SSID
 *  @param password     连接WiFi 密码
 *  @param deviceSerial 连接WiFi的设备的设备序列号
 *  @param statusBlock  返回连接设备的WiFi配置状态
 *
 *  @return YES/NO
 */
+ (BOOL)startConfigWifi:(NSString *)ssid
               password:(NSString *)password
           deviceSerial:(NSString *)deviceSerial
           deviceStatusBlock:(void (^)(JWifiConfigStatus status))statusBlock;

/**
 *  @since 1.0.0
 *  Wifi配置停止接口
 *
 *  @return YES/NO
 */
+ (BOOL)stopConfigWifi;

#pragma mark ------视频解码管理者
/**
 *  @since 1.0.0
 *  根据cameraId构造JWPlayerManage对象
 *
 *
 *
 *
 *  @return JWPlayerManage对象
 */


+ (JWPlayerManage *)createPlayerManageWithDevidId:(NSString *)deviceId ChannelNo:(NSInteger)channelNo;

/**
 *  @since 1.0.0
 *  释放ZWPlayerManage对象
 *
 *  @param player ZWPlayer对象
 *
 *  @return YES/NO
 */
+ (BOOL)releasePlayer:(JWPlayerManage *)player;

/**
 * @brief 与上述接口通，但适用于含有chan_code和chan_id的设备
 */
+ (JWPlayerManage *)createPlayerManageWithDevidId:(NSString *)deviceId ChannelId:(NSString *)chanId ChannelCode:(NSString *)chanCode;

@end
