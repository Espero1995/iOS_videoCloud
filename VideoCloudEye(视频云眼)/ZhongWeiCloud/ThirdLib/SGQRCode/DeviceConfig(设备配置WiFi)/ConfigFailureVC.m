//
//  ConfigFailureVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/3/19.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import "ConfigFailureVC.h"
#import "ConfigTypeVC.h"//添加设备类型界面
#import "SGScanningQRCodeVC.h"//扫描二维码界面
#import "HelpVC.h"//帮助文档界面
#import "ZCTabBarController.h"
@interface ConfigFailureVC ()
/**
 * @brief 重新添加按钮
 */
@property (strong, nonatomic) IBOutlet UIButton *reAddBtn;
/**
 * @brief 返回首页按钮
 */
@property (strong, nonatomic) IBOutlet UIButton *backHomeBtn;
/**
 * @brief 顶部图片
 */
@property (strong, nonatomic) IBOutlet UIImageView *headImg;

@end

@implementation ConfigFailureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
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

#pragma mark - setUI
- (void)setUpUI
{
    self.navigationItem.title = NSLocalizedString(@"步骤(3/3)", nil);
    [self createNavEmptyBtn];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    //reAddBtn Style
    self.reAddBtn.layer.cornerRadius = 22.f;
    //backHomeBtn Style
    self.backHomeBtn.layer.cornerRadius = 22.f;
    self.headImg.image = [UIImage imageNamed:NSLocalizedString(@"config_failure", nil)];
}

#pragma mark - 返回点击事件
- (void)returnVC
{
    //无需触发事件，此处就是为空方法
}

#pragma mark - 常见问题点击事件
- (IBAction)questionClick:(id)sender
{
    HelpVC *helpVC = [[HelpVC alloc]init];
    BaseUrlModel *urlModel = [BaseUrlDefaults geturlModel];
    helpVC.url = urlModel.appHelpUrl;
    [self.navigationController pushViewControllerFromTop:helpVC];
}

#pragma mark - 重新添加点击事件
- (IBAction)reAddClick:(id)sender
{
    if (self.isQRCode) {
        SGScanningQRCodeVC *QRCodeVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 7];
        [self.navigationController popToViewController:QRCodeVC animated:YES];
    }else{
        SGScanningQRCodeVC *QRCodeVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 6];
        [self.navigationController popToViewController:QRCodeVC animated:YES];
    }
}

#pragma mark - 返回首页点击事件
- (IBAction)returnBackHomeClick:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
