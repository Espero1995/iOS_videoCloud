//
//  WebViewController.m
//  YouzaniOSDemo
//
//  Created by 可乐 on 16/10/13.
//  Copyright © 2016年 Youzan. All rights reserved.
//
#import "WebViewController.h"
#import "yzLoginViewController.h"
#import <YZBaseSDK/YZBaseSDK.h>
#import "YZDUICService.h"
#import <WebKit/WebKit.h>
#import "yzLoginUserModel.h"
#import "ZCTabBarController.h"
#import "LiveVideoVC.h"
#import "LiveListModel.h"
#import "WebProgressLineLayer.h"
/*无内容是显示视图*/
#import "NoNetworkBGView.h"
//下拉菜单栏
#import "YCXMenu.h"
#import "YCXMenuItem.h"
//腾讯API
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
//微信
#import "WXApi.h"
//分享弹框
#import "HomeShareView.h"

@interface WebViewController ()
<
    YZWebViewDelegate,
    YZWebViewNoticeDelegate,
    NoNetworkBGViewDelegate
>
{
    WebProgressLineLayer *_progressLayer; ///< 网页加载进度条
    BOOL isFailure;//是否请求失败
    BOOL isFirst;
}
@property (nonatomic, strong) YZWebView *webView;/**< 展示界面 */

@property (strong, nonatomic) UIBarButtonItem *closeBarButtonItem; /**< 关闭按钮 */
@property (nonatomic,strong) NoNetworkBGView* bgView;//无内容时背景图
@property (nonatomic,strong) NSArray *menuArray;
@end

@implementation WebViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // ⽣成⼀个配置对象
    YZConfig *conf = [[YZConfig alloc] initWithClientId:CLIENT_ID];
    conf.enableLog = NO; // 关闭 sdk 的 log 输出
    conf.scheme = @"yzwx"; // 配置 scheme 以便微信⽀付完成后跳转
    [YZSDK.shared initializeSDKWithConfig:conf]; // 使⽤配置初始化 SDK
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"发现", nil);
    [self initBarButtonItem];
    self.navigationItem.rightBarButtonItem.enabled = NO;//默认分享按钮不可用
//    self.loadUrl = @"https://h5.youzan.com/v2/showcase/homepage?alias=2cgVDdXYf6";
    [self loginAndloadUrl:self.loadUrl];

}

- (BOOL)navigationShouldPopOnBackButton {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
        self.navigationItem.leftItemsSupplementBackButton = YES;
        self.navigationItem.leftBarButtonItem = self.closeBarButtonItem;
        return NO;
    } else {
        return YES;
    }
}

- (void)dealloc {
    //Demo中 退出当前controller就清除用户登录信息
    [YZSDK.shared logout];
    _webView.delegate = nil;
    _webView.noticeDelegate = nil;
    _webView = nil;
}


#pragma mark - YZWebViewDelegate
- (void)webView:(YZWebView *)webView didReceiveNotice:(YZNotice *)notice
{
    __weak typeof(self) weakSelf = self;
    if ([weakSelf.webView canGoBack]) {
        self.navigationItem.leftBarButtonItem.title = nil;
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"back"];
    }else{
        self.navigationItem.leftBarButtonItem.title = nil;
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"VideoClose"];
    }
    switch (notice.type) {
        case YZNoticeTypeLogin: // 收到登陆请求
        {
            [self showLoginViewControllerIfNeeded];
            break;
        }
        case YZNoticeTypeShare: // 收到分享的回调数据
        {
            //            [self alertShareData:notice.response];
            [self shareH5:notice.response];
            break;
        }
        case YZNoticeTypeReady: // Web页面已准备好，可以调用分享接口
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            break;
        }
        default:
            break;
    }
}

- (BOOL)webView:(YZWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSHTTPURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSLog(@"response.statusCode：%ld",(long)response.statusCode);
    if (response.statusCode == 200) {
        isFailure = NO;
    }else{
        isFailure = YES;
    }
    //    //加载新链接时，分享按钮先置为不可用，直到有赞环境初始化成功方可使用
    //    self.navigationItem.rightBarButtonItem.enabled = NO;
    //    // 不做任何筛选
    NSURL * url = [request URL];
    NSString * urlStr = [NSString stringWithFormat:@"%@",url];
    NSLog(@"截取的url是：%@==",url);
    //http://121.40.154.199/open/openLive.html?device_id=000740851642&chan_id=1
    if ([urlStr rangeOfString:@"/open/openLive"].location != NSNotFound)
    {
        NSRange range = [urlStr rangeOfString:@"/open/openLive.html?"]; //现获取要截取的字符串位置
        NSString * result = [urlStr substringFromIndex:range.location]; //截取字符串
        NSString * chan_id_Str = [result substringFromIndex:[result rangeOfString:@"&chan_id="].location+9];
        NSString * temp_device_id_Str = [result substringToIndex:[result rangeOfString:@"&chan_id="].location];
        NSString * device_id_Str = [temp_device_id_Str substringFromIndex:[temp_device_id_Str rangeOfString:@"device_id="].location+10];
        NSLog(@"截取的url参数是：chan_id是:%@ === device_id 是:%@",chan_id_Str,device_id_Str);
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:device_id_Str forKey:@"device_id"];
        [dic setObject:chan_id_Str forKey:@"chan_id"];
        [[HDNetworking sharedHDNetworking]GET:@"v1/live/get" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
            NSLog(@"h5直播调整，后台返回：%@",responseObject);
            LiveListModel *listModel = [LiveListModel mj_objectWithKeyValues:responseObject[@"body"]];
            if (listModel.liveChans != nil) {
                NSMutableArray * tempArr = [NSMutableArray arrayWithArray:listModel.liveChans];
                liveChans * livechansModel = tempArr[0];
                //包含此字符串，代表是直播
                LiveVideoVC * LiveVideo = [[LiveVideoVC alloc]init];
                LiveVideo.play_info = livechansModel.play_info;
                LiveVideo.titleName = livechansModel.name;
                LiveVideo.liveDesc = livechansModel.desc;
                [self.navigationController pushViewController:LiveVideo animated:YES];
            }else
            {
                [XHToast showCenterWithText:NSLocalizedString(@"无直播相关参数", nil)];
            }
        } failure:^(NSError * _Nonnull error) {
            [XHToast showCenterWithText:NSLocalizedString(@"无直播相关参数", nil)];
        }];
        return NO;
    }else
    {
        return YES;
    }
}


- (void)webViewDidStartLoad:(id<YZWebView>)webView
{
    [_progressLayer finishedLoad];
    _progressLayer = [WebProgressLineLayer layerWithFrame:CGRectMake(0, -1, iPhoneWidth, 2)];
    [self.webView.layer addSublayer:_progressLayer];
    [_progressLayer startLoad];
}

- (void)webViewDidFinishLoad:(id<YZWebView>)webView
{
    [_progressLayer finishedLoad];
    [self.bgView removeFromSuperview];
    [webView evaluateJavaScript:@"document.title"
              completionHandler:^(id  _Nullable response, NSError * _Nullable error) {
                  self.navigationItem.title = response;
                  NSLog(@"TITLELLL: %@",response);
              }];
}

-(void)webView:(UIWebView* )webView didFailLoadWithError:(NSError* )error
{
    if (isFailure == YES) {
        //网页加载失败 调用此方法
        [_progressLayer finishedLoad];
        [self.webView addSubview:self.bgView];
    }
}

#pragma mark - Action
- (void)showLoginViewControllerIfNeeded
{
    //    if (self.loginTime == kLoginTimeNever) {
    //        return;
    //    }
    __weak typeof(self) weakSelf = self;
    [self presentNativeLoginViewWithBlock:^(BOOL success){
        if (success) {
            [weakSelf.webView reload];
        } else {
            if ([weakSelf.webView canGoBack]) {
                [weakSelf.webView goBack];
            }
        };
    }];
}

- (void)moreClickAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    //set title
    if (self.menuArray.count != 0) {
        if ([YCXMenu isShow]) {
            [YCXMenu dismissMenu];
        }else{
            [self showMenu:btn];
        }
    }else{
        self.menuArray = @[[YCXMenuItem menuItem:NSLocalizedString(@"刷新", nil) image:[UIImage imageNamed:@"h5refresh"] tag:100 userInfo:nil],[YCXMenuItem menuItem:NSLocalizedString(@"首页", nil) image:[UIImage imageNamed:@"h5backHome"] tag:101 userInfo:nil]];//,[YCXMenuItem menuItem:NSLocalizedString(@"分享", nil) image:[UIImage imageNamed:@"h5share"] tag:102 userInfo:nil]
        [self showMenu:btn];
    }
    
}

- (void)showMenu:(UIButton *)btn
{
    [YCXMenu showMenuInView:self.view fromRect:CGRectMake(iPhoneWidth-50,0, 50, 0) menuItems:self.menuArray selected:^(NSInteger index, YCXMenuItem *item) {
        switch (index) {
            case 0:
            {
                [self.webView reload];//刷新按钮：刷新当前页面
            }
                break;
            case 1:
            {
//                //返回首页按钮：返回首页
//                _webView = nil;
//                // 加载链接
//                [self loginAndloadUrl:self.loadUrl];
//                [self.view addSubview:self.webView];

                [self.webView removeFromSuperview];
                _webView.delegate = nil;
                _webView.noticeDelegate = nil;
                _webView = nil;
                isFirst = 1;
                [self loginAndloadUrl:self.loadUrl];
                [self.view addSubview:self.webView];
            }
                break;
            /*
            case 2:
            {
                //分享按钮：分享该H5页面
                [self.webView share];
            }
                break;
            */
            default:
                break;
        }
    }];
}

- (void)shareH5:(id)data
{
    NSDictionary *bodyDic = (NSDictionary *)data;
    
    [HomeShareView showWithTitle:NSLocalizedString(@"分享方式", nil) titArray:@[NSLocalizedString(@"QQ好友", nil), NSLocalizedString(@"QQ空间", nil), NSLocalizedString(@"微信好友", nil), NSLocalizedString(@"朋友圈", nil)] imgArray:@[@"H5QQ", @"H5QQzone", @"H5WeChat", @"H5CircleofFriends"] select:^(NSInteger row) {
        
        switch (row) {
            case 0:
                [self QQSeriesSharedClick:0 andSharedBody:bodyDic];//QQ
                break;
            case 1:
                [self QQSeriesSharedClick:1 andSharedBody:bodyDic];//QQ空间
                break;
            case 2:
                [self WeChatSeriesSharedClick:0 andSharedBody:bodyDic];//微信
                break;
            case 3:
                [self WeChatSeriesSharedClick:1 andSharedBody:bodyDic];//朋友圈
                break;
                
            default:
                break;
        }
        
    }];
    
}

#pragma mark - QQ系列分享【0：QQ，1：QQ空间】
- (void)QQSeriesSharedClick:(NSInteger)isQQ andSharedBody:(NSDictionary *)body
{
    NSString *link = body[@"link"];
    NSString *title = body[@"title"];
    NSString *description = body[@"desc"];
    NSString *previewImageUrl = body[@"imgUrl"];
    NSLog(@"body:%@",body);
    
    if (![TencentOAuth iphoneQQInstalled]) {
        NSLog(@"请移步 Appstore 去下载腾讯 QQ 客户端");
        [XHToast showCenterWithText:NSLocalizedString(@"你还没有安装QQ！", nil)];
    }else{
        QQApiNewsObject *newsObj = [QQApiNewsObject
                                    objectWithURL:[NSURL URLWithString:link]
                                    title:title
                                    description:description
                                    previewImageURL:[NSURL URLWithString:previewImageUrl]];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        QQApiSendResultCode sent;
        if (isQQ == 0) {
            //将内容分享到qq
            sent = [QQApiInterface sendReq:req];
        }else{
            //将内容分享到qzone
            sent = [QQApiInterface SendReqToQZone:req];
        }
    }
}

#pragma mark - 微信系列分享【0：微信，1：朋友圈】
- (void)WeChatSeriesSharedClick:(NSInteger)isWeChat andSharedBody:(NSDictionary *)body
{
    NSString *link = body[@"link"];
    NSString *title = body[@"title"];
    NSString *description = body[@"desc"];
    NSString *previewImageUrl = body[@"imgUrl"];
    
    //微信好友分享
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;//不是文档类型
        
        //分享场景：WXSceneSession = 好友列表 WXSceneTimeline = 朋友圈 WXSceneFavorite = 收藏
        if (isWeChat == 0) {
            req.scene = WXSceneSession;
        }else{
            req.scene = WXSceneTimeline;
        }
        
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = title;//分享标题
        message.description = description;//分享描述
        
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:previewImageUrl]];
        [message setThumbImage:[UIImage imageWithData:data]];//分享图片,使用SDK的setThumbImage方法可压缩图片大小
        //创建多媒体对象
        WXWebpageObject *webObj = [WXWebpageObject object];
        webObj.webpageUrl = link;//分享链接
        //完成发送对象实例
        message.mediaObject = webObj;
        req.message = message;
        [WXApi sendReq:req];
    }else{
        [XHToast showCenterWithText:NSLocalizedString(@"你还没有安装微信！", nil)];
    }
}


#pragma mark - 无网络连接时刷新按钮点击事件
- (void)refreshBtnClick
{
    if ([self.webView canGoBack]) {
        [self.webView reload];
    }else{
        [self loginAndloadUrl:self.loadUrl];
    }
}

- (void)closeItemBarButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backButtonAction
{
    __weak typeof(self) weakSelf = self;
    if ([weakSelf.webView canGoBack]) {
        [weakSelf.webView goBack];
    }else{
        if (self.isAdPush) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
            tabVC.tabHidden = NO;
            tabVC.tabSelectIndex = tabVC.tabLastSelectedIndex;
        }
        
    }
}

#pragma mark - Private
- (void)initBarButtonItem {
    //初始化关闭按钮
    self.closeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"关闭", nil) style:UIBarButtonItemStylePlain target:self action:@selector(closeItemBarButtonAction)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"h5moreclick"] style:UIBarButtonItemStyleDone target:self action:@selector(moreClickAction:)];
    
    //初始化后退按钮
    __weak typeof(self) weakSelf = self;
    if ([weakSelf.webView canGoBack]) {
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"后退", nil) style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
        self.navigationItem.leftBarButtonItem = backButtonItem;
    }else{
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"VideoClose"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
        self.navigationItem.leftBarButtonItem = backButtonItem;
    }
}

/**
 *  加载链接。
 *
 *  @remark 这里强制先登录再加载链接，你的工程里由你控制。
 *  @param urlString 链接
 */
- (void)loginAndloadUrl:(NSString*)urlString {
    if (self.loginTime != kLoginTimePrior) {
        [self loadWithString:urlString];
        return;
    }
    
    /**
     登录方法(在你使用时，应该换成自己服务器给的接口来获取access_token，cookie)
     */
    NSString * userID = [unitl get_User_id];
    NSString * yzlonginKey = [unitl getKeyWithSuffix:userID Key:youzanLoginModel];
    yzLoginUserModel * yzModel = [unitl getNeedArchiverDataWithKey:yzlonginKey];
    if (yzModel.access_token && yzModel.cookie_key && yzModel.cookie_value) {
        [YZDUICService loginWithOpenUid:[yzUserModel sharedManage].userId completionBlock:^(NSDictionary *resultInfo) {
            if (resultInfo) {
                [YZSDK.shared synchronizeAccessToken:yzModel.access_token
                                           cookieKey:yzModel.cookie_key
                                         cookieValue:yzModel.cookie_value];
                [self loadWithString:urlString];
            }
        }];
    }else{
        [self loginYouZan];
        [YZDUICService loginWithOpenUid:[yzUserModel sharedManage].userId completionBlock:^(NSDictionary *resultInfo) {
            if (resultInfo) {
                [YZSDK.shared synchronizeAccessToken:yzModel.access_token
                                           cookieKey:yzModel.cookie_key
                                         cookieValue:yzModel.cookie_value];
                [self loadWithString:urlString];
            }
        }];
    }
}

- (void)loadWithString:(NSString *)urlStr {
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    if ([NSThread isMainThread]) {
        [self.webView loadRequest:urlRequest];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.webView loadRequest:urlRequest];
        });
    }
}

/**
 唤起原生登录界面
 
 @param block 登录事件回调
 */
- (void)presentNativeLoginViewWithBlock:(LoginResultBlock)block {
    //    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    UINavigationController *navigation = [board instantiateViewControllerWithIdentifier:@"login"];
    //   yzLoginViewController *loginVC = [navigation.viewControllers objectAtIndex:0];
    yzLoginViewController * loginVC = [[yzLoginViewController alloc]init];
    loginVC.loginBlock = block; //买家登录结果
//    [self presentViewController:loginVC animated:YES completion:nil];
    [self.navigationController pushViewController:loginVC animated:YES];//TODO
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    if (self.presentedViewController)
    {
        [super dismissViewControllerAnimated:flag completion:completion];
    }
}


/**
 *  显示分享数据
 *
 *  @param data
 */
- (void)alertShareData:(id)data {
    NSDictionary *shareDic = (NSDictionary *)data;
    NSString *message = [NSString stringWithFormat:@"%@\r%@" , shareDic[@"title"],shareDic[@"link"]];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"数据已经复制到粘贴板", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"好", nil) otherButtonTitles:nil];
    [alertView show];
    //复制到粘贴板
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = message;
}


#pragma mark ==== 有赞登录
- (void)loginYouZan
{
    //有赞商城接入
    NSMutableDictionary * youzanDic = [NSMutableDictionary dictionary];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [youzanDic setValue:userModel.access_token forKey:@"access_token"];
        [youzanDic setValue:userModel.user_id forKey:@"user_id"];
    }
    [[HDNetworking sharedHDNetworking]POST:@"v1/youzan/open/login" parameters:youzanDic IsToken:NO success:^(id  _Nonnull responseObject) {
        NSLog(@"第一次失败 ，有赞商城接入【成功】：%@==%@",responseObject,responseObject[@"body"]);
        NSString *JSONString = responseObject[@"body"];
        yzLoginUserModel * yzModel = [[yzLoginUserModel alloc]init];
        // 将流转换为字典
        NSDictionary *dataDict = [unitl JSONStringToDictionary:JSONString];
        if(dataDict)
        {
            yzModel.access_token = dataDict[@"data"][@"access_token"];
            yzModel.cookie_key = dataDict[@"data"][@"cookie_key"];
            yzModel.cookie_value = dataDict[@"data"][@"cookie_value"];
            NSString * userID = [unitl get_User_id];
            NSString * yzlonginKey = [unitl getKeyWithSuffix:userID Key:youzanLoginModel];
            [unitl saveNeedArchiverDataWithKey:yzlonginKey Data:yzModel];
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"第一次失败，有赞商城接入【失败】：");
    }];
}

- (YZWebView*)webView
{
    if(!_webView)
    {
        _webView = [[YZWebView alloc]initWithWebViewType:YZWebViewTypeUIWebView];
        _webView.backgroundColor = BG_COLOR;
        _webView.multipleTouchEnabled = NO;
        _webView.delegate = self;
        _webView.noticeDelegate = self;
        if (iPhone_Xr || iPhone_XsMAX) {
            [self.view addSubview:_webView];
            _webView.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-54);
        }else{
            [self.view addSubview:_webView];
            if (@available(iOS 11.0, *)){
                [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.view.mas_centerX);
                    make.width.mas_equalTo(iPhoneWidth);
                    make.top.equalTo(self.view.mas_top).offset(0);
                    make.bottom.equalTo(self.view.mas_bottom).offset(0);
                }];
            }else{
                _webView.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-12);
            }

        }

    }
    return _webView;
}

//无内容时的背景图
-(NoNetworkBGView *)bgView{
    if (!_bgView) {
        _bgView = [[NoNetworkBGView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight) bgColor:BG_COLOR bgImg:[UIImage imageNamed:@"noNetWork"] bgTip:NSLocalizedString(@"当前网络不可用", nil)];
    }
    _bgView.delegate = self;
    return _bgView;
}

//下拉菜单数组
- (NSArray *)menuArray
{
    if (!_menuArray) {
        _menuArray = [NSArray array];
    }
    return _menuArray;
}

@end



