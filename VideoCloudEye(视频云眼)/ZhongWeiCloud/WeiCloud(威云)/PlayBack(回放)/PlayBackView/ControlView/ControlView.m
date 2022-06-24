//
//  ControlView.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/16.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "ControlView.h"

@interface ControlView ()
@property (weak, nonatomic) IBOutlet UIButton *btn_top;
@property (weak, nonatomic) IBOutlet UIButton *btn_left;
@property (weak, nonatomic) IBOutlet UIButton *btn_right;
@property (weak, nonatomic) IBOutlet UIButton *btn_down;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnViewTopToDownView;


@end
@implementation ControlView
+(instancetype)viewFromXib
{
    NSString *strClass =  NSStringFromClass([self class]);
    NSArray *arr = [[NSBundle mainBundle]loadNibNamed:strClass owner:self options:nil];
    return [arr lastObject];
}
#pragma mark ------控制按钮
- (IBAction)btnTopClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ControlViewBtnTopClick)]) {
        [self.delegate ControlViewBtnTopClick];
    }
}
- (IBAction)btnTopInside:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ControlViewBtnTopClick)]) {
        [self.delegate ControlViewBtnTopInside];
    }

}

- (IBAction)btnLeftClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ControlViewBtnLeftClick)]) {
        [self.delegate ControlViewBtnLeftClick];
    }
}
- (IBAction)btnLeftInside:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ControlViewBtnLeftClick)]) {
        [self.delegate ControlViewBtnLeftInside];
    }
}
- (IBAction)btnRightClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ControlViewBtnRightClick)]) {
        [self.delegate ControlViewBtnRightClick];
    }
}
- (IBAction)btnRightInside:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ControlViewBtnRightClick)]) {
        [self.delegate ControlViewBtnRightInside];
    }
}
- (IBAction)btnDownClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ControlViewBtnDownClick)]) {
        [self.delegate ControlViewBtnDownClick];
    }
}
- (IBAction)btnDownInside:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ControlViewBtnDownClick)]) {
        [self.delegate ControlViewBtnDownInside];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    if (iPhoneWidth == 320) {
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
