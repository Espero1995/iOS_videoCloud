//
//  DeviceNameCell_t.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/3/1.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "DeviceNameCell_t.h"

@implementation DeviceNameCell_t
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}


#pragma mark - 生成UI

- (void)createUI{
    //设备名输入框
    _nameText = [[UITextField alloc]initWithFrame:CGRectMake(0, 13, iPhoneWidth-50, 20)];
    _nameText.borderStyle = UITextBorderStyleNone;
    _nameText.keyboardType = UIKeyboardTypeEmailAddress ;
    [self.contentView addSubview:_nameText];
    [self.nameText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(20);
        make.right.equalTo(self.contentView.mas_right).offset(-50);
        make.top.equalTo(self.contentView.mas_top).offset(0);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(0);
    }];
    //按钮
    _deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    _deleteBtn.userInteractionEnabled = YES;
    _deleteBtn.enabled = YES;
    [_deleteBtn addTarget:self action:@selector(cleanName:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_deleteBtn];
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
}
- (void)cleanName:(DeviceNameCell_t *)cell{

    if (self.delegete && [self.delegete respondsToSelector:@selector(DeviceNameCell_tChooseBtnClick:)]) {
        [self.delegete DeviceNameCell_tChooseBtnClick:self];
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
