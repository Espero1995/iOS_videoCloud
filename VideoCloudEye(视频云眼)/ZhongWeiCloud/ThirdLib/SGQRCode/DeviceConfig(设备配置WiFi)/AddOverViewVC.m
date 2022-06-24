//
//  AddOverViewVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/3/18.
//  Copyright © 2019 苏旋律. All rights reserved.

#import "AddOverViewVC.h"
#import "ZCTabBarController.h"
#import "ConnectWiFiVC.h"//连接Wi-Fim界面
#import "LocBannerView.h"
@interface AddOverViewVC ()

/**
 * @brief 轮播图父类 View
 */
@property (strong, nonatomic) IBOutlet UIView *SlideShowView;
/**
 * @brief 连接网络 Button
 */
@property (strong, nonatomic) IBOutlet UIButton *connectBtn;
/**
 * @brief 轮播图
 */
@property (nonatomic,strong) LocBannerView *bannerView;

@end

@implementation AddOverViewVC

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
    if (isMainAccount) {
        self.navigationItem.title = NSLocalizedString(@"添加设备", nil);
    }else{
        self.navigationItem.title = NSLocalizedString(@"配置设备", nil);
    }
    
    [self cteateNavBtn];
    
    //连接网络 Button Style
    self.connectBtn.layer.cornerRadius = 22.5f;
    self.connectBtn.alpha = 0.5f;
    self.connectBtn.userInteractionEnabled = NO;
    
    //SlideShowView
    [self.SlideShowView addSubview:self.bannerView];
    [self.bannerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.SlideShowView);
    }];
}


#pragma mark -
- (IBAction)agreeContectClick:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        self.connectBtn.backgroundColor = MAIN_COLOR;
        self.connectBtn.alpha = 1.f;
        self.connectBtn.userInteractionEnabled = YES;
    }else{
        self.connectBtn.alpha = 0.5f;
        self.connectBtn.userInteractionEnabled = NO;
    }
}

#pragma mark - 连接网络按钮点击事件
- (IBAction)connectClick:(id)sender
{
    ConnectWiFiVC *wifiVC = [[ConnectWiFiVC alloc]init];
    wifiVC.isQRCode = self.isQRCode;
    wifiVC.configModel = self.configModel;
    [self.navigationController pushViewController:wifiVC animated:YES];
}


#pragma mark - getters&&setters

- (LocBannerView *)bannerView
{
    if (!_bannerView) {
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        NSString *img1 = NSLocalizedString(@"config_banner1", nil);
        NSString *img2 = NSLocalizedString(@"config_banner2", nil);
        NSString *img3 = NSLocalizedString(@"config_banner3", nil);
        [tempArr addObject:img1];
        [tempArr addObject:img2];
        [tempArr addObject:img3];

        _bannerView = [[LocBannerView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneWidth/75*90) andImageArray:tempArr];
        _bannerView.backgroundColor = [UIColor clearColor];
    }
    return _bannerView;
}

- (void)dealloc
{
    [LocBannerView destroyTimer];
}

@end
