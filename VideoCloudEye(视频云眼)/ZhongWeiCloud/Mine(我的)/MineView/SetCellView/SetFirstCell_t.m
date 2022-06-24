//
//  SetFirstCell_t.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/20.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "SetFirstCell_t.h"

@implementation SetFirstCell_t
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}


#pragma mark - 生成UI

- (void)createUI{
    //类型
    _typeLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 300, 14) text:nil font:[UIFont systemFontOfSize:14]];
    _typeLabel.textColor = [UIColor colorWithHexString:@"000000"];
    _typeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _typeLabel.numberOfLines = 0;
    [self.contentView addSubview:_typeLabel];
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(20);
        make.top.equalTo (self.contentView.mas_top).offset(10);
    }];
    //线
    _lineView1 = [FactoryUI createViewWithFrame:CGRectMake(20,0, self.bounds.size.width+100, 0.5)];
    _lineView1.backgroundColor = [UIColor colorWithHexString:@"#dedede"];
    [self.contentView addSubview:_lineView1];
    //开关按钮
    _switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 46.5, 28.5)];
    _switchBtn.enabled = YES;
    _switchBtn.userInteractionEnabled = YES;
    _switchBtn.on = NO;
    _switchBtn.onTintColor = [UIColor greenColor];
//    _switchBtn.tintColor = [UIColor grayColor];
    [self.contentView addSubview:_switchBtn];
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(6.25);
        make.right.equalTo(self.contentView.mas_right).offset(-13);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-6.25);
        make.left.equalTo(self.contentView.mas_left).offset(iPhoneWidth-59.5);
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
