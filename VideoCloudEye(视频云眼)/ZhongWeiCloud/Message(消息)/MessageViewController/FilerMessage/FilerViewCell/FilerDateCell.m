//
//  FilerDateCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/21.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "FilerDateCell.h"

@implementation FilerDateCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
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
    //日期
    self.dateLb = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, iPhoneWidth, 15) text:nil font:[UIFont systemFontOfSize:17]];
    [self.contentView addSubview:self.dateLb];
    [self.dateLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
}

@end
