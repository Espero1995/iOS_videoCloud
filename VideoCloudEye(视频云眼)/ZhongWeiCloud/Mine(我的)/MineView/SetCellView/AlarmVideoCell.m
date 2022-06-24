//
//  AlarmVideoCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2020/2/24.
//  Copyright © 2020 苏旋律. All rights reserved.
//

#import "AlarmVideoCell.h"

@implementation AlarmVideoCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

#pragma mark - 生成UI
- (void)createUI{
    //图标
    self.iconImg = [[UIImageView alloc]init];
    self.iconImg.image = [UIImage imageNamed:@"alarmVideoIcon"];
    [self.contentView addSubview:self.iconImg];
    [self.iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(15);
    }];
    //名称
    self.titleLb = [[UILabel alloc]init];
    self.titleLb.text = NSLocalizedString(@"告警查询方式", nil);
    self.titleLb.font = FONT(16);
    [self.contentView addSubview:self.titleLb];
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.iconImg.mas_right).offset(10);
    }];
    //副标题
    self.subTitleLb = [[UILabel alloc]init];
    self.subTitleLb.font = FONT(14);
    self.subTitleLb.textColor = RGB(180, 180, 180);
    [self.contentView addSubview:self.subTitleLb];
    [self.subTitleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
    }];
    
}



- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
