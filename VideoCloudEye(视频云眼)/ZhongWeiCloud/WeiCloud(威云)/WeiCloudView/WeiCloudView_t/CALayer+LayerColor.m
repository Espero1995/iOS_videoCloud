//
//  CALayer+LayerColor.m
//  
//
//  Created by 赵金强 on 2017/8/21.
//
//

#import "CALayer+LayerColor.h"
#import <UIKit/UIKit.h>
@implementation CALayer (LayerColor)
-(void)setBorderUIColor:(UIColor *)color
{
    self.borderColor=color.CGColor;
}


@end
