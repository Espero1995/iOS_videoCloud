//
//  HomeShareCollectionCell.m
//  mb
//
//  Created by Boris on 2018/5/21.
//  Copyright © 2018年 laborc. All rights reserved.
//

#import "HomeShareCollectionCell.h"
#import "Masonry.h"

@implementation HomeShareCollectionCell


- (UIImageView *)headerImg
{
    if (!_headerImg) {
        self.headerImg = [UIImageView new];
    }
    return _headerImg;
}


- (UILabel *)conLabel
{
    if (!_conLabel) {
        self.conLabel = [UILabel new];
        _conLabel.text = @"";
        _conLabel.textAlignment = NSTextAlignmentCenter;
        
//        if (UI_IS_IPHONE5) {
            _conLabel.font = [UIFont systemFontOfSize:11];
//        }else{
            _conLabel.font = [UIFont systemFontOfSize:12];
//        }
        
        _conLabel.textColor = [UIColor blackColor];
    }
    return _conLabel;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.headerImg];
        [self.contentView addSubview:self.conLabel];
        [self makeSubViewsLayout];
    }
    return self;
}






// 给控件做约束
- (void)makeSubViewsLayout
{
    [self.headerImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.centerX.equalTo(self.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(50.f / 375.f * [UIScreen mainScreen].bounds.size.width, 50.f / 375.f * [UIScreen mainScreen].bounds.size.width));
    }];
    
    [self.conLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerImg.mas_bottom).offset(5.f / 375.f * [UIScreen mainScreen].bounds.size.width);
        make.left.equalTo(self.mas_left).offset(5);
        make.right.equalTo(self.mas_right).offset(-5);
        make.height.mas_equalTo(22.f / 375.f * [UIScreen mainScreen].bounds.size.width );
    }];
    
}



@end
