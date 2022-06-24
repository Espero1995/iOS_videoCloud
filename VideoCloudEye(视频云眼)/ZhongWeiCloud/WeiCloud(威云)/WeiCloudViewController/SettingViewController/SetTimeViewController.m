//
//  SetTimeViewController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/27.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "SetTimeViewController.h"
#import "ZCTabBarController.h"
#import "SettingCellOne_t.h"
#import "SettingCellTwo_t.h"
#import "WeekViewController.h"
#import "SetPickerView.h"
#import "SettingViewController.h"
#import "SetTimeModel.h"
@interface SetTimeViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
{
    SetPickerView * timePickerView;

    NSArray * _proTimeList ;
    NSArray * _proTitleList;
    //选择器小时
    NSString * _timeStr;
    //选择器分钟
    NSString * _minStr;
    //开始时间
    NSString * _beginTime;
    //结束时间
    NSString * _stopTime;
    //重复周期
    NSMutableString * _weekString;
    NSMutableArray * _dataArr;
    //判断编辑哪个cell
    BOOL _editing;
    BOOL _reading;
    
}
@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) UILabel *deleteLabel;

@property (nonatomic,strong) NSArray *array;

@property (nonatomic,strong) UIButton *editButton;

@property (nonatomic,strong) UIView *backView;

@property (nonatomic,strong) UILabel *label;
/*灵敏度*/
@property (nonatomic,copy) NSString *sensibility;

@end

@implementation SetTimeViewController
//-------------------------------------system-------------------------------------
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置时间";
    self.view.backgroundColor = BG_COLOR;
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    //导航栏按钮
    [self cteateNavBtn];
    //数据源
    [self createData];
    //tableView
    [self createTableView];
    _reading = YES;
    
    NSLog(@"打印看看是否打开了活动检测提醒：%d",_subing);
    if (_subing) {
        NSLog(@"打开了活动检测提醒");
    }else{
        NSLog(@"未打开活动检测提醒");
    }
    
}

#pragma mark ------接受子页面传值
-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
    
    NSComparator finderSort = ^(id string1,id string2){
        
        if ([string1 integerValue] > [string2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }else if ([string1 integerValue] < [string2 integerValue]){
            return (NSComparisonResult)NSOrderedAscending;
        }
        else
            return (NSComparisonResult)NSOrderedSame;
    };
    _weekString = [[NSMutableString alloc]init];
    //数组排序：
    _array = [_weekArray sortedArrayUsingComparator:finderSort];
    for (int i = 1; i<=_array.count; i++) {
        NSString * str = _array[i-1];
        [_weekString appendString:str];
        if (i < _array.count) {
            [_weekString appendFormat:@","];
            
        }
    }
    [self.tableView reloadData];
    NSLog(@"%@",_weekString);
    NSLog(@"%@",_array);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//-------------------------------------init-------------------------------------
#pragma mark ----- 导航栏按钮和响应事件
//导航栏按钮
- (void)cteateNavBtn{
    UIButton * backButton = [[UIButton alloc]initWithFrame:CGRectMake(13, 0, 40, 14)];
    
    [backButton setTitle:@"取消" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.highlighted = YES;
    backButton.userInteractionEnabled = YES;
    
    [backButton addTarget:self action:@selector(createAlert) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    UIBarButtonItem * leftSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    //    leftSpace.width = 13;
    self.navigationItem.leftBarButtonItems = @[leftSpace,leftItem];
    
    _editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 14)];
    [_editButton setTitle:@"保存" forState:UIControlStateNormal];
    [_editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_editButton addTarget:self action:@selector(reservePlan) forControlEvents:UIControlEventTouchUpInside];
    _editButton.highlighted = YES;
    _editButton.userInteractionEnabled = YES;
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:_editButton];
    UIBarButtonItem * rightSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    rightSpace.width = -13;
    self.navigationItem.rightBarButtonItems = @[rightSpace,rightItem];
 
}

#pragma mark ----- 数据源
//数据源
- (void)createData{
    _proTimeList = [[NSArray alloc]initWithObjects:@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23", nil];
    _proTitleList = [[NSArray alloc]initWithObjects:@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"50",@"51",@"52",@"53",@"54",@"55",@"56",@"57",@"58",@"59", nil];
    
    _dataArr = [[NSMutableArray alloc]init];
    _timeStr = [[NSMutableString alloc]init];
    _minStr = [[NSMutableString alloc]init];
    _weekString = [[NSMutableString alloc]init];
    _beginTime = [[NSString alloc]init];
    _stopTime = [[NSString alloc]init];
    [self getData];
    
}


#pragma mark ------ 创建tableview
// 创建tableView
-(void)createTableView{
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, iPhoneHeight) style:UITableViewStylePlain];
    //设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = BG_COLOR;
    
    UIView * headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 35)];
    headView.backgroundColor = BG_COLOR;
    self.tableView.tableHeaderView = headView;
    UIView *footView = [[UIView alloc]init];
    self.tableView.tableFooterView = footView;
    [self.view addSubview:self.tableView];
}


//-------------------------------------method-------------------------------------
- (void)createAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示"message:@"时间设置尚未保存,确定返回？"preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消返回" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定返回" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self returnVC];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

//返回上一页
- (void)returnVC{
    SettingViewController * setVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    if (![NSString isNull:[NSString isNullToString:_stopTime]]) {
        setVC.minTime = [NSMutableString stringWithString:_stopTime];
    }else{
        setVC.minTime = nil;
    }
    if (![NSString isNull:[NSString isNullToString:_beginTime]]) {
        setVC.hourTime = [NSMutableString stringWithString:_beginTime];
    }else{
        setVC.hourTime = nil;
    }
    setVC.subing = _subing;
    [self.navigationController popToViewController:setVC animated:true];

}

#pragma mark ------ 查询布防
//查询布放
- (void)getData{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.listModel.ID forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking] GET:@"v1/device/getguardplan" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        
        NSLog(@"打印出数据:%@",responseObject);
        
        
        if (ret == 0) {
            
            /*
             * description: 查询灵敏度的Key在不在，不在：则设置灵敏度为默认值：50；否则怎传入该值。
             */
            if (responseObject[@"body"][@"guardConfigList"]) {
                NSArray *tempArr = (NSArray *)(responseObject[@"body"][@"guardConfigList"]);
                NSDictionary *tempDic = (NSDictionary *)tempArr[0];
                //[[tempDic objectForKey:@"sensibility"] isKindOfClass:[NSNull class]]
                
                if (![[tempDic allKeys] containsObject:@"sensibility"]) {
                    NSLog(@"不存在senivlity");
                    self.sensibility = @"50";//默认50
                }else{
                    NSLog(@"存在senivlity");
                    self.sensibility = [tempDic objectForKey:@"sensibility"];
                }
                
            }
            
            
            
            [_dataArr removeAllObjects];
            SetTimeModel * model = [SetTimeModel mj_objectWithKeyValues:responseObject[@"body"]];
            _dataArr = [NSMutableArray arrayWithArray:model.guardConfigList];
            NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:model.guardConfigList[0]];
            _beginTime = [dic valueForKey:@"start_time"];
            _stopTime = [dic valueForKey:@"stop_time"];
            _weekString = [dic valueForKey:@"period"];
            int  temp = [dic[@"enable"] intValue];
            if (temp == 1) {
                _subing = YES;
            }else if (temp == 0){
                _subing = NO;
            }
            [self.tableView reloadData];
            [self.backView removeFromSuperview];
        }else{
        
            _beginTime = @"00:00";
            _stopTime = @"23:59";
            [self.tableView reloadData];
            [self.backView removeFromSuperview];
        }
    } failure:^(NSError * _Nonnull error) {
    [self.backView removeFromSuperview];
    }];
}

//确定按钮
- (void)reservePlan{
    [self ActivityDetectionAlert:@"时间设置中..."];
    [self setGuardPlan];
}

#pragma mark ------ 设置布防
//设置布放
- (void)setGuardPlan{
//     NSLog(@"打印看看是否打开了活动检测提醒：%d",_subing);
    NSMutableDictionary * guardDic = [NSMutableDictionary dictionary];
    [guardDic setObject:self.listModel.ID forKey:@"dev_id"];
    [guardDic setObject:@"1"forKey:@"alarmType"];
    if (_subing == YES) {
        [guardDic setObject:@"1" forKey:@"enable"];

    }else if (_subing == NO){
        [guardDic setObject:@"0" forKey:@"enable"];
        
    }
    [guardDic setObject:_beginTime forKey:@"start_time"];
    [guardDic setObject:_stopTime forKey:@"stop_time"];
    [guardDic setObject:_weekString forKey:@"period"];
    
    //灵敏度
    NSNumber *degree = @([self.sensibility integerValue]);
    [guardDic setObject:degree forKey:@"sensibility"];
    
    NSLog(@"guardDicguardDicguardDic%@",guardDic);
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/setguardplan" parameters:guardDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"更改成功");
        SettingViewController * setVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        if (![NSString isNull:[NSString isNullToString:_stopTime]]) {
            setVC.minTime = [NSMutableString stringWithString:_stopTime];
        }else{
            setVC.minTime = nil;
        }
        if (![NSString isNull:[NSString isNullToString:_stopTime]]) {
            setVC.hourTime = [NSMutableString stringWithString:_beginTime];
        }else{
            setVC.minTime = nil;
        }
        setVC.subing = _subing;
         [_backView removeFromSuperview];
        [self.navigationController popToViewController:setVC animated:true];
    } failure:^(NSError * _Nonnull error) {
        [_backView removeFromSuperview];
        [self createNetWrong];
    }];
}

- (void)createNetWrong{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"网络请求异常提示"message:@"布防设置失败，是否退出？"preferredStyle:UIAlertControllerStyleAlert];
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
    //    _label.backgroundColor=[UIColor redColor];
    _label.textColor = [UIColor whiteColor];
    float contentWidth = size.width + 50 +35;
    //NSLog(@"内容的宽度:%f",contentWidth);
    //来刚好容纳菊花旋转+字
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake((0.7*iPhoneWidth - contentWidth)/2, 0, contentWidth, 60)];
    //    contentView.backgroundColor = [UIColor blueColor];
    
    [contentView addSubview:activ];
    [contentView addSubview:_label];
    
    [view addSubview:contentView];
    
}

//-------------------------------------delegate-------------------------------------

//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else
        return 1;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        if (indexPath.section == 0){
        static NSString * str1 = @"MyCell1";
        SettingCellOne_t * firstCell = [tableView dequeueReusableCellWithIdentifier:str1];
        if(!firstCell){
            
            firstCell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str1];
        }

        if (indexPath.row == 0) {
            if (_reading == YES && _editing == NO) {
                if (![NSString isNull:[NSString isNullToString:_beginTime]]) {
                    firstCell.titleLabel.text = _beginTime;
                }else{
                    firstCell.titleLabel.text = @"";
                }
            }else if (_reading == NO && _editing == NO){
                firstCell.titleLabel.text = [NSString stringWithFormat:@"%@:%@",_timeStr,_minStr];
                _beginTime = firstCell.titleLabel.text;
            }
            
            firstCell.typeLabel.text = @"开始时间";
        }else if (indexPath.row == 1){
            if (![NSString isNull:[NSString isNullToString:_stopTime]]) {
                firstCell.titleLabel.text = _stopTime;
            }else{
                firstCell.titleLabel.text = @"";
            }
            if (_editing == YES) {
                firstCell.titleLabel.text = [NSString stringWithFormat:@"%@:%@",_timeStr,_minStr];
                _stopTime = firstCell.titleLabel.text;
            }
            firstCell.typeLabel.text = @"结束时间";
        }

        firstCell.pushImage.image = [UIImage imageNamed:@"more"];
        return firstCell;
    }
    static NSString * str1 = @"MyCell1";
    SettingCellOne_t * firstCell = [tableView dequeueReusableCellWithIdentifier:str1];
    if(!firstCell){
        firstCell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str1];
    }

    firstCell.typeLabel.text = @"重复";
    NSArray * titleArr = @[@"",@"周一,",@"周二,",@"周三,",@"周四,",@"周五,",@"周六,",@"周日"];
    NSMutableString * titleStr = [[NSMutableString alloc]init];
    NSArray * arr;
    if (![NSString isNull:[NSString isNullToString:_weekString]]) {
        arr = [_weekString componentsSeparatedByString:@","];
    }
    for (int i = 0; i<arr.count; i++) {

        [titleStr appendFormat:@"%@", titleArr[[arr[i] integerValue]]];
    }
    firstCell.titleLabel.text = [NSString stringWithFormat:@"%@",titleStr];
    return firstCell;
        
    
}
#pragma mark ----- 设置区头区尾
//区尾高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 0;
    }
    return 30;
}

//区尾
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
        UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 50)];
    backView.backgroundColor = BG_COLOR;
        return backView;
}
#pragma mark ------cell的点击事件
//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        WeekViewController * weekVC = [[WeekViewController alloc]init];
        weekVC.listModel = _listModel;
        [self.navigationController pushViewController:weekVC animated:YES];
    }else if (indexPath.section == 0){
        [self createPickerView];
        [timePickerView popPickerView];
        if (indexPath.row == 0) {
            _editing = NO;
            _reading = NO;
            
        }else if (indexPath.row == 1){
            _editing = YES;
            
        }
    }
}


#pragma mark ------pickerView
- (void)createPickerView{
    NSLog(@"创建pickerview");
    timePickerView = [[SetPickerView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    timePickerView.hourPickerData = _proTimeList;
    timePickerView.minPickerData = _proTitleList;
    [timePickerView.pickerView selectRow:0 inComponent:0 animated:YES];
    [timePickerView.pickerView selectRow:0 inComponent:1 animated:YES];
    [self.view addSubview:timePickerView];
//    __block SetTimeViewController * blockSelf = self;
    timePickerView.selectBlock = ^(NSString * hourStr,NSString *minStr){
        _timeStr = hourStr;
        _minStr = minStr;
    };
    [timePickerView.btnOK addTarget:self action:@selector(reloadTableView) forControlEvents:UIControlEventTouchUpInside];

}
- (void)reloadTableView{
    [self.tableView reloadData];
}



@end
