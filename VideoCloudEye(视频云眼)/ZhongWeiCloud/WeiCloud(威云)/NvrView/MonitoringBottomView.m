//
//  MonitoringBottomView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/4/3.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "MonitoringBottomView.h"
@interface MonitoringBottomView()
@end
@implementation MonitoringBottomView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGB(242, 242, 242);
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
  
    [self addSubview:self.historyLabel];
    [_historyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(10);
        make.top.mas_equalTo(self).offset(8);
        make.size.mas_equalTo(CGSizeMake(200, 10));
    }];
    
    [self addSubview:self.historyBtn];
    [_historyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_equalTo(iPhoneWidth);
        make.top.mas_equalTo(self.historyLabel.mas_bottom).offset(6);
        make.height.mas_equalTo(FitHeight(180));
    }];
}

#pragma mark - Action

- (void)historyBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(historyBtnClick)]) {
        [self.delegate historyBtnClick];
    }
}

#pragma mark -getter && setter

- (UILabel *)historyLabel
{
    if (!_historyLabel) {
        _historyLabel = [[UILabel alloc]init];
        _historyLabel.text = @"历史回放";
        _historyLabel.font = FONT(15);
    }
    return _historyLabel;
}

- (UIButton *)historyBtn
{
    if (!_historyBtn) {
        _historyBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        [_historyBtn addTarget:self action:@selector(historyBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_historyBtn setBackgroundImage:[UIImage imageNamed:@"timeClick"] forState:UIControlStateNormal];
    }
    return _historyBtn;
}

@end
