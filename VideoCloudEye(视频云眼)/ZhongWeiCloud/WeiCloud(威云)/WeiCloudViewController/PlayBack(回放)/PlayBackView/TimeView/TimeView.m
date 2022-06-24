//
//  TimeView.m
//  ZhongWeiEyes
//
//  Created by 张策 on 16/12/23.
//  Copyright © 2016年 张策. All rights reserved.
//

#import "TimeView.h"

@implementation TimeView
+(instancetype)viewFromXib
{
    NSString *strClass =  NSStringFromClass([self class]);
    NSArray *arr = [[NSBundle mainBundle]loadNibNamed:strClass owner:self options:nil];
    return [arr lastObject];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 4;
    self.userInteractionEnabled = YES;
    self.lab_time.userInteractionEnabled = YES;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
