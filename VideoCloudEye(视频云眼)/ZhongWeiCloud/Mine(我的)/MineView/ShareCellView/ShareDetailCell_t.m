//
//  ShareDetailCell_t.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/6.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "ShareDetailCell_t.h"

@implementation ShareDetailCell_t
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
    
    //按钮
    [self.contentView addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.size.mas_equalTo(CGSizeMake(60, 30));
    }];
 
}

- (void)CancleShared:(ShareDetailCell_t *)cell{
    if (self.delegete && [self.delegete respondsToSelector:@selector(ShareDetail_tCancelBtnClick:)]) {
        [self.delegete ShareDetail_tCancelBtnClick:self];
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
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
- (UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc]init];
        [_cancelBtn setTitleColor:RGB(100, 100, 100) forState:UIControlStateNormal];
        [_cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _cancelBtn.layer.cornerRadius = 5;
        _cancelBtn.layer.borderColor = RGB(100, 100, 100).CGColor;
        _cancelBtn.layer.borderWidth = 0.5f;
        [_cancelBtn addTarget:self action:@selector(CancleShared:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _cancelBtn;
}

@end
