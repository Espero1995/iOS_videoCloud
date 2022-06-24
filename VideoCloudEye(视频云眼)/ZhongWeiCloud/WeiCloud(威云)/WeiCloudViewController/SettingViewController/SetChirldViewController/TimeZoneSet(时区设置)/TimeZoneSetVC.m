//
//  TimeZoneSetVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/12/28.
//  Copyright © 2018 张策. All rights reserved.
//

#import "TimeZoneSetVC.h"
#import "SettingCellOne_t.h"
#import "SinglePickView.h"
#import "SetPickerView.h"
#import "TimeZonePickerView.h"
#import "CircleLoading.h"
#import "CircleSuccessLoading.h"
@interface TimeZoneSetVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    SinglePickViewDelegate,
    TimeZonePickerViewDelegate
>
{
    /*保存按钮*/
    UIButton * _saveBtn;
    BOOL isBeginDate;
    SetPickerView* timePickerView;
    NSArray* _proTimeList;//小时数组
    NSArray* _proTitleList;//分钟数组
    NSString* _hourStr;//选择器小时
    NSString* _minStr;//选择器分钟
}
/*表视图*/
@property (nonatomic,strong) UITableView *tv_list;
//时区字符
@property (nonatomic,copy) NSString *timeZoneStr;
//时令 0：无；1：夏令时；2：冬令时
@property (nonatomic,assign) int seasonType;
//偏移量
@property (nonatomic,assign) int offset;
//开始日期
@property (nonatomic,copy) NSString *beginDate;
//结束日期
@property (nonatomic,copy) NSString *endDate;
//日期选择器
@property (strong, nonatomic) TimeZonePickerView *dateView;
@end

@implementation TimeZoneSetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"时区设置", nil);
    self.view.backgroundColor = BG_COLOR;
    [self cteateNavBtn];
    [self setBarButtonItem];
    [self getTimeZone];
    [self createdateData];
    [self.view addSubview:self.tv_list];
}

//=========================init=========================
#pragma mark - 设置导航栏按钮和响应事件
- (void)setBarButtonItem{
    _saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [_saveBtn setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateNormal];
    [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_saveBtn addTarget:self action:@selector(saveTimeZoneSet) forControlEvents:UIControlEventTouchUpInside];
    _saveBtn.highlighted = YES;
    _saveBtn.userInteractionEnabled = YES;
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:_saveBtn];
    UIBarButtonItem * rightSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    rightSpace.width = -10;
    self.navigationItem.rightBarButtonItems = @[rightItem,rightSpace];
}

#pragma mark - 创建日期数据
- (void)createdateData{
    _proTimeList = [[NSArray alloc]initWithObjects:@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23", nil];
    _proTitleList = [[NSArray alloc]initWithObjects:@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"50",@"51",@"52",@"53",@"54",@"55",@"56",@"57",@"58",@"59", nil];
}

//=========================method=========================
#pragma mark - 获取时区
- (void)getTimeZone
{
    NSString *tempZoneStr = [self.model.timeZone substringToIndex:self.model.timeZone.length-2];
    self.timeZoneStr = [NSString stringWithFormat:@"GMT%@",tempZoneStr];
    self.seasonType = self.model.dayLight.Type;
    self.offset = self.model.dayLight.Offset;
    self.beginDate = self.model.dayLight.BeginDate;
    self.endDate = self.model.dayLight.EndDate;
    _hourStr = [NSString stringWithFormat:@"%.2d",self.offset/60];
    _minStr = [NSString stringWithFormat:@"%.2d",self.offset%60];
}

#pragma mark - 保存时区设置
- (void)saveTimeZoneSet
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [postDic setObject:self.dev_mList.ID forKey:@"dev_id"];
    
    if (self.seasonType != 0) {
        if ([self.beginDate isEqualToString:@"0000"]||[self.endDate isEqualToString:@"0000"]||self.offset == 0) {
            [XHToast showCenterWithText:NSLocalizedString(@"请完成时令设置", nil)];
            return;
        }else{
            [postDic setObject:[NSNumber numberWithInt:self.offset] forKey:@"offset"];
            self.beginDate = [self.beginDate stringByReplacingOccurrencesOfString:@"-" withString:@""];
            self.endDate = [self.endDate stringByReplacingOccurrencesOfString:@"-" withString:@""];
            [postDic setObject:self.beginDate forKey:@"beginDate"];
            [postDic setObject:self.endDate forKey:@"endDate"];
            
            
            NSDate *date = [NSDate date];
            NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"yyyy"];
            NSInteger year = [[dateformatter stringFromDate:date]integerValue];
            
            NSString *beginDay = [self.beginDate substringFromIndex:2];
            NSString *beginCompareDay = [self getYearNumber:year month:[[self.beginDate substringToIndex:2] integerValue]];
            
            NSString *endDay = [self.endDate substringFromIndex:2];
            NSString *endCompareDay = [self getYearNumber:year month:[[self.endDate substringToIndex:2] integerValue]];
            
            if ([beginDay intValue] > [beginCompareDay intValue]) {
                [XHToast showCenterWithText:NSLocalizedString(@"开始日期不合法", nil)];
                [self recoverBeginandEndDate];
                return;
            }
            
            if ([endDay intValue] > [endCompareDay intValue]) {
                [XHToast showCenterWithText:NSLocalizedString(@"结束日期不合法", nil)];
                [self recoverBeginandEndDate];
                return;
            }
        }
        
    }
    
    NSNumber *typeNum = [NSNumber numberWithInt:self.seasonType];
    [postDic setObject:typeNum forKey:@"type"];
    NSString *time_zone = [NSString stringWithFormat:@"%@00",[self.timeZoneStr substringFromIndex:3]];
    NSLog(@"时区:%@,时令:%d",self.timeZoneStr,self.seasonType);
    [postDic setObject:time_zone forKey:@"time_zone"];
    
    [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"正在保存时区设置", nil)];
    [[HDNetworking sharedHDNetworking] POST:@"v1/device/setDeviceTimeZone" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            [CircleLoading hideCircleInView:self.view];
            [CircleSuccessLoading showSucInView:self.view andTip:NSLocalizedString(@"时区设置成功", nil)];
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [self.navigationController popViewControllerAnimated:YES];
            });
        }else{
            [CircleLoading hideCircleInView:self.view];
            [self recoverBeginandEndDate];
            [XHToast showCenterWithText:NSLocalizedString(@"时区设置失败,请稍候再试", nil)];
        }
        
        
    } failure:^(NSError * _Nonnull error) {
        [CircleLoading hideCircleInView:self.view];
        [self recoverBeginandEndDate];
        [XHToast showCenterWithText:NSLocalizedString(@"时区设置失败,请检查您的网络", nil)];
    }];
    
}

#pragma mark - 创建pickerView
- (void)createPickerView
{
    NSInteger hourTime = [_hourStr integerValue];
    NSInteger minuteTime = [_minStr integerValue];
    
    timePickerView = [[SetPickerView alloc]initWithFrame:CGRectMake(0, -iPhoneHeight, iPhoneWidth, 236.0f)];
    
    timePickerView.hourPickerData = _proTimeList;
    timePickerView.minPickerData = _proTitleList;
    [timePickerView.pickerView selectRow:hourTime inComponent:0 animated:YES];
    [timePickerView.pickerView selectRow:minuteTime inComponent:1 animated:YES];
    
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
#pragma mark - 获取对应月份的日期
- (NSString *)getYearNumber:(NSInteger)year month:(NSInteger)month{
    NSArray *days = @[@"31", @"28", @"31", @"30", @"31", @"30", @"31", @"31", @"30", @"31", @"30", @"31"];
    if (2 == month && 0 == (year % 4) && (0 != (year % 100) || 0 == (year % 400))) {
        return @"29";
    }
    return days[month - 1];
}

#pragma mark - 时区、开始/结束时间恢复原来的格式
- (void)recoverBeginandEndDate
{
    self.beginDate = [NSString stringWithFormat:@"%@-%@",[self.beginDate substringToIndex:2],[self.beginDate substringFromIndex:2]];
    self.endDate = [NSString stringWithFormat:@"%@-%@",[self.endDate substringToIndex:2],[self.endDate substringFromIndex:2]];
}

//=========================delegate=========================
//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}
//section顶部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headView = [[UIView alloc]initWithFrame:CGRectMake(15, 0, iPhoneWidth, 15)];
    headView.backgroundColor = BG_COLOR;
    return headView;
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.001;
}

//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, 0.001)];
    footView.backgroundColor = [UIColor clearColor];
    return footView;
}

//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.seasonType == 0) {
        return 2;
    }else{
        return 4;
    }
}

//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 3) {
        return 2;
    }else{
      return 1;
    }
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

    static NSString* Cell_Identifier = @"Cell_Identifier";
    SettingCellOne_t* cell = [tableView dequeueReusableCellWithIdentifier:Cell_Identifier];
    if(!cell){
        cell = [[SettingCellOne_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cell_Identifier];
    }
   
    if (section == 0) {
        cell.typeLabel.text = NSLocalizedString(@"时区", nil);
        cell.titleLabel.text = self.timeZoneStr;
    }else if (section == 1){
        cell.typeLabel.text = NSLocalizedString(@"时令", nil);
        if (self.seasonType == 0) {
            cell.titleLabel.text = NSLocalizedString(@"无", nil);
        }else if (self.seasonType == 1){
            cell.titleLabel.text = NSLocalizedString(@"夏令时", nil);
        }else{
            cell.titleLabel.text = NSLocalizedString(@"冬令时", nil);
        }
        
    }else if (section == 2){
        cell.typeLabel.text = NSLocalizedString(@"偏移量", nil);
        if (([_hourStr isEqualToString:@"00"] && [_minStr isEqualToString:@"00"]) || (!_hourStr && !_minStr)) {
            cell.titleLabel.text = @"";
            self.offset = 0;
        }else{
            cell.titleLabel.text = [NSString stringWithFormat:@"%@h%@m",_hourStr,_minStr];
            self.offset = [_hourStr intValue]*60+[_minStr intValue];
        }

    }else{
        if (row == 0) {
            cell.typeLabel.text = NSLocalizedString(@"开始日期", nil);
            
            if ([self.beginDate isEqualToString:@""]||[self.endDate isEqualToString:@"0000"]) {
                cell.titleLabel.text = @"";
            }else{
                if([self.beginDate rangeOfString:@"-"].location !=NSNotFound){
                    cell.titleLabel.text = self.beginDate;
                }else{
                    cell.titleLabel.text = [NSString stringWithFormat:@"%@-%@",[self.beginDate substringToIndex:2],[self.beginDate substringFromIndex:2]];
                    self.beginDate = cell.titleLabel.text;
                }
            }

        }else{
            cell.typeLabel.text = NSLocalizedString(@"结束日期", nil);
            if ([self.endDate isEqualToString:@""]||[self.endDate isEqualToString:@"0000"]) {
                cell.titleLabel.text = @"";
            }else{
                if([self.endDate rangeOfString:@"-"].location !=NSNotFound){
                    cell.titleLabel.text = self.endDate;
                }else{
                    cell.titleLabel.text = [NSString stringWithFormat:@"%@-%@",[self.endDate substringToIndex:2],[self.endDate substringFromIndex:2]];
                    self.endDate = cell.titleLabel.text;
                }
            }
            
        }
    }
    return cell;
}

//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0) {
        NSArray *arr = @[@"GMT+0",@"GMT+1",@"GMT+2",@"GMT+3",@"GMT+4",@"GMT+5",@"GMT+6",@"GMT+7",@"GMT+8",@"GMT+9",@"GMT+10",@"GMT+11",@"GMT+12",@"GMT-12",@"GMT-11",@"GMT-10",@"GMT-9",@"GMT-8",@"GMT-7",@"GMT-6",@"GMT-5",@"GMT-4",@"GMT-3",@"GMT-2",@"GMT-1"];

        SinglePickView *sv;
        if (!([arr indexOfObject:self.timeZoneStr] > arr.count)) {
            sv = [[SinglePickView alloc] initWithArray:arr Select:[arr indexOfObject:self.timeZoneStr] Tag:1];
        }else{
            sv = [[SinglePickView alloc] initWithArray:arr Select:0 Tag:1];
        }
        sv.delegate = self;
        [sv show];
    }else if (section == 1){
        NSArray *arr = @[NSLocalizedString(@"无", nil),NSLocalizedString(@"夏令时", nil),NSLocalizedString(@"冬令时", nil)];
        SinglePickView *sv = [[SinglePickView alloc] initWithArray:arr Select:self.seasonType Tag:2];
        sv.delegate = self;
        [sv show];
    }else if (section == 2){
        [self createPickerView];
        [timePickerView popPickerView];
    
    }else{
        if (row == 0) {
            isBeginDate = YES;
            NSString *month,*day;
            if (![self.beginDate isEqualToString:@""]) {
                month = [NSString stringWithFormat:@"%@%@",[self.beginDate substringToIndex:2],NSLocalizedString(@"选择器月", nil)];
                day = [NSString stringWithFormat:@"%@%@",[self.beginDate substringFromIndex:3],NSLocalizedString(@"选择器日", nil)];
            }else{
                NSDate *today = [NSDate date];
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"MM-dd"];
                NSString *dateStr;
                dateStr=[format stringFromDate:today];
                month = [NSString stringWithFormat:@"%@%@",[dateStr substringToIndex:2],NSLocalizedString(@"选择器月", nil)];
                day = [NSString stringWithFormat:@"%@%@",[dateStr substringFromIndex:3],NSLocalizedString(@"选择器日", nil)];
            }
            

            [self.dateView show:month andDay:day];
        }else{
            isBeginDate = NO;
            NSString *month,*day;
            if (![self.endDate isEqualToString:@""]) {
                month = [NSString stringWithFormat:@"%@%@",[self.endDate substringToIndex:2],NSLocalizedString(@"选择器月", nil)];
                day = [NSString stringWithFormat:@"%@%@",[self.endDate substringFromIndex:3],NSLocalizedString(@"选择器日", nil)];
            }else{
                NSDate *today = [NSDate date];
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"MM-dd"];
                NSString *dateStr;
                dateStr=[format stringFromDate:today];
                month = [NSString stringWithFormat:@"%@%@",[dateStr substringToIndex:2],NSLocalizedString(@"选择器月", nil)];
                day = [NSString stringWithFormat:@"%@%@",[dateStr substringFromIndex:3],NSLocalizedString(@"选择器日", nil)];
            }
            
            
            [self.dateView show:month andDay:day];
        }
    }
}

#pragma mark - SinglePickViewDelegate
-(void)SinglePickViewTag:(NSInteger)t Select:(NSInteger)index Value:(NSString *)value
{
    if (t==1) {
        self.timeZoneStr = value;
        [self.tv_list reloadData];
    }
    if (t==2) {
        if ([value isEqualToString:NSLocalizedString(@"无", nil)]) {
            self.seasonType = 0;
        }else if ([value isEqualToString:NSLocalizedString(@"夏令时", nil)]){
            self.seasonType = 1;
        }else{
            self.seasonType = 2;
        }
        [self.tv_list reloadData];
    }
    
}


#pragma mark - TimeZonePickerViewDelegate
/**
 保存按钮代理方法
 @param timer 选择的数据
 */
- (void)datePickerViewSaveBtnClickDelegate:(NSString *)timer {
    NSLog(@"保存点击");
    if (isBeginDate) {
        self.beginDate = timer;
    }else{
        self.endDate = timer;
    }
    [self.tv_list reloadData];
}

//=========================lazy loading=========================
#pragma mark - 懒加载部分
-(UITableView *)tv_list{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, hideNavHeight, self.view.width, iPhoneHeight-64) style:UITableViewStyleGrouped];
        //设置代理
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        _tv_list.backgroundColor = BG_COLOR;
        _tv_list.scrollEnabled = NO;
        _tv_list.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tv_list;
}

- (TimeZonePickerView *)dateView
{
    if (!_dateView) {
        _dateView = [[TimeZonePickerView alloc]initWithFrame:CGRectMake(0, iPhoneHeight, iPhoneWidth, 236.0f)];
        _dateView.delegate = self;
        _dateView.title = NSLocalizedString(@"请选择时间", nil);
        [self.view addSubview:_dateView];
    }
    return _dateView;
}

@end
