//
//  HelpVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/11/1.
//  Copyright © 2018 张策. All rights reserved.
//

#import "HelpVC.h"
#import <WebKit/WebKit.h>
#import "WebProgressLineLayer.h"
/*无内容是显示视图*/
#import "NoNetworkBGView.h"
#import "ZCTabBarController.h"
@interface HelpVC ()
<
    UIWebViewDelegate,
    NoNetworkBGViewDelegate
>
{
    WebProgressLineLayer *_progressLayer; ///< 网页加载进度条
}
@property(nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) NoNetworkBGView* bgView;//无内容时背景图
@end

@implementation HelpVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //这个方法的作用是在退出全屏时监听到,然后设置状态栏显示,状态栏显示的方法除了上面的代码,plist也要处理,退出全屏瞬间状态栏还是隐藏的,之后才又显示,这是个小缺陷。
    if (@available(iOS 12.0, *)){
        [self addObserverNotification];
    }
    
    [self cteateNavBtn];
    [self initView];
    [self loadWebUrl:self.url];
}

#pragma mark - 通知
-(void)addObserverNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(windowDidBecomeHidden:) name:UIWindowDidBecomeHiddenNotification object:nil];
}

-(void)windowDidBecomeHidden:(NSNotification *)nitice
{
    UIWindow * window = (UIWindow *)nitice.object;
    if(window){
        UIViewController *rootViewController = window.rootViewController;
        NSArray<__kindof UIViewController *> *viewVCArray = rootViewController.childViewControllers;
        if([viewVCArray.firstObject isKindOfClass:NSClassFromString(@"AVPlayerViewController")]){
            [UIApplication sharedApplication].statusBarHidden = NO;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)initView
{
    self.webView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight)];
    self.webView.delegate=self;
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(0);
        make.bottom.equalTo(self.view.mas_bottom);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(iPhoneWidth);
    }];
    _progressLayer = [WebProgressLineLayer layerWithFrame:CGRectMake(0, -1, iPhoneWidth, 2)];
    [self.view.layer addSublayer:_progressLayer];
}

//加载网页
- (void)loadWebUrl:(NSString*)url
{
    NSURL *u = [NSURL URLWithString:url];
    NSURLRequest *r = [NSURLRequest requestWithURL:u];
    [self.webView loadRequest:r];
}

- (void)returnVC
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }else{
        ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
        tabVC.tabHidden = NO;
        [self.navigationController popViewControllerFromBottom];
    }
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
    [self.bgView removeFromSuperview];
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

/// 网页加载失败
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_progressLayer finishedLoad];
    [self.webView addSubview:self.bgView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

#pragma mark - getter && setter
//无内容时的背景图
-(NoNetworkBGView *)bgView{
    if (!_bgView) {
        _bgView = [[NoNetworkBGView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight) bgColor:BG_COLOR bgImg:[UIImage imageNamed:@"noNetWork"] bgTip:NSLocalizedString(@"当前网络不可用", nil)];
    }
    _bgView.delegate = self;
    return _bgView;
}

#pragma mark - 无网络连接时刷新按钮点击事件
- (void)refreshBtnClick
{
    if ([self.webView canGoBack]) {
        [self.webView reload];
    }else{
        [self loadWebUrl:self.url];
    }
}

@end
