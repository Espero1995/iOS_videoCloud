//
//  ZCTabBarController.m
//  ZCTabBarController
//
//  Created by 张策 on 15/12/4.
//  Copyright © 2015年 ZC. All rights reserved.
//



#import "ZCTabBarController.h"
#import "UIImage+image.h"
#import "ZCNavigationController.h"
#import "ZCTabBar.h"
#import "ZCTabBarButton.h"

#import "BaseNavigationViewController.h"
#import "WeiCloudViewController.h"
#import "MessageViewController.h"
#import "FindViewController.h"
#import "MineViewController.h"
#import "UpdataViewController.h"

#import "FourPingTransition.h"
#import "PushMsgModel.h"
#import <CloudPushSDK/CloudPushSDK.h>
@interface ZCTabBarController ()<ZCTabBarDelegate,UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic,weak)ZCTabBar *tabMine;
@property (nonatomic, weak) WeiCloudViewController *weiCloudVC;
@property (nonatomic,weak) FindViewController *findVC;
@property (nonatomic,weak) MineViewController *mineVC;
@property (nonatomic,weak)MessageViewController *messageVC;
@property (nonatomic,weak)UpdataViewController *updataVC;

@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,strong) NSMutableArray *readArr;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 添加所有子控制器
    [self setUpAllChildViewController];
  
    
    // 自定义tabBar
    [self setUpTabBar];
    //转场动画代理
    self.transitioningDelegate = self;
    _timer =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getMesgCount) userInfo:nil repeats:YES];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [CloudPushSDK bindAccount:userModel.user_id withCallback:^(CloudPushCallbackResult *res) {
        }];
    }

}
#pragma mark ------检查消息
- (void)getMesgCount
{
    [self.readArr removeAllObjects];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:PUSH]) {
        NSData *data1 = [[NSUserDefaults standardUserDefaults]objectForKey:PUSH];
        NSMutableArray *pushArrData = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
        NSMutableArray *pushArr = [NSMutableArray arrayWithArray:pushArrData];
        for (PushMsgModel *model in pushArr) {
            if (model.isRead == NO) {
                [self.readArr addObject:model];
            }
        }
    }
    if (self.readArr.count != 0) {
        _messageVC.tabBarItem.badgeValue =@"............";
    }
    else{
        _messageVC.tabBarItem.badgeValue = @"";
    }
}
#pragma mark ------结束定时器
- (void)stopTimer
{
    [_timer invalidate];   // 将定时器从运行循环中移除，
    _timer = nil;
}
#pragma mark - 设置tabBar
- (void)setUpTabBar
{
    self.supportLandscape = NO;

    // 自定义tabBar
    ZCTabBar *tabBar = [[ZCTabBar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-49, [UIScreen mainScreen].bounds.size.width, 49)];
    tabBar.backgroundColor = [UIColor whiteColor];
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tabBar.bounds.size.width, 1)];
    lab.backgroundColor = [UIColor grayColor];
    lab.alpha = 0.3;
    [tabBar addSubview:lab];
    // 设置代理
    tabBar.delegate = self;
    
    // 给tabBar传递tabBarItem模型
    tabBar.items = self.items;
    
    // 添加自定义tabBar
    [self.view addSubview:tabBar];
    _tabMine = tabBar;
    
    // 移除系统的tabBar
    [self.tabBar removeFromSuperview];
}

#pragma mark - 当点击tabBar上的按钮调用
- (void)tabBar:(ZCTabBar *)tabBar didClickButton:(NSInteger)index
{
        self.selectedIndex = index;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


#pragma mark - 添加所有的子控制器
- (void)setUpAllChildViewController
{
    // 威云首页
    WeiCloudViewController *weiCloudVC = [[WeiCloudViewController alloc] init];
    [self setUpOneChildViewController:weiCloudVC image:[UIImage imageNamed:@"home_12weiyun_n"] selectedImage:[UIImage imageWithOriginalName:@"home_12weiyun_h"] title:@"威云"];
    _weiCloudVC = weiCloudVC;
    
    
 
    // 发现
//   FindViewController *findVC = [[FindViewController alloc] init];
//    [self setUpOneChildViewController:findVC image:[UIImage imageNamed:@"newhome_find_n"] selectedImage:[UIImage imageWithOriginalName:@"newhome_find_h"] title:@"发现"];
//    _findVC = findVC;
    
//    UpdataViewController *updataVc = [[UpdataViewController alloc]init];
//      [self setUpOneChildViewController:updataVc image:[UIImage imageNamed:@"newhome_find_n"] selectedImage:[UIImage imageWithOriginalName:@"newhome_find_h"] title:@"发现"];
//    _updataVC = updataVc;
    
    
    //消息
    MessageViewController *messageVC = [[MessageViewController alloc]init];
    [self setUpOneChildViewController:messageVC image:[UIImage imageNamed:@"newhome_message_n"] selectedImage:[UIImage imageNamed:@"newhome_message_h"] title:@"消息"];
    _messageVC = messageVC;
    
    //我的
    MineViewController *mineVC = [[MineViewController alloc]init];
    [self setUpOneChildViewController:mineVC image:[UIImage imageNamed:@"newhome_myself_n"] selectedImage:[UIImage imageNamed:@"newhome_myself_h"] title:@"我的"];
    _mineVC = mineVC;


    
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

}
#pragma mark ------登录转场动画
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [FourPingTransition transitionWithTransitionType:XWPresentOneTransitionTypePresent];
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [FourPingTransition transitionWithTransitionType:XWPresentOneTransitionTypeDismiss];
}
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
