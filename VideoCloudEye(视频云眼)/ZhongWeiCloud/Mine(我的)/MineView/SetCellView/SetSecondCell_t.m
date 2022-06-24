//
//  SetSecondCell_t.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/20.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "SetSecondCell_t.h"

@implementation SetSecondCell_t
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}


#pragma mark - 生成UI

- (void)createUI{
    //类型
    _typeLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 300, 14) text:nil font:[UIFont systemFontOfSize:14]];
    _typeLabel.textColor = [UIColor colorWithHexString:@"000000"];
    _typeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _typeLabel.numberOfLines = 0;
    [self.contentView addSubview:_typeLabel];
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(20);
        make.top.equalTo (self.contentView.mas_top).offset(10);
    }];
    //
    //箭头
    _pushImage = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 6.5, 11.5) imageName:@"more1"];

    [self.contentView addSubview:_pushImage];
    [self.pushImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(14);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-14.5);
        make.left.equalTo(self.contentView.mas_left).offset(iPhoneWidth-19.5);
        make.height.equalTo(@11.5);
        make.width.equalTo(@6.5);
    }];

    //名称
    _titleLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 64, 14) text:nil font:[UIFont systemFontOfSize:14]];
    _titleLabel.textColor = [UIColor colorWithHexString:@"101010"];
    _titleLabel.numberOfLines = 0;
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self.contentView addSubview:_titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pushImage.mas_left).offset(-10);
        make.top.equalTo(self.contentView.mas_top).offset(13);
    }];

}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
