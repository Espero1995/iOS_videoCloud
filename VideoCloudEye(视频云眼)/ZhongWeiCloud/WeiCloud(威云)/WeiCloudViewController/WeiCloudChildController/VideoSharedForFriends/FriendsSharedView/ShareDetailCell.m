//
//  ShareDetailCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/9/3.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "ShareDetailCell.h"

@implementation ShareDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

#pragma mark - 生成UI
- (void)createUI{
    self.backgroundColor = [UIColor whiteColor];
    //图片
    [self.contentView addSubview:self.headImage];
    [self.headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    //备注
    [self.contentView addSubview:self.remarkNameLb];
    [self.remarkNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImage.mas_right).offset(10);
        make.right.equalTo(self.contentView.mas_right).offset(-70);
        make.top.equalTo(self.headImage.mas_top).offset(5);
    }];
    //手机号
    [self.contentView addSubview:self.mobileLb];
    [self.mobileLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImage.mas_right).offset(10);
        make.right.equalTo(self.contentView.mas_right).offset(-70);
        make.bottom.equalTo(self.headImage.mas_bottom).offset(-5);
    }];
    //备注按钮
    [self.contentView addSubview:self.remarksBtn];
    [self.remarksBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.size.mas_equalTo(CGSizeMake(60, 30));
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - 修改备注
- (void)remarkClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ShareDetailRemarkClick:)]) {
        [self.delegate ShareDetailRemarkClick:self];
    }
}

#pragma mark - getter && setter
//头像
- (UIImageView *)headImage
{
    if (!_headImage) {
        _headImage = [[UIImageView alloc]init];
        _headImage.layer.cornerRadius = 20;
        _headImage.clipsToBounds = YES;
    }
    return _headImage;
}
//备注名
- (UILabel *)remarkNameLb
{
    if (!_remarkNameLb) {
        _remarkNameLb = [[UILabel alloc]init];
        _remarkNameLb.font = FONT(15);
    }
    return _remarkNameLb;
}
//手机号
- (UILabel *)mobileLb
{
    if (!_mobileLb) {
        _mobileLb = [[UILabel alloc]init];
        _mobileLb.font = FONT(13);
        _mobileLb.textColor = RGB(180, 180, 180);
    }
    return _mobileLb;
}
//备注按钮
- (UIButton *)remarksBtn
{
    if (!_remarksBtn) {
        _remarksBtn = [[UIButton alloc]init];
        [_remarksBtn setTitleColor:RGB(100, 100, 100) forState:UIControlStateNormal];
        [_remarksBtn setTitle:NSLocalizedString(@"备注", nil) forState:UIControlStateNormal];
        _remarksBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _remarksBtn.layer.cornerRadius = 5;
        _remarksBtn.layer.borderColor = RGB(100, 100, 100).CGColor;
        _remarksBtn.layer.borderWidth = 0.5f;
        [_remarksBtn addTarget:self action:@selector(remarkClick) forControlEvents:UIControlEventTouchUpInside];

    }
    return _remarksBtn;
}
@end
