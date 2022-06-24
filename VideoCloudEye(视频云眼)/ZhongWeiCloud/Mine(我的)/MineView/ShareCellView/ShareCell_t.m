//
//  ShareCell_t.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/5.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "ShareCell_t.h"

@implementation ShareCell_t

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
    _headImage = [FactoryUI createImageViewWithFrame:CGRectMake(0,0, 90, 40) imageName:nil];
//    _headImage.contentMode = UIViewContentModeScaleAspectFit;
//    _headImage.clipsToBounds = YES;
    [self.contentView addSubview:_headImage];
    [self.headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(13);
        make.top.equalTo(self.contentView.mas_top).offset(10);
        make.right.equalTo(self.contentView.mas_left).offset(103);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
        
    }];
    
    //名称
    _NameLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 200, 16) text:nil font:[UIFont systemFontOfSize:16]];
    _NameLabel.textColor = [UIColor colorWithHexString:@"313335"];
    _NameLabel.numberOfLines = 0;
    _NameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_NameLabel];
    [self.NameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(118.5);
        make.top.equalTo(self.contentView.mas_top).offset(22);
    }];
    
    //消息
    _MessageLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 300, 13) text:nil font:[UIFont systemFontOfSize:13]];
    _MessageLabel.textColor = [UIColor colorWithHexString:@"adadad"];
    _MessageLabel.numberOfLines = 0;
    _MessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_MessageLabel];
    [self.MessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-13);
        make.top.equalTo(self.contentView.mas_top).offset(23.5);
        
    }];
    
    
    //线
    _lineView = [FactoryUI createViewWithFrame:CGRectMake(0, 59, iPhoneWidth, 0.5)];
    _lineView.backgroundColor = [UIColor colorWithHexString:@"#d5d5d5"];
    [self.contentView addSubview:_lineView];
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
