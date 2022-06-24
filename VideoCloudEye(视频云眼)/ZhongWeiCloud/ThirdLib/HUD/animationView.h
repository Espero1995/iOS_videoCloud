//
//  animationView.h
//  animation
//
//  Created by lee on 2016/10/18.
//  Copyright © 2016年 lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface animationView : UIView
@property (nonatomic, assign) CGFloat timeFlag;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, strong) UIColor* color1;//内圆颜色
@property (nonatomic, strong) UIColor* color2;//中间颜色
@property (nonatomic, strong) UIColor* color3;//外圈颜色

-(void)startAnimation;//
-(void)stopAnimation;
+(void)showInView:(UIView *)view;//显示动画
+(void)dismiss;//停止动画
@end
