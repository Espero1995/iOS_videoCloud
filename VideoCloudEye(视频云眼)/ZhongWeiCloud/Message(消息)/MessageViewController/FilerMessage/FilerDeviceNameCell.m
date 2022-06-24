//
//  FilerDeviceNameCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/21.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "FilerDeviceNameCell.h"

@implementation FilerDeviceNameCell

//========================init========================
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

#pragma mark - 生成UI
- (void)createUI
{
    //选择按钮
    _chooseBtn = [[UIButton alloc]initWithFrame:CGRectZero];
    [_chooseBtn setBackgroundImage:[UIImage imageNamed:@"select_n"] forState:UIControlStateNormal];
    [_chooseBtn setBackgroundImage:[UIImage imageNamed:@"select_h"] forState:UIControlStateSelected];
    [self.contentView addSubview:_chooseBtn];
    [self.chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(15);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    //设备名
    _deviceNameLb = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:17]];
    [self.contentView addSubview:_deviceNameLb];
    [self.deviceNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.chooseBtn.mas_right).offset(10);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
//        make.size.mas_equalTo(CGSizeMake(, 55));
    }];

}

//========================method========================


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}



@end
