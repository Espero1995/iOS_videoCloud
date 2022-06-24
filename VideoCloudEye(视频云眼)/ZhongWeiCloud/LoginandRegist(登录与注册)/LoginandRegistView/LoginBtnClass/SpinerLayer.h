//
//  SpinerLayer.h
//  ButtonAnimation
//
//  Created by KeyTaotao on 15/12/24.
//  Copyright © 2015年 KeyTaotao. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface SpinerLayer : CAShapeLayer

-(instancetype) initWithFrame:(CGRect)frame;

-(void)animation;

-(void)stopAnimation;//停止动画
@end
