//
//  InvestigateCell_t.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/21.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "InvestigateCell_t.h"

@implementation InvestigateCell_t
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}


#pragma mark - 生成UI

- (void)createUI{
    //星期
    _titleLbel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 45, 15) text:nil font:[UIFont systemFontOfSize:15]];
    _titleLbel.textColor = [UIColor colorWithHexString:@"313335"];
    _titleLbel.numberOfLines = 1;
    [self.contentView addSubview:_titleLbel];
    [self.titleLbel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(20);
        make.top.equalTo(self.contentView.mas_top).offset(10);
    }];
    //线
    _lineView = [FactoryUI createViewWithFrame:CGRectMake(20, 0, iPhoneWidth-20, 0.5)];
    _lineView.backgroundColor = [UIColor colorWithHexString:@"#dedede"];
    [self.contentView addSubview:_lineView];
//    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.titleLbel.mas_left).offset(0);
//        make.bottom.equalTo(self.contentView.mas_bottom).offset(0);
//    }];
    //选择按钮
    _chooseBtn = [FactoryUI createButtonWithFrame:CGRectMake(0, 0, 15, 13) title:nil titleColor:nil imageName:nil backgroundImageName:nil target:self selector:nil];
//    _chooseBtn.backgroundColor = [UIColor colorWithHexString:@"#f4f4f4"];
    _chooseBtn.enabled = YES;
    _chooseBtn.userInteractionEnabled = YES;
//    [_chooseBtn addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [_chooseBtn setBackgroundImage:[UIImage imageNamed:@"choose"] forState:UIControlStateSelected];
    
    [self.contentView addSubview:_chooseBtn];
    [self.chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(iPhoneWidth-35);
        make.right.equalTo(self.contentView.mas_left).offset(iPhoneWidth-20);
        make.top.equalTo(self.contentView.mas_top).offset(11);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-11);
    }];

    
}
- (void)buttonSelected{

    if (_chooseBtn.selected == NO) {
        _chooseBtn.selected = YES;
    }else
        _chooseBtn.selected = NO;
    
    NSLog(@"点击");
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
