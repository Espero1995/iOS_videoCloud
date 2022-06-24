//
//  AboutUsHeadCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/11/20.
//  Copyright © 2018 张策. All rights reserved.
//

#import "AboutUsHeadCell.h"
#define LOGOWIDTH iPhoneWidth/7
@implementation AboutUsHeadCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.logoIcon];
    [self.logoIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX).offset(0);
        make.centerY.equalTo(self.contentView.mas_centerY).offset(0);
        make.size.mas_equalTo(CGSizeMake(LOGOWIDTH, LOGOWIDTH/150*195));
    }];
    [self.contentView addSubview:self.versionLb];
    [self.versionLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.logoIcon.mas_bottom).offset(0);
    }];
}

#pragma mark - getter&&setter
- (UIImageView *)logoIcon
{
    if (!_logoIcon) {
        _logoIcon = [[UIImageView alloc]init];
    }
    return _logoIcon;
}

- (UILabel *)versionLb
{
    if (!_versionLb) {
        _versionLb = [[UILabel alloc]init];
        _versionLb.font = FONT(13);
        _versionLb.textColor = RGB(150, 150, 150);
        _versionLb.textAlignment = NSTextAlignmentCenter;
    }
    return _versionLb;
}
@end
