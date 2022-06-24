//
//  WiFiConfigVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/3/18.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import "WiFiConfigVC.h"
#import "VerticalScrollView.h"//滚动 View
#import "ConfigFailureVC.h"//配置失败界面
#import "ConfigSuccessVC.h"//配置成功界面
#import "ProgressView.h"//进度条
#import "Sadp.h"//sadp
#import "jw_smart_config.h"//smart_config
#import "device_discovery.h"
//cself
static WiFiConfigVC *cSelf = nil;

@interface WiFiConfigVC ()
{
    int timeCount;//倒计时
}
/**
 * @brief 滚动图
 */
@property (strong, nonatomic) VerticalScrollView * scrollerView;
/**
 * @brief 请求连接的定时器
 */
@property (nonatomic,strong) NSTimer *timer;
/**
 * @brief 动画展示的定时器
 */
@property (nonatomic,strong) NSTimer *actionTimer;
/**
 * @brief 加载动画的点
 */
@property (nonatomic,strong) UIImageView * pointImage1;
@property (nonatomic,strong) UIImageView * pointImage2;
@property (nonatomic,strong) UIImageView * pointImage3;

/**
 * @brief 倒计时i
 */
@property (nonatomic,assign) int i;

/**
 * @brief 进度条
 */
@property (nonatomic,strong) ProgressView *progress;

@end

@implementation WiFiConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    JWDeviceDiscovery_init();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"self.isQRCode:%d",self.isQRCode);

    if (self.isQRCode) {
        timeCount = 60;
        _timer =  [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(getDevStatus) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }else{//smartConfig
        cSelf = self;
        timeCount = 120;
        JWDeviceDiscovery_setAutoRequestInterval(5);
        JWDeviceDiscovery_start(deviceFindCallBack);
        [self startWifiWithPassStr:self.wifiPwdStr];
    }
    
    _i = 1;
    _actionTimer =  [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(actionBegin) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopTimer];
    [self.scrollerView destroyTime];

}

#pragma mark - setUI
- (void)setUpUI
{
    self.navigationItem.title = NSLocalizedString(@"步骤(2/3)", nil);
    [self cteateNavBtn];
    
    //point 2
    self.pointImage2 = [[UIImageView alloc]init];
    self.pointImage2.image = [UIImage imageNamed:@"config_otherLink"];
    [self.view addSubview:self.pointImage2];
    [self.pointImage2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(250);
    }];
    
    //point 1
    self.pointImage1 = [[UIImageView alloc]init];
    self.pointImage1.image = [UIImage imageNamed:@"config_otherLink"];
    [self.view addSubview:self.pointImage1];
    [self.pointImage1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pointImage2.mas_left).offset(-7);
        make.centerY.equalTo(self.pointImage2.mas_centerY);
    }];
    
    //point 3
    self.pointImage3 = [[UIImageView alloc]init];
    self.pointImage3.image = [UIImage imageNamed:@"config_otherLink"];
    [self.view addSubview:self.pointImage3];
    [self.pointImage3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.pointImage2.mas_right).offset(7);
        make.centerY.equalTo(self.pointImage2.mas_centerY);
    }];
    
    //Camera
    UIImageView * cameraImg = [[UIImageView alloc]init];
    cameraImg.image = [UIImage imageNamed:@"config_camera"];
    [self.view addSubview:cameraImg];
    [cameraImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pointImage1.mas_left).offset(-20);
        make.centerY.equalTo(self.pointImage2.mas_centerY);
    }];
    
    //云服务
    UIImageView *cloudImg = [[UIImageView alloc]init];
    cloudImg.image = [UIImage imageNamed:@"config_cloud"];
    [self.view addSubview:cloudImg];
    [cloudImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.pointImage3.mas_right).offset(20);
        make.centerY.equalTo(self.pointImage2.mas_centerY);
    }];
    
    //进度条
    [self.view addSubview:self.progress];
    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(cloudImg.mas_bottom).offset(70);
        make.size.mas_equalTo(CGSizeMake(0.8*iPhoneWidth, 60));
    }];
    
    //滚动条布局
    [self.view addSubview:self.scrollerView];
    [self.scrollerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.progress.mas_bottom).offset(0);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth,30));
    }];
    
}

#pragma mark - 返回点击事件
- (void)returnVC
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"正在为您添加设备，您确定要退出\"添加设备\"操作吗？", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *btnAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertCtrl addAction:btnAction];
    [alertCtrl addAction:cancelAction];
    
    [self presentViewController:alertCtrl animated:YES completion:nil];
}

#pragma mark - 倒计时
- (void)actionBegin{
    
    _i ++;
    if (_i%3 == 1) {
        self.pointImage1.image = [UIImage imageNamed:@"config_currenLink"];
        self.pointImage2.image = [UIImage imageNamed:@"config_otherLink"];
        self.pointImage3.image = [UIImage imageNamed:@"config_otherLink"];
    }else if (_i%3 == 2){
        self.pointImage2.image = [UIImage imageNamed:@"config_currenLink"];
        self.pointImage1.image = [UIImage imageNamed:@"config_otherLink"];
        self.pointImage3.image = [UIImage imageNamed:@"config_otherLink"];
    }else if (_i%3 == 0){
        self.pointImage3.image = [UIImage imageNamed:@"config_currenLink"];
        self.pointImage1.image = [UIImage imageNamed:@"config_otherLink"];
        self.pointImage2.image = [UIImage imageNamed:@"config_otherLink"];
    }
    NSLog(@"i:%d======timeCount:%d",_i,timeCount);
    if (_i/2 <= timeCount) {//60
        NSString * str = [NSString stringWithFormat:@"%d",timeCount - _i/2];
        NSLog(@"str:%@",str);
        self.progress.progress = 1.0/timeCount*(timeCount - [str intValue]);
        self.progress.titleString = [NSString stringWithFormat:@"%@s",str];

    }else{
        _i = 0;
        ConfigFailureVC *failureVC = [[ConfigFailureVC alloc]init];
        failureVC.isQRCode = self.isQRCode;
        [self.navigationController pushViewController:failureVC animated:YES];
    }
    
}

#pragma mark - 获取设备当前状态
- (void)getDevStatus
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.configModel.deviceId forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/getstatus" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"获取设备在线状态responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSDictionary *bodyDic = responseObject[@"body"];
            int isLine = [bodyDic[@"status"]intValue];
            if (isLine == 0) {
            }else{
                
                if (isMainAccount) {
                    //在线了
                    ConfigSuccessVC *successVC = [[ConfigSuccessVC alloc]init];
                    successVC.configModel = self.configModel;
                    successVC.title = NSLocalizedString(@"步骤(3/3)", nil);
                    NSLog(@"我跳往成功了~");
                    [self.navigationController pushViewController:successVC animated:YES];
                }else{
                    [XHToast showCenterWithText:@"设备配置完成"];
                    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                    dispatch_after(time, dispatch_get_main_queue(), ^(void){
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    });
                    

                }
                
                
            }
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}



#pragma mark ------结束定时器
- (void)stopTimer
{
    if (self.isQRCode) {//二维码
        [_timer invalidate];   // 将定时器从运行循环中移除，
        _timer = nil;
    }else{//smartConfig
        JWSmart_stop();
        JWDeviceDiscovery_stop();
        JWDeviceDiscovery_clearup();
    }
    
    [_actionTimer invalidate];
    _actionTimer = nil;
    
}


#pragma mark - getters && setters
- (VerticalScrollView *)scrollerView{
    if (!_scrollerView) {
        _scrollerView = [[VerticalScrollView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, 30)];
        _scrollerView.titleArray = @[NSLocalizedString(@"1. 路由器、手机和摄像头尽量靠近", nil),NSLocalizedString(@"2. 不要切断设备电源", nil),NSLocalizedString(@"3. 请尽量让App处于当前界面", nil),NSLocalizedString(@"4. 耐心等待，正在配置中...", nil)];
        _scrollerView.titleFont = 16.f;
        _scrollerView.titleColor = [UIColor blackColor];
        _scrollerView.BGColor = [UIColor clearColor];
    }
    
    return _scrollerView;
}


- (ProgressView *)progress
{
    if (!_progress) {
        _progress = [[ProgressView alloc]init];
    }
    return _progress;
}


//==================smartConfig的一些相关配置功能====================
#pragma mark - smartConfig Wi-Fi开始
- (void)startWifiWithPassStr:(NSString *)passStr{
    //wifi配置
    NSLog(@"wifiName=====%@  wifi密码：%@",self.wifiNameStr,self.wifiPwdStr);
    const char * wifiCharStr = [self.wifiNameStr UTF8String];
    const char * passCharStr = [self.wifiPwdStr UTF8String];
    
    size_t str_len = strlen(wifiCharStr);
    for (int i = 0; i < str_len; ++i) {
        NSLog(@"wifiName16jinzhi :%x",wifiCharStr[i]);
    }

    BOOL ConfigSuccess = JWSmart_config(wifiCharStr,passCharStr,5,0);
    if (ConfigSuccess) {
        NSLog(@"smartConfig配置成功");
    }else{
        NSLog(@"smartConfig配置失败");
    }
}


void deviceFindCallBack (const JWDeviceInfo& deviceInfo){

    if (cSelf.configModel.deviceId) {
        const char * erialNumberCharStr = [cSelf.configModel.deviceId UTF8String];
        const char * lpDeviceInfoNumberCharStr = deviceInfo.serial;

        NSString * erialNumberStr = [[NSString alloc] initWithUTF8String:erialNumberCharStr];
        NSString * lpDeviceInfoNumberStr = [[NSString alloc] initWithUTF8String:lpDeviceInfoNumberCharStr];

        NSLog(@"自研对比设备序列号：扫码：%@ ===函数回调：%@",erialNumberStr,lpDeviceInfoNumberStr);
        if ([erialNumberStr isEqualToString: lpDeviceInfoNumberStr]) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [cSelf activeDevice];
            });
        }
    }
}

#pragma mark - 设备已激活并跳转至成功界面
- (void)activeDevice
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        ConfigSuccessVC *successVC = [[ConfigSuccessVC alloc]init];
        successVC.configModel = self.configModel;
        successVC.title = NSLocalizedString(@"步骤(3/3)", nil);
        [self.navigationController pushViewController:successVC animated:YES];
    });
}

@end
