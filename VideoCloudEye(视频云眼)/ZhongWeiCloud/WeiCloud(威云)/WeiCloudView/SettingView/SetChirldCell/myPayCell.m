//
//  myPayCell.m
//  Demo
//
//  Created by Espero on 2017/12/4.
//  Copyright © 2017年 Espero. All rights reserved.
//
#import "myPayCell.h"

@implementation myPayCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

-(UIImageView *)headImg{
    if (!_headImg) {
        _headImg = [[UIImageView alloc]init];
    }
    [self addSubview:_headImg];
    [_headImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    return _headImg;
}

-(UILabel *)payName{
    if (!_payName) {
        _payName = [[UILabel alloc]init];
    }
    [self addSubview:_payName];
    [_payName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(55);
    }];
    return _payName;
}

-(UIImageView *)selectImg{
    if (!_selectImg) {
        _selectImg = [[UIImageView alloc]init];
    }
    [self addSubview:_selectImg];
    [_selectImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(iPhoneWidth-40);
        make.top.mas_equalTo(10);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    return _selectImg;
}
@end
