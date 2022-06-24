//
//  NoTimeShaftRulerView.m
//  TimelineDemo
//
//  Created by Espero on 2019/10/21.
//  Copyright © 2019 Joyware Electronic co., LTD. All rights reserved.
//
#import "NoTimeShaftRulerView.h"

@interface NoTimeShaftRulerView ()
<
    UIScrollViewDelegate
>
{
    float scrollWidth;
}

/**
 * scrollView
 */
@property (nonatomic, strong) UIScrollView *scrollView;

/**
 * timeView
 */
@property (nonatomic, strong) UIView *timeView;

/**
 * 轴线
 */
@property (nonatomic, strong) UIView *shaftLine;

@end


@implementation NoTimeShaftRulerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        scrollWidth = iPhoneWidth;
        [self setUpUI];
    }
    return self;
}


#pragma mark - UI
- (void)setUpUI
{
    self.backgroundColor = [UIColor colorWithWhite:0.93 alpha:1];;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.timeView];
    [self addSubview:self.shaftLine];
    [self addSubview:self.timeLb];
}

/**
 * 滑动轴是否横屏
 */
- (void)fullScreenSettingScrollView:(BOOL)isFull
{
    
    if (isFull) {
        scrollWidth = iPhoneHeight;
    }else{
        scrollWidth = iPhoneWidth;
    }
    
    self.scrollView.frame = CGRectMake(0, 0, scrollWidth, 70);
    self.scrollView.contentSize = CGSizeMake(2*scrollWidth, 0);
    self.timeView.frame = CGRectMake(scrollWidth/2, 30, scrollWidth, 40);
    self.shaftLine.frame = CGRectMake((scrollWidth-1)/2, 0, 1, 70);
    self.timeLb.frame = CGRectMake((scrollWidth-76)/2, 5, 76, 20);
}

#pragma mark - method
- (void)scrollFrameSetting:(float)value
{
    if (value < 0) {
        value = 0;
    }
    if (value > scrollWidth) {
        value = scrollWidth;
    }
    
    [self.scrollView setContentOffset:CGPointMake(value,0) animated:NO];
    
    if ([self.delegate respondsToSelector:@selector(timeShaftRulerViewScrollOffSet:untilEnd:)]) {
        [self.delegate timeShaftRulerViewScrollOffSet:value untilEnd:NO];
    }
}

#pragma mark - delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    NSLog(@"即将开始滑动内容时");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int value = scrollView.contentOffset.x;
    NSLog(@"正在滑动这么多:%d",value);
    if (value >= 0 && value <= scrollWidth) {
        scrollView.scrollEnabled = YES;
    }else{
        scrollView.scrollEnabled = NO;
    }
    
    float offSet = [[NSString stringWithFormat:@"%d",value] floatValue];
    [self scrollFrameSetting:offSet];

}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
//    NSLog(@"当用户完成滑动内容时");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    NSLog(@"结束滑动");
    
    if (decelerate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //减速
            [scrollView setContentOffset:scrollView.contentOffset animated:NO];
        });
    }
    int value = scrollView.contentOffset.x;
    if ([self.delegate respondsToSelector:@selector(timeShaftRulerViewScrollOffSet:untilEnd:)]) {
        [self.delegate timeShaftRulerViewScrollOffSet:value untilEnd:YES];
    }
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
//    NSLog(@"将开始减速");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    NSLog(@"减速完毕，停止滑动");
}

#pragma mark - getters && setters
//滚动条
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, scrollWidth, 70)];
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(2*scrollWidth, 0);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.alwaysBounceHorizontal = NO;
    }
    return _scrollView;
}

//时间块
- (UIView *)timeView
{
    if (!_timeView) {
        _timeView = [[UIView alloc]initWithFrame:CGRectMake(scrollWidth/2, 30, scrollWidth, 40)];
        _timeView.backgroundColor = [UIColor orangeColor];
    }
    return _timeView;
}

//轴线
- (UIView *)shaftLine
{
    if (!_shaftLine) {
        _shaftLine = [[UIView alloc]initWithFrame:CGRectMake((scrollWidth-1)/2, 0, 1, 70)];
        _shaftLine.backgroundColor = [UIColor redColor];
        _shaftLine.layer.cornerRadius = 1.5f;
    }
    return _shaftLine;
}

//时间标签
- (UILabel *)timeLb
{
    if (!_timeLb) {
        _timeLb = [[UILabel alloc]initWithFrame:CGRectMake((scrollWidth-76)/2, 5, 76, 20)];
        _timeLb.backgroundColor = [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:0.8];
        _timeLb.textColor = [UIColor whiteColor];
        _timeLb.text = @"00:00:00";
        _timeLb.font = [UIFont systemFontOfSize:12];
        _timeLb.textAlignment = NSTextAlignmentCenter;
        _timeLb.layer.masksToBounds = YES;
        _timeLb.layer.cornerRadius = 10.f;
    }
    return _timeLb;
}

@end
