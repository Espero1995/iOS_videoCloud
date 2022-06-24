//
//  RcodeShowController.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/24.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "RcodeShowController.h"
#import "SGAlertView.h"
#import "ZCTabBarController.h"
#import "RcodeSuccessController.h"
#import "InputWifiView.h"
#import "ScottAlertViewController.h"
#import "WiFiSetController.h"
#import "WifiQRConfigVC.h"

#import <SystemConfiguration/CaptiveNetwork.h>
@interface RcodeShowController ()
<
    InputWifiViewDelegate
>

//是否可以添加
@property (nonatomic,assign)BOOL isCanAdd;
//是否在线
@property (nonatomic,assign)BOOL isLine;
@property (strong, nonatomic) IBOutlet UIImageView *Device_img;
@property (weak, nonatomic) IBOutlet UIButton *btn_line;
//提示信息
@property (nonatomic,strong)UILabel *messageLabel;
//分享设备
@property (nonatomic,strong)UILabel *shareLabel;
//接触绑定
@property (nonatomic,strong)UILabel *cancleContent;
/*图片的url*/
@property (nonatomic,copy) NSString *dev_ImgUrl;
@end

@implementation RcodeShowController

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
       _messageLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, iPhoneWidth, 15) text:nil font:[UIFont systemFontOfSize:14]];
        _messageLabel.text = NSLocalizedString(@"该设备已被用户添加", nil);
        _messageLabel.textColor = [UIColor colorWithHexString:@"#000000"];
        _messageLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 1;
    }
    return _messageLabel;
}
- (UILabel *)shareLabel
{
    if (!_shareLabel) {
        //分享
        _shareLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 100, 15) text:nil font:[UIFont systemFontOfSize:14]];
        _shareLabel.textColor = [UIColor colorWithHexString:@"#676767"];
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:NSLocalizedString(@"如果这不是你的设备,可以让设备主人分享设备", nil)];
//        [string addAttribute:NSForegroundColorAttributeName value:MAIN_COLOR range:NSMakeRange(17, 4)];
//        [string addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(17, 4)];
        _shareLabel.attributedText = string;
        _shareLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _shareLabel.numberOfLines = 0;
    }
    return _shareLabel;
}

- (UILabel *)cancleContent
{
    if (!_cancleContent) {
        _cancleContent = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 130, 15) text:nil font:[UIFont systemFontOfSize:14]];
        _cancleContent.textColor = [UIColor colorWithHexString:@"#676767"];
        NSMutableAttributedString * string1 = [[NSMutableAttributedString alloc]initWithString:NSLocalizedString(@"如果是你的设备,可以先解除绑定", nil)];
//        NSRange range = NSMakeRange(11, 4);
//        [string1 addAttribute:NSForegroundColorAttributeName value:MAIN_COLOR range:range];
//        [string1 addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
        
        
        _cancleContent.attributedText = string1;
        _cancleContent.lineBreakMode = NSLineBreakByCharWrapping;
        _cancleContent.numberOfLines = 1;
    }
    return _cancleContent;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    
    
    if (isMainAccount) {
        self.navigationItem.title = NSLocalizedString(@"添加设备", nil);
    }else{
        self.navigationItem.title = NSLocalizedString(@"配置设备", nil);
    }
    
//    self.lab_deveId.text = [NSString stringWithFormat:@"设备型号:%@",self.deveId];
    self.lab_erialNumber.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"设备序列号", nil),self.erialNumber];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.erialNumber forKey:@"erialNumber"];
    //获取设备在线状态
    [self getDevStates];
    //请求设备信息是否能添加
    [self getDevMsg];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.isCanAdd = NO;
//    self.isLine = NO;
    /*
    self.navigationItem.title = @"添加设备";
    self.lab_deveId.text = [NSString stringWithFormat:@"设备型号:%@",self.deveId];
    self.lab_erialNumber.text = self.erialNumber;
    [[NSUserDefaults standardUserDefaults] setObject:self.erialNumber forKey:@"erialNumber"];
     */
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self cteateNavBtn];
}
- (void)showCannotAddUI;
{
    //提示信息
    [self.view addSubview:self.messageLabel];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lab_erialNumber.mas_bottom).offset(10);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(iPhoneWidth);
    }];
    self.btn_line.hidden = YES;
    //分享设备
    [self.view addSubview:self.shareLabel];
    CGFloat labWeith = iPhoneWidth - 85;
    [self.shareLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(42.5);
        make.width.equalTo(@(labWeith));
        make.top.equalTo(self.btn_line.mas_bottom).offset(0);
    }];
    
    //解除绑定
    [self.view addSubview:self.cancleContent];
    [_cancleContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(42.5);
        make.top.equalTo(_shareLabel.mas_bottom).offset(20);
    }];

}
#pragma mark ------点击链接网络按钮
- (IBAction)lineBtnClick:(id)sender {
    NSLog(@"当前的设备型号：%@",self.deveId);
    if (self.isCanAdd == YES) {
        if (self.isLine) {
            //加载
            [LBProgressHUD showHUDto:self.view animated:YES];
            //延迟一秒请求添加设备
            [self performSelector:@selector(addDevice) withObject:nil afterDelay:1];
        }
        if (self.isLine == NO) {
            
            //判断NT4不支持网络连接
            if ([self.deveId isEqualToString:@"NT4"]) {
                [XHToast showCenterWithText:NSLocalizedString(@"该设备不支持无线配置", nil)];
                return;
            }
            
            NSString *str = [self panDuanLine];
            if ([str isEqualToString:@"WIFI"] || [str isEqualToString:@"HOTSPOT"]) {
                //WiFi配置
                [self putAlert];
            }
            else{
                //请链接wifi
                [self showWifiAlert];
            }
        }
    }
}

#pragma mark ------获取设备归属信息
- (void)getDevMsg
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.erialNumber forKey:@"dev_id"];

    [[HDNetworking sharedHDNetworking]POST:@"v1/device/getowner" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"后台返回，获取设备归属信息:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];

        if (ret == 0) {
            NSDictionary *bodyDic = responseObject[@"body"];
            NSString * ower_id = bodyDic[@"owner_id"];
            NSString * vender = bodyDic[@"vender"];
            NSLog(@"ower_id:%@===%ld",ower_id,[ower_id length]);
            //图片
            NSString *tempImgUrl = [NSString stringWithFormat:@"%@1.png",[bodyDic objectForKey:@"dev_img"]];
            [self.Device_img sd_setImageWithURL:[NSURL URLWithString:tempImgUrl] placeholderImage:[UIImage imageNamed:@"CloudPic"]];
            self.dev_ImgUrl = tempImgUrl;
            NSLog(@"self.dev_ImgUrl:%@",self.dev_ImgUrl);
            
            if (self.deveId) {
                self.lab_deveId.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"设备型号", nil),self.deveId];
            }else{
                if ([bodyDic objectForKey:@"dev_type"]) {
                    self.lab_deveId.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"设备型号", nil),[bodyDic objectForKey:@"dev_type"]];
                }else{
                    self.lab_deveId.hidden = YES;
                }
            }
            [[NSUserDefaults standardUserDefaults]setObject:vender forKey:@"vender"];
            if ((NSNull *)ower_id == [NSNull null]){
                //不空
                self.isCanAdd = YES;
            }
            else{
                //空
                self.isCanAdd = NO;
                [self showCannotAddUI];
            }
        }else{//ret == -1
            self.Device_img.image = [UIImage imageNamed:@"InvalidSerialNum"];
            self.lab_deveId.text = NSLocalizedString(@"无效的序列号", nil);
            self.lab_deveId.font = FONTB(14);
            //空
            self.isCanAdd = NO;
//            [self showIsCannotAdd];
        }
        
//            //判断按钮字
//            if (self.isLine) {
//                [self.btn_line setTitle:@"添加" forState:UIControlStateNormal];
//            }else{
//                [self.btn_line setTitle:@"连接网络" forState:UIControlStateNormal];
//            }

        
    } failure:^(NSError * _Nonnull error) {
        self.Device_img.image = [UIImage imageNamed:@"InvalidSerialNum"];
        self.lab_deveId.text = NSLocalizedString(@"无法连接到网络", nil);
        self.lab_deveId.font = FONTB(14);
        self.isCanAdd = NO;
//        [self showIsCannotAdd];
    }];
 
}
#pragma mark ------获取设备在线状态
- (void)getDevStates
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.erialNumber forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/getstatus" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"获取设备在线状态responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSDictionary *bodyDic = responseObject[@"body"];
            BOOL isLine = [bodyDic[@"status"] boolValue];
            NSLog(@"查询设备是否在线：%@",isLine?@"在线":@"不在线");
            if (!isLine) {
                self.isLine = NO;
//                self.btn_line.hidden = NO;
                [self.btn_line setTitle:NSLocalizedString(@"连接网络", nil) forState:UIControlStateNormal];
            }else{
                self.isLine = YES;
//                self.btn_line.hidden = YES;
                 [self.btn_line setTitle:NSLocalizedString(@"添加", nil) forState:UIControlStateNormal];
            }
        }
    } failure:^(NSError * _Nonnull error) {
            self.isLine = NO;
            [self.btn_line setTitle:NSLocalizedString(@"连接网络", nil) forState:UIControlStateNormal];
            self.btn_line.hidden = NO;
    }];
}
#pragma mark ------添加设备
- (void)addDevice
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.erialNumber forKey:@"dev_id"];
    if (!self.check_code) {
        self.check_code = @"";
    }
    NSLog(@"获取当前所在的组：%ld",(long)[unitl getCurrentDisplayGroupIndex]);
    
    [dic setObject:self.check_code forKey:@"check_code"];
    NSString *groupID = ((deviceGroup *)[unitl getCameraGroupModelIndex:[unitl getCurrentDisplayGroupIndex]]).groupId;
    [dic setObject:groupID forKey:@"group_id"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/add" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            //添加成功
            [self successAdd];
        }else{
            //添加失败
            [self failureAdd];
        }
        
    } failure:^(NSError * _Nonnull error) {
        //添加失败
        [self failureAdd];
    }];

}
#pragma mark ------WiFi配置弹窗
- (void)putAlert
{
    NSString *wifiStr = [self getWifiName];
    InputWifiView *customActionSheet = [InputWifiView viewFromXib];
    customActionSheet.delegate = self;
    customActionSheet.lab_wifiName.text = wifiStr;
    ScottAlertViewController *alertController = [ScottAlertViewController alertControllerWithAlertView:customActionSheet preferredStyle:ScottAlertControllerStyleAlert transitionAnimationStyle:ScottAlertTransitionStyleFade];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark ------点击弹窗连接按钮
- (void)InputWifiViewBtnJoinClick:(InputWifiView *)inPutView
{
    if ([self.deveId isEqualToString:@"T12(6mm)"]) {
         NSString *passStr = inPutView.fied_passWord.text;
         //开始配置去配置wifi
         //    [self startWifiWithPassStr:passStr];
         WiFiSetController *wifiVc = [[WiFiSetController alloc]init];
         wifiVc.deveId = self.deveId;
         wifiVc.erialNumber = self.erialNumber;
         wifiVc.check_code = self.check_code;
         wifiVc.passStr = passStr;
         wifiVc.wifiName = [self getWifiName];
         wifiVc.device_imgUrl = self.dev_ImgUrl;
         [self.navigationController pushViewController:wifiVc animated:YES];
    }else{
        WifiQRConfigVC *wifiConfigVC = [[WifiQRConfigVC alloc]init];
        wifiConfigVC.smartConfigWifiPwd = inPutView.fied_passWord.text;
        wifiConfigVC.ssidNameStr = [self getWifiName];
        wifiConfigVC.deveId = self.deveId;
        wifiConfigVC.erialNumber = self.erialNumber;
        wifiConfigVC.check_code = self.check_code;
        wifiConfigVC.device_imgUrl = self.dev_ImgUrl;
        [self.navigationController pushViewController:wifiConfigVC animated:YES];
    }
}
#pragma mark ------成功连接
- (void)successAdd;
{
    [LBProgressHUD hideAllHUDsForView:self.view animated:YES];
    RcodeSuccessController *successVc = [[RcodeSuccessController alloc]init];
    successVc.dev_ImgUrl = self.dev_ImgUrl;//图片URL
    [self.navigationController pushViewController:successVc animated:YES];
}
#pragma mark ------连接失败
- (void)failureAdd
{
    [LBProgressHUD hideAllHUDsForView:self.view animated:YES];
    SGAlertView *alertView = [SGAlertView alertViewWithTitle:NSLocalizedString(@"温馨提示", nil) delegate:nil contentTitle:NSLocalizedString(@"该设备添加失败", nil) alertViewBottomViewType:(SGAlertViewBottomViewTypeOne)];
    [alertView show];
}
#pragma mark ------提示连接wifi
- (void)showWifiAlert
{
//    SGAlertView *alertView = [SGAlertView alertViewWithTitle:@"温馨提示" delegate:nil contentTitle:@"请手机连接wifi" alertViewBottomViewType:(SGAlertViewBottomViewTypeOne)];
//    [alertView show];
    [self createAlertActionWithTitle:NSLocalizedString(@"网络提醒", nil) message:NSLocalizedString(@"设备必须在wifi网络环境下才能接入网络，请先确认手机已连入wifi网络。", nil)];
}
#pragma mark ------提示设备已被添加
- (void)showIsCannotAdd{
//    SGAlertView *alertView = [SGAlertView alertViewWithTitle:@"温馨提示" delegate:nil contentTitle:@"该设备无效" alertViewBottomViewType:(SGAlertViewBottomViewTypeOne)];
//    [alertView show];
    [self createAlertActionWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"无效的序列号", nil)];
}
#pragma mark ------获取WiFi状态
- (NSString *)panDuanLine
{
    // 状态栏是由当前app控制的，首先获取当前app
    UIApplication *app = [UIApplication sharedApplication];
    id statusBar = [app valueForKeyPath:@"statusBar"];
    NSString *network = @"";
    if (iPhone_X_) {
        id statusBarView = [statusBar valueForKeyPath:@"statusBar"];
        UIView *foregroundView = [statusBarView valueForKeyPath:@"foregroundView"];
        
        NSArray *subviews = [[foregroundView subviews][2] subviews];
        
        for (id subview in subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                network = @"WIFI";
            }else if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarStringView")]) {
                network = [subview valueForKeyPath:@"originalText"];
            }
        }
    }else{
        CGFloat x_height = iPhoneHeight;
        CGFloat x_widith = iPhoneWidth;
        NSLog(@"屏幕尺寸：%ff==%ff",x_height,x_widith);
        NSArray *children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
        int type = 0;
        for (id child in children) {
            if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
                type = [[child valueForKeyPath:@"dataNetworkType"] intValue];
            }
        }
        switch (type) {
            case 1:
                network = @"2G";
                break;
            case 2:
                network = @"3G";
                break;
            case 3:
                network = @"4G";
                break;
            case 5:
                network = @"WIFI";
                break;
            case 6:
                network = @"HOTSPOT";//热点
                break;
            default:
                network = @"NO-WIFI";//代表未知网络
                break;
        }
    }
    if ([network isEqualToString:@""]) {
        network = @"NO DISPLAY";
    }
    return network;
}
#pragma mark ------得到当前wifi名称
- (NSString *)getWifiName
{
    NSString *wifiName = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString*)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiName;
}


#pragma mark - 警告框
- (void)createAlertActionWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertCtrl addAction:btnAction];
    [self presentViewController:alertCtrl animated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
