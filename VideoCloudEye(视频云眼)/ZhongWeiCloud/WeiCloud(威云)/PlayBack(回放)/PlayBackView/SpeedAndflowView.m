//
//  SpeedAndflowView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/24.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "SpeedAndflowView.h"

@implementation SpeedAndflowView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self initSpeedAndflowLayout];//流量与网速的布局
}

//==========================init==========================
#pragma mark ----- 流量与网速的布局
- (void)initSpeedAndflowLayout{
    [self addSubview:self.showSpeedAndflowLabelBgview];
    [self.showSpeedAndflowLabelBgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(0);
        make.right.equalTo(self.mas_right).offset(0);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    [self.showSpeedAndflowLabelBgview addSubview:self.speedLabel];
    [self.speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.showSpeedAndflowLabelBgview.mas_top).offset(11);
        make.centerX.equalTo(self.showSpeedAndflowLabelBgview.mas_centerX);
    }];
    
    [self.showSpeedAndflowLabelBgview addSubview:self.flowLabel];
    [self.flowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.showSpeedAndflowLabelBgview.mas_bottom).offset(-11);
        make.centerX.equalTo(self.showSpeedAndflowLabelBgview.mas_centerX);
    }];
}
//==========================lazy loading==========================
#pragma mark -getter && setter
//流量显示
-(UIImageView *)showSpeedAndflowLabelBgview{
    if (!_showSpeedAndflowLabelBgview) {
        _showSpeedAndflowLabelBgview = [[UIImageView alloc]init];
        _showSpeedAndflowLabelBgview.image = [UIImage imageNamed:@"SpeedAndflowBg"];
    }
    return _showSpeedAndflowLabelBgview;
}
//网速
-(UILabel *)speedLabel{
    if (!_speedLabel) {
        _speedLabel = [[UILabel alloc]init];
        _speedLabel.textColor = [UIColor whiteColor];
        _speedLabel.font = FONT(11.5);
    }
    return _speedLabel;
}
//流量
-(UILabel *)flowLabel{
    if (!_flowLabel) {
        _flowLabel = [[UILabel alloc]init];
        _flowLabel.textColor = [UIColor whiteColor];
        _flowLabel.font = FONT(11.5);
    }
    return _flowLabel;
}
@end
