//
//  SettingCellOne_t.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/27.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "SettingCellOne_t.h"

@implementation SettingCellOne_t
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}


#pragma mark - 生成UI
- (void)createUI
{
    //类型
    _typeLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 300, 14) text:nil font:[UIFont systemFontOfSize:16]];
    _typeLabel.textColor = [UIColor colorWithHexString:@"000000"];
    [self.contentView addSubview:_typeLabel];
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];

    //箭头
    _pushImage = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 6.5, 11.5) imageName:@"more1"];
    [self.contentView addSubview:_pushImage];
    [self.pushImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.height.equalTo(@11.5);
        make.width.equalTo(@6.5);
    }];
    
    //名称
    _titleLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 64, 15) text:nil font:[UIFont systemFontOfSize:14]];
    _titleLabel.textColor = RGB(150, 150, 150);
    _titleLabel.textAlignment = NSTextAlignmentRight;
    
    [self.contentView addSubview:_titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pushImage.mas_left).offset(-10);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.typeLabel.mas_right).offset(10);
    }];
    
    //红点
    _redDotImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 3, 3)];
    _redDotImg.image = [UIImage imageNamed:@"msg_red"];
    [self.contentView addSubview:_redDotImg];
    [self.redDotImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(0);
        make.top.equalTo(self.titleLabel.mas_top).offset(0);
        make.size.mas_equalTo(CGSizeMake(5, 5));
    }];
    _redDotImg.hidden = YES;
}


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
