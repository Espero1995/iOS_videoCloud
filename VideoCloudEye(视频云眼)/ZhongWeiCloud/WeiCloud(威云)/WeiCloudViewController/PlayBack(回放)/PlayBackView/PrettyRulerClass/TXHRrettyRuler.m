//
//  TXHRrettyRuler.m
//  PrettyRuler
//
//  Created by 张策 on 16/12/11.
//  Copyright © 2016年 张策. All rights reserved.
//  withCount:(NSUInteger)count average:(NSUInteger)average

#import "TXHRrettyRuler.h"
#import "ZCVideoTimeModel.h"

#define SHEIGHT 10 // 中间指示器顶部闭合三角形高度
#define INDICATORCOLOR [UIColor redColor].CGColor // 中间指示器颜色
#define MaxSCale 1.5  //最大缩放比例
#define MinScale 0.5  //最小缩放比例
@implementation TXHRrettyRuler {
    TXHRulerScrollView * rulerScrollView;
    NSInteger _minutes;
    CGFloat _minValue;
    BOOL _isLogTime;
    CGFloat _totalScale;
}
- (TimeView *)timeViewnew
{
    if (!_timeViewnew) {
        _timeViewnew = [TimeView viewFromXib];
        _timeViewnew.frame = CGRectMake((iPhoneWidth-40-70)/2, 37, 70, 20);
    }
    return _timeViewnew;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        rulerScrollView = [self rulerScrollView];
        rulerScrollView.rulerHeight = frame.size.height;
        rulerScrollView.rulerWidth = frame.size.width;
        _isLogTime = YES;
        //添加缩放手势
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        [self addGestureRecognizer:pinch];
          _totalScale = 1.0;
    }
    return self;
}
- (void)setCurrentValue:(CGFloat)currentValue
{
    _currentValue = currentValue;

    rulerScrollView.moveValue = currentValue;

}

- (void)setBeginTime:(CGFloat)beginTime EndTime:(CGFloat)endTime Minutes:(NSInteger)minutes
{
    CGFloat beginCount = beginTime/minutes;
    CGFloat endCount = endTime/minutes;
    [rulerScrollView drawBackViewStartCount:beginCount EndCount:endCount];
}

- (void)setLevelCount:(NSInteger)levelCount
{
    _levelCount = levelCount;
    switch (levelCount) {
        case 0:
           [self showRulerScrollViewWithCount:24 average:[NSNumber numberWithFloat:1] currentValue:0.0f smallMode:YES LabCount:3 Minutes:60 LineCount:3];
            [self drawArrayBackView:60];
            break;
        case 1:
            [self showRulerScrollViewWithCount:48 average:[NSNumber numberWithFloat:1] currentValue:0.0f smallMode:YES LabCount:3 Minutes:30 LineCount:3];
            [self drawArrayBackView:30];
            break;
        case 2:
            [self showRulerScrollViewWithCount:96 average:[NSNumber numberWithFloat:1] currentValue:0.0f smallMode:YES LabCount:3 Minutes:15 LineCount:3];
            [self drawArrayBackView:15];
            break;
        case 3:
            [self showRulerScrollViewWithCount:288 average:[NSNumber numberWithFloat:1] currentValue:0.0f smallMode:YES LabCount:3 Minutes:5 LineCount:3];
            [self drawArrayBackView:5];
            break;
        case 4:
            [self showRulerScrollViewWithCount:720 average:[NSNumber numberWithFloat:1] currentValue:0.0f smallMode:YES LabCount:3 Minutes:2 LineCount:3];
            [self drawArrayBackView:2];
            break;
        default:
            break;
    }
}

- (void)drawArrayBackView:(NSInteger)minutes
{
    if (self.timeArr.count!=0) {

        for (int i = 0; i<self.timeArr.count; i++) {
            ZCVideoTimeModel *timeModel = self.timeArr[i];
            [self setBeginTime:timeModel.benginTime EndTime:timeModel.endTime Minutes:minutes];
        }
    }
}
- (void)showRulerScrollViewWithCount:(NSUInteger)count
                             average:(NSNumber *)average
                        currentValue:(CGFloat)currentValue
                           smallMode:(BOOL)mode LabCount:(NSInteger)labCount Minutes:(NSInteger)minutes LineCount:(NSInteger)lineCount{
    NSAssert(rulerScrollView != nil, @"***** 调用此方法前，请先调用 initWithFrame:(CGRect)frame 方法初始化对象 rulerScrollView\n");
    NSAssert(currentValue < [average floatValue] * count, @"***** currentValue 不能大于直尺最大值（count * average）\n");
    rulerScrollView.rulerAverage = average;
    rulerScrollView.rulerCount = count;
    rulerScrollView.mode = mode;
     _isLogTime = NO;
    [rulerScrollView drawRuler:lineCount];
    _isLogTime = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [rulerScrollView drawLable:labCount Minutes:minutes];
    }];
 
    if (_minValue>0) {
        _isLogTime = NO;
       rulerScrollView.moveValue = _minValue/minutes;
        _isLogTime = YES;
    }
    _minutes = minutes;
    [self addSubview:rulerScrollView];
    [self drawRacAndLine];
    [self addSubview:self.timeViewnew];
}

- (TXHRulerScrollView *)rulerScrollView {
    if (!rulerScrollView) {
        rulerScrollView = [TXHRulerScrollView new];
        rulerScrollView.delegate = self;
        rulerScrollView.showsHorizontalScrollIndicator = NO;
        rulerScrollView.bounces = NO;
    }
    return rulerScrollView;
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(TXHRulerScrollView *)scrollView {
    CGFloat offSetX = scrollView.contentOffset.x + self.frame.size.width / 2 - DISTANCELEFTANDRIGHT;
    CGFloat ruleValue = (offSetX / DISTANCEVALUE) * [scrollView.rulerAverage floatValue];
    if (ruleValue < 0.f) {
        return;
    } else if (ruleValue > scrollView.rulerCount * [scrollView.rulerAverage floatValue]) {
        return;
    }
    if (self.rulerDeletate && [self.rulerDeletate respondsToSelector:@selector(txhTimeStr:MinValue:)]) {
        if (!scrollView.mode) {
            scrollView.rulerValue = ruleValue;
        }
        scrollView.mode = NO;
        if (_isLogTime == YES) {
            [self.rulerDeletate txhRrettyRuler:scrollView];
            CGFloat rulerAverageValue = scrollView.rulerValue;
            CGFloat minValue = rulerAverageValue*_minutes;
            double aaa = fmod (minValue, 60);
            if (aaa == 0) {
                NSString *timeStr = [NSString stringWithFormat:@"%d:00",(int)minValue/60];
                //代理
                [self.rulerDeletate txhTimeStr:timeStr MinValue:minValue];
                //时间显示
                [self timeViewTimeStr:timeStr MinValue:minValue];
            }else{
                NSString *timeStr = [NSString stringWithFormat:@"%d:%.2d",(int)minValue/60,(int)aaa];
                //代理
                [self.rulerDeletate txhTimeStr:timeStr MinValue:minValue];
                //时间显示
                [self timeViewTimeStr:timeStr MinValue:minValue];
            }
        }
    }
}
#pragma mark ------timeView显示时间
- (void)timeViewTimeStr:(NSString *)timeStr MinValue:(CGFloat)minValue
{
    NSString *str = [NSString stringWithFormat:@"%.2f",minValue];
    NSArray *arr = [str componentsSeparatedByString:@"."];
    NSString *min = arr[0];
    
    //小时
    float hour = [min intValue]/60;
    int hourInt;
    hourInt = floor(hour);
    NSString *hourStr = [NSString stringWithFormat:@"%02d",hourInt];
    //分钟
    int minutes =floor(minValue);
    int minutesInt = minutes%60;
    NSString *minutesStr = [NSString stringWithFormat:@"%02d",minutesInt];
    
    //秒
    NSString *strArr = arr[1];
    int mouse = [strArr intValue]*0.6;
    NSString *mouseStr = [NSString stringWithFormat:@"%02d",mouse];
    NSString *strrrrrrr = [NSString stringWithFormat:@"%@:%@:%@",hourStr,minutesStr,mouseStr];
    self.timeViewnew.lab_time.text = strrrrrrr;
}
//停止
- (void)scrollViewDidEndDecelerating:(TXHRulerScrollView *)scrollView {
//    [self animationRebound:scrollView];
    CGFloat rulerAverageValue = scrollView.rulerValue;
    CGFloat minValue = rulerAverageValue*_minutes;
    _minValue = minValue;
}
-(void)scrollViewWillBeginDecelerating: (UIScrollView *)scrollView
{
    [scrollView setContentOffset:scrollView.contentOffset animated:NO];
}
//减速
- (void)scrollViewDidEndDragging:(TXHRulerScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    [self animationRebound:scrollView];
    CGFloat rulerAverageValue = scrollView.rulerValue;
    CGFloat minValue = rulerAverageValue*_minutes;
    _minValue = minValue;
     if (self.rulerDeletate && [self.rulerDeletate respondsToSelector:@selector(reloadTimePlay)])
     {
         [self.rulerDeletate reloadTimePlay];
     }
}
#pragma mark ------捏合手势
- (void)pinch:(UIPinchGestureRecognizer *)recognizer{
//    if (recognizer.state == UIGestureRecognizerStateChanged )
//    {
        CGFloat scale = recognizer.scale;
        NSLog(@"放大倍数======= %f",scale);

        if(scale > 1.2){
            self.levelCount +=1;
            if (self.levelCount>4) {
                self.levelCount = 4;
            }
            recognizer.scale = 1.0;
            return;
        }
        //缩小情况
        if (scale < 0.8) {
            self.levelCount -=1;
            if (self.levelCount<0) {
                self.levelCount = 0;
            }
            recognizer.scale = 1.0;
            return;
        }
}

- (void)animationRebound:(TXHRulerScrollView *)scrollView {
    CGFloat offSetX = scrollView.contentOffset.x + self.frame.size.width / 2 - DISTANCELEFTANDRIGHT;
    CGFloat oX = (offSetX / DISTANCEVALUE) * [scrollView.rulerAverage floatValue];
#ifdef DEBUG
    NSLog(@"ago*****************ago:oX:%f",oX);
#endif
    if ([self valueIsInteger:scrollView.rulerAverage]) {
        oX = [self notRounding:oX afterPoint:0];
    }
    else {
        oX = [self notRounding:oX afterPoint:1];
    }
#ifdef DEBUG
    NSLog(@"after*****************after:oX:%.1f",oX);
#endif
    CGFloat offX = (oX / ([scrollView.rulerAverage floatValue])) * DISTANCEVALUE + DISTANCELEFTANDRIGHT - self.frame.size.width / 2;
    [UIView animateWithDuration:.2f animations:^{
        scrollView.contentOffset = CGPointMake(offX, 0);
    }];
}

- (void)drawRacAndLine {
    // 圆弧
    CAShapeLayer *shapeLayerArc = [CAShapeLayer layer];
    shapeLayerArc.strokeColor = [UIColor lightGrayColor].CGColor;
    shapeLayerArc.fillColor = [UIColor clearColor].CGColor;
    shapeLayerArc.lineWidth = 1.f;
    shapeLayerArc.lineCap = kCALineCapButt;
    shapeLayerArc.frame = self.bounds;
    
    // 渐变
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    
    gradient.colors = @[(id)[[UIColor whiteColor] colorWithAlphaComponent:1.f].CGColor,
                        (id)[[UIColor whiteColor] colorWithAlphaComponent:0.0f].CGColor,
                        (id)[[UIColor whiteColor] colorWithAlphaComponent:1.f].CGColor];
    
    gradient.locations = @[[NSNumber numberWithFloat:0.0f],
                           [NSNumber numberWithFloat:0.6f]];
    
    gradient.startPoint = CGPointMake(0, .5);
    gradient.endPoint = CGPointMake(1, .5);
    
    CGMutablePathRef pathArc = CGPathCreateMutable();
    
    CGPathMoveToPoint(pathArc, NULL, 0, DISTANCETOPANDBOTTOM);
    CGPathAddQuadCurveToPoint(pathArc, NULL, self.frame.size.width / 2, - 20, self.frame.size.width, DISTANCETOPANDBOTTOM);
    
    shapeLayerArc.path = pathArc;
//    [self.layer addSublayer:shapeLayerArc];
//    [self.layer addSublayer:gradient];
    
    // 红色指示器
    CAShapeLayer *shapeLayerLine = [CAShapeLayer layer];
    shapeLayerLine.strokeColor = [UIColor redColor].CGColor;
    shapeLayerLine.fillColor = INDICATORCOLOR;
    shapeLayerLine.lineWidth = 1.f;
    shapeLayerLine.lineCap = kCALineCapSquare;
    
    NSUInteger ruleHeight = 20; // 文字高度
    CGMutablePathRef pathLine = CGPathCreateMutable();
    CGPathMoveToPoint(pathLine, NULL, self.frame.size.width / 2, self.frame.size.height);
    CGPathAddLineToPoint(pathLine, NULL, self.frame.size.width / 2, 20 + SHEIGHT);
    
    CGPathAddLineToPoint(pathLine, NULL, self.frame.size.width / 2 - SHEIGHT / 2, 20);
    CGPathAddLineToPoint(pathLine, NULL, self.frame.size.width / 2 + SHEIGHT / 2, 20);
    CGPathAddLineToPoint(pathLine, NULL, self.frame.size.width / 2, 20 + SHEIGHT);
    
    shapeLayerLine.path = pathLine;
    [self.layer addSublayer:shapeLayerLine];
}

#pragma mark - tool method

- (CGFloat)notRounding:(CGFloat)price afterPoint:(NSInteger)position {
    NSDecimalNumberHandler*roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber*ouncesDecimal;
    NSDecimalNumber*roundedOunces;
    ouncesDecimal = [[NSDecimalNumber alloc]initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [roundedOunces floatValue];
}

- (BOOL)valueIsInteger:(NSNumber *)number {
    NSString *value = [NSString stringWithFormat:@"%f",[number floatValue]];
    if (value != nil) {
        NSString *valueEnd = [[value componentsSeparatedByString:@"."] objectAtIndex:1];
        NSString *temp = nil;
        for(int i =0; i < [valueEnd length]; i++)
        {
            temp = [valueEnd substringWithRange:NSMakeRange(i, 1)];
            if (![temp isEqualToString:@"0"]) {
                return NO;
            }
        }
    }
    return YES;
}




@end
