//
//  RcodeSuccessController.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/25.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "RcodeSuccessController.h"
#import "ZCTabBarController.h"
@interface RcodeSuccessController ()
@property (strong, nonatomic) IBOutlet UIImageView *deviceSuc_Img;

@end

@implementation RcodeSuccessController
- (void)viewWillAppear:(BOOL)animated {
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
- (void)viewDidLoad {
    [super viewDidLoad];
    if (isMainAccount) {
        self.navigationItem.title = NSLocalizedString(@"添加设备", nil);
    }else{
        self.navigationItem.title = NSLocalizedString(@"配置设备", nil);
    }
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.deviceSuc_Img sd_setImageWithURL:[NSURL URLWithString:self.dev_ImgUrl] placeholderImage:[UIImage imageNamed:@"CloudPic"]];
    [self cteateNavBtn];
}
- (IBAction)btnDoneClick:(id)sender {
    //发送删除设备的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:ADDORDELETEDEVICE object:nil userInfo:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)left_BarButtonItemAction {
//    [self.navigationController popToViewController:self.navigationController.childViewControllers[0] animated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
