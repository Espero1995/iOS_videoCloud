//
//  UpdataViewController.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/27.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "UpdataViewController.h"
#import "UpdataCell_t.h"
#import "ScottAlertViewController.h"
#import "PubUpdateView.h"
#import "UpdataModel.h"
#import "UpdateStatus.h"

#define CELL @"UpdataCell_t.h"
@interface UpdataViewController ()
//升级信息数据源
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabHeight;
@property (nonatomic,strong)NSMutableArray *dataArr;

@property (nonatomic,strong) NSMutableDictionary * infoDic;

@property (nonatomic,strong) UIView * backView;

@property (nonatomic,strong) UILabel * messageLabel;
/*设备升级进度显示*/
@property (nonatomic,strong) UILabel * tipProgressLb;

@property (nonatomic,strong) UIProgressView * progress;

@property (nonatomic,strong) NSTimer * timer;

@property (nonatomic,assign) CGFloat i;

@property (nonatomic,assign) int x;

@property (nonatomic,assign) int y;


@end

@implementation UpdataViewController

- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpData1];
    [self setUpUI];
    [self cteateNavBtn];
    [self getVersionInfo];
}

- (void)setUpData1
{
    _x = -1;
    _infoDic = [[NSMutableDictionary alloc]init];
//    self.dataArr = [NSMutableArray arrayWithObjects:@"1.提高设备流畅度",@"2.修复已知缺陷",@"3.提高设备稳定性",@"4.设备功能升级", nil];
}
#pragma mark ------ 设备升级网络请求
//查询版本信息
- (void)getVersionInfo{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.listModel.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking] GET:@"v1/device/version/info" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
//        NSLog(@"设备版本信息：%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            UpdataModel * model = [UpdataModel mj_objectWithKeyValues:responseObject[@"body"]];
            if ([unitl isNull:_listModel.name]) {
                _lab_deveName.text = NSLocalizedString(@"无", nil);
            }else{
                _lab_deveName.text = _listModel.name;
            }
            _lab_versionNow.text = model.cur_version;
            _lab_versionUp.text = model.latest_version;
            if (model.cur_version == model.latest_version) {
                self.updateBtn.hidden = YES;
            }else{
                self.updateBtn.hidden = NO;
            }
        }
        
    } failure:^(NSError * _Nonnull error) {

    }];
    
    
}
//设备升级
- (void)upgrade{

    NSMutableDictionary * updateDic = [NSMutableDictionary dictionary];
    [updateDic setObject:self.listModel.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/upgrade" parameters:updateDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSLog(@"更改成功%d",ret);
            [self updateDevice];
        }else{
            [XHToast showCenterWithText:NSLocalizedString(@"发送升级指令失败", nil)];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [XHToast showCenterWithText:NSLocalizedString(@"发送升级指令失败，请检查您的网络", nil)];
    }];

}
//设备升级状态
- (void)getStatus{

    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.listModel.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking] GET:@"v1/device/upgrade/status" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"升级后台信息：%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            UpdateStatus * model = [UpdateStatus mj_objectWithKeyValues:responseObject[@"body"]];
            _x = model.status;
            _y = model.progress;
            _tipProgressLb.text = [NSString stringWithFormat:@"%d%%",model.progress];
        }
    } failure:^(NSError * _Nonnull error) {
         [XHToast showCenterWithText:NSLocalizedString(@"设备升级失败，请检查您的网络", nil)];
    }];

}

//返回上一页
- (void)returnBack{
    if (_x == 0 || _x == 1 ) {
        [self createAlert];

    }else{
        [self.navigationController popViewControllerAnimated:YES];

    }
}
- (void)createAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"设备正在升级,退出将导致升级失败！导致部分功能无法使用！是否确认退出？", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消退出", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"确定退出", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self stopTimer];
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)setUpUI
{
    self.navigationItem.title = NSLocalizedString(@"设备升级", nil);
    self.automaticallyAdjustsScrollViewInsets = NO;
    //tableView
    _tableView.separatorStyle = NO;
    _tableView.estimatedRowHeight = 28;  //随便设个不那么离谱的值
    _tableView.rowHeight = UITableViewAutomaticDimension;
    [_tableView registerNib:[UINib nibWithNibName:@"UpdataCell_t" bundle:nil] forCellReuseIdentifier:CELL];
    _tableView.scrollEnabled = NO;
    CGFloat tabHeight = 18*_dataArr.count;

    [self.tabHeight setConstant:tabHeight];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UpdataCell_t *cell = [tableView dequeueReusableCellWithIdentifier:CELL];
    cell.selectionStyle = NO;
    cell.lab_name.text = _dataArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark ------点击升级按钮
- (IBAction)btnLineClick:(id)sender {
    [self putAlert];
}
#pragma mark ------ 提示升级框
- (void)putAlert
{
    PubUpdateView *customActionSheet = [PubUpdateView viewFromXib];
//    customActionSheet.delegate = self;
    customActionSheet.lab_headTitle.text = NSLocalizedString(@"升级提醒", nil);
    customActionSheet.lab_topTitle.text = NSLocalizedString(@"升级过程中需要几分钟", nil);
    customActionSheet.lab_bottowTitle.text = NSLocalizedString(@"请勿断开电源，是否现在升级？", nil);
    [customActionSheet.btn_left setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    [customActionSheet.btn_right setTitleColor:MAIN_COLOR forState:UIControlStateNormal];

    [customActionSheet.btn_right addTarget:self action:@selector(upgrade) forControlEvents:UIControlEventTouchUpInside];//updateDevice
    ScottAlertViewController *alertController = [ScottAlertViewController alertControllerWithAlertView:customActionSheet preferredStyle:ScottAlertControllerStyleAlert transitionAnimationStyle:ScottAlertTransitionStyleFade];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark ------ 开始升级设备
- (void)updateDevice{
//    [self upgrade];
    self.updateBtn.hidden = YES;
    _backView = [FactoryUI createViewWithFrame:CGRectMake(0, 210, iPhoneWidth, 40)];
    _backView.backgroundColor = [UIColor whiteColor];
    //UIProgressView进度条 继承自UIView
    _progress = [[UIProgressView alloc]initWithFrame:CGRectMake(20, 12.5, iPhoneWidth-40, 8)];
    
    //完成进度的颜色
    _progress.tintColor = MAIN_COLOR;
    //未完成进度的颜色
    _progress.trackTintColor = [UIColor colorWithHexString:@"#e0e0e0"];
    
    _progress.layer.cornerRadius = 2;
    
    _messageLabel = [FactoryUI createLabelWithFrame:CGRectMake(20, 20, iPhoneWidth, 15) text:nil font:[UIFont systemFontOfSize:10]];
    _messageLabel.text = NSLocalizedString(@"正在升级...", nil);
    _messageLabel.textColor = [UIColor colorWithHexString:@"000000"];
    [_backView addSubview:_messageLabel];
    [_backView addSubview:_progress];
    [self.view addSubview:_backView];
    
    
    _tipProgressLb = [FactoryUI createLabelWithFrame:CGRectMake(iPhoneWidth-40, 24.5, 40, 10) text:nil font:[UIFont systemFontOfSize:10]];
    _tipProgressLb.textColor = [UIColor colorWithHexString:@"000000"];
    [_backView addSubview:_tipProgressLb];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(beginUpdate) userInfo:nil repeats:YES];
    
}
#pragma mark ------ 进度条
- (void)beginUpdate{
    [self getStatus];
    _i = _y;
    if (_x == 0) {
        _progress.progress = _i/100;
    }else if (_x == 1){
        _progress.progress = _i/100;
        _messageLabel.text = NSLocalizedString(@"升级成功,正在重启,请等待重新上线(该过程大约需要2分钟)", nil);
        [Toast showLoading:self.view Tips:NSLocalizedString(@"设备正在重启中,请稍等...", nil)];

    }else if (_x == 2){
        [self getVersionInfo];
        [self refreshUI];
        [self stopTimer];
        _messageLabel.text = NSLocalizedString(@"升级成功", nil);
        [_messageLabel setTextColor:RGB(16, 175, 84)];
        [Toast dissmiss];
        _x = -1;
    }else if (_x == 3){
        [self refreshUI];
        [self stopTimer];
        _x = -1;
        _messageLabel.text = NSLocalizedString(@"升级失败", nil);
        [_messageLabel setTextColor:[UIColor redColor]];
        [Toast dissmiss];
    }
    
//    NSLog(@"%d",_x);
    
}

- (void)runTimer{
    
    _i ++;
    NSLog(@"%f",_i/100);
    _progress.progress = _i/10;
    if (_i/100 == 0.900000) {
        
    }
    if (_i/10 == 1.000000) {
        _messageLabel.text = NSLocalizedString(@"升级成功,正在重启,请等待重新上线(该过程大约需要2分钟)", nil);

    }
    if (_i/10 == 2.000000) {
        [self refreshUI];
        [self stopTimer];
    }
}
#pragma mark ------ 升级设备后刷新UI
- (void)refreshUI{

    [_progress removeFromSuperview];
    [_tipProgressLb removeFromSuperview];
    _messageLabel.frame = CGRectMake(0, 10, iPhoneWidth, 20);
    _messageLabel.font = [UIFont systemFontOfSize:16];
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.textColor = [UIColor colorWithHexString:@"000000"];
}
#pragma mark ------结束定时器
- (void)stopTimer
{
    [_timer invalidate];//将定时器从运行循环中移除，
    _timer = nil;
}
- (void)viewWillDisappear:(BOOL)animated{
    [self stopTimer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
