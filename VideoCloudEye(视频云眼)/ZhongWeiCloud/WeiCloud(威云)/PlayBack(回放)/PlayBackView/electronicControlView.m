//
//  electronicControlView.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2019/3/12.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import "electronicControlView.h"

@interface electronicControlView()
@property (nonatomic, strong) UIButton* subtractBtn;/**< 焦距减 */
@property (nonatomic, strong) UIButton* plusBtn;/**< 焦距加 */
@property (nonatomic, strong) UILabel* titleLab;/**< 文字标题 */
@property (nonatomic, strong) UIImageView* bgIV;/**< 背景view */
@end

@implementation electronicControlView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self createUI];
    }
    return self;
}
- (void)createUI
{
    WS(weakSelf);
    [self addSubview:self.bgIV];
    [self.bgIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(weakSelf);
    }];
    
    [self.bgIV addSubview:self.subtractBtn];
    [self.subtractBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.bgIV.mas_left);
        make.centerY.mas_equalTo(weakSelf.bgIV.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(70, 72));
    }];
    
    [self.bgIV addSubview:self.plusBtn];
    [self.plusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.bgIV.mas_right);
        make.centerY.mas_equalTo(weakSelf.bgIV.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(70, 72));
    }];
    
    [self.bgIV addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.bgIV.mas_centerX);
        make.centerY.mas_equalTo(weakSelf.bgIV.mas_centerY);
    }];
}

- (void)electronicControlVCAction:(UIButton*)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(electronicControlVCAction:)]) {
        [self.delegate electronicControlVCAction:btn];
    }
}

- (void)electronicControlVCStopAction:(UIButton*)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(electronicControlVCStopAction:)]) {
        [self.delegate electronicControlVCStopAction:btn];
    }
}

#pragma mark - getter && setter
- (UIButton *)subtractBtn
{
    if (!_subtractBtn) {
        _subtractBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _subtractBtn.tag = electronicControlBtnType_subtract;
        [_subtractBtn setImage:[UIImage imageNamed:@"subStrct"] forState:UIControlStateNormal];
        [_subtractBtn setImage:[UIImage imageNamed:@"subStrct_h"] forState:UIControlStateHighlighted];
        [_subtractBtn addTarget:self action:@selector(electronicControlVCAction:) forControlEvents:UIControlEventTouchDown];
        [_subtractBtn addTarget:self action:@selector(electronicControlVCStopAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _subtractBtn;
}

- (UIButton *)plusBtn
{
    if (!_plusBtn) {
        _plusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _plusBtn.tag = electronicControlBtnType_plus;
        [_plusBtn setImage:[UIImage imageNamed:@"plusBtn"] forState:UIControlStateNormal];
        [_plusBtn setImage:[UIImage imageNamed:@"plusBtn_h"] forState:UIControlStateHighlighted];
        [_plusBtn addTarget:self action:@selector(electronicControlVCAction:) forControlEvents:UIControlEventTouchDown];
        [_plusBtn addTarget:self action:@selector(electronicControlVCStopAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _plusBtn;
}

- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc]init];
        _titleLab.text = NSLocalizedString(@"缩放", nil);
        _titleLab.textColor = [UIColor whiteColor];
    }
    return _titleLab;
}

- (UIImageView *)bgIV
{
    if (!_bgIV) {
        _bgIV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"electronicControl_BG"]];
        _bgIV.userInteractionEnabled = YES;
    }
    return _bgIV;
}

@end
