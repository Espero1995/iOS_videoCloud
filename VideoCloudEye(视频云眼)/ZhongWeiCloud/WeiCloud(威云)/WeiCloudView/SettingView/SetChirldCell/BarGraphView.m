//
//  BarGraphView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/1.
//  Copyright © 2018年 张策. All rights reserved.
//
#define BarGraphWidth self.frame.size.width
#define BarGraphHeight self.frame.size.height
#define SpacingX 20
#import "BarGraphView.h"

@interface BarGraphView ()
@property (nonatomic,strong) NSArray *dateArr;//星期
@property (nonatomic,strong) UILabel *markLb;//标注
@property (nonatomic,strong) UIView *canvasView;//底部View
@end

@implementation BarGraphView

//重写初始化
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.dateArr = @[@"一",@"二",@"三",@"四",@"五",@"六",@"日"];
        [self addSubview:self.markLb];//标注
    }
    return self;
    
}

#pragma mark - 创建柱状图背景与柱形状
- (void)createBarView:(NSArray *)weekValueArr
{
    [self.canvasView removeFromSuperview];
    self.canvasView = nil;
    [self addSubview:self.canvasView];//坐标
    float barWidth = (BarGraphWidth - SpacingX*8)/7;
    //底部坐标
    for (int i = 0; i < 7; i++) {
        UILabel *weekLb = [[UILabel alloc]initWithFrame:CGRectMake(SpacingX+(SpacingX+barWidth)*i, BarGraphHeight-15-10, barWidth, 15)];
        weekLb.backgroundColor = [UIColor clearColor];
        weekLb.textAlignment = NSTextAlignmentCenter;
        weekLb.text = self.dateArr[i];
        weekLb.font = FONTB(12);
        [self.canvasView addSubview:weekLb];
    }
    
    float barHeight = (BarGraphHeight - 15 - 20);
    for (int i = 0; i < 7; i++) {
        int value = [weekValueArr[i] intValue];
        CGFloat Y_value = BarGraphHeight - 15 - 15 - barHeight*value;
        UIView *barView = [[UIView alloc]initWithFrame:CGRectMake(SpacingX+(SpacingX+barWidth)*i, Y_value+barHeight*value, barWidth, 2)];
        barView.backgroundColor = MAIN_COLOR;//RGB(239, 27, 93);
        
        if (value == 1) {
            barView.layer.masksToBounds = YES;
            barView.layer.cornerRadius = 3.f;
            
            [UIView animateWithDuration:0.5 animations:^{
                barView.frame = CGRectMake(SpacingX+(SpacingX+barWidth)*i, Y_value, barWidth, barHeight*value+2);
            } completion:^(BOOL finished) {
                
            }];
        }
        
        [self.canvasView addSubview:barView];
    }
    
    
}


#pragma mark - getter && setter
//标注
- (UILabel *)markLb
{
    if (!_markLb) {
        _markLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, BarGraphWidth, 15)];
        _markLb.text = @"周期(单位/星期)";
        _markLb.textColor = RGB(180, 180, 180);
        _markLb.font = FONT(13);
    }
    return _markLb;
}
//底部View
- (UIView *)canvasView
{
    if (!_canvasView) {
        _canvasView = [[UIView alloc]initWithFrame:CGRectMake(0, 15, BarGraphWidth, BarGraphHeight-15)];
        _canvasView.backgroundColor = [UIColor clearColor];
    }
    return _canvasView;
}



@end
