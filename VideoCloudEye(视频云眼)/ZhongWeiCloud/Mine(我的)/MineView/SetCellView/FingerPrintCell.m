//
//  FingerPrintCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/5/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "FingerPrintCell.h"

@implementation FingerPrintCell

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
    [self.contentView addSubview:self.IconImg];
    [self.IconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(15);
    }];
    
    //名称
    self.nameLb = [[UILabel alloc]init];
    self.nameLb.font = FONT(16);
    [self.contentView addSubview:self.nameLb];
    [self.nameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.IconImg.mas_right).offset(10);
    }];
    
    //开关按钮
    self.switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 46.5, 28.5)];
    self.switchBtn.enabled = YES;
    self.switchBtn.userInteractionEnabled = YES;
    self.switchBtn.on = NO;
    [self.contentView addSubview:_switchBtn];
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(iPhoneWidth-60);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
