//
//  GroupCommonCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "GroupCommonCell.h"

@implementation GroupCommonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    [self.contentView addSubview:self.titleLb];
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(15);
    }];
    [self.contentView addSubview:self.arrowIcon];
    [self.arrowIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.height.equalTo(@11.5);
        make.width.equalTo(@6.5);
    }];
    [self.contentView addSubview:self.subtitleLb];
    [self.subtitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.arrowIcon.mas_left).offset(-5);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    [self.contentView addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.right.equalTo(self.contentView.mas_right).offset(0);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(0);
        make.height.mas_equalTo(@0.5);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
#pragma mark - getter && setter
- (UILabel *)titleLb
{
    if (!_titleLb) {
        _titleLb = [[UILabel alloc]init];
        _titleLb.font = FONT(17);
        _titleLb.textColor = RGB(50, 50, 50);
    }
    return _titleLb;
}
- (UILabel *)subtitleLb
{
    if (!_subtitleLb) {
        _subtitleLb = [[UILabel alloc]init];
        _subtitleLb.font = FONT(15);
        _subtitleLb.textColor = RGB(150, 150, 150);
    }
    return _subtitleLb;
}
- (UIImageView *)arrowIcon
{
    if (!_arrowIcon) {
        _arrowIcon = [[UIImageView alloc]init];
        _arrowIcon.image = [UIImage imageNamed:@"more1"];
    }
    return _arrowIcon;
}
- (UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc]init];
        _line.backgroundColor = RGB(240, 240, 240);
    }
    return _line;
}

@end
