//
//  GLFRulerControl.m
//  timeRuler
//
//  Created by 高凌峰 on 2018/6/21.
//  Copyright © 2018年 苏旋律. All rights reserved.
//

#import "GLFRulerControl.h"
#import "ZCVideoTimeModel.h"//处理录像时间段的model数组
/* 小刻度间距默认值*/
#define kMinorScaleDefaultSpacing 8.0

/* 主刻度长度默认值*/
#define kMajorScaleDefaultLength    25.0

/* 中间刻度长度默认值*/
#define kMiddleScaleDefaultLength   15.0

/* 小刻度长度默认值*/
#define kMinorScaleDefaultLength    10.0

/* 刻度尺背景颜色默认值*/
#define kRulerDefaultBackgroundColor    ([UIColor clearColor])

/* 刻度颜色默认值*/
#define kScaleDefaultColor          ([UIColor lightGrayColor])

/* 刻度字体颜色默认值*/
#define kScaleDefaultFontColor      ([UIColor darkGrayColor])

/* 刻度字体默认值*/
#define kScaleDefaultFontSize       10.0

/* 指示器默认颜色*/
#define kIndicatorDefaultColor      ([UIColor redColor])

/* 指示器长度默认值*/
#define kIndicatorDefaultLength     40.0

/* 需要显示的视频的背景颜色默认值*/
#define kDisplayDefaultBackgroundColor      ([UIColor orangeColor])

@interface GLFRulerControl() <UIScrollViewDelegate>

@end

@implementation GLFRulerControl
{
    UIScrollView *_scrollView;
    UIImageView *_rulerImageView;
    UIView *_indicatorView;
    NSInteger selectedTime_Second;
}

#pragma mark - 构造函数
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_rulerImageView.image == nil) {
        [self reloadRuler];
    }

    CGSize size = self.bounds.size;
    _indicatorView.frame = CGRectMake(size.width * 0.5, size.height - self.indicatorLength, 1, self.indicatorLength);
    
    // 设置滚动视图内容间距
    CGSize textSize = [self maxValueTextSize];
    CGFloat offset = size.width * 0.5 - textSize.width;
    _scrollView.contentInset = UIEdgeInsetsMake(0, offset, 0, offset);
}

#pragma mark - 绘制标尺相关方法
/**
 * 刷新标尺
 */
- (void)reloadRuler {
    UIImage *image = [self rulerImage];
    
    if (image == nil) {
        return;
    }
    _rulerImageView.image = image;
    _rulerImageView.backgroundColor = self.rulerBackgroundColor;
    
    [_rulerImageView sizeToFit];
    _scrollView.contentSize = _rulerImageView.image.size;
    
    // 水平标尺靠下对齐
    CGRect rect = _rulerImageView.frame;
    //rect.origin.y = _scrollView.bounds.size.height - _rulerImageView.image.size.height;
    _rulerImageView.frame = rect;
    
    // 更新初始值
   // self.selectedValue = _selectedValue;
}

/**
 * 生成标尺图像
 */
- (UIImage *)rulerImage {
    
    // 1. 常数计算
    CGFloat steps = [self stepsWithValue:_maxValue];
    if (steps == 0) {
        return nil;
    }
    
    // 水平方向绘制图像的大小
    CGSize textSize = [self maxValueTextSize];
    CGFloat height = self.majorScaleLength + textSize.height + 2 * self.minorScaleSpacing;
    CGFloat startX = textSize.width;
    CGRect rect = CGRectMake(0, 0, steps * self.minorScaleSpacing + 2 * startX, height);
    
    // 2. 绘制图像
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    // 1> 绘制刻度线
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    for (NSInteger i = _minValue; i <= _maxValue; i += _valueStep) {
       // NSLog(@"绘制刻度线   i:%ld == minValue:%ld === maxValue:%ld === ValueStep:%ld",(long)i,(long)_minValue,(long)_maxValue,(long)_valueStep);
        // 绘制主刻度
        CGFloat x = (i - _minValue) / _valueStep * self.minorScaleSpacing * self.stepPerHour + startX;
        [path moveToPoint:CGPointMake(x, height)];
        [path addLineToPoint:CGPointMake(x, height - self.majorScaleLength)];//从x，heigh点画到x，height - self.majorScaleLength点，也就是往上画self.majorScaleLength长度  全长- 2 * self.minorScaleSpacing - textSize.height
        if (_maxValue % i == 0 && _maxValue / i == 1) {
            break;
        }
        // 绘制小刻度线
        for (NSInteger j = 1; j < self.stepPerHour; j++) {
            CGFloat scaleX = x + j * self.minorScaleSpacing;
            [path moveToPoint:CGPointMake(scaleX, height)];
            CGFloat scaleY = height - ((j == self.stepPerHour / 2) ? self.middleScaleLength : self.minorScaleLength);
            [path addLineToPoint:CGPointMake(scaleX, scaleY)];
        }
    }
    [self.scaleColor set];
    [path stroke];
    
    //绘制时间刻度值
    NSDictionary * strAttributes = [self scaleTextAttributes];
    for (NSInteger i = _minValue;i <= _maxValue; i += _valueStep) {
 
        CGFloat minuteValue = i * self.stepPerHour;

        double tempTimeValue = fmod(minuteValue, 60);
       // NSLog(@"tempTimeValue:%f====times：%ld",tempTimeValue,(long)i);
        NSString *str;
        if (tempTimeValue == 0) {
            str = [NSString stringWithFormat:@"%d:00",(int)minuteValue/60];
        }else{
            str = [NSString stringWithFormat:@"%d:%.2d",(int)minuteValue/60,(int)tempTimeValue];
        }
        CGRect strRect = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:strAttributes
                                           context:nil];
        strRect.origin.x = (i - _minValue) / _valueStep * self.minorScaleSpacing * self.stepPerHour + startX - strRect.size.width * 0.5;//字体宽度：strRect.size.width
        strRect.origin.y = 8;

        [str drawInRect:strRect withAttributes:strAttributes];
    }
    
    [self drawVideoBgViewWithArray:nil];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

/**
 * 计算最小值和指定 value 之间的步长，即：绘制刻度的总数量
 */
- (CGFloat)stepsWithValue:(CGFloat)value {
    
    if (_minValue >= value || _valueStep <= 0) {
        return 0;
    }
    
    return (value - (CGFloat)_minValue) / _valueStep * self.stepPerHour ;
}

/**
 * 以水平绘制方向计算 `最大数值的文字` 尺寸
 */
- (CGSize)maxValueTextSize {
    
    NSString *scaleText = @(self.maxValue).description;
    
    CGSize size = [scaleText boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:[self scaleTextAttributes]
                                          context:nil].size;
    
    return CGSizeMake(floor(size.width), floor(size.height));
}

/**
 * 文本属性字典
 */
- (NSDictionary *)scaleTextAttributes {
    
    CGFloat fontSize = self.scaleFontSize * [UIScreen mainScreen].scale * 0.5;
    
    return @{NSForegroundColorAttributeName: self.scaleFontColor,
             NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
}

/**
 * 通过传入的时间段，画出相应时间的背景颜色
 */
- (void)drawVideoBgViewWithArray:(NSArray *)timeArr
{
    if (timeArr.count != 0) {
        for (int i = 0; i < timeArr.count; i++) {
            ZCVideoTimeModel *timeModel = timeArr[i];
            CGFloat endCount = timeModel.endTime / 3600.00 * _valueStep;//这里的count代表的是大格式，每一大格子是1h
            CGFloat startCount = timeModel.benginTime / 3600.00 * _valueStep;
           // NSLog(@"1=======【新写】开始时间：%f 结束时间：%lf === endCount：%f startCount：%f",timeModel.benginTime,timeModel.endTime,endCount,startCount);

            CGSize textSize = [self maxValueTextSize];
            CGFloat height = self.majorScaleLength + textSize.height + 2 * self.minorScaleSpacing;
            CGFloat spacing = self.minorScaleSpacing;
            CGFloat endSteps_x = 0;
            CGFloat startSteps_x = 0;
            // 计算偏移量
            CGFloat endSteps = [self stepsWithValue:endCount];
            CGFloat startSteps = [self stepsWithValue:startCount];
            endSteps_x = textSize.width + endSteps * spacing;
            startSteps_x = textSize.width + startSteps * spacing;
            CGFloat backViewW = (endSteps_x - startSteps_x);
          //  NSLog(@"时间轴背景：endSteps == %f == startSteps:%f == endSteps_x:%f == startSteps_x:%f == backViewW:%f",endSteps,startSteps,endSteps_x,startSteps_x,backViewW);
            UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(startSteps_x , height , backViewW , self.majorScaleLength)];
            backView.backgroundColor = self.displayBackgroundColor;
            [_scrollView addSubview:backView];
        }
    }
}

#pragma mark - 设置界面
- (void)setupUI
{
    // 滚动视图
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    
    [self addSubview:_scrollView];
    
    // 标尺图像
    _rulerImageView = [[UIImageView alloc] init];
    
    [_scrollView addSubview:_rulerImageView];
    
    // 指示器视图
    _indicatorView = [[UIView alloc] init];
    _indicatorView.backgroundColor = self.indicatorColor;
    
    [self addSubview:_indicatorView];
}


#pragma mark - 设置属性
- (void)setIndicatorColor:(UIColor *)indicatorColor {
    _indicatorView.backgroundColor = indicatorColor;
}

- (void)setSelectedValue:(CGFloat)selectedValue {
    if (selectedValue < _minValue || selectedValue > _maxValue || _valueStep <= 0) {
        return;
    }

    _selectedValue = selectedValue;
    [self sendActionsForControlEvents:UIControlEventValueChanged];

    CGFloat spacing = self.minorScaleSpacing;
    CGSize size = self.bounds.size;
    CGSize textSize = [self maxValueTextSize];
    CGFloat offset = 0;

    // 计算偏移量
    CGFloat steps = [self stepsWithValue:selectedValue];

    offset = size.width * 0.5 - textSize.width - steps * spacing;
    
    _scrollView.contentOffset = CGPointMake(-offset, 0);
}

- (void)setIndicatorCurrentTime:(int)indicatorCurrentTime
{
    _indicatorCurrentTime = indicatorCurrentTime;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    NSString * tempIndicatorCurrentTime_zeroStr = [self timeStampSwitchTime:indicatorCurrentTime andFormatter:@"YYYY-MM-dd HH:mm:ss" IsTenBit:YES];
    NSString * tempTimeToSwitch = [tempIndicatorCurrentTime_zeroStr substringToIndex:10];
    NSString * timeToSwitch = [NSString stringWithFormat:@"%@ 00:00:00",tempTimeToSwitch];
    int appointedTimeStamp = [self timeSwitchTimeStamp:timeToSwitch andFormatter:@"YYYY-MM-dd HH:mm:ss"];
    int timeDifference = [self getTwoTimeStampDifferenceStartTime:appointedTimeStamp EndTime:indicatorCurrentTime];
    CGFloat currentTime_hour = (CGFloat)(timeDifference/3600.00);
    CGFloat selectedValue = currentTime_hour * _valueStep;
    
    CGFloat offset = 0;
    CGSize size = self.bounds.size;
    CGSize textSize = [self maxValueTextSize];
    CGFloat spacing = self.minorScaleSpacing;
    // 计算偏移量
    CGFloat steps = [self stepsWithValue:selectedValue];
    offset = size.width * 0.5 - textSize.width - steps * spacing;
    _scrollView.contentOffset = CGPointMake( - offset, 0);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {

    //不用悬停在最近的一个小标度上。
//    CGFloat spacing = self.minorScaleSpacing;
//    CGSize size = self.bounds.size;
//    CGSize textSize = [self maxValueTextSize];
//
//    CGFloat offset = targetContentOffset->x + size.width * 0.5 - textSize.width;
//    NSInteger steps = (NSInteger)(offset / spacing + 0.5);
//
//    targetContentOffset->x = -(size.width * 0.5 - textSize.width - steps * spacing) - 0.5;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!(scrollView.isDragging || scrollView.isTracking || scrollView.isDecelerating)) {
        return;
    }
 
    CGFloat spacing = self.minorScaleSpacing;
    CGSize size = self.bounds.size;
    CGSize textSize = [self maxValueTextSize];
    
    CGFloat offset = 0;
    
    offset = scrollView.contentOffset.x + size.width * 0.5 - textSize.width;

    CGFloat steps = (CGFloat)(offset / spacing + 0.5);
   // CGFloat value = _minValue + steps * _valueStep / 10.0;
    
    CGFloat value = _minValue + steps * _valueStep;//这个value就是时间轴的分钟
    selectedTime_Second = (NSInteger)(value*60);

    double tempShowTimeValue = fmod(value, 60);
   // NSLog(@"tempTimeValue:%f",tempShowTimeValue);
    NSString *str;
    if (tempShowTimeValue == 0) {
        str = [NSString stringWithFormat:@"%d:00",(int)value/60];
    }else{
        str = [NSString stringWithFormat:@"%d:%.2d",(int)value/60,(int)tempShowTimeValue];
    }
   // NSLog(@"时间上：%@ === selectedTime_Second：%ld == value/10:%f ==min:%ld ==max:%ld",str,(long)selectedTime_Second,value/10,(long)_minValue,(long)_maxValue);
    if (value/10 != _selectedValue && (value/10 >= _minValue * 12 && value/10 <= _maxValue * 12)) {//这里对比的分钟数
        _selectedValue = value;
        _showTime = str;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
   // NSLog(@"scrollViewDidScroll");
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    if (self.GlfRulerDelegate && [self.GlfRulerDelegate respondsToSelector:@selector(btnStartClick:)])
//    {
//        [self.GlfRulerDelegate stopCurrentVideo];
//    }
  //  NSLog(@"scrollViewWillBeginDragging");
   // [[NSNotificationCenter defaultCenter] removeObserver:self name:RETURNTIMESTAMP object:nil];
    
    if (self.GlfRulerDelegate && [self.GlfRulerDelegate respondsToSelector:@selector(stopReceiveRefreshTimeNoti)])
    {
        [self.GlfRulerDelegate stopReceiveRefreshTimeNoti];
    }
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    if (self.GlfRulerDelegate && [self.GlfRulerDelegate respondsToSelector:@selector(reloadTimePlay)])
//    {
//        [self.GlfRulerDelegate reloadTimePlay];
//    }
//    NSLog(@"scrollViewDidEndDecelerating");
//}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
   // NSLog(@"scrollViewDidEndScrollingAnimation");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            printf("stop");
            [scrollView setContentOffset:scrollView.contentOffset animated:NO];
        });
    }else{
        if (self.GlfRulerDelegate && [self.GlfRulerDelegate respondsToSelector:@selector(reloadTimePlay)])
        {
            BOOL isBeyongLimit = [unitl isBeyondLastVideoListTimeLimit:selectedTime_Second];
            if (!isBeyongLimit) {
                [self.GlfRulerDelegate reloadTimePlay];
            }else
            {
                NSLog(@"当前时间轴时间，超出有录像的最大时间，不予发送播放请求~");
            }
        }
    }
    
    
    
    
   // NSLog(@"%s",__func__);
}

#pragma mark - 工具类方法 - 获取时间相关
- (NSString *)getNowTimeTimestamp{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    return timeSp;
}

//获取当前的时间
- (NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    //NSLog(@"currentTimeString =  %@",currentTimeString);
    
    return currentTimeString;
    
}

/**
 获取当前时间与指定时间的时间戳的差值（秒数）
 
 @param appointedTimeStamp 指定时间时间戳
 @return 差值
 */
- (int)getNowTimeTimestampWithAppointedTimeStampDifference:(int)appointedTimeStamp
{
    int nowTimeTimeStamp = [[self getNowTimeTimestamp] intValue];
    int difference = nowTimeTimeStamp - appointedTimeStamp;
    return difference;
}

/**
 获取2个指定时间的时间戳的差值

 @param startTime 开始时间戳
 @param endTime 结束时间戳
 @return 差值
 */
- (int)getTwoTimeStampDifferenceStartTime:(int)startTime EndTime:(int)endTime
{
    int difference = endTime - startTime;
    return difference;
}

/**
 传入标准指定时间以及指定输出格式，输出当前指定时间时间戳

 @param formatTime 指定时间
 @param format 指定时间的格式 (@"YYYY-MM-dd HH:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
 @return 输出当前指定时间时间戳
 */
- (int)timeSwitchTimeStamp:(NSString *)formatTime andFormatter:(NSString *)format{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format]; //
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate* date = [formatter dateFromString:formatTime]; //-将字符串按formatter转成nsdate
    //时间转时间戳的方法:
    int timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] intValue];
    return timeSp;
}

/**
  传入时间戳以及指定输出格式，输出当前指定时间戳对应的时间

 @param timeStamp 想要转换的时间戳
 @param format 指定时间的格式 (@"YYYY-MM-dd hh:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
 @param tenBit 是否是ios 10位的 时间戳 一般服务器给的是13位的，需要处理
 @return 输出指定时间戳的对应时间
 */
- (NSString *)timeStampSwitchTime:(int)timeStamp andFormatter:(NSString *)format IsTenBit:(BOOL)tenBit
{
    NSTimeInterval interval= tenBit? (timeStamp) : (timeStamp / 1000.0);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:format];
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr;
}

#pragma mark - 属性默认值
- (CGFloat)minorScaleSpacing {
    if (_minorScaleSpacing <= 0) {
        _minorScaleSpacing = kMinorScaleDefaultSpacing;
    }
    return _minorScaleSpacing;
}

- (CGFloat)majorScaleLength {
    if (_majorScaleLength <= 0) {
        _majorScaleLength = kMajorScaleDefaultLength;
    }
    return _majorScaleLength;
}

- (CGFloat)middleScaleLength {
    if (_middleScaleLength <= 0) {
        _middleScaleLength = kMiddleScaleDefaultLength;
    }
    return _middleScaleLength;
}

- (CGFloat)minorScaleLength {
    if (_minorScaleLength <= 0) {
        _minorScaleLength = kMinorScaleDefaultLength;
    }
    return _minorScaleLength;
}

- (UIColor *)rulerBackgroundColor {
    if (_rulerBackgroundColor == nil) {
        _rulerBackgroundColor = kRulerDefaultBackgroundColor;
    }
    return _rulerBackgroundColor;
}

- (UIColor *)scaleColor {
    if (_scaleColor == nil) {
        _scaleColor = kScaleDefaultColor;
    }
    return _scaleColor;
}

- (UIColor *)scaleFontColor {
    if (_scaleFontColor == nil) {
        _scaleFontColor = kScaleDefaultFontColor;
    }
    return _scaleFontColor;
}

- (CGFloat)scaleFontSize {
    if (_scaleFontSize <= 0) {
        _scaleFontSize = kScaleDefaultFontSize;
    }
    return _scaleFontSize;
}

- (UIColor *)indicatorColor {
    if (_indicatorView.backgroundColor == nil) {
        _indicatorView.backgroundColor = kIndicatorDefaultColor;
    }
    return _indicatorView.backgroundColor;
}

- (CGFloat)indicatorLength {
    if (_indicatorLength <= 0) {
        _indicatorLength = kIndicatorDefaultLength;
    }
    return _indicatorLength;
}

- (UIColor *)displayBackgroundColor {
    if (_displayBackgroundColor == nil) {
        _displayBackgroundColor = kDisplayDefaultBackgroundColor;
    }
    return _displayBackgroundColor;
}

@end
