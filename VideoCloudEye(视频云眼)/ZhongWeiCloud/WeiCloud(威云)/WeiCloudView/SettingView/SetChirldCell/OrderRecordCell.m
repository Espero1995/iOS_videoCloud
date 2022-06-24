//
//  OrderRecordCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2017/12/5.
//  Copyright © 2017年 张策. All rights reserved.
//
#import "OrderRecordCell.h"

@implementation OrderRecordCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
//套餐类型
- (UILabel *)typeLb{
    if (!_typeLb) {
        _typeLb = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:16.0f]];
    }
         _typeLb.textAlignment=NSTextAlignmentCenter;
        [self addSubview:_typeLb];
        [_typeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(0);
            make.centerY.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(iPhoneWidth/3, 14));
        }];
    return _typeLb;
}
//生效时间
- (UILabel *)effectTimeLb{
    if (!_effectTimeLb) {
        _effectTimeLb = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:16.0f]];
        _effectTimeLb.textAlignment=NSTextAlignmentCenter;
        [self addSubview:_effectTimeLb];
        [_effectTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self);
            make.centerX.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(iPhoneWidth/3, 14));
        }];
    }
    return _effectTimeLb;
}
//生效时间
- (UILabel *)expireTimeLb{
    if (!_expireTimeLb) {
        _expireTimeLb = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:16.0f]];
        _expireTimeLb.textAlignment=NSTextAlignmentCenter;
        [self addSubview:_expireTimeLb];
        [_expireTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.mas_right).offset(0);
            make.centerY.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(iPhoneWidth/3, 14));
        }];
    }
    return _expireTimeLb;
}


@end
