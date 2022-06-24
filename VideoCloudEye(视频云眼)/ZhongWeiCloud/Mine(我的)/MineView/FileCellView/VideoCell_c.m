//
//  VideoCell_c.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/3/22.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "VideoCell_c.h"

@implementation VideoCell_c
- (instancetype)initWithFrame:(CGRect)frame{

    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}


#pragma mark - 生成UI

- (void)createUI{
    //图片
    _ImageV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    _ImageV.contentMode = UIViewContentModeScaleAspectFit;
    _ImageV.userInteractionEnabled = YES;
    _ImageV.contentMode = UIViewContentModeScaleToFill;
    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPage)];
//    [_ImageV addGestureRecognizer:tapGesturRecognizer];
    [self.contentView addSubview:_ImageV];
    [self.ImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(5);
        make.top.equalTo(self.contentView.mas_top).offset(0);
        make.right.equalTo(self.contentView.mas_right).offset(-5);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(0);
    }];
    //选择按钮
    _chooseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_chooseBtn setImage:[UIImage imageNamed:@"select_n"] forState:UIControlStateNormal];
    [_chooseBtn setImage:[UIImage imageNamed:@"select_h"] forState:UIControlStateSelected];
    [self.ImageV addSubview:_chooseBtn];
    [self.chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.ImageV.mas_left).offset(8);
        make.top.equalTo(self.ImageV.mas_top).offset(8);
    }];

    //播放图片
    _playImage = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, 25, 25) imageName:@"playvideo"];
    [self.ImageV addSubview:self.playImage];
    [self.playImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.ImageV.mas_centerX);
        make.centerY.equalTo(self.ImageV.mas_centerY);
    }];
    /*
    //名称
    _nameLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, 200, 10) text:nil font:[UIFont systemFontOfSize:14]];
    _nameLabel.numberOfLines = 1;
//    _nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.ImageV.mas_left).offset(0);
        make.top.equalTo(self.ImageV.mas_bottom).offset(2);
        make.right.equalTo(self.ImageV.mas_right).offset(0);
    }];
    */
}
#pragma mark ------点击图片点用方法
- (void)tapPage
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ImageVClick:)]) {
        [self.delegate ImageVClick:self];
    }
}

@end
