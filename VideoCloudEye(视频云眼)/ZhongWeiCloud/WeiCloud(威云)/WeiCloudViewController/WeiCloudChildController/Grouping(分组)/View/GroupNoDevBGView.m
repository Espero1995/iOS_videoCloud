//
//  GroupNoDevBGView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "GroupNoDevBGView.h"

@implementation GroupNoDevBGView

//==========================system==========================
- (instancetype)initWithFrame : (CGRect) frame bgColor : (UIColor *) bgColor bgImg:(UIImage *) bgImg bgTip:(NSString *)tipStr{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = bgColor;
        UIImageView * backImage = [[UIImageView alloc]init];
        backImage.image = bgImg;
        [self addSubview:backImage];
        [backImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY).offset(-0.1*iPhoneHeight);
        }];
        
        UILabel * tipLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 15)];
        tipLb.text = tipStr;
        tipLb.textColor = RGB(100, 100, 100);
        tipLb.font = FONT(16);
        [self addSubview:tipLb];
        [tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(backImage.mas_bottom).offset(20);
            make.centerX.mas_equalTo(backImage);
        }];
        
        UIButton *shopBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        [shopBtn setTitle:NSLocalizedString(@"去商城看看", nil) forState:UIControlStateNormal];
        [shopBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        shopBtn.titleLabel.font = FONT(16);
        shopBtn.backgroundColor = [UIColor whiteColor];
        shopBtn.layer.cornerRadius = 22.5f;
        shopBtn.layer.borderColor = MAIN_COLOR.CGColor;
        shopBtn.layer.borderWidth = 0.5f;
        [shopBtn addTarget:self action:@selector(shopClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:shopBtn];
        [shopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(backImage);
            make.top.equalTo(tipLb.mas_bottom).offset(35);
            make.size.mas_equalTo(CGSizeMake(150, 45));
        }];
        if (isOverSeas) {
            shopBtn.hidden = YES;
        }else{
            shopBtn.hidden = NO;
        }
    }
    
    return self;
}

- (void)shopClick
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(shopBtnClick)]) {
        [self.delegate shopBtnClick];
    }
}

@end
