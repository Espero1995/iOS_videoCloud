//
//  GroupDeleteCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "GroupDeleteCell.h"

@implementation GroupDeleteCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    [self.contentView addSubview:self.deleteLb];
    [self.deleteLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (UILabel *)deleteLb
{
    if (!_deleteLb) {
        _deleteLb = [[UILabel alloc]init];
        _deleteLb.font = FONT(17);
        _deleteLb.textColor = [UIColor redColor];
    }
    return _deleteLb;
}

@end
