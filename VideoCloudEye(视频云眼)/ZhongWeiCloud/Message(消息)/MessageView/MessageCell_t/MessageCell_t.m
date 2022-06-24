//
//  MessageCell_t.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/15.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "MessageCell_t.h"
#import "FactoryUI.h"
@implementation MessageCell_t


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
//    _headImage = [FactoryUI createImageViewWithFrame:CGRectZero imageName:nil];
    _headImage = [[UIImageView alloc]initWithFrame:CGRectZero];
    [self.contentView addSubview:_headImage];
    [self.headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.top.equalTo(self.contentView.mas_top).offset(10);
    }];

    //名称
    _NameLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 200, 13) text:nil font:[UIFont systemFontOfSize:15]];
    _NameLabel.textColor = RGB(100, 100, 100);

    [self.contentView addSubview:_NameLabel];
    [self.NameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImage.mas_right).offset(10);
        make.top.equalTo(self.contentView.mas_top).offset(14);
    }];
    
    //消息
    _MessageLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 300, 10) text:nil font:[UIFont systemFontOfSize:12]];
    _MessageLabel.textColor = [UIColor colorWithHexString:@"bababa"];
    [self.contentView addSubview:_MessageLabel];
    [self.MessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImage.mas_right).offset(10);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-14);
        
    }];
    
    // 红点
    _attentionImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 7.5, 7.5)];
    _attentionImage.image = [UIImage imageNamed:@"msg_red"];
    _attentionImage.alpha = 0;
    [self.contentView addSubview:_attentionImage];
    [self.attentionImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.MessageLabel.mas_right).offset(0);
        make.centerY.equalTo(self.MessageLabel.mas_centerY);
    }];
    
    
    //时间
    _TimeLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 50, 10) text:nil font:[UIFont systemFontOfSize:13]];
 
    _TimeLabel.textColor = [UIColor colorWithHexString:@"c9c9c9"];
    _TimeLabel.numberOfLines = 0;
    _TimeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [self.contentView addSubview:_TimeLabel];
    [self.TimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    
    //标签图片
    _iconImage = [[UIImageView alloc]initWithFrame:CGRectZero];
    [self.contentView addSubview:_iconImage];
    [self.iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.NameLabel.mas_right).offset(5);
        make.centerY.equalTo(self.NameLabel.mas_centerY).offset(-1);
    }];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
