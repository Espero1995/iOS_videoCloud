//
//  EmptyDataBGView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/13.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "EmptyDataBGView.h"

@implementation EmptyDataBGView

//==========================system==========================
- (instancetype)initWithFrame : (CGRect) frame bgColor : (UIColor *) bgColor bgImg : (UIImage *) bgImg bgTip : (NSString *)tipStr{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = bgColor;
        UIImageView * backImage = [[UIImageView alloc]init];
        backImage.image = bgImg;
        [self addSubview:backImage];
        [backImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY).offset(-15);
        }];
        
        UILabel * tipLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 15)];
        tipLb.text = tipStr;
        tipLb.textColor = [UIColor lightGrayColor];
        [self addSubview:tipLb];
        [tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(backImage.mas_bottom).offset(10);
            make.centerX.mas_equalTo(backImage);
        }];
    }
    
    return self;
}
@end
