//
//  AddRemindPlanCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/30.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "AddRemindPlanCell.h"

@implementation AddRemindPlanCell

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
    [self.contentView addSubview:self.addImg];
    [self.addImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        if (isSimplifiedChinese) {
            make.centerX.equalTo(self.contentView.mas_centerX).offset(-55);
        }else{
            make.centerX.equalTo(self.contentView.mas_centerX).offset(-75);
        }
        
    }];
    [self.contentView addSubview:self.titleLb];
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.addImg.mas_right).offset(10);
    }];
}

#pragma mark - getter && setter
- (UIImageView *)addImg
{
    if (!_addImg) {
        _addImg = [[UIImageView alloc]init];
    }
    return _addImg;
}

- (UILabel *)titleLb
{
    if (!_titleLb) {
        _titleLb = [[UILabel alloc]init];
        _titleLb.font = FONT(16);
    }
    return _titleLb;
}

@end
