//
//  WifiConfigCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/5/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "WifiConfigCell.h"

@implementation WifiConfigCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

#pragma mark - 生成UI
- (void)createUI{
    //图标
    self.IconImg = [[UIImageView alloc]init];
    self.IconImg.image = [UIImage imageNamed:@"WifiConfig"];
    [self.contentView addSubview:self.IconImg];
    [self.IconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(15);
    }];
    //名称
    self.nameLb = [[UILabel alloc]init];
    self.nameLb.text = NSLocalizedString(@"Wi-Fi二维码生成", nil);
    self.nameLb.font = FONT(16);
    [self.contentView addSubview:self.nameLb];
    [self.nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.IconImg.mas_right).offset(10);
    }];
    
    
    //箭头
    self.pushImg = [[UIImageView alloc]init];
    self.pushImg.image = [UIImage imageNamed:@"more1"];
    [self.contentView addSubview:self.pushImg];
    [self.pushImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(iPhoneWidth-19.5);
    }];
}



- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
