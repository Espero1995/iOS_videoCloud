//
//  InputWifiView.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/25.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "InputWifiView.h"
#import "UIView+ScottAlertView.h"

@interface InputWifiView ()

@end

@implementation InputWifiView
+(instancetype)viewFromXib
{
    NSString *strClass =  NSStringFromClass([self class]);
    NSArray *arr = [[NSBundle mainBundle]loadNibNamed:strClass owner:self options:nil];
    return [arr lastObject];
}
- (void)awakeFromNib {
    [super awakeFromNib];
}
- (IBAction)btnCancelClick:(id)sender {
    [self dismiss];
}
- (IBAction)btnJoinClick:(id)sender {
    [self dismiss];
    if (self.delegate && [self.delegate respondsToSelector:@selector(InputWifiViewBtnJoinClick:)]) {
        [self.delegate InputWifiViewBtnJoinClick:self];
    }
}


@end
