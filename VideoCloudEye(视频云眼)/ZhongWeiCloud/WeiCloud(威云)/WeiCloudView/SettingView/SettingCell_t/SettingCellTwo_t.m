//
//  SettingCellTwo_t.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/27.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "SettingCellTwo_t.h"

@implementation SettingCellTwo_t
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}


#pragma mark - 生成UI

- (void)createUI{
    //类型
    _typeLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 300, 15) text:nil font:[UIFont systemFontOfSize:16]];
    _typeLabel.textColor = [UIColor colorWithHexString:@"000000"];
    _typeLabel.numberOfLines = 0;
    [self.contentView addSubview:_typeLabel];
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];

    //开关按钮
    _switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 46.5, 28.5)];
    _switchBtn.enabled = YES;
    _switchBtn.userInteractionEnabled = YES;
    _switchBtn.on = NO;
    [self.contentView addSubview:_switchBtn];
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(iPhoneWidth-60);
    }];
    [self.contentView addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.right.equalTo(self.contentView.mas_right).offset(0);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(0);
        make.height.mas_equalTo(@0.5);
    }];
}
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc]init];
        _line.backgroundColor = RGB(240, 240, 240);
    }
    return _line;
}

@end
