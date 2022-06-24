//
//  autoUpdateCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/20.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "autoUpdateCell.h"

@implementation autoUpdateCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

#pragma mark - 生成UI
- (void)createUI
{
    self.nameLb = [[UILabel alloc]init];
    self.nameLb.font = FONT(16);
    [self.contentView addSubview:self.nameLb];
    [self.nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    self.tipLb = [[UILabel alloc]init];
    self.tipLb.font = FONT(14);
    self.tipLb.text = NSLocalizedString(@"(0:00~6:00自动升级)", nil);
    self.tipLb.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.tipLb];
    [self.tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLb.mas_right).offset(0);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    //开关按钮
    self.switchBtn = [[UISwitch alloc]init];
    [self.contentView addSubview:self.switchBtn];
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
}



- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
