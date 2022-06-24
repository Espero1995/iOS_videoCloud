//
//  InvestigateTimeCell.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/22.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "InvestigateTimeCell.h"

@implementation InvestigateTimeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}


#pragma mark - 生成UI

- (void)createUI{
    
    _backView = [FactoryUI createViewWithFrame:CGRectMake(0, 0, iPhoneWidth, 40)];

    [self.contentView addSubview:_backView];
    
    _lineView = [FactoryUI createViewWithFrame:CGRectMake(0, 0, iPhoneWidth, 0.5)];
    _lineView.backgroundColor = [UIColor colorWithHexString:@"#c6c6c6"];
    [self.contentView addSubview:_lineView];
    //从
    _fromLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 16, 16) text:nil font:[UIFont systemFontOfSize:16]];
    _fromLabel.text = @"从";
    _fromLabel.textColor = [UIColor colorWithHexString:@"0068ff"];
    _fromLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _fromLabel.numberOfLines = 0;
    [self.contentView addSubview:_fromLabel];
    [self.fromLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(iPhoneWidth/2-24);
        make.top.equalTo (self.contentView.mas_top).offset(12);
    }];
       //开始时间
    _beginLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 100, 16) text:nil font:[UIFont systemFontOfSize:16]];
    _beginLabel.textColor = [UIColor colorWithHexString:@"0068ff"];
    _beginLabel.text = @"00:00";
    _beginLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _beginLabel.numberOfLines = 0;
    [self.contentView addSubview:_beginLabel];
    [self.beginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.fromLabel.mas_right).offset(10);
        make.top.equalTo (self.fromLabel.mas_top).offset(0);
        
        
    }];
    



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
