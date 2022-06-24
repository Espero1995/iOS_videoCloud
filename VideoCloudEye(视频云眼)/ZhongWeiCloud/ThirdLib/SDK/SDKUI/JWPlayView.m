//
//  VideoPlayView.m
//  ZhongWeiEyes
//
//  Created by 张策 on 16/12/2.
//  Copyright © 2016年 张策. All rights reserved.
//

#import "JWPlayView.h"
#import "LoadingHubView.h"
@implementation JWPlayView
+(instancetype)viewFromXib
{
    NSString *strClass =  NSStringFromClass([self class]);
    NSArray *arr = [[NSBundle mainBundle]loadNibNamed:strClass owner:self options:nil];
    
    return [arr lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}
@end
