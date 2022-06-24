//
//  BackBtnView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/24.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "BackBtnView.h"

@implementation BackBtnView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self initBackLayout];//返回按钮的布局
    self.backgroundColor = [UIColor clearColor];
}

//==========================init==========================
#pragma mark ----- 返回按钮的布局
- (void)initBackLayout{
    [self addSubview:self.backBtn];
    [self.backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(0);
        make.left.equalTo(self.mas_left).offset(0);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
}

//==========================method==========================
#pragma mark ----- 曝露按钮接口
//返回按钮的点击事件
- (void)backClick{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(backBtnClick)]) {
        [self.delegate backBtnClick];
    }
}

//==========================lazy loading==========================
#pragma mark -getter && setter
//返回按钮
- (UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setBackgroundImage:[UIImage imageNamed:@"realTimeBack"] forState:UIControlStateNormal];
    }
    return _backBtn;
}

@end
