//
//  testView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/13.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "testView.h"
static CGFloat ballScale = 1.5f;
@interface testView()<CAAnimationDelegate>
{
    UIVisualEffectView *_ballContainer;
    UIView *_ball1;
    UIView *_ball2;
    UIView *_ball3;
    BOOL _stopAnimationByUser;
}
@end
@implementation testView


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

-(void)initUI{
    _ballContainer = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    _ballContainer.frame = CGRectMake(0, 0, 50, 50);
    _ballContainer.backgroundColor = [UIColor yellowColor];
    _ballContainer.center = CGPointMake(self.bounds.size.width/2.0f, self.bounds.size.height/2.0f);
    _ballContainer.layer.cornerRadius = 10.0f;
    _ballContainer.layer.masksToBounds = true;
    [self addSubview:_ballContainer];
    
    CGFloat ballWidth = 8.0f;
    CGFloat margin = 2.0f;
    
    _ball1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ballWidth, ballWidth)];
    _ball1.center = CGPointMake(ballWidth/2.0f + margin, _ballContainer.bounds.size.height/2.0f);
    _ball1.layer.cornerRadius = ballWidth/2.0f;
    _ball1.backgroundColor = [UIColor colorWithRed:54/255.0 green:136/255.0 blue:250/255.0 alpha:1];
    [_ballContainer.contentView addSubview:_ball1];
    
    _ball2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ballWidth, ballWidth)];
    _ball2.center = CGPointMake(_ballContainer.bounds.size.width/2.0f, _ballContainer.bounds.size.height/2.0f);
    _ball2.layer.cornerRadius = ballWidth/2.0f;
    _ball2.backgroundColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1];
    [_ballContainer.contentView addSubview:_ball2];
    
    _ball3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ballWidth, ballWidth)];
    _ball3.center = CGPointMake(_ballContainer.bounds.size.width - ballWidth/2.0f - margin, _ballContainer.bounds.size.height/2.0f);
    _ball3.layer.cornerRadius = ballWidth/2.0f;
    _ball3.backgroundColor = [UIColor colorWithRed:234/255.0 green:67/255.0 blue:69/255.0 alpha:1];
    [_ballContainer.contentView addSubview:_ball3];
}

-(void)startPathAnimate{
    
    //-------第一个球的动画
    CGFloat width = _ballContainer.bounds.size.width;
    //小圆半径
    CGFloat r = (_ball1.bounds.size.width)*ballScale/2.0f;
    //大圆半径
    CGFloat R = (width/2 + r)/2.0;
    
    UIBezierPath *path1 = [UIBezierPath bezierPath];
    [path1 moveToPoint:_ball1.center];
    //画大圆
    [path1 addArcWithCenter:CGPointMake(R + r, width/2) radius:R startAngle:M_PI endAngle:M_PI*2 clockwise:NO];
    //画小圆
    UIBezierPath *path1_1 = [UIBezierPath bezierPath];
    [path1_1 addArcWithCenter:CGPointMake(width/2, width/2) radius:r*2 startAngle:M_PI*2 endAngle:M_PI clockwise:NO];
    [path1 appendPath:path1_1];
    //回到原处
    [path1 addLineToPoint:_ball1.center];
    //执行动画
    CAKeyframeAnimation *animation1 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation1.path = path1.CGPath;
    animation1.removedOnCompletion = YES;
    animation1.duration = [self animationDuration];
    animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_ball1.layer addAnimation:animation1 forKey:@"animation1"];
    
    
    //-------第三个球的动画
    UIBezierPath *path3 = [UIBezierPath bezierPath];
    [path3 moveToPoint:_ball3.center];
    //画大圆
    [path3 addArcWithCenter:CGPointMake(width - (R + r), width/2) radius:R startAngle:2*M_PI endAngle:M_PI clockwise:NO];
    //画小圆
    UIBezierPath *path3_1 = [UIBezierPath bezierPath];
    [path3_1 addArcWithCenter:CGPointMake(width/2, width/2) radius:r*2 startAngle:M_PI endAngle:M_PI*2 clockwise:NO];
    [path3 appendPath:path3_1];
    //回到原处
    [path3 addLineToPoint:_ball3.center];
    //执行动画
    CAKeyframeAnimation *animation3 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation3.path = path3.CGPath;
    animation3.removedOnCompletion = YES;
    animation3.duration = [self animationDuration];
    animation3.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation3.delegate = self;
    [_ball3.layer addAnimation:animation3 forKey:@"animation3"];
}


//放大缩小动画
-(void)animationDidStart:(CAAnimation *)anim{
    
    CGFloat delay = 0.3f;
    CGFloat duration = [self animationDuration]/2 - delay;
    
    [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseOut| UIViewAnimationOptionBeginFromCurrentState animations:^{
        _ball1.transform = CGAffineTransformMakeScale(ballScale, ballScale);
        _ball2.transform = CGAffineTransformMakeScale(ballScale, ballScale);
        _ball3.transform = CGAffineTransformMakeScale(ballScale, ballScale);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseInOut| UIViewAnimationOptionBeginFromCurrentState animations:^{
            _ball1.transform = CGAffineTransformIdentity;
            _ball2.transform = CGAffineTransformIdentity;
            _ball3.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (_stopAnimationByUser) {return;}
    [self startPathAnimate];
}


-(CGFloat)animationDuration{
    return 1.6f;
}


+(testView *)shareInstance{
    static testView *mTestView=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mTestView=[[testView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
    });
    return mTestView;
}


#pragma mark ----- 显示隐藏方法
-(void)start{
    [self startPathAnimate];
    _stopAnimationByUser = false;
}

-(void)stop{
    _stopAnimationByUser = true;
    [_ball1.layer removeAllAnimations];
    [_ball1 removeFromSuperview];
    [_ball2.layer removeAllAnimations];
    [_ball2 removeFromSuperview];
    [_ball3.layer removeAllAnimations];
    [_ball3 removeFromSuperview];
}



+(void)showInView{
    [self hideInView];
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:[testView shareInstance]];
    [testView shareInstance].backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [[testView shareInstance] start];
    
}

+(void)hideInView{
    [[testView shareInstance] removeFromSuperview];
//    [[testView shareInstance] stop];
}


@end
