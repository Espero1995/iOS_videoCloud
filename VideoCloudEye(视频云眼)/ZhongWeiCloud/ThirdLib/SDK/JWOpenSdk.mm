//
//  ZWOpenSdk.m
//  ZWCloudSdk
//
//  Created by 张策 on 17/4/11.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "JWOpenSdk.h"
#import "JWAccessToken.h"
#import "JWGuardConfigList.h"
#import "HeadClass.h"
#import "NSString+Md5String.h"
#import "JWDeviceInfo.h"
#import "JWVideoAddressInfo.h"
#import "JWPlayerManage.h"
#import "JWDeviceRecordFileList.h"
#import "JWRECPlanInfo.h"
#import "JWRECPlanInfoList.h"
#import "NewSdkHead.h"

@implementation JWOpenSdk

/**
 *  @since 1.0.0
 *  获取SDK版本号接口
 *
 *  @return 版本号
 */
+ (NSString *)getVersion
{
    return @"未实现该方法";
}
/**
 *  @since 1.0.0
 *  OpenSDK设置accessToken接口
 *
 *  @param accessToken 授权登录获取的accessToken
 */
+ (void)setAccessToken:(NSString *)accessToken userid:(NSString *)userid
{
    BOOL isInit = VmNet_Init(16);
    if (isInit) {
        NSLog(@"【VmNet Init succeed！】");
    }else
    {
        NSLog(@"【VmNet Init failed！】");
    }

    JWAccessToken *accessTokenInfo = [[JWAccessToken alloc]init];
    accessTokenInfo.accessToken = accessToken;
    accessTokenInfo.userid = userid;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accessTokenInfo];
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:JWACCESSTOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 * 获取访问令牌
 *
 * @return 访问令牌
 */
+ (NSString *)getAccessToken
{
    JWAccessToken *accessToken;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:JWACCESSTOKEN]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:JWACCESSTOKEN];
        accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return accessToken.accessToken;
    }
    return accessToken.accessToken;
}

- (NSString *)getAccessToken
{
    JWAccessToken *accessToken;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:JWACCESSTOKEN]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:JWACCESSTOKEN];
        accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return accessToken.accessToken;
    }
    return accessToken.accessToken;
}

- (NSString *)getUserId
{
    JWAccessToken *accessToken;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:JWACCESSTOKEN]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:JWACCESSTOKEN];
        accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return accessToken.userid;
    }
    return accessToken.userid;
}

+ (NSString *)getUserId
{
    JWAccessToken *accessToken;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:JWACCESSTOKEN]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:JWACCESSTOKEN];
        accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return accessToken.userid;
    }
    return accessToken.userid;
}

#pragma mark ------释放sdk
+ (void)deallocSdk
{
    VmNet_UnInit();
    NSLog(@"VmNet_UnInit3");
}

- (void)dealloc
{
    VmNet_UnInit();
    NSLog(@"VmNet_UnInit2");
}

/**
 * 添加设备
 *
 * @param deviceId  设备序列号
 * @param checkCode 验证码
 * @return operation
 */
+(NSOperationQueue *)addDeviceWithDeviceId:(NSString *)deviceId
                                 checkCode:(NSString *)checkCode
                           completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:deviceId];
    //设备验证码
    NSString *check_code = [NSString isNullToString:checkCode];
    //令牌
    NSString *access_token = [NSString isNullToString:[self getAccessToken]];
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:check_code forKey:@"check_code"];
    [postDic setObject:access_token forKey:@"access_token"];
    
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/add" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            completionBlock(JW_SUCCESS);
        }else{
            completionBlock(JW_FAILD);
        }
    } failure:^(NSError * _Nonnull error) {
        completionBlock(JW_FAILD);
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}

/**
 * 删除设备
 *
 * @param deviceId 设备序列号
 * @return operation
 */
+(NSOperationQueue *)deleteDeviceWithDeviceId:(NSString *)deviceId
                              completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:[self getAccessToken]];
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/delete" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            completionBlock(JW_SUCCESS);
        }else{
            completionBlock(JW_FAILD);
        }
    } failure:^(NSError * _Nonnull error) {
        completionBlock(JW_FAILD);
    }];
    return [ZCNetWorking shareInstance].operationQueue;
    
}

/**
 * 设置设备名称
 *
 * @param deviceName 设备名称
 * @param deviceId   设备序列号
 * @return operation
 */
+(NSOperationQueue *)setDeviceName:(NSString *)deviceName
                          deviceId:(NSString *)deviceId
                   completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
#warning 暂时未实现
    return [ZCNetWorking shareInstance].operationQueue;
}

/**
 * 设置布防计划
 *
 * @param deviceId  设备序列号
 * @param jwGuardPlanInfo 布防相关信息
 * @return operation
 */
+(NSOperationQueue *)setGuardPlanWithDevidId:(NSString *)deviceId
                             jwGuardPlanInfo:(JWGuardPlanInfo *)jwGuardPlanInfo
                             completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:[self getAccessToken]];
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    //布防结构体
    //告警类型
    [postDic setObject:[NSNumber numberWithInteger:jwGuardPlanInfo.alarmType] forKey:@"alarmType"];
    //布防、撤防
    [postDic setObject:[NSNumber numberWithInteger:jwGuardPlanInfo.enable] forKey:@"enable"];
    if (jwGuardPlanInfo.enable == JWDefenceStatusOn) {
        //开始时间
          [postDic setObject:jwGuardPlanInfo.start_time forKey:@"start_time"];
        //结束时间
         [postDic setObject:jwGuardPlanInfo.stop_time forKey:@"stop_time"];
        //周期
        [postDic setObject:jwGuardPlanInfo.period forKey:@"period"];
    }
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/setguardplan" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            completionBlock(JW_SUCCESS);
        }else{
            completionBlock(JW_FAILD);
        }
    } failure:^(NSError * _Nonnull error) {
        completionBlock(JW_FAILD);
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}

/**
 * 获取布防计划
 *
 * @param deviceId 设备序列号
 * @return operation
 */
+(NSOperationQueue *)getGuardPlanWithDevidId:(NSString *)deviceId
                             completionBlock:(void (^)(NSArray *jwGuardConfigList,JWErrorCode errorCode))completionBlock
{
    NSMutableDictionary *getDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:[self getAccessToken]];
    [getDic setObject:dev_id forKey:@"dev_id"];
    [getDic setObject:access_token forKey:@"access_token"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/getguardplan" parameters:getDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            JWGuardConfigList *jwGuardConfigList = [JWGuardConfigList mj_objectWithKeyValues:responseObject[@"body"]];
            
            completionBlock(jwGuardConfigList.guardConfigList,JW_SUCCESS);
        }else{
            completionBlock(nil,JW_FAILD);
        }
        
    } failure:^(NSError * _Nonnull error) {
            completionBlock(nil,JW_FAILD);
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}

/**
 * 获取设备版本信息
 *
 * @param deviceId 设备序列号
 * @return operation
 */
+(NSOperationQueue *)getDeviceVersionWithDevidId:(NSString *)deviceId
                                 completionBlock:(void (^)(JWDeviceInfo *jwDeviceInfo,JWErrorCode errorCode))completionBlock;
{
    NSMutableDictionary *getDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:[self getAccessToken]];
    [getDic setObject:dev_id forKey:@"dev_id"];
    [getDic setObject:access_token forKey:@"access_token"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/version/info" parameters:getDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            JWDeviceInfo *jwDeviceInfo = [JWDeviceInfo mj_objectWithKeyValues:responseObject[@"body"]];
            NSLog(@"responseObject中的body：%@",responseObject[@"body"]);
            completionBlock(jwDeviceInfo,JW_SUCCESS);
        }else{
            completionBlock(nil,JW_FAILD);
        }
        
    } failure:^(NSError * _Nonnull error) {
        completionBlock(nil,JW_FAILD);
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}

/**
 * 升级设备
 *
 * @param deviceId 设备序列号
 * @return operation
 */
+(NSOperationQueue *)upgradeDeviceWithDevidId:(NSString *)deviceId
                              completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:[self getAccessToken]];
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/upgrade" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            completionBlock(JW_SUCCESS);
        }else{
            completionBlock(JW_FAILD);
        }
        
    } failure:^(NSError * _Nonnull error) {
        completionBlock(JW_FAILD);
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}

/**
 * 获取设备升级状态
 *
 * @param deviceId 设备序列号
 * @return operation
 */
+(NSOperationQueue *)getDeviceUpgradeStatusWithDevidId:(NSString *)deviceId
                                       completionBlock:(void (^)(JWDeviceInfo *jwDeviceInfo,JWErrorCode errorCode))completionBlock
{
    NSMutableDictionary *getDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:[self getAccessToken]];
    [getDic setObject:dev_id forKey:@"dev_id"];
    [getDic setObject:access_token forKey:@"access_token"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/upgrade/status" parameters:getDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            JWDeviceInfo *jwDeviceInfo = [JWDeviceInfo mj_objectWithKeyValues:responseObject[@"body"]];
            
            completionBlock(jwDeviceInfo,JW_SUCCESS);
        }else{
            completionBlock(nil,JW_FAILD);
        }
        
    } failure:^(NSError * _Nonnull error) {
        completionBlock(nil,JW_FAILD);
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}


/**
 *  @since 1.0.0
 *  根据设备id查询录像播放接口
 *  @param deviceId 设备id
 *  @param recVideoType   录像视频类型
 *  @param beginTime   开始时间
 *  @param completionBlock 回调
 *  @exception 错误码类型：110004、120002、120014、120018，具体参考JWConstants头文件中的JWErrorCode错误码注释
 *
 *  @return operation
 */
+ (NSOperationQueue *)searchRecordVideoWithDevidId:(NSString *)deviceId
                                      recVideoType:(JWRecVideoTypeStatus)recVideoType
                                         beginTime:(NSDate *)beginTime
                                   completionBlock:(void (^)(NSArray *recVideoTimeArr,JWErrorCode errorCode))completionBlock
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:[self getAccessToken]];
    //录像类型
    NSNumber *recVideoTypeNum = [NSNumber numberWithInteger:recVideoType];
    //开始时间
    NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[beginTime timeIntervalSince1970]];
    int beginTimeInt = [dateStr intValue];
    NSNumber *beginNum = [NSNumber numberWithInt:beginTimeInt];
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    [postDic setObject:recVideoTypeNum forKey:@"rec_type"];
    [postDic setObject:beginNum forKey:@"s_date"];
    
    //先确认保证通道model是否有
    if ([MultiChannelDefaults getChannelModel]) {
        MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
        [postDic setObject:model.chanCode forKey:@"chan_code"];
    }
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/list" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            JWDeviceRecordFileList *jwDeviceRecordFileList = [JWDeviceRecordFileList mj_objectWithKeyValues:responseObject[@"body"]];
            
            completionBlock(jwDeviceRecordFileList.his_recs,JW_SUCCESS);
        }else{
            if (ret == 1501) {
                completionBlock(nil,JW_SEARCH_PLAYBACK_NO_PERMISSION);
            }else
            {
                completionBlock(nil,JW_FAILD);
            }
        }
        
    } failure:^(NSError * _Nonnull error) {
        completionBlock(nil,JW_FAILD);
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}

/**
 * 设置录像计划
 *
 * @param deviceId   设备序列号
 * @param jwRecPlanInfo 录像计划
 * @return operation
 */
+ (NSOperationQueue *)setRecordPlanWithDevidId:(NSString *)deviceId
                                 jwRecPlanInfo:(JWRECPlanInfo *)jwRecPlanInfo
                               completionBlock:(void (^)(JWErrorCode errorCode))completionBlock
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:[self getAccessToken]];
    [postDic setObject:dev_id forKey:@"dev_id"];
    [postDic setObject:access_token forKey:@"access_token"];
    //结构体
    //类型
    [postDic setObject:[NSNumber numberWithInteger:jwRecPlanInfo.recViewoType] forKey:@"rec_type"];
    //开始，停止
    [postDic setObject:[NSNumber numberWithInteger:jwRecPlanInfo.enable] forKey:@"enable"];
    if (jwRecPlanInfo.enable == JWRecVideoEnableTypeStatusBegin) {
        //开始时间
        [postDic setObject:jwRecPlanInfo.start_time forKey:@"start_time"];
        //结束时间
        [postDic setObject:jwRecPlanInfo.stop_time forKey:@"stop_time"];
        //周期
        [postDic setObject:jwRecPlanInfo.period forKey:@"period"];
    }
    [[HDNetworking sharedHDNetworking]POST:@"v1/media/record/setrecordplan" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            completionBlock(JW_SUCCESS);
        }else{
            completionBlock(JW_FAILD);
        }
    } failure:^(NSError * _Nonnull error) {
        completionBlock(JW_FAILD);
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}

/**
 * 获取录像计划
 *
 * @param deviceId 设备序列号
 * @param videoType 录像类型
 * @return operation
 */
+ (NSOperationQueue *)getRecordPlanWithDevidId:(NSString *)deviceId
                          jWRecVideoTypeStatus:(JWRecVideoTypeStatus)videoType
                               completionBlock:(void (^)(NSArray *jwRecPlanInfo,JWErrorCode errorCode))completionBlock
{
    NSMutableDictionary *getDic = [NSMutableDictionary dictionary];
    //设备id
    NSString *dev_id = [NSString isNullToString:deviceId];
    //令牌
    NSString *access_token = [NSString isNullToString:[self getAccessToken]];
    //录像类型
    NSNumber *videoTypeNum = [NSNumber numberWithInteger:videoType];
    [getDic setObject:dev_id forKey:@"dev_id"];
    [getDic setObject:access_token forKey:@"access_token"];
    [getDic setObject:videoTypeNum forKey:@"rec_type"];
    
    [[HDNetworking sharedHDNetworking]GET:@"v1/media/record/getrecordplan" parameters:getDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0 ) {
            JWRECPlanInfoList *jwRECPlanInfoList = [JWRECPlanInfoList mj_objectWithKeyValues:responseObject[@"body"]];
            
            completionBlock(jwRECPlanInfoList.recordPlans,JW_SUCCESS);
        }else{
            completionBlock(nil,JW_FAILD);
        }
        
    } failure:^(NSError * _Nonnull error) {
        completionBlock(nil,JW_FAILD);
    }];
    return [ZCNetWorking shareInstance].operationQueue;
}
/**
 *  @since 1.0.0
 *  根据构造JWPlayerManage对象
 *
 *
 *
 *
 *  @return JWPlayerManage对象
 */
+ (JWPlayerManage *)createPlayerManageWithDevidId:(NSString *)deviceId ChannelNo:(NSInteger)channelNo
{
   
    NSString*token = [NSString isNullToString:[self getAccessToken]];
    NSString*userId = [NSString isNullToString:[self getUserId]];
    NSString*deviceIdStr = [NSString isNullToString:deviceId];
    NSInteger cannelNo = channelNo;
    JWPlayerManage *playManage = [[JWPlayerManage alloc]initWithToken:token userId:userId deviceId:deviceIdStr cannelNo:cannelNo];
    return playManage;
}


/**
 * @brief 与上述接口通，但适用于含有chan_code和chan_id的设备
 */
+ (JWPlayerManage *)createPlayerManageWithDevidId:(NSString *)deviceId
                                          ChannelId:(NSString *)chanId
                                        ChannelCode:(NSString *)chanCode{
    NSString *token = [NSString isNullToString:[self getAccessToken]];
    NSString *userId = [NSString isNullToString:[self getUserId]];
    NSString *deviceIdStr = [NSString isNullToString:deviceId];
    NSInteger cannelNo = [chanId integerValue];
    NSString *chanCodeStr = [NSString isNullToString:chanCode];
    JWPlayerManage *playManage = [[JWPlayerManage alloc]initWithToken:token userId:userId deviceId:deviceIdStr chanId:cannelNo chanCode:chanCodeStr];
    return playManage;
}
@end
