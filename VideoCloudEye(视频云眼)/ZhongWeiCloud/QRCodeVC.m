//
//  QRCodeVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/5/25.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "QRCodeVC.h"
#import "ZCTabBarController.h"
#import "SGQRCodeTool.h"
@interface QRCodeVC ()
@property (strong, nonatomic) IBOutlet UIImageView *QRCodeImg;

@end

@implementation QRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WiFi二维码";
    [self cteateNavBtn];
    NSLog(@"base64:%@",self.Base64EncryptedStr);
    [self setUpQRCode];//根据字符串生成二维码
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


#pragma mark - 根据字符串生成二维码
- (void)setUpQRCode
{
    self.QRCodeImg.image = [SGQRCodeTool SG_generateWithDefaultQRCodeData:self.Base64EncryptedStr imageViewWidth:1000.f];
 
}






@end
