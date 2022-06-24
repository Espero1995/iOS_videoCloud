//
//  tempVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2020/8/12.
//  Copyright © 2020 苏旋律. All rights reserved.
//

#import "tempVC.h"
#import "ZCTabBarController.h"
#import "VerticalScrollView.h"//滚动 View
@interface tempVC ()

@property (strong, nonatomic) VerticalScrollView * scrollerView;
/**
 * @brief 动画展示的定时器
 */
@property (nonatomic,strong) NSTimer *actionTimer;
/**
 * @brief 倒计时i
 */
@property (nonatomic,assign) int i;

@end

@implementation tempVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    _i = 1;
    _actionTimer =  [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(actionBegin) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
     [self.scrollerView destroyTime];
    [_actionTimer invalidate];   // 将定时器从运行循环中移除，
    _actionTimer = nil;
}

-(void)setUpUI{
    self.navigationItem.title = NSLocalizedString(@"测试页", nil);
    self.view.backgroundColor = BG_COLOR;
    [self cteateNavBtn];
    
    //进度条
//    [self.view addSubview:self.progress];
//    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view.mas_centerX);
//        make.top.equalTo(cloudImg.mas_bottom).offset(70);
//        make.size.mas_equalTo(CGSizeMake(0.8*iPhoneWidth, 60));
//    }];
    
    //滚动条布局
    [self.view addSubview:self.scrollerView];
    [self.scrollerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(150);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth,30));
    }];
}


#pragma mark - 倒计时
- (void)actionBegin{
    _i ++;
    NSLog(@"i:%d======",_i);
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

//- (ProgressView *)progress
//{
//    if (!_progress) {
//        _progress = [[ProgressView alloc]init];
//    }
//    return _progress;
//}
@end
