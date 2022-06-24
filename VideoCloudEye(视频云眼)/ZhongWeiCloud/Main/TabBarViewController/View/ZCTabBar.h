//
//  ZCTabBar.h
//  ZCTabBarController
//
//  Created by 张策 on 15/12/4.
//  Copyright © 2015年 ZC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZCTabBar;
@protocol ZCTabBarDelegate <NSObject>

@optional
- (void)tabBar:(ZCTabBar *)tabBar didClickButton:(NSInteger)index;

- (void)centerBtnClick;
/**
 *  推出登录
 */
- (void)pushLogVC;
/**
 *  推出认证
 */
- (void)pushCertification;

@end
@interface ZCTabBar : UIView
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSMutableArray *buttons;

@property (nonatomic, weak) id<ZCTabBarDelegate> delegate;

@property (nonatomic,assign)NSInteger selectTag;
@end
