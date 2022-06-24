//
//  UserAgreementVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/9.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "UserAgreementVC.h"
#import "WebProgressLineLayer.h"
@interface UserAgreementVC ()
<
    UIWebViewDelegate
>
{
    WebProgressLineLayer *_progressLayer; ///< 网页加载进度条
}

@property(nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) UIView* navView;//头部视图
@property (nonatomic,strong) UILabel* titleLb;//标题
@property (nonatomic,strong) UIView* line;//线条
@property (nonatomic,strong) UIButton *backBtn;//返回按钮
@end

@implementation UserAgreementVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavView];
    [self initView];
    [self loadWebUrl:self.url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//自定义导航栏
- (void)createNavView
{
    //头部视图
    [self.view addSubview:self.navView];
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(0);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, iPhoneNav_StatusHeight));
    }];
    [self.navView addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.navView);
        make.bottom.equalTo(self.navView.mas_bottom).offset(0);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 0.5));
    }];
    [self.navView addSubview:self.titleLb];
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.navView);
        if (iPhone_X_) {
            make.centerY.equalTo(self.navView.mas_centerY).offset(20);
        }else{
            make.centerY.equalTo(self.navView.mas_centerY).offset(7);
        }
    }];
    
    //返回按钮
    [self.view addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(10);
        make.centerY.equalTo(self.titleLb.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}

-(void)initView
{
    self.webView=[[UIWebView alloc] init];
    self.webView.delegate=self;
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(0);
        make.bottom.equalTo(self.view.mas_bottom);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(iPhoneWidth);
    }];
    _progressLayer = [WebProgressLineLayer layerWithFrame:CGRectMake(0, iPhoneNav_StatusHeight-2, iPhoneWidth, 2)];
    [self.view.layer addSublayer:_progressLayer];
}


//==========================method==========================
#pragma mark - 返回方法
- (void)returnBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
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
    self.titleLb.text = NSLocalizedString(@"拾光云服务协议", nil);
}


/// 网页加载失败
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [_progressLayer finishedLoad];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}


#pragma mark -getter&setter
//头部视图
- (UIView *)navView
{
    if (!_navView) {
        _navView = [[UIView alloc]init];
        _navView.backgroundColor = [UIColor whiteColor];
    }
    return _navView;
}
//线条
- (UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc]init];
        _line.backgroundColor = RGB(200, 200, 200);
    }
    return _line;
}
//标题
- (UILabel *)titleLb
{
    if (!_titleLb) {
        _titleLb = [[UILabel alloc]init];
        _titleLb.font = FONT(18);
    }
    return _titleLb;
}
//返回按钮
- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(returnBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}
@end
