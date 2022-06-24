//
//  CenterBtn.m
//  B2B_iOS
//
//  Created by 张策 on 16/9/12.
//  Copyright © 2016年 KQC. All rights reserved.
//

#import "CenterBtn.h"
#define ZCImageRidio 0.7
#import "UIView+frame.h"

@implementation CenterBtn
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // 设置字体颜色
        [self setTitleColor:[UIColor colorWithRed:135/255.0 green:135/255.0 blue:135/255.0 alpha:1] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:253/255.0 green:125/255.0 blue:47/255.0 alpha:1] forState:UIControlStateSelected];
        
        // 图片居中
        self.imageView.contentMode = UIViewContentModeCenter;
        // 文字居中
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        // 设置文字字体
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 1.imageView
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageW = self.bounds.size.width;
    CGFloat imageH = self.bounds.size.height * ZCImageRidio;
    self.imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
    
    
    // 2.title
    CGFloat titleX = 0;
    CGFloat titleY = imageH - 3;
    CGFloat titleW = self.bounds.size.width;
    CGFloat titleH = self.bounds.size.height - titleY;
    self.titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    
    // 3.badgeView
//    self.badgeView.x = self.width - self.badgeView.width - 18;
//    self.badgeView.y = 0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
