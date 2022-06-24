//
//  SwitchFolderTreeView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/10/16.
//  Copyright © 2019 苏旋律. All rights reserved.
//
#define switchShowBtn_bgView_Height 50
#import "SwitchFolderTreeView.h"

@interface SwitchFolderTreeView()
@end

@implementation SwitchFolderTreeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - UI
 - (void)createUI
 {
     self.backgroundColor = [UIColor whiteColor];
     [self addSubview:self.switchShowStyle_bgView];
     [self.switchShowStyle_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.right.top.bottom.mas_equalTo(self);
     }];
     
     [self.switchShowStyle_bgView addSubview:self.switchShowBtn_bgView];
     [self.switchShowBtn_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.right.mas_equalTo(self.switchShowStyle_bgView);
         make.bottom.mas_equalTo(self.switchShowStyle_bgView.mas_bottom);
         make.height.mas_equalTo(switchShowBtn_bgView_Height);
     }];
     
     
     [self.switchShowStyle_bgView addSubview:self.line1_horizontal];
     [self.line1_horizontal mas_makeConstraints:^(MASConstraintMaker *make) {
         make.right.mas_equalTo(self.switchShowStyle_bgView);
         make.left.mas_equalTo(self.switchShowBtn_bgView.mas_left).offset(20);
         make.height.mas_equalTo(@0.5);
         make.bottom.mas_equalTo(self.switchShowBtn_bgView.mas_top).offset(5);//TODO
     }];
     
     [self.switchShowBtn_bgView addSubview:self.littleMode];
     [self.littleMode mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.mas_equalTo(self.switchShowBtn_bgView.mas_left);
         make.top.bottom.mas_equalTo(self.switchShowBtn_bgView);
         make.size.mas_equalTo(CGSizeMake((iPhoneWidth/3)-1, switchShowBtn_bgView_Height));
         }];
     [self.switchShowBtn_bgView addSubview:self.largeMode];
     [self.largeMode mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.mas_equalTo(self.littleMode.mas_right);
         make.top.bottom.mas_equalTo(self.switchShowBtn_bgView);
         make.size.mas_equalTo(CGSizeMake((iPhoneWidth/3), switchShowBtn_bgView_Height));
     }];
     
     [self.switchShowBtn_bgView addSubview:self.fourScreenMode];
     [self.fourScreenMode mas_makeConstraints:^(MASConstraintMaker *make) {
         make.right.mas_equalTo(self.switchShowBtn_bgView.mas_right);
         make.top.bottom.mas_equalTo(self.switchShowBtn_bgView);
         make.size.mas_equalTo(CGSizeMake((iPhoneWidth/3)-1, switchShowBtn_bgView_Height));
     }];
     
     [self.switchShowBtn_bgView addSubview:self.line1_vertical];
     [self.line1_vertical mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.mas_equalTo(self.littleMode.mas_right);
         make.centerY.mas_equalTo(self.switchShowBtn_bgView);
         make.height.mas_equalTo(switchShowBtn_bgView_Height /3);
         make.width.mas_equalTo(@1);
     }];
     
     [self.switchShowBtn_bgView addSubview:self.line2_vertical];
     [self.line2_vertical mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.mas_equalTo(self.largeMode.mas_right);
         make.centerY.mas_equalTo(self.switchShowBtn_bgView);
         make.height.mas_equalTo(switchShowBtn_bgView_Height /3);
         make.width.mas_equalTo(@1);
     }];
     
     
     [self.switchShowStyle_bgView addSubview:self.closeBtn];
     [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
         make.right.mas_equalTo(self.switchShowStyle_bgView).offset(-15);
         if (iPhone_X_) {
             make.top.mas_equalTo(self.switchShowStyle_bgView).offset(50);
         }else{
             make.top.mas_equalTo(self.switchShowStyle_bgView).offset(30);
         }
     }];
     
     
     [self.switchShowBtn_bgView addSubview:self.titleLb];
     [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
         make.centerY.equalTo(self.closeBtn.mas_centerY);
         make.left.equalTo(self.switchShowBtn_bgView.mas_left).offset(15);
     }];
     
     if (self.littleMode.selected) {
         self.titleLb.text = NSLocalizedString(@"小屏模式", nil);
     }
     if (self.largeMode.selected) {
         self.titleLb.text = NSLocalizedString(@"大屏模式", nil);
     }
     
     if (self.fourScreenMode.selected) {
         self.titleLb.text = NSLocalizedString(@"四分屏模式", nil);
     }
     
 }


#pragma mark === Action
- (void)SwitchShowStyleBtnClick:(UIButton*)btn
{
    if (self.delegate && [self respondsToSelector:@selector(SwitchShowStyleBtnClick:)]) {
        [self.delegate SwitchShowStyleBtnClick:btn];
    }
}

#pragma mark === getter && setter
- (UIView *)switchShowStyle_bgView//self上面的一层背景view
{
    if (!_switchShowStyle_bgView) {
        _switchShowStyle_bgView = [[UIView alloc]initWithFrame:CGRectZero];
    }
    return _switchShowStyle_bgView;
}

- (UIView *)switchShowBtn_bgView
{
    if (!_switchShowBtn_bgView) {
        _switchShowBtn_bgView = [[UIView alloc]initWithFrame:CGRectZero];
        _switchShowBtn_bgView.backgroundColor = [UIColor colorWithHexString:@"#EEEFF3"];
    }
    return _switchShowBtn_bgView;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.tag = TAG_CLOSEBTN;
        _closeBtn.hidden = YES;
        [_closeBtn setImage:[UIImage imageNamed:@"close_three"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(SwitchShowStyleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}


- (UIButton *)littleMode
{
    if (!_littleMode) {
        _littleMode = [UIButton buttonWithType:UIButtonTypeCustom];
        _littleMode.tag = TAG_LITTLEMODE;
        if ([unitl CameraListDisplayMode] == CameraListDisplayMode_littleMode) {
            _littleMode.selected = YES;
        }
        [_littleMode setImage:[UIImage imageNamed:@"list_n"] forState:UIControlStateNormal];
        [_littleMode setImage:[UIImage imageNamed:@"list_h"] forState:UIControlStateSelected];
        [_littleMode addTarget:self action:@selector(SwitchShowStyleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _littleMode;
}

- (UIButton *)largeMode
{
    if (!_largeMode) {
        _largeMode = [UIButton buttonWithType:UIButtonTypeCustom];
        _largeMode.tag = TAG_LARGEMODE;
        if ([unitl CameraListDisplayMode] == CameraListDisplayMode_largeMode) {
            _largeMode.selected = YES;
        }
        [_largeMode setImage:[UIImage imageNamed:@"big_n"] forState:UIControlStateNormal];
        [_largeMode setImage:[UIImage imageNamed:@"big_h"] forState:UIControlStateSelected];
        [_largeMode addTarget:self action:@selector(SwitchShowStyleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _largeMode;
}

- (UIButton *)fourScreenMode
{
    if (!_fourScreenMode) {
        _fourScreenMode = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([unitl CameraListDisplayMode] == CameraListDisplayMode_fourScreenMode) {
            _fourScreenMode.selected = YES;
        }
        _fourScreenMode.tag = TAG_FOURSCREENMODE;
        [_fourScreenMode setImage:[UIImage imageNamed:@"gouped_n"] forState:UIControlStateNormal];
        [_fourScreenMode setImage:[UIImage imageNamed:@"gouped_h"] forState:UIControlStateSelected];
        [_fourScreenMode addTarget:self action:@selector(SwitchShowStyleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fourScreenMode;
}

- (UIView *)line1_vertical
{
    if (!_line1_vertical) {
        _line1_vertical = [[UIView alloc]initWithFrame:CGRectZero];
        _line1_vertical.backgroundColor = [UIColor lightGrayColor];
    }
    return _line1_vertical;
}

- (UIView *)line2_vertical
{
    if (!_line2_vertical) {
        _line2_vertical = [[UIView alloc]initWithFrame:CGRectZero];
        _line2_vertical.backgroundColor = [UIColor lightGrayColor];
    }
    return _line2_vertical;
}

- (UIView *)line1_horizontal
{
    if (!_line1_horizontal) {
        _line1_horizontal = [[UIView alloc]initWithFrame:CGRectZero];
        _line1_horizontal.backgroundColor = RGB(220, 220, 220);
        _line1_horizontal.hidden = YES;
    }
    return _line1_horizontal;
}

- (UILabel *)titleLb
{
    if (!_titleLb) {
        _titleLb = [[UILabel alloc]init];
        _titleLb.font = FONT(25);
        _titleLb.textColor = MAIN_COLOR;
        _titleLb.text = NSLocalizedString(@"小屏模式", nil);
    }
    return _titleLb;
}

@end
