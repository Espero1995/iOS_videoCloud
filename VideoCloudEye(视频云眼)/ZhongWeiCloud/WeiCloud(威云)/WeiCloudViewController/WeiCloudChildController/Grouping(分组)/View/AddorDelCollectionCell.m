//
//  AddorDelCollectionCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/29.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "AddorDelCollectionCell.h"

@interface AddorDelCollectionCell ()
@end

@implementation AddorDelCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.addorDeleteBtn];
        [self.addorDeleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(0);
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.size.mas_offset(CGSizeMake(self.frame.size.width, self.frame.size.height-20));
        }];
        [self.contentView addSubview:self.devNameLb];
        [self.devNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.top.equalTo(self.addorDeleteBtn.mas_bottom).offset(5);
            make.width.mas_equalTo(self.frame.size.width);
        }];
    }
    return self;
}

#pragma mark - getter && setter
- (UIButton *)addorDeleteBtn
{
    if (!_addorDeleteBtn) {
        _addorDeleteBtn = [[UIButton alloc]init];
        _addorDeleteBtn.userInteractionEnabled = NO;
    }
    return _addorDeleteBtn;
}
- (UILabel *)devNameLb
{
    if (!_devNameLb) {
        _devNameLb = [[UILabel alloc]init];
        _devNameLb.font = FONT(12);
        _devNameLb.textColor = RGB(100, 100, 100);
        _devNameLb.textAlignment = NSTextAlignmentCenter;
    }
    return _devNameLb;
}

@end
