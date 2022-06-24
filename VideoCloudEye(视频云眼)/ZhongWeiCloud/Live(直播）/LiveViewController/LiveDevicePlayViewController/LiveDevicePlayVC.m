//
//  LiveDevicePlayVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/16.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "LiveDevicePlayVC.h"
#import "ZCTabBarController.h"
@interface LiveDevicePlayVC ()

@end

@implementation LiveDevicePlayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [NSString stringWithFormat:@"我是第%ld组第%ld个",(long)self.section,(long)self.row];
    self.view.backgroundColor = BG_COLOR;
    //导航栏按钮
    [self cteateNavBtn];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
