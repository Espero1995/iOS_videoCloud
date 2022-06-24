//
//  ZCTabBarController.h
//  ZCTabBarController
//
//  Created by 张策 on 15/12/4.
//  Copyright © 2015年 ZC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCTabBar.h"
@interface ZCTabBarController : UITabBarController
//是否隐藏tab
@property (nonatomic,setter=isTabarHidden:)BOOL tabHidden;
/**
 *  选中的第几个控制器
 */
@property (nonatomic,assign)NSUInteger tabSelectIndex;
@property (nonatomic,assign)NSUInteger tabLastSelectedIndex;//上一个选择的控制器
@property (nonatomic,assign)BOOL supportLandscape;
//停止定时器
- (void)stopTimer;
//开启视频sdk
- (void)setVideoSdk;
//关闭视频sdk
- (void)deallocVideoSdk;
@end
