//
//  CircleSuccessLoading.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/14.
//  Copyright © 2018年 张策. All rights reserved.
//
static CGFloat lineWidth = 3.0f;
static CGFloat circleDuriation = 0.5f;
static CGFloat checkDuration = 0.2f;

#import "CircleSuccessLoading.h"

@interface CircleSuccessLoading ()<CAAnimationDelegate>
{
    UIVisualEffectView *_containerView;
    UIView *_circleContainer;
    UILabel *_tipLb;
}
@property (nonatomic,copy) NSString *tipStr;
@end

@implementation CircleSuccessLoading{
    CALayer *_animationLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)initUI{
    
    _containerView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    _containerView.frame = CGRectMake(0, 0, 250, 90);
    _containerView.backgroundColor = [UIColor whiteColor];
    _containerView.center = CGPointMake(iPhoneWidth/2.0f, (iPhoneHeight-64-44)/2.0f);
    _containerView.layer.cornerRadius = 10.0f;
    _containerView.layer.masksToBounds = true;
    
    [self addSubview:_containerView];
    
    _circleContainer = [[UIView alloc]init];
    _circleContainer.frame = CGRectMake(0, 5, 40, 40);
    _circleContainer.backgroundColor = [UIColor clearColor];
    _circleContainer.center = CGPointMake(30, _containerView.bounds.size.height/2.0f);
    _circleContainer.layer.masksToBounds = true;
    [_containerView.contentView addSubview:_circleContainer];
    
    _animationLayer = [CALayer layer];
    _animationLayer.bounds = CGRectMake(0, 0, 40, 40);
    _animationLayer.position = CGPointMake(_circleContainer.bounds.size.width/2.0, _circleContainer.bounds.size.height/2.0);
    [_circleContainer.layer addSublayer:_animationLayer];
    
    _tipLb = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 190, 90)];
    [_tipLb setText:self.tipStr];
    [_tipLb setTextColor:RGB(100, 100, 100)];
    [_containerView.contentView addSubview:_tipLb];
    
}

//画圆
- (void)circleAnimation {
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.frame = _animationLayer.bounds;
    [_animationLayer addSublayer:circleLayer];
    circleLayer.fillColor =  [[UIColor clearColor] CGColor];
    circleLayer.strokeColor  = MAIN_COLOR.CGColor;
    circleLayer.lineWidth = lineWidth;
    circleLayer.lineCap = kCALineCapRound;
    
    
    CGFloat lineWidth = 5.0f;
    CGFloat radius = _animationLayer.bounds.size.width/2.0f - lineWidth/2.0f;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:circleLayer.position radius:radius startAngle:-M_PI/2 endAngle:M_PI*3/2 clockwise:true];
    circleLayer.path = path.CGPath;
    
    CABasicAnimation *circleAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    circleAnimation.duration = circleDuriation;
    circleAnimation.fromValue = @(0.0f);
    circleAnimation.toValue = @(1.0f);
    circleAnimation.delegate = self;
    [circleAnimation setValue:@"circleAnimation" forKey:@"animationName"];
    [circleLayer addAnimation:circleAnimation forKey:nil];
    [self checkAnimation];
}

//对号
- (void)checkAnimation{
    
    CGFloat a = _animationLayer.bounds.size.width;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(a*2.7/10,a*5.4/10)];
    [path addLineToPoint:CGPointMake(a*4.5/10,a*7/10)];
    [path addLineToPoint:CGPointMake(a*7.8/10,a*3.8/10)];
    
    CAShapeLayer *checkLayer = [CAShapeLayer layer];
    checkLayer.path = path.CGPath;
    checkLayer.fillColor = [UIColor clearColor].CGColor;
    checkLayer.strokeColor = MAIN_COLOR.CGColor;
    checkLayer.lineWidth = lineWidth;
    checkLayer.lineCap = kCALineCapRound;
    checkLayer.lineJoin = kCALineJoinRound;
    [_animationLayer addSublayer:checkLayer];
    
    CABasicAnimation *checkAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    checkAnimation.duration = checkDuration;
    checkAnimation.fromValue = @(0.0f);
    checkAnimation.toValue = @(1.0f);
    checkAnimation.delegate = self;
    [checkAnimation setValue:@"checkAnimation" forKey:@"animationName"];
    [checkLayer addAnimation:checkAnimation forKey:nil];
    
}


-(void)startLoading:(UIView *)view{
    [self circleAnimation];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2.5 * circleDuriation * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^(void){
        for (CircleSuccessLoading *loading in view.subviews) {
            if ([loading isKindOfClass:[CircleSuccessLoading class]]) {
                [loading stopLoading];
                [loading removeFromSuperview];
            }
        }
    });

}

-(void)stopLoading{
    for (CALayer *layer in _animationLayer.sublayers) {
        [layer removeAllAnimations];
    }
}

+(CircleSuccessLoading *)showSucInView:(UIView *)view andTip:(NSString *)tip{
    [self hideSucInView:view];
    CircleSuccessLoading *loading = [[CircleSuccessLoading alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
    loading.tipStr = tip;
    [loading initUI];
    [view addSubview:loading];
    loading.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    [loading startLoading:view];
    return loading;
}

+(CircleSuccessLoading *)hideSucInView:(UIView *)view{
    CircleSuccessLoading *hud = nil;
    for (CircleSuccessLoading *loading in view.subviews) {
        if ([loading isKindOfClass:[CircleSuccessLoading class]]) {
            [loading stopLoading];
            [loading removeFromSuperview];
            hud = loading;
        }
    }
    return hud;
}

@end
