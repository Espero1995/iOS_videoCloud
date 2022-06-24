//
//  CustomRemindPlanCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/30.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "CustomRemindPlanCell.h"

@implementation CustomRemindPlanCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}
- (void)createUI
{
    [self.contentView addSubview:self.titleLb];
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.top.equalTo(self.contentView.mas_top).offset(7);
    }];
    [self.contentView addSubview:self.subTitleLb];
    [self.subTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-7);
    }];
}

#pragma mark - getter && setter
- (UILabel *)titleLb
{
    if (!_titleLb) {
        _titleLb = [[UILabel alloc]init];
        _titleLb.font = FONT(17);
    }
    return _titleLb;
}

- (UILabel *)subTitleLb
{
    if (!_subTitleLb) {
        _subTitleLb = [[UILabel alloc]init];
        _subTitleLb.font = FONT(13);
        _subTitleLb.textColor = RGB(180, 180, 180);
    }
    return _subTitleLb;
}
@end
