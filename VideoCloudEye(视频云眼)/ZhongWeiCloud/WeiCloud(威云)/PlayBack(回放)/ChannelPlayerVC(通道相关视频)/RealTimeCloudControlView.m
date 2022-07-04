//
//  RealTimeCloudControlView.m
//  ZhongWeiCloud
//
//  Created by 王攀登 on 2022/6/30.
//  Copyright © 2022 苏旋律. All rights reserved.
//

#import "RealTimeCloudControlView.h"

@interface RealTimeCloudControlView ()

@property (nonatomic, strong) UIButton* subtractBtn;/**< 焦距减 */
@property (nonatomic, strong) UIButton* plusBtn;/**< 焦距加 */

@end

@implementation RealTimeCloudControlView

- (instancetype)initWithTargetVC:(UIViewController *)targetVC {
    self = [super init];
    if (self) {
        UILabel *titleLabel = [UILabel new];
        titleLabel.text = NSLocalizedString(@"云台控制", nil);
        titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:titleLabel];
        self.normalZMRocker =[[ZMRocker alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
        [self.normalZMRocker setStyle:RockStyleBig];
        self.normalZMRocker.delegate = targetVC;
        [self addSubview:self.normalZMRocker];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(20);
            make.centerX.equalTo(self);
        }];
        [self.normalZMRocker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(70);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(140, 140));
        }];
        
        [self addSubview:self.subtractBtn];
        [self addSubview:self.plusBtn];
        [self.subtractBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(25);
            make.centerY.mas_equalTo(self.normalZMRocker);
            make.size.mas_equalTo(CGSizeMake(50, 30));
        }];
        [self.plusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-25);
            make.centerY.mas_equalTo(self.normalZMRocker);
            make.size.mas_equalTo(CGSizeMake(50, 30));
        }];
    }
    return self;
}


// 重写hitTest
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // 判断当前点在不在audioView上.
    CGPoint playViewPoint = [self convertPoint:point toView:self.normalZMRocker];// 把当前点转换成view所在的坐标系
    // 在audioView上的话，进行下续操作
    if ([self.normalZMRocker pointInside:playViewPoint withEvent:event]) {
        if (self.hitTestPostBlock) {
            self.hitTestPostBlock(NO);
        }
        return self.normalZMRocker;
    }else {
        // 不在的话  继续默认方法
        if (self.hitTestPostBlock) {
            self.hitTestPostBlock(YES);
        }
        return [super hitTest:point withEvent:event];
    }
}

- (UIButton *)subtractBtn
{
    if (!_subtractBtn) {
        _subtractBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_subtractBtn setImage:[UIImage imageNamed:@"subStrct_h"] forState:UIControlStateNormal];
        [_subtractBtn setImage:[UIImage imageNamed:@"subStrct"] forState:UIControlStateHighlighted];
        [_subtractBtn addTarget:self action:@selector(electronicControlSubtrace) forControlEvents:UIControlEventTouchDown];
        [_subtractBtn addTarget:self action:@selector(electronicControlVCStopAction) forControlEvents:UIControlEventTouchUpInside];
        _subtractBtn.layer.masksToBounds = YES;
        _subtractBtn.layer.cornerRadius = 4;
        [_subtractBtn setBackgroundColor:[UIColor colorWithHexString:@"#e6e6e6"]];
    }
    return _subtractBtn;
}

- (UIButton *)plusBtn
{
    if (!_plusBtn) {
        _plusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_plusBtn setImage:[UIImage imageNamed:@"plusBtn_h"] forState:UIControlStateNormal];
        [_plusBtn setImage:[UIImage imageNamed:@"plusBtn"] forState:UIControlStateHighlighted];
        [_plusBtn addTarget:self action:@selector(electronicControlPlus) forControlEvents:UIControlEventTouchDown];
        [_plusBtn addTarget:self action:@selector(electronicControlVCStopAction) forControlEvents:UIControlEventTouchUpInside];
        _plusBtn.layer.masksToBounds = YES;
        _plusBtn.layer.cornerRadius = 4;
        [_plusBtn setBackgroundColor:[UIColor colorWithHexString:@"#e6e6e6"]];
    }
    return _plusBtn;
}

- (void)electronicControlSubtrace {
    if (self.electronicControlSubtraceBlock) {
        self.electronicControlSubtraceBlock();
    }
}

- (void)electronicControlPlus {
    if (self.electronicControlPlusBlock) {
        self.electronicControlPlusBlock();
    }
}

- (void)electronicControlVCStopAction {
    if (self.electronicControlVCStopBlock) {
        self.electronicControlVCStopBlock();
    }
}

@end
