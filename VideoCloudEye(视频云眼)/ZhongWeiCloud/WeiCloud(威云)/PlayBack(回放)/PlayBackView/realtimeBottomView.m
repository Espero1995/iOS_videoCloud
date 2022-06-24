//
//  realtimeBottomView.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/1/23.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "realtimeBottomView.h"

@interface realtimeBottomView()
@end

@implementation realtimeBottomView

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
    
    float btnHeight;
    if (iPhone_5_Series) {
        btnHeight = 180/750.0*iPhoneWidth;
    }else{
        btnHeight = 200/750.0*iPhoneWidth;
    }

    
    [self addSubview:self.saveLabel];
    [self.saveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(10);
        make.top.mas_equalTo(self.mas_top).offset(0);
        make.size.mas_equalTo(CGSizeMake(200, 23));
    }];
    [self addSubview:self.saveBtn];
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.saveLabel.mas_bottom).offset(0);
        make.centerX.equalTo(self.mas_centerX);
        make.height.mas_equalTo(btnHeight);//FitHeight(btnHeight)
        make.width.mas_equalTo(iPhoneWidth);
    }];
    [self addSubview:self.historyLabel];
    [self.historyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.saveBtn.mas_bottom).offset(0);
        make.left.mas_equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(200, 23));
    }];
    [self addSubview:self.historyBtn];
    [self.historyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.historyLabel.mas_bottom).offset(0);
        make.width.mas_equalTo(iPhoneWidth);
        make.height.mas_equalTo(btnHeight);//FitHeight(btnHeight)
    }];
}

#pragma mark - Action
- (void)saveBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(saveBtnClick)]) {
        [self.delegate saveBtnClick];
    }
}
- (void)historyBtnClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(historyBtnClick)]) {
        [self.delegate historyBtnClick];
    }
}

#pragma mark -getter && setter
- (UILabel *)saveLabel
{
    if (!_saveLabel) {
        _saveLabel = [[UILabel alloc]init];
        _saveLabel.text = @"云存储";
        _saveLabel.font = FONT(15);
    }
    return _saveLabel;
}
- (UILabel *)historyLabel
{
    if (!_historyLabel) {
        _historyLabel = [[UILabel alloc]init];
        _historyLabel.text = @"历史回放";
        _historyLabel.font = FONT(15);
    }
    return _historyLabel;
}

- (UIButton *)saveBtn
{
    if (!_saveBtn) {
        _saveBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        [_saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_saveBtn setBackgroundImage:[UIImage imageNamed:@"cloudClick"] forState:UIControlStateNormal];
    }
    return _saveBtn;
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
