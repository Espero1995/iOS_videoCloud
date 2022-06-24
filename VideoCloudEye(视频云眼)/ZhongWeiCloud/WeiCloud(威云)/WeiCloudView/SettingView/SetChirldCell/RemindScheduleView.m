//
//  RemindScheduleView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/31.
//  Copyright © 2018年 张策. All rights reserved.
//


#import "RemindScheduleView.h"
#define AnimationDuration 1.0f
#define PieFillColor [UIColor clearColor].CGColor
#define LabelLoctionRatio bgRadius

@interface RemindScheduleView()

@property (nonatomic) CAShapeLayer *bgCircleLayer;
@property (nonatomic) CAShapeLayer *pie;
@property (nonatomic,strong) UILabel *tipLb;
@property (nonatomic,strong) UIView *centerPointView;
@end

@implementation RemindScheduleView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        //背景图
        UIImageView *bgImg = [[UIImageView alloc]initWithFrame:frame];
        bgImg.backgroundColor = [UIColor clearColor];
        bgImg.image = [UIImage imageNamed:@"clock"];
        bgImg.layer.zPosition = 10;//优先级最高
        [self addSubview:bgImg];
    }
    return self;
}

//绘制扇形
- (void)drawSectorStartTime:(NSString *)startTime andEndTime:(NSString *)endTime
{
    
    //1.pieView中心点
    CGFloat centerWidth = self.frame.size.width * 0.5f;
    CGFloat centerHeight = self.frame.size.height * 0.5f;
    CGFloat centerX = centerWidth;
    CGFloat centerY = centerHeight;
    CGPoint centerPoint = CGPointMake(centerX, centerY);
    
    //中心点
    self.centerPointView.center = centerPoint;
    [self addSubview:self.centerPointView];
    
    CGFloat radiusBasic = centerWidth > centerHeight ? centerHeight-3 : centerWidth-3;
    //线的半径为扇形半径的一半，线宽是扇形半径，这样就能画出圆形了
    //2.背景路径
    CGFloat bgRadius = radiusBasic * 0.5;
    UIBezierPath *bgPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                          radius:bgRadius
                                                      startAngle:-M_PI_2
                                                        endAngle:M_PI_2 * 3
                                                       clockwise:YES];
    _bgCircleLayer = [CAShapeLayer layer];
    _bgCircleLayer.fillColor   = [UIColor clearColor].CGColor;
    _bgCircleLayer.strokeColor = [UIColor whiteColor].CGColor;
    _bgCircleLayer.strokeStart = 0.0f;
    _bgCircleLayer.strokeEnd   = 1.0f;
    _bgCircleLayer.zPosition   = 1;
    _bgCircleLayer.lineWidth   = bgRadius*2.0f ;
    _bgCircleLayer.path        = bgPath.CGPath;
    
    
    //3.子扇区路径
    CGFloat otherRadius = radiusBasic*0.5;
    UIBezierPath *otherPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                             radius:otherRadius
                                                         startAngle:-M_PI_2
                                                           endAngle:M_PI_2 * 3
                                                          clockwise:YES];
    
    CGFloat start = [self getTimeScaleByHHMM:startTime];
    CGFloat end = [self getTimeScaleByHHMM:endTime];
    
    
    //绘制的图
    [self.layer addSublayer:self.pie];
    if (start<end) {
        _pie.strokeColor = MAIN_COLOR.CGColor;
        _pie.strokeStart = start;
        _pie.strokeEnd   = end;
        _pie.lineWidth   = otherRadius * 2.0f;
        _pie.path        = otherPath.CGPath;
        self.backgroundColor = RGB(200, 200, 200);
        
        //计算百分比tipLb的位置
        CGFloat centerAngle = M_PI * (start + end);
        CGFloat labelCenterX = LabelLoctionRatio * sinf(centerAngle) + centerX;
        CGFloat labelCenterY = -LabelLoctionRatio * cosf(centerAngle) + centerY;
        self.tipLb.frame = CGRectMake(0, 0, radiusBasic+10, 12);
        self.tipLb.center = CGPointMake(labelCenterX, labelCenterY);
        self.tipLb.text = [NSString stringWithFormat:@"%@~%@",startTime,endTime];
        [self addSubview:self.tipLb];
        
    }else{
        _pie.strokeColor = RGB(200, 200, 200).CGColor;
        _pie.strokeStart = end;
        _pie.strokeEnd   = start;
        _pie.lineWidth   = otherRadius * 2.0f;
        _pie.path        = otherPath.CGPath;
        self.backgroundColor = MAIN_COLOR;
        
        //计算百分比tipLb的位置
        CGFloat centerAngle = M_PI * (start + end + 1);
        CGFloat labelCenterX = LabelLoctionRatio * sinf(centerAngle) + centerX;
        CGFloat labelCenterY = -LabelLoctionRatio * cosf(centerAngle) + centerY;
        self.tipLb.frame = CGRectMake(0, 0, radiusBasic+10, 12);
        self.tipLb.center = CGPointMake(labelCenterX, labelCenterY);
        self.tipLb.text = [NSString stringWithFormat:@"%@~%@",startTime,endTime];
        [self addSubview:self.tipLb];
    }
    
    self.layer.mask = _bgCircleLayer;
}


- (void)stroke
{
    //画图动画
    self.hidden = NO;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration  = AnimationDuration;
    animation.fromValue = @0.0f;
    animation.toValue   = @1.0f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = YES;
    [_bgCircleLayer addAnimation:animation forKey:@"circleAnimation"];
}


- (void)dealloc
{
    [self.layer removeAllAnimations];
}


#pragma mark - 根据 HH:MM格式的时间 来获取与总时间24小时的占比值
- (float)getTimeScaleByHHMM:(NSString *)time
{
    float timeScale;
    NSInteger hour = [self getFrontofString:time];
    NSInteger min = [self getBackofString:time];
    timeScale = (hour*60+min)/(24*60.f);
    
    return timeScale;
}

#pragma mark - 取“：”字符串之前的部分并转成NSInterger类型
- (NSInteger)getFrontofString:(NSString *)str
{
    NSRange range = [str rangeOfString:@":"]; //现获取要截取的字符串位置
    NSString * resultStr= [str substringToIndex:range.location]; //截取字符串
    if (resultStr) {
        return  [resultStr integerValue];
    }else{
        return 0;
    }
}

#pragma mark - 取“：”字符串之后的部分并转成NSInterger类型
- (NSInteger)getBackofString:(NSString *)str
{
    NSRange range = [str rangeOfString:@":"]; //现获取要截取的字符串位置
    NSString * resultStr= [str substringFromIndex:range.location+1]; //截取字符串
    if (resultStr) {
        return  [resultStr integerValue];
    }else{
        return 0;
    }
}

# pragma mark - getter && setter
//中心点
- (UIView *)centerPointView
{
    if (!_centerPointView) {
        _centerPointView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 4, 4)];
        _centerPointView.backgroundColor = [UIColor whiteColor];
        _centerPointView.layer.cornerRadius = 2.f;
        _centerPointView.layer.zPosition = 10;
    }
    return _centerPointView;
}
//时间提示
- (UILabel *)tipLb
{
    if (!_tipLb) {
        _tipLb = [[UILabel alloc]init];
        _tipLb.font = FONTB(12);
        _tipLb.textAlignment = NSTextAlignmentCenter;
        _tipLb.textColor = [UIColor whiteColor];
        _tipLb.layer.zPosition = 3;
    }
    return _tipLb;
}

- (CAShapeLayer *)pie
{
    if (!_pie) {
        _pie = [CAShapeLayer layer];
        _pie.fillColor = PieFillColor;
        _pie.zPosition = 1;
    }
    return _pie;
}

@end
