//
//  GroupnoDevCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/29.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "GroupnoDevCell.h"

@implementation GroupnoDevCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (self.isMydevGroup) {
        [self.contentView addSubview:self.tipLb];
        [self.tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
             make.centerY.equalTo(self.contentView.mas_centerY).offset(-10);
        }];
    }else{
        [self.contentView addSubview:self.addorDeleteBtn];
        [self.addorDeleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY).offset(-20);
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.size.mas_offset(CGSizeMake(230/2, 130/2));
        }];
        [self.contentView addSubview:self.tipLb];
        [self.tipLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.top.equalTo(self.addorDeleteBtn.mas_bottom).offset(10);
        }];
    }
    
}

#pragma  mark - method
- (void)addDevClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(noDevAddClick)]) {
        [self.delegate noDevAddClick];
    }
}


#pragma mark - getter && setter
- (UIButton *)addorDeleteBtn
{
    if (!_addorDeleteBtn) {
        _addorDeleteBtn = [[UIButton alloc]init];
        [_addorDeleteBtn setBackgroundImage:[UIImage imageNamed:@"groupAdd"] forState:UIControlStateNormal];
        [_addorDeleteBtn addTarget:self action:@selector(addDevClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addorDeleteBtn;
}
- (UILabel *)tipLb
{
    if (!_tipLb) {
        _tipLb = [[UILabel alloc]init];
        _tipLb.font = FONT(14);
        _tipLb.textColor = RGB(100, 100, 100);
        _tipLb.textAlignment = NSTextAlignmentCenter;
        _tipLb.numberOfLines = 0;
    }
    return _tipLb;
}

@end
