//
//  PubUpdateView.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/17.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "PubUpdateView.h"
#import "UIView+ScottAlertView.h"
#import "ZCTabBarController.h"

@implementation PubUpdateView
+(instancetype)viewFromXib
{
    NSString *strClass =  NSStringFromClass([self class]);
    NSArray *arr = [[NSBundle mainBundle]loadNibNamed:strClass owner:self options:nil];
    return [arr lastObject];
}
- (void)awakeFromNib {
    [super awakeFromNib];
}
- (IBAction)pubUpdateViewBtnLeftClick:(id)sender {
    [self dismiss];

    if (self.delegete && [self.delegete respondsToSelector:@selector(PubUpdateView_LeftBtnClick:)]) {
        [self.delegete PubUpdateView_LeftBtnClick:self];
    }

}
- (IBAction)pubUpdateViewBtnRightClick:(id)sender {
    [self dismiss];


    if (self.delegete && [self.delegete respondsToSelector:@selector(PubUpdateView_RightBtnClick:)]) {
        [self.delegete PubUpdateView_RightBtnClick:self];
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
