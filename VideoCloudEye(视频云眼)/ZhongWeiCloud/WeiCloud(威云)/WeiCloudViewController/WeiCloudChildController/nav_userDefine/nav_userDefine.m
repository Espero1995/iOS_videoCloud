//
//  nav_userDefine.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/7/18.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "nav_userDefine.h"
#import "UIButton+JKImagePosition.h"
#define KMargin_sc       80
#define KMargin_ItemBtn  15
#define groupBtnEdge     (iPhoneWidth - 2 * KMargin_sc - 3 * groupBtnWidth) / 4
#define groupBetweenEdge 2 * groupBtnEdge + 10
#define groupBtnWidth    60
#define groupBtnHeight   60

@implementation nav_userDefine

- (instancetype)initWithFrame:(CGRect)frame GroupNameAndIDArr:(NSMutableArray *)groupNameAndIDArr
{
    self = [super initWithFrame:frame];
    if (self) {
        [self dealData_GroupNameAndIDArr:groupNameAndIDArr];
        [self createUI];
    }
    return self;
}

#pragma mark - public methods
- (void)changeNavFrameAnimation:(NSTimeInterval)duration IsUp:(BOOL)isUp compeleteBlock:(void (^)())compeleteBlock
{
    if (isUp) {
        [UIView animateWithDuration:duration animations:^{
            CGFloat nav_CurrentHeight = CGRectGetHeight(self.frame);
            if (nav_CurrentHeight != NavBarHeight_UserDefined_Up) {
                [self setFrame:CGRectMake(0, 0, iPhoneWidth, NavBarHeight_UserDefined_Up)];//Status_NavBar
                [self.nav_userDefine_bgView setFrame:self.frame];
                CGFloat navCurrentHeight = CGRectGetHeight(self.nav_userDefine_bgView.frame) - 20;
                [self.sc mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(KMargin_sc);
                    make.right.mas_equalTo(-KMargin_sc);
                    make.top.mas_equalTo(@20);
                    make.height.mas_equalTo(navCurrentHeight);
                }];
                [self.sc changeBtnAndTitleFrameAnimationIsUp:isUp];
                [self layoutIfNeeded];
                if (compeleteBlock) {
                    compeleteBlock();
                }
            }
            [unitl saveDataWithKey:NAV_Status Data:@"NAV_Status_UP"];
        }];
    } else {
        [UIView animateWithDuration:duration animations:^{
            CGFloat nav_CurrentHeight = CGRectGetHeight(self.frame);
            if (nav_CurrentHeight != NavBarHeight_UserDefined) {
                [self setFrame:CGRectMake(0, 0, iPhoneWidth, NavBarHeight_UserDefined)];
                [self.nav_userDefine_bgView setFrame:self.frame];
                CGFloat navCurrentHeight = CGRectGetHeight(self.nav_userDefine_bgView.frame) - 20;
                [self.sc mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(KMargin_sc);
                    make.right.mas_equalTo(-KMargin_sc);
                    make.top.mas_equalTo(@20);
                    make.height.mas_equalTo(navCurrentHeight);
                }];
                [self.sc changeBtnAndTitleFrameAnimationIsUp:isUp];
                [self layoutIfNeeded];
                if (compeleteBlock) {
                    compeleteBlock();
                }
                [unitl saveDataWithKey:NAV_Status Data:@"NAV_Status_DOWN"];
            }
        }];
    }
}

//处理初始化传来的数组，根据数组来创建当前的组btn和sc的长度
- (void)dealData_GroupNameAndIDArr:(NSMutableArray *)groupNameAndIDArr
{
    if (groupNameAndIDArr) {
        for (int i = 0; i < groupNameAndIDArr.count; i++) {
            [self.groupNameArr addObject:groupNameAndIDArr[i][@"groupName"]];
            [self.groupIDArr addObject:groupNameAndIDArr[i][@"groupID"]];
        }
    }
}

- (void)createUI
{
    [self addSubview:self.nav_userDefine_bgView];
    [self.nav_userDefine_bgView addSubview:self.sc];

    [self.nav_userDefine_bgView addSubview:self.leftItemBtn];
    [self.leftItemBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KMargin_ItemBtn);
        make.centerY.mas_equalTo(self.nav_userDefine_bgView.mas_centerY).offset(15);
    }];

    [self.nav_userDefine_bgView addSubview:self.rightItemBtn];
    [self.rightItemBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(- KMargin_ItemBtn);
        make.centerY.mas_equalTo(self.nav_userDefine_bgView.mas_centerY).offset(15);
    }];

    // 搜索功能屏蔽
    [self.nav_userDefine_bgView addSubview:self.searchBtn];
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.rightItemBtn.mas_left).offset(- KMargin_ItemBtn);
        make.centerY.mas_equalTo(self.nav_userDefine_bgView.mas_centerY).offset(15);
    }];

}

#pragma mark ======  event response
#pragma mark - 菜单栏
- (void)leftItemBtnClick
{
    if (self.delegate && [self respondsToSelector:@selector(leftItemBtnClick)]) {
        [self.delegate leftItemBtnClick];
    }
}

#pragma mark - 添加设备
- (void)rightItemBtnClick
{
    if (self.delegate && [self respondsToSelector:@selector(rightItemBtnClick)]) {
        [self.delegate rightItemBtnClick];
    }
}

#pragma mark - 分组
- (void)centerItemBtnClick
{
//    if (self.delegate && [self respondsToSelector:@selector(centerItemBtnClick)]) {
//        [self.delegate centerItemBtnClick];
//    }
}

- (void)groupBtnClick
{
    if (self.delegate && [self respondsToSelector:@selector(groupBtnClick)]) {
        [self.delegate groupBtnClick];
    }
}

#pragma mark - 搜索
- (void)searchItemBtnClick
{
    if (self.delegate && [self respondsToSelector:@selector(searchItemBtnClick)]) {
        [self.delegate searchItemBtnClick];
    }
}

#pragma mark ====== setter && getter
- (UIView *)nav_userDefine_bgView
{
    if (!_nav_userDefine_bgView) {
        _nav_userDefine_bgView = [[UIView alloc]initWithFrame:self.frame];
        _nav_userDefine_bgView.userInteractionEnabled = YES;
        _nav_userDefine_bgView.backgroundColor = self.nav_main_bgColor;
    }
    return _nav_userDefine_bgView;
}

- (definePageWidthRoundSc *)sc
{
    if (!_sc) {
        CGFloat navCurrentHeight = CGRectGetHeight(self.nav_userDefine_bgView.frame) - 20;
        _sc = [[definePageWidthRoundSc alloc]initWithFrame:CGRectMake(KMargin_sc, 20, iPhoneWidth - 2 * KMargin_sc, navCurrentHeight) GroupNameArr:self.groupNameArr GroupIDArr:self.groupIDArr GroupBtnLabelArr:self.groupBtnLabelArr GroupBtnArr:self.groupBtnArr];
        [_sc setScContentSize:CGSizeMake(self.groupNameArr.count * groupBtnWidth + (self.groupNameArr.count + 1) * groupBtnEdge, navCurrentHeight)];
    }
    return _sc;
}

- (UIButton *)leftItemBtn
{
    if (!_leftItemBtn) {
        _leftItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftItemBtn setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
        [_leftItemBtn addTarget:self action:@selector(leftItemBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftItemBtn;
}

- (UIButton *)rightItemBtn
{
    if (!_rightItemBtn) {
        _rightItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightItemBtn setImage:[UIImage imageNamed:@"search_icon"] forState:UIControlStateNormal];
        [_rightItemBtn addTarget:self action:@selector(rightItemBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightItemBtn;
}

- (UIButton *)searchBtn
{
    if (!_searchBtn) {
        _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_searchBtn setImage:[UIImage imageNamed:@"deviceSearch"] forState:UIControlStateNormal];
        [_searchBtn addTarget:self action:@selector(searchItemBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchBtn;
}

- (UIButton *)centerBtn
{
    if (!_centerBtn) {
        _centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_centerBtn setImage:[UIImage imageNamed:@"centerGroup"] forState:UIControlStateNormal];
        [_centerBtn addTarget:self action:@selector(centerItemBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _centerBtn;
}

- (UILabel *)centerBtnLabel
{
    if (!_centerBtnLabel) {
        _centerBtnLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _centerBtnLabel.text = NSLocalizedString(@"我的设备", nil);
        [_centerBtnLabel setFont:[UIFont boldSystemFontOfSize:FitWidth(14)]];
        [_centerBtnLabel setTextColor:MAIN_COLOR];
    }
    return _centerBtnLabel;
}

- (UIColor *)nav_main_bgColor
{
    if (!_nav_main_bgColor) {
        _nav_main_bgColor = [UIColor whiteColor];
    }
    return _nav_main_bgColor;
}

- (NSMutableArray *)groupBtnArr
{
    if (!_groupBtnArr) {
        _groupBtnArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _groupBtnArr;
}

- (NSMutableArray *)groupBtnLabelArr
{
    if (!_groupBtnLabelArr) {
        _groupBtnLabelArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _groupBtnLabelArr;
}

- (NSMutableArray *)groupNameArr
{
    if (!_groupNameArr) {
        _groupNameArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _groupNameArr;
}

- (NSMutableArray *)groupIDArr
{
    if (!_groupIDArr) {
        _groupIDArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _groupIDArr;
}

@end
