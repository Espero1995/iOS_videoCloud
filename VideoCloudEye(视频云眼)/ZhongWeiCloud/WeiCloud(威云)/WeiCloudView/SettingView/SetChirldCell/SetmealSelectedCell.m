//
//  SetmealSelectedCell.m
//  ZhongWeiCloud
//
//  Created by Espero on 2017/11/23.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "SetmealSelectedCell.h"

@implementation SetmealSelectedCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}

#pragma mark - 生成UI
- (void)createUI{
    _BoxView = [FactoryUI createViewWithFrame:CGRectMake(15, 7.5, iPhoneWidth-30, 55)];
    _BoxView.layer.masksToBounds = YES;
    _BoxView.layer.cornerRadius = 5.0f;
    _BoxView.layer.borderWidth = 1.0f;
    _BoxView.layer.borderColor = RGB(217, 218, 219).CGColor;
    [self addSubview:_BoxView];
    
    float width = (iPhoneWidth-30)/3;
    //1.天数
    _daysLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 20, width, 16) text:nil font:[UIFont systemFontOfSize:16]];
    _daysLabel.textAlignment=NSTextAlignmentCenter;
    [_BoxView addSubview:_daysLabel];
    //2.套餐类型
    _typeLabel = [FactoryUI createLabelWithFrame:CGRectMake(width, 0, width, 55) text:nil font:[UIFont systemFontOfSize:16]];
    _typeLabel.textAlignment=NSTextAlignmentCenter;
    [_BoxView addSubview:_typeLabel];
    //3.价格
    _priceLabel = [FactoryUI createLabelWithFrame:CGRectMake(2*width, 17.5, width, 20) text:nil font:[UIFont systemFontOfSize:19]];
    _priceLabel.textColor = RGB(250, 92, 0);
    _priceLabel.textAlignment=NSTextAlignmentCenter;
    [_BoxView addSubview:_priceLabel];
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_BoxView.mas_right).offset(-5);
        make.centerY.mas_equalTo(_BoxView);
        make.size.mas_equalTo(CGSizeMake(60, 25));
    }];
    
//    //4.推荐图片
    _recommandImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 17.5, 20, 20)];
    _recommandImg.image = [UIImage imageNamed:@"recommend"];
    _recommandImg.hidden = YES;
    [_BoxView addSubview:_recommandImg];
    //5.原价Label
    _originalPriceLabel = [FactoryUI createLabelWithFrame:CGRectZero text:nil font:[UIFont systemFontOfSize:14]];//CGRectMake(2*width-15, 17.5, 35, 20)
    _originalPriceLabel.textColor = [UIColor lightGrayColor];
    _originalPriceLabel.textAlignment=NSTextAlignmentCenter;
//    _originalPriceLabel.hidden = YES;
    [_BoxView addSubview:_originalPriceLabel];
    [_originalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_priceLabel.mas_left).offset(2);
        make.centerY.mas_equalTo(_BoxView);
        make.size.mas_equalTo(CGSizeMake(35, 20));
    }];
    
    //6.划线img
    _lineImgLabel = [[UILabel alloc]initWithFrame:CGRectMake(2*width-20, 27, 45, 1)];
    _lineImgLabel.backgroundColor = [UIColor lightGrayColor];
    _lineImgLabel.hidden = YES;
    [_BoxView addSubview:_lineImgLabel];
    [_lineImgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_priceLabel.mas_left).offset(2);
        make.centerY.mas_equalTo(_BoxView);
        make.size.mas_equalTo(CGSizeMake(35, 1));
    }];
}

//被选中的cell修改样式
- (void)changeSelectUI{
    //修改框的颜色和背景色
    _BoxView.layer.borderColor = RGB(251, 91, 0).CGColor;
    _BoxView.backgroundColor = RGB(252, 232, 204);
}

//取消被选择的状态
- (void)cancelSelectUI{
    _BoxView.layer.borderColor = RGB(217, 218, 219).CGColor;
    _BoxView.backgroundColor = [UIColor whiteColor];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}



@end
