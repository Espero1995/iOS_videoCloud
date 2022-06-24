//
//  GroupDevCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/27.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "GroupDevCell.h"

@implementation GroupDevCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

#pragma mark - 生成UI
- (void)createUI
{
    [self.contentView addSubview:self.titleLb];
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY).offset(0);
        make.left.equalTo(self.contentView.mas_left).offset(15);
    }];
    [self.contentView addSubview:self.setBtn];
    [self.setBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(0);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - method
//对设备组别进行设置
- (void)settingClick
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(GroupSettingClick:)]) {
        [self.delegate GroupSettingClick:self];
    }
}

#pragma mark - getter && setter
- (UILabel *)titleLb
{
    if (!_titleLb) {
        _titleLb = [[UILabel alloc]init];;
        _titleLb.font = FONT(16);
    }
    return _titleLb;
}
-(UIButton *)setBtn
{
    if (!_setBtn) {
        _setBtn = [[UIButton alloc]init];
        [_setBtn setImage:[UIImage imageNamed:@"moreChoose"] forState:UIControlStateNormal];
        [_setBtn addTarget:self action:@selector(settingClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _setBtn;
}

@end
