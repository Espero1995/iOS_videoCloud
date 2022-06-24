//
//  ShareVideoToWeixinVC.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/5/10.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "ShareVideoToWeixinVC.h"
#import "ZCTabBarController.h"
#import "SettingCellTwo_t.h"//带switch的cell
#import "CustomTextField.h"
#import "WXApi.h"
#define shareURL_testEnvironment @"http://y.yun.joyware.com/joyLive/index.html" //测试环境
#define shareURL_officialEnvironment @"http://yun.joyware.com/joyLive/index.html" //正式环境
@interface ShareVideoToWeixinVC ()
<
UITableViewDelegate,
UITableViewDataSource
>

/**
 * 分享的当前视频的截图
 */
@property (nonatomic, strong) UIImageView* cutIV;
/**
 * 展示是否需要访问密码
 */
@property (nonatomic, strong) UITableView* tv_list;
/**
 * 如果需要密码，则显示出密码输入框
 */
@property (nonatomic, strong) UITextField* psdTF;

@end

@implementation ShareVideoToWeixinVC

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
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"分享至微信", nil);
    self.view.backgroundColor = BG_COLOR;
    [self cteateNavBtn];
    
    //分享到微信，下一步
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"下一步", nil) style:UIBarButtonItemStylePlain target:self action:@selector(next_shareVideoToWeiXin)];
    
    
    [self.view addSubview:self.cutIV];
    [self.cutIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(30);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(0.8*iPhoneWidth, 0.5*iPhoneWidth));
    }];
    
    [self.view addSubview:self.tv_list];
    [self.tv_list mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.cutIV.mas_bottom).mas_offset(30);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 44));
    }];
    
    
    [self.view addSubview:self.psdTF];
    [self.psdTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tv_list.mas_bottom).offset(30);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(0.8*iPhoneWidth, 40));
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - 微信分享下一步
- (void)next_shareVideoToWeiXin
{
    if (!self.psdTF.hidden) {
        if (self.psdTF.text.length<4 || self.psdTF.text.length > 12) {
            [XHToast showCenterWithText:NSLocalizedString(@"请输入4-12位数字的密码", nil)];
            return;
        }
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.dev_id forKey:@"dev_id"];
    if (self.psdTF.text.length > 0) {
        NSString * psdStr_md5 = [NSString md5:self.psdTF.text];
        if (psdStr_md5) {
            [dic setObject:psdStr_md5 forKey:@"randomId"];
        }
    }else{
        [dic setObject:@"" forKey:@"randomId"];
    }
   // NSLog(@"微信分享下一步传之前：%@",dic);
    [[HDNetworking sharedHDNetworking] GET:@"v1/live/addWechatLive" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        NSLog(@"微信视频分享：%@",responseObject);
        if (ret == 0) {
            if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
                NSString * tempBaseUrl;
                if ([[NSUserDefaults standardUserDefaults]objectForKey:Environment]) {
                    NSString * URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:Environment];
                    if ([URLStr isEqualToString:official_Environment_key]) {
                        tempBaseUrl = BASEURL_officialEnvironment;
                    }else if([URLStr isEqualToString:test_Environment_key]){
                        tempBaseUrl = BASEURL_testEnvironment;
                    }
                }
                NSString * needPsd= @"";
             
                self.psdTF.text.length > 0 ? (needPsd = @"y"):(needPsd = @"n");
                APP_Environment environment = [unitl environment];
                NSString * shareURLStr;
                switch (environment) {
                    case Environment_official:
                        shareURLStr = [NSString stringWithFormat:@"%@?dev_id=%@&randomId=%@",shareURL_officialEnvironment,self.dev_id,needPsd];
                        break;
                    case Environment_test:
                        shareURLStr = [NSString stringWithFormat:@"%@?dev_id=%@&randomId=%@",shareURL_testEnvironment,self.dev_id,needPsd];
                        break;
                    default:
                        break;
                }
                NSLog(@"微信分享观看地址是:%@",shareURLStr);
                //创建发送对象实例
                SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
                sendReq.bText = NO;//不使用文本信息
                sendReq.scene = 0;//0 = 好友列表 1 = 朋友圈 2 = 收藏
                
                //创建分享内容对象
                WXMediaMessage *urlMessage = [WXMediaMessage message];
                urlMessage.title = @"视频云眼分享";//分享标题
                NSString *weChatdescStr = [NSString stringWithFormat:@"来看看%@的视频直播吧",self.devName];
                urlMessage.description = weChatdescStr;//分享描述
                
//                UIImage * shareImage = self.cutIV.image;
                /*
                UIImage * tempImage =  [self compressOriginalImage:self.cutIV.image toSize:CGSizeMake(130, 104)];
                NSData * tempImageData = [self compressOriginalImage:tempImage toMaxDataSizeKBytes:26];
                UIImage *resultImage = [UIImage imageWithData:tempImageData];
                 */
                UIImageView * videoLogoImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"shareVideoLogo"]];
                [self.cutIV addSubview:videoLogoImage];
                [videoLogoImage mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.center.mas_equalTo(self.cutIV);
                }];
                
                UIImage * tempImage =  [self compressOriginalImage:self.cutIV.image toSize:CGSizeMake(50, 40)];
                NSLog(@"tempImage:%@",tempImage);
                
                UIGraphicsBeginImageContext(CGSizeMake(100, 80));
                [tempImage drawInRect:CGRectMake(0, 0, 100, 80)];
                UIImage * resultImage222 = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                NSData *data = UIImageJPEGRepresentation(resultImage222,0.2);
                UIImage *resultImage = [UIImage imageWithData:data];
                
                [urlMessage setThumbImage:resultImage];//分享图片,使用SDK的setThumbImage方法可压缩图片大小
                
                [self calulateImageFileSize:resultImage];
                //创建多媒体对象
                WXWebpageObject *webObj = [WXWebpageObject object];
                webObj.webpageUrl = shareURLStr;//分享链接
                
                //完成发送对象实例
                urlMessage.mediaObject = webObj;
                sendReq.message = urlMessage;
                
                //发送分享信息
                [WXApi sendReq:sendReq];

            } else {
                [XHToast showCenterWithText:NSLocalizedString(@"你还没有安装微信！", nil)];
            }
        }else{
            [XHToast showCenterWithText:NSLocalizedString(@"视频分享到微信失败！", nil)];
        }
    } failure:^(NSError * _Nonnull error) {
        [XHToast showCenterWithText:NSLocalizedString(@"视频分享到微信失败！", nil)];
    }];
}

/**
 * 压缩图片到指定尺寸大小
 *
 * @param image 原始图片
 * @param size 目标大小
 *
 * @return 生成图片
 */
-(UIImage *)compressOriginalImage:(UIImage *)image toSize:(CGSize)size{
    UIImage * resultImage = image;
    UIGraphicsBeginImageContext(size);
    [resultImage drawInRect:CGRectMake(00, 0, size.width, size.height)];
    UIGraphicsEndImageContext();
    return image;
}
/**
 * 压缩图片到指定文件大小
 *
 * @param image 目标图片
 * @param size 目标大小（最大值）
 *
 * @return 返回的图片文件
 */
- (NSData *)compressOriginalImage:(UIImage *)image toMaxDataSizeKBytes:(CGFloat)size{
    NSData * data = UIImageJPEGRepresentation(image, 1.0);
    CGFloat dataKBytes = data.length/1000.0;
    CGFloat maxQuality = 0.9f;
    CGFloat lastData = dataKBytes;
    while (dataKBytes > size && maxQuality > 0.01f) {
        maxQuality = maxQuality - 0.01f;
        data = UIImageJPEGRepresentation(image, maxQuality);
        dataKBytes = data.length / 1000.0;
        if (lastData == dataKBytes) {
            break;
        }else{
            lastData = dataKBytes;
        }
    }
    return data;
}


// 计算当前图片的大小
- (void)calulateImageFileSize:(UIImage *)image {
    NSData *data = UIImagePNGRepresentation(image);
    if (!data) {
        data = UIImageJPEGRepresentation(image, 1.0);//需要改成0.5才接近原图片大小，原因请看下文
    }
    double dataLength = [data length] * 1.0;
    NSArray *typeArray = @[@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB",@"ZB",@"YB"];
    NSInteger index = 0;
    while (dataLength > 1024) {
        dataLength /= 1024.0;
        index ++;
    }
    NSLog(@"image = %.3f %@",dataLength,typeArray[index]);
}


#pragma mark - method
- (void)changeValue:(UISwitch *)switchBtn
{
    if (switchBtn.on == YES) {
        self.psdTF.hidden = NO;
    }else{
        self.psdTF.hidden = YES;
        self.psdTF.text = @"";
        [self.psdTF resignFirstResponder];
    }
}

#pragma mark - UITableView代理协议
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *fingerPrintCell_Identifier = @"fingerPrintCell_Identifier";
    SettingCellTwo_t* fingerPrintCell = [tableView dequeueReusableCellWithIdentifier:fingerPrintCell_Identifier];
    if(!fingerPrintCell){
        fingerPrintCell = [[SettingCellTwo_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fingerPrintCell_Identifier];
    }
    
    /**
     * 先判断本地有没有存了这个指纹功能，有，判断是开还是关；若没存本地便默认是关的。
     */
    /*
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    
    NSString *FingerPrintKey = [NSString stringWithFormat:@"%@%@",FingerPrint_key,self.userID];
    
    NSString *fingerPrintStr = [userDefaultes objectForKey:FingerPrintKey];
    NSLog(@"fingerPrintStr:%@",fingerPrintStr);
    if (fingerPrintStr) {
        if ([fingerPrintStr isEqualToString:@"YES"]) {
            fingerPrintCell.switchBtn.on = YES;
        }else{
            fingerPrintCell.switchBtn.on = NO;
        }
    }else{
        fingerPrintCell.switchBtn.on = NO;
    }
    
    */
    [fingerPrintCell.switchBtn addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
     
    fingerPrintCell.typeLabel.text = NSLocalizedString(@"需要访问密码", nil);
    return fingerPrintCell;
}

//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark ===== getter && setter
- (UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, 230, self.view.width, 70) style:UITableViewStylePlain];
        _tv_list.scrollEnabled = NO;
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        _tv_list.backgroundColor = [UIColor redColor];
        UIView * headView = [[UIView alloc]initWithFrame:CGRectMake(0,230,self.view.width, 0)];
        headView.backgroundColor = BG_COLOR;
        _tv_list.tableHeaderView = headView;
        UIView *footView = [[UIView alloc]init];
        _tv_list.tableFooterView = footView;
    }
    return _tv_list;
}

- (UIImageView *)cutIV
{
    if (!_cutIV) {
        _cutIV = [[UIImageView alloc]initWithImage:self.currentVideo_CutImage];
    }
    return _cutIV;
}

- (UITextField *)psdTF
{
    if (!_psdTF) {
        _psdTF = [[CustomTextField alloc]initWithFrame:CGRectZero];
        _psdTF.backgroundColor = RGB(246, 246, 246);
        _psdTF.placeholder = NSLocalizedString(@"请输入4-12位数字的密码", nil);
        _psdTF.keyboardType = UIKeyboardTypeNumberPad;
        _psdTF.layer.masksToBounds = YES;
        _psdTF.hidden = YES;
        _psdTF.layer.cornerRadius = 6.0f;
    }
    return _psdTF;
}


@end
