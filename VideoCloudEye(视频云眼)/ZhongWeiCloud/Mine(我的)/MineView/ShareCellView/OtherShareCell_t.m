//
//  OtherShareCell_t.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/10.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "OtherShareCell_t.h"

@implementation OtherShareCell_t
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}


#pragma mark - 生成UI

- (void)createUI{
    self.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    //图片
    _headImage = [[UIImageView alloc]initWithFrame:CGRectZero];
    _headImage.layer.masksToBounds = YES;
    _headImage.layer.cornerRadius = 3.f;
    [self.contentView addSubview:_headImage];
    [self.headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(100, 75));
    }];
    
    //名称
    _NameLabel = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:16]];
    _NameLabel.textColor = [UIColor colorWithHexString:@"313335"];
    [self.contentView addSubview:_NameLabel];
    [self.NameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImage.mas_right).offset(15);
        make.top.equalTo(self.headImage.mas_top).offset(3);
        make.right.equalTo(self.contentView.mas_right).offset(-20);
    }];
    
    //消息
    _MessageLabel = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:13]];
    _MessageLabel.textColor = [UIColor colorWithHexString:@"adadad"];
    [self.contentView addSubview:_MessageLabel];
    [self.MessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImage.mas_right).offset(15);
        make.right.equalTo(self.contentView.mas_right).offset(-20);
        make.bottom.equalTo(self.headImage.mas_bottom).offset(-3);
    }];
    
    _cancelShareBtn = [[UIButton alloc]initWithFrame:CGRectZero];
    [_cancelShareBtn setImage:[UIImage imageNamed:@"cancelLink"] forState:UIControlStateNormal];
    [_cancelShareBtn addTarget:self action:@selector(cancelShareBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_cancelShareBtn];
    [self.cancelShareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.right.mas_equalTo(self.contentView.mas_right).offset(0);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
}

- (void)cancelShareBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelShareBtnClick:)]) {
        [self.delegate cancelShareBtnClick:self];
    }
}

- (void)setModel:(others_shared *)model{
    _lis_model = model;
    _NameLabel.text = model.name;
    _MessageLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"来自", nil),model.owner_name];
    NSString *imaStr = [NSString isNullToString:model.vsample];
    NSURL *imaUrl = [NSURL URLWithString:imaStr];
    [_headImage sd_setImageWithURL:imaUrl placeholderImage:[UIImage imageNamed:@"sharedBg"]];
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
