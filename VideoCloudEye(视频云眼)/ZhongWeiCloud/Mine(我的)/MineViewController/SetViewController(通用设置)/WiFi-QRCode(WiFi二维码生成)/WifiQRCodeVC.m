//
//  WifiQRCodeVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/5/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "WifiQRCodeVC.h"
#import "ZCTabBarController.h"
#import "SGQRCodeTool.h"

#import "WiFiConfigurationProtocol.h"
#import "WifiQRCodeAlert.h"
#import "ScottAlertViewController.h"

#import "ZJImageMagnification.h"

@interface WifiQRCodeVC ()
<
    WifiQRCodeAlertDelegate
>
{
    double currentLight;
}
@property (strong, nonatomic) IBOutlet UIImageView *QRCodeImg;
@property (strong, nonatomic) IBOutlet UIView *QRCodeView;
//操作步骤
@property (strong, nonatomic) IBOutlet UILabel *stepsContentLb;
@property (strong, nonatomic) IBOutlet UILabel *stepsContentLb1;
@property (strong, nonatomic) IBOutlet UILabel *stepsContentLb2;
@property (strong, nonatomic) IBOutlet UILabel *stepsContentLb3;

//操作步骤提示语
@property (strong, nonatomic) IBOutlet UILabel *stepsTipLb;
@property (strong, nonatomic) IBOutlet UIButton *wifiConfigSucBtn;
@property (strong, nonatomic) IBOutlet UILabel *enlargeQRCodeTipLb;

@end

@implementation WifiQRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Wi-Fi二维码生成", nil);
    [self cteateNavBtn];
//    NSLog(@"网络名称:%@",self.ssidNameStr);
    if (self.smartConfigWifiPwd) {
        NSLog(@"wifiName :%@;wifiPwd:%@",self.ssidNameStr,self.smartConfigWifiPwd);
        [self setSmartConfigUI];//通过smartConfig过来的样式
    }else{
        [self SetWifiPwdBoxUI];
    }
    

    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lightScreen)];
    [self.QRCodeView addGestureRecognizer:tapGesture];
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


- (void)lightScreen
{
    [ZJImageMagnification scanBigImageWithImageView:self.QRCodeImg alpha:1.0];
}

#pragma mark - 创建WiFi密码弹出框
- (void)SetWifiPwdBoxUI
{
    WifiQRCodeAlert *  WifiQRCodeActionSheet = [WifiQRCodeAlert viewFromXib];
    WifiQRCodeActionSheet.delegate = self;
    WifiQRCodeActionSheet.wifiNameLabel.text = [NSString stringWithFormat:@"%@\"%@\"%@",NSLocalizedString(@"请输入", nil),self.ModifySSIDNameStr,NSLocalizedString(@"的密码", nil)];
    ScottAlertViewController *alertController = [ScottAlertViewController alertControllerWithAlertView:WifiQRCodeActionSheet preferredStyle:ScottAlertControllerStyleAlert transitionAnimationStyle:ScottAlertTransitionStyleFade];
    [self presentViewController:alertController animated:YES completion:nil];
    
    /**
     *  description: 存在WiFi的前提下,搜索我保存本地的wifiQRCode数据信息
     */
    NSData *wifiQRCodeData = [[NSUserDefaults standardUserDefaults]objectForKey:@"wifiQRCodeKey"];
    NSMutableArray *wifiQRCodeArr = [NSMutableArray arrayWithCapacity:0];
    wifiQRCodeArr = [NSKeyedUnarchiver unarchiveObjectWithData:wifiQRCodeData];
    
    for(NSDictionary *dic in wifiQRCodeArr)
    {
        if ([[dic objectForKey:@"ssid"] isEqualToString:self.ssidNameStr]) {
            WifiQRCodeActionSheet.psdTextField.text = [dic objectForKey:@"wifipwd"];
        }
    }
    
}


#pragma mark  - confirmViewDelegate
#pragma mark - 生成二维码按钮
- (void)joinBtnClick:(id)sender psdStr:(NSString *)psdStr
{
    NSLog(@"self.ssidStr:%@,psdStr:%@",self.ssidNameStr,psdStr);
    NSString *base64EncryptedStr = [WiFiConfigurationProtocol base64WifiCalculate:self.ssidNameStr andPwd:psdStr];
    self.QRCodeView.hidden = NO;
    self.stepsTipLb.hidden = NO;
    self.stepsContentLb.hidden = NO;
    self.stepsContentLb1.hidden = NO;
    self.stepsContentLb2.hidden = NO;
    self.stepsContentLb3.hidden = NO;
    self.wifiConfigSucBtn.hidden = NO;
    self.wifiConfigSucBtn.layer.cornerRadius = 20.f;
    self.stepsContentLb.text = NSLocalizedString(@"①设备通电，听到“请为设备配置无线网络”提示音后，请将二维码对准摄像头", nil);
    self.stepsContentLb1.text = NSLocalizedString(@"②保持约20cm的距离，等待扫描", nil);
    self.stepsContentLb2.text = NSLocalizedString(@"③听到“扫描二维码成功”提示音后移开手机", nil);
    self.stepsContentLb3.text = NSLocalizedString(@"④听到“WiFi连接成功”提示音后表示设备Wi-Fi配置已完成", nil);
    [self setUpQRCode:base64EncryptedStr];//根据字符串生成二维码
    
    //================================
    //先获取WiFi数组信息
    NSData *wifiQRCodeData = [[NSUserDefaults standardUserDefaults]objectForKey:@"wifiQRCodeKey"];
    NSMutableArray *wifiQRCodeArr = [NSMutableArray arrayWithCapacity:0];
    wifiQRCodeArr = [NSKeyedUnarchiver unarchiveObjectWithData:wifiQRCodeData];
    
    if (wifiQRCodeArr) {
        //存储WiFi账号/密码
        NSArray *tempArr = [NSArray arrayWithArray: wifiQRCodeArr];
        //寻找所有所存储的网络数组进行筛选处理
        for(NSDictionary *dic in tempArr){
            NSString *wifiNameStr = [dic objectForKey:@"ssid"];
            if ([wifiNameStr isEqualToString:self.ssidNameStr]) {
                [wifiQRCodeArr removeObject:dic];
            }
        }
        //为了存储当前想要存储的数据
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [tempDic setValue:self.ssidNameStr forKey:@"ssid"];
        [tempDic setValue:psdStr forKey:@"wifipwd"];
        [wifiQRCodeArr addObject:tempDic];
        
        
        NSData *wifiQRCodeNewData = [NSKeyedArchiver archivedDataWithRootObject:wifiQRCodeArr];
        [[NSUserDefaults standardUserDefaults] setObject:wifiQRCodeNewData forKey:@"wifiQRCodeKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        NSMutableArray *wifiQRCodeFirstArr = [NSMutableArray arrayWithCapacity:0];
        //存储WiFi账号/密码
        NSMutableDictionary *wifiQRCodeDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [wifiQRCodeDic setValue:self.ssidNameStr forKey:@"ssid"];
        [wifiQRCodeDic setValue:psdStr forKey:@"wifipwd"];
        //存到该数组里
        [wifiQRCodeFirstArr addObject:wifiQRCodeDic];
        
        NSData *wifiQRCodeNewData = [NSKeyedArchiver archivedDataWithRootObject:wifiQRCodeFirstArr];
        [[NSUserDefaults standardUserDefaults] setObject:wifiQRCodeNewData forKey:@"wifiQRCodeKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //================================
    
}

#pragma mark - 通过smartConfig过来的样式
- (void)setSmartConfigUI
{
    NSString *base64EncryptedStr = [WiFiConfigurationProtocol base64WifiCalculate:self.ssidNameStr andPwd:self.smartConfigWifiPwd];
    self.QRCodeView.hidden = NO;
    self.stepsTipLb.hidden = NO;
    self.stepsContentLb.hidden = NO;
    self.stepsContentLb1.hidden = NO;
    self.stepsContentLb2.hidden = NO;
    self.stepsContentLb3.hidden = NO;
    self.wifiConfigSucBtn.hidden = NO;
    self.wifiConfigSucBtn.layer.cornerRadius = 20.f;
    self.stepsContentLb.text = NSLocalizedString(@"①请将二维码朝向摄像头镜头", nil);
    self.stepsContentLb1.text = NSLocalizedString(@"②保持约20cm的距离，等待扫描", nil);
    self.stepsContentLb2.text = NSLocalizedString(@"③听到“扫描二维码成功”提示音后移开手机", nil);
    self.stepsContentLb3.text = NSLocalizedString(@"④听到“WiFi连接成功”提示音后表示设备Wi-Fi配置已完成", nil);
    [self setUpQRCode:base64EncryptedStr];//根据字符串生成二维码
}

- (IBAction)wifiConfigSucClick:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - 取消按钮
- (void)cancelClick
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 根据字符串生成二维码
- (void)setUpQRCode:(NSString *)Base64EncryptedStr
{
    self.QRCodeImg.image = [SGQRCodeTool SG_generateWithDefaultQRCodeData:Base64EncryptedStr imageViewWidth:1000.f];
}
@end
