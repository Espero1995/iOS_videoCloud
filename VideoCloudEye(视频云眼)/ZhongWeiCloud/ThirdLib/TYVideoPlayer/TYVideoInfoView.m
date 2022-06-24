//
//  TYVideoInfoView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/28.
//  Copyright © 2018年 张策. All rights reserved.
//
#define kViewHorizenlSpacing 10
#define kBackBtnHeightWidth 40

#import "TYVideoInfoView.h"

@interface TYVideoInfoView ()
@property (nonatomic, weak) UILabel *viedoInfoLabel;
@end

@implementation TYVideoInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addViedoInfoLabel];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self addViedoInfoLabel];
    }
    return self;
}

- (void)addViedoInfoLabel
{
    UILabel *label = [[UILabel alloc]init];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:13];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    [self addSubview:label];
    _viedoInfoLabel = label;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _viedoInfoLabel.frame = CGRectMake(kViewHorizenlSpacing, 0, CGRectGetWidth(self.frame) - 2*kViewHorizenlSpacing, kBackBtnHeightWidth);
}


@end
