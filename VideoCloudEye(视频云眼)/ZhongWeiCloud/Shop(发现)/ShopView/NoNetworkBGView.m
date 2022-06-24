//
//  NoNetworkBGView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/31.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "NoNetworkBGView.h"

@implementation NoNetworkBGView

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
        
        UIButton *refreshBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        [refreshBtn setTitle:NSLocalizedString(@"重新加载", nil) forState:UIControlStateNormal];
        [refreshBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        refreshBtn.titleLabel.font = FONT(15);
        refreshBtn.backgroundColor = MAIN_COLOR;
        refreshBtn.layer.cornerRadius = 20.f;
        [refreshBtn addTarget:self action:@selector(refreshClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:refreshBtn];
        [refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(backImage);
            make.top.equalTo(tipLb.mas_bottom).offset(35);
            make.size.mas_equalTo(CGSizeMake(150, 40));
        }];
    }
    return self;
}

- (void)refreshClick
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(refreshBtnClick)]) {
        [self.delegate refreshBtnClick];
    }
}

@end
