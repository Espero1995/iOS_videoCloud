//
//  MineReviseView.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/8.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "MineReviseView.h"

@implementation MineReviseView
+(instancetype)viewFromXib
{
    NSString *strClass =  NSStringFromClass([self class]);
    NSArray *arr = [[NSBundle mainBundle]loadNibNamed:strClass owner:self options:nil];
    return [arr lastObject];
}
- (void)awakeFromNib {
    [super awakeFromNib];
}
- (IBAction)btnOkChick:(id)sender {
    [self dismiss];
    if (self.delegate &&[self.delegate respondsToSelector:@selector(mineReviseBtnOkClick:)]) {
        [self.delegate mineReviseBtnOkClick:self.fied_name.text];
    }
}
- (IBAction)btnCancelClick:(id)sender {
    [self dismiss];
    if (self.delegate &&[self.delegate respondsToSelector:@selector(mineReviseBtnCancelClick)]) {
        [self.delegate mineReviseBtnCancelClick];
    }

}


@end
