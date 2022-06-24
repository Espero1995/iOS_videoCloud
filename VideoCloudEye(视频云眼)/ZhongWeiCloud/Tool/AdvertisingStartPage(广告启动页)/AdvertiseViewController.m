//
//  AdvertiseViewController.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/30.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "AdvertiseViewController.h"
#import "ZCTabBarController.h"
@interface AdvertiseViewController ()
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation AdvertiseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"发现", nil);
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.backgroundColor = [UIColor whiteColor];
    if (!self.adUrl) {
        self.adUrl = @"https://shop488828177.m.taobao.com";
    }
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.adUrl]];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
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

- (void)setAdUrl:(NSString *)adUrl
{
    _adUrl = adUrl;
}

@end
