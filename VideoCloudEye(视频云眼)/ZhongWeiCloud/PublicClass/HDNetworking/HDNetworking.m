//
//  HDNetworking.m
//  PortableTreasure
//
//  Created by HeDong on 16/2/10.
//  Copyright © 2016年 hedong. All rights reserved.
//

#import "HDNetworking.h"
#import "HDPicModle.h"
#import "UIImage+HDExtension.h"
#import "AFNetworking.h"
#import <CloudPushSDK/CloudPushSDK.h>

@implementation HDNetworking
{
    NSURLSessionDataTask *_task;
}
HDSingletonM(HDNetworking) // 单例实现



/**
 *  网络监测(在什么网络状态)
 *
 *  @param unknown          未知网络
 *  @param reachable        无网络
 *  @param reachableViaWWAN 蜂窝数据网
 *  @param reachableViaWiFi WiFi网络
 */
- (void)networkStatusUnknown:(Unknown)unknown reachable:(Reachable)reachable reachableViaWWAN:(ReachableViaWWAN)reachableViaWWAN reachableViaWiFi:(ReachableViaWiFi)reachableViaWiFi;
{
    // 创建网络监测者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 监测到不同网络的情况
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown:
                unknown();
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                reachable();
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                reachableViaWWAN();
                
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                reachableViaWiFi();
                break;
                
            default:
                break;
        }
    }] ;
}

/**
 *  封装的get请求
 *
 *  @param URLString  请求的链接
 *  @param parameters 请求的参数
 *  @param success    请求成功回调
 *  @param failure    请求失败回调
 */
- (void)GET:(NSString *)URLString parameters:(NSMutableDictionary *)parameters success:(Success)success failure:(Failure)failure
{
    AFHTTPSessionManager *manager = [ZCNetWorking shareInstance];

    //HTTPS SSL的验证，在此处调用上面的代码，给这个证书验证；
//    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    NSMutableSet *contentTypes = [[NSMutableSet alloc] initWithSet:manager.responseSerializer.acceptableContentTypes];
    [contentTypes addObject:@"text/html"];
    [contentTypes addObject:@"text/plain"];
    
    manager.responseSerializer.acceptableContentTypes = self.acceptableContentTypes;
    manager.requestSerializer.timeoutInterval = (self.timeoutInterval ? self.timeoutInterval : 10);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString * tempBaseUrl;
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:Environment]) {
        NSString * URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:Environment];
        if ([URLStr isEqualToString:official_Environment_key]) {
            tempBaseUrl = BASEURL_officialEnvironment;
        }else if([URLStr isEqualToString:test_Environment_key]){
            tempBaseUrl = BASEURL_testEnvironment;
        }
    }

    NSString * urlStr = [NSString stringWithFormat:@"%@%@",tempBaseUrl,URLString];
    
    _task =  [manager GET:urlStr parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success)
        {
           // NSDictionary * safeResponseObject = [responseObject dictionaryByReplacingNulls];
            success(responseObject);
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure)
        {
            failure(error);
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (void)GET:(NSString *)URLString parameters:(NSMutableDictionary *)parameters IsToken:(BOOL)isToken success:(Success)success failure:(Failure)failure
{
    AFHTTPSessionManager *manager = [ZCNetWorking shareInstance];
//    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    [manager setSecurityPolicy:[self customSecurityPolicy]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSMutableSet *contentTypes = [[NSMutableSet alloc] initWithSet:manager.responseSerializer.acceptableContentTypes];
    [contentTypes addObject:@"text/html"];
    [contentTypes addObject:@"text/plain"];
    
    manager.responseSerializer.acceptableContentTypes = self.acceptableContentTypes;
    manager.requestSerializer.timeoutInterval = (self.timeoutInterval ? self.timeoutInterval : 10);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString * tempBaseUrl;
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:Environment]) {
        NSString * URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:Environment];
        if ([URLStr isEqualToString:official_Environment_key]) {
            tempBaseUrl = BASEURL_officialEnvironment;
        }else if([URLStr isEqualToString:test_Environment_key]){
            tempBaseUrl = BASEURL_testEnvironment;
        }
    }
    NSString * urlStr = [NSString stringWithFormat:@"%@%@",tempBaseUrl,URLString];
    
    if (isToken) {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
            NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
            UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [parameters setValue:userModel.access_token forKey:@"access_token"];
            [parameters setValue:userModel.user_id forKey:@"user_id"];
        }
    }

  _task = [manager GET:urlStr parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        
        if (ret == 1003 ) {
            if (![unitl isRefreshTokenSucceed]) {
                 NSLog(@"上次用refreshToken刷新token时间【成功】1");
                @synchronized (Refresh_Lock)
                {
                    [self refreshTokenUrlStr:URLString parameters:parameters IsToken:isToken success:success failure:failure isPost:YES];
                }
            }else
            {
                NSLog(@"上次用refreshToken刷新token时间还未超过10s，不予刷新~1");
            }
            return ;
        }else if (ret == 1002) {
            [XHToast showTopWithText:NSLocalizedString(@"您的账号已在其它设备登录", nil)];
            NSLog(@"后台返回登录过期2：%@",[unitl getCurrentTimes]);
            NSError *error = [[NSError alloc]init];
            if (failure)
            {
                failure(error);
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:BACKLOGIN object:nil];
        }else {
            if(success)
            {
               // NSDictionary * safeResponseObject = [responseObject dictionaryByReplacingNulls];
                success(responseObject);
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; // 关闭状态栏动画
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure)
        {
            failure(error);
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

//测试支付宝

- (void)GET:(NSString *)URLString parameters:(NSMutableDictionary *)parameters Iszfb:(BOOL)iszfb IsToken:(BOOL)isToken success:(Success)success failure:(Failure)failure
{
    AFHTTPSessionManager *manager = [ZCNetWorking shareInstance];
    //    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    //    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //
    //    [manager setSecurityPolicy:[self customSecurityPolicy]];
    
    
    NSMutableSet *contentTypes = [[NSMutableSet alloc] initWithSet:manager.responseSerializer.acceptableContentTypes];
    [contentTypes addObject:@"text/html"];
    [contentTypes addObject:@"text/plain"];
    
    manager.responseSerializer.acceptableContentTypes = self.acceptableContentTypes;
    manager.requestSerializer.timeoutInterval = (self.timeoutInterval ? self.timeoutInterval : 10);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString * tempBaseUrl;
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:Environment]) {
        NSString * URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:Environment];
        if ([URLStr isEqualToString:official_Environment_key]) {
            tempBaseUrl = BASEURL_officialEnvironment;
        }else if([URLStr isEqualToString:test_Environment_key]){
            tempBaseUrl = BASEURL_testEnvironment;
        }
    }
    NSString * urlStr = @"";
    if (iszfb) {
      urlStr  = [NSString stringWithFormat:@"%@%@",tempBaseUrl,URLString];

    }else{
      urlStr = [NSString stringWithFormat:@"%@%@",tempBaseUrl,URLString];
    }
    if (isToken) {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
            NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
            UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [parameters setValue:userModel.access_token forKey:@"access_token"];
            [parameters setValue:userModel.user_id forKey:@"user_id"];
        }
    }
    
    _task = [manager GET:urlStr parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 1003 ) {
            if (![unitl isRefreshTokenSucceed]) {
                NSLog(@"上次用refreshToken刷新token时间【成功】2");
                
                [self refreshTokenUrlStr:URLString parameters:parameters IsToken:isToken success:success failure:failure isPost:YES];
            }else
            {
                NSLog(@"上次用refreshToken刷新token时间还未超过10s，不予刷新~2");
            }
            return ;
        }else if (ret == 1002) {
            [XHToast showTopWithText:NSLocalizedString(@"您的账号已在其它设备登录", nil)];
            NSLog(@"后台返回登录过期1:%@",[unitl getCurrentTimes]);
            NSError *error = [[NSError alloc]init];
            if (failure)
            {
                failure(error);
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:BACKLOGIN object:nil];
        }
        else {
            if(success)
            {
               // NSDictionary * safeResponseObject = [responseObject dictionaryByReplacingNulls];
                success(responseObject);
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; // 关闭状态栏动画
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure)
        {
            failure(error);
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}



/**
 *  封装的POST请求
 *
 *  @param URLString  请求的链接
 *  @param parameters 请求的参数
 *  @param success    请求成功回调
 *  @param failure    请求失败回调
 */
- (void)POST:(NSString *)URLString parameters:(NSMutableDictionary *)parameters success:(Success)success failure:(Failure)failure
{
    AFHTTPSessionManager *manager = [ZCNetWorking shareInstance];
//    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    [manager setSecurityPolicy:[self customSecurityPolicy]];

    
    NSMutableSet *contentTypes = [[NSMutableSet alloc] initWithSet:manager.responseSerializer.acceptableContentTypes];
    [contentTypes addObject:@"text/html"];
    [contentTypes addObject:@"text/plain"];
    
    manager.responseSerializer.acceptableContentTypes = self.acceptableContentTypes;
    manager.requestSerializer.timeoutInterval = (self.timeoutInterval ? self.timeoutInterval : 10);

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; // 开启状态栏动画
    
    NSString * tempBaseUrl;
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:Environment]) {
        NSString * URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:Environment];
        if ([URLStr isEqualToString:official_Environment_key]) {
            tempBaseUrl = BASEURL_officialEnvironment;
        }else if([URLStr isEqualToString:test_Environment_key]){
            tempBaseUrl = BASEURL_testEnvironment;
        }
    }
    NSString * urlStr = [NSString stringWithFormat:@"%@%@",tempBaseUrl,URLString];
    NSLog(@"最终的URL:%@",urlStr);
    
  _task = [manager POST:urlStr parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 1003 ) {
            if (![unitl isRefreshTokenSucceed]) {
                NSLog(@"上次用refreshToken刷新token时间【成功】3");
                @synchronized (Refresh_Lock)
                {
                    [self refreshTokenUrlStr:URLString parameters:parameters IsToken:NO success:success failure:failure isPost:YES];
                }
            }else
            {
                NSLog(@"上次用refreshToken刷新token时间还未超过10s，不予刷新~3");
            }
            return ;
        }else if (ret == 1002) {
            [XHToast showTopWithText:NSLocalizedString(@"您的账号已在其它设备登录", nil)];
            NSLog(@"后台返回登录过期3:%@",[unitl getCurrentTimes]);
            NSError *error = [[NSError alloc]init];
            if (failure)
            {
                failure(error);
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:BACKLOGIN object:nil];
        }
        else {
            if(success)
            {
              //  NSDictionary * safeResponseObject = [responseObject dictionaryByReplacingNulls];
                success(responseObject);
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; // 关闭状态栏动画
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; // 关闭状态栏动画
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure)
        {
            failure(error);
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; // 关闭状态栏动画
    }];
}
/**
 *  封装的POST请求是否添加token userid
 *
 *  @param URLString  请求的链接
 *  @param parameters 请求的参数
 *  @param isToken    是否添加token
 *  @param success    请求成功回调
 *  @param failure    请求失败回调
 */
- (void)POST:(NSString *)URLString parameters:(NSMutableDictionary *)parameters IsToken:(BOOL)isToken success:(Success)success failure:(Failure)failure
{
    AFHTTPSessionManager *manager = [ZCNetWorking shareInstance];
//    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    [manager setSecurityPolicy:[self customSecurityPolicy]];

    
    NSMutableSet *contentTypes = [[NSMutableSet alloc] initWithSet:manager.responseSerializer.acceptableContentTypes];
    [contentTypes addObject:@"text/html"];
    [contentTypes addObject:@"text/plain"];
    
    manager.responseSerializer.acceptableContentTypes = self.acceptableContentTypes;
    manager.requestSerializer.timeoutInterval = (self.timeoutInterval ? self.timeoutInterval : 10);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; // 开启状态栏动画
    NSString * tempBaseUrl;
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:Environment]) {
        NSString * URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:Environment];
        if ([URLStr isEqualToString:official_Environment_key]) {
            tempBaseUrl = BASEURL_officialEnvironment;
        }else if([URLStr isEqualToString:test_Environment_key]){
            tempBaseUrl = BASEURL_testEnvironment;
        }
    }
    NSString * urlStr = [NSString stringWithFormat:@"%@%@",tempBaseUrl,URLString];
    if (isToken) {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
            NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
            UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [parameters setValue:userModel.access_token forKey:@"access_token"];
            [parameters setValue:userModel.user_id forKey:@"user_id"];
        }
    }
   _task = [manager POST:urlStr parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 1003 ) {
            if (![unitl isRefreshTokenSucceed]) {
                NSLog(@"上次用refreshToken刷新token时间【成功】4");
                @synchronized (Refresh_Lock)
                {
                  [self refreshTokenUrlStr:URLString parameters:parameters IsToken:isToken success:success failure:failure isPost:YES];
                }
            }else
            {
                NSLog(@"上次用refreshToken刷新token时间还未超过10s，不予刷新~4");
            }
            return ;
        }else if (ret == 1002) {
           // [XHToast showTopWithText:@"登录过期,请退出当前账号重新登录"];
//            [XHToast showTopWithText:@"您的账号已在其它设备登录"];
            NSLog(@"后台返回登录过期4:%@",[unitl getCurrentTimes]);
            NSError *error = [[NSError alloc]init];
            if (failure)
            {
                failure(error);
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:BACKLOGIN object:nil];
        }
        else {
            if(success)
            {
              //  NSDictionary * safeResponseObject = [responseObject dictionaryByReplacingNulls];
                success(responseObject);
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; // 关闭状态栏动画
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure)
        {
            failure(error);
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; // 关闭状态栏动画
    }];
}


/*
- (void)POST:(NSString *)URLString DeviceCaptureBlock:(deviceCaptureBlock)deviceCaptureParameters IsToken:(BOOL)isToken  success:(Success)success failure:(Failure)failure
{
    AFHTTPSessionManager *manager = [ZCNetWorking shareInstance];
    //    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    //    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //
    //    [manager setSecurityPolicy:[self customSecurityPolicy]];
    
    NSMutableSet *contentTypes = [[NSMutableSet alloc] initWithSet:manager.responseSerializer.acceptableContentTypes];
    [contentTypes addObject:@"text/html"];
    [contentTypes addObject:@"text/plain"];
    
    manager.responseSerializer.acceptableContentTypes = self.acceptableContentTypes;
    manager.requestSerializer.timeoutInterval = (self.timeoutInterval ? self.timeoutInterval : 10);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; // 开启状态栏动画
    NSString * tempBaseUrl;
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:Environment]) {
        NSString * URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:Environment];
        if ([URLStr isEqualToString:official_Environment_key]) {
            tempBaseUrl = BASEURL_officialEnvironment;
        }else if([URLStr isEqualToString:test_Environment_key]){
            tempBaseUrl = BASEURL_testEnvironment;
        }
    }
    NSString * urlStr = [NSString stringWithFormat:@"%@%@",tempBaseUrl,URLString];
    if (isToken) {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
            NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
            UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [parameters setValue:userModel.access_token forKey:@"access_token"];
            [parameters setValue:userModel.user_id forKey:@"user_id"];
        }
    }
    _task = [manager POST:urlStr parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 1003 ) {
            if (![unitl isRefreshTokenSucceed]) {
                NSLog(@"上次用refreshToken刷新token时间【成功】4");
                @synchronized (Refresh_Lock)
                {
                    [self refreshTokenUrlStr:URLString parameters:parameters IsToken:isToken success:success failure:failure isPost:YES];
                }
            }else
            {
                NSLog(@"上次用refreshToken刷新token时间还未超过10s，不予刷新~4");
            }
            return ;
        }
        if (ret == 1002) {
            // [XHToast showTopWithText:@"登录过期,请退出当前账号重新登录"];
            //            [XHToast showTopWithText:@"您的账号已在其它设备登录"];
            NSLog(@"后台返回登录过期4:%@",[unitl getCurrentTimes]);
            NSError *error = [[NSError alloc]init];
            if (failure)
            {
                failure(error);
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:BACKLOGIN object:nil];
        }
        else {
            if(success)
            {
 //NSDictionary * safeResponseObject = [responseObject dictionaryByReplacingNulls];
 success(responseObject);
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; // 关闭状态栏动画
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure)
        {
            failure(error);
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; // 关闭状态栏动画
    }];
}
*/



#pragma mark ------刷新令牌
- (void)refreshTokenUrlStr:(NSString *)URLNewString parameters:(NSMutableDictionary *)newParameterss IsToken:(BOOL)isToken success:(Success)successBlock failure:(Failure)failure isPost:(BOOL)isPost
{
    NSLog(@"后台返回登录过期【刷新令牌】时间：%@",[unitl getCurrentTimes]);
    NSMutableDictionary *newParameters = [[NSMutableDictionary alloc]initWithDictionary:newParameterss];
    NSString * tempBaseUrl;
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:Environment]) {
        NSString * URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:Environment];
        if ([URLStr isEqualToString:official_Environment_key]) {
            tempBaseUrl = BASEURL_officialEnvironment;
        }else if([URLStr isEqualToString:test_Environment_key]){
            tempBaseUrl = BASEURL_testEnvironment;
        }
    }
    NSString * urlStr = [NSString stringWithFormat:@"%@%@",tempBaseUrl,@"v1/user/token"];

    AFHTTPSessionManager *manager = [ZCNetWorking shareInstance];
//    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    [manager setSecurityPolicy:[self customSecurityPolicy]];

    NSMutableSet *contentTypes = [[NSMutableSet alloc] initWithSet:manager.responseSerializer.acceptableContentTypes];
    [contentTypes addObject:@"text/html"];
    [contentTypes addObject:@"text/plain"];
    manager.responseSerializer.acceptableContentTypes = self.acceptableContentTypes;
    manager.requestSerializer.timeoutInterval = (self.timeoutInterval ? self.timeoutInterval : 10);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; // 开启状态栏动画
    NSMutableDictionary *postTokenDic = [NSMutableDictionary dictionary];
        if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
            NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
            UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [postTokenDic setValue:userModel.refresh_token forKey:@"refresh_token"];
            [postTokenDic setValue:userModel.user_id forKey:@"user_id"];
        }
  _task = [manager POST:urlStr parameters:postTokenDic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            //写入数据到本地
            if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
                NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
                UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                NSDictionary *getDic = responseObject[@"body"];
                userModel.access_token = getDic[@"access_token"];
                userModel.expires_in = [getDic[@"expires_in"]intValue];
                userModel.refresh_token = getDic[@"refresh_token"];
                NSString * refreshTime = [unitl getNowTimeTimestamp];
                userModel.refreshTime = refreshTime;
                NSData *dataa = [NSKeyedArchiver archivedDataWithRootObject:userModel];
                [[NSUserDefaults standardUserDefaults]setObject:dataa forKey:USERMODEL];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            if (isPost) {
                [self POST:URLNewString parameters:newParameters IsToken:isToken success:successBlock failure:failure];
            }
            else if (isPost == NO){
                [self GET:URLNewString parameters:newParameters IsToken:isToken success:successBlock failure:failure];
            }
        }
        else{
            [XHToast showTopWithText:NSLocalizedString(@"登录过期,请退出当前账号重新登录", nil)];
            NSLog(@"后台返回登录过期5:%@",[unitl getCurrentTimes]);
            NSError *error = [[NSError alloc]init];
            if (failure)
            {
                failure(error);
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:BACKLOGIN object:nil];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; // 关闭状态栏动画
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; // 关闭状态栏动画
        [XHToast showTopWithText:NSLocalizedString(@"登录过期,请退出当前账号重新登录", nil)];
        NSLog(@"后台返回登录过期6");
        if (failure)
        {
            failure(error);
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:BACKLOGIN object:nil];
    }];
}
/**
 *  封装POST图片上传(多张图片) // 可扩展成多个别的数据上传如:mp3等
 *
 *  @param URLString  请求的链接
 *  @param parameters 请求的参数
 *  @param picArray   存放图片模型(HDPicModle)的数组
 *  @param progress   进度的回调
 *  @param success    发送成功的回调
 *  @param failure    发送失败的回调
 */
- (void)POST:(NSString *)URLString parameters:(NSDictionary *)parameters andPicArray:(NSArray *)picArray progress:(Progress)progress success:(Success)success failure:(Failure)failure
{
    AFHTTPSessionManager *manager = [ZCNetWorking shareInstance];
//    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    [manager setSecurityPolicy:[self customSecurityPolicy]];

    
    manager.responseSerializer.acceptableContentTypes = self.acceptableContentTypes;
    manager.requestSerializer.timeoutInterval = (self.timeoutInterval ? self.timeoutInterval : 10);
    manager.requestSerializer = [AFHTTPRequestSerializer serializer]; // 请求不使用AFN默认转换,保持原有数据
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 响应不使用AFN默认转换,保持原有数据
    
   _task = [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSInteger count = picArray.count;
        NSString *fileName = @"";
        NSData *data = [NSData data];
        
        for (int i = 0; i < count; i++)
        {
            @autoreleasepool {
                HDPicModle *picModle = picArray[i];
                fileName = [NSString stringWithFormat:@"pic%02d.jpg", i];
                /**
                 *  压缩图片然后再上传(1.0代表无损 0~~1.0区间)
                 */
                data = UIImageJPEGRepresentation(picModle.pic, 1.0);
                CGFloat precent = self.picSize / (data.length / 1024.0);
                if (precent > 1)
                {
                    precent = 1.0;
                }
                data = nil;
                data = UIImageJPEGRepresentation(picModle.pic, precent);
                
                [formData appendPartWithFileData:data name:picModle.picName fileName:fileName mimeType:@"image/jpeg"];
                data = nil;
                picModle.pic = nil;
            }
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (progress)
        {
            progress(uploadProgress); // HDLog(@"%lf", 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success)
        {
           // NSDictionary * safeResponseObject = [responseObject dictionaryByReplacingNulls];
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure)
        {
            failure(error);
        }
    }];
}

/**
 *  封装POST图片上传(单张图片) // 可扩展成单个别的数据上传如:mp3等
 *
 *  @param URLString  请求的链接
 *  @param parameters 请求的参数
 *  @param picModle   上传的图片模型
 *  @param progress   进度的回调
 *  @param success    发送成功的回调
 *  @param failure    发送失败的回调
 */
- (void)POST:(NSString *)URLString parameters:(NSDictionary *)parameters andPic:(HDPicModle *)picModle progress:(Progress)progress success:(Success)success failure:(Failure)failure
{
    AFHTTPSessionManager *manager = [ZCNetWorking shareInstance];
//    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    [manager setSecurityPolicy:[self customSecurityPolicy]];

    
    manager.responseSerializer.acceptableContentTypes = self.acceptableContentTypes;
    manager.requestSerializer.timeoutInterval = (self.timeoutInterval ? self.timeoutInterval : 10);
    manager.requestSerializer = [AFHTTPRequestSerializer serializer]; // 请求不使用AFN默认转换,保持原有数据
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 响应不使用AFN默认转换,保持原有数据
    
    _task = [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        /**
         *  压缩图片然后再上传(1.0代表无损 0~~1.0区间)
         */
        NSData *data = UIImageJPEGRepresentation(picModle.pic, 1.0);
        CGFloat precent = self.picSize / (data.length / 1024.0);
        if (precent > 1)
        {
            precent = 1.0;
        }
        data = nil;
        data = UIImageJPEGRepresentation(picModle.pic, precent);
        
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", picModle.picName];
        
        [formData appendPartWithFileData:data name:picModle.picName fileName:fileName mimeType:@"image/jpeg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (progress)
        {
            progress(uploadProgress); // HDLog(@"%lf", 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success)
        {
            //NSDictionary * safeResponseObject = [responseObject dictionaryByReplacingNulls];
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure)
        {
            failure(error);
        }
    }];
}

/**
 *  封装POST上传url资源
 *
 *  @param URLString  请求的链接
 *  @param parameters 请求的参数
 *  @param picModle   上传的图片模型(资源的url地址)
 *  @param progress   进度的回调
 *  @param success    发送成功的回调
 *  @param failure    发送失败的回调
 */
- (void)POST:(NSString *)URLString parameters:(NSDictionary *)parameters andPicUrl:(HDPicModle *)picModle progress:(Progress)progress success:(Success)success failure:(Failure)failure
{
    AFHTTPSessionManager *manager = [ZCNetWorking shareInstance];
//    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    [manager setSecurityPolicy:[self customSecurityPolicy]];

    
    manager.responseSerializer.acceptableContentTypes = self.acceptableContentTypes;
    manager.requestSerializer.timeoutInterval = (self.timeoutInterval ? self.timeoutInterval : 10);
    manager.requestSerializer = [AFHTTPRequestSerializer serializer]; // 请求不使用AFN默认转换,保持原有数据
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // 响应不使用AFN默认转换,保持原有数据
    
 _task = [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", picModle.picName];
        // 根据本地路径获取url(相册等资源上传)
        NSURL *url = [NSURL fileURLWithPath:picModle.url]; // [NSURL URLWithString:picModle.url] 可以换成网络的图片在上传
        
        [formData appendPartWithFileURL:url name:picModle.picName fileName:fileName mimeType:@"application/octet-stream" error:nil];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (progress)
        {
            progress(uploadProgress); // HDLog(@"%lf", 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success)
        {
           // NSDictionary * safeResponseObject = [responseObject dictionaryByReplacingNulls];
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure)
        {
            failure(error);
        }
    }];
}

/**
 *  下载
 *
 *  @param URLString       请求的链接
 *  @param progress        进度的回调
 *  @param destination     返回URL的回调
 *  @param downLoadSuccess 发送成功的回调
 *  @param failure         发送失败的回调
 */
- (NSURLSessionDownloadTask *)downLoadWithURL:(NSString *)URLString progress:(Progress)progress destination:(Destination)destination downLoadSuccess:(DownLoadSuccess)downLoadSuccess failure:(Failure)failure;
{
    AFHTTPSessionManager *manager = [ZCNetWorking shareInstance];
//    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//
//    [manager setSecurityPolicy:[self customSecurityPolicy]];


    NSURL *url = [NSURL URLWithString:URLString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 下载任务
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        if (progress)
        {
            progress(downloadProgress); // HDLog(@"%lf", 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        }
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        if (destination)
        {
            return destination(targetPath, response);
        }
        else
        {
            return nil;
        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if (error)
        {
            failure(error);
        }
        else
        {
            downLoadSuccess(response, filePath);
        }
    }];
    
    // 开始启动任务
    [task resume];
    
    return task;
}
- (void)canleAllHttp
{
    [_task cancel];
    _task = nil;
    AFHTTPSessionManager *manager = [ZCNetWorking shareInstance];
//    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
//    [manager setSecurityPolicy:[self customSecurityPolicy]];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    [manager.operationQueue cancelAllOperations];

}
- (void)postBackLogin
{
    [[NSNotificationCenter defaultCenter]postNotificationName:BACKLOGIN object:nil];
}
- (AFSecurityPolicy *)customSecurityPolicy {
    
    // 先导入证书 证书由服务端生成，具体由服务端人员操作
//    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"https.cer" ofType:@"cer"];//证书的路径
    NSString * cerPath = [NSString stringWithFormat:@"Users/mengranzhang/Desktop/sdk/SDKZhongWeiCloud/ZhongWeiCloud/https.cer"];
    NSLog(@"%@",cerPath);
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    NSLog(@"%@",cerData);
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = NO;
    
    //validatesDomainName 是否需要验证域名，默认为YES;
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = YES;
    
    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData,nil];
    
    return securityPolicy;
}

- (void)AP_GET:(NSString *)URLString parameters:(NSMutableDictionary *)parameters IsToken:(BOOL)isToken success:(Success)success failure:(Failure)failure
{
    AFHTTPSessionManager *manager = [ZCNetWorking shareInstance];
    //    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    //    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //
    //    [manager setSecurityPolicy:[self customSecurityPolicy]];
    
    
    NSMutableSet *contentTypes = [[NSMutableSet alloc] initWithSet:manager.responseSerializer.acceptableContentTypes];
    [contentTypes addObject:@"text/html"];
    [contentTypes addObject:@"text/plain"];
    
    manager.responseSerializer.acceptableContentTypes = self.acceptableContentTypes;
    manager.requestSerializer.timeoutInterval = (self.timeoutInterval ? self.timeoutInterval : 10);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString * tempBaseUrl;
    /*
    if ([[NSUserDefaults standardUserDefaults]objectForKey:Environment]) {
        NSString * URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:Environment];
        if ([URLStr isEqualToString:official_Environment_key]) {
            tempBaseUrl = BASEURL_officialEnvironment;
        }else if([URLStr isEqualToString:test_Environment_key]){
            tempBaseUrl = BASEURL_testEnvironment;
        }
    }
     */
    //NSString * urlStr = [NSString stringWithFormat:@"%@%@",tempBaseUrl,URLString];
    /*
    if (isToken) {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
            NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
            UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [parameters setValue:userModel.access_token forKey:@"access_token"];
            [parameters setValue:userModel.user_id forKey:@"user_id"];
        }
    }
    */
     NSLog(@"ap 请求接口 :%@==%@",URLString,parameters);
    _task = [manager GET:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        NSLog(@"ap 后台返回 :%@",responseObject);
        if (ret == 1003 ) {
            if (![unitl isRefreshTokenSucceed]) {
                NSLog(@"上次用refreshToken刷新token时间【成功】5");
                @synchronized (Refresh_Lock){
                    [self refreshTokenUrlStr:URLString parameters:parameters IsToken:isToken success:success failure:failure isPost:YES];
                }
            }else
            {
                NSLog(@"上次用refreshToken刷新token时间还未超过10s，不予刷新~5");
            }
            return ;
        }
        if (ret == 1002) {
            [XHToast showTopWithText:NSLocalizedString(@"您的账号已在其它设备登录", nil)];
            NSLog(@"后台返回登录过期2:%@",[unitl getCurrentTimes]);
            NSError *error = [[NSError alloc]init];
            if (failure)
            {
                failure(error);
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:BACKLOGIN object:nil];
        }
        else {
            if(success)
            {
               // NSDictionary * safeResponseObject = [responseObject dictionaryByReplacingNulls];
                success(responseObject);
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; // 关闭状态栏动画
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure)
        {
            failure(error);
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (void)AP_POST:(NSString *)URLString parameters:(NSMutableDictionary *)parameters IsToken:(BOOL)isToken success:(Success)success failure:(Failure)failure
{
    AFHTTPSessionManager *manager = [ZCNetWorking shareInstance];
    //    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //
    //    [manager setSecurityPolicy:[self customSecurityPolicy]];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];   // 请求JSON格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer]; // 响应JSON格式
    [manager.requestSerializer setValue:@"application/json"forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json;charset=utf-8"forHTTPHeaderField:@"Content-Type"];
    
    NSMutableSet *contentTypes = [[NSMutableSet alloc] initWithSet:manager.responseSerializer.acceptableContentTypes];
    [contentTypes addObject:@"text/html"];
    [contentTypes addObject:@"text/plain"];
    [contentTypes addObject:@"application/json"];
    [contentTypes addObject:@"charset=utf-8"];
    [contentTypes addObject:@"text/javascript"];
    [contentTypes addObject:@"text/json"];
    
    manager.responseSerializer.acceptableContentTypes = self.acceptableContentTypes;
    manager.requestSerializer.timeoutInterval = (self.timeoutInterval ? self.timeoutInterval : 10);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; // 开启状态栏动画

    
    // NSLog(@"ap_post 请求接口 :%@==%@",URLString,parameters);
    _task = [manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       // NSLog(@"ap_post 请求接口,返回数据 :%@==",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 1003 ) {
           // [self refreshTokenUrlStr:URLString parameters:parameters IsToken:isToken success:success failure:failure isPost:YES];
            return ;
        }
        else {
            if(success)
            {
              //  NSDictionary * safeResponseObject = [responseObject dictionaryByReplacingNulls];
                success(responseObject);
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; // 关闭状态栏动画
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure)
        {
            failure(error);
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO]; // 关闭状态栏动画
    }];
}

@end

