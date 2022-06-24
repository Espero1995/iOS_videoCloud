//
//  UITableView+Popover.m
//  SSTableViewPopover
//
//  Created by Mrss on 16/1/26.
//  Copyright © 2016年 expai. All rights reserved.
//

#import "UITableView+Popover.h"
#import <objc/runtime.h>

@implementation PopoverItem

+ (instancetype)itemWithName:(NSString *)name image:(UIImage *)image selectedHandler:(PopoverItemSelectHandler)handler {
    PopoverItem *item = [[PopoverItem alloc]init];
    [item setValue:name forKey:@"name"];
    [item setValue:image forKey:@"image"];
    [item setValue:handler forKey:@"handler"];
    return item;
}

@end

typedef NS_ENUM(NSInteger,TableViewPopoverDirection) {
    TableViewPopoverDirectionUp,
    TableViewPopoverDirectionDown,
};

@interface PopoverButton : UIButton

@end

@implementation PopoverButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    CGRect rect = [super titleRectForContentRect:contentRect];
    return CGRectMake((CGRectGetWidth(contentRect)-CGRectGetWidth(rect))/2, CGRectGetHeight(contentRect)-CGRectGetHeight(rect)-10, CGRectGetWidth(rect), CGRectGetHeight(rect));
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGRect rect = [super imageRectForContentRect:contentRect];
    return CGRectMake((CGRectGetWidth(contentRect)-CGRectGetWidth(rect))/2, 10, CGRectGetWidth(rect), CGRectGetHeight(rect));
}

@end


@interface TableViewPopover : UIView

@property (nonatomic,assign) TableViewPopoverDirection direction;
@property (nonatomic,assign) ShowPopoverType ShowType;

@end


@implementation TableViewPopover

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat offset;
    if (self.ShowType == ShowPopoverType_LineStyle) {
        switch (self.direction) {
            case TableViewPopoverDirectionUp: {
                offset = 0;
            }
                break;
            default: {
                offset = 8;
            }
                break;
        }
        for (UIView *subView in self.subviews) {
            subView.frame = CGRectMake(subView.frame.origin.x,offset, CGRectGetWidth(subView.frame), CGRectGetHeight(subView.frame));
        }
    }
}

- (void)setDirection:(TableViewPopoverDirection)direction {
    if (_direction == direction) {
        return;
    }
    _direction = direction;
    [self setNeedsDisplay];
    [self setNeedsLayout];
}
- (void)setShowType:(ShowPopoverType)ShowType
{
    if (_ShowType == ShowType) {
        return;
    }
    _ShowType = ShowType;
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (void)drawRect:(CGRect)rect {
    CGRect roundRect;
    CGPoint p;
    CGPoint o;
    switch (self.direction) {
        case TableViewPopoverDirectionUp: {
            if (self.ShowType == ShowPopoverType_LineStyle) {
                float widthArrow;
                if (iPhoneWidth <=320) {
                    widthArrow = 140.0f;
                }else if(iPhoneWidth == 375){
                    widthArrow = 150.0f;
                }else{
                    widthArrow = 160.0f;
                }
                
                roundRect = CGRectMake(rect.origin.x+7, rect.origin.y+3, CGRectGetWidth(rect), CGRectGetHeight(rect)-8);
                p = CGPointMake(CGRectGetWidth(roundRect)/2+widthArrow, roundRect.origin.y+CGRectGetHeight(roundRect));
                o = CGPointMake(CGRectGetWidth(rect)/2+widthArrow, CGRectGetHeight(rect)+rect.origin.y);
            }else{
                float widthArrow;
                if (iPhoneWidth <=320) {
                    widthArrow = 140.0f;
                }else if(iPhoneWidth == 375){
                    widthArrow = 150.0f;
                }else{
                    widthArrow = 160.0f;
                }
                
                roundRect = CGRectMake(rect.origin.x+7, rect.origin.y+5, CGRectGetWidth(rect), CGRectGetHeight(rect)-8);
                p = CGPointMake(CGRectGetWidth(roundRect)/2+widthArrow, roundRect.origin.y+CGRectGetHeight(roundRect));
                o = CGPointMake(CGRectGetWidth(rect)/2+widthArrow, CGRectGetHeight(rect)+rect.origin.y);
            }
        }
            break;
        default: {
            if (self.ShowType == ShowPopoverType_LineStyle) {
                
                float widthArrow;
                if (iPhoneWidth <=320) {
                    widthArrow = 140.0f;
                }else if(iPhoneWidth == 375){
                    widthArrow = 150.0f;
                }else{
                    widthArrow = 160.0f;
                }
                
                roundRect = CGRectMake(rect.origin.x+7, rect.origin.y+5, CGRectGetWidth(rect), CGRectGetHeight(rect)-8);
                p = CGPointMake(CGRectGetWidth(roundRect)/2+widthArrow, roundRect.origin.y);
                o = CGPointMake(CGRectGetWidth(rect)/2+widthArrow, rect.origin.y);
            }else{
                
                float widthArrow;
                if (iPhoneWidth <=320) {
                    widthArrow = 140.0f;
                }else if(iPhoneWidth == 375){
                    widthArrow = 150.0f;
                }else{
                    widthArrow = 160.0f;
                }
                
                roundRect = CGRectMake(rect.origin.x+7, rect.origin.y+5, CGRectGetWidth(rect), CGRectGetHeight(rect)-8);
                p = CGPointMake(CGRectGetWidth(roundRect)/2+widthArrow, roundRect.origin.y);
                o = CGPointMake(CGRectGetWidth(rect)/2+widthArrow, rect.origin.y);
            }
        }
            break;
    }
    
    
    UIBezierPath *roundPath = [UIBezierPath bezierPathWithRoundedRect:roundRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(7, 7)];
    [roundPath moveToPoint:p];
    [roundPath addLineToPoint:o];
    [roundPath addLineToPoint:CGPointMake(p.x+14, p.y)];
    [roundPath closePath];
    [RGB(252, 252, 252) setFill];
    [roundPath fill];
}

@end


static const char *PopoverKey = "PopoverKey";
static const char *PopoverItemsKey = "PopoverItemsKey";
static const char *PopoverTapGestureKey = "PopoverTapGestureKey";

@implementation UITableView (Popover)

- (void)showPopoverWithItems:(NSArray<PopoverItem *> *)items ShowStyle:(ShowPopoverType)showStyle forIndexPath:(NSIndexPath *)indexPath {
    if (items.count <= 0) {
        NSLog(@"At least one item!!!");
        return;
    }
    else if (items.count > (NSInteger)CGRectGetWidth(self.frame)/75) {
        NSLog(@"Can not be more than %ld items!!!",(NSInteger)CGRectGetWidth(self.frame)/75);
        return;
    }
    NSArray *visibleIndexPaths = [self indexPathsForVisibleRows];
    __block BOOL flag = NO;
    [visibleIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *ip, NSUInteger idx, BOOL *stop) {
        if (ip.section == indexPath.section && ip.row == indexPath.row) {
            flag = YES;
            *stop = YES;
        }
    }];
    if (!flag) {
        return;
    }
    NSArray *popoverItems = objc_getAssociatedObject(self, PopoverItemsKey);
    if (popoverItems == nil) {
        popoverItems = [items copy];
        objc_setAssociatedObject(self, PopoverItemsKey, popoverItems, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    self.scrollEnabled = NO;
    CGRect rect = [self rectForRowAtIndexPath:indexPath];
    TableViewPopover *popover = objc_getAssociatedObject(self, PopoverKey);
    popover.ShowType = showStyle;
    if (popover == nil) {
        switch (showStyle) {
            case ShowPopoverType_LineStyle:
            {
                if(iPhoneWidth<=320){
                    popover = [[TableViewPopover alloc]initWithFrame:CGRectMake((rect.size.width-items.count*75)/2-10, rect.origin.y, items.count*75, 70)];
                }else if (iPhoneWidth == 375){
                    popover = [[TableViewPopover alloc]initWithFrame:CGRectMake((rect.size.width-items.count*80)/2, rect.origin.y, items.count*85, 70)];
                }else{
                    popover = [[TableViewPopover alloc]initWithFrame:CGRectMake((rect.size.width-items.count*85)/2+10, rect.origin.y, items.count*85, 70)];
                }
                
            }
                break;
            case ShowPopoverType_four_SquareStyle:
            {
                popover = [[TableViewPopover alloc]initWithFrame:CGRectMake((rect.size.width-items.count/2*80)-50, rect.origin.y, items.count/2*80, items.count/2 * 80)];
            }
                break;
                
            default:
                break;
        }
        
        popover.layer.shadowColor = [UIColor grayColor].CGColor;//shadowColor阴影颜色
        popover.layer.shadowOffset = CGSizeMake(0,0);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        popover.layer.shadowOpacity = 0.8;//阴影透明度，默认0
        popover.layer.shadowRadius = 8;//阴影半径，默认3
        popover.alpha = 0.95f;

        [self addSubview:popover];
        
        switch (showStyle) {
            case ShowPopoverType_LineStyle:
            {
                [items enumerateObjectsUsingBlock:^(PopoverItem *obj, NSUInteger idx, BOOL *stop) {
                    PopoverButton *button = [PopoverButton buttonWithType:UIButtonTypeCustom];
                    button.frame = CGRectMake(CGRectGetWidth(popover.frame)/items.count*idx+4, 8, CGRectGetWidth(popover.frame)/items.count, CGRectGetHeight(popover.frame)-8);
                    button.tag = idx;
                    button.backgroundColor = [UIColor clearColor];
                    [button setTitle:obj.name forState:UIControlStateNormal];
                    button.titleLabel.font = [UIFont systemFontOfSize:14];
                    [button setTitleColor:RGB(56, 56, 56) forState:UIControlStateNormal];
                    [button setImage:[self ss_imageWithColor:RGB(56, 56, 56) image:obj.image] forState:UIControlStateNormal];
                    [button addTarget:self action:@selector(ss_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                    [popover addSubview:button];
                }];
                popover.layer.hidden = YES;
                objc_setAssociatedObject(self, PopoverKey, popover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
                break;
            case ShowPopoverType_four_SquareStyle:
            {
                [items enumerateObjectsUsingBlock:^(PopoverItem *obj, NSUInteger idx, BOOL *stop) {
                    PopoverButton *button = [PopoverButton buttonWithType:UIButtonTypeCustom];
                    if (idx > 1) {
                        button.frame = CGRectMake(CGRectGetWidth(popover.frame)/(items.count - 2) *(idx-2)+4, CGRectGetHeight(popover.frame) / 2 + 4, CGRectGetWidth(popover.frame)/(items.count-2), CGRectGetHeight(popover.frame)/(items.count -2 )-8);
                    }else{
                        button.frame = CGRectMake(CGRectGetWidth(popover.frame)/(items.count-2) *idx+4, 4, CGRectGetWidth(popover.frame)/(items.count-2), CGRectGetHeight(popover.frame)/(items.count -2 )-8);
                    }
                        button.tag = idx;
                        button.backgroundColor = [UIColor clearColor];
//                    button.backgroundColor = [UIColor yellowColor];//TODO
                        [button setTitle:obj.name forState:UIControlStateNormal];
                        button.titleLabel.font = [UIFont systemFontOfSize:14];
                        [button setTitleColor:RGB(56, 56, 56) forState:UIControlStateNormal];
                        [button setImage:[self ss_imageWithColor:RGB(56, 56, 56) image:obj.image] forState:UIControlStateNormal];
                        [button addTarget:self action:@selector(ss_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                        [popover addSubview:button];
                        // NSLog(@"tag:%ld === button.frame:%@====popover.frame:%@",(long)button.tag,NSStringFromCGRect(button.frame),NSStringFromCGRect(popover.frame));
                }];
                popover.layer.hidden = YES;
                objc_setAssociatedObject(self, PopoverKey, popover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
                break;
                
            default:
                break;
        }
    }
    CGFloat offHeight = fabs(rect.origin.y-self.contentOffset.y);
    CGRect popoverFrame;
    TableViewPopoverDirection direction;
    if (offHeight>=70) {
        //箭头向下的情况
        direction = TableViewPopoverDirectionUp;
        
        switch (showStyle) {
        case ShowPopoverType_LineStyle:
            {
                popoverFrame = CGRectMake(popover.frame.origin.x, rect.origin.y-50, CGRectGetWidth(popover.frame), CGRectGetHeight(popover.frame));
            }
                break;
        case ShowPopoverType_four_SquareStyle:
            {
                popoverFrame = CGRectMake(popover.frame.origin.x, rect.origin.y-70, CGRectGetWidth(popover.frame), CGRectGetHeight(popover.frame));

            }
                break;
            default:
                break;
        }
        
    }
    else {
        //箭头向上的情况
        direction = TableViewPopoverDirectionDown;
        
        
        switch (showStyle) {
            case ShowPopoverType_LineStyle:
            {
                //根据设备类型适配
                if (iPhoneWidth<=320) {
                    popoverFrame = CGRectMake(popover.frame.origin.x, rect.origin.y+CGRectGetHeight(rect)-170, CGRectGetWidth(popover.frame), CGRectGetHeight(popover.frame));
                }else if(iPhoneWidth == 375){
                    popoverFrame = CGRectMake(popover.frame.origin.x, rect.origin.y+CGRectGetHeight(rect)-200, CGRectGetWidth(popover.frame), CGRectGetHeight(popover.frame));
                }else{
                    popoverFrame = CGRectMake(popover.frame.origin.x, rect.origin.y+CGRectGetHeight(rect)-230, CGRectGetWidth(popover.frame), CGRectGetHeight(popover.frame));
                }
            }
                break;
            case ShowPopoverType_four_SquareStyle:
            {
                
                 popoverFrame = CGRectMake(popover.frame.origin.x, rect.origin.y+CGRectGetHeight(rect)-80, CGRectGetWidth(popover.frame), CGRectGetHeight(popover.frame));
//                //根据设备类型适配
//                if (iPhoneWidth<=320) {
//                    popoverFrame = CGRectMake(popover.frame.origin.x, rect.origin.y+CGRectGetHeight(rect)-80, CGRectGetWidth(popover.frame), CGRectGetHeight(popover.frame));
//                }else if(iPhoneWidth == 375){
//                    popoverFrame = CGRectMake(popover.frame.origin.x, rect.origin.y+CGRectGetHeight(rect)-80, CGRectGetWidth(popover.frame), CGRectGetHeight(popover.frame));
//                }else{
//                    popoverFrame = CGRectMake(popover.frame.origin.x, rect.origin.y+CGRectGetHeight(rect)-80, CGRectGetWidth(popover.frame), CGRectGetHeight(popover.frame));
//                }
            }
                break;
                
            default:
                break;
        }
        
    }
    
    [self bringSubviewToFront:popover];
    popover.frame = popoverFrame;
    popover.direction = direction;
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DIdentity],
                   [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.075, 1.075, 1)],
                   [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    scaleAnimation.keyTimes = @[@(0),@(0.7),@(1)];
    CABasicAnimation *hiddenAnimation = [CABasicAnimation animationWithKeyPath:@"hidden"];
    hiddenAnimation.toValue = [NSNumber numberWithBool:NO];
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = @[scaleAnimation,hiddenAnimation];
    groupAnimation.duration = 0.3;
    groupAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    groupAnimation.repeatCount = 1;
    popover.layer.hidden = NO;
    [popover.layer addAnimation:groupAnimation forKey:@"ani"];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ss_tap:)];
    [self addGestureRecognizer:tap];
    objc_setAssociatedObject(self, PopoverTapGestureKey, tap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark Action
- (void)ss_buttonAction:(PopoverButton *)sender {
    NSArray *popoverItems = objc_getAssociatedObject(self, PopoverItemsKey);
    PopoverItem *popoverItem = popoverItems[sender.tag];
    if (popoverItem.handler) {
        popoverItem.handler(popoverItem);
    }
    [self ss_hide];
}

- (void)ss_tap:(UITapGestureRecognizer *)tap {
    [self ss_hide];
}

- (void)ss_hide {
    TableViewPopover *popover = objc_getAssociatedObject(self, PopoverKey);
    popover.layer.hidden = YES;
    self.scrollEnabled = YES;
    UITapGestureRecognizer *tap = objc_getAssociatedObject(self, PopoverTapGestureKey);
    [self removeGestureRecognizer:tap];
    objc_setAssociatedObject(self, PopoverTapGestureKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, PopoverItemsKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)removePopView{
    TableViewPopover *popover = objc_getAssociatedObject(self, PopoverKey);
    popover.layer.hidden = YES;
    self.scrollEnabled = YES;
    UITapGestureRecognizer *tap = objc_getAssociatedObject(self, PopoverTapGestureKey);
    [self removeGestureRecognizer:tap];
    objc_setAssociatedObject(self, PopoverTapGestureKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, PopoverItemsKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//Blend image with whitecolor.
- (UIImage *)ss_imageWithColor:(UIColor *)color image:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
