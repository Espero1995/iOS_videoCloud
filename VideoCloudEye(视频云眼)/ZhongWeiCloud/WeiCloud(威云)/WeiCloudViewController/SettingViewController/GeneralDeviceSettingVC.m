//
//  GeneralDeviceSettingVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/9.
//  Copyright © 2018年 张策. All rights reserved.
//
/*
 * description:普通设备的界面【C11、PT12、S12、S12T、T12】
 */
#define ArrowsPic  [UIImage imageNamed:@"more"]

#import "GeneralDeviceSettingVC.h"
#import "ZCTabBarController.h"

#import "DeviceNameController.h"//设备名称
#import "TransferDeviceVC.h"//设备转移
#import "UpdataViewController.h"//升级
#import "ImageSetTempVC.h"//图像设置
#import "TimeZoneSetVC.h"//时区设置
#import "WifiConfigurationController.h"//wifi网络
#import "RemindTimePlanVC.h"//活动检测提醒计划
#import "RemindTimeController.h"//提醒时间设置
#import "AdjustSensitivityController.h"//灵敏度设置

#import "SetTimeModel.h"//布防时间的model
#import "UpdataModel.h"
#import "TimeZoneModel.h"//时区设置的model

#import "SettingCellOne_t.h"
#import "SettingCellTwo_t.h"
#import "SettingCellRemind_t.h"
#import "autoUpdateCell.h"
#import "SettingCellThree_t.h"

@interface GeneralDeviceSettingVC ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
{
    BOOL isRefreshDeviceSet;//判断是否刷新设备布防信息
}
@property (nonatomic,strong) UITableView* tv_list;
@property (nonatomic,copy) NSString* startTime;//提醒开始时间
@property (nonatomic,copy) NSString* endTime;//提醒结束时间
@property (nonatomic,copy) NSString* periodStr;//重复周期
@property(nonatomic,copy) NSString* testAdjust;//灵敏度
@property (nonatomic,copy) NSString* latest_version;//最新版本
@property (nonatomic,copy) NSString* cur_version;//当前版本
@property (nonatomic,assign) BOOL isAutoUpdate;//判断是否自动升级
@property (nonatomic,assign) BOOL isInfrared;//是否开启红外功能
@property (nonatomic,assign) BOOL isOnline;//设备是否在线
@property (nonatomic,assign) BOOL isActivity;//判断活动检测按钮是否打开

@end

@implementation GeneralDeviceSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"设置", nil);
    self.view.backgroundColor = BG_COLOR;
    
    //获取本地的model
    NSMutableArray * tempAllGroupArr = [NSMutableArray arrayWithCapacity:0];
    tempAllGroupArr = [unitl getAllGroupCameraModel];
    NSMutableArray * devListArr = [NSMutableArray arrayWithCapacity:0];
    devListArr = (NSMutableArray *)((deviceGroup*)tempAllGroupArr[[unitl getCurrentDisplayGroupIndex]]).dev_list;
    
    for (int i = 0; i < devListArr.count; i++) {
        if ([((dev_list *)devListArr[i]).ID isEqualToString:self.dev_mList.ID]) {
            self.dev_mList = devListArr[i];
        }
    }
    
    [self cteateNavBtn]; //导航栏按钮
    self.isActivity = NO;
    self.isOnline = NO;
    [self.view addSubview:self.tv_list];
    if (self.dev_mList.status != 0) {//在线
        [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在查询设备信息", nil)];
        [self getGuardPlan];//查询布防信息
    }else{
        self.isOnline = NO;
    }
    
    if ([self.dev_mList.enableInfrared isEqualToString:@"0"]) {
        self.isInfrared = NO;
    }else{
        self.isInfrared = YES;
    }
    [self getAutoUpdateStatus];//获取自动升级状态
    [self getVersionInfo];//查询设备版本信息
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    
    if (isRefreshDeviceSet == YES) {
        [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在查询设备信息", nil)];
        [self getGuardPlan];//查询布防信息
        isRefreshDeviceSet = NO;
    }
    [self.tv_list reloadData];
    
}

//=========================method=========================
#pragma mark - 查询布防信息
- (void)getGuardPlan
{
    /*
     * description : GET v1/device/getguardplan(获取布防信息)
     *  param：access_token=<令牌> & dev_id=<设备ID>
     */
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/getguardplan" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"查询布防==responseObject:%@",responseObject);
        
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            self.isOnline = YES;
            SetTimeModel* model = [SetTimeModel mj_objectWithKeyValues:responseObject[@"body"]];
            NSMutableDictionary* resultDic = [NSMutableDictionary dictionaryWithDictionary:model.guardConfigList[0]];
            //活动检测打开
            if ([resultDic[@"enable"] intValue] == 1){
                self.isActivity = YES;
            }else{
                self.isActivity = NO;
            }
            //提醒时间显示
            //开始时间
            if ([NSString isNullToString:resultDic[@"start_time"]].length == 0) {
                self.startTime = [NSMutableString stringWithFormat:@"00:00"];
            }else{
                self.startTime = resultDic[@"start_time"];
            }
            //结束时间
            if ([NSString isNullToString:resultDic[@"stop_time"]].length == 0) {
                self.endTime = [NSMutableString stringWithFormat:@"23:59"];
            }else{
                self.endTime = resultDic[@"stop_time"];
            }
            //周期
            if ([NSString isNullToString:resultDic[@"period"]].length == 0) {
                self.periodStr = @"1,2,3,4,5,6,7";
            }else{
                self.periodStr = resultDic[@"period"];
            }
            
            //灵敏度
            long sensibilityLong = 60;
            //本地灵敏度
            NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
            NSString* localDegree  =[userDefault objectForKey:@"degree"];
            //先判断有没有这个key/没有：看看有没有本地存储/没有：默认60
            if (![[resultDic allKeys] containsObject:@"sensibility"]) {
                if (localDegree) {
                    self.testAdjust = localDegree;
                }else{
                    self.testAdjust = [NSString stringWithFormat:@"%ld",sensibilityLong];
                }
            }else{
                sensibilityLong = [[resultDic valueForKey:@"sensibility"] longValue];
                NSString* sensibilityStr = [NSString stringWithFormat:@"%ld",sensibilityLong];
                //判断灵敏度是否为空
                if ([NSString isNullToString:sensibilityStr].length == 0) {
                    self.testAdjust = [NSString stringWithFormat:@"%ld",sensibilityLong];
                }else{
                    self.testAdjust = sensibilityStr;
                }
                
            }
            
            [self.tv_list reloadData];
            
        }else{
            [self.tv_list reloadData];
        }
        [CircleLoading hideCircleInView:self.view];
    }failure:^(NSError * _Nonnull error) {
        [self.tv_list reloadData];
        [CircleLoading hideCircleInView:self.view];
        [XHToast showCenterWithText:NSLocalizedString(@"查询设备布防信息失败", nil)];
    }];
}

#pragma mark - 判断活动检测提醒按钮
- (void)changeActivityValue:(UISwitch *)switchBtn
{
    if (switchBtn.on == YES) {
        switchBtn.on = YES;
        self.isActivity =YES;
        [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在设置活动提醒", nil)];
        [self setGuardPlan];
    }else{
        switchBtn.on = NO;
        self.isActivity =NO;
        [self setGuardPlan];
        [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在设置活动提醒", nil)];
    }
}

#pragma mark - 设置布防
- (void)setGuardPlan
{
    /*
     * description : POST v1/device/setguardplan(设置布防信息)
     *  param：access_token=<令牌> & user_id=<用户ID> & dev_id=<设备ID> & alarmType=<告警类型>
     & enable= <启用还是停止> & start_time<开始时间> & stop_time<结束时间> & period<周期>
     &sensibility=<灵敏度 int>
     
     * alarmType：告警类型，目前只支持1（活动检测），不填默认为1
     enable:  布防/撤防，1是布防 0是撤防，撤防的话，后面start_time, stop_time以及period可以不填
     start_time:布防开始时间，如08:30
     stop_time:布防结束时间，如 17:00
     period: 重复周期，如”1,2,3,4,5”， 表示周一到周五
     sensibility: 灵敏度 1~100
     */
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* userID = [defaults objectForKey:@"user_id"];
    [dic setObject:userID forKey:@"user_id"];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    [dic setObject:@"1"forKey:@"alarmType"];
    if (self.isActivity == YES) {
        [dic setObject:@"1" forKey:@"enable"];
    }else if (self.isActivity == NO){
        [dic setObject:@"0" forKey:@"enable"];
    }
    
    [dic setObject:self.startTime forKey:@"start_time"];
    [dic setObject:self.endTime forKey:@"stop_time"];
    [dic setObject:self.periodStr forKey:@"period"];
    
    
    NSNumber* sensitivityNum = @([self.testAdjust integerValue]);
    [dic setObject:sensitivityNum forKey:@"sensibility"];
    
    NSLog(@"灵敏度111：%@,开始时间111：%@，结束时间11：%@，周期11：%@",sensitivityNum,self.startTime,self.endTime,self.periodStr);
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/setguardplan" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"设置布放：%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            //发送活动检测状态的通知
            NSDictionary * dic = @{@"isActivity":[NSString stringWithFormat:@"%d",self.isActivity],@"selectedIndex":self.currentIndex};
            NSLog(@"更新活动检测状态的dic：%@",dic);
            [[NSNotificationCenter defaultCenter]postNotificationName:deviceisActivity object:nil userInfo:dic];
        }else{
            self.isActivity = !self.isActivity;
            [XHToast showCenterWithText:NSLocalizedString(@"活动提醒设置失败，请稍候再试", nil)];
        }
        
        [CircleLoading hideCircleInView:self.view];
        [self.tv_list reloadData];
    } failure:^(NSError * _Nonnull error) {
        [CircleLoading hideCircleInView:self.view];
        self.isActivity = !self.isActivity;
        [XHToast showCenterWithText:NSLocalizedString(@"活动提醒设置失败，请检查您的网络", nil)];
        [self.tv_list reloadData];
    }];
}

#pragma mark - 比较两个时间段【判断同一天还是第二天】
- (BOOL)compareTime:(NSString *)min andMaxTime:(NSString *)max
{
    if ([min length] != 0  && [max length] != 0) {
        //小时间的小时部分
        NSRange minrH = {0,2};
        NSString *minStrH = [min substringWithRange:minrH];
        int minH = [minStrH intValue];
        //大时间的小时部分
        NSRange maxrH = {0,2};
        NSString *maxStrH = [max substringWithRange:maxrH];
        int maxH = [maxStrH intValue];
        //小时间的分钟部分
        NSString *minStrM = [min substringFromIndex:3];
        int minM = [minStrM intValue];
        //大时间的小时部分
        NSString *maxStrM = [max substringFromIndex:3];
        int maxM = [maxStrM intValue];
        //    NSLog(@"%d:%d;%d:%d",minH,minM,maxH,maxM);
        if (maxH > minH) {
            return NO;
        }else if(maxH < minH){
            return YES;
        }else{
            if (maxM > minM) {
                return NO;
            }else{
                return YES;
            }
        }
    }else{
        return NO;
    }
}

#pragma mark - 获取图像设置信息
-(void)getImageSetData{
    /*
     *  description : GET  v1/device/getpictureconfig(查询视频图像参数)
     *  param : access_token=<令牌> & user_id=<用户ID> & dev_id=<设备ID>
     */
    
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* userID = [defaults objectForKey:@"user_id"];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    [dic setObject:userID forKey:@"user_id"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/getpictureconfig" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            NSLog(@"宽动态：%@",responseObject);
            //图像设置
            ImageSetTempVC* imageSetVC = [[ImageSetTempVC alloc]init];
            imageSetVC.listModel = self.dev_mList;
            //镜像显示
            imageSetVC.mirror = responseObject[@"body"][@"pictureConfig"][@"mirror"];
            //旋转显示
            imageSetVC.rotate = responseObject[@"body"][@"pictureConfig"][@"rotate"];
            //开关显示
            NSString* enableStr = [NSString stringWithFormat:@"%@",responseObject[@"body"][@"pictureConfig"][@"wdrEnable"]];
            if ([enableStr isEqualToString:@"0"]) {
                imageSetVC.isWdr = NO;
            }else{
                imageSetVC.isWdr = YES;
            }
            //宽动态显示
            imageSetVC.wdr = responseObject[@"body"][@"pictureConfig"][@"wdr"];
            //查询后跳转时,取消加载动画
            [CircleLoading hideCircleInView:self.view];
            [self.navigationController pushViewController:imageSetVC animated:YES];
        }else{
            //查询失败,取消加载动画
            [CircleLoading hideCircleInView:self.view];
            [XHToast showCenterWithText:NSLocalizedString(@"获取图像设置失败，请稍候再试", nil)];
        }
    } failure:^(NSError * _Nonnull error) {
        //查询失败,取消加载动画
        [CircleLoading hideCircleInView:self.view];
        [XHToast showCenterWithText:NSLocalizedString(@"该设备不支持图像设置", nil)];
        //获取图像设置失败,请检查您的网络
    }];
     

}

#pragma mark - 获取当前时区
- (void)getDeviceTimeZone
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/getDeviceTimeZone" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"获取时区内容:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            TimeZoneModel *model = [TimeZoneModel mj_objectWithKeyValues:responseObject[@"body"]];
            TimeZoneSetVC *timeZoneVC = [[TimeZoneSetVC alloc]init];
            timeZoneVC.model = model;
            timeZoneVC.dev_mList = self.dev_mList;
            //查询后跳转时,取消加载动画
            [CircleLoading hideCircleInView:self.view];
            [self.navigationController pushViewController:timeZoneVC animated:YES];
        }else{
            //查询失败,取消加载动画
            [CircleLoading hideCircleInView:self.view];
            [XHToast showCenterWithText:NSLocalizedString(@"获取设备时区失败，请稍候再试", nil)];
        }
        
    } failure:^(NSError * _Nonnull error) {
        //查询失败,取消加载动画
        [CircleLoading hideCircleInView:self.view];
        [XHToast showCenterWithText:NSLocalizedString(@"获取设备时区失败，请检查您的网络", nil)];
    }];
}

#pragma mark - 判断是否打开开关红外自动开启
- (void)changeInfraredFunc:(UISwitch *)switchBtn
{
    if (switchBtn.on == YES) {
        switchBtn.on = YES;
        self.isInfrared = YES;
        [self setInfraredStatus];
    }else{
        switchBtn.on = NO;
        self.isInfrared = NO;
        [self setInfraredStatus];
    }
}

- (void)setInfraredStatus
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    NSString *isInfraredStr;
    if (self.isInfrared) {
        isInfraredStr = @"1";
    }else{
        isInfraredStr = @"0";
    }
    [dic setObject:isInfraredStr forKey:@"enable"];
    [[HDNetworking sharedHDNetworking] POST:@"v1/deviceinfrared/setInfraredConfig" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"红外设置：%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {

            NSMutableArray * tempAllGroupArr = [NSMutableArray arrayWithCapacity:0];
            tempAllGroupArr = [unitl getAllGroupCameraModel];
            
            NSMutableArray * devListArr = [NSMutableArray arrayWithCapacity:0];
            devListArr = (NSMutableArray *)((deviceGroup*)tempAllGroupArr[[unitl getCurrentDisplayGroupIndex]]).dev_list;
            
            for (int i = 0; i < devListArr.count; i++) {
                if ([((dev_list *)devListArr[i]).ID isEqualToString:self.dev_mList.ID]) {
                    dev_list * appointDevModel = devListArr[i];
                    if (self.isInfrared) {
                        appointDevModel.enableInfrared = @"1";
                    }else{
                        appointDevModel.enableInfrared = @"0";
                    }
                }
            }
            [unitl saveAllGroupCameraModel:tempAllGroupArr];
            
        }else{
            self.isInfrared = !self.isInfrared;
            [XHToast showCenterWithText:NSLocalizedString(@"红外灯设置失败，请稍候再试", nil)];
            [self.tv_list reloadData];
        }
    } failure:^(NSError * _Nonnull error) {
        self.isInfrared = !self.isInfrared;
        [XHToast showCenterWithText:NSLocalizedString(@"红外灯设置失败，请检查您的网络", nil)];
        [self.tv_list reloadData];
        NSLog(@"红外设置失败");
    }];
}


#pragma mark - 获取自动升级状态
- (void)getAutoUpdateStatus
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/getupgradeconfig" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"自动升级结果：%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            if ([responseObject[@"body"][@"UpgradeConfig"] intValue] == 1) {
                self.isAutoUpdate = YES;
            }else{
                self.isAutoUpdate = NO;
            }
        }else{
            self.isAutoUpdate = NO;
        }
        
        [self.tv_list reloadData];
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"自动升级获取失败了");
        [self.tv_list reloadData];
    }];
}
//更改升级状态
- (void)changeAutoUpdateValue:(UISwitch *)switchBtn
{
    if (switchBtn.on == YES) {
        switchBtn.on = YES;
        self.isAutoUpdate = YES;
        [self setAutoUpdateDevice];
    }else{
        switchBtn.on = NO;
        self.isAutoUpdate = NO;
        [self setAutoUpdateDevice];
    }
}
#pragma mark - 设置自动升级状态
- (void)setAutoUpdateDevice
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    if (self.isAutoUpdate) {
        [dic setObject:@"1" forKey:@"auto_ug"];
    }else{
        [dic setObject:@"0" forKey:@"auto_ug"];
    }
    
    [[HDNetworking sharedHDNetworking] POST:@"v1/device/setupgradeconfig" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"自动升级设置：%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
        }else{
            self.isAutoUpdate = !self.isAutoUpdate;
            [XHToast showCenterWithText:NSLocalizedString(@"自动升级设置失败，请稍候再试", nil)];
            [self.tv_list reloadData];
        }
        
    } failure:^(NSError * _Nonnull error) {
        self.isAutoUpdate = !self.isAutoUpdate;
        [XHToast showCenterWithText:NSLocalizedString(@"自动升级设置失败，请检查您的网络", nil)];
        [self.tv_list reloadData];
        NSLog(@"自动升级设置失败");
    }];
}

#pragma mark - 查询版本信息
- (void)getVersionInfo
{
    /*
     * description : GET v1/device/version/info(获取版本信息)
     *  param：access_token=<令牌> & user_id=<用户ID> & dev_id=<设备ID>
     */
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* userID = [defaults objectForKey:@"user_id"];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    [dic setObject:userID forKey:@"user_id"];
    [[HDNetworking sharedHDNetworking] GET:@"v1/device/version/info" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            UpdataModel* model = [UpdataModel mj_objectWithKeyValues:responseObject[@"body"]];
            self.latest_version = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"当前版本", nil),model.latest_version];
            self.cur_version = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"当前版本", nil),model.cur_version];
            [self.tv_list reloadData];
        }else{
            self.latest_version = NSLocalizedString(@"获取版本号失败", nil);
            self.cur_version = NSLocalizedString(@"获取版本号失败", nil);
            [self.tv_list reloadData];
        }
        
    } failure:^(NSError * _Nonnull error) {
        self.latest_version = NSLocalizedString(@"获取版本号失败", nil);
        self.cur_version = NSLocalizedString(@"获取版本号失败", nil);
        [self.tv_list reloadData];
    }];
}
#pragma mark - 重启设备方法
- (void)restartAlert
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"确定要重启设备吗？发送重启指令后,设备将在几分钟内离线！", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在发送重启指令...", nil)];
        [self deviceRestart];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
//设备重启方法
- (void)deviceRestart
{
    /*
     * description : POST v1/device/restart(重启设备)
     *  param：access_token=<令牌> & dev_id=<设备ID>
     */
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/restart" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            [CircleLoading hideCircleInView:self.view];
            [XHToast showCenterWithText:NSLocalizedString(@"重启设备成功", nil)];
        }else{
            [CircleLoading hideCircleInView:self.view];
            [XHToast showCenterWithText:NSLocalizedString(@"重启设备失败", nil)];
        }
    } failure:^(NSError * _Nonnull error) {
        [CircleLoading hideCircleInView:self.view];
        [XHToast showCenterWithText:NSLocalizedString(@"重启设备失败，请检查您的网络", nil)];
    }];
}

#pragma mark - 删除设备方法
- (void)deleteAlert
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"确定删除该设备？", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteDevice];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
//删除设备
- (void)deleteDevice
{
    /*
     * description : POST v1/device/delete(删除设备)
     *  param：access_token=<令牌> & dev_id=<设备ID>
     */
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:self.dev_mList.ID forKey:@"dev_id"];

    [[HDNetworking sharedHDNetworking]POST:@"v1/device/delete" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            [self.navigationController popToViewController:self.navigationController.viewControllers[0]  animated:YES];
            //发送删除设备的通知
            [[NSNotificationCenter defaultCenter] postNotificationName:ADDORDELETEDEVICE object:nil userInfo:nil];
            NSLog(@"deleteDevice 删除成功");
        }else{
            [XHToast showCenterWithText:NSLocalizedString(@"删除设备失败", nil)];
        }
    } failure:^(NSError * _Nonnull error) {
        [XHToast showCenterWithText:NSLocalizedString(@"删除设备失败，请检查您的网络", nil)];
        //NSLog(@"失败了");
    }];
}
//=========================delegate=========================
#pragma mark - tableview的代理方法
//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (self.isOnline == NO) {//不在线
        return 44;
    }else{//在线
        if (section == 2) {
            if (row == 0) {
                return 80;
            }
        }
        return 44;
    }
    
}
//分区数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isOnline == NO) {//不在线
        return 7;
    }else{//在线
        return 9;
    }
    
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isOnline == NO) {//不在线
        if (section == 1) {//小模块大功能
            return 2;//（新加设置时区）
        }else if (section == 4){//升级
            return 2;
        }else{
            return 1;
        }
    }else{//在线
        if (section == 2) {//活动检测提醒
            return 2;
        }else if (section == 3){//小模块大功能
            return 2;//（新加设置时区）
        }else if (section == 6){//升级
            return 2;
        }else{
            return 1;
        }
    }
    
}

//cell
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    if (self.isOnline == NO) {//设备不在线
        
        
        if (section == 0) {//设备名称
            static NSString* nameCell_Identifier = @"NameCell_Identifier";
            SettingCellOne_t* cell = [tableView dequeueReusableCellWithIdentifier:nameCell_Identifier];
            if(!cell){
                cell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nameCell_Identifier];
            }
            cell.typeLabel.text = NSLocalizedString(@"设备名称", nil);
            
            //获取本地的model
            NSMutableArray * tempAllGroupArr = [NSMutableArray arrayWithCapacity:0];
            tempAllGroupArr = [unitl getAllGroupCameraModel];
            
            NSMutableArray * devListArr = [NSMutableArray arrayWithCapacity:0];
            devListArr = (NSMutableArray *)((deviceGroup*)tempAllGroupArr[[unitl getCurrentDisplayGroupIndex]]).dev_list;
            
            for (int i = 0; i < devListArr.count; i++) {
                if ([((dev_list *)devListArr[i]).ID isEqualToString:self.dev_mList.ID]) {
                    dev_list * appointDevModel = devListArr[i];
                    cell.titleLabel.text = appointDevModel.name;
                }
            }
            
            
            return cell;
        }else if (section == 1){
            if (row == 0) {
                static NSString* TransferDeviceCell_Identifier = @"WifiConfigurationCell_Identifier";
                SettingCellOne_t* cell = [tableView dequeueReusableCellWithIdentifier:TransferDeviceCell_Identifier];
                if(!cell){
                    cell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TransferDeviceCell_Identifier];
                }
                cell.typeLabel.text = NSLocalizedString(@"WI-FI网络", nil);
                return cell;
            }else if (row == 1){
                static NSString* ImgSetACell_Identifier = @"ImgSetACell_Identifier";
                SettingCellOne_t* cell = [tableView dequeueReusableCellWithIdentifier:ImgSetACell_Identifier];
                if(!cell){
                    cell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ImgSetACell_Identifier];
                }
                cell.typeLabel.text = NSLocalizedString(@"图像设置", nil);
                return cell;
            }else{
                static NSString* TimeZoneCell_Identifier = @"TimeZoneCell_Identifier";
                SettingCellOne_t* cell = [tableView dequeueReusableCellWithIdentifier:TimeZoneCell_Identifier];
                if(!cell){
                    cell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeZoneCell_Identifier];
                }
                cell.typeLabel.text = NSLocalizedString(@"时区设置", nil);
                return cell;
            }
        }else if (section == 2){
            static NSString* TransferDeviceCell_Identifier = @"TransferDeviceCell_Identifier";
            SettingCellOne_t* cell = [tableView dequeueReusableCellWithIdentifier:TransferDeviceCell_Identifier];
            if(!cell){
                cell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TransferDeviceCell_Identifier];
            }
            cell.typeLabel.text = NSLocalizedString(@"转移设备", nil);
            return cell;
        }else if (section == 3){
            static NSString *InfraredCell_Identifier = @"InfraredCell_Identifier";
            SettingCellTwo_t* cell = [tableView dequeueReusableCellWithIdentifier:InfraredCell_Identifier];
            if(!cell){
                cell = [[SettingCellTwo_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:InfraredCell_Identifier];
            }
            cell.typeLabel.text = NSLocalizedString(@"红外自动开启", nil);
            if (self.isInfrared) {
                cell.switchBtn.on = YES;
            }else{
                cell.switchBtn.on = NO;
            }
            [cell.switchBtn addTarget:self action:@selector(changeInfraredFunc:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }else if (section == 4){
            if (row == 0) {
                static NSString *autoUpdateCell_Identifier = @"autoUpdateCell_Identifier";
                autoUpdateCell* cell = [tableView dequeueReusableCellWithIdentifier:autoUpdateCell_Identifier];
                if(!cell){
                    cell = [[autoUpdateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:autoUpdateCell_Identifier];
                }
                cell.nameLb.text = NSLocalizedString(@"设备自动升级", nil);
                if (self.isAutoUpdate) {
                    cell.switchBtn.on = YES;
                }else{
                    cell.switchBtn.on = NO;
                }
                [cell.switchBtn addTarget:self action:@selector(changeAutoUpdateValue:) forControlEvents:UIControlEventValueChanged];
                return cell;
            }else{
                static NSString* UpdateCell_Identifier = @"UpdateCell_Identifier";
                SettingCellOne_t* cell = [tableView dequeueReusableCellWithIdentifier:UpdateCell_Identifier];
                if(!cell){
                    cell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UpdateCell_Identifier];
                }
                cell.typeLabel.text = NSLocalizedString(@"设备升级", nil);
                cell.titleLabel.text = self.cur_version;
                if(![self.cur_version isEqualToString:self.latest_version]){//红点
                    cell.redDotImg.hidden = NO;
                }else{
                    cell.redDotImg.hidden = YES;
                }
                return cell;
            }
        }else if (section == 5){
            static NSString* RestartCell_Identifier = @"RestartCell_Identifier";
            SettingCellThree_t* cell = [tableView dequeueReusableCellWithIdentifier:RestartCell_Identifier];
            if(!cell){
                cell = [[SettingCellThree_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RestartCell_Identifier];
            }
            cell.deleteLabel.text = NSLocalizedString(@"重启设备", nil);
            return cell;
        }else{
            static NSString *DeleteCell_Identifier = @"DeleteCell_Identifier";
            SettingCellThree_t* cell = [tableView dequeueReusableCellWithIdentifier:DeleteCell_Identifier];
            if(!cell){
                cell = [[SettingCellThree_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DeleteCell_Identifier];
            }
            cell.deleteLabel.text = NSLocalizedString(@"删除设备", nil);
            [cell.deleteLabel setTextColor:[UIColor redColor]];
            return cell;
        }
        
        
        
        
    }else{//设备在线
        if (section == 0) {//设备名称
            static NSString* nameCell_Identifier = @"NameCell_Identifier";
            SettingCellOne_t* cell = [tableView dequeueReusableCellWithIdentifier:nameCell_Identifier];
            if(!cell){
                cell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nameCell_Identifier];
            }
            cell.typeLabel.text = NSLocalizedString(@"设备名称", nil);
            
            //获取本地的model
            NSMutableArray * tempAllGroupArr = [NSMutableArray arrayWithCapacity:0];
            tempAllGroupArr = [unitl getAllGroupCameraModel];
            NSMutableArray * devListArr = [NSMutableArray arrayWithCapacity:0];
            devListArr = (NSMutableArray *)((deviceGroup*)tempAllGroupArr[[unitl getCurrentDisplayGroupIndex]]).dev_list;
            
            for (int i = 0; i < devListArr.count; i++) {
                if ([((dev_list *)devListArr[i]).ID isEqualToString:self.dev_mList.ID]) {
                    dev_list * appointDevModel = devListArr[i];
                    cell.titleLabel.text = appointDevModel.name;
                }
            }
            
             
            return cell;
        }else if (section == 1){//活动检测
            static NSString* ActitvityCell_Identifier = @"ActitvityCell_Identifier";
            SettingCellTwo_t* cell = [tableView dequeueReusableCellWithIdentifier:ActitvityCell_Identifier];
            if(!cell){
                cell = [[SettingCellTwo_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ActitvityCell_Identifier];
            }
            cell.typeLabel.text = NSLocalizedString(@"活动检测提醒", nil);
            
            if (self.isActivity == YES) {
                cell.switchBtn.on = YES;//nvr关闭活动检测
            }else if(self.isActivity == NO){
                cell.switchBtn.on = NO;
            }
            [cell.switchBtn addTarget:self action:@selector(changeActivityValue:) forControlEvents:UIControlEventValueChanged];
            
            return cell;
            
        }else if (section == 2){
            if (row == 0){
                static NSString* RemindCell_Identifier = @"RemindCell_Identifier";
                SettingCellRemind_t* cell = [tableView dequeueReusableCellWithIdentifier:RemindCell_Identifier];
                if(!cell){
                    cell = [[SettingCellRemind_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RemindCell_Identifier];
                }
                cell.typeLabel.text = NSLocalizedString(@"提醒时间", nil);
                
                //时间
                if ([self compareTime:self.startTime andMaxTime:self.endTime]) {
                    cell.titleLabel.text = [NSString stringWithFormat:@"%@~%@(%@)",self.startTime,self.endTime,NSLocalizedString(@"第二天", nil)];
                }else{
                    cell.titleLabel.text = [NSString stringWithFormat:@"%@~%@",self.startTime,self.endTime];
                }
                
                //重复周期
                NSArray * titleArr = @[NSLocalizedString(@"星期一,", nil),NSLocalizedString(@"星期二,", nil),NSLocalizedString(@"星期三,", nil),NSLocalizedString(@"星期四,", nil),NSLocalizedString(@"星期五,", nil),NSLocalizedString(@"星期六,", nil),NSLocalizedString(@"星期日,", nil)];
                NSMutableString* titleStr = [[NSMutableString alloc]init];
                NSArray* tempArr;
                if (self.periodStr.length!=0) {
                    tempArr = [self.periodStr componentsSeparatedByString:@","];
                }
                
                if(tempArr.count < 7){
                    for (int i = 0; i<tempArr.count; i++) {
                        [titleStr appendFormat:@"%@", titleArr[[tempArr[i] integerValue]-1]];
                    }
                    NSString* resultTitle = [titleStr substringWithRange:NSMakeRange(0, [titleStr length] - 1)];
                    cell.scopeLabel.text = [NSString stringWithFormat:@"%@",resultTitle];
                    [cell.scopeLabel setFont:FONT(12)];
                }else if(tempArr.count == 7){
                    cell.scopeLabel.text = NSLocalizedString(@"每天", nil);
                    [cell.scopeLabel setFont:FONT(16)];
                }
                
                return cell;
            }else{
                static NSString* AdjustCell_Identifier = @"AdjustCell_Identifier";
                SettingCellOne_t* cell = [tableView dequeueReusableCellWithIdentifier:AdjustCell_Identifier];
                if(!cell){
                    cell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AdjustCell_Identifier];
                }
                cell.typeLabel.text = NSLocalizedString(@"灵敏度", nil);
                cell.titleLabel.text = self.testAdjust;
                return cell;
            }
        }else if (section == 3){
            if (row == 0) {
                static NSString* TransferDeviceCell_Identifier = @"WifiConfigurationCell_Identifier";
                SettingCellOne_t* cell = [tableView dequeueReusableCellWithIdentifier:TransferDeviceCell_Identifier];
                if(!cell){
                    cell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TransferDeviceCell_Identifier];
                }
                cell.typeLabel.text = NSLocalizedString(@"WI-FI网络", nil);
                return cell;
            }else if (row == 1){
                static NSString* ImgSetACell_Identifier = @"ImgSetACell_Identifier";
                SettingCellOne_t* cell = [tableView dequeueReusableCellWithIdentifier:ImgSetACell_Identifier];
                if(!cell){
                    cell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ImgSetACell_Identifier];
                }
                cell.typeLabel.text = NSLocalizedString(@"图像设置", nil);
                return cell;
            }else{
                static NSString* TimeZoneCell_Identifier = @"TimeZoneCell_Identifier";
                SettingCellOne_t* cell = [tableView dequeueReusableCellWithIdentifier:TimeZoneCell_Identifier];
                if(!cell){
                    cell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeZoneCell_Identifier];
                }
                cell.typeLabel.text = NSLocalizedString(@"时区设置", nil);
                return cell;
            }
        }else if (section == 4){
            static NSString* TransferDeviceCell_Identifier = @"TransferDeviceCell_Identifier";
            SettingCellOne_t* cell = [tableView dequeueReusableCellWithIdentifier:TransferDeviceCell_Identifier];
            if(!cell){
                cell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TransferDeviceCell_Identifier];
            }
            cell.typeLabel.text = NSLocalizedString(@"转移设备", nil);
            return cell;
        }else if (section == 5){
            static NSString *InfraredCell_Identifier = @"InfraredCell_Identifier";
            SettingCellTwo_t* cell = [tableView dequeueReusableCellWithIdentifier:InfraredCell_Identifier];
            if(!cell){
                cell = [[SettingCellTwo_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:InfraredCell_Identifier];
            }
            cell.typeLabel.text = NSLocalizedString(@"红外自动开启", nil);
            if (self.isInfrared) {
                cell.switchBtn.on = YES;
            }else{
                cell.switchBtn.on = NO;
            }
            [cell.switchBtn addTarget:self action:@selector(changeInfraredFunc:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }else if (section == 6){
            if (row == 0) {
                static NSString *autoUpdateCell_Identifier = @"autoUpdateCell_Identifier";
                autoUpdateCell* cell = [tableView dequeueReusableCellWithIdentifier:autoUpdateCell_Identifier];
                if(!cell){
                    cell = [[autoUpdateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:autoUpdateCell_Identifier];
                }
                cell.nameLb.text = NSLocalizedString(@"设备自动升级", nil);
                if (self.isAutoUpdate) {
                    cell.switchBtn.on = YES;
                }else{
                    cell.switchBtn.on = NO;
                }
                [cell.switchBtn addTarget:self action:@selector(changeAutoUpdateValue:) forControlEvents:UIControlEventValueChanged];
                return cell;
            }else{
                static NSString* UpdateCell_Identifier = @"UpdateCell_Identifier";
                SettingCellOne_t* cell = [tableView dequeueReusableCellWithIdentifier:UpdateCell_Identifier];
                if(!cell){
                    cell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:UpdateCell_Identifier];
                }
                cell.typeLabel.text = NSLocalizedString(@"设备升级", nil);
                cell.titleLabel.text = self.cur_version;
                if(![self.cur_version isEqualToString:self.latest_version]){//红点
                    cell.redDotImg.hidden = NO;
                }else{
                    cell.redDotImg.hidden = YES;
                }
                return cell;
            }
        }else if (section == 7){
            static NSString* RestartCell_Identifier = @"RestartCell_Identifier";
            SettingCellThree_t* cell = [tableView dequeueReusableCellWithIdentifier:RestartCell_Identifier];
            if(!cell){
                cell = [[SettingCellThree_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RestartCell_Identifier];
            }
            cell.deleteLabel.text = NSLocalizedString(@"重启设备", nil);
            return cell;
        }else{
            static NSString *DeleteCell_Identifier = @"DeleteCell_Identifier";
            SettingCellThree_t* cell = [tableView dequeueReusableCellWithIdentifier:DeleteCell_Identifier];
            if(!cell){
                cell = [[SettingCellThree_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DeleteCell_Identifier];
            }
            cell.deleteLabel.text = NSLocalizedString(@"删除设备", nil);
            [cell.deleteLabel setTextColor:[UIColor redColor]];
            return cell;
        }
    }
    
}

//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.isOnline == NO) {//设备不在线
        
        if (section == 0) {//修改设备名称
            DeviceNameController* nameVC = [[DeviceNameController alloc]init];
            nameVC.listModel = self.dev_mList;
            nameVC.currentIndex = self.currentIndex;
            [self.navigationController pushViewController:nameVC animated:YES];
        }else if (section == 1){//WiFi网络+图像设置
            if (row == 0) {//WiFi网络
                WifiConfigurationController* wifiVC = [[WifiConfigurationController alloc]init];
                wifiVC.dev_mList = self.dev_mList;
                [self.navigationController pushViewController:wifiVC animated:YES];
            }else if (row == 1){//图像设置
                if (self.isOnline == NO) {
                    [XHToast showCenterWithText:NSLocalizedString(@"该设备不在线,无法进行图像配置", nil)];
                }else{
                    [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在查询图像配置信息", nil)];
                    [self getImageSetData];
                }
            }else{//时区设置
                if (self.isOnline == NO) {
                    [XHToast showCenterWithText:NSLocalizedString(@"该设备不在线,无法进行时区设置", nil)];
                }else{
                    [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在查询设备时区", nil)];
                    [self getDeviceTimeZone];
                }
            }
        }else if (section == 2){//转移设备
//            TransferDeviceVC* transferVC = [[TransferDeviceVC alloc]init];
//            transferVC.dev_mList = self.dev_mList;
//            [self.navigationController pushViewController:transferVC animated:YES];
        }else if (section == 3){//红外自动开启
            
        }else if (section == 4){//设备升级
            if (row == 0) {//设备自动升级
                
            }else{//设备升级
                if (![self.cur_version isEqualToString:self.latest_version]) {
                    UpdataViewController * updataVC= [[UpdataViewController alloc]init];
                    updataVC.listModel = self.dev_mList;
                    [self.navigationController pushViewController:updataVC animated:YES];
                }else{
                    if ([self.cur_version isEqualToString:NSLocalizedString(@"获取版本号失败", nil)]) {
                    }else{
                        [XHToast showCenterWithText:NSLocalizedString(@"设备已为当前最新版本,无需升级", nil)];
                    }
                }
            }
        }else if (section == 5){//重启设备
            [self restartAlert];
        }else{//设备删除
            [self deleteAlert];
        }
        
        
        
    }else{//设备在线
        if (section == 0) {//修改设备名称
            DeviceNameController* nameVC = [[DeviceNameController alloc]init];
            nameVC.listModel = self.dev_mList;
            nameVC.currentIndex = self.currentIndex;
            [self.navigationController pushViewController:nameVC animated:YES];
        }else if (section == 1){//活动检测
            
        }else if (section == 2){//提醒时间+灵敏度
            if (row == 0) {//提醒时间
                if (self.isActivity == NO) {
                    [XHToast showCenterWithText:NSLocalizedString(@"请先打开活动检测提醒，再进行提醒时间设置", nil)];
                }else{
                    RemindTimePlanVC *remindTimeVC = [[RemindTimePlanVC alloc]init];
                    remindTimeVC.dev_mList = self.dev_mList;
                    remindTimeVC.sensibility = self.testAdjust;
                    remindTimeVC.startTime = self.startTime;
                    remindTimeVC.endTime = self.endTime;
                    remindTimeVC.periodStr = self.periodStr;
                    isRefreshDeviceSet = YES;//判断是否刷新设备布防信息
                    [self.navigationController pushViewController:remindTimeVC animated:YES];
                }
            }else{//灵敏度
                if (self.isActivity == NO) {
                    [XHToast showCenterWithText:NSLocalizedString(@"请先打开活动检测提醒，再进行灵敏度设置", nil)];
                }else{
                    //灵敏度调整
                    AdjustSensitivityController* adjust = [[AdjustSensitivityController alloc]init];
                    adjust.adjustDegree = self.testAdjust;
                    adjust.startTime = self.startTime;
                    adjust.endTime = self.endTime;
                    adjust.periodStr = self.periodStr;
                    adjust.listModel = self.dev_mList;
                    //block取值
                    adjust.block = ^(NSString *str) {
                        //NSLog(@"str:%@",str);
                        self.testAdjust = str;
                        //保存到本地
                        NSUserDefaults *degreeInfo = [NSUserDefaults standardUserDefaults];
                        [degreeInfo setObject:str forKey:@"degree"];
                        [degreeInfo synchronize];
                    };
                    isRefreshDeviceSet = YES;//判断是否刷新设备布防信息
                    [self.navigationController pushViewController:adjust animated:YES];
                }
            }
        }else if (section == 3){//WiFi网络+图像设置
            if (row == 0) {//WiFi网络
                WifiConfigurationController* wifiVC = [[WifiConfigurationController alloc]init];
                wifiVC.dev_mList = self.dev_mList;
                [self.navigationController pushViewController:wifiVC animated:YES];
            }else if (row == 1){//图像设置
                if (self.isOnline == NO) {
                    [XHToast showCenterWithText:NSLocalizedString(@"该设备不在线,无法进行图像配置", nil)];
                }else{
                    [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在查询图像配置信息", nil)];
                    [self getImageSetData];
                }
            }else{//时区设置
                if (self.isOnline == NO) {
                    [XHToast showCenterWithText:NSLocalizedString(@"该设备不在线,无法进行时区设置", nil)];
                }else{
                    [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在查询设备时区", nil)];
                    [self getDeviceTimeZone];
                }
            }
        }else if (section == 4){//转移设备
//            TransferDeviceVC* transferVC = [[TransferDeviceVC alloc]init];
//            transferVC.dev_mList = self.dev_mList;
//            [self.navigationController pushViewController:transferVC animated:YES];
        }else if (section == 5){//红外自动开启
            
        }else if (section == 6){//设备升级
            if (row == 0) {//设备自动升级
                
            }else{//设备升级
                if (![self.cur_version isEqualToString:self.latest_version]) {
                    UpdataViewController * updataVC= [[UpdataViewController alloc]init];
                    updataVC.listModel = self.dev_mList;
                    [self.navigationController pushViewController:updataVC animated:YES];
                }else{
                    if ([self.cur_version isEqualToString:NSLocalizedString(@"获取版本号失败", nil)]) {
                    }else{
                        [XHToast showCenterWithText:NSLocalizedString(@"设备已为当前最新版本,无需升级", nil)];
                    }
                }
            }
        }else if (section == 7){//重启设备
            [self restartAlert];
        }else{//设备删除
            [self deleteAlert];
        }
    }
    
}

//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }
    return 15;
}

//head的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 0.001)];
    headView.backgroundColor = [UIColor clearColor];
    return headView;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    if (self.isOnline == NO) {//设备不在线
        if (section == 2 || section == 3) {
            return 15;
        }
    }else{//设备在线
        if (section == 1 || section == 4 || section == 5) {
            return 15;
        }
    }
    
   
    return 0.001;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] init];
    
    if (self.isOnline == NO) {//设备不在线
        if (section == 2 || section == 3) {
            view.frame = CGRectMake(0, 0, iPhoneWidth, 15);
            UILabel *tipLb = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, iPhoneWidth, 15)];
            tipLb.font = FONT(12);
            tipLb.textColor = RGB(150, 150, 150);
            if (section == 2){
                tipLb.text = NSLocalizedString(@"您可以将设备转移给他人使用，转移后设备将归属他人", nil);
            }else{
                tipLb.text = NSLocalizedString(@"根据环境光线强弱，自动开启红外灯", nil);
            }
            [view addSubview:tipLb];
        }else{
            view.frame = CGRectMake(0, 0, iPhoneWidth, 0.001);
        }
    }else{//设备在线
        if (section == 1 || section == 4 || section == 5) {
            view.frame = CGRectMake(0, 0, iPhoneWidth, 15);
            UILabel *tipLb = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, iPhoneWidth, 15)];
            tipLb.font = FONT(12);
            tipLb.textColor = RGB(150, 150, 150);
            if (section == 1) {
                tipLb.text = NSLocalizedString(@"画面中出现活动行为,立刻发出提醒", nil);
            }else if (section == 4){
                tipLb.text = NSLocalizedString(@"您可以将设备转移给他人使用，转移后设备将归属他人", nil);
            }else{
                tipLb.text = NSLocalizedString(@"根据环境光线强弱，自动开启红外灯", nil);
            }
            [view addSubview:tipLb];
        }else{
            view.frame = CGRectMake(0, 0, iPhoneWidth, 0.001);
        }
    }
    
    
    
    view.backgroundColor = [UIColor clearColor];
    return view;
}


//=========================lazy loadiing=========================
#pragma mark ----- 懒加载 -----
#pragma mark - getter&&setter
- (UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, hideNavHeight, iPhoneWidth, iPhoneHeight-64) style:UITableViewStyleGrouped];
        _tv_list.backgroundColor = BG_COLOR;
        //设置代理
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
    }
    return _tv_list;
}

@end
