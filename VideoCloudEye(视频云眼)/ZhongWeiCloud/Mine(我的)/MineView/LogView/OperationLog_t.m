//
//  OperationLog_t.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/9/26.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "OperationLog_t.h"
#import "LogModel.h"
@implementation OperationLog_t
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}


#pragma mark - 生成UI

- (void)createUI{

    _dateLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 40, 20) text:nil font:[UIFont systemFontOfSize:18]];
    _dateLabel.textColor = [UIColor colorWithHexString:@"1f1e24"];
    _dateLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _dateLabel.numberOfLines = 1;
    [self.contentView addSubview:_dateLabel];
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(42);
        make.left.equalTo(self.contentView.mas_left).offset(20);
        
    }];
    _timeLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 48, 12) text:nil font:[UIFont systemFontOfSize:10]];
    _timeLabel.textColor = [UIColor colorWithHexString:@"#909090"];
    _timeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _timeLabel.numberOfLines = 1;
    [self.contentView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dateLabel.mas_bottom).offset(5);
        make.left.equalTo(self.dateLabel.mas_left).offset(0);
        make.right.equalTo(self.dateLabel.mas_right).offset(4);
    }];
    _lineView = [FactoryUI createViewWithFrame:CGRectMake(0, 0, 1, 75)];
    _lineView.backgroundColor = [UIColor colorWithHexString:@"#e7e7e7"];
    [self.contentView addSubview:_lineView];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(0);
        make.left.equalTo(self.dateLabel.mas_right).offset(14);
        make.right.equalTo(self.dateLabel.mas_right).offset(15);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(0);
    }];
    _picView = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 13, 13) imageName:@"point_green"];
    [self.contentView addSubview:_picView];
    [_picView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(50);
        make.left.equalTo(self.dateLabel.mas_right).offset(8);
        make.right.equalTo(self.dateLabel.mas_right).offset(21);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-17);
    }];

    _conLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 44, 11) text:nil font:[UIFont systemFontOfSize:11]];
    _conLabel.textColor = [UIColor colorWithHexString:@"#4287ff"];
    _conLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _conLabel.numberOfLines = 1;
    [self.contentView addSubview:_conLabel];
    [_conLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.picView.mas_top).offset(0);
        make.left.equalTo(self.picView.mas_right).offset(15);
    }];
    
    _logLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 200, 11) text:nil font:[UIFont systemFontOfSize:11]];
    _logLabel.textColor = [UIColor colorWithHexString:@"#1f1e24"];
    _logLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _logLabel.numberOfLines = 1;
    [self.contentView addSubview:_logLabel];
    [_logLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.conLabel.mas_top).offset(0);
        make.left.equalTo(self.conLabel.mas_right).offset(25);
        
    }];
    
    _ipLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 100, 10) text:nil font:[UIFont systemFontOfSize:10]];
    _ipLabel.textColor = [UIColor colorWithHexString:@"#a9a9a9"];
    _ipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _ipLabel.numberOfLines = 1;
    [self.contentView addSubview:_ipLabel];
    [_ipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logLabel.mas_bottom).offset(6);
        make.left.equalTo(self.logLabel.mas_left).offset(0);
    }];
    
}
- (void)setModel:(opLogList *)model{
    _model = model;
    NSString * timeStr = [NSString stringWithFormat:@"%@",[_model valueForKey:@"log_time"]];
    double publishLong = [timeStr doubleValue];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:@"MM.dd"];
    //  @"yyyy年MM月dd日 HH:mm:ss E"];
    NSDate *publishDate = [NSDate dateWithTimeIntervalSince1970:publishLong];
    NSString *publishString = [formatter stringFromDate:publishDate];
    _dateLabel.text =publishString;
    
    
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateStyle:NSDateFormatterMediumStyle];
    [formatter1 setTimeStyle:NSDateFormatterShortStyle];
    [formatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter1 setDateFormat:@"HH:mm:ss"];
//    NSDate *publishDate1 = [NSDate dateWithTimeIntervalSince1970:publishLong];
//    NSString *publishString1 = [formatter1 stringFromDate:publishDate1];
     NSDate *publishDate1 = [NSDate dateWithTimeIntervalSince1970:publishLong];
     NSDate* currentData = [self getNowDateFromatAnDate:publishDate1];
     NSString *publishString1 = [formatter1 stringFromDate:currentData];
    _timeLabel.text = publishString1;
    _conLabel.text = [NSString stringWithFormat:@"%@",[_model valueForKey:@"op"]];
    _logLabel.text = [NSString stringWithFormat:@"%@",[_model valueForKey:@"content"]];
    _ipLabel.text = [NSString stringWithFormat:@"%@",[_model valueForKey:@"ip"]];
    
    
    
    
}

- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    
    return destinationDateNow;
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
