//
//  ConfigOccupiedVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/3/20.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import "ConfigOccupiedVC.h"
#import "ZCTabBarController.h"
@interface ConfigOccupiedVC ()

/**
 * @brief 提交按钮
 */
@property (strong, nonatomic) IBOutlet UIButton *submitBtn;
/**
 * @brief 摄像头图片
 */
@property (strong, nonatomic) IBOutlet UIImageView *cameraImg;
/**
 * @brief 摄像头机型
 */
@property (strong, nonatomic) IBOutlet UILabel *cameraLb;
/**
 * @brief 顶部图片
 */
@property (strong, nonatomic) IBOutlet UIImageView *headImg;

@end

@implementation ConfigOccupiedVC

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

#pragma mark - setUI
- (void)setUpUI
{
    [self createNavEmptyBtn];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.submitBtn.layer.cornerRadius = 22.5f;
    [self.cameraImg sd_setImageWithURL:[NSURL URLWithString:self.configModel.devImgURL] placeholderImage:[UIImage imageNamed:@"CloudPic"]];
    self.cameraLb.text = self.configModel.deviceType;
    self.headImg.image = [UIImage imageNamed:NSLocalizedString(@"config_occupid", nil)];
}

#pragma mark - 返回点击事件
- (void)returnVC
{
    //无需触发事件，此处就是为空方法
}

#pragma mark - 提交点击事件
- (IBAction)submitClick:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
