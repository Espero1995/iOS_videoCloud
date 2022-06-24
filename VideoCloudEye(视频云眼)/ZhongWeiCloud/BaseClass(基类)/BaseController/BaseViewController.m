//
//  BaseViewController.m
//  ZhongWeiEyes
//
//  Created by 张策 on 16/10/21.
//  Copyright © 2016年 张策. All rights reserved.
//

#import "AccountLoginNewVC.h"
#import "BaseViewController.h"
#import "ZCTabBarController.h"
#import <CloudPushSDK/CloudPushSDK.h>
#import "BaseNavigationViewController.h"
@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(goBackLogin:) name:BACKLOGIN object:nil];
//    [self setUpUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark ------通知进入后台停止播放
-(void)goBackLogin:(NSNotification *)noit
{
    [self performSelector:@selector(goBackLoginVc) withObject:nil afterDelay:2];
}
- (void)goBackLoginVc{
    /*
    //清除排序的数组
    if ([[NSUserDefaults standardUserDefaults]objectForKey:AFTERSORTVIDEOLISTARR]) {
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:AFTERSORTVIDEOLISTARR];
        [defaults synchronize];
    }
    */
    //解除绑定
    
    [CloudPushSDK unbindAccount:^(CloudPushCallbackResult *res) {
        NSLog(@"推送解除绑定：%@",res.success?@"YES":@"NO");
    }];
     
    ZCTabBarController *tab = (ZCTabBarController *)self.tabBarController;
    [tab stopTimer];
    [tab deallocVideoSdk];
    BOOL isLogin = NO;
    NSNumber *isLoginNum = [NSNumber numberWithBool:isLogin];
    [[NSUserDefaults standardUserDefaults]setObject:isLoginNum forKey:ISLOGIN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //判断根式图是哪一个
    UIWindow *window =  [[UIApplication sharedApplication] keyWindow];
    if ([window.rootViewController isKindOfClass:[BaseNavigationViewController class]]) {
        [self.tabBarController dismissViewControllerAnimated:YES completion:^{
            AccountLoginNewVC *loginVC = [[AccountLoginNewVC alloc]init];
            BaseNavigationViewController *NVC = [[BaseNavigationViewController alloc]initWithRootViewController:loginVC];
            window.rootViewController = NVC;
        }];
    }
    else{
        AccountLoginNewVC *loginVC = [[AccountLoginNewVC alloc]init];
        BaseNavigationViewController *NVC = [[BaseNavigationViewController alloc]initWithRootViewController:loginVC];
        window.rootViewController = NVC;
    }

}
- (void)setUpUI
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"playback_menu"] style:UIBarButtonItemStyleDone target:self action:@selector(presentLeftMenuViewController:)];
}

- (void)setUpNavBack
{
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"return"] style:UIBarButtonItemStylePlain target:self action:@selector(backReturn)];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title =@"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
}
- (void)backReturn
{
    [self.navigationController popViewControllerAnimated:YES];
}

//导航栏按钮(白色)
- (void)cteateNavBtn
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame= CGRectMake(0, 0, 64, 64);
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateHighlighted];
    backButton.userInteractionEnabled = YES;
    backButton.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
    [backButton addTarget:self action:@selector(returnVC) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)createNavEmptyBtn
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame= CGRectMake(0, 0, 64, 64);
    [backButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    backButton.userInteractionEnabled = YES;
    backButton.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
    [backButton addTarget:self action:@selector(returnVC) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftItem;
}

//导航栏按钮(黑色)
-(void)createNavBlackBtn{
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame= CGRectMake(0, 0, 64, 64);
//    [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 50)];
    [backButton setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateHighlighted];
    backButton.userInteractionEnabled = YES;
    [backButton addTarget:self action:@selector(returnVC) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
//    UIBarButtonItem * leftSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
//    leftSpace.width = -20;
    self.navigationItem.leftBarButtonItem = leftItem;//@[leftSpace,leftItem];
}

//返回上一页
- (void)returnVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}




@end
