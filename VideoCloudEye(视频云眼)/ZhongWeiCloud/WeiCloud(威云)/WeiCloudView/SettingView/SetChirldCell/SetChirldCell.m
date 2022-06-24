//
//  SetChirldCell.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/27.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "SetChirldCell.h"

@implementation SetChirldCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}


#pragma mark - 生成UI
- (void)createUI{
    //星期
    _titleLb = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:17]];
    [self.contentView addSubview:_titleLb];
    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];

    //选择按钮
    _chooseBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 12, 9.5)];
    _chooseBtn.enabled = YES;
    _chooseBtn.userInteractionEnabled = YES;
    [_chooseBtn setBackgroundImage:[UIImage imageNamed:@"choose"] forState:UIControlStateSelected];
    
    [self.contentView addSubview:_chooseBtn];
    [self.chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(iPhoneWidth-32);
        make.right.equalTo(self.contentView.mas_left).offset(iPhoneWidth-20);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(12, 9.5));
    }];
    
    
}
- (void)buttonSelected{
    if (_chooseBtn.selected == NO) {
        _chooseBtn.selected = YES;
    }else
        _chooseBtn.selected = NO;
//    NSLog(@"点击");
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
