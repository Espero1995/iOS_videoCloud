//
//  TimeZonePickerView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/1/2.
//  Copyright © 2019 张策. All rights reserved.
//

#import "TimeZonePickerView.h"

@interface TimeZonePickerView () <UIPickerViewDelegate, UIPickerViewDataSource>
{
    UIView *rootView;
}

@property (strong, nonatomic) UIView *toolView; // 工具条
@property (strong, nonatomic) UILabel *titleLbl; // 标题

@property (strong, nonatomic) NSMutableArray *dataArray; // 数据源
@property (copy, nonatomic) NSString *selectStr; // 选中的时间


@property (strong, nonatomic) NSMutableArray *monthArr; // 月数组
@property (strong, nonatomic) NSMutableArray *dayArr; // 日数组
@property (strong, nonatomic) NSArray *timeArr; // 当前时间数组

@property (copy, nonatomic) NSString *month; //选中月
@property (copy, nonatomic) NSString *day; //选中日
@end


@implementation TimeZonePickerView
#define _ROOTVIEW_HEIGHT_ (236.0f)

#define _VIEW_FRAME_START_ (CGRectMake(0, iPhoneHeight, iPhoneWidth, iPhoneHeight))
#define _VIEW_FRAME_END_ (CGRectMake(0, iPhoneHeight-_ROOTVIEW_HEIGHT_, iPhoneWidth, _ROOTVIEW_HEIGHT_))

#pragma mark - init
/// 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
    if (self) {
        [self setBackgroundColor:RGBA(0, 0, 0, 0.5)];
        rootView=[[UIView alloc] initWithFrame:_VIEW_FRAME_START_];
        [rootView setBackgroundColor:RGBA(0xed, 0xed, 0xed, 1)];
        
        self.timeArr = [NSArray array];
        self.dataArray = [NSMutableArray array];
        [self.dataArray addObject:self.monthArr];
        [self.dataArray addObject:self.dayArr];
        
        [self configData];
        [self configToolView];
        [self configPickerView];
    }
    return self;
}

- (void)configData {
    
    self.isSlide = YES;
    NSDate *date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM-dd"];//yyyy-
    
    self.date = [dateFormatter stringFromDate:date];
}


#pragma mark - 配置界面
/// 配置工具条
- (void)configToolView {
    
    self.toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, 40)];
    self.toolView.backgroundColor = MAIN_COLOR;
    [rootView addSubview:self.toolView];
    
    UIButton *saveBtn = [[UIButton alloc] init];
    saveBtn.frame = CGRectMake(iPhoneWidth - 70, 0, 60, 40);
    [saveBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    saveBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:saveBtn];
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(10, 0, 60, 40);
    [cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:cancelBtn];
    
    self.titleLbl = [[UILabel alloc] init];
    self.titleLbl.frame = CGRectMake(60, 0, self.frame.size.width - 120, 40);
    self.titleLbl.textAlignment = NSTextAlignmentCenter;
    self.titleLbl.textColor = [UIColor whiteColor];
    [self.toolView addSubview:self.titleLbl];
}

/// 配置UIPickerView
- (void)configPickerView {
    UIView *bule_line = [[UIView alloc] initWithFrame:CGRectMake(0, 116, iPhoneWidth, 42.5)];
    [bule_line setBackgroundColor:RGBA(0xda, 0xe8, 0xf1, 1)];
    [rootView addSubview:bule_line];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.toolView.frame), self.frame.size.width, _ROOTVIEW_HEIGHT_ - 40)];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerView.showsSelectionIndicator = YES;
    [rootView addSubview:self.pickerView];
    [self addSubview:rootView];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLbl.text = title;
}

- (void)setDate:(NSString *)date {
    _date = date;
    
    NSString *newDate = [[date stringByReplacingOccurrencesOfString:@"-" withString:@" "] stringByReplacingOccurrencesOfString:@":" withString:@" "];
    NSMutableArray *timerArray = [NSMutableArray arrayWithArray:[newDate componentsSeparatedByString:@" "]];
    [timerArray replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%@%@", timerArray[0],NSLocalizedString(@"选择器月", nil)]];
    [timerArray replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:@"%@%@", timerArray[1],NSLocalizedString(@"选择器日", nil)]];
    self.timeArr = timerArray;
}


- (void)show:(NSString *)month andDay:(NSString *)day{
    if (self.isShowing) {
        return;
    }
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];

    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 1;
        [rootView setFrame:_VIEW_FRAME_END_];
        self.show = YES;
    }];
    
//    self.month = [NSString stringWithFormat:@"%ld%@", [self.timeArr[0] integerValue],NSLocalizedString(@"选择器月", nil)];
//    self.day = [NSString stringWithFormat:@"%ld%@", [self.timeArr[1] integerValue],NSLocalizedString(@"选择器日", nil)];
    self.month = month;
    self.day = day;
    
    [self.pickerView selectRow:[self.monthArr indexOfObject:self.month] inComponent:0 animated:YES];
    [self.pickerView selectRow:[self.dayArr indexOfObject:self.day] inComponent:1 animated:YES];
}

#pragma mark - 点击方法
/// 保存按钮点击方法
- (void)saveBtnClick {
    NSString *month = self.month.length == 3 ? [NSString stringWithFormat:@"%02ld", self.month.integerValue] : [NSString stringWithFormat:@"%02ld", self.month.integerValue];
    NSString *day = self.day.length == 3 ? [NSString stringWithFormat:@"%02ld", self.day.integerValue] : [NSString stringWithFormat:@"%02ld", self.day.integerValue];
    
    self.selectStr = [NSString stringWithFormat:@"%@-%@", month, day];
    if ([self.delegate respondsToSelector:@selector(datePickerViewSaveBtnClickDelegate:)]) {
        [self.delegate datePickerViewSaveBtnClickDelegate:self.selectStr];
    }
    [self cancelBtnClick];
}

/// 取消按钮点击方法
- (void)cancelBtnClick {
    NSLog(@"点击了取消");
    if (!self.isShowing) {
        return;
    }
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 0;
        [rootView setFrame:_VIEW_FRAME_START_];
    } completion:^(BOOL finished) {
        self.show = NO;
        [self removeFromSuperview];
    }];
}
#pragma mark - UIPickerViewDelegate and UIPickerViewDataSource
/// UIPickerView返回多少组
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return self.dataArray.count;
}

/// UIPickerView返回每组多少条数据
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return  [self.dataArray[component] count] * 200;
}

/// UIPickerView选择哪一行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {

        case 0: {//月
            
            NSString *month_value = self.monthArr[row%[self.dataArray[component] count]];
            self.month = month_value;
        } break;
        case 1: {//日
            NSString *day_value = self.dayArr[row%[self.dataArray[component] count]];
            self.day = day_value;
        } break;
            
        default: break;
    }
}

/// UIPickerView返回每一行数据
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return  [self.dataArray[component] objectAtIndex:row%[self.dataArray[component] count]];
}
/// UIPickerView返回每一行的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}
/// UIPickerView返回每一行的View
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *titleLbl;
    if (!view) {
        titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 40)];
        titleLbl.font = [UIFont systemFontOfSize:15];
        titleLbl.textAlignment = NSTextAlignmentCenter;
    } else {
        titleLbl = (UILabel *)view;
    }
    titleLbl.text = [self.dataArray[component] objectAtIndex:row%[self.dataArray[component] count]];
    return titleLbl;
}


- (void)pickerViewLoaded:(NSInteger)component row:(NSInteger)row{
    NSUInteger max = 16384;
    NSUInteger base10 = (max/2)-(max/2)%row;
    [self.pickerView selectRow:[self.pickerView selectedRowInComponent:component] % row + base10 inComponent:component animated:NO];
}

/// 获取月份
- (NSMutableArray *)monthArr {
    if (!_monthArr) {
        _monthArr = [NSMutableArray array];
        for (int i = 1; i <= 12; i ++) {
            [_monthArr addObject:[NSString stringWithFormat:@"%02d%@", i,NSLocalizedString(@"选择器月", nil)]];
        }
    }
    return _monthArr;
}

/// 获取当前月的天数
- (NSMutableArray *)dayArr {
    if (!_dayArr) {
        _dayArr = [NSMutableArray array];
        for (int i = 1; i <= 31; i ++) {
            [_dayArr addObject:[NSString stringWithFormat:@"%02d%@", i,NSLocalizedString(@"选择器日", nil)]];
        }
    }
    return _dayArr;
}

@end
