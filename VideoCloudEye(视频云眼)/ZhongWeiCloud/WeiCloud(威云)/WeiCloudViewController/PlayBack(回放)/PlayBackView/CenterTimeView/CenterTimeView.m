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
    self.isCenter = NO;
}
#pragma mark ------按钮点击方法
//日期日历
- (IBAction)btnTimeClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    WeakSelf(self);
    __weak typeof(btn) weakBtn = btn;
    SZCalendarPicker *calendarPicker = [SZCalendarPicker showOnView:self.superview.superview];
    calendarPicker.today = [NSDate date];
    calendarPicker.date = calendarPicker.today;
    calendarPicker.frame = CGRectMake(0, 308, self.superview.frame.size.width, self.superview.superview.bounds.size.height-308);
    calendarPicker.calendarBlock = ^(NSInteger day, NSInteger month, NSInteger year){
        [weakBtn setTitle:[NSString stringWithFormat:@"%li-%li-%li", (long)year,(long)month,(long)day] forState:UIControlStateNormal];
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(CenterTimeViewCenterBtnClick:TimeStr:)]) {
            [weakSelf.delegate CenterTimeViewCenterBtnClick:NO TimeStr:[NSString stringWithFormat:@"%li-%li-%li", (long)year,(long)month,(long)day]];
        }

    };
    
}
- (IBAction)btnCenterClick:(id)sender {
    [self.btn_center setImage:[UIImage imageNamed:@"通道按钮2"] forState:UIControlStateNormal];
    [self.btn_front setImage:[UIImage imageNamed:@"通道按钮4"] forState:UIControlStateNormal];
    self.isCenter = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(CenterTimeViewCenterBtnClick:TimeStr:)]) {
        [self.delegate CenterTimeViewCenterBtnClick:self.isCenter TimeStr:self.btn_time.titleLabel.text];
    }
}
- (IBAction)btnFrontClick:(id)sender {
    [self.btn_center setImage:[UIImage imageNamed:@"通道按钮1"] forState:UIControlStateNormal];
    [self.btn_front setImage:[UIImage imageNamed:@"通道按钮3"] forState:UIControlStateNormal];
    self.isCenter = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(CenterTimeViewCenterBtnClick:TimeStr:)]) {
        [self.delegate CenterTimeViewCenterBtnClick:self.isCenter TimeStr:self.btn_time.titleLabel.text];
    }

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
