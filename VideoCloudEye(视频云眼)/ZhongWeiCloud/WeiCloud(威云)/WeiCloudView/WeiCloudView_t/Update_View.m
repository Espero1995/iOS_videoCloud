//
//  PubUpdateView.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/17.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "Update_View.h"
#import "UIView+ScottAlertView.h"
#import "ZCTabBarController.h"

@implementation Update_View
+(instancetype)viewFromXib
{
    NSString *strClass =  NSStringFromClass([self class]);
    NSArray *arr = [[NSBundle mainBundle]loadNibNamed:strClass owner:self options:nil];
    
    return [arr lastObject];
}
- (void)awakeFromNib {
    [super awakeFromNib];
}
- (IBAction)Update_ViewBtnLeftClick:(id)sender {
    [self dismiss];

    if (self.delegete && [self.delegete respondsToSelector:@selector(Update_View_LeftBtnClick:)]) {
        [self.delegete Update_View_LeftBtnClick:self];
    }

}
- (IBAction)Update_ViewBtnRightClick:(id)sender {
    [self dismiss];


    if (self.delegete && [self.delegete respondsToSelector:@selector(Update_View_RightBtnClick:)]) {
        [self.delegete Update_View_RightBtnClick:self];
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
