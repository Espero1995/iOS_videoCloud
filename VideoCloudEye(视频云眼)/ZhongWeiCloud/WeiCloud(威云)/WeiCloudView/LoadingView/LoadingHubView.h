//
//  LoadingHubView.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/7/27.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingHubView : UIView

@property (nonatomic, strong) UIColor *hudColor;

-(void)showAnimated:(BOOL)animated;
-(void)hide;



@end
