//
//  MineHeadView.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/8.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "MineHeadView.h"

@implementation MineHeadView
+(instancetype)viewFromXib
{
    NSString *strClass =  NSStringFromClass([self class]);
    NSArray *arr = [[NSBundle mainBundle]loadNibNamed:strClass owner:self options:nil];
    return [arr lastObject];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *tag = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tagClickFunc)];
    self.lab_name.userInteractionEnabled = YES;
    [self.lab_name addGestureRecognizer:tag];
    
    MySingleton *singleton = [MySingleton shareInstance];
    self.lab_name.text = singleton.userNameStr;
}

- (void)tagClickFunc
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mineHeadViewLabnameClick)]) {
        [self.delegate mineHeadViewLabnameClick];
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
