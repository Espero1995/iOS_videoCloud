//
//  SetThirdCell_t.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/20.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "SetThirdCell_t.h"

@implementation SetThirdCell_t
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}


#pragma mark - 生成UI

- (void)createUI{
    //线
    _lineView1 = [FactoryUI createViewWithFrame:CGRectMake(20,0, self.bounds.size.width+100, 0.5)];
    _lineView1.backgroundColor = [UIColor colorWithHexString:@"#dedede"];
    [self.contentView addSubview:_lineView1];

    //从
    _fromLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 14, 14) text:nil font:[UIFont systemFontOfSize:14]];
    _fromLabel.text = @"从";
    _fromLabel.textColor = [UIColor colorWithHexString:@"000000"];
    _fromLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _fromLabel.numberOfLines = 0;
    [self.contentView addSubview:_fromLabel];
    [self.fromLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(20);
        make.top.equalTo (self.contentView.mas_top).offset(11);
    }];
    //至
    _overLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 14, 14) text:nil font:[UIFont systemFontOfSize:14]];
    _overLabel.text = @"至";
    _overLabel.textColor = [UIColor colorWithHexString:@"000000"];
    _overLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _overLabel.numberOfLines = 0;
    [self.contentView addSubview:_overLabel];
    [self.overLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(20);
        make.top.equalTo (self.fromLabel.mas_bottom).offset(8);
        
    }];
    //箭头
    _pushImage = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 6.5, 11.5) imageName:@"more"];
    [self.contentView addSubview:_pushImage];
    [self.pushImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(24.1);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-24.15);
        make.left.equalTo(self.contentView.mas_left).offset(iPhoneWidth-19.5);
        make.height.equalTo(@11.5);
        make.width.equalTo(@6.5);
    }];

    //开始时间
    _beginLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 100, 15) text:nil font:[UIFont systemFontOfSize:15]];
    _beginLabel.textColor = [UIColor colorWithHexString:@"077eff"];
    _beginLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _beginLabel.numberOfLines = 0;
    [self.contentView addSubview:_beginLabel];
    [self.beginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pushImage.mas_left).offset(-10);
        make.top.equalTo (self.contentView.mas_top).offset(10);
        
        
    }];
    
    //结束时间
    _stopLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 100, 15) text:nil font:[UIFont systemFontOfSize:15]];
    _stopLabel.textColor = [UIColor colorWithHexString:@"077eff"];
    _stopLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _stopLabel.numberOfLines = 0;
    [self.contentView addSubview:_stopLabel];
    [self.stopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.beginLabel.mas_right).offset(0);
        make.top.equalTo (self.beginLabel.mas_bottom).offset(8);
        
    }];
    //星期
    _firstLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 30, 10) text:nil font:[UIFont systemFontOfSize:10]];
    _firstLabel.textColor = [UIColor colorWithHexString:@"459eff"];
    _firstLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _firstLabel.numberOfLines = 0;
    _firstLabel.text = @"星期一";
    [self.contentView addSubview:_firstLabel];
    [self.firstLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.fromLabel.mas_right).offset(25);
        make.top.equalTo(self.contentView.mas_top).offset(13);
    }];
    _secondLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 30, 10) text:nil font:[UIFont systemFontOfSize:10]];
    _secondLabel.textColor = [UIColor colorWithHexString:@"459eff"];
    _secondLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _secondLabel.numberOfLines = 0;
    _secondLabel.text = @"星期二";
    [self.contentView addSubview:_secondLabel];
    [self.secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.firstLabel.mas_right).offset(20);
        make.top.equalTo(self.contentView.mas_top).offset(13);
    }];
    _thirdLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 30, 10) text:nil font:[UIFont systemFontOfSize:10]];
    _thirdLabel.textColor = [UIColor colorWithHexString:@"459eff"];
    _thirdLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _thirdLabel.numberOfLines = 0;
    _thirdLabel.text = @"星期三";
    [self.contentView addSubview:_thirdLabel];
    [self.thirdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.secondLabel.mas_right).offset(20);
        make.top.equalTo(self.contentView.mas_top).offset(13);
    }];
    
    _fourthLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 30, 10) text:nil font:[UIFont systemFontOfSize:10]];
    _fourthLabel.textColor = [UIColor colorWithHexString:@"459eff"];
    _fourthLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _fourthLabel.numberOfLines = 0;
    _fourthLabel.text = @"星期四";
    [self.contentView addSubview:_fourthLabel];
    [self.fourthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.thirdLabel.mas_right).offset(20);
        make.top.equalTo(self.contentView.mas_top).offset(13);
    }];
    
    _fifthLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 30, 10) text:nil font:[UIFont systemFontOfSize:10]];
    _fifthLabel.textColor = [UIColor colorWithHexString:@"459eff"];
    _fifthLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _fifthLabel.numberOfLines = 0;
    _fifthLabel.text = @"星期五";
    [self.contentView addSubview:_fifthLabel];
    [self.fifthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.firstLabel.mas_left).offset(0);
        make.top.equalTo(self.firstLabel.mas_bottom).offset(14);
    }];
    
    _sixthLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 30, 10) text:nil font:[UIFont systemFontOfSize:10]];
    _sixthLabel.textColor = [UIColor colorWithHexString:@"459eff"];
    _sixthLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _sixthLabel.numberOfLines = 0;
    _sixthLabel.text = @"星期六";
    [self.contentView addSubview:_sixthLabel];
    [self.sixthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.secondLabel.mas_left).offset(0);
        make.top.equalTo(self.firstLabel.mas_bottom).offset(14);
    }];
    
    _seventhLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 30, 10) text:nil font:[UIFont systemFontOfSize:10]];
    _seventhLabel.textColor = [UIColor colorWithHexString:@"459eff"];
    _seventhLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _seventhLabel.numberOfLines = 0;
    _seventhLabel.text = @"星期日";
    [self.contentView addSubview:_seventhLabel];
    [self.seventhLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.thirdLabel.mas_left).offset(0);
        make.top.equalTo(self.firstLabel.mas_bottom).offset(14);
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
