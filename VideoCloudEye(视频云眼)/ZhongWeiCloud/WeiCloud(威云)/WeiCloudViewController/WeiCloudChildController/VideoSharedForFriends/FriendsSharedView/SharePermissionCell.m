//
//  SharePermissionCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "SharePermissionCell.h"
@interface SharePermissionCell()
// 分隔线
@property (nonatomic, strong) UIView *separatorLine;
@end
@implementation SharePermissionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}


#pragma mark - 生成UI
- (void)createUI{
    //名称
    self.titleLb = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:16]];
    [self.contentView addSubview:self.titleLb];
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    //选择按钮
    self.chooseBtn = [[UIButton alloc]initWithFrame:CGRectZero];
    [self.contentView addSubview:self.chooseBtn];
    [self.chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    self.separatorLine = [[UIView alloc]init];
    self.separatorLine.backgroundColor = RGB(200, 200, 200);
    [self.contentView addSubview:self.separatorLine];
    [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(0);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth-15, 0.5));
    }];
    
}
- (void)buttonSelected{
    if (_chooseBtn.selected == NO) {
        _chooseBtn.selected = YES;
    }else
        _chooseBtn.selected = NO;
}



- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.separatorLine.backgroundColor = RGB(200, 200, 200);
}

@end
