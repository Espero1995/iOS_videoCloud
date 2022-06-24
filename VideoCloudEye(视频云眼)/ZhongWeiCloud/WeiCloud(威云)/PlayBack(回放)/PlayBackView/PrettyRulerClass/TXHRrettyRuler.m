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
#define SECONDLENGTH  0.016666666667

@interface TXHRrettyRuler ()
@property (nonatomic,assign)float step;
@property (nonatomic,assign)BOOL refreshTime;
@property (nonatomic,copy)NSString * chooseTimeManually;

@end
@implementation TXHRrettyRuler {
    TXHRulerScrollView * rulerScrollView;
    NSInteger _minutes;
    CGFloat _minValue;
    BOOL _isLogTime;
    CGFloat _totalScale;
    //时间所占全天的比例
    CGFloat biLi;
    //记录当前的时间
    NSString *currentClock;
    //第一次标记时间
    int firstClockTime;
}
- (TimeView *)timeViewnew
{
    if (!_timeViewnew) {
        _timeViewnew = [TimeView viewFromXib];
        _timeViewnew.frame = CGRectMake((iPhoneWidth-40-70)/2, 37, 70, 20);
    }
    return _timeViewnew;
}
- (NSString *)chooseTimeManually
{
    if (!_chooseTimeManually) {
        _chooseTimeManually = [NSString stringWithFormat:@""];
    }
    return _chooseTimeManually;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        rulerScrollView = [self rulerScrollView];
        rulerScrollView.rulerHeight = frame.size.height;
        rulerScrollView.rulerWidth = frame.size.width;
        
        _isLogTime = YES;
        _step = 0;
        //添加缩放手势
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        [self addGestureRecognizer:pinch];
          _totalScale = 1.0;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTimeLabel:) name:RETURNTIMESTAMP object:nil];
    }
    return self;
}
- (void)setCurrentValue:(CGFloat)currentValue
{
    _currentValue = currentValue;

    rulerScrollView.moveValue = currentValue;

}
//背景刻度
- (void)setBeginTime:(CGFloat)beginTime EndTime:(CGFloat)endTime Minutes:(NSInteger)minutes
{
    if (beginTime>=0) {
        CGFloat beginCount = beginTime/minutes;
        CGFloat endCount = endTime/minutes;
//        NSLog(@"2=======开始点：%f 结束点：%lf",beginTime,endTime);
        [rulerScrollView drawBackViewStartCount:beginCount EndCount:endCount];
    }
}
- (void)setTimeMiao:(int)timeMiao
{
    
    NSLog(@"timeMiao:%d",timeMiao);
    _timeMiao = timeMiao;
    
    //时间戳转date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSDate *nowDate = [NSDate dateWithTimeIntervalSince1970:timeMiao];
    currentClock = [formatter stringFromDate:nowDate];


    NSDate *date=[NSDate dateWithTimeIntervalSince1970:timeMiao];
    //0时刻的date字符串
    NSDateFormatter *zeroClockformatter = [[NSDateFormatter alloc] init];
    [zeroClockformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *zeroClockStr = [NSString stringWithFormat:@"%@ %@",[zeroClockformatter stringFromDate:date],@"00:00:00"];

    NSDateFormatter *zeroClockformatter1 = [[NSDateFormatter alloc] init];
    [zeroClockformatter1 setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *zeroClcokDate = [zeroClockformatter1 dateFromString:zeroClockStr];
    NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[zeroClcokDate timeIntervalSince1970]];
    int beginTimeInt = [dateStr intValue];
    
    biLi = (timeMiao-beginTimeInt)/86400.00;
 
}
- (void)setLevelCount:(float)levelCount
{
    // NSLog(@"前===levelCount:%f",levelCount);
    _levelCount = levelCount;
    [self showRulerScrollViewWithCount:24 * levelCount average:[NSNumber numberWithFloat:1] currentValue:0.0f smallMode:YES LabCount:3 Minutes:60/levelCount LineCount:3 bIsPinch:YES];
    NSLog(@"后===levelCount:%f",levelCount);
    [self drawArrayBackView:60/levelCount];

    /*
    switch (levelCount) {
        case 0:
            [self showRulerScrollViewWithCount:24 average:[NSNumber numberWithFloat:1] currentValue:0.0f smallMode:YES LabCount:3 Minutes:60 LineCount:3 bIsPinch:YES];
            [self drawArrayBackView:60];
            break;
        case 1:
            [self showRulerScrollViewWithCount:48 average:[NSNumber numberWithFloat:1] currentValue:0.0f smallMode:YES LabCount:3 Minutes:30 LineCount:3 bIsPinch:YES];
            [self drawArrayBackView:30];
            break;
        case 2:
            [self showRulerScrollViewWithCount:96 average:[NSNumber numberWithFloat:1] currentValue:0.0f smallMode:YES LabCount:3 Minutes:15 LineCount:3 bIsPinch:YES];
            [self drawArrayBackView:15];
            break;
        case 3:
            [self showRulerScrollViewWithCount:288 average:[NSNumber numberWithFloat:1] currentValue:0.0f smallMode:YES LabCount:3 Minutes:5 LineCount:3 bIsPinch:YES];
            [self drawArrayBackView:5];
            break;
        case 4:
            [self showRulerScrollViewWithCount:720 average:[NSNumber numberWithFloat:1] currentValue:0.0f smallMode:YES LabCount:3 Minutes:2 LineCount:3 bIsPinch:YES];
            [self drawArrayBackView:2];
            break;
        default:
            break;
    }
     */
}
//绘制标尺上面有录像的的部分
- (void)drawArrayBackView:(NSInteger)minutes
{
    if (self.timeArr.count!=0) {

        for (int i = 0; i<self.timeArr.count; i++) {
            ZCVideoTimeModel *timeModel = self.timeArr[i];
//            NSLog(@"1=======开始时间：%f 结束时间：%lf分钟：%ld",timeModel.benginTime,timeModel.endTime,(long)minutes);
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
    [UIView animateWithDuration:0 animations:^{
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
    CGFloat nowCount = count *biLi ;
    CGFloat moveOffSetX = nowCount *DISTANCEVALUE;
    CGFloat endOffSet = rulerScrollView.contentOffset.x+moveOffSetX;
    
    CGPoint rulerSize = rulerScrollView.contentOffset;
    rulerSize.x = endOffSet;
    [rulerScrollView setContentOffset:rulerSize];
}
- (void)showRulerScrollViewWithCount:(NSUInteger)count
                             average:(NSNumber *)average
                        currentValue:(CGFloat)currentValue
                           smallMode:(BOOL)mode LabCount:(NSInteger)labCount Minutes:(NSInteger)minutes LineCount:(NSInteger)lineCount bIsPinch:(BOOL)pinch{
    NSAssert(rulerScrollView != nil, @"***** 调用此方法前，请先调用 initWithFrame:(CGRect)frame 方法初始化对象 rulerScrollView\n");
    NSAssert(currentValue < [average floatValue] * count, @"***** currentValue 不能大于直尺最大值（count * average）\n");
    rulerScrollView.rulerAverage = average;
    rulerScrollView.rulerCount = count;
    rulerScrollView.mode = mode;
    _isLogTime = NO;
    [rulerScrollView drawRuler:lineCount];
    _isLogTime = YES;
    [UIView animateWithDuration:0 animations:^{
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
    CGFloat nowCount = count *biLi ;
    CGFloat moveOffSetX = nowCount *DISTANCEVALUE;
    CGFloat endOffSet = rulerScrollView.contentOffset.x+moveOffSetX;
    
    CGPoint rulerSize = rulerScrollView.contentOffset;
    rulerSize.x = endOffSet;
//    if (!pinch) {
//        [rulerScrollView setContentOffset:rulerSize];
//    }
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

- (void)refreshTimeLabel:(NSNotification *)noti
{
    
    if (noti) {
        NSString * timeStampString = [NSString stringWithFormat:@"%@",[noti.userInfo objectForKey:@"TimeStamp"]];
        NSLog(@"%@",timeStampString);
    }
    
    
    
    //这里暂时注释，因为跟走时间轴有点问题。
//    if (noti) {
//        NSString * timeStampString = [NSString stringWithFormat:@"%@",[noti.userInfo objectForKey:@"TimeStamp"]];
//        // iOS 生成的时间戳是10位
//        NSTimeInterval interval    = [timeStampString doubleValue] / 1000.0;
//        NSDate *date               = [NSDate dateWithTimeIntervalSince1970:interval];
//        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateFormat:@"HH:mm:ss"];//yyyy-MM-dd
//        NSString *dateString       = [formatter stringFromDate: date];
//        dispatch_async(dispatch_get_main_queue(),^{
//            self.timeViewnew.lab_time.text = [NSString stringWithFormat:@"%@",dateString];
//
//            NSInteger zonghms = [self calculateTimeSeconds:dateString];
////            NSLog(@"选择时机：%@",self.chooseTimeManually);
//            NSInteger chooseTime = [self calculateTimeSeconds:self.chooseTimeManually];
//
//
//
//            CGFloat rul = 0;
//            float TotalMiaoAllDay = 86400;
//            float timeUp = 0;
//            if (_levelCount) {
//
//            }
//            /*
//            switch (_levelCount) {
//                case 0: rul = 24,timeUp = SECONDLENGTH;
//                    break;
//                case 1: rul = 48,timeUp = SECONDLENGTH * 2;
//                    break;
//                case 2: rul = 96,timeUp = SECONDLENGTH * 4;
//                    break;
//                case 3: rul = 288,timeUp = SECONDLENGTH * 12;
//                    break;
//                case 4: rul = 720,timeUp = SECONDLENGTH *30;
//                    break;
//
//                default:
//                    break;
//            }
//             */
//            /*
//            CGFloat rulheight = self.rulerScrollView.width;
//            CGFloat rulerHeight =  [UIScreen mainScreen].bounds.size.width - 20 * 2;
//
//            float bili = zonghms / TotalMiaoAllDay;
//            float chushibili = chooseTime / TotalMiaoAllDay;
//            float currentX = bili * rul;
//            if (_refreshTime) {
//                _step = currentX; //chushibili * rul/currentX
//            }
//            _step = _step + timeUp;
//            NSLog(@"当前时间的秒数：%ld====比例是：%f===currentX:%f=rulerHeight:%f ====rulheight:%f===rul:%f==step：%f",(long)zonghms,bili,currentX,rulerHeight,rulheight,rul,_step);
//
////            CGPoint rulerSize = rulerScrollView.contentOffset;
////            rulerSize.x = _step;
//
//
//            CGPoint rulerSize = rulerScrollView.contentOffset;
//
//            CGFloat moveOffSetX = currentX *DISTANCEVALUE;
//            NSLog(@"moveOffSetX:%f",moveOffSetX);
//            CGFloat endOffSet = moveOffSetX - 160;//160*(_levelCount+1)
//            rulerSize.x = endOffSet;
//            [rulerScrollView setContentOffset:rulerSize];
//            */
////            NSLog(@"rulerSize2222:%f",rulerScrollView.contentOffset.x);
//
//        });
//
//        NSLog(@"服务器返回的时间戳对应的时间是:%@",dateString);
//    }
}

- (NSInteger)calculateTimeSeconds:(NSString *)dateString
{
    NSInteger zonghms = 0;
//    NSLog(@"这个dateString内容是:%@",dateString);
    if (dateString) {
        NSArray *array = [dateString componentsSeparatedByString:@":"]; //从字符A中分隔成2个元素的数组
//        NSLog(@"这个测试数组内容是:%@",array);
        if (array.count != 1) {
            NSString *HH = array[0];
            NSString *MM= array[1];
            NSString *ss = array[2];
            NSInteger h = [HH integerValue];
            NSInteger m = [MM integerValue];
            NSInteger s = [ss integerValue];
            zonghms = h*3600 + m*60 +s;
        }else{
            NSLog(@"有空值！");
            zonghms = 0;
        }
    }
    return zonghms;
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
    NSString *strrrrrrr;
    if (firstClockTime == 0) {
        strrrrrrr = currentClock;
        firstClockTime = 1;
    }else{
        strrrrrrr = [NSString stringWithFormat:@"%@:%@:%@",hourStr,minutesStr,mouseStr];
    }
    
    self.timeViewnew.lab_time.text = strrrrrrr;
    self.chooseTimeManually = strrrrrrr;
    _refreshTime = YES;
}
#pragma mark ===== scrollview 代理 ======
- (void)scrollViewWillBeginDragging:(TXHRulerScrollView *)scrollView
{
    NSLog(@"时间轴滑动:1");
//    if (self.rulerDeletate && [self.rulerDeletate respondsToSelector:@selector(endPlaying)])
//    {
//        [self.rulerDeletate endPlaying];
//    }
}

- (void)scrollViewWillEndDragging:(TXHRulerScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
     NSLog(@"时间轴滑动:2");
    
}
- (void)scrollViewDidEndDragging:(TXHRulerScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"时间轴滑动:3 decelerate:%@",decelerate?@"YES":@"NO");
    //    [self animationRebound:scrollView];
    CGFloat rulerAverageValue = scrollView.rulerValue;
    CGFloat minValue = rulerAverageValue*_minutes;
    _minValue = minValue;
    if (decelerate == NO) {
        if (self.rulerDeletate && [self.rulerDeletate respondsToSelector:@selector(reloadTimePlay)])
        {
            [SXLReachability SXL_hasNetwork:^(ReachabilityStatus netStatus) {
                if (netStatus == ReachabilityStatusReachableViaWWAN) {
                   // [self.rulerDeletate netWorkAlert];
                   // [Toast showInfo:netWorkReminder];
                    [self.rulerDeletate reloadTimePlay];
                }else{
                    [self.rulerDeletate reloadTimePlay];
                }
            }];
        }
    }
}




- (void)scrollViewWillBeginDecelerating:(TXHRulerScrollView *)scrollView
{
     NSLog(@"时间轴滑动:4");
     [scrollView setContentOffset:scrollView.contentOffset animated:NO];
}
- (void)scrollViewDidEndDecelerating:(TXHRulerScrollView *)scrollView
{
     NSLog(@"时间轴滑动:5");
   // [self animationRebound:scrollView];
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
    //if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGFloat scale = recognizer.scale;
        NSLog(@"放大倍数======= %f",scale);
        self.levelCount = scale;
        
//        if (scale > 1.1) {
//            self.levelCount = scale;
//            if (self.levelCount > 4) {
//            }
//           // scale = 1.0;
//            return;
//        }
//        if (scale < 0.9) {
//            self.levelCount = scale;
//            if (self.levelCount < 0) {
//            }
//           // scale = 1.0;
//            return;
//        }
        
        
        
        
//        if(scale > 1.2){
//            self.levelCount +=1;
//            if (self.levelCount>4) {
//                self.levelCount = 4;
//            }
//            recognizer.scale = 1.0;
//            return;
//        }
//        //缩小情况
//        if (scale < 0.8) {
//            self.levelCount -=1;
//            if (self.levelCount<0) {
//                self.levelCount = 0;
//            }
//            recognizer.scale = 1.0;
//            return;
//        }
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
