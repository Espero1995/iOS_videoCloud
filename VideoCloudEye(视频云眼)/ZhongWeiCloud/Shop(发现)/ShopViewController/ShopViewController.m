//
//  ShopViewController.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/10.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "ShopViewController.h"
#import <WebKit/WebKit.h>
#import "ZCTabBarController.h"
#import "UIImage+image.h"
#import "BallLoading.h"
/*无内容是显示视图*/
#import "EmptyDataBGView.h"
#import "WebViewController.h"
@interface ShopViewController ()
<
UIWebViewDelegate,
WKNavigationDelegate
>
{
    WKWebView *webView;
}
//无内容时背景图
@property (nonatomic,strong)EmptyDataBGView *bgView;

@end

@implementation ShopViewController
//==========================system==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//==========================init==========================
- (void)setUpUI
{
    WebViewController *vc = [[WebViewController alloc]init];
    //vc.loginTime = indexPath.row;
    //目前支持有赞的店铺主页链接、商品详情链接、商品列表链接、订单列表、会员中心等
    vc.loadUrl = @"https://h5.youzan.com/v2/showcase/homepage?kdt_id=1110622&reft=1521795795175&spm=ol1110622";
    [self.navigationController pushViewController:vc animated:YES];
    
    /*
    self.navigationItem.title = @"小威商城";
    webView=[[WKWebView alloc]init];
    webView.backgroundColor = BG_COLOR;
    if (iPhoneWidth <= 320) {
        webView.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight);
    }else{
        webView.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-44);
    }
    NSURL *url = [NSURL URLWithString:@"https://shop488828177.m.taobao.com"];
    NSURLRequest *request= [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [webView setNavigationDelegate:self];
    
    [self.view addSubview:webView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh"] style:UIBarButtonItemStylePlain target:self action:@selector(reloadWebView)];
     */
}
//==========================method==========================
- (void)reloadWebView{
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://shop488828177.m.taobao.com"]]];
    
}


//==========================delegate==========================
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [BallLoading showBallInView:self.view andTip:@"网页加载中,请稍等..."];
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [BallLoading hideBallInView:self.view];
    [self.bgView removeFromSuperview];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [BallLoading hideBallInView:self.view];
    [self.view addSubview:self.bgView];
}
//==========================lazy loading==========================
#pragma mark ----- 懒加载
//无内容时的背景图
-(EmptyDataBGView *)bgView{
    if (!_bgView) {
        _bgView = [[EmptyDataBGView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-44-64) bgColor:BG_COLOR bgImg:[UIImage imageNamed:@"noNetWork"] bgTip:@"网页加载失败,请稍后再试"];
    }
    return _bgView;
}


@end
