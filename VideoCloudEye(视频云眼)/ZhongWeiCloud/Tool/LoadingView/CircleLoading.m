//
//  CircleLoading.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/13.
//  Copyright © 2018年 张策. All rights reserved.
//
static CGFloat lineWidth = 3.0f;

#import "CircleLoading.h"

@interface CircleLoading ()
{
    UIVisualEffectView *_containerView;
    UIView *_circleContainer;
    UILabel *_tipLb;
}
@property (nonatomic,copy) NSString *tipStr;
@end

@implementation CircleLoading
{
    CADisplayLink *_link;
    CAShapeLayer *_animationLayer;
    
    CGFloat _startAngle;
    CGFloat _endAngle;
    CGFloat _progress;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

-(void)initUI{
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
    
    
    _animationLayer = [CAShapeLayer layer];
    _animationLayer.bounds = CGRectMake(0, 0, 40, 40);
    _animationLayer.position = CGPointMake(_circleContainer.bounds.size.width/2.0f, _circleContainer.bounds.size.height/2.0);
    _animationLayer.fillColor = [UIColor clearColor].CGColor;
    _animationLayer.strokeColor = MAIN_COLOR.CGColor;
    _animationLayer.lineWidth = lineWidth;
    _animationLayer.lineCap = kCALineCapRound;
    [_circleContainer.layer addSublayer:_animationLayer];
    
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    _link.paused = true;
    
    _tipLb = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 190, 90)];
    [_tipLb setText:self.tipStr];
    [_tipLb setTextColor:RGB(100, 100, 100)];
    [_containerView.contentView addSubview:_tipLb];
    
}

-(void)displayLinkAction{
    _progress += [self speed];
    if (_progress >= 1) {
        _progress = 0;
    }
    [self updateAnimationLayer];
}

-(void)updateAnimationLayer{
    _startAngle = -M_PI_2;
    _endAngle = -M_PI_2 +_progress * M_PI * 2;
    if (_endAngle > M_PI) {
        CGFloat progress1 = 1 - (1 - _progress)/0.25;
        _startAngle = -M_PI_2 + progress1 * M_PI * 2;
    }
    CGFloat radius = _animationLayer.bounds.size.width/2.0f - lineWidth/2.0f;
    CGFloat centerX = _animationLayer.bounds.size.width/2.0f;
    CGFloat centerY = _animationLayer.bounds.size.height/2.0f;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY) radius:radius startAngle:_startAngle endAngle:_endAngle clockwise:true];
    path.lineCapStyle = kCGLineCapRound;
    
    _animationLayer.path = path.CGPath;
}

-(CGFloat)speed{
    if (_endAngle > M_PI) {
        return 0.3/60.0f;
    }
    return 2/60.0f;
}

-(void)startLoading{
    _link.paused = false;
}

-(void)stopLoading{
    _link.paused = true;
    _progress = 0;
}

+(CircleLoading *)showCircleInView:(UIView *)view andTip:(NSString *)tip{
    [self hideCircleInView:view];
    CircleLoading *loading = [[CircleLoading alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
    loading.tipStr = tip;
    [loading initUI];
    [view addSubview:loading];
    loading.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    [loading startLoading];
    return loading;
}

+(CircleLoading *)hideCircleInView:(UIView *)view{
    CircleLoading *hud = nil;
    for (CircleLoading *loading in view.subviews) {
        if ([loading isKindOfClass:[CircleLoading class]]) {
            [loading stopLoading];
            [loading removeFromSuperview];
            hud = loading;
        }
    }
    return hud;
}

//显示横屏的加载框
+(CircleLoading *)showCircleInView:(UIView*)view andTipH:(NSString *)tip{
    [self hideCircleInView:view];
    CircleLoading *loading = [[CircleLoading alloc] initWithFrame:CGRectMake(0, 0, iPhoneHeight, iPhoneWidth)];
    loading.tipStr = tip;
    [loading initUIH];
    [view addSubview:loading];
    loading.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    [loading startLoading];
    return loading;
}

//显示横屏的UI
-(void)initUIH{
    _containerView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    _containerView.frame = CGRectMake(0, 0, 250, 90);
    _containerView.backgroundColor = [UIColor whiteColor];
    _containerView.center = CGPointMake(iPhoneHeight/2.0f, iPhoneWidth/2.0f);
    _containerView.layer.cornerRadius = 10.0f;
    _containerView.layer.masksToBounds = true;
    
    [self addSubview:_containerView];
    
    _circleContainer = [[UIView alloc]init];
    _circleContainer.frame = CGRectMake(0, 5, 40, 40);
    _circleContainer.backgroundColor = [UIColor clearColor];
    _circleContainer.center = CGPointMake(30, _containerView.bounds.size.height/2.0f);
    _circleContainer.layer.masksToBounds = true;
    [_containerView.contentView addSubview:_circleContainer];
    
    
    _animationLayer = [CAShapeLayer layer];
    _animationLayer.bounds = CGRectMake(0, 0, 40, 40);
    _animationLayer.position = CGPointMake(_circleContainer.bounds.size.width/2.0f, _circleContainer.bounds.size.height/2.0);
    _animationLayer.fillColor = [UIColor clearColor].CGColor;
    _animationLayer.strokeColor = MAIN_COLOR.CGColor;
    _animationLayer.lineWidth = lineWidth;
    _animationLayer.lineCap = kCALineCapRound;
    [_circleContainer.layer addSublayer:_animationLayer];
    
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    _link.paused = true;
    
    _tipLb = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 190, 90)];
    [_tipLb setText:self.tipStr];
    [_tipLb setTextColor:RGB(100, 100, 100)];
    [_containerView.contentView addSubview:_tipLb];
    
}

@end
