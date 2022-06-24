//
//  CircleLoading.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/13.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleLoading : UIView

/**
 开始加载动画
 */
-(void)startLoading;

/**
 停止加载
 */
-(void)stopLoading;

/**
 显示竖屏加载等待框

 @param view 当前view
 @param tip 提示的文本信息
 @return  显示加载等待框
 */
+(CircleLoading *)showCircleInView:(UIView*)view andTip:(NSString *)tip;

/**
 

 @param view 显示横屏加载等待框
 @param tip 提示的文本信息
 @return 显示加载等待框
 */
+(CircleLoading *)showCircleInView:(UIView*)view andTipH:(NSString *)tip;
+(CircleLoading *)hideCircleInView:(UIView*)view;
@end
