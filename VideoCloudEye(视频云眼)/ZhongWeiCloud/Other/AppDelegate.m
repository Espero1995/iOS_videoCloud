//
//  AppDelegate.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/9.
//  Copyright © 2017年 张策. All rights reserved.
//
#import "GetAccountInfo.h"
#import "AccountLoginNewVC.h"
#import "FingerPrintLoginVC.h"//指纹登录
#import "AppDelegate.h"
#import <IQKeyboardManager.h>
#import "BaseNavigationViewController.h"
#import "ZCTabBarController.h"
#import "PushMsgModel.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <AlipaySDK/AlipaySDK.h>
//广告页
#import "AdvertiseView.h"
#import "AdvertiseVC.h"
#import "NSObject+Tool.h"
#import "AlarmMsgVC.h"
//有赞商城
#import "WebViewController.h"
//阿里推送
#import <CloudPushSDK/CloudPushSDK.h>
// iOS 10 notification
#import <UserNotifications/UserNotifications.h>

#import "WeChatVerifyVC.h"
#import "JWOpenSdk.h"
#import "fingerPrintLoginManage.h"
#import "AppSettingsModel.h"
#import <Bugly/Bugly.h>

@interface AppDelegate ()
<
UNUserNotificationCenterDelegate,
TencentSessionDelegate,
UIApplicationDelegate,
WXApiDelegate
>
@property (nonatomic,strong) AdvertiseVC *advertiseVC;
@end

@implementation AppDelegate
{
    // iOS 10通知中心
    UNUserNotificationCenter *_notificationCenter;
}

//当APP为关闭状态时，点击通知栏消息跳转到指定的页面
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [unitl saveDataWithKey:NAV_Status Data:@"NAV_Status_DOWN"];
    
    //3D展示，及时渲染【使用Cocoapods pod 'LookinServer', :configurations => ['Debug']】并安装Lookin进行实时预览
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_3D" object:nil];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:Environment]) {
        NSString * URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:Environment];
        if ([URLStr isEqualToString:official_Environment_key]) {
            NSLog(@"【本次启动---正式环境】");
        }else if([URLStr isEqualToString:test_Environment_key]){
            NSLog(@"【本次启动---测试环境】");
        }
    }else{
        //默认正式环境
        [[NSUserDefaults standardUserDefaults]setObject:official_Environment_key forKey:Environment];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    NSLog(@"launchOptions:%@",launchOptions);
    //初始化bugly
    [Bugly startWithAppId:BUGLY_APP_ID];
    //注册阿里云推送
    [self registerCloudPushApplication:application Options:launchOptions];
    //获取基本的url
    [self getBaseUrl];
    
    if (launchOptions) {//由消息点击进入
        UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        NSLog(@"【app 在后台】点击推送跳转消息界面1");
        [self directGoingToAppointMessageInterface];

    }else{//正常判断用户是否登录进入
        BOOL isLogin = [[[NSUserDefaults standardUserDefaults]objectForKey:ISLOGIN] boolValue];
        if (isLogin)
        {
//            [self addADView]; //添加广告页
            [self getAppSettings];//获取app内tabbar 的标签个数
            BOOL openFingerPrint;
            NSString * temppStr = [unitl getDataWithKey:[NSString stringWithFormat:@"%@%@",FingerPrint_key,[unitl get_User_id]]];
            if ([temppStr isEqualToString:@"YES"]) {
                openFingerPrint = YES;
            }else{
                openFingerPrint = NO;
            }
            NSLog(@"openFingerPrint:%@==temppStr:%@",openFingerPrint?@"YES":@"NO",temppStr);

            __block AppDelegate *blockSelf = self;
            
            if (openFingerPrint) {
                FingerPrintLoginVC *fingerLoginVC = [[FingerPrintLoginVC alloc]init];
                BaseNavigationViewController *NVC = [[BaseNavigationViewController alloc]initWithRootViewController:fingerLoginVC];
                blockSelf.window.rootViewController = NVC;
                blockSelf.window.backgroundColor = [UIColor whiteColor];
                [blockSelf.window makeKeyAndVisible];
                
                [fingerLoginVC faceIDLoginResult:^(fingerLoginResult LoginResult) {
                    if (LoginResult == fingerLoginResultSuccess) {
                        [blockSelf directGoingToMainInterface];
                    }else if (LoginResult == fingerLoginResultErrorTouchIDLockout)
                    {
                        NSLog(@"该设备，Touch ID被锁，需要用户输入密码解锁");
                        [blockSelf directGoingToAppointFingerPrintLoginInterface];
                    }
                    else //指纹/面容 登录失败
                    {
                        [blockSelf directGoingToAppointAccountLoginInterface];
                    }
                }];
            }else{
                [blockSelf directGoingToMainInterface];
            }
            
            
            /*
            self.advertiseVC.skipButtonClickBlock = ^{
                if (openFingerPrint) {
                    FingerPrintLoginVC *fingerLoginVC = [[FingerPrintLoginVC alloc]init];
                    BaseNavigationViewController *NVC = [[BaseNavigationViewController alloc]initWithRootViewController:fingerLoginVC];
                    blockSelf.window.rootViewController = NVC;
                    blockSelf.window.backgroundColor = [UIColor whiteColor];
                    [blockSelf.window makeKeyAndVisible];
                    
                    [fingerLoginVC faceIDLoginResult:^(fingerLoginResult LoginResult) {
                        if (LoginResult == fingerLoginResultSuccess) {
                            [blockSelf directGoingToMainInterface];
                        }else if (LoginResult == fingerLoginResultErrorTouchIDLockout)
                        {
                            NSLog(@"该设备，Touch ID被锁，需要用户输入密码解锁");
                            [blockSelf directGoingToAppointFingerPrintLoginInterface];
                        }
                        else //指纹/面容 登录失败
                        {
                            [blockSelf directGoingToAppointAccountLoginInterface];
                        }
                    }];
                }else{
                    [blockSelf directGoingToMainInterface];
                }
            };
            self.advertiseVC.imageClickBlock = ^{
                if (openFingerPrint) {
                    FingerPrintLoginVC *fingerLoginVC = [[FingerPrintLoginVC alloc]init];
                    BaseNavigationViewController *NVC = [[BaseNavigationViewController alloc]initWithRootViewController:fingerLoginVC];
                    blockSelf.window.rootViewController = NVC;
                    blockSelf.window.backgroundColor = [UIColor whiteColor];
                    [blockSelf.window makeKeyAndVisible];
                    
                    [fingerLoginVC faceIDLoginResult:^(fingerLoginResult LoginResult) {
                        if (LoginResult == fingerLoginResultSuccess) {
                            //===========
                            if (isOverSeas) {
                                [blockSelf directGoingToMainInterface];
                            }else{
                              [blockSelf directGoingToAppointAdInterface];
                            }
                            //===========
                        }else if (LoginResult == fingerLoginResultErrorTouchIDLockout)
                        {
                            NSLog(@"该设备，Touch ID被锁，需要用户输入密码解锁");
                            [blockSelf directGoingToAppointFingerPrintLoginInterface];
                        }
                        else //指纹/面容 登录失败
                        {
                            [blockSelf directGoingToAppointAccountLoginInterface];
                        }
                    }];
                }else{
                    //===========
                    if (isOverSeas) {
                        [blockSelf directGoingToMainInterface];
                    }else{
                        [blockSelf directGoingToAppointAdInterface];
                    }
                    //===========
                }
            };
            */
        }else{
            [self directGoingToAppointAccountLoginInterface];
        }
    }
    //键盘
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    
    
    APP_Environment environment = [unitl environment];
    NSString * weixinAppIDStr;
    switch (environment) {
        case Environment_official:
            weixinAppIDStr = weixinAppID_test;//这边貌似就用一个。后台和申请开放平台的开发人员也说的
            break;
        case Environment_test:
            weixinAppIDStr = weixinAppID_test;//weixinAppID_official
            break;
        default:
            break;
    }
    //注册微信ID
    [WXApi registerApp:weixinAppIDStr];
    TencentOAuth * TencentOAuthResult =  [[TencentOAuth alloc] initWithAppId:@"101511050" andDelegate:self];//weixinAppSecret/@"1106248144"//@"101511050"
    NSLog(@"TencentOAuthResult :%@",TencentOAuthResult);
    return YES;
}

#pragma mark - 注册阿里云推送相关
- (void)registerCloudPushApplication:(UIApplication *)application Options:(NSDictionary *)launchOptions
{
    //推送
    // APNs注册，获取deviceToken并上报
    [self registerAPNS:application];
    // 初始化SDK
    [self initCloudPush];
    // 监听推送通道打开动作
    [self listenerOnChannelOpened];
    // 监听推送消息到达
    [self registerMessageReceive];
    // 点击通知将App从关闭状态启动时，将通知打开回执上报
    // [CloudPushSDK handleLaunching:launchOptions];(Deprecated from v1.8.1)
    [CloudPushSDK sendNotificationAck:launchOptions];
    
    NSString *deveid = [CloudPushSDK getDeviceId];
    NSLog(@"CloudPushSDK  deveid===%@",deveid);
}

#pragma mark - 直接进入主界面
- (void)directGoingToMainInterface
{
    dispatch_async(dispatch_get_main_queue(),^{
        ZCTabBarController *mainTabVC = [[ZCTabBarController alloc]init];
        [mainTabVC setVideoSdk];
        mainTabVC.tabSelectIndex = 0;
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.rootViewController = mainTabVC;
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
    });
}

#pragma mark - 直接进入指纹登录界面
- (void)directGoingToAppointFingerPrintLoginInterface
{
    dispatch_async(dispatch_get_main_queue(),^{
        FingerPrintLoginVC *fingerLoginVC = [[FingerPrintLoginVC alloc]init];
        BaseNavigationViewController *NVC = [[BaseNavigationViewController alloc]initWithRootViewController:fingerLoginVC];
        self.window.rootViewController = NVC;
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
    });
}

#pragma mark - 直接进入账号登录界面
- (void)directGoingToAppointAccountLoginInterface
{
    dispatch_async(dispatch_get_main_queue(),^{
        AccountLoginNewVC *loginVC = [[AccountLoginNewVC alloc]init];
        BaseNavigationViewController *NVC = [[BaseNavigationViewController alloc]initWithRootViewController:loginVC];
        self.window.rootViewController = NVC;
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
    });
}

#pragma mark - 直接跳转广告指定界面
- (void)directGoingToAppointAdInterface
{
    dispatch_async(dispatch_get_main_queue(),^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        //有赞商城
        WebViewController *webVC = [[WebViewController alloc] init];
        webVC.loadUrl = self.advertiseVC.adModel.linkUrl;
        webVC.hidesBottomBarWhenPushed = YES;
        ZCTabBarController *rootVC = [[ZCTabBarController alloc] init];
        [rootVC setVideoSdk];
        webVC.isAdPush = YES;
        [self.window setRootViewController:rootVC];
        [self.window addSubview:rootVC.view];
        [self.window makeKeyAndVisible];
        ZCTabBarController *baseTabBar = (ZCTabBarController *)self.window.rootViewController;
        [baseTabBar.viewControllers[baseTabBar.selectedIndex] pushViewController:webVC animated:NO];
    });
}

#pragma mark - 由推送消息点击进入指定界面
- (void)directGoingToAppointMessageInterface
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //进入消息界面
    AlarmMsgVC *messageVC = [[AlarmMsgVC alloc] init];
    messageVC.hidesBottomBarWhenPushed = YES;
    ZCTabBarController *rootVC = [[ZCTabBarController alloc] init];
    [rootVC setVideoSdk];
    [self.window setRootViewController:rootVC];
    [self.window addSubview:rootVC.view];
    [self.window makeKeyAndVisible];
    ZCTabBarController *baseTabBar = (ZCTabBarController *)self.window.rootViewController;
    [baseTabBar.viewControllers[baseTabBar.selectedIndex] pushViewController:messageVC animated:NO];
}

#pragma mark - 添加广告页
- (void)addADView
{
    //广告启动页
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.advertiseVC = [[AdvertiseVC alloc]init];
    self.window.rootViewController = self.advertiseVC;
    
    BaseUrlModel *urlModel = [BaseUrlDefaults geturlModel];
    NSMutableArray *adArr = [NSMutableArray arrayWithCapacity:0];
    if (urlModel.advertisingUrl) {
        adArr = [AdUrlModel mj_objectArrayWithKeyValuesArray:urlModel.advertisingUrl];
    }else{
        AdUrlModel *admodel1 = [[AdUrlModel alloc]init];
        admodel1.linkUrl = PT12LINKURL;
        admodel1.imageUrl = PT12IMGURL;
        [adArr addObject:admodel1];
        AdUrlModel *admodel2 = [[AdUrlModel alloc]init];
        admodel2.linkUrl = C11LINKURL;
        admodel2.imageUrl = C11IMGURL;
        [adArr addObject:admodel2];
    }
    AdUrlModel *admodel = adArr[arc4random() % adArr.count];
    self.advertiseVC.adModel = admodel;
    self.advertiseVC.duration = 5;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([url isEqual:[NSString stringWithFormat:@"tencent1106248144"]]) {
        return [TencentOAuth HandleOpenURL:url];
    }else{
        return [WXApi handleOpenURL:url delegate:self];
    }
}

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
    /****支付宝支付***/
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            if ([resultDic[@"resultStatus"] intValue] == 9000) {
                [[NSNotificationCenter defaultCenter]postNotificationName:PAYSUCCESSJUMPTOVC object:nil];
            }else if ([resultDic[@"resultStatus"] intValue] == 6001){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"温馨提示", nil)
                                                                message:NSLocalizedString(@"您退出了支付操作", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
    }
    /*
    if ([url.host isEqualToString:@"pay"]) {
        //处理微信的支付结果
        [WXApi handleOpenURL:url delegate:self];
    }
    */
    
    if ([url isEqual:[NSString stringWithFormat:@"tencent1106248144"]]) {
        return [TencentOAuth HandleOpenURL:url];
    }else {
        return [WXApi handleOpenURL:url delegate:self];
    }
    return YES;

}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    /****支付宝支付***/
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
        }];
        
        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
    }else if ([url.host isEqualToString:@"pay"])
    {
        //处理微信的支付结果
        [WXApi handleOpenURL:url delegate:self];
    }
    return YES;
}

/*! 微信回调，不管是登录还是分享成功与否，都是走这个方法 @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
- (void)onResp:(BaseResp *)resp
{
    NSLog(@"微信回调处理:%@",resp);
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {   //授权登录的类。
        if (resp.errCode == 0) {  //成功。
            SendAuthResp *resp2 = (SendAuthResp *)resp;
            if (self.wxDelegate && [self.wxDelegate respondsToSelector:@selector(loginSuccessByCode:)]) {
                 [self.wxDelegate loginSuccessByCode:resp2.code];
            }
        }else{ //失败
            NSLog(@"error %@",resp.errStr);
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"登录失败" message:[NSString stringWithFormat:@"reason : %@",resp.errStr] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil,nil];
//            [alert show];
        }
    }
    
    
    //分享的回调处理有问题先注释
    /**
    // 处理 分享请求 回调
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        
        switch (resp.errCode) {
            case WXSuccess:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"分享成功!"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
                break;
                
            default:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"分享失败!"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
                break;
        }
    }
     */
    //启动微信支付的response
    NSString *payResoult = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        switch (resp.errCode) {
            case 0:
                payResoult = @"支付结果：成功！";
                break;
            case -1:
                payResoult = @"支付结果：失败！";
                break;
            case -2:
                payResoult = @"用户已经退出支付！";
                break;
            default:
                payResoult = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
                break;
        }
        
        
        if (resp.errCode == 0) {
            [[NSNotificationCenter defaultCenter]postNotificationName:PAYSUCCESSJUMPTOVC object:nil];
            NSLog(@"支付成功");
        }else if (resp.errCode == -1){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"温馨提示", nil)
                                                            message:NSLocalizedString(@"支付失败", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }else if (resp.errCode == -2){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"温馨提示", nil)
                                                            message:NSLocalizedString(@"您退出了支付操作", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}


#pragma mark APNs Register
/**
 *	向APNs注册，获取deviceToken用于推送
 *
 *	@param 	application
 */
- (void)registerAPNS:(UIApplication *)application {
    float systemVersionNum = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersionNum >= 10.0) {
        // iOS 10 notifications
        _notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        // 创建category，并注册到通知中心
        [self createCustomNotificationCategory];
        
        _notificationCenter.delegate = self;
         
        // 请求推送权限
        [_notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // granted
                NSLog(@"User authored notification.");
                // 向APNs注册，获取deviceToken
                dispatch_async(dispatch_get_main_queue(), ^{
                    [application registerForRemoteNotifications];
                });
                
            } else {
                // not granted
                NSLog(@"User denied notification.");
            }
        }];
    } else if (systemVersionNum >= 8.0) {
        // iOS 8 Notifications
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [application registerUserNotificationSettings:
         [UIUserNotificationSettings settingsForTypes:
          (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                           categories:nil]];
        [application registerForRemoteNotifications];
#pragma clang diagnostic pop
    } else {
        // iOS < 8 Notifications
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
#pragma clang diagnostic pop
    }
}

/**
 *  主动获取设备通知是否授权(iOS 10+)
 */
- (void)getNotificationSettingStatus {
    [_notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            NSLog(@"User authed.");
        } else {
            NSLog(@"User denied.");
        }
    }];
}

/*
 *  APNs注册成功回调，将返回的deviceToken上传到CloudPush服务器
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Upload deviceToken to CloudPush server.");
    [CloudPushSDK registerDevice:deviceToken withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Register deviceToken success, deviceToken: %@", [CloudPushSDK getApnsDeviceToken]);
        } else {
            NSLog(@"Register deviceToken failed, error: %@", res.error);
        }
    }];
}
/*
 *  APNs注册失败回调
 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@", error);
}
/**
 *  创建并注册通知category(iOS 10+)
 */
- (void)createCustomNotificationCategory {
    // 自定义`action1`和`action2`
    UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"action1" title:@"test1" options: UNNotificationActionOptionNone];
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"action2" title:@"test2" options: UNNotificationActionOptionNone];
    // 创建id为`test_category`的category，并注册两个action到category
    // UNNotificationCategoryOptionCustomDismissAction表明可以触发通知的dismiss回调
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"test_category" actions:@[action1, action2] intentIdentifiers:@[] options:
                                        UNNotificationCategoryOptionCustomDismissAction];
    // 注册category到通知中心
    [_notificationCenter setNotificationCategories:[NSSet setWithObjects:category, nil]];
}

/**
 *  处理iOS 10通知(iOS 10+)
 */
- (void)handleiOS10Notification:(UNNotification *)notification {
    UNNotificationRequest *request = notification.request;
    UNNotificationContent *content = request.content;
    
    NSDictionary *userInfo = content.userInfo;
    NSLog(@"告警推送:%@",content.userInfo);
    
    // 通知时间
    NSDate *noticeDate = notification.date;
    // 标题
    NSString *title = content.title;
    // 副标题
    NSString *subtitle = content.subtitle;
    // 内容
    NSString *body = content.body;
    // 角标
    int badge = [content.badge intValue];
    // 取得通知自定义字段内容，例：获取key为"Extras"的内容
    NSString *extras = [userInfo valueForKey:@"Extras"];
    // 通知打开回执上报
    [CloudPushSDK sendNotificationAck:userInfo];
    NSLog(@"Notification, date: %@, title: %@, subtitle: %@, body: %@, badge: %d, extras: %@.", noticeDate, title, subtitle, body, badge, extras);
}
/**
 *  App处于前台时收到通知(iOS 10+)
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"Receive a notification in foregound.");
    // 处理iOS 10通知，并上报通知打开回执
    [self handleiOS10Notification:notification];
    // 通知不弹出
   // completionHandler(UNNotificationPresentationOptionNone);
    
    // 通知弹出，且带有声音、内容和角标
    completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge);
}

/**
 *  触发通知动作时回调，比如点击、删除通知和点击自定义action(iOS 10+)
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSString *userAction = response.actionIdentifier;
    // 点击通知打开
    if ([userAction isEqualToString:UNNotificationDefaultActionIdentifier]) {
        // 处理iOS 10通知，并上报通知打开回执
        [self handleiOS10Notification:response.notification];
        /**
         【app 在后台】点击通知栏的消息界面，跳转消息界面。
         */
        NSLog(@"【app 在后台】点击推送跳转消息界面2");
        [self directGoingToAppointMessageInterface];
    }
    // 通知dismiss，category创建时传入UNNotificationCategoryOptionCustomDismissAction才可以触发
    if ([userAction isEqualToString:UNNotificationDismissActionIdentifier]) {
        NSLog(@"User dismissed the notification.");
    }
    NSString *customAction1 = @"action1";
    NSString *customAction2 = @"action2";
    // 点击用户自定义Action1
    if ([userAction isEqualToString:customAction1]) {
        NSLog(@"User custom action1.");
    }
    
    // 点击用户自定义Action2
    if ([userAction isEqualToString:customAction2]) {
        NSLog(@"User custom action2.");
    }
    completionHandler();
}

#pragma mark SDK Init
- (void)initCloudPush {
    // 正式上线建议关闭
   // [CloudPushSDK turnOnDebug];
    // SDK初始化
    [CloudPushSDK asyncInit:CloudPushAppKey appSecret:CloudPushAppSecret callback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Push SDK init success, deviceId: %@.", [CloudPushSDK getDeviceId]);
        } else {
            NSLog(@"Push SDK init failed, error: %@", res.error);
        }
    }];
}


#pragma mark Notification Open
/*
 * 当APP在后台运行时，点击通知栏消息跳转到指定的页面
 */
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
    NSLog(@"Receive one notification.didReceiveRemoteNotification");
    //当APP在前台运行时，不做处理
    if( [UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
    }
    //当APP在后台运行时，当有通知栏消息时，点击它，就会执行下面的方法跳转到相应的页面
    else if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive)
    {
        BOOL isLogin = [[[NSUserDefaults standardUserDefaults]objectForKey:ISLOGIN] boolValue];
        if (isLogin)
        {
            NSNumber *isLoginNum  = [[NSUserDefaults standardUserDefaults]objectForKey:ISLOGIN];
            BOOL islogin = [isLoginNum boolValue];
            if (islogin) {
                NSLog(@"【app 在后台】点击推送跳转消息界面:%@",userInfo);
                [self directGoingToAppointMessageInterface];
            }
        }
    }
    /*
    // 取得APNS通知内容
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    // 内容
    NSString *content = [aps valueForKey:@"alert"];
    // badge数量
    NSInteger badge = [[aps valueForKey:@"badge"] integerValue];
    // 播放声音
    NSString *sound = [aps valueForKey:@"sound"];
    // 取得通知自定义字段内容，例：获取key为"Extras"的内容
    NSString *Extras = [userInfo valueForKey:@"Extras"]; //服务端中Extras字段，key是自己定义的
    NSLog(@"content = [%@], badge = [%ld], sound = [%@], Extras = [%@]", content, (long)badge, sound, Extras);
    // iOS badge 清0
    application.applicationIconBadgeNumber = 0;
    // 通知打开回执上报
   //  [CloudPushSDK handleReceiveRemoteNotification:userInfo];(Deprecated from v1.8.1)
    [CloudPushSDK sendNotificationAck:userInfo];
     */
    application.applicationIconBadgeNumber = 0;
}

#pragma mark Channel Opened
/**
 *	注册推送通道打开监听
 */
- (void)listenerOnChannelOpened {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onChannelOpened:)
                                                 name:@"CCPDidChannelConnectedSuccess"
                                               object:nil];
}

/**
 *	推送通道打开回调
 *
 *	@param 	notification
 */
- (void)onChannelOpened:(NSNotification *)notification {
    NSLog(@"消息通道建立成功");
}

#pragma mark Receive Message
/**
 *	@brief	注册推送消息到来监听
 */
- (void)registerMessageReceive {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageReceived:)
                                                 name:@"CCPDidReceiveMessageNotification"
                                               object:nil];
}

/**
 *	处理到来推送消息
 */
- (void)onMessageReceived:(NSNotification *)notification {
//    NSLog(@"Receive one message!===notification：%@",notification);
    
    /*
    CCPSysMessage *message = [notification object];
//    NSString *title = [[NSString alloc] initWithData:message.title encoding:NSUTF8StringEncoding];
    NSString *body = [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding];
    PushMsgModel *pushModel = [PushMsgModel mj_objectWithKeyValues:body];
    
    
    //==================================
    //存储最新的推送过来的model
    NSString * userID = [unitl get_User_id];
    NSString * tempStrKey = [unitl getKeyWithSuffix:userID Key:@"user_id_push"];
    [unitl saveNeedArchiverDataWithKey:tempStrKey Data:pushModel];
    //==================================

    pushModel.markread = NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *UserID = [defaults objectForKey:@"user_id_push"];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:UserID]) {
        NSData *data1 = [[NSUserDefaults standardUserDefaults]objectForKey:UserID];
        NSMutableArray *pushArrData = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
        NSMutableArray *pushArr = [NSMutableArray arrayWithArray:pushArrData];
        [pushArr insertObject:pushModel atIndex:0];
        NSArray *DataArr = [NSArray arrayWithArray:pushArr];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:DataArr];
        [[NSUserDefaults standardUserDefaults]setObject:data forKey:UserID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        NSMutableArray *pushArr = [NSMutableArray array];
        [pushArr insertObject:pushModel atIndex:0];
        NSArray *DataArr = [NSArray arrayWithArray:pushArr];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:DataArr];
        [[NSUserDefaults standardUserDefaults]setObject:data forKey:UserID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
     */
    //专门针对事件进行存储
    //==========================================
    
    
    //==========================================
}

//#pragma mark 禁止横屏
//- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
//    return UIInterfaceOrientationMaskPortrait;
//}

- (void)applicationWillResignActive:(UIApplication *)application {

}

//进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"【应用进入后台】");
    [[UIApplication sharedApplication]beginBackgroundTaskWithExpirationHandler:^(){
        //程序在10分钟内未被系统关闭或者强制关闭，则程序会调用此代码块，可以在这里做一些保存或者清理工作
        //解除绑定
        
//        [CloudPushSDK unbindAccount:^(CloudPushCallbackResult *res) {
//            NSLog(@"推送解除绑定：%@",res.success?@"YES":@"NO");
//        }];
        
        NSLog(@"程序关闭");
    }];
    [[NSNotificationCenter defaultCenter]postNotificationName:BEBACKGROUNDSTOP object:nil];
}

//进入前台
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter]postNotificationName:BEBEFORSTART object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:RECHECKNETSTATUS object:nil];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"【杀死应用】");
}

-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (self.allowRotation) {//当允许时，支持所有方向
        return UIInterfaceOrientationMaskAll;
    }
    if (self.allowRotation == NO) {
        return UIInterfaceOrientationMaskPortrait;
    }
    //否则 就只有竖屏
    return UIInterfaceOrientationMaskPortrait;
}

#pragma 获取下面tabbar的功能的开关信息
- (void)getAppSettings
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:@"200" forKey:@"app_plat"];
    [dic setObject:APPVERSION forKey:@"app_ver"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/app/getAppSettings" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        NSLog(@"【tabbar 的功能的开关信息】:%@",responseObject);
        if (ret == 0) {
            NSMutableDictionary * updataBody = responseObject[@"body"];
            BOOL bodyIsNull;
            if(!updataBody) bodyIsNull = YES;
            else  bodyIsNull = NO;
            AppSettingsModel * appSettingModel = [[AppSettingsModel alloc]init];
            appSettingModel.message = updataBody[@"extParams"][@"modelFeature"][@"message"];
            appSettingModel.dev = updataBody[@"extParams"][@"modelFeature"][@"dev"];
            appSettingModel.find = updataBody[@"extParams"][@"modelFeature"][@"find"];
            appSettingModel.mine = updataBody[@"extParams"][@"modelFeature"][@"mine"];
            [unitl saveNeedArchiverDataWithKey:AppSettings Data:appSettingModel];
        }
    } failure:^(NSError * _Nonnull error) {
    }];
}

#pragma mark - 获取基础URL
- (void)getBaseUrl
{
    NSString *isBangScreen;
    if (iPhone_X_) {
        isBangScreen = @"6.5";
    }else{
        isBangScreen = @"5.5";
    }
    NSNumber *languageType;
    if (isSimplifiedChinese) {
        languageType = [NSNumber numberWithInt:1];
    }else{
        languageType = [NSNumber numberWithInt:2];
    }
    NSDictionary *postDic = @{@"resolution":isBangScreen,@"app_type":@200,@"languageType":languageType};//[unitl getDeviceScreenSize]

    [[HDNetworking sharedHDNetworking]POST:@"v1/user/getUrls" parameters:postDic success:^(id  _Nonnull responseObject) {
//        NSLog(@"responseObject：%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            BaseUrlModel *urlModel = [BaseUrlModel mj_objectWithKeyValues:responseObject[@"body"]];
            [BaseUrlDefaults setUrlModel:urlModel];
        }else{
            //并不需要广告页的url，在展示的时候已经为其添加
            BaseUrlModel *urlModel = [[BaseUrlModel alloc]init];
            urlModel.appHelpUrl = HELPLINK;
            urlModel.userAgreementUrl = USERAGREEMENTLINK;
            urlModel.appDownloadUrl = APPDOWNLOADLINK;
            urlModel.bannerBaseUrl = APPBANNERLINK;
            [BaseUrlDefaults setUrlModel:urlModel];
        }
    } failure:^(NSError * _Nonnull error) {
        //并不需要广告页的url，在展示的时候已经为其添加
        BaseUrlModel *urlModel = [[BaseUrlModel alloc]init];
        urlModel.appHelpUrl = HELPLINK;
        urlModel.userAgreementUrl = USERAGREEMENTLINK;
        urlModel.appDownloadUrl = APPDOWNLOADLINK;
        urlModel.bannerBaseUrl = APPBANNERLINK;
        [BaseUrlDefaults setUrlModel:urlModel];
    }];
}

/*
//启动广告页
- (void)StartAdvertising{
    // 1.判断沙盒中是否存在广告图片，如果存在，直接显示
    NSString *filePath = [self getFilePathWithImageName:[kUserDefaults valueForKey:adImageName]];
    
    BOOL isExist = [self isFileExistWithFilePath:filePath];
    if (isExist) {// 图片存在
        AdvertiseView *advertiseView = [[AdvertiseView alloc] initWithFrame:self.window.bounds];
        advertiseView.filePath = filePath;
        [advertiseView show];
    }else{
        AdvertiseView *advertiseView = [[AdvertiseView alloc] initWithFrame:self.window.bounds];
        advertiseView.defaultImg = [UIImage imageNamed:@"defaultLaunchImg"];
        [advertiseView show];
    }
    // 2.无论沙盒中是否存在广告图片，都需要重新调用广告接口，判断广告是否更新
    [self getAdvertisingImage];
}


 // 判断文件是否存在
- (BOOL)isFileExistWithFilePath:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = FALSE;
    return [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
}

 //初始化广告页面
- (void)getAdvertisingImage
{
    // TODO 请求广告接口
    // 一些固定的图片url代替
    NSArray *imageArray = @[@"http://yun.joyware.com/zwsyimg/engine-logo1.png",@"http://yun.joyware.com/zwsyimg/engine-logo2.png",@"http://yun.joyware.com/zwsyimg/engine-logo1.png",@"http://yun.joyware.com/zwsyimg/engine-logo2.png"];
    NSString *imageUrl = imageArray[arc4random() % imageArray.count];
    
    NSArray *stringArr = [imageUrl componentsSeparatedByString:@"/"];
//    NSLog(@"%@",stringArr);
    NSString *imageName = stringArr.lastObject;
    
    // 拼接沙盒路径
    NSString *filePath = [self getFilePathWithImageName:imageName];
    BOOL isExist = [self isFileExistWithFilePath:filePath];
    if (!isExist){// 如果该图片不存在，则删除老图片，下载新图片
        [self downloadAdImageWithUrl:imageUrl imageName:imageName];
    }
}

 //下载新图片
- (void)downloadAdImageWithUrl:(NSString *)imageUrl imageName:(NSString *)imageName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        UIImage *image = [UIImage imageWithData:data];
        
        NSString *filePath = [self getFilePathWithImageName:imageName]; // 保存文件的名称
        
        if ([UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES]) {// 保存成功
            NSLog(@"保存成功");
            [self deleteOldImage];
            [kUserDefaults setValue:imageName forKey:adImageName];
            [kUserDefaults synchronize];
            // 如果有广告链接，将广告链接也保存下来
        }else{
            NSLog(@"保存失败");
        }
    });
}
 
 //删除旧图片
- (void)deleteOldImage
{
    NSString *imageName = [kUserDefaults valueForKey:adImageName];
    if (imageName) {
        NSString *filePath = [self getFilePathWithImageName:imageName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

 //根据图片名拼接文件路径
- (NSString *)getFilePathWithImageName:(NSString *)imageName
{
    if (imageName) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:imageName];
        
        return filePath;
    }
    
    return nil;
}
*/

//#pragma mark 微信登录回调。
//-(void)loginSuccessByCode:(NSString *)code{
//    NSLog(@"微信登录回调code: %@",code);

////    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
////    manager.requestSerializer = [AFJSONRequestSerializer serializer];//请求
////    manager.responseSerializer = [AFHTTPResponseSerializer serializer];//响应
////    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json",@"text/plain",nil,nil];
////    //通过 appid  secret 认证code . 来发送获取 access_token的请求
////    [manager GET:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",weixinAppID,weixinAppSecret,code] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
////
////    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {  //获得access_token，然后根据access_token获取用户信息请求。
////
////        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
////        NSLog(@"微信登录回调dic %@",dic);
////
////        /*
////         access_token   接口调用凭证
////         expires_in access_token接口调用凭证超时时间，单位（秒）
////         refresh_token  用户刷新access_token
////         openid 授权用户唯一标识
////         scope  用户授权的作用域，使用逗号（,）分隔
////         unionid     当且仅当该移动应用已获得该用户的userinfo授权时，才会出现该字段
////         */
////        NSString* accessToken=[dic valueForKey:@"access_token"];
////        NSString* openID=[dic valueForKey:@"openid"];
////        [weakSelf requestUserInfoByToken:accessToken andOpenid:openID];
////    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
////        NSLog(@"微信登录回调error %@",error.localizedFailureReason);
////    }];
//
//}

//-(void)requestUserInfoByToken:(NSString *)token andOpenid:(NSString *)openID{
//
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    [manager GET:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",token,openID] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *dic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
//        NSLog(@"dic  ==== %@",dic);
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"error %ld",(long)error.code);
//    }];
//}


@end
