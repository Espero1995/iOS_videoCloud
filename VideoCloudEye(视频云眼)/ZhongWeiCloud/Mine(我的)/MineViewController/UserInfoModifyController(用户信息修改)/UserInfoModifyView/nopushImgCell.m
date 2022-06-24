//
//  nopushImgCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/4.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "nopushImgCell.h"

@implementation nopushImgCell

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
    
    
    //显示信息
    self.tipLb = [[UILabel alloc]init];
    self.tipLb.font = FONT(13);
    self.tipLb.textColor = RGB(180, 180, 180);
    self.tipLb.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.tipLb];
    [self.tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.left.equalTo(self.nameLb.mas_right).offset(5);
    }];
}


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
