//
//  SetScopeTimeCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/5/21.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "SetScopeTimeCell.h"

@implementation SetScopeTimeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

#pragma mark - 生成UI
- (void)createUI{
    //时间范围
    self.scopeTimeLb = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:17]];
    [self.contentView addSubview:self.scopeTimeLb];
    [self.scopeTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    //范围
    self.scopeTipLb = [[UILabel alloc]init];
    self.scopeTipLb.textColor = RGB(150, 150, 150);
    self.scopeTipLb.font = FONT(16);
    [self.contentView addSubview:self.scopeTipLb];
    [self.scopeTipLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.scopeTimeLb.mas_centerY);
        make.left.equalTo(self.scopeTimeLb.mas_right).offset(5);
    }];
    //选择按钮图片
    self.isChoosedImg = [[UIImageView alloc]init];
    self.isChoosedImg.image = [UIImage imageNamed:@"choose"];
    self.isChoosedImg.hidden = YES;
    [self.contentView addSubview:self.isChoosedImg];
    [self.isChoosedImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-15);
    }];
    
    
//    //选择按钮
//    self.chooseBtn = [FactoryUI createButtonWithFrame:CGRectMake(0, 0, 12, 9.5) title:nil titleColor:nil imageName:nil backgroundImageName:nil target:self selector:nil];
//     self.chooseBtn.enabled = YES;
//     self.chooseBtn.userInteractionEnabled = YES;
//    [ self.chooseBtn setBackgroundImage:[UIImage imageNamed:@"choose"] forState:UIControlStateSelected];
//    
//    [self.contentView addSubview: self.chooseBtn];
//    [self.chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView.mas_left).offset(iPhoneWidth-32);
//        make.right.equalTo(self.contentView.mas_left).offset(iPhoneWidth-20);
//        make.centerY.equalTo(self.contentView.mas_centerY);
//        make.size.mas_equalTo(CGSizeMake(12, 9.5));
//    }];
    
    
}

- (void)buttonSelected{
    if (self.chooseBtn.selected == NO) {
        self.chooseBtn.selected = YES;
    }else
        self.chooseBtn.selected = NO;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
