//
//  SZCalendarCell.m
//  SZCalendarPicker
//
//  Created by Stephen Zhuang on 14/12/1.
//  Copyright (c) 2014年 Stephen Zhuang. All rights reserved.
//

#import "SZCalendarCell.h"

@implementation SZCalendarCell
-(void)awakeFromNib
{
    [super awakeFromNib];
}
- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 13, self.bounds.size.width-26, self.bounds.size.height-26)];//self.bounds
        [_dateLabel setTextAlignment:NSTextAlignmentCenter];
        [_dateLabel setFont:[UIFont systemFontOfSize:15]];
        [self addSubview:_dateLabel];
    }
    return _dateLabel;
}

- (UIView *)circleView
{
    if (!_circleView) {
        _circleView = [[UIView alloc]initWithFrame:CGRectMake(13, 13, self.bounds.size.width-26, self.bounds.size.height-26)];
        _circleView.backgroundColor = [UIColor clearColor];
        _circleView.layer.cornerRadius = (self.bounds.size.width-26)/2;
        _circleView.layer.borderColor = RGB(255, 74, 51).CGColor;
        _circleView.layer.borderWidth = 1.f;
        [self addSubview:_circleView];
    }
    return _circleView;
}

- (UIView *)redDot
{
    if (!_redDot) {
        _redDot = [[UIView alloc]initWithFrame:CGRectMake((_dateLabel.bounds.size.width - 5)/2,_dateLabel.bounds.size.height - 15, 4, 4)];
        _redDot.layer.masksToBounds = YES;
        _redDot.layer.cornerRadius = 2.f;
        [self addSubview:_redDot];
    }
    return _redDot;
}

@end
