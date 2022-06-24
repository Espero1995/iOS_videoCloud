//
//  RegisterController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/3/17.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "RegisterController.h"
#import "RcodeSuccessController.h"
#import "BindingController.h"
#import "ZCTabBarController.h"
@interface RegisterController ()
@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,strong)NSTimer *actionTimer;
@property (nonatomic,strong)UIImageView * pointImage1;
@property (nonatomic,strong)UIImageView * pointImage2;
@property (nonatomic,strong)UIImageView * pointImage3;
@property (nonatomic,strong)UIButton * button;
@property (nonatomic,assign)int i;
@end

@implementation RegisterController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    _timer =  [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(getDevStates) userInfo:nil repeats:YES];
     [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    _actionTimer =  [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(actionBegin) userInfo:nil repeats:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    [self stopTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    self.title = NSLocalizedString(@"注册平台服务器", nil);
    [self createUI];
}
- (void)createUI{
    //图标
    UIImageView * logoImage = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 75, 75) imageName:@"logo"];
    [self.view addSubview:logoImage];
    [logoImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(100);
        make.centerX.equalTo(self.view.mas_centerX);
//        make.left.equalTo(self.view.mas_left).offset(iPhoneWidth/2-37.5);
//        make.right.equalTo(self.view.mas_left).offset(iPhoneWidth/2+37.5);
    }];
    //点1
    _pointImage1 = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 6, 6) imageName:@"link1"];
    [self.view addSubview:_pointImage1];
    [_pointImage1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(iPhoneWidth/2-3);
        make.top.equalTo(logoImage.mas_bottom).offset(10);
    }];
    //点2
    _pointImage2 = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 6, 6) imageName:@"link1"];
    [self.view addSubview:_pointImage2];
    [_pointImage2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_pointImage1.mas_left).offset(0);
        make.top.equalTo(_pointImage1.mas_bottom).offset(5);
    }];
    //点3
    _pointImage3 = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 6, 6) imageName:@"link1"];
    [self.view addSubview:_pointImage3];
    [_pointImage3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_pointImage2.mas_left).offset(0);
        make.top.equalTo(_pointImage2.mas_bottom).offset(5);
    }];
    //图片
     UIImageView *pictureImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    [pictureImage sd_setImageWithURL:[NSURL URLWithString:self.device_imgUrl] placeholderImage:[UIImage imageNamed:@"CloudPic"]];
    [self.view addSubview:pictureImage];
    [pictureImage mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(logoImage.mas_left).offset(0);
        make.top.equalTo(_pointImage3.mas_bottom).offset(5);
        make.centerX.equalTo(_pointImage3.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    //提示信息
    UILabel * label = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 240, 40) text:nil font:[UIFont systemFontOfSize:16]];
    label.text = NSLocalizedString(@"正在注册平台服务器，请耐心等待", nil);
        label.textColor = [UIColor colorWithHexString:@"#020202"];
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pictureImage.mas_bottom).offset(31);
        make.centerX.equalTo(self.view.mas_centerX).offset(0);
        make.width.mas_equalTo(@300);
    }];


    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(0, 0, 45, 45);
    _button.backgroundColor = MAIN_COLOR;
    _button.layer.cornerRadius = 22.5;
    _button.titleLabel.font = [UIFont systemFontOfSize:16];
//    [_button setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
    [_button setTitle:@"60" forState:UIControlStateNormal];
    [self.view addSubview:_button];
    [_button mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view.mas_left).offset(iPhoneWidth/2-22.5);
        make.top.equalTo(label.mas_bottom).offset(20);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(45, 45));
//        make.right.equalTo(self.view.mas_left).offset(iPhoneWidth/2+22.5);
    }];
}
- (void)actionBegin{
    _i ++;
    if (_i%3 == 1) {
        _pointImage1.image = [UIImage imageNamed:@"link2"];
        _pointImage2.image = [UIImage imageNamed:@"link1"];
        _pointImage3.image = [UIImage imageNamed:@"link1"];
    }else if (_i%3 == 2){
        _pointImage2.image = [UIImage imageNamed:@"link2"];
        _pointImage1.image = [UIImage imageNamed:@"link1"];
        _pointImage3.image = [UIImage imageNamed:@"link1"];
    }else if (_i%3 == 0){
        _pointImage3.image = [UIImage imageNamed:@"link2"];
        _pointImage1.image = [UIImage imageNamed:@"link1"];
        _pointImage2.image = [UIImage imageNamed:@"link1"];
    }
    if (_i/5<=60) {
        NSString * str = [NSString stringWithFormat:@"%d",60-_i/5];
        [_button setTitle:str forState:UIControlStateNormal];
    }

}

#pragma mark ------获取设备在线状态
- (void)getDevStates
{
    NSLog(@"wifi配置，获取设备在线状态responseObject【请求】===time：%@",[unitl getCurrentTimes]);
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.erialNumber forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/getstatus" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        NSLog(@"wifi配置，获取设备在线状态responseObject:%@===time：%@",responseObject,[unitl getCurrentTimes]);
        if (ret == 0) {
            NSDictionary *bodyDic = responseObject[@"body"];
            int isLine = [bodyDic[@"status"]intValue];
            if (isLine == 0) {
                //                self.btn_line.hidden = NO;
            }else{
                NSLog(@"wifi配置，获取设备在线状态responseObject:该结束请求定时器：%d",isLine);
                //在线了
                [self stopTimer];
                [self addDevice];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"wifi配置，获取设备在线状态responseObject【失败】===time：%@",[unitl getCurrentTimes]);
    }];
}

#pragma mark ------添加设备
- (void)addDevice
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.erialNumber forKey:@"dev_id"];
    if (self.check_code) {
        [dic setObject:self.check_code forKey:@"check_code"];
    }else{
        [dic setObject:@"" forKey:@"check_code"];
    }
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
- (void)successAdd
{
    RcodeSuccessController *successVc = [[RcodeSuccessController alloc]init];
    successVc.dev_ImgUrl = self.device_imgUrl;//图片url
    [self.navigationController pushViewController:successVc animated:YES];
}
- (void)failureAdd
{
    BindingController *bindVc = [[BindingController alloc]init];
     bindVc.device_imgUrl = self.device_imgUrl;//图片url
    [self.navigationController pushViewController:bindVc animated:YES];
}
#pragma mark ------结束定时器
- (void)stopTimer
{
    [_timer invalidate];   // 将定时器从运行循环中移除，
    _timer = nil;
    [_actionTimer invalidate];
    _actionTimer = nil;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
