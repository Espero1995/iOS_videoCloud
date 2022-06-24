//
//  UINavigationController+push_pop.h
//  HybridDevelopedApp
//
//  Created by Espero on 2019/2/20.
//  Copyright © 2019 Espero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (push_pop)

/**
 * @brief 是否开启左滑pop功能
 * @param enable 传YES/NO
 */
- (void)enablePopGesture:(BOOL)enable;

/**
 * @brief 从下往上PUSH
 * @param VC 需要push的VC
 */
- (void)pushViewControllerFromTop:(UIViewController *)VC;

/**
 * @brief 从上往下POP
 */
- (void)popViewControllerFromBottom;



@end

