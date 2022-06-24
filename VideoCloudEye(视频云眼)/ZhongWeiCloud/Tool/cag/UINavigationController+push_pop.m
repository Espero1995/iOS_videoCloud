//
//  UINavigationController+push_pop.m
//  HybridDevelopedApp
//
//  Created by Espero on 2019/2/20.
//  Copyright © 2019 Espero. All rights reserved.
//

#import "UINavigationController+push_pop.h"

@implementation UINavigationController (push_pop)


//是否关闭左滑功能
/**
 * description:禁止页面左侧滑动返回，注意，如果仅仅需要禁止此单个页面返回，还需要在viewWillDisapper下开放侧滑权限
 */
- (void)enablePopGesture:(BOOL)enable
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = enable;
    }
}

//从下往上PUSH
- (void)pushViewControllerFromTop:(UIViewController *)VC
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    [self.view.layer addAnimation:transition forKey:kCATransition];
    [self pushViewController:VC animated:NO];
}


//从上往下POP
- (void)popViewControllerFromBottom
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [self.view.layer addAnimation:transition forKey:kCATransition];
    [self popViewControllerAnimated:NO];
}
@end
