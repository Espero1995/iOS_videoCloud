//
//  RealTimeCloudControlView.m
//  ZhongWeiCloud
//
//  Created by 王攀登 on 2022/6/30.
//  Copyright © 2022 苏旋律. All rights reserved.
//

#import "RealTimeCloudControlView.h"

@implementation RealTimeCloudControlView

- (instancetype)initWithTargetVC:(UIViewController *)targetVC {
    self = [super init];
    if (self) {
        UILabel *titleLabel = [UILabel new];
        titleLabel.text = @"云台控制";
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

@end
