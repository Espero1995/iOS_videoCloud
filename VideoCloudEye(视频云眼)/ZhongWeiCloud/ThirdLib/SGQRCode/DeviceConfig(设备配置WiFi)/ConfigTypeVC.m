//
//  ConfigTypeVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/3/18.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import "ConfigTypeVC.h"
#import "ZCTabBarController.h"
#import "AddOverViewVC.h"//添加设备概述界面

@interface ConfigTypeVC ()
/**
 * @brief 二维码配置Wi-Fi View
 */
@property (strong, nonatomic) IBOutlet UIView *QRCodeView;

/**
 * @brief 无线智能配置 View
 */
@property (strong, nonatomic) IBOutlet UIView *smartConfigView;

/**
 * @brief 推荐图标（国际化使用）
 */
@property (strong, nonatomic) IBOutlet UIImageView *recommendImg;


@end

@implementation ConfigTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

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


#pragma mark - setUI
- (void)setUpUI
{
    if (isMainAccount) {
        self.navigationItem.title = NSLocalizedString(@"添加设备", nil);
    }else{
        self.navigationItem.title = NSLocalizedString(@"配置设备", nil);
    }
    
    
    [self cteateNavBtn];
    
    self.recommendImg.image = [UIImage imageNamed:NSLocalizedString(@"recommendImg", nil)];
    
    //QRCodeView Style
    UIImage *QRCodeBgImg = [UIImage imageNamed:@"config_bg"];
    self.QRCodeView.layer.contents = (id)QRCodeBgImg.CGImage;
    
    //QRCodeView Click
    UITapGestureRecognizer *QRCodeViewTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(QRCodeViewClick)];
    [self.QRCodeView addGestureRecognizer:QRCodeViewTap];
    
    //smartConfigView Style
    UIImage *smartConfigBgImg = [UIImage imageNamed:@"config_bg"];
    self.smartConfigView.layer.contents = (id)smartConfigBgImg.CGImage;
    
    //smartConfigView Click
    UITapGestureRecognizer *smartConfigViewTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(smartConfigViewClick)];
    [self.smartConfigView addGestureRecognizer:smartConfigViewTap];
    
}


#pragma mark - QRCodeView 点击事件
- (void)QRCodeViewClick
{
    
    if (self.configModel.enableWifi != 1) {
        [XHToast showCenterWithText:NSLocalizedString(@"该设备不支持无线网络", nil)];
        return ;
    }
    
    if ([self.configModel.deviceType isEqualToString:@"T12(6mm)"]) {
        [XHToast showCenterWithText:NSLocalizedString(@"该设备不支持\"设备扫码添加\"", nil)];
        return ;
    }
    
    AddOverViewVC *overView = [[AddOverViewVC alloc]init];
    overView.isQRCode = YES;
    overView.configModel = self.configModel;
    [self.navigationController pushViewController:overView animated:YES];
}

#pragma mark - smartConfigView 点击事件
- (void)smartConfigViewClick
{
    if (self.configModel.enableWifi != 1) {
        [XHToast showCenterWithText:NSLocalizedString(@"该设备不支持无线网络", nil)];
        return ;
    }
    
    AddOverViewVC *overView = [[AddOverViewVC alloc]init];
    overView.isQRCode = NO;
    overView.configModel = self.configModel;
    [self.navigationController pushViewController:overView animated:YES];
}





@end
