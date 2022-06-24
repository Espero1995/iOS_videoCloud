//
//  ZCTabBarController.m
//  ZCTabBarController
//
//  Created by 张策 on 15/12/4.
//  Copyright © 2015年 ZC. All rights reserved.
//


#import "AccountLoginNewVC.h"
#import "ZCTabBarController.h"
#import "UIImage+image.h"
#import "ZCNavigationController.h"
#import "ZCTabBar.h"
#import "ZCTabBarButton.h"

#import "BaseNavigationViewController.h"


#import "WeiCloudVC.h"//首页 模式一
#import "FolderTreeVC.h"//首页 模式二
#import "LiveViewController.h"//直播
#import "MessageNewVC.h"//消息
#import "MyViewController.h"//我的
#import "WebViewController.h"//有赞商城

#import "FourPingTransition.h"
#import "PushMsgModel.h"
#import <CloudPushSDK/CloudPushSDK.h>

#import "NewSdkHead.h"

#import "JWOpenSdk.h"
//app tabbar 设置
#import "AppSettingsModel.h"


@interface ZCTabBarController ()<ZCTabBarDelegate>//,UIViewControllerTransitioningDelegate
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic,weak)ZCTabBar *tabMine;


@property (nonatomic, weak) WeiCloudVC *weiCloudVC;//首页 模式一
@property (nonatomic, weak) FolderTreeVC *folderTreeVC; // 首页 模式二
@property (nonatomic,weak) LiveViewController *liveVC;//直播
@property (nonatomic,weak) MessageNewVC *messageVC;//消息
@property (nonatomic,weak) MyViewController *myVC;//我的
@property (nonatomic, weak) WebViewController* youzanShoppingVC;/**< 有赞商城 */


@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,strong) NSMutableArray *readArr;
/*未读条数*/
@property (nonatomic,copy) NSString *unReadCount;

@end

@implementation ZCTabBarController

- (NSMutableArray *)readArr
{
    if (!_readArr) {
        _readArr = [NSMutableArray array];
    }
    return _readArr;
}

- (NSMutableArray *)items
{
    if (_items == nil) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (void)setTabSelectIndex:(NSUInteger )tabSelectIndex
{
    _tabSelectIndex = tabSelectIndex;
    self.selectedIndex = tabSelectIndex;
    _tabMine.selectTag = tabSelectIndex;
}


- (void)isTabarHidden:(BOOL)tabHidden
{
//    NSLog(@"我现在打算隐藏！");
    _tabHidden = tabHidden;
    if (tabHidden) {
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass: [ZCTabBar class]]) {
                 view.alpha = 0;
            }
        }
    }else{
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass: [ZCTabBar class]]) {
                   view.alpha = 1;
            }
        }
    }
}


- (void)setVideoSdk
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        MySingleton *singleton = [MySingleton shareInstance];
        NSString *nameStr = userModel.user_name;
        if ([nameStr isEqualToString:@""]) {
            singleton.userNameStr = @"";
        }else{
            singleton.userNameStr = nameStr;
        }
        
        [JWOpenSdk setAccessToken:userModel.access_token userid:userModel.user_id];
        NSLog(@"setVideoSdk 设置accessToken：%@  userID：%@",userModel.access_token,userModel.user_id);
//        [CloudPushSDK bindAccount:userModel.user_id withCallback:^(CloudPushCallbackResult *res) {
//            if (res.success) {
//                NSLog(@"【阿里云推送】绑定成功");
//            }else
//            {
//                NSLog(@"【阿里云推送】绑定失败");
//            }
//        }];
    }else//如果在本地没有找到保存字段。
    {
        
        
    }
    //注册心跳包服务
    BOOL StartHeartBeat = VmNet_StartStreamHeartbeatServer();
    if (StartHeartBeat) {
        NSLog(@"【心跳服务注册成功】");
    }else{
        NSLog(@"【心跳服务注册失败】");
    }
}
- (void)deallocVideoSdk
{
    VmNet_UnInit();
    NSLog(@"VmNet_UnInit");
    VmNet_StopStreamHeartbeatServer();//关闭heartbeat
    NSLog(@"【心跳服务关闭】");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 添加所有子控制器
    [self setUpAllChildViewController];
  
    // 自定义tabBar
    [self setUpTabBar];
    //转场动画代理
//    self.transitioningDelegate = self;
    
//    _timer =  [NSTimer scheduledTimerWithTimeInterval:RedDotTime target:self selector:@selector(getMessageRecord) userInfo:nil repeats:YES];//getMesgCount
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//        NSLog(@"userModel.user_id：：：：%@",userModel.user_id);
        [CloudPushSDK bindAccount:userModel.user_id withCallback:^(CloudPushCallbackResult *res) {
            if (res.success) {
                NSLog(@"【阿里云推送】绑定成功");
            }else
            {
                NSLog(@"【阿里云推送】绑定失败");
            }
        }];
    }
}


#pragma mark ------检查消息
- (void)getMesgCount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *UserID = [defaults objectForKey:@"user_id_push"];
//    NSLog(@"用户IDD：%@",UserID);
    if (UserID.length<1) {
        [self cancleLogin];
    }else{
        [self.readArr removeAllObjects];
        if ([[NSUserDefaults standardUserDefaults]objectForKey:UserID]) {
        NSData *data1 = [[NSUserDefaults standardUserDefaults]objectForKey:UserID];
        NSMutableArray *pushArrData = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
        NSMutableArray *pushArr = [NSMutableArray arrayWithArray:pushArrData];
        for (PushMsgModel *model in pushArr) {
            if (model.markread == NO) {
                [self.readArr addObject:model];
                }
            }
        }
    if (self.readArr.count != 0) {
//        _messageVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",(unsigned long)self.readArr.count];//100
        
        _messageVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lf",MAXFLOAT];//MAXFLOAT
        
//        NSLog(@"有数据啊！");
        }
    else{
        _messageVC.tabBarItem.badgeValue = @"";
//        NSLog(@"无数据啊！");
        }
    }
}



#pragma mark - 从后台查询未读报警消息记录
- (void)getMessageRecord
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [[HDNetworking sharedHDNetworking] GET:@"v1/alarm/unreadStats" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
//        NSLog(@"获取未读消息条数%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            self.unReadCount = responseObject[@"body"];
            if ([self.unReadCount intValue] == 0) {
                _messageVC.tabBarItem.badgeValue = @"";
            }else{
                _messageVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lf",MAXFLOAT];
            }
        }else{
            self.unReadCount = @"0";
        }
        
    } failure:^(NSError * _Nonnull error) {
        self.unReadCount = @"0";
    }];
}

- (void)cancleLogin{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:app_type forKey:@"app_type"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/user/logoutNew" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    //解除绑定
    
    [CloudPushSDK unbindAccount:^(CloudPushCallbackResult *res) {
        NSLog(@"推送解除绑定：%@",res.success?@"YES":@"NO");
    }];
     
    ZCTabBarController *tab = (ZCTabBarController *)self.tabBarController;
//    [tab stopTimer];
    [tab deallocVideoSdk];
    BOOL isLogin = NO;
    NSNumber *isLoginNum = [NSNumber numberWithBool:isLogin];
    [[NSUserDefaults standardUserDefaults]setObject:isLoginNum forKey:ISLOGIN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //判断根式图是哪一个
    UIWindow *window =  [[UIApplication sharedApplication] keyWindow];
    if ([window.rootViewController isKindOfClass:[BaseNavigationViewController class]]) {
        [self.tabBarController dismissViewControllerAnimated:YES completion:^{
        }];
    }else{
        AccountLoginNewVC *loginVC = [[AccountLoginNewVC alloc]init];
        BaseNavigationViewController *NVC = [[BaseNavigationViewController alloc]initWithRootViewController:loginVC];
        window.rootViewController = NVC;
    }
}


#pragma mark ------结束定时器
- (void)stopTimer
{
    [_timer invalidate];   // 将定时器从运行循环中移除，
    _timer = nil;
    [_messageVC stopTimer];
}

#pragma mark - 设置tabBar
- (void)setUpTabBar
{
    self.supportLandscape = NO;
    // 自定义tabBar
    ZCTabBar *tabBar = [[ZCTabBar alloc] init];
    tabBar.backgroundColor = [UIColor whiteColor];
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tabBar.bounds.size.width, 0.5)];
    lab.backgroundColor = RGBA(200, 200, 200, 0.9);
    [tabBar addSubview:lab];
    // 设置代理
    tabBar.delegate = self;
    
    // 给tabBar传递tabBarItem模型
    tabBar.items = self.items;
    
    // 添加自定义tabBar
    [self.view addSubview:tabBar];
    
    _tabMine = tabBar;
    
    [tabBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, iPhoneToolBarHeight));
    }];
    // 移除系统的tabBar
    [self.tabBar removeFromSuperview];
    NSLog(@"[UIApplication sharedApplication].statusBarFrame.size.height:%lf",[UIApplication sharedApplication].statusBarFrame.size.height);
}

#pragma mark - 当点击tabBar上的按钮调用
- (void)tabBar:(ZCTabBar *)tabBar didClickButton:(NSInteger)index
{
    self.tabLastSelectedIndex = self.selectedIndex;
    self.selectedIndex = index;
    self.tabSelectIndex = index;//这里如果不设置选中的tabSelectIndex，会导致，如果是获取的tabbar然后不是点击，设置的tabSelectIndex，会要多点击当前选中的indexItem一次，才会消失当前的蓝色选中标记、
    [self getMessageRecord];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


#pragma mark - 添加所有的子控制器
- (void)setUpAllChildViewController
{
    AppSettingsModel * appSettingModel = [[AppSettingsModel alloc]init];
    appSettingModel = [unitl getNeedArchiverDataWithKey:AppSettings];

    if (appSettingModel == nil) {
        
        //有无树节点
        NSLog(@"是否有树节点：%d",isNodeTreeMode);
        // 威云首页
        if (isNodeTreeMode){
            //模式二
            FolderTreeVC *folderTreeVC = [[FolderTreeVC alloc] init];
            [self setUpOneChildViewController:folderTreeVC image:[UIImage imageNamed:@"device_n"] selectedImage:[UIImage imageWithOriginalName:@"device_h"] title:NSLocalizedString(@"设备", nil)];
            _folderTreeVC = folderTreeVC;
        }else{
            //模式一
            WeiCloudVC *weiCloudVC = [[WeiCloudVC alloc] init];
            [self setUpOneChildViewController:weiCloudVC image:[UIImage imageNamed:@"device_n"] selectedImage:[UIImage imageWithOriginalName:@"device_h"] title:NSLocalizedString(@"设备", nil)];
            _weiCloudVC = weiCloudVC;
        }
        
        
        //消息
        MessageNewVC *messageVC = [[MessageNewVC alloc]init];
        [self setUpOneChildViewController:messageVC image:[UIImage imageNamed:@"home_message_n_1"] selectedImage:[UIImage imageWithOriginalName:@"home_message_h_1"] title:NSLocalizedString(@"消息", nil)];
        _messageVC = messageVC;
        
        /*
        if (!isOverSeas) {
            WebViewController *shopVC = [[WebViewController alloc] init];
            [self setUpOneChildViewController:shopVC image:[UIImage imageNamed:@"shop_n"] selectedImage:[UIImage imageWithOriginalName:@"shop_h"] title:NSLocalizedString(@"发现", nil)];
            shopVC.loadUrl = @"https://h5.youzan.com/v2/showcase/homepage?alias=2cgVDdXYf6";
            _youzanShoppingVC = shopVC;
        }
        */
        
        //我的
        MyViewController *myVC = [[MyViewController alloc]init];
        [self setUpOneChildViewController:myVC image:[UIImage imageNamed:@"user_n"] selectedImage:[UIImage imageWithOriginalName:@"user_h"] title:NSLocalizedString(@"我的", nil)];
        _myVC = myVC;
        
    }else{
        if ([appSettingModel.dev intValue] == 1) {
            
            //有无树节点
            NSLog(@"是否有树节点：%d",isNodeTreeMode);
            // 威云首页
            if (isNodeTreeMode) {
                FolderTreeVC *folderTreeVC = [[FolderTreeVC alloc] init];
                [self setUpOneChildViewController:folderTreeVC image:[UIImage imageNamed:@"device_n"] selectedImage:[UIImage imageWithOriginalName:@"device_h"] title:NSLocalizedString(@"设备", nil)];
                _folderTreeVC = folderTreeVC;
            }else{
                WeiCloudVC *weiCloudVC = [[WeiCloudVC alloc] init];
                [self setUpOneChildViewController:weiCloudVC image:[UIImage imageNamed:@"device_n"] selectedImage:[UIImage imageWithOriginalName:@"device_h"] title:NSLocalizedString(@"设备", nil)];
                _weiCloudVC = weiCloudVC;
            }
            
            
            
        }
     
        if ([appSettingModel.message intValue] == 1) {
            //消息
            MessageNewVC *messageVC = [[MessageNewVC alloc]init];
            [self setUpOneChildViewController:messageVC image:[UIImage imageNamed:@"home_message_n_1"] selectedImage:[UIImage imageWithOriginalName:@"home_message_h_1"] title:NSLocalizedString(@"消息", nil)];
            _messageVC = messageVC;
        }
        
        /*
        if (!isOverSeas) {
            if ([appSettingModel.find intValue] == 1) {
                WebViewController *shopVC = [[WebViewController alloc] init];
                [self setUpOneChildViewController:shopVC image:[UIImage imageNamed:@"shop_n"] selectedImage:[UIImage imageWithOriginalName:@"shop_h"] title:NSLocalizedString(@"发现", nil)];
                shopVC.loadUrl = @"https://h5.youzan.com/v2/showcase/homepage?alias=2cgVDdXYf6";
                _youzanShoppingVC = shopVC;
            }
        }
        */
        
        if ([appSettingModel.mine intValue] == 1) {
            //我的
            MyViewController *myVC = [[MyViewController alloc]init];
            [self setUpOneChildViewController:myVC image:[UIImage imageNamed:@"user_n"] selectedImage:[UIImage imageWithOriginalName:@"user_h"] title:NSLocalizedString(@"我的", nil)];
            _myVC = myVC;
        }
    }
}


#pragma mark - 添加一个子控制器
- (void)setUpOneChildViewController:(UIViewController *)vc image:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title
{
    vc.title = title;
    vc.tabBarItem.image = image;
    vc.tabBarItem.selectedImage = selectedImage;
    // 保存tabBarItem模型到数组
    [self.items addObject:vc.tabBarItem];
    BaseNavigationViewController *nvc = [[BaseNavigationViewController alloc]initWithRootViewController:vc];
    [self addChildViewController:nvc];
}

- (void)dealloc
{
   // [JWOpenSdk deallocSdk];
}

#pragma mark ------登录转场动画
//-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
//    return [FourPingTransition transitionWithTransitionType:XWPresentOneTransitionTypePresent];
//}
//
//-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
//    return [FourPingTransition transitionWithTransitionType:XWPresentOneTransitionTypeDismiss];
//}



//- (BOOL)shouldAutorotate
//{
//    // 获取当前的控制器
//    BaseNavigationViewController*navC = self.selectedViewController;
//    UIViewController *currentVC = navC.visibleViewController;
//    
//    // 因为默认shouldAutorotate是YES，所以每个不需要支持横屏的控制器都需要重写一遍这个方法
//    // 一般项目中要支持横屏的界面比较少，为了解决这个问题，就取反值：shouldAutorotate返回为YES的时候不能旋转，返回NO的时候可以旋转
//    // 所以只要重写了shouldAutorotate方法的控制器，并return了NO，这个控制器就可以旋转
//    // 当然，如果项目中支持横屏的界面占多数的话，可以不取反值。
//    NSLog(@"当前控制器：%@  是否支持旋转：%zd", currentVC, !currentVC.shouldAutorotate);
//    
//    return !currentVC.shouldAutorotate;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAll;
//}

@end
