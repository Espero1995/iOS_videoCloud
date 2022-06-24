//
//  showRockerBtnView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/24.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "showRockerBtnView.h"

@implementation showRockerBtnView

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
    [self initRockerLayout];//滚轮按钮的布局
}

//==========================init==========================
#pragma mark ----- 滚轮按钮的布局
- (void)initRockerLayout{
    [self addSubview:self.showRockerBtn];
    [self.showRockerBtn addTarget:self action:@selector(RockerClick) forControlEvents:UIControlEventTouchUpInside];
    [self.showRockerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(0);
        make.bottom.equalTo(self.mas_bottom).offset(0);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];
}

//==========================method==========================
#pragma mark ----- 曝露按钮接口
//控制滚轮的点击事件
- (void)RockerClick{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(showRockerBtnClick)]) {
        [self.delegate showRockerBtnClick];
    }
}

//==========================lazy loading==========================
#pragma mark -getter && setter
//滚轮按钮
-(UIButton *)showRockerBtn{
    if (!_showRockerBtn) {
        _showRockerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_showRockerBtn setBackgroundImage:[UIImage imageNamed:@"realTimeRocker"] forState:UIControlStateNormal];
    }
    return _showRockerBtn;
}

@end
