//
//  SettingCellRemind_t.m
//  ZhongWeiCloud
//
//  Created by Espero on 2017/11/22.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "SettingCellRemind_t.h"

@implementation SettingCellRemind_t
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}
#pragma mark - 生成UI

- (void)createUI{
    //类型
    _typeLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 50, 14) text:nil font:[UIFont systemFontOfSize:16]];
    _typeLabel.numberOfLines = 0;
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
        make.size.mas_equalTo(CGSizeMake(6.5, 11.5));
    }];
    
    //名称
    _titleLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 64, 15) text:nil font:[UIFont systemFontOfSize:16]];
    _titleLabel.textColor = MAIN_COLOR;
    _titleLabel.numberOfLines = 1;
    _titleLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pushImage.mas_left).offset(-10);
        make.top.equalTo(self.contentView.mas_top).offset(15);
    }];
    
    //时间范围
    _scopeLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 64, 15) text:nil font:[UIFont systemFontOfSize:16]];
    _scopeLabel.textColor = MAIN_COLOR;
    _scopeLabel.numberOfLines = 1;
    _scopeLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_scopeLabel];
    [self.scopeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pushImage.mas_left).offset(-10);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-15);
        make.left.equalTo(self.typeLabel.mas_right).offset(5);
    }];
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
