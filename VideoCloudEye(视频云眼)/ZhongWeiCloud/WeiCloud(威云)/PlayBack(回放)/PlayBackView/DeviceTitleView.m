//
//  DeviceTitleView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/2/1.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "DeviceTitleView.h"

@implementation DeviceTitleView

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
    [self initDeviceTitleNameLayout];//标题名字布局
}

//==========================init==========================
#pragma mark ----- 标题名字的布局
- (void)initDeviceTitleNameLayout{
    [self addSubview:self.deviceTitleName_lb];
    [self.deviceTitleName_lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
    }];
}

//==========================lazy loading==========================
#pragma mark -getter && setter
- (UILabel *)deviceTitleName_lb{
    if (!_deviceTitleName_lb) {
        _deviceTitleName_lb = [[UILabel alloc]init];
        _deviceTitleName_lb.textColor = [UIColor whiteColor];
        _deviceTitleName_lb.font = FONT(22);
    }
    return _deviceTitleName_lb;
}




@end
