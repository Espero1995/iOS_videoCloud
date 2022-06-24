//
//  CenterTimeView.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/16.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "CenterTimeView.h"
#import "SZCalendarPicker.h"

@interface CenterTimeView ()

@end
@implementation CenterTimeView

+(instancetype)viewFromXib
{
    NSString *strClass =  NSStringFromClass([self class]);
    NSArray *arr = [[NSBundle mainBundle]loadNibNamed:strClass owner:self options:nil];
    return [arr lastObject];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.btn_time.layer.cornerRadius = 13.f;
    self.btn_time.layer.borderColor = RGB(190, 190, 190).CGColor;
    self.btn_time.layer.borderWidth = 1.f;
    self.btn_time.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.isCenter = NO;
}
#pragma mark ------按钮点击方法
- (IBAction)btnLeftClick:(id)sender {
    NSString *dateString = self.btn_time.titleLabel.text;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-M-d"];
    
    NSDate *date = [formatter dateFromString:dateString];
  
    NSDate *yesterday = [NSDate dateWithTimeInterval:-60 * 60 * 24 sinceDate:date];
   
  
  
    [self.btn_time setTitle:[formatter stringFromDate:yesterday] forState:UIControlStateNormal];
    if (self.delegate && [self.delegate respondsToSelector:@selector(CenterTimeViewCenterBtnClick:TimeStr:)]) {
        [self.delegate CenterTimeViewCenterBtnClick:self.isCenter TimeStr:[NSString stringWithFormat:@"%@", [formatter stringFromDate:yesterday]]];
    }
    
}
- (IBAction)btnRightClick:(id)sender {
    NSString *dateString = self.btn_time.titleLabel.text;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-M-d"];
    
    NSDate *date = [formatter dateFromString:dateString];
    

    
    NSDate *tomorrow = [NSDate dateWithTimeInterval:60 * 60 * 24 sinceDate:date];
    

    [self.btn_time setTitle:[formatter stringFromDate:tomorrow] forState:UIControlStateNormal];
    if (self.delegate && [self.delegate respondsToSelector:@selector(CenterTimeViewCenterBtnClick:TimeStr:)]) {
        [self.delegate CenterTimeViewCenterBtnClick:self.isCenter TimeStr:[NSString stringWithFormat:@"%@", [formatter stringFromDate:tomorrow]]];
    }
}

//日期日历
- (IBAction)btnTimeClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    
    //DateSelectionClick
    if (self.delegate && [self.delegate respondsToSelector:@selector(DateSelectionClick:isCenter:)]) {
        [self.delegate DateSelectionClick:btn isCenter:self.isCenter];
    }
    
    /*
    WeakSelf(self);
    __weak typeof(btn) weakBtn = btn;
    SZCalendarPicker *calendarPicker = [SZCalendarPicker showOnView:self.superview.superview];
    calendarPicker.today = [NSDate date];
    calendarPicker.date = calendarPicker.today;

    CGFloat bili = (CGFloat)(375.0000/244.000);
    CGFloat h  = (CGFloat)iPhoneWidth/bili+64;

    
   
    calendarPicker.frame = CGRectMake(0, h, self.superview.frame.size.width, self.superview.superview.bounds.size.height-h);
    calendarPicker.calendarBlock = ^(NSInteger day, NSInteger month, NSInteger year){
        [weakBtn setTitle:[NSString stringWithFormat:@"%li-%li-%li", (long)year,(long)month,(long)day] forState:UIControlStateNormal];
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(CenterTimeViewCenterBtnClick:TimeStr:)]) {
            [weakSelf.delegate CenterTimeViewCenterBtnClick:self.isCenter TimeStr:[NSString stringWithFormat:@"%li-%li-%li", (long)year,(long)month,(long)day]];
        }
    };
*/
}

- (IBAction)btn_centerClick:(id)sender {
    [self.btn_center setImage:[UIImage imageNamed:@"buttonCenter_h"] forState:UIControlStateNormal];
//    self.btn_center.contentMode = UIViewContentModeScaleToFill;
    [self.btn_front setImage:[UIImage imageNamed:@"buttonFront_n"] forState:UIControlStateNormal];
//    self.btn_front.contentMode = UIViewContentModeScaleToFill;
    self.isCenter = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(CenterTimeViewLeftBtnClick:TimeStr:)]) {
        [self.delegate CenterTimeViewLeftBtnClick:self.isCenter TimeStr:self.btn_time.titleLabel.text];
    }
}
- (IBAction)btn_frontClick:(id)sender {
    [self.btn_center setImage:[UIImage imageNamed:@"buttonCenter_n"] forState:UIControlStateNormal];
//    self.btn_center.contentMode = UIViewContentModeScaleToFill;
    [self.btn_front setImage:[UIImage imageNamed:@"buttonFront_h"] forState:UIControlStateNormal];
//    self.btn_front.contentMode = UIViewContentModeScaleToFill;
    self.isCenter = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(CenterTimeViewRightBtnClick:TimeStr:)]) {
        [self.delegate CenterTimeViewRightBtnClick:self.isCenter TimeStr:self.btn_time.titleLabel.text];
    }
}

- (IBAction)switchRulerModeClick:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchRulerMode:)]) {
        [self.delegate switchRulerMode:!btn.selected];
    }
}


@end
