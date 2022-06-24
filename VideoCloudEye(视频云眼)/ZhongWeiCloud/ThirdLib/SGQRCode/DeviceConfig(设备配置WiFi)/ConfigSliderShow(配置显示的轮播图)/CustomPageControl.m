//
//  customPageControl.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/3/19.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import "CustomPageControl.h"

@implementation CustomPageControl

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = NO;
    }
    return self;
}

-(void)setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    
    for (NSUInteger subviewIndex = 0; subviewIndex < [self.subviews count]; subviewIndex++) {
        
        UIImageView *subview = (UIImageView *)[self.subviews objectAtIndex:subviewIndex];
        CGSize size;
        size.height = 6;
        size.width = 12;
//        [subview setFrame:CGRectMake(subview.frame.origin.x, subview.frame.origin.y, size.width, size.height)];
        subview.frame = CGRectMake(subview.frame.origin.x, subview.frame.origin.y, size.width, size.height);
        if (subviewIndex == currentPage)
        {
            UIImage *bgImg = [UIImage imageNamed:@"config_currentPage"];
            subview.layer.contents = (id)bgImg.CGImage;
        }
        else
        {
            UIImage *bgImg = [UIImage imageNamed:@"config_otherPage"];
            subview.layer.contents = (id)bgImg.CGImage;
        }
    }
}

@end
