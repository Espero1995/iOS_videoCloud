//
//  PublicShareCell_t.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/8.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "PublicShareCell_t.h"

@implementation PublicShareCell_t
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

#pragma mark - 生成UI

- (void)createUI{
    self.backgroundColor = RGB(255, 255, 255);
    
    //图片
    _headImage = [FactoryUI createImageViewWithFrame:CGRectZero imageName:nil];
    _headImage.layer.masksToBounds = YES;
    _headImage.layer.cornerRadius = 3.f;
    [self.contentView addSubview:_headImage];
    [self.headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(100, 75));
    }];
    _idLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 0, 0) text:nil font:nil];
    _idLabel.alpha = 0;
    [self.contentView addSubview:_idLabel];
    //名称
    _NameLabel = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:16]];
    _NameLabel.textColor = [UIColor colorWithHexString:@"313335"];
    [self.contentView addSubview:_NameLabel];
    [self.NameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImage.mas_right).offset(15);
        make.centerY.equalTo(self.headImage.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-90);
    }];
    
    //消息
    _MessageLabel = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:13]];
    _MessageLabel.textColor = [UIColor colorWithHexString:@"adadad"];
    [self.contentView addSubview:_MessageLabel];
    [self.MessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.centerY.equalTo(self.headImage.mas_centerY);
    }];
    
    
}

- (void)setModel:(shared *)model{
    _lis_model = model;
    _NameLabel.text = model.name;
    _MessageLabel.text = [NSString stringWithFormat:@"分享给:%@",model.name];//user_list[0][@"name"]
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
