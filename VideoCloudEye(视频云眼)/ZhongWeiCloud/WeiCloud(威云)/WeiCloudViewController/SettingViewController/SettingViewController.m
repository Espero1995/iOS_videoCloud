//
//  SettingViewController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/27.
//  Copyright © 2017年 张策. All rights reserved.
//
#import "CircleLoading.h"
#import "MyShareModel.h"
#import "SettingViewController.h"
#import "ZCTabBarController.h"
#import "SettingCellOne_t.h"
#import "SettingCellTwo_t.h"
#import "SettingCellThree_t.h"
#import "SetTimeViewController.h"
#import "DeviceNameController.h"
#import "UpdataViewController.h"
#import "UpdataModel.h"
//调节灵敏度
#import "AdjustSensitivityController.h"
//云存储
#import "CloudStorageController.h"
#import "MealRecordModel.h"//套餐记录
//提醒时间的cell
#import "SettingCellRemind_t.h"
//图像设置
#import "ImageSetViewController.h"
//直通公安警告框
#import "ToPoliceView.h"
@interface SettingViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    ToPoliceViewDelegate
>
{
    BOOL isActivity;//判断活动检测按钮是否打开
    BOOL istoPolice;//是否分享给公安
    BOOL isWebClosePolice;//由于网络原因直接强制关闭无法打开
    NSMutableArray *_tempArr;//存储套餐记录
    NSMutableArray  *_tv_dataSource;
    NSMutableArray *_policeListArr;//公安列表数组
}

@property (nonatomic,strong) UITableView * tableView;

//@property (nonatomic,strong) UILabel * deleteLabel;

@property (nonatomic,copy) NSString * latest_version;

@property (nonatomic,copy) NSString * cur_version;

@property (nonatomic,strong) UIView * backView;

@property (nonatomic,strong) UILabel * label;

@property(nonatomic,copy) NSString * testAdjust;
/*公安的id*/
@property(nonatomic,copy) NSString *policeID;
@end

@implementation SettingViewController

//=========================system=========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    [self ActivityDetectionAlert:@"正在查询设备信息"];
    self.view.backgroundColor = BG_COLOR;
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    isActivity = NO;
    //导航栏按钮
    [self cteateNavBtn];
    //数据源
    [self createData];
    [self getVersionInfo];
    //tableView
    [self createTableView];

}
#pragma mark ------接收子页面传值
- (void)viewWillAppear:(BOOL)animated{
    [self getData];
    [self getAllPoliceUser];//获取公安消息(为判断是否有公安信息)
    [self ActivityDetectionAlert:@"正在查询设备信息"];
    _tempArr = [NSMutableArray arrayWithCapacity:0];//初始化
    _tv_dataSource = [NSMutableArray arrayWithCapacity:0];//初始化
    _policeListArr = [NSMutableArray arrayWithCapacity:0];//初始化
    //获取云存储的购买信息
    [self getOrderInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


//=========================init=========================
#pragma mark ------ 创建tableview
// 创建tableView
-(void)createTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, hideNavHeight, self.view.width, iPhoneHeight-64) style:UITableViewStylePlain];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = BG_COLOR;
    
    UIView * headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 22.5)];
    headView.backgroundColor = BG_COLOR;
    self.tableView.tableHeaderView = headView;
    UIView *footView = [[UIView alloc]init];
    self.tableView.tableFooterView = footView;
    [self.view addSubview:self.tableView];
}


//=========================method=========================
#pragma mark ----- 导航栏按钮和响应事件
//返回上一页
- (void)returnVC{
    [self.navigationController popViewControllerAnimated:YES];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
}

#pragma mark ----- 数据源
//数据源
- (void)createData{
    _hourTime = [NSMutableString string];
    _minTime = [NSMutableString string];
    _weekString=[NSMutableString string];
    isActivity = nil;
    if (_chan_size==1) {
//        [self createAlare];
//        [self getData];
    }else{
        isActivity = NO;
    }
    [self getVersionInfo];
}
#pragma mark ------ 查询布防
//查询布放
- (void)getData{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.listModel.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking] GET:@"v1/device/getguardplan" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSLog(@"打印数据。。查询布放：%@",responseObject);
            SetTimeModel * model = [SetTimeModel mj_objectWithKeyValues:responseObject[@"body"]];
            if (model.guardConfigList.count!=0) {
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:model.guardConfigList[0]];
                
                _hourTime = [dict valueForKey:@"start_time"];
                _minTime = [dict valueForKey:@"stop_time"];
                _weekString = [dict valueForKey:@"period"];
                [self.tableView reloadData];
                //根据后台的数据，现在没后台数据,【默认50】
                //看数据是否已经在本地，即注销上述语句，在本地调用数据
                NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
                NSString *degreeaa=[userDefault objectForKey:@"degree"];
//                _testAdjust=degreeaa;
                //根据后台的数据，现在没后台数据,【默认50】
                long sensibilityStr = 50;
                sensibilityStr = [[dict valueForKey:@"sensibility"] longValue];
                if (![[dict allKeys] containsObject:@"sensibility"]) {
                    NSLog(@"灵敏度，没有这个key");
                    if (degreeaa) {
                        _testAdjust=degreeaa;
                    }else{
                        _testAdjust=@"50";
                    }
                }else{
                    NSString * tempStr = [NSString stringWithFormat:@"%ld",sensibilityStr];
                    NSLog(@"获取的灵敏度值：%ld",sensibilityStr);
                    if (![[NSString isNullToString:tempStr] isEqualToString:@""]) {
                        _testAdjust = tempStr;
                    }else{
                        if (degreeaa) {
                            _testAdjust=degreeaa;
                        }else{
                            _testAdjust=@"50";
                        }
                    }
                }
                
//                NSLog(@"字典内容：%@",dict);
                
                int  temp = [dict[@"enable"] intValue];
                if (temp == 1 ) {
                    isActivity = YES;
                    
                }else if (temp == 0){
                    isActivity = NO;
                }
               
                if ([NSString isNullToString:_hourTime].length == 0) {
                    _hourTime = [NSMutableString stringWithFormat:@"00:00"];
                }
                if ([NSString isNullToString:_minTime].length == 0) {
                    _minTime = [NSMutableString stringWithFormat:@"23:59"];
                }
                if ([NSString isNullToString:_weekString].length == 0) {
                    _weekString = [NSMutableString stringWithFormat:@"1,2,3,4,5,6,7"];
                }
                [self.backView removeFromSuperview];
                [self.tableView reloadData];
            }else{
                isActivity = NO;
                _hourTime = [NSMutableString stringWithFormat:@"00:00"];
                _minTime = [NSMutableString stringWithFormat:@"23:59"];
                _weekString = [NSMutableString stringWithFormat:@"1,2,3,4,5,6,7"];
                [self.backView removeFromSuperview];
                [self.tableView reloadData];
            }
        }
        else{
            [self.backView removeFromSuperview];
    }
    } failure:^(NSError * _Nonnull error) {
        [self.backView removeFromSuperview];
    }];
}

#pragma mark ------查询版本信息
- (void)getVersionInfo{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.listModel.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking] GET:@"v1/device/version/info" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            UpdataModel * model = [UpdataModel mj_objectWithKeyValues:responseObject[@"body"]];
            _latest_version = [NSString stringWithFormat:@"%@", model.latest_version];
            _cur_version = [NSString stringWithFormat:@"%@",model.cur_version];
        }
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark ------获取云存储的购买信息
- (void)getOrderInfo{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.listModel.ID forKey:@"device_id"];
    [[HDNetworking sharedHDNetworking] GET:@"v1/cloudplans/device" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
//        NSLog(@"打印云存储购买信息记录：%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSDictionary *dic = responseObject[@"body"];
            NSArray *arr = [dic objectForKey:@"recording_plans"];
             _tempArr=[MealRecordModel mj_objectArrayWithKeyValuesArray: arr];
            if (_tempArr) {
                [_tv_dataSource addObjectsFromArray:_tempArr];
            }
            [self.tableView reloadData];
        }
    }failure:^(NSError * _Nonnull error) {
        NSLog(@"云存储购买失败！");
    }];
}

//网络报错信息
- (void)createNetWrong{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"网络请求异常提示"message:@"网络请求异常，是否退出？"preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定退出" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

        [self.navigationController popViewControllerAnimated:YES];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


//修改活动检测提醒按钮时弹出的警告框
- (void)ActivityDetectionAlert:(NSString *)tipStr{
    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
    _backView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_backView];
    [self.view bringSubviewToFront:_backView];
    
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0.15*iPhoneWidth, iPhoneHeight/2-80, iPhoneWidth*0.7, 60)];
    view.layer.cornerRadius = 2;
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.75;
    [_backView addSubview:view];
    //UIActivityIndicatorView 菊花 继承自UIView
    UIActivityIndicatorView *activ = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 5, 50, 50)];
    
    //样式
    activ.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    /*
     UIActivityIndicatorViewStyleWhiteLarge,
     UIActivityIndicatorViewStyleWhite,
     UIActivityIndicatorViewStyleGray
     */
    self.view.backgroundColor = [UIColor grayColor];
    
    //设置颜色
    activ.color = [UIColor whiteColor];
    
    //动画停止时隐藏
    activ.hidesWhenStopped = YES;
    
    //开始转
    [activ startAnimating];
//    [view addSubview:activ];
    
    CGSize size = [tipStr sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    
    _label = [[UILabel alloc]init];
    _label.frame = CGRectMake(50, 0, size.width + 35, 60);
    _label.text = tipStr;
    _label.textColor = [UIColor whiteColor];
    float contentWidth = size.width + 50 +35;
    //来刚好容纳菊花旋转+字
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake((0.7*iPhoneWidth - contentWidth)/2, 0, contentWidth, 60)];
    [contentView addSubview:activ];
    [contentView addSubview:_label];
    [view addSubview:contentView];

}

- (void)createRestartAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设备重启"message:@"确定重启设备吗？发送重启命令后,设备在几分钟内离线！"preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deviecRestart];
        [self ActivityDetectionAlert:@"正在重启设备"];
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark ------ 提示框和开关按钮
- (void)createAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除设备"message:@"确定删除该设备？"preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消删除" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteDeviece];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark ------ 设备重启
- (void)deviecRestart{
    NSMutableDictionary * guardDic = [NSMutableDictionary dictionary];
    [guardDic setObject:self.listModel.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/restart" parameters:guardDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            NSLog(@"重启成功");
            [_backView removeFromSuperview];
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"失败了");
    }];
}

#pragma mark ------ 设置布防
//设置布放
- (void)setGuardPlan{
    NSMutableDictionary * guardDic = [NSMutableDictionary dictionary];
    [guardDic setObject:self.listModel.ID forKey:@"dev_id"];
    [guardDic setObject:@"1"forKey:@"alarmType"];
    if (isActivity == YES) {
        [guardDic setObject:@"1" forKey:@"enable"];
    }else if (isActivity == NO){
        [guardDic setObject:@"0" forKey:@"enable"];
    }
    
    [guardDic setObject:_hourTime forKey:@"start_time"];
    [guardDic setObject:_minTime forKey:@"stop_time"];
    [guardDic setObject:_weekString forKey:@"period"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/setguardplan" parameters:guardDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"更改成功:%@",responseObject);
        [_backView removeFromSuperview];
        [self.tableView reloadData];
    } failure:^(NSError * _Nonnull error) {
         [_backView removeFromSuperview];
        [self.tableView reloadData];
        NSLog(@"失败了");
    }];
}


#pragma mark ------ 删除设备
- (void)deleteDeviece{
    NSMutableDictionary * changeDic = [NSMutableDictionary dictionary];
    [changeDic setObject:self.listModel.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/delete" parameters:changeDic IsToken:YES success:^(id  _Nonnull responseObject) {
        //发送删除设备的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:ADDORDELETEDEVICE object:nil userInfo:nil];
        NSLog(@"删除成功");
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"失败了");
    }];
}

#pragma mark ------比较两个时间段【判断同一天还是第二天】
- (BOOL)compareTime:(NSString *)min andMaxTime:(NSString *)max{
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
}

#pragma mark ----- 判断活动检测提醒按钮
- (void)changeValue:(UISwitch *)switchBtn{
    if (switchBtn.on == YES) {
        switchBtn.on = YES;
        isActivity =YES;
        [self ActivityDetectionAlert:@"正在打开活动提醒"];
        [self setGuardPlan];
    }else{
        switchBtn.on = NO;
          isActivity =NO;
        [self setGuardPlan];
        [self ActivityDetectionAlert:@"正在关闭活动提醒"];
    }
}

/**
 * description 输入字符串返回时间格式化的时间字符串方法
 * 默认:返回的是以秒为单位，若为毫秒:则进行interval/1000操作。
 */
- (NSString *)backFormatterTime:(NSString *)time{
    NSTimeInterval interval = [time doubleValue];
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *newTimeStr = [formatter stringFromDate:startDate];
    return newTimeStr;
}

//=========================delegate=========================
#pragma mark ------ tableview的代理方法
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.status== YES && indexPath.section== 3) {
        return 80;
    }
    return 44;
}

//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.status == YES) {
        if (isActivity == YES) {
            return 10;
        }else{
            return 9;
        }
    }
    return 7;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        return 1;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //section 0
    if (indexPath.section == 0) {
            static NSString * str1 = @"MyCell1";
            SettingCellOne_t * firstCell1 = [tableView dequeueReusableCellWithIdentifier:str1];
            if(!firstCell1){
                firstCell1 = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str1];
            }
            firstCell1.typeLabel.text = @"设备名称";
            if (_nameString==nil) {
                firstCell1.titleLabel.text = @"";
            }else{
                firstCell1.titleLabel.text = [NSString stringWithFormat:@"%@",_nameString];
            }
            
            firstCell1.pushImage.image = [UIImage imageNamed:@"more"];
            return firstCell1;
    }
    
    //设备不在线
    if (self.status == NO) {
        if (indexPath.section == 1){//直通公安
            static NSString *toPublicCellStr = @"toPublicCell";
            SettingCellTwo_t * cell = [tableView dequeueReusableCellWithIdentifier:toPublicCellStr];
            if(!cell){
                cell = [[SettingCellTwo_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:toPublicCellStr];
            }
            
            //判断是不是网络请求失败的
            if (isWebClosePolice) {
                cell.switchBtn.userInteractionEnabled = NO;
            }else{
                cell.switchBtn.userInteractionEnabled = YES;
                //判断是否已经分享
                if (istoPolice) {
                    cell.switchBtn.on = YES;
                }else{
                    cell.switchBtn.on = NO;
                }
            }
            
            [cell.switchBtn addTarget:self action:@selector(changeSharedPublic:) forControlEvents:UIControlEventValueChanged];
            cell.typeLabel.text = @"直通公安";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
        
        else if (indexPath.section == 2){//设备不在线的第2行状态
            //添加云存储页面
            static NSString * str2 = @"MyCell2";
            SettingCellOne_t * firstCell2 = [tableView dequeueReusableCellWithIdentifier:str2];
            if(!firstCell2){
                firstCell2 = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str2];
            }
            firstCell2.typeLabel.text = @"云存储";
            if (_tv_dataSource.count == 0) {
                firstCell2.titleLabel.text = @"";
            }else{
                MealRecordModel *record= _tempArr[0];
                NSString *stopTime = [NSString stringWithFormat:@"%d",record.stop_date];
                firstCell2.titleLabel.text = [NSString stringWithFormat:@"到期时间:%@",[self backFormatterTime:stopTime]];
            }
            
            return firstCell2;
        }else if(indexPath.section == 3){
            static NSString *ImageSetStr1 = @"ImageSetCell1";
            SettingCellOne_t * imageSetCell1 = [tableView dequeueReusableCellWithIdentifier:ImageSetStr1];
            if(!imageSetCell1){
                imageSetCell1 = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ImageSetStr1];
            }
            imageSetCell1.typeLabel.text = @"图像设置";
            
            imageSetCell1.pushImage.image = [UIImage imageNamed:@"more"];
            return imageSetCell1;
        }else if (indexPath.section == 4){
            static NSString * str8 = @"MyCell8";
            SettingCellOne_t * firstCell8 = [tableView dequeueReusableCellWithIdentifier:str8];
            if(!firstCell8){
                firstCell8 = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str8];
            }
            firstCell8.typeLabel.text = @"设备升级";
           
            if (_cur_version) {
                 firstCell8.titleLabel.text = [NSString stringWithFormat:@"当前版本:%@",_cur_version];
                if (![_cur_version isEqualToString:_latest_version]) {
                    firstCell8.redDotImg.hidden = NO;
                }
            }else{
                 firstCell8.titleLabel.text = @"暂无当前版本信息";
            }
            firstCell8.pushImage.image = [UIImage imageNamed:@"more"];
            
            return firstCell8;
            
        }else if (indexPath.section == 5){
            static NSString * str9 = @"MyCell9";
            SettingCellThree_t * firstCell9 = [tableView dequeueReusableCellWithIdentifier:str9];
            if(!firstCell9){
                firstCell9 = [[SettingCellThree_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str9];
            }
            firstCell9.deleteLabel.text =  @"重启设备";
            return firstCell9;
        }
        
        
    }else{//设备在线
        
        if (indexPath.section == 1){//直通公安
            static NSString *toPublicCellStr = @"toPublicCell";
            SettingCellTwo_t * cell = [tableView dequeueReusableCellWithIdentifier:toPublicCellStr];
            if(!cell){
                cell = [[SettingCellTwo_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:toPublicCellStr];
            }
            
            //判断是不是网络请求失败的
            if (isWebClosePolice) {
                cell.switchBtn.userInteractionEnabled = NO;
            }else{
                cell.switchBtn.userInteractionEnabled = YES;
                //判断是否已经分享
                if (istoPolice) {
                    cell.switchBtn.on = YES;
                }else{
                    cell.switchBtn.on = NO;
                }
            }
            
            [cell.switchBtn addTarget:self action:@selector(changeSharedPublic:) forControlEvents:UIControlEventValueChanged];
            cell.typeLabel.text = @"直通公安";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
        
        if(indexPath.section == 2){//设备在线的第2行；会有2种状态是否开关
            static NSString * str3 = @"MyCell3";
            SettingCellTwo_t * secondCell = [tableView dequeueReusableCellWithIdentifier:str3];
            if(!secondCell){
                secondCell = [[SettingCellTwo_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str3];
            }
            if (isActivity == YES) {
                secondCell.switchBtn.on = YES;//nvr关闭活动检测
            }else if(isActivity == NO){
                if (_chan_size>1) {
                    secondCell.switchBtn.enabled = NO;
                }
                secondCell.switchBtn.on = NO;
            }
            
            [secondCell.switchBtn addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
            secondCell.typeLabel.text = @"活动检测提醒";
            
            return secondCell;
        }
        
        //section 3
        else if (indexPath.section ==3){
            static NSString * str4 = @"MyCell4";
            SettingCellRemind_t * firstCell4 = [tableView dequeueReusableCellWithIdentifier:str4];
            if(!firstCell4){
                
                firstCell4 = [[SettingCellRemind_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str4];
            }
            firstCell4.typeLabel.text = @"提醒时间";
            //        NSLog(@"_hourTime:%@,_minTime:%@",_hourTime,_minTime);
            //比较两个时间段是否要标记成第二天
            if ([_minTime length] != 0 && [_hourTime length] != 0) {
                if ([self compareTime:_hourTime andMaxTime:_minTime]){
                    firstCell4.titleLabel.text = [NSString stringWithFormat:@"%@~%@(第二天)",_hourTime,_minTime];
                }else{
                    firstCell4.titleLabel.text = [NSString stringWithFormat:@"%@~%@",_hourTime,_minTime];
                }
            }
            firstCell4.titleLabel.textColor = [UIColor colorWithHexString:@"0068ff"];
            
            //根据他返回的数据会带有["空格"+","+"数据"];所以我先去掉空格和逗号字符串先
            NSString *tempStr = [[_weekString substringFromIndex:0] stringByReplacingOccurrencesOfString:@"," withString:@""];
            if ([tempStr isEqualToString:@"1234567"]){
                firstCell4.scopeLabel.text = @"每天";
            }else{
                NSArray * titleArr = @[@"",@"星期一,",@"星期二,",@"星期三,",@"星期四,",@"星期五,",@"星期六,",@"星期日"];
                NSMutableString * titleStr = [[NSMutableString alloc]init];
                NSArray * arr = [_weekString componentsSeparatedByString:@","];
                for (int i = 0; i<arr.count; i++) {
                    
                    [titleStr appendFormat:@"%@", titleArr[[arr[i] integerValue]]];
                }
                firstCell4.scopeLabel.text = [NSString stringWithFormat:@"%@",titleStr];
            }
            
            firstCell4.scopeLabel.textColor = [UIColor colorWithHexString:@"0068ff"];
            
            return firstCell4;
        }
        
        //section4
        else if (indexPath.section == 4 && isActivity == YES){
            //添加灵敏度页面
            static NSString * str5 = @"MyCell5";
            SettingCellOne_t * firstCell5 = [tableView dequeueReusableCellWithIdentifier:str5];
            if(!firstCell5){
                
                firstCell5 = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str5];
            }
            firstCell5.typeLabel.text = @"灵敏度";
            
            firstCell5.titleLabel.text=_testAdjust;
            return firstCell5;
            
        }else if (indexPath.section == 4 && isActivity == NO){
            //添加云存储页面
            static NSString * str12 = @"MyCell12";
            SettingCellOne_t * firstCell12 = [tableView dequeueReusableCellWithIdentifier:str12];
            if(!firstCell12){
                firstCell12 = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str12];
            }
            firstCell12.typeLabel.text = @"云存储";
            
            if (_tv_dataSource.count == 0) {
                firstCell12.titleLabel.text = @"";
            }else{
                MealRecordModel *record= _tempArr[0];
                NSString *stopTime = [NSString stringWithFormat:@"%d",record.stop_date];
                firstCell12.titleLabel.text = [NSString stringWithFormat:@"到期时间:%@",[self backFormatterTime:stopTime]];
            }
            return firstCell12;
        }
        
        
        //section 5
        else if (indexPath.section == 5 && isActivity ==YES){
            //添加云存储页面
            static NSString * str6 = @"MyCell6";
            SettingCellOne_t * firstCell6 = [tableView dequeueReusableCellWithIdentifier:str6];
            if(!firstCell6){
                firstCell6 = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str6];
            }
            firstCell6.typeLabel.text = @"云存储";
            
            if (_tv_dataSource.count == 0) {
                firstCell6.titleLabel.text = @"";
            }else{
                MealRecordModel *record= _tempArr[0];
                NSString *stopTime = [NSString stringWithFormat:@"%d",record.stop_date];
                firstCell6.titleLabel.text = [NSString stringWithFormat:@"到期时间:%@",[self backFormatterTime:stopTime]];
            }
            return firstCell6;
        }
        //section 5
        else if (indexPath.section == 5 && isActivity == NO){
            static NSString *ImageSetStr2 = @"ImageSetCell2";
            SettingCellOne_t * imageSetCell2 = [tableView dequeueReusableCellWithIdentifier:ImageSetStr2];
            if(!imageSetCell2){
                imageSetCell2 = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ImageSetStr2];
            }
            imageSetCell2.typeLabel.text = @"图像设置";
            
            imageSetCell2.pushImage.image = [UIImage imageNamed:@"more"];
            return imageSetCell2;
        }
        
        //section 6
        else if (indexPath.section == 6 &&isActivity == YES){
            static NSString *ImageSetStr3 = @"ImageSetCell3";
            SettingCellOne_t * imageSetCell3 = [tableView dequeueReusableCellWithIdentifier:ImageSetStr3];
            if(!imageSetCell3){
                imageSetCell3 = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ImageSetStr3];
            }
            imageSetCell3.typeLabel.text = @"图像设置";
            
            imageSetCell3.pushImage.image = [UIImage imageNamed:@"more"];
            return imageSetCell3;
        }
        
        else if (indexPath.section == 6 && isActivity == NO){
            static NSString * str13 = @"MyCell13";
            SettingCellOne_t * firstCell13 = [tableView dequeueReusableCellWithIdentifier:str13];
            if(!firstCell13){
                
                firstCell13 = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str13];
            }
            firstCell13.typeLabel.text = @"设备升级";

            if (_cur_version) {
                firstCell13.titleLabel.text = [NSString stringWithFormat:@"当前版本:%@",_cur_version];
                if (![_cur_version isEqualToString:_latest_version]) {
                    firstCell13.redDotImg.hidden = NO;
                }
            }else{
                firstCell13.titleLabel.text = @"暂无当前版本信息";
            }
            firstCell13.pushImage.image = [UIImage imageNamed:@"more"];
            return firstCell13;
        }
        
        //section 7
        else if (indexPath.section == 7 &&isActivity == YES){
            static NSString * str7 = @"MyCell7";
            SettingCellOne_t * firstCell7 = [tableView dequeueReusableCellWithIdentifier:str7];
            if(!firstCell7){
                
                firstCell7 = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str7];
            }
            firstCell7.typeLabel.text = @"设备升级";

            
            if (![_cur_version isEqualToString:_latest_version]) {
                firstCell7.redDotImg.hidden = NO;
            }
            
            if (_cur_version) {
                firstCell7.titleLabel.text = [NSString stringWithFormat:@"当前版本:%@",_cur_version];
                if (![_cur_version isEqualToString:_latest_version]) {
                    firstCell7.redDotImg.hidden = NO;
                }
            }else{
                firstCell7.titleLabel.text = @"暂无当前版本信息";
            }
            firstCell7.pushImage.image = [UIImage imageNamed:@"more"];
            return firstCell7;
        }else if (indexPath.section == 7 && isActivity == NO){
            static NSString * str14 = @"MyCell14";
            SettingCellThree_t * firstCell14 = [tableView dequeueReusableCellWithIdentifier:str14];
            if(!firstCell14){
                firstCell14 = [[SettingCellThree_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str14];
            }
            firstCell14.deleteLabel.text =  @"重启设备";
            return firstCell14;
        }
        
        //section8
        else if(indexPath.section == 8 && isActivity == YES){
            static NSString * str10 = @"MyCell10";
            SettingCellThree_t * firstCell10 = [tableView dequeueReusableCellWithIdentifier:str10];
            if(!firstCell10){
                firstCell10 = [[SettingCellThree_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str10];
            }
            firstCell10.deleteLabel.text =  @"重启设备";
            return firstCell10;
        }else if (indexPath.section == 8 &&isActivity == NO){
            static NSString * str15 = @"MyCell15";
            SettingCellThree_t * cell = [tableView dequeueReusableCellWithIdentifier:str15];
            if(!cell){
                cell = [[SettingCellThree_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str15];
            }
            cell.deleteLabel.text=@"删除设备";
            return cell;
        }
    }

    static NSString * str11 = @"MyCell11";
    SettingCellThree_t * cell = [tableView dequeueReusableCellWithIdentifier:str11];
    if(!cell){
        
        cell = [[SettingCellThree_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str11];
    }
    cell.deleteLabel.text=@"删除设备";
    return cell;
}


#pragma mark ------cell的点击事件
//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //section 0
    if (indexPath.section == 0){
            DeviceNameController * nameVC = [[DeviceNameController alloc]init];
            nameVC.deviceName = self.nameString;
            nameVC.listModel = _listModel;
            nameVC.currentIndex = self.currentIndex;
            [self.navigationController pushViewController:nameVC animated:YES];
    }
    
    //section 1 因为是按钮所以这里不需要点击
    
    //设备不在线
    if (self.status == NO) {
        if(indexPath.section == 2){
            if (self.isCloudStorage) {
                CloudStorageController *cloud=[[CloudStorageController alloc]init];
                cloud.deviceID=self.listModel.ID;
                cloud.orderRecordArr=_tempArr;//传入云存储购买记录
                [self.navigationController pushViewController:cloud animated:YES];
            }else{
                [XHToast showCenterWithText:@"该设备不支持云存"];
            }
            
        }else if (indexPath.section == 3){
            [XHToast showCenterWithText:@"该设备不在线,无法进行图像设置"];
        }else if(indexPath.section == 4){
            if (![_cur_version isEqualToString:_latest_version]) {
                UpdataViewController * updataVC= [[UpdataViewController alloc]init];
                updataVC.listModel = _listModel;
                [self.navigationController pushViewController:updataVC animated:YES];
            }else{
                [XHToast showBottomWithText:@"无需升级" bottomOffset:iPhoneHeight-100];
            }
        }else if (indexPath.section == 5){
            [self createRestartAlert];//重启设备
        }else if(indexPath.section == 6){
            [self createAlert];
        }
    }else{//设备在线
        //section 3
        if (indexPath.section == 3) {
            if (isActivity == YES) {
                SetTimeViewController * setTimeVC = [[SetTimeViewController alloc]init];
                setTimeVC.listModel = _listModel;
                setTimeVC.subing = isActivity;
                [self.navigationController pushViewController:setTimeVC animated:YES];
            }else{
                [XHToast showCenterWithText:@"请先打开活动检测提醒"];
            }
           
        }
        
        //section 4
        else if (indexPath.section == 4 && isActivity == YES){
            //灵敏度调整
            AdjustSensitivityController *adjust = [[AdjustSensitivityController alloc]init];
            adjust.adjustDegree = _testAdjust;
            adjust.listModel = _listModel;
            //block取值
            adjust.block = ^(NSString *str) {
//                NSLog(@"str:%@",str);
                _testAdjust = str;
                //保存到本地
                NSUserDefaults *degreeInfo = [NSUserDefaults standardUserDefaults];
                [degreeInfo setObject:str forKey:@"degree"];
                [degreeInfo synchronize];
            };
            [self.navigationController pushViewController:adjust animated:YES];
        }else if (indexPath.section == 4 && isActivity == NO){
            //云存储功能
            if (self.isCloudStorage) {
                CloudStorageController *cloud=[[CloudStorageController alloc]init];
                cloud.deviceID=self.listModel.ID;
                cloud.orderRecordArr=_tempArr;//传入云存储购买记录
                [self.navigationController pushViewController:cloud animated:YES];
            }else{
                [XHToast showCenterWithText:@"该设备不支持云存"];
            }

        }
        
        //section 5
        else if (indexPath.section == 5 && isActivity == YES){
            //云存储功能
            if (self.isCloudStorage) {
                CloudStorageController *cloud=[[CloudStorageController alloc]init];
                cloud.deviceID=self.listModel.ID;
                cloud.orderRecordArr=_tempArr;//传入云存储购买记录
                [self.navigationController pushViewController:cloud animated:YES];
            }else{
                [XHToast showCenterWithText:@"该设备不支持云存"];
            }

        }else if(indexPath.section == 5 && isActivity == NO){
            [CircleLoading showCircleInView:self.view andTip:@"正在查询图像设置信息"];
            [self getImageSetData];
        }
        
        //section 6
        else if (indexPath.section == 6 && isActivity == NO){
            if (![_cur_version isEqualToString:_latest_version]) {
                UpdataViewController * updataVC= [[UpdataViewController alloc]init];
                updataVC.listModel = _listModel;
                [self.navigationController pushViewController:updataVC animated:YES];
            }else{
                [XHToast showBottomWithText:@"无需升级" bottomOffset:iPhoneHeight-100];
            }
        }
        else if(indexPath.section == 6 && isActivity == YES){
            //图像设置
            [CircleLoading showCircleInView:self.view andTip:@"正在查询图像设置信息"];
            [self getImageSetData];
        }

        //section 7
        else if(indexPath.section == 7 && isActivity == YES){
            if (![_cur_version isEqualToString:_latest_version]) {
                UpdataViewController * updataVC= [[UpdataViewController alloc]init];
                updataVC.listModel = _listModel;
                [self.navigationController pushViewController:updataVC animated:YES];
            }else{
                [XHToast showBottomWithText:@"无需升级" bottomOffset:iPhoneHeight-100];
            }
        }else if (indexPath.section == 7 && isActivity == NO){
            [self createRestartAlert];//重启设备
        }
        
        //section 8
        else if(indexPath.section == 8 && isActivity == YES){
            [self createRestartAlert];//重启设备
        }else if(self.status == YES && indexPath.section == 8 && isActivity == NO){
            [self createAlert];//删除设备
        }
        
        //section 9
        else if(indexPath.section == 9 && isActivity == YES){
            [self createAlert];//删除设备
        }
    }

}

#pragma mark ----- 设置区头区尾
//区尾高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (isActivity == YES &&section == 2) {
        return 30;
    }else{
        return 15;
    }
}

//区尾
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if (isActivity == YES && section == 2) {
        UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 35)];
        UILabel * label = [FactoryUI createLabelWithFrame:CGRectMake(20, 7.5, 255, 10) text:nil font:[UIFont systemFontOfSize:10]];
        label.text = @"画面中出现活动行为，立刻发出提醒";
        label.textColor = [UIColor colorWithHexString:@"b2b2b2"];
        label.numberOfLines = 1;
        [backView addSubview:label];
        return backView;
    }else{
        UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 23)];
        return backView;
    }
    return nil;
}


#pragma mark ----- 判断是否打开开关分享给公安
- (void)changeSharedPublic:(UISwitch *)switchBtn{
    if (switchBtn.on == YES) {
        switchBtn.on = YES;
        istoPolice = YES;
        [self opentoPoliceList];
    }else{
        [self createCancelPoliceAlert];
        switchBtn.on = NO;
    }
}


#pragma mark ----- 获取公安信息判断开关是否打开（打开并获取到policeID）
- (void)getAllPoliceUser
{
    /*
     *  description : GET  v1/device/share/to-public(获取共享给公共用户列表)
     *  param : access_token=<令牌> & user_id=<用户ID>
     */
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults objectForKey:@"user_id"];
    [dic setObject:userID forKey:@"user_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/share/to-public" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
//        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
            MyShareModel *listModel = [MyShareModel mj_objectWithKeyValues:responseObject[@"body"]];
            tempArr = [NSMutableArray arrayWithArray:listModel.shared];
            isWebClosePolice = NO;
            if ([self isToPolice:tempArr]) {
                istoPolice = YES;
                [self.tableView reloadData];
            }else{
                istoPolice = NO;
                [self.tableView reloadData];
            }
           
        }
        else{
            isWebClosePolice = YES;
            [XHToast showBottomWithText:@"获取直通公安失败,导致无法打开直通公安按钮"];
        }
     
    } failure:^(NSError * _Nonnull error) {
        isWebClosePolice = YES;
        [XHToast showBottomWithText:@"获取直通公安失败,导致无法打开直通公安按钮"];
    }];
    
}

#pragma mark ----- 判断是否直通公安
//判断的过程中会将其id也获取出来
- (BOOL)isToPolice:(NSMutableArray *)tempArr{
    for (int i = 0; i<tempArr.count; i++) {
        shared *shareUsersInfo = tempArr[i];
        if ([shareUsersInfo.ID isEqualToString:self.listModel.ID]) {
            self.policeID = shareUsersInfo.user_list[0][@"id"];
            break;
        }else{
            self.policeID = @"";
        }
    }
    if ([NSString isNull:self.policeID]) {
        return NO;
    }else{
        return YES;
    }
    
}


#pragma mark ----- 关闭直通公安
//创建取消直通公安的警告框
- (void)createCancelPoliceAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否取消该分享"message:@"取消分享后公安机关将无法有效监管该场所"preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            istoPolice = YES;
            [self.tableView reloadData];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self closetoPolice];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//关闭直通公安方法
- (void)closetoPolice{
    /*
     * description : POST v1/device/cancelshare2public(删除给公共用户的设备共享)
     *  param：access_token=<令牌> & user_id=<用户ID> & dev_id=<设备ID> & puser_id=<共享的用户ID>
     */
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults objectForKey:@"user_id"];
    [dic setObject:userID forKey:@"user_id"];
    [dic setObject:self.policeID forKey:@"puser_id"];
    [dic setObject:self.listModel.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/cancelshare2public" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            istoPolice = NO;
            [self.tableView reloadData];
        }else{
            istoPolice = YES;
            [self.tableView reloadData];
            [XHToast showBottomWithText:@"取消分享失败"];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [XHToast showBottomWithText:@"由于网络原因，取消分享失败"];
    }];
    
}

#pragma mark ----- 打开直通公安列表
- (void)opentoPoliceList{
    /*
     * description : POST v1/user/getpusers(获取共享用户列表)
     *  param : access_token=<令牌> & user_id=<用户ID>  
     */
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults objectForKey:@"user_id"];
    [dic setObject:userID forKey:@"user_id"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/user/getpusers" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        //NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSMutableArray *nameArr = [NSMutableArray arrayWithCapacity:0];
            _policeListArr = responseObject[@"body"][@"p_users"];
            for (int i = 0; i<_policeListArr.count; i++) {
                NSDictionary *dic = _policeListArr[i];
                [nameArr addObject:dic[@"name"]];
            }
            if (nameArr.count == 0) {
                istoPolice = NO;
                [self.tableView reloadData];
                [XHToast showCenterWithText:@"未发现可以分享的公安机关"];
            }else{
                [self showPoliceList:nameArr];
            }
            
        }else{
            [XHToast showBottomWithText:@"获取公安列表失败"];
        }
        
    }failure:^(NSError * _Nonnull error) {
        [XHToast showBottomWithText:@"由于网络原因，获取公安列表失败"];
    }];
}

//表视图弹框
- (void)showPoliceList:(NSArray *)arr{
    NSLog(@"arr:%@",arr);
    //每个cell的高度
    float cellheight = 44;
    //headView(标题view的高度)
    float headTitleHeight = 40;
    
    ToPoliceView *customV = [[ToPoliceView alloc]initWithDataArr:arr origin:CGPointMake(iPhoneWidth/2, 0.25*iPhoneHeight) width:0.7*iPhoneWidth Singleheight:cellheight title:@"公安列表" headTitleHeight:headTitleHeight];
    [customV customAlertViewShow];
    customV.delegate=self;
    
    istoPolice = NO;
    [self.tableView reloadData];
    
}
//警告框的代理协议
- (void)downOutViewSelectRowAtIndex:(NSInteger)index{
    //NSLog(@"我打印的是第几个数组：%@",_policeListArr[index]);
    self.policeID = _policeListArr[index][@"id"];
    [self opentoPolice];
}

//打开直通公安
- (void)opentoPolice{
    /*
     * description : POST v1/device/share2public(共享设备给公共用户)
     *  param：access_token=<令牌> & user_id=<用户ID> & dev_id=<设备ID> & puser_id=<共享的用户ID> & share_info=<设备共享信息>
     */
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults objectForKey:@"user_id"];
    [dic setObject:userID forKey:@"user_id"];
    [dic setObject:self.policeID forKey:@"puser_id"];
    [dic setObject:self.listModel.ID forKey:@"dev_id"];
    [dic setObject:@"" forKey:@"share_info"];//暂时不需要该参数
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/share2public" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        //NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            istoPolice = YES;
            [self.tableView reloadData];
        }else{
            istoPolice = NO;
            [self.tableView reloadData];
            [XHToast showBottomWithText:@"分享失败"];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [XHToast showBottomWithText:@"由于网络原因，分享失败"];
    }];
}


//获取图像设置信息
-(void)getImageSetData{
    /*
     *  description : GET  v1/device/getpictureconfig(查询视频图像参数)
     *  param : access_token=<令牌> & user_id=<用户ID> & dev_id=<设备ID>
     */
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [defaults objectForKey:@"user_id"];
    [dic setObject:self.listModel.ID forKey:@"dev_id"];
    [dic setObject:userID forKey:@"user_id"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/getpictureconfig" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            //图像设置
            ImageSetViewController *imageSetVC = [[ImageSetViewController alloc]init];
            imageSetVC.listModel = self.listModel;
            
            //镜像显示
            imageSetVC.mirror = responseObject[@"body"][@"pictureConfig"][@"mirror"];
            //旋转显示
            imageSetVC.rotate = responseObject[@"body"][@"pictureConfig"][@"rotate"];
            //开关显示
            NSString *enableStr = [NSString stringWithFormat:@"%@",responseObject[@"body"][@"pictureConfig"][@"wdrEnable"]];
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
            [XHToast showCenterWithText:@"获取图像设置失败,请重试"];
        }
    } failure:^(NSError * _Nonnull error) {
        //查询失败,取消加载动画
        [CircleLoading hideCircleInView:self.view];
        [XHToast showCenterWithText:@"获取图像设置失败,请检查您的网络"];
    }];
}
//}
//#pragma mark - TableView 占位图
//- (UIImage *)xy_noDataViewImage {
//    return [UIImage imageNamed:@"defualt_no_data.png"];
//}
//
//- (NSString *)xy_noDataViewMessage {
//    return @"暂无数据哦~";
//}
//
//- (UIColor *)xy_noDataViewMessageColor {
//    return [UIColor lightGrayColor];

//=========================lazy loading=========================


@end
