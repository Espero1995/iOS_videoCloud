//
//  nav_userFolder.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/10/16.
//  Copyright © 2019 苏旋律. All rights reserved.
//
#define KMargin_ItemBtn 15
#import "nav_userFolder.h"
#import "ZScrollLabel.h"
@interface nav_userFolder()
@property (nonatomic, strong) UIView* nav_userDefine_bgView;/**< 自定义导航条的背景view */

@property (nonatomic, strong) UIButton* rightItemBtn;/**< 右边itemBtn */
@property (nonatomic, strong) ZScrollLabel *titleLb;/**< 标题*/
@end

@implementation nav_userFolder

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

#pragma mark - UI
- (void)createUI
{
    [self addSubview:self.nav_userDefine_bgView];
    [self.nav_userDefine_bgView addSubview:self.rightItemBtn];
    [self.rightItemBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(- KMargin_ItemBtn);
        if (iPhone_X_) {
            make.centerY.mas_equalTo(self.nav_userDefine_bgView.mas_centerY).offset(15);
        }else{
            make.centerY.mas_equalTo(self.nav_userDefine_bgView.mas_centerY).offset(8);
        }
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.nav_userDefine_bgView addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(KMargin_ItemBtn);
        make.centerY.mas_equalTo(self.rightItemBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(18, 32));
    }];
    
    
    [self.nav_userDefine_bgView addSubview:self.leftItemBtn];
    [self.leftItemBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backBtn.mas_right).offset(10);
        make.centerY.mas_equalTo(self.rightItemBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    
    [self.nav_userDefine_bgView addSubview:self.titleLb];
//    [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.nav_userDefine_bgView.mas_centerX);
//        make.centerY.equalTo(self.backBtn.mas_centerY);
////        make.width.mas_equalTo(@200);
////        make.left.equalTo(self.mas_left).offset(70);
////        make.right.equalTo(self.mas_right).offset(-70);
//    }];
    
}

- (void)setTitleStr:(NSString *)titleStr
{
    _titleStr = titleStr;
    if ([titleStr containsString:@"("] && [titleStr containsString:@"/"]) {
        NSRange startRange = [titleStr rangeOfString:@"("];
        NSRange endRange = [titleStr rangeOfString:@"/"];
        NSMutableAttributedString *channelStr = [[NSMutableAttributedString alloc] initWithString:titleStr];
        [channelStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:23/255.0 green:139/255.0 blue:54/255.0 alpha:1] range:NSMakeRange(startRange.location+1, endRange.location-startRange.location-1)];
        self.titleLb.attributedText = channelStr;
    }else {
        self.titleLb.text = _titleStr;
    }
}

#pragma mark ====== event response
#pragma mark - 返回点击事件
- (void)backFolderTreeClick
{
    if (self.delegate && [self respondsToSelector:@selector(backFolderTreeClick)]) {
        [self.delegate backFolderTreeClick];
    }
}

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



#pragma mark setters && getters
#pragma mark - bgView
- (UIView *)nav_userDefine_bgView
{
    if (!_nav_userDefine_bgView) {
        _nav_userDefine_bgView = [[UIView alloc]initWithFrame:self.frame];
        _nav_userDefine_bgView.userInteractionEnabled = YES;
        _nav_userDefine_bgView.backgroundColor = [UIColor whiteColor];
    }
    return _nav_userDefine_bgView;
}

#pragma mark - 返回按钮
- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backFolderTreeClick) forControlEvents:UIControlEventTouchUpInside];
        _backBtn.hidden = YES;
    }
    return _backBtn;
}

#pragma mark - 模式切换按钮
- (UIButton *)leftItemBtn
{
    if (!_leftItemBtn) {
        _leftItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftItemBtn setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
        [_leftItemBtn addTarget:self action:@selector(leftItemBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _leftItemBtn.hidden = YES;
    }
    return _leftItemBtn;
}

#pragma mark - 添加设备按钮
- (UIButton *)rightItemBtn
{
    if (!_rightItemBtn) {
        _rightItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightItemBtn setImage:[UIImage imageNamed:@"deviceAdd"] forState:UIControlStateNormal];
//        if (isChannelMode) {
//            [_rightItemBtn setImage:[UIImage imageNamed:@"deviceSearch"] forState:UIControlStateNormal];
//        }else {
//            [_rightItemBtn setImage:[UIImage imageNamed:@"deviceAdd"] forState:UIControlStateNormal];
//        }
        
        [_rightItemBtn addTarget:self action:@selector(rightItemBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightItemBtn;
}

#pragma mark - 标题
- (ZScrollLabel *)titleLb
{
    
    if (!_titleLb) {
        if (iPhone_X_) {
            _titleLb = [[ZScrollLabel alloc] initWithFrame:CGRectMake(0.22*iPhoneWidth, (iPhoneNav_StatusHeight - 20)/2+15, 0.56*iPhoneWidth, 20)];
        }else{
            _titleLb = [[ZScrollLabel alloc] initWithFrame:CGRectMake(0.22*iPhoneWidth, (iPhoneNav_StatusHeight - 20)/2+7, 0.56*iPhoneWidth, 20)];
        }
        
        _titleLb.font = FONT(18);
        _titleLb.textColor = MAIN_COLOR;
        _titleLb.labelAlignment = ZScrollLabelAlignmentCenter;
    }
    return _titleLb;
}

@end
