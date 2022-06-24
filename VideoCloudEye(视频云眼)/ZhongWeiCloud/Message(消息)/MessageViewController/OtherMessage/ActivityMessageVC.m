//
//  ActivityMessageVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/29.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "ActivityMessageVC.h"
#import "ZCTabBarController.h"
@interface ActivityMessageVC ()

@end

@implementation ActivityMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"活动提醒", nil);
     [self cteateNavBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
}

@end
