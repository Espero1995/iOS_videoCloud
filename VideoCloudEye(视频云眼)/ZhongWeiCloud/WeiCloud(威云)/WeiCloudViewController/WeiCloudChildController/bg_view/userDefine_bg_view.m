//
//  userDefine_bg_view.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/7/23.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "userDefine_bg_view.h"
@interface userDefine_bg_view()
<
    UIGestureRecognizerDelegate
>
@end

@implementation userDefine_bg_view

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bg_view_TapAction:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
}

- (void)bg_view_TapAction:(UITapGestureRecognizer*)tap
{
    if (self.delegate && [self respondsToSelector:@selector(bg_view_TapAction:)]) {
        [self.delegate bg_view_TapAction:tap];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
//    NSLog(@"输出点击的view的类名：%@", NSStringFromClass([touch.view class]));
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
} 

@end
