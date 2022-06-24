//
//  AboutUsAgreementVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/11/21.
//  Copyright © 2018 张策. All rights reserved.
//
#import "AboutUsAgreementVC.h"
#import "WebProgressLineLayer.h"
#import "ZCTabBarController.h"
@interface AboutUsAgreementVC ()
<
    UIWebViewDelegate
>
{
    WebProgressLineLayer *_progressLayer; ///< 网页加载进度条
}
@property(nonatomic,strong) UIWebView *webView;

@end

@implementation AboutUsAgreementVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self cteateNavBtn];
    [self initView];
    [self loadWebUrl:self.url];
    
    __block int a = 10;
    float sum = ^(float b, float c)
    {
        a = 2;
        return a*b*c;
    }(3,4);
    NSLog(@"乘🐓：%lf",sum);
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

-(void)initView
{
    self.webView=[[UIWebView alloc] init];
    self.webView.delegate=self;
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(0);
        make.bottom.equalTo(self.view.mas_bottom);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(iPhoneWidth);
    }];
    _progressLayer = [WebProgressLineLayer layerWithFrame:CGRectMake(0, -2, iPhoneWidth, 2)];
    [self.view.layer addSublayer:_progressLayer];
}

//==========================method==========================
//加载网页
- (void)loadWebUrl: (NSString*)url
{
    NSURL* u = [NSURL URLWithString:url];
    NSURLRequest* r = [NSURLRequest requestWithURL:u];
    [self.webView loadRequest:r];
}

//===========================delegate===========================
#pragma mark -UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_progressLayer startLoad];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_progressLayer finishedLoad];
    self.navigationItem.title = NSLocalizedString(@"拾光云服务协议", nil);
}


/// 网页加载失败
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [_progressLayer finishedLoad];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

@end
