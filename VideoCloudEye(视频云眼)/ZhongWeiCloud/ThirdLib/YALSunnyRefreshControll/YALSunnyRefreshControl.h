//
//  YALSunyRefreshControl.h
//  YALSunyPullToRefresh
//
//  Created by Konstantin Safronov on 12/24/14.
//  Copyright (c) 2014 Konstantin Safronov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YALSunnyRefreshControl : UIView
@property (nonatomic, strong) UIScrollView *scrollView;
+ (YALSunnyRefreshControl*)attachToScrollView:(UIScrollView *)scrollView
                                      target:(id)target
                               refreshAction:(SEL)refreshAction;
- (void)endRefreshing;

@end
