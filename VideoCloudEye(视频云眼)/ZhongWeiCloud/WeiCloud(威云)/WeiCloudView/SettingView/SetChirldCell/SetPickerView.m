//
//  SetPickerView.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/28.
//  Copyright © 2017年 张策. All rights reserved.
//
#define SCREEN_WIDTH                [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT               [[UIScreen mainScreen] bounds].size.height
#define PICKERVIEW_HEIGHT           236.0
#import "SetPickerView.h"
@interface SetPickerView () <UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSInteger _hourRow;
    NSInteger _minRow;
}

@property (retain, nonatomic) UIView *baseView;

@end
@implementation SetPickerView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
    if (self) {
        
        _baseView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-PICKERVIEW_HEIGHT, SCREEN_WIDTH, PICKERVIEW_HEIGHT)];
        _baseView.backgroundColor = MAIN_COLOR;
        
        _btnOK = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, 0, 40, 40)];
        [_btnOK setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
        [_btnOK setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnOK.selected = NO;
        [_btnOK addTarget:self action:@selector(pickerViewBtnOK:) forControlEvents:UIControlEventTouchUpInside];
        [_baseView addSubview:_btnOK];
        
        UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 60, 40)];
        [btnCancel setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnCancel addTarget:self action:@selector(pickerViewBtnCancel:) forControlEvents:UIControlEventTouchUpInside];
        [_baseView addSubview:btnCancel];
        
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, 216)];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.backgroundColor = [UIColor whiteColor];
        [_baseView addSubview:_pickerView];
        [self addSubview:_baseView];
    }
    return self;
}

#pragma mark - UIPickerViewDataSource
//返回多少列
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

//每列对应多少行
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return _hourPickerData.count;
    }
    return _minPickerData.count;
}

//每行显示的数据
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        _hourRow = row;
        return _hourPickerData[row];
    }
    _minRow = row;
    return _minPickerData[row];
}


#pragma mark - UIPickerViewDelegate
//选中pickerView的某一行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        _hourRow = row;
    }
    if (component == 1) {
         _minRow = row;
    }
   
}

#pragma mark - Private Menthods

//弹出pickerView
- (void)popPickerView
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    [UIView animateWithDuration:0.25
                     animations:^{
                         _baseView.frame = CGRectMake(0, iPhoneHeight-PICKERVIEW_HEIGHT, iPhoneWidth, PICKERVIEW_HEIGHT);// hideNavHeight
                     }];
   
}

//取消pickerView
- (void)dismissPickerView
{
    [UIView animateWithDuration:0.25f animations:^{
        _baseView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

//确定
- (void)pickerViewBtnOK:(id)sender
{
    if (self.selectBlock) {
//        NSLog(@"小时：%@分钟：%@",_hourPickerData[_hourRow],_minPickerData[_minRow]);
        self.selectBlock(_hourPickerData[_hourRow],_minPickerData[_minRow]);
    }
    _btnOK.selected = YES;
    [self dismissPickerView];
    
}

//取消
- (void)pickerViewBtnCancel:(id)sender
{
    if (self.selectBlock) {
        self.selectBlock(nil,nil);
    }
    
    [self dismissPickerView];
    
}

@end
