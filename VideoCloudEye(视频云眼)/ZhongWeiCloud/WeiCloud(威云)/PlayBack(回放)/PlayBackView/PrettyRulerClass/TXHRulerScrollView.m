//
//  TXHRulerScrollView.m
//  PrettyRuler
//
//  Created by 张策 on 16/12/11.
//  Copyright © 2016年 张策. All rights reserved.

#import "TXHRulerScrollView.h"
#import "TimeView.h"
@interface TXHRulerScrollView ()
@property (nonatomic,strong)UIView *labBackView;

@end

@implementation TXHRulerScrollView


- (void)setRulerValue:(CGFloat)rulerValue {
    _rulerValue = rulerValue;
}

- (void)setMoveValue:(CGFloat)moveValue
{
    _moveValue = moveValue;
    // 开启最小模式
    if (_mode) {
        UIEdgeInsets edge = UIEdgeInsetsMake(0, self.rulerWidth / 2.f - DISTANCELEFTANDRIGHT, 0, self.rulerWidth / 2.f - DISTANCELEFTANDRIGHT);
        self.contentInset = edge;
        self.contentOffset = CGPointMake(DISTANCEVALUE * (moveValue / [self.rulerAverage floatValue]) - self.rulerWidth + (self.rulerWidth / 2.f + DISTANCELEFTANDRIGHT), 0);
    }
    else
    {
        self.contentOffset = CGPointMake(DISTANCEVALUE * (moveValue / [self.rulerAverage floatValue]) - self.rulerWidth / 2.f + DISTANCELEFTANDRIGHT, 0);
    }
}
- (void)drawLable:(NSInteger)labCount Minutes:(NSInteger)minutes
{
    NSLog(@"self.rulerCount:%lu==labCount:%ld==Minutes:%ld",(unsigned long)self.rulerCount,(long)labCount,minutes);
    for (int i = 0; i <= self.rulerCount; i++)
    {
        if (i%labCount == 0) {
            UILabel *rule = [[UILabel alloc] init];
            rule.textColor = [UIColor colorWithHexString:@"b1b1b1"];
            rule.font = [UIFont systemFontOfSize:10];
            
            CGFloat rulerAverageValue = i*[self.rulerAverage floatValue];
            CGFloat minValue = rulerAverageValue * minutes;
            NSLog(@"我想要知道的数据：====self.rulerAverage：%@ ===rulerAverageValue：%f===minValue：%f",self.rulerAverage,rulerAverageValue,minValue);
            double aaa = fmod (minValue, 60);
            if (aaa == 0) {
                rule.text = [NSString stringWithFormat:@"%d:00",(int)minValue/60];
            }else{
                rule.text = [NSString stringWithFormat:@"%d:%.2d",(int)minValue/60,(int)aaa];
            }
            CGSize textSize = [rule.text sizeWithAttributes:@{ NSFontAttributeName : rule.font }];
            rule.frame = CGRectMake(DISTANCELEFTANDRIGHT + DISTANCEVALUE * i - textSize.width / 2, 0, 0, 0);
            [rule sizeToFit];
            [_labBackView addSubview:rule];
        }
    }
}
- (void)drawRuler:(NSInteger)lineCount {
    //之前添加的lable layer删除
    for (UIView *suberView in self.subviews) {
        if ([suberView isKindOfClass:[UIView class]]) {
            [suberView removeFromSuperview];
        }
    }
    NSArray *tempArray = [NSArray arrayWithArray:self.layer.sublayers];
    [tempArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[CAShapeLayer class]]) {
                [obj removeFromSuperlayer];
        }
    }];
    
    self.contentSize = CGSizeMake(self.rulerCount * DISTANCEVALUE + DISTANCELEFTANDRIGHT * 2.f, self.rulerHeight);
    //labbackview
    _labBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.rulerCount * DISTANCEVALUE + DISTANCELEFTANDRIGHT * 2.f, 20)];
    //_labBackView.backgroundColor = [UIColor colorWithHexString:@"cdcdcd"];//ffffff//调试修改
    [self addSubview:_labBackView];
    
    //上下左右边框
    UIView *lineViewUp = [[UIView alloc]initWithFrame:CGRectMake(DISTANCELEFTANDRIGHT, 19, self.rulerCount * DISTANCEVALUE , 1)];
    lineViewUp.backgroundColor = [UIColor colorWithHexString:@"cdcdcd"];
    [self addSubview:lineViewUp];

    UIView *lineViewDown = [[UIView alloc]initWithFrame:CGRectMake(DISTANCELEFTANDRIGHT, self.rulerHeight-1, self.rulerCount * DISTANCEVALUE , 1)];
    lineViewDown.backgroundColor = [UIColor colorWithHexString:@"cdcdcd"];
    [self addSubview:lineViewDown];
    
    UIView *lineViewRight = [[UIView alloc]initWithFrame:CGRectMake(self.rulerCount * DISTANCEVALUE+DISTANCELEFTANDRIGHT, 20, 1, self.rulerHeight-20)];
    lineViewRight.backgroundColor = [UIColor colorWithHexString:@"cdcdcd"];
    [self addSubview:lineViewRight];
    
    UIView *lineViewLeft = [[UIView alloc]initWithFrame:CGRectMake(DISTANCELEFTANDRIGHT, 20, 1 , self.rulerHeight-20)];
    lineViewLeft.backgroundColor = [UIColor colorWithHexString:@"cdcdcd"];
    [self addSubview:lineViewLeft];
     //上下左右边框
    
    
    CGMutablePathRef pathRef1 = CGPathCreateMutable();
    CGMutablePathRef pathRef2 = CGPathCreateMutable();
    //上面
    CAShapeLayer *shapeLayer1 = [CAShapeLayer layer];
    shapeLayer1.strokeColor = [UIColor lightGrayColor].CGColor;
    shapeLayer1.fillColor = [UIColor clearColor].CGColor;
    shapeLayer1.lineWidth = 1.f;
    shapeLayer1.lineCap = kCALineCapButt;
    
    CAShapeLayer *shapeLayer2 = [CAShapeLayer layer];
    shapeLayer2.strokeColor = [UIColor grayColor].CGColor;
    shapeLayer2.fillColor = [UIColor clearColor].CGColor;
    shapeLayer2.lineWidth = 1.f;
    shapeLayer2.lineCap = kCALineCapButt;
    
    for (int i = 0; i <= self.rulerCount; i++) {
            if (i % lineCount == 0) {
            CGPathMoveToPoint(pathRef2, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i , 20);
            CGPathAddLineToPoint(pathRef2, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i, DISBASE);
        }
        else
        {
            CGPathMoveToPoint(pathRef1, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i , 20);
            CGPathAddLineToPoint(pathRef1, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i, DISBASE - 5);
        }
    }
    
    shapeLayer1.path = pathRef1;
    shapeLayer2.path = pathRef2;
    [self.layer addSublayer:shapeLayer1];
    [self.layer addSublayer:shapeLayer2];

//下面
    CGMutablePathRef pathRef11 = CGPathCreateMutable();
    CGMutablePathRef pathRef22 = CGPathCreateMutable();
    
    CAShapeLayer *shapeLayer11 = [CAShapeLayer layer];
    shapeLayer11.strokeColor = [UIColor lightGrayColor].CGColor;
    shapeLayer11.fillColor = [UIColor clearColor].CGColor;
    shapeLayer11.lineWidth = 1.f;
    shapeLayer11.lineCap = kCALineCapButt;
    
    CAShapeLayer *shapeLayer22 = [CAShapeLayer layer];
    shapeLayer22.strokeColor = [UIColor grayColor].CGColor;
    shapeLayer22.fillColor = [UIColor clearColor].CGColor;
    shapeLayer22.lineWidth = 1.f;
    shapeLayer22.lineCap = kCALineCapButt;
    
    for (int i = 0; i <= self.rulerCount; i++) {
        if (i % lineCount == 0) {
            CGPathMoveToPoint(pathRef22, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i , self.rulerHeight);
            CGPathAddLineToPoint(pathRef22, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i, self.rulerHeight-DISBASE+20);
        }
//        else if (i % 3 == 0) {
//            CGPathMoveToPoint(pathRef11, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i , self.rulerHeight);
//            CGPathAddLineToPoint(pathRef11, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i, self.rulerHeight-DISBASE + 10);
//        }
        else
        {
            CGPathMoveToPoint(pathRef11, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i , self.rulerHeight);
            CGPathAddLineToPoint(pathRef11, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i, self.rulerHeight-DISBASE + 5+20);
        }
    }
    
    shapeLayer11.path = pathRef11;
    shapeLayer22.path = pathRef22;
    
    [self.layer addSublayer:shapeLayer11];
    [self.layer addSublayer:shapeLayer22];

    
    
    
    
    self.frame = CGRectMake(0, 0, self.rulerWidth, self.rulerHeight);
    
    // 开启最小模式
    if (_mode) {
        UIEdgeInsets edge = UIEdgeInsetsMake(0, self.rulerWidth / 2.f - DISTANCELEFTANDRIGHT, 0, self.rulerWidth / 2.f - DISTANCELEFTANDRIGHT);
        self.contentInset = edge;
        self.contentOffset = CGPointMake(DISTANCEVALUE * (self.rulerValue / [self.rulerAverage floatValue]) - self.rulerWidth + (self.rulerWidth / 2.f + DISTANCELEFTANDRIGHT), 0);
    }
    else
    {
        self.contentOffset = CGPointMake(DISTANCEVALUE * (self.rulerValue / [self.rulerAverage floatValue]) - self.rulerWidth / 2.f + DISTANCELEFTANDRIGHT, 0);
    }
}

- (void)drawBackViewStartCount:(CGFloat)startCount EndCount:(CGFloat)endCount
{
    CGFloat endendcount =endCount-startCount;
    NSLog(@"时间轴画背景startCount:%f===endCount:%f==差值：%f",startCount,endCount,endendcount);
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(DISTANCELEFTANDRIGHT + DISTANCEVALUE * startCount, 20,DISTANCEVALUE * endendcount,self.rulerHeight-20 )];
    backView.backgroundColor = [UIColor colorWithHexString:@"eaeaea"];
//    backView.backgroundColor = [UIColor greenColor];
    [self addSubview:backView];
    [self sendSubviewToBack:backView];
}
@end
