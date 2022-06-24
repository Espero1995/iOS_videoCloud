//
//  TimePhotoNoAlbumView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/10/18.
//  Copyright © 2018 张策. All rights reserved.
//

#import "TimePhotoNoAlbumView.h"

@implementation TimePhotoNoAlbumView

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
        tipLb.numberOfLines = 0;
        tipLb.textAlignment = NSTextAlignmentCenter;
        tipLb.lineBreakMode = NSLineBreakByCharWrapping;
        [self addSubview:tipLb];
        [tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(backImage.mas_bottom).offset(20);
            make.centerX.mas_equalTo(backImage);
            make.width.mas_equalTo(0.8*iPhoneWidth);
        }];
        
        self.cloudBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        [self.cloudBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        self.cloudBtn.titleLabel.font = FONT(16);
        self.cloudBtn.backgroundColor = [UIColor whiteColor];
        self.cloudBtn.layer.cornerRadius = 22.5f;
        self.cloudBtn.layer.borderColor = MAIN_COLOR.CGColor;
        self.cloudBtn.layer.borderWidth = 0.5f;
        [self.cloudBtn addTarget:self action:@selector(shopClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cloudBtn];
        [self.cloudBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(backImage);
            make.top.equalTo(tipLb.mas_bottom).offset(35);
            make.size.mas_equalTo(CGSizeMake(150, 45));
        }];
        
    }
    
    return self;
}

- (void)shopClick
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(cloudStorageBtnClick)]) {
        [self.delegate cloudStorageBtnClick];
    }
}

@end
