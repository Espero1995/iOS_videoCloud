//
//  CustomSlider.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/13.
//  Copyright © 2018年 张策. All rights reserved.
//

#define LiuXSlideWidth      (self.bounds.size.width)
#define LiuXSliderHight     (self.bounds.size.height)

#define LiuXSliderTitle_H   (LiuXSliderHight*.3)

#define CenterImage_W       26.0

#define LiuXSliderLine_W    (LiuXSlideWidth-CenterImage_W)
#define LiuXSLiderLine_H    10.0
#define LiuXSliderLine_Y    (LiuXSliderHight-LiuXSliderTitle_H)


#define CenterImage_Y       (LiuXSliderLine_Y+(LiuXSLiderLine_H/2))

#import "RatioSlider.h"

@interface RatioSlider()
{
    
    CGFloat _pointX;
    NSInteger _sectionIndex;//当前选中的那个
    CGFloat _sectionLength;//根据数组分段后一段的长度
    UILabel *_selectLab;
    UILabel *_leftLab;
    UILabel *_rightLab;
}
/**
 *  必传，范围（0到(array.count-1)）
 */
@property (nonatomic,assign)CGFloat defaultIndx;

/**
 *  必传，传入节点数组
 */
@property (nonatomic,strong)NSArray *titleArray;


/**
 *  传入图片
 */
@property (nonatomic,strong)UIImage *sliderImage;

@property (strong,nonatomic)UIView *selectView;
@property (strong,nonatomic)UIView *defaultView;
@property (strong,nonatomic)UIImageView *centerImage;
@end

@implementation RatioSlider

-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titleArray defaultIndex:(CGFloat)defaultIndex sliderImage:(UIImage *)sliderImage
{
    if (self  = [super initWithFrame:frame]) {
        _pointX=0;
        _sectionIndex=0;
        
        self.backgroundColor=[UIColor clearColor];
        
        //userInteractionEnabled=YES;代表当前视图可交互，该视图不响应父视图手势
        //UIView的userInteractionEnabled默认是YES，UIImageView默认是NO
        _defaultView=[[UIView alloc] initWithFrame:CGRectMake(CenterImage_W/2, LiuXSliderLine_Y, LiuXSlideWidth-CenterImage_W, LiuXSLiderLine_H)];
        _defaultView.layer.cornerRadius=LiuXSLiderLine_H/2;
        _defaultView.userInteractionEnabled=NO;
        _defaultView.backgroundColor = [UIColor clearColor];
        UIImage *slideBg=[UIImage imageNamed:@"ratioBg"];
        _defaultView.layer.contents=(__bridge id)slideBg.CGImage;
        [self addSubview:_defaultView];
        
        _selectView=[[UIView alloc] initWithFrame:CGRectMake(CenterImage_W/2, LiuXSliderLine_Y, LiuXSlideWidth-CenterImage_W, LiuXSLiderLine_H)];
        _selectView.backgroundColor = [UIColor clearColor];
        _selectView.layer.cornerRadius=LiuXSLiderLine_H/2;
        _selectView.userInteractionEnabled=NO;
        [self addSubview:_selectView];
        
        _centerImage=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CenterImage_W, CenterImage_W)];
        _centerImage.center=CGPointMake(0, CenterImage_Y);
        _centerImage.userInteractionEnabled=NO;
        _centerImage.alpha=1.f;
        [self addSubview:_centerImage];
        

        self.titleArray=titleArray;
        float PicWidth = (LiuXSlideWidth-CenterImage_W)/6;
        float Spacing = CenterImage_W/2;
        
        for (int i = 0; i < titleArray.count; i++) {
            UILabel *tipLb = [[UILabel alloc]initWithFrame:CGRectMake(Spacing-PicWidth/2+i*PicWidth, 0, PicWidth, 15)];
            tipLb.backgroundColor = [UIColor clearColor];
            tipLb.textAlignment = NSTextAlignmentCenter;
            tipLb.textColor = RGB(255, 123, 0);
            tipLb.text = titleArray[i];
            [self addSubview:tipLb];
        }
        
        self.defaultIndx=defaultIndex;
        self.sliderImage=sliderImage;
    }
    return self;
}


-(void)setDefaultIndx:(CGFloat)defaultIndx{
    CGFloat withPress=defaultIndx/(_titleArray.count-1);
    //设置默认位置
    CGRect rect=[_selectView frame];
    rect.size.width = withPress*LiuXSliderLine_W;
    _selectView.frame=rect;
    
    _pointX=withPress*LiuXSliderLine_W;
    _sectionIndex=defaultIndx;
}

-(void)setTitleArray:(NSArray *)titleArray{
    _titleArray=titleArray;
    _sectionLength=(LiuXSliderLine_W/(titleArray.count-1));
    //NSLog(@"(%lu),(%f),(%f)",(unsigned long)titleArray.count,LiuXSliderLine_W,_sectionLength);
}


-(void)setSliderImage:(UIImage *)sliderImage{
    _centerImage.image=sliderImage;
    [self refreshSlider];
}


#pragma mark ---UIColor Touchu
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [self changePointX:touch];
    _pointX=_sectionIndex*(_sectionLength);
    [self refreshSlider];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [self changePointX:touch];
    [self refreshSlider];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [self changePointX:touch];
    _pointX=_sectionIndex*(_sectionLength);
    if (self.block) {
        self.block((int)_sectionIndex);
    }
    [self refreshSlider];
}

-(void)changePointX:(UITouch *)touch{
    CGPoint point = [touch locationInView:self];
    _pointX=point.x;
    if (point.x<0) {
        _pointX=CenterImage_W/2;
    }else if (point.x>LiuXSliderLine_W){
        _pointX=LiuXSliderLine_W+CenterImage_W/2;
    }
    //四舍五入计算选择的节点
    _sectionIndex=(int)roundf(_pointX/_sectionLength);
    //NSLog(@"pointx=(%f),(%ld),(%f)",point.x,(long)_sectionIndex,_pointX);
    
}

-(void)refreshSlider{
    _pointX=_pointX+CenterImage_W/2;
    _centerImage.center=CGPointMake(_pointX, CenterImage_Y);
    CGRect rect = [_selectView frame];
    rect.size.width=_pointX-CenterImage_W/2;
    _selectView.frame=rect;
}




@end
