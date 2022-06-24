//
//  PassageWay_t.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/12.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "PassageWay_t.h"

@implementation PassageWay_t
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}


#pragma mark - 生成UI
- (void)createUI{
    //图标
    _imageV = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 27, 18) imageName:@"list_recorder"];
    [self.contentView addSubview:_imageV];
    [_imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(15);
        make.size.mas_equalTo(CGSizeMake(27, 18));
    }];
    //设备名
   _titleLbel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 60, 18) text:nil font:[UIFont systemFontOfSize:15]];
   _titleLbel.textColor = [UIColor colorWithHexString:@"#212322"];
   _titleLbel.numberOfLines = 1;
   [self.contentView addSubview:_titleLbel];
   [self.titleLbel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.left.equalTo(self.imageV.mas_right).offset(15);
       make.centerY.equalTo(self.imageV.mas_centerY);
       make.right.equalTo(self.contentView.mas_right).offset(0);
    }];
   //选择按钮
//   _chooseBtn = [FactoryUI createButtonWithFrame:CGRectMake(0, 0, 18, 18) title:nil titleColor:nil imageName:nil backgroundImageName:nil target:self selector:nil];
//   _chooseBtn.enabled = YES;
//   _chooseBtn.userInteractionEnabled = YES;
//   _chooseBtn.hidden = YES;
//   [_chooseBtn setBackgroundImage:[UIImage imageNamed:@"list_unchecked"] forState:UIControlStateNormal];
//   [_chooseBtn setBackgroundImage:[UIImage imageNamed:@"list_choice"] forState:UIControlStateSelected];
//
//   [self.contentView addSubview:_chooseBtn];
//   [self.chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//       make.left.equalTo(self.contentView.mas_right).offset(-30);
////       make.top.equalTo(self.contentView.mas_top).offset(16);
//       make.centerY.equalTo(self.contentView.mas_centerY);
//   }];
   
}

- (void)buttonSelected{
    if (_chooseBtn.selected == NO) {
        _chooseBtn.selected = YES;
    }else
        _chooseBtn.selected = NO;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
