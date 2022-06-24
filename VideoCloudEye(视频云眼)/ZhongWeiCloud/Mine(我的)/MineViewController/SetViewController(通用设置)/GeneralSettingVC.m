//
//  GeneralSettingVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/4/19.
//  Copyright © 2018年 张策. All rights reserved.
//
//导入框架头文件用户获取当前WiFi
#import <SystemConfiguration/CaptiveNetwork.h>
#import "GeneralSettingVC.h"
#import "ZCTabBarController.h"
#import "FingerPrintCell.h"//指纹登录cell
#import "fingerPrintLoginManage.h"
#import "WifiConfigCell.h"//WiFi二维码cell
#import "WifiQRCodeVC.h"
#import "AlarmVideoCell.h"//告警视频cell
#import "ACActionSheet.h"
@interface GeneralSettingVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    ACActionSheetDelegate
>
@property (nonatomic,strong) UITableView* tv_list;
@property (nonatomic,copy) NSString *userID;
@end

@implementation GeneralSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"通用设置", nil);
    self.view.backgroundColor = BG_COLOR;
    [self cteateNavBtn];
    [self.view addSubview:self.tv_list];
    
    self.userID = [unitl get_User_id];
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

#pragma mark - method
- (void)changeValue:(UISwitch *)switchBtn
{
    if (switchBtn.on == YES) {
       
        if ([fingerPrintLoginManage supportFingerPrint]) {
            switchBtn.on = YES;
            if (iPhone_X_) {
                [XHToast showCenterWithText:NSLocalizedString(@"面容ID开启", nil)];
            }else{
                [XHToast showCenterWithText:NSLocalizedString(@"触控ID开启", nil)];
            }
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *FingerPrintKey = [NSString stringWithFormat:@"%@%@",FingerPrint_key,self.userID];
            [userDefaults setObject:@"YES" forKey:FingerPrintKey];
            [userDefaults synchronize];
        }else{
            if (iPhone_X_) {
                [XHToast showCenterWithText:NSLocalizedString(@"该手机不支持面容ID或还未开启面容ID功能", nil)];
            }else{
                [XHToast showCenterWithText:NSLocalizedString(@"该手机不支持触控ID或还未开启触控ID功能", nil)];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                           switchBtn.on = NO;
            });
        }
    }else{
        if (iPhone_X_) {
            [XHToast showCenterWithText:NSLocalizedString(@"面容ID关闭", nil)];
        }else{
            [XHToast showCenterWithText:NSLocalizedString(@"触控ID关闭", nil)];
        }

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *FingerPrintKey = [NSString stringWithFormat:@"%@%@",FingerPrint_key,self.userID];
        [userDefaults setObject:@"NO" forKey:FingerPrintKey];
        [userDefaults synchronize];
        
        switchBtn.on = NO;
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
    return 2;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger section = indexPath.section;
    
    if (section == 0) {//指纹
        static NSString *fingerPrintCell_Identifier = @"fingerPrintCell_Identifier";
        FingerPrintCell *cell = [tableView dequeueReusableCellWithIdentifier:fingerPrintCell_Identifier];
        if(!cell){
            cell = [[FingerPrintCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:fingerPrintCell_Identifier];
        }
        
        if (iPhone_X_) {
            cell.IconImg.image = [UIImage imageNamed:@"faceIDIcon"];
            cell.nameLb.text = NSLocalizedString(@"面容ID登录", nil);
        }else{
            cell.IconImg.image = [UIImage imageNamed:@"fingerprint"];
            cell.nameLb.text = NSLocalizedString(@"触控ID登录", nil);
        }
        
        
        /**
         * 先判断本地有没有存了这个指纹功能，有，判断是开还是关；若没存本地便默认是关的。
         */
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        
        NSString *FingerPrintKey = [NSString stringWithFormat:@"%@%@",FingerPrint_key,self.userID];
        
        NSString *fingerPrintStr = [userDefaultes objectForKey:FingerPrintKey];
        NSLog(@"fingerPrintStr:%@",fingerPrintStr);
        if (fingerPrintStr) {
            if ([fingerPrintStr isEqualToString:@"YES"]) {
                cell.switchBtn.on = YES;
            }else{
                cell.switchBtn.on = NO;
            }
        }else{
            cell.switchBtn.on = NO;
        }
        
        [cell.switchBtn addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
        
    }else if (section == 1){
        //加载自定义的Cell
        static NSString *AlarmVideoCell_Identifier = @"AlarmVideoCell_Identifier";
        
        AlarmVideoCell* cell = [tableView dequeueReusableCellWithIdentifier:AlarmVideoCell_Identifier];
        if(!cell){
            cell = [[AlarmVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AlarmVideoCell_Identifier];
        }
       
        NSNumber *typeNum = [[NSUserDefaults standardUserDefaults] objectForKey:ALARMVIDEOTYPE];
        NSLog(@"typeNum:%@===%d",typeNum,[typeNum intValue]);
        switch ([typeNum intValue]) {
            case AlarmVideoType_shortVideo:
                cell.subTitleLb.text = NSLocalizedString(@"短视频", nil);
                break;
            case AlarmVideoType_CloudVideo:
                cell.subTitleLb.text = NSLocalizedString(@"云端录像", nil);
                break;
            case AlarmVideoType_SDVideo:
                cell.subTitleLb.text = NSLocalizedString(@"SD卡录像", nil);
                break;
            default:
                break;
        }
        
        return cell;
    }else{//WI-FI二维码配置
        //加载自定义的Cell
        static NSString *WifiConfigCell_Identifier = @"WifiConfigCell_Identifier";
        
        WifiConfigCell* cell = [tableView dequeueReusableCellWithIdentifier:WifiConfigCell_Identifier];
        if(!cell){
            cell = [[WifiConfigCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WifiConfigCell_Identifier];
        }

        return cell;
    }
    
}

//区头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 20;
    }
    return 10;
}
//区高
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* backView = [[UIView alloc]init];
    if (section == 0) {
        backView.frame = CGRectMake(0, 0, iPhoneWidth, 20);
    }else{
        backView.frame = CGRectMake(0, 0, iPhoneWidth, 10);
    }
    return backView;
}
//区尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}
//区尾
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView* backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 0.001)];
    return backView;
}


//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    
    if (section == 0) {
        
    }else if (section == 1){
        [self actionSheetViewShow];
    }else{
        
        id info = nil;
        NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
        
        for (NSString *ifnam in ifs) {
            info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
            NSString *ssid = info[@"SSID"];
            if (ssid) {
                if (ssid.length > 15) {
                   NSString *wifiNameStr = [ssid substringToIndex:15];
                    //二维码生成页面
                    WifiQRCodeVC *wifiQRVC = [[WifiQRCodeVC alloc]init];
                    wifiQRVC.ssidNameStr = ssid;
                    wifiQRVC.ModifySSIDNameStr = [NSString stringWithFormat:@"%@...",wifiNameStr];
                    [self.navigationController pushViewController:wifiQRVC animated:YES];
                }else{
                    //二维码生成页面
                    WifiQRCodeVC *wifiQRVC = [[WifiQRCodeVC alloc]init];
                    wifiQRVC.ssidNameStr = ssid;
                    wifiQRVC.ModifySSIDNameStr = ssid;
                    [self.navigationController pushViewController:wifiQRVC animated:YES];       
                }
                
            }else{
                [XHToast showCenterWithText:NSLocalizedString(@"未检测到WiFi网络，请先连接WiFi", nil)];
            }
        }
            
    }
    
}

#pragma mark - 仿微信ActionSheet弹框
- (void)actionSheetViewShow
{
    ACActionSheet *actionSheet = [[ACActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"短视频", nil),NSLocalizedString(@"云端录像", nil),NSLocalizedString(@"SD卡录像", nil), nil];
    [actionSheet show];
}


#pragma mark - ACActionSheet delegate
- (void)actionSheet:(ACActionSheet *)actionSheet didClickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 3) { //去掉 取消的这种情况
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        switch (buttonIndex) {
            case 0:
                [defaults setObject:[NSNumber numberWithUnsignedInteger:AlarmVideoType_shortVideo] forKey:ALARMVIDEOTYPE];
                break;
            case 1:
                [defaults setObject:[NSNumber numberWithUnsignedInteger:AlarmVideoType_CloudVideo] forKey:ALARMVIDEOTYPE];
                break;
            case 2:
                [defaults setObject:[NSNumber numberWithUnsignedInteger:AlarmVideoType_SDVideo] forKey:ALARMVIDEOTYPE];
                break;
            default:
                break;
        }
        [defaults synchronize];
        [self.tv_list reloadData];
    }
    
}


- (UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, hideNavHeight, iPhoneWidth, iPhoneHeight) style:UITableViewStyleGrouped];
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        _tv_list.backgroundColor = BG_COLOR;
        _tv_list.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tv_list.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tv_list;
}

@end
