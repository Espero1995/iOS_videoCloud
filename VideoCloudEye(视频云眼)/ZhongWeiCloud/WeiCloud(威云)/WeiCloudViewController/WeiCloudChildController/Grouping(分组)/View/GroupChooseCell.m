//
//  GroupChooseCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/30.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "GroupChooseCell.h"

@implementation GroupChooseCell

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
    [self.contentView addSubview:self.chooseBtn];
    [self.chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    //设备图片
    [self.contentView addSubview:self.deviceImage];
    [self.deviceImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.chooseBtn.mas_right).offset(10);
        make.size.mas_equalTo(CGSizeMake(13.0/8*70, 70));
    }];
    //设备名
    [self.contentView addSubview:self.deviceNameLb];
    [self.deviceNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.deviceImage.mas_right).offset(5);
        make.right.equalTo(self.contentView.mas_right).offset(0);
    }];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

#pragma mark - getter && setter
//选择按钮
- (UIButton *)chooseBtn
{
    if (!_chooseBtn) {
        _chooseBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        [_chooseBtn setBackgroundImage:[UIImage imageNamed:@"select_n"] forState:UIControlStateNormal];
        [_chooseBtn setBackgroundImage:[UIImage imageNamed:@"select_h"] forState:UIControlStateSelected];
    }
    return _chooseBtn;
}
//设备图片
- (UIImageView *)deviceImage
{
    if (!_deviceImage) {
        _deviceImage = [[UIImageView alloc]init];
    }
    return _deviceImage;
}
//设备名称
- (UILabel *)deviceNameLb
{
    if (!_deviceNameLb) {
        _deviceNameLb = [[UILabel alloc]init];
        _deviceNameLb.font = FONT(15);
    }
    return _deviceNameLb;
}

@end
