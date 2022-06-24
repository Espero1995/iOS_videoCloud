//
//  VerifyCodeInputLabel.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/3.
//  Copyright © 2018年 张策. All rights reserved.
//
#define space 10
#import "VerifyCodeInputLabel.h"
//设置边框宽度，值越大，边框越粗
#define ADAPTER_RATE_WIDTH 1
//设置是否有边框，等于 1 时 是下划线  大于1 的时候随着值越大，边框越大，
#define ADAPTER_RATE_HIDTH 1
@interface VerifyCodeInputLabel()
//光标
@property (nonatomic,strong)UILabel *shuLineLb;
@end
@implementation VerifyCodeInputLabel

//重写setText方法，当text改变时手动调用drawRect方法，将text的内容按指定的格式绘制到label上
- (void)setText:(NSString *)text {
    [super setText:text];
    // 手动调用drawRect方法
    [self setNeedsDisplay];
}

// 按照指定的格式绘制验证码/密码
- (void)drawRect:(CGRect)rect1 {
    //计算每位验证码/密码的所在区域的宽和高
    CGRect rect =CGRectMake(0,0,250,45);
    float width = rect.size.width / (float)self.numberOfVerifyCode;
    float height = rect.size.height;
    // 将每位验证码/密码绘制到指定区域
    for (int i =0; i <self.text.length; i++) {
        // 计算每位验证码/密码的绘制区域
        CGRect tempRect =CGRectMake(i * width,0, width, height);
        if (_secureTextEntry) {//密码，显示圆点
            UIImage *dotImage = [UIImage imageNamed:@"dot"];
            // 计算圆点的绘制区域
            CGPoint securityDotDrawStartPoint =CGPointMake(width * i + (width - dotImage.size.width) /2.0, (tempRect.size.height - dotImage.size.height) / 2.0);
            // 绘制圆点
            [dotImage drawAtPoint:securityDotDrawStartPoint];
        } else {//验证码，显示数字
            // 遍历验证码/密码的每个字符
            NSString *charecterString = [NSString stringWithFormat:@"%c", [self.text characterAtIndex:i]];
            // 设置验证码/密码的现实属性
            NSMutableDictionary *attributes = [[NSMutableDictionary alloc]init];
            attributes[NSFontAttributeName] =self.font;
            // 计算每位验证码/密码的绘制起点（为了使验证码/密码位于tempRect的中部，不应该从tempRect的重点开始绘制）
            // 计算每位验证码/密码的在指定样式下的size
            CGSize characterSize = [charecterString sizeWithAttributes:attributes];
            CGPoint vertificationCodeDrawStartPoint =CGPointMake(width * i + (width - characterSize.width) /2.0, (tempRect.size.height - characterSize.height) /2.0);
            // 绘制验证码/密码
            [charecterString drawAtPoint:vertificationCodeDrawStartPoint withAttributes:attributes];
        }
    }
    //绘制底部横线
    for (int k=0; k<self.numberOfVerifyCode; k++) {
        [self drawBottomLineWithRect:rect andIndex:k];
        [self drawCenterLineWithRect:rect andIndex:k];
    }
}

//绘制底部的线条
- (void)drawBottomLineWithRect:(CGRect)rect1 andIndex:(int)k{
    CGRect rect =CGRectMake(0,0,250,45);
//    float width = rect.size.width / (float)self.numberOfVerifyCode;
    float rectWidth = (rect.size.width - 3*space) / (float)self.numberOfVerifyCode;
    float height = rect.size.height;
    //1.获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //2.设置当前上下问路径
    CGFloat lineHidth = 0.5 * ADAPTER_RATE_WIDTH;
    CGFloat strokHidth = 0.5 * ADAPTER_RATE_HIDTH;
    CGContextSetLineWidth(context, lineHidth);
    
    if ( k<=self.text.length ) {
        CGContextSetStrokeColorWithColor(context,RGB(69, 135, 251).CGColor);//底部颜色
        CGContextSetFillColorWithColor(context,RGB(69, 135, 251).CGColor);//内容的颜色
    }else{
        CGContextSetStrokeColorWithColor(context,RGB(200, 200, 200).CGColor);//底部颜色
        CGContextSetFillColorWithColor(context,RGB(69, 135, 251).CGColor);//内容的颜色
    }
//    CGRect rectangle =CGRectMake(k*width+width/10,height-lineHidth-strokHidth,width-width/5,strokHidth);
    CGRect rectangle =CGRectMake(k*rectWidth+space*k,height-lineHidth-strokHidth,rectWidth,strokHidth);
    
    CGContextAddRect(context, rectangle);
    CGContextStrokePath(context);
}

//绘制中间的输入的线条
- (void)drawCenterLineWithRect:(CGRect)rect1 andIndex:(int)k{
    if ( k==self.text.length ) {
        CGRect rect =CGRectMake(0,0,250,45);
        float width = rect.size.width / (float)self.numberOfVerifyCode;
        float height = rect.size.height;
        //1.获取上下文
//        CGContextRef context =UIGraphicsGetCurrentContext();
//        CGContextSetLineWidth(context,1);
//        /****  设置竖线的颜色 ****/
//        CGContextSetStrokeColorWithColor(context,RGB(63, 113, 255).CGColor);
//        CGContextSetFillColorWithColor(context,RGB(63, 113, 255).CGColor);
//        CGContextMoveToPoint(context, width * k + (width -1.0) /2.0, height/5);
//        CGContextAddLineToPoint(context,  width * k + (width -1.0) /2.0,height-height/5);
//        CGContextStrokePath(context);
        

        
        self.shuLineLb.backgroundColor = RGB(69, 135, 251);
        [self addSubview:self.shuLineLb];
        [self.shuLineLb.layer addAnimation:[self opacityForever_Animation:0.7] forKey:nil];
        if (k == 0) {
            self.shuLineLb.frame = CGRectMake(width * k + (width -1.0) /2.0, height/6, 1, height-height/3);
        }else if (k == 1){
            self.shuLineLb.frame = CGRectMake(width * k + (width -1.0) /2.0, height/6, 1, height-height/3);
        }else if (k == 2){
            self.shuLineLb.frame = CGRectMake(width * k + (width -1.0) /2.0, height/6, 1, height-height/3);
        }else if (k == 3){
            self.shuLineLb.frame = CGRectMake(width * k + (width -1.0) /2.0, height/6, 1, height-height/3);
        }
    }
}

#pragma mark === 永久闪烁的动画 ======
-(CABasicAnimation *)opacityForever_Animation:(float)time
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];//这是透明度。
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];///没有的话是均匀的动画。
    return animation;
}

//光标
- (UILabel *)shuLineLb
{
    if (!_shuLineLb) {
        _shuLineLb = [[UILabel alloc]init];
    }
    return _shuLineLb;
}

@end
