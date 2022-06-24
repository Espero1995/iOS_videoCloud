//
//  DeviceSetBtnView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/26.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "DeviceSetBtnView.h"

@interface DeviceSetBtnView ()

@end

@implementation DeviceSetBtnView


- (void)drawRect:(CGRect)rect
{
    [self addSubview:self.btnImgView];
    [self.btnImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY).offset(-10);
    }];
    [self addSubview:self.btnTitleLb];
    [self.btnTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.btnImgView.mas_bottom).offset(10);
    }];
    [self addSubview:self.IconView];
    [self.IconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(0);
        make.right.equalTo(self.mas_right).offset(0);
    }];
}



//图片
- (UIImageView *)btnImgView
{
    if (!_btnImgView) {
        _btnImgView = [[UIImageView alloc]init];
    }
    return _btnImgView;
}
//文字
- (UILabel *)btnTitleLb
{
    if (!_btnTitleLb) {
        _btnTitleLb = [[UILabel alloc]init];
        _btnTitleLb.font = FONT(15);
        _btnTitleLb.textColor = RGB(50, 50, 50);
    }
    return _btnTitleLb;
}
//小图标
-(UIImageView *)IconView
{
    if (!_IconView) {
        _IconView = [[UIImageView alloc]init];
    }
    return _IconView;
}
@end
