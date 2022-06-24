//
//  BindingController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/3/20.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "BindingController.h"
#import "ZCTabBarController.h"
#import "WifiQRConfigVC.h"
#import "RcodeShowController.h"
//#import "WifiQRCodeVC.h"//smartConfig配置失败后使用二维码配置WiFi
@interface BindingController ()

@end

@implementation BindingController

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
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    self.title = NSLocalizedString(@"绑定", nil);
    [self cteateNavBtn];
    [self createUI];
}

- (void)createUI{
    //图片
//    UIImageView * pictureImage = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 77, 100) imageName:@"errorImage"];
    UIImageView *pictureImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    [pictureImage sd_setImageWithURL:[NSURL URLWithString:self.device_imgUrl] placeholderImage:[UIImage imageNamed:@"CloudPic"]];

    [self.view addSubview:pictureImage];
    [pictureImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(144);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    //提示信息
    UILabel * label = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:16]];
    label.text = NSLocalizedString(@"配置设备Wi-Fi失败", nil);
    label.textColor = [UIColor colorWithHexString:@"#020202"];
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 1;
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pictureImage.mas_bottom).offset(20);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    //重试按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 240, 40)];
    [button setTitle:NSLocalizedString(@"重试", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = MAIN_COLOR;
    button.layer.cornerRadius = 15;
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:self action:@selector(popVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.mas_bottom).offset(40);
        make.left.equalTo(self.view.mas_left).offset(iPhoneWidth/2-120);
        make.right.equalTo(self.view.mas_left).offset(iPhoneWidth/2+120);
    }];
    
    /*
    //PS:若设备名称发生更改，可能会造成显示问题（注意）
    if ([self.deviceTypeName isEqualToString:@"C11(2.6mm)"] || [self.deviceTypeName isEqualToString:@"C11"]) {
        UILabel * orLb = [FactoryUI createLabelWithFrame:CGRectZero text:@"或" font:[UIFont systemFontOfSize:16]];
        orLb.textColor = [UIColor grayColor];
        orLb.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:orLb];
        [orLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(button.mas_bottom).offset(15);
        }];
        
        
        //WiFi配置按钮
        UIButton *WifiConfigBtn = [FactoryUI createButtonWithFrame:CGRectZero title:@"使用二维码配置设备Wi-Fi" titleColor:[UIColor whiteColor] imageName:nil backgroundImageName:nil target:self selector:nil];
        WifiConfigBtn.backgroundColor = MAIN_COLOR;
        WifiConfigBtn.layer.cornerRadius = 15;
        WifiConfigBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [WifiConfigBtn addTarget:self action:@selector(wifiConfigClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:WifiConfigBtn];
        [WifiConfigBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(iPhoneWidth/2-120);
            make.top.equalTo(orLb.mas_bottom).offset(15);
            make.right.equalTo(self.view.mas_left).offset(iPhoneWidth/2+120);
        }];
     
        
    } */
    
}


- (void)popVC
{
//    [self.navigationController popToRootViewControllerAnimated:YES];
    RcodeShowController * RcodeShowVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 4];
    
    [self.navigationController popToViewController:RcodeShowVC animated:YES];
}
/*
#pragma mark - wifi配置
- (void)wifiConfigClick
{
//    NSLog(@"wifiName :%@;wifiPwd:%@",self.wifiName,self.wifiPwd);
    WifiQRCodeVC *wifiQrVC = [[WifiQRCodeVC alloc]init];
    wifiQrVC.ssidNameStr = self.wifiName;
    wifiQrVC.smartConfigWifiPwd = self.wifiPwd;
    [self.navigationController pushViewController:wifiQrVC animated:YES];
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
