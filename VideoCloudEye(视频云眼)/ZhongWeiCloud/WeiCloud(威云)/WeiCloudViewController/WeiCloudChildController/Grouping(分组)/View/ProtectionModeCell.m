//
//  ProtectionModeCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "ProtectionModeCell.h"

@implementation ProtectionModeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    
    [self.contentView addSubview:self.devImg];
    [self.devImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.size.mas_equalTo(CGSizeMake(13.0/8*70, 70));
    }];
    [self.contentView addSubview:self.devNameLb];
    [self.devNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.devImg.mas_right).offset(5);
        make.right.equalTo(self.contentView.mas_right).offset(70);
    }];
    [self.contentView addSubview:self.switchBtn];
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(46.5, 28.5));
    }];
    [self.contentView addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(0);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 0.5));
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - getter && setter
- (UILabel *)devNameLb
{
    if (!_devNameLb) {
        _devNameLb = [[UILabel alloc]init];
        _devNameLb.font = FONT(16);
    }
    return _devNameLb;
}
- (UIImageView *)devImg
{
    if (!_devImg) {
        _devImg = [[UIImageView alloc]init];
    }
    return _devImg;
}
- (UISwitch *)switchBtn
{
    if (!_switchBtn) {
        _switchBtn = [[UISwitch alloc]init];
        _switchBtn.enabled = YES;
        _switchBtn.userInteractionEnabled = YES;
        _switchBtn.on = NO;
    }
    return _switchBtn;
}
- (UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc]init];
        _line.backgroundColor = RGB(220, 220, 220);
    }
    return _line;
}

@end
