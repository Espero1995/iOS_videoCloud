//
//  uploadHeadCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/4.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "uploadHeadCell.h"

@implementation uploadHeadCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

#pragma mark - 生成UI
- (void)createUI{
    //名称
    self.nameLb = [[UILabel alloc]init];
    self.nameLb.font = FONT(16);
    self.nameLb.textColor = RGB(10, 10, 10);
    [self.contentView addSubview:self.nameLb];
    [self.nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(15);
    }];
    //头像
    self.headImg = [[UIImageView alloc]init];
    [self.contentView addSubview:self.headImg];
    [self.headImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
