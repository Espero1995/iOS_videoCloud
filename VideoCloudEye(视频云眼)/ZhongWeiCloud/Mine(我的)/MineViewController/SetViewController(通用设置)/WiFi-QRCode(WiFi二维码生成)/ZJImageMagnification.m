//
//  ZJImageMagnification.m
//
//  Created by degulade on 2017/4/21.
//  Copyright © 2017年 degulade. All rights reserved.
/*图片放大*/

#import "ZJImageMagnification.h"
@interface ZJImageMagnification ()
{
    double currentLight;
}
+ (ZJImageMagnification *)sharedSingleton;
@property (nonatomic,assign) double currentLight;

@end

@implementation ZJImageMagnification

@synthesize currentLight;

+ (ZJImageMagnification *)sharedSingleton
{
    static ZJImageMagnification *sharedSingleton;
    
    @synchronized(self)
    {
        if (!sharedSingleton)
            sharedSingleton = [[ZJImageMagnification alloc] init];
        
        return sharedSingleton;
    }
}

//原始尺寸
static CGRect oldframe;

/**
 *  浏览大图
 *
 *  @param currentImageview 当前图片
 *  @param alpha            背景透明度
 */
+(void)scanBigImageWithImageView:(UIImageView *)currentImageview alpha:(CGFloat)alpha {
    
    //  当前imageview的图片
    UIImage *image = currentImageview.image;
    //  当前视图
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //  背景
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    //  当前imageview的原始尺寸->将像素currentImageview.bounds由currentImageview.bounds所在视图转换到目标视图window中，返回在目标视图window中的像素值
    oldframe = [currentImageview convertRect:currentImageview.bounds toView:window];
    [backgroundView setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:alpha]];
    
    //  此时视图不会显示
    [backgroundView setAlpha:0];
    //  将所展示的imageView重新绘制在Window中
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:oldframe];
    [imageView setImage:image];
    imageView.contentMode =UIViewContentModeScaleAspectFit;
    [imageView setTag:1024];
    [backgroundView addSubview:imageView];
    //  将原始视图添加到背景视图中
    [window addSubview:backgroundView];
    
    
    //  添加点击事件同样是类方法 -> 作用是再次点击回到初始大小
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImageView:)];
    [backgroundView addGestureRecognizer:tapGestureRecognizer];
    
    //  动画放大所展示的ImageView
    [UIView animateWithDuration:0.4 animations:^{
        CGFloat y,width,height;
        y = ([UIScreen mainScreen].bounds.size.height - image.size.height *[UIScreen mainScreen].bounds.size.width / image.size.width) * 0.5;
        //宽度为屏幕宽度
        width = 1.0* [UIScreen mainScreen].bounds.size.width;
        //高度 根据图片宽高比设置
        height = image.size.height * [UIScreen mainScreen].bounds.size.width / image.size.width;
        [imageView setFrame:CGRectMake(0, y, width, height)];
        //重要！ 将视图显示出来
        [backgroundView setAlpha:1];
        
    } completion:^(BOOL finished) {

        [ZJImageMagnification sharedSingleton].currentLight =  [[UIScreen mainScreen] brightness];
        double currentLight = [[UIScreen mainScreen] brightness];
        if(currentLight < 0.80){
            [[UIScreen mainScreen] setBrightness:1.0];
        }
    }];
    
}

/**
 *  恢复imageView原始尺寸
 *
 *  @param tap 点击事件
 */
+(void)hideImageView:(UITapGestureRecognizer *)tap{
    
    UIView *backgroundView = tap.view;
    //  原始imageview
    UIImageView *imageView = [tap.view viewWithTag:1024];
    //  恢复
    [UIView animateWithDuration:0.4 animations:^{
        [imageView setFrame:oldframe];
        [backgroundView setAlpha:0];
    } completion:^(BOOL finished) {
        //完成后操作->将背景视图删掉
        [backgroundView removeFromSuperview];
        double lastLight = [ZJImageMagnification sharedSingleton].currentLight;
        [[UIScreen mainScreen] setBrightness:lastLight];
    }];
}

@end
