//
//  BaseNavigationViewController.m
//  ZhongWeiEyes
//
//  Created by 张策 on 16/10/20.
//  Copyright © 2016年 张策. All rights reserved.
//

#import "BaseNavigationViewController.h"
#import "UIImage+image.h"


@interface BaseNavigationViewController ()<UIViewControllerTransitioningDelegate>

@end

@implementation BaseNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:18], NSForegroundColorAttributeName:RGB(255, 255, 255)};
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        appearance.backgroundColor = MAIN_COLOR;
        appearance.titleTextAttributes = titleTextAttributes;
        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        self.navigationBar.barTintColor = MAIN_COLOR;
        [self.navigationBar setTitleTextAttributes:titleTextAttributes];
    }
    self.navigationBar.translucent = NO;
    self.supportLandscape = NO;

}
- (UIInterfaceOrientationMask) navigationControllerSupportedInterfaceOrientations:(UINavigationController *) navigationController{
    if(self.supportLandscape){
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeRight;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}



@end
