//
//  RemindTimeController.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/19.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "RemindTimeController.h"
#import "RemindTimePlanVC.h"
#import "ZCTabBarController.h"
#import "SettingCellOne_t.h"//一般cell
#import "CircleLoading.h"//等待加载框
#import "CircleSuccessLoading.h"//等待成功的加载框
#import "SetPickerView.h"//pickerView

#import "PeriodTimeController.h"
@interface RemindTimeController ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
{
    SetPickerView* timePickerView;
    NSArray* _proTimeList;//小时数组
    NSArray* _proTitleList;//分钟数组
    NSString* _hourStr;//选择器小时
    NSString* _minStr;//选择器分钟
    int _editRow;//判断编辑哪个cell（1：第一个；2：第二个）
}
@property (nonatomic,strong) UITableView* tv_list;
//在该页面保留住起始时间/结束时间
@property (nonatomic,copy) NSString *tempStartTimeStr;
@property (nonatomic,copy) NSString *tempEndTimeStr;
@end

@implementation RemindTimeController
//=========================system=========================
#pragma mark ----- 生命周期 -----
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"提醒时间段", nil);
    self.view.backgroundColor = BG_COLOR;
    [self setButtonitem];
    [self cteateNavBtn];
    [self createdateData];
    //初始化数据
    _editRow = 0;
    [self.view addSubview:self.tv_list];
    NSLog(@"R灵敏度：%@,R开始时间：%@，R结束时间：%@，R周期：%@",self.sensibility,self.startTime,self.endTime,self.periodStr);
    self.tempStartTimeStr = self.startTime;
    self.tempEndTimeStr = self.endTime;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    [self.tv_list reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//=========================init=========================
#pragma mark ----- 页面初始化的一些方法 -----
#pragma mark - 设置导航栏按钮和响应事件
- (void)setButtonitem
{
    UIButton* saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [saveBtn setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveGuardPlan) forControlEvents:UIControlEventTouchUpInside];
    saveBtn.userInteractionEnabled = YES;
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    UIBarButtonItem* rightSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    rightSpace.width = -10;
    self.navigationItem.rightBarButtonItems = @[rightItem,rightSpace];
}
#pragma mark - 创建pickerView
- (void)createPickerView:(NSInteger)row
{
    NSInteger startFrontTime;
    NSInteger startBackTime;
    if (row == 0) {
        startFrontTime = [self getFrontofString:self.tempStartTimeStr];
        startBackTime = [self getBackofString:self.tempStartTimeStr];
    }else{
        startFrontTime = [self getFrontofString:self.tempEndTimeStr];
        startBackTime = [self getBackofString:self.tempEndTimeStr];
    }
    
    NSLog(@"时间是什么：%ld==%ld",(long)startFrontTime,(long)startBackTime);
    
    timePickerView = [[SetPickerView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
    timePickerView.hourPickerData = _proTimeList;
    timePickerView.minPickerData = _proTitleList;
    //
    [timePickerView.pickerView selectRow:startFrontTime inComponent:0 animated:YES];
    [timePickerView.pickerView selectRow:startBackTime inComponent:1 animated:YES];
    [self.view addSubview:timePickerView];
    timePickerView.selectBlock = ^(NSString * hourStr,NSString *minStr){
        _hourStr = hourStr;
        _minStr = minStr;
    };
    [timePickerView.btnOK addTarget:self action:@selector(reloadTableView) forControlEvents:UIControlEventTouchUpInside];
}
-(void)reloadTableView
{
    [self.tv_list reloadData];
}
#pragma mark - 创建日期数据
- (void)createdateData{
    _proTimeList = [[NSArray alloc]initWithObjects:@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23", nil];
    _proTitleList = [[NSArray alloc]initWithObjects:@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"50",@"51",@"52",@"53",@"54",@"55",@"56",@"57",@"58",@"59", nil];
}

//=========================method=========================
#pragma mark ----- 方法 -----
#pragma mark - 保存设置布防
- (void)saveGuardPlan
{
    [Toast showLoading:self.view Tips:NSLocalizedString(@"正在自定义时间段，请稍候...", nil)];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        RemindTimePlanVC *remindVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        remindVC.periodStr = self.periodStr;
        remindVC.startTime = self.startTime;
        remindVC.endTime = self.endTime;
        remindVC.isRefresh = YES;
        [self.navigationController popToViewController:remindVC animated:YES];
        [Toast dissmiss];
    });
    
}


#pragma mark - 取“：”字符串之前的部分并转成NSInterger类型
- (NSInteger)getFrontofString:(NSString *)str
{
    NSRange range = [str rangeOfString:@":"]; //现获取要截取的字符串位置
    NSString * resultStr= [str substringToIndex:range.location]; //截取字符串
    NSLog(@"时间冒号前面部分：%@",resultStr);
    if (resultStr) {
        return  [resultStr integerValue];
    }else{
        return 0;
    }
}

#pragma mark - 取“：”字符串之后的部分并转成NSInterger类型
- (NSInteger)getBackofString:(NSString *)str
{
    NSRange range = [str rangeOfString:@":"]; //现获取要截取的字符串位置
    NSString * resultStr= [str substringFromIndex:range.location+1]; //截取字符串
    NSLog(@"时间冒号后面部分：%@",resultStr);
    if (resultStr) {
        return  [resultStr integerValue];
    }else{
        return 0;
    }
}

//=========================delegate=========================
#pragma mark ----- 代理协议 -----
#pragma mark - tableview的代理方法
//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
//分区数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return 1;
}
//cell
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        if (row == 0) {
            static NSString* startTimeCell_Identifier = @"startTimeCell_Identifier";
            SettingCellOne_t* startTimeCell = [tableView dequeueReusableCellWithIdentifier:startTimeCell_Identifier];
            if(!startTimeCell){
                startTimeCell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:startTimeCell_Identifier];
            }
            startTimeCell.typeLabel.text = NSLocalizedString(@"起始时间", nil);
            
            if (_editRow == 0) {
                startTimeCell.titleLabel.text = self.startTime;
            }else if(_editRow == 1){
                
                if (_hourStr && _minStr) {
                    startTimeCell.titleLabel.text = [NSString stringWithFormat:@"%@:%@",_hourStr,_minStr];
                    self.startTime =  startTimeCell.titleLabel.text;
                    self.tempStartTimeStr = startTimeCell.titleLabel.text;
                }else{
                    startTimeCell.titleLabel.text = self.startTime;
                }
    
            }
            
            startTimeCell.pushImage.image = [UIImage imageNamed:@"more"];
            return startTimeCell;
        }else{
            static NSString* endTimeCell_Identifier = @"endTimeCell_Identifier";
            SettingCellOne_t* endTimeCell = [tableView dequeueReusableCellWithIdentifier:endTimeCell_Identifier];
            if(!endTimeCell){
                endTimeCell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:endTimeCell_Identifier];
            }
            endTimeCell.typeLabel.text = NSLocalizedString(@"结束时间", nil);
            if (_editRow == 0) {
                endTimeCell.titleLabel.text = self.endTime;
            }else if(_editRow == 2){
                if (_hourStr && _minStr) {
                    endTimeCell.titleLabel.text = [NSString stringWithFormat:@"%@:%@",_hourStr,_minStr];
                    self.endTime =  endTimeCell.titleLabel.text;
                    self.tempEndTimeStr = endTimeCell.titleLabel.text;
                }else{
                    endTimeCell.titleLabel.text = self.endTime;
                }
                
            }

            endTimeCell.pushImage.image = [UIImage imageNamed:@"more"];
            return endTimeCell;
        }
    }else{
        static NSString* periodCell_Identifier = @"periodCell_Identifier";
        SettingCellOne_t* periodCell = [tableView dequeueReusableCellWithIdentifier:periodCell_Identifier];
        if(!periodCell){
            periodCell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:periodCell_Identifier];
        }
        periodCell.typeLabel.text = NSLocalizedString(@"周期", nil);

        NSArray * titleArr = @[NSLocalizedString(@"星期一,", nil),NSLocalizedString(@"星期二,", nil),NSLocalizedString(@"星期三,", nil),NSLocalizedString(@"星期四,", nil),NSLocalizedString(@"星期五,", nil),NSLocalizedString(@"星期六,", nil),NSLocalizedString(@"星期日,", nil)];
        NSMutableString* titleStr = [[NSMutableString alloc]init];
        NSArray* tempArr;
        if (self.periodStr.length!=0) {
            tempArr = [self.periodStr componentsSeparatedByString:@","];
        }
        
        if (tempArr.count < 7){
            for (int i = 0; i<tempArr.count; i++) {
                [titleStr appendFormat:@"%@", titleArr[[tempArr[i] integerValue]-1]];
            }
            NSString* resultTitle = [titleStr substringWithRange:NSMakeRange(0, [titleStr length] - 1)];
            periodCell.titleLabel.text = [NSString stringWithFormat:@"%@",resultTitle];
            [periodCell.titleLabel setFont:FONT(11)];
        }else if(tempArr.count == 7){
            periodCell.titleLabel.text = NSLocalizedString(@"每天", nil);
            [periodCell.titleLabel setFont:FONT(14)];
        }

        periodCell.pushImage.image = [UIImage imageNamed:@"more"];
        return periodCell;
    }
}
//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (section == 0) {
        if (row == 0) {
            _editRow = 1;
            [self createPickerView:0];
        }else if (row == 1){
            _editRow = 2;
            [self createPickerView:1];
        }
        [timePickerView popPickerView];
    }else if (section == 1){
        PeriodTimeController* periodVC = [[PeriodTimeController alloc]init];
        periodVC.periodStr = self.periodStr;
        [self.navigationController pushViewController:periodVC animated:YES];
    }
    
}
//区头高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}
//区尾
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 20)];
    return headView;
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


