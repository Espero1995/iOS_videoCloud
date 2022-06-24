//
//  TYViedoToolBarView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/11/2.
//  Copyright © 2018 张策. All rights reserved.
//
#define kViewHorizenlSpacing 10
#define kBackBtnHeightWidth 40
#define kButtonHeight 26
#define kButtonWidth 28
#define kViewHorizenlSpace 10

#import "TYViedoToolBarView.h"
@interface TYViedoToolBarView ()
@end
@implementation TYViedoToolBarView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addViedoInfoLabel];
        [self addSaveBtn];
    }
    return self;
}

- (void)addViedoInfoLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:13];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    [self addSubview:label];
    _viedoInfoLabel = label;
}

- (void)addSaveBtn
{
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setImage:[UIImage imageNamed:@"hold"] forState:UIControlStateNormal];
    [self addSubview:saveBtn];
    _saveBtn = saveBtn;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _viedoInfoLabel.frame = CGRectMake(kViewHorizenlSpacing, 0, CGRectGetWidth(self.frame) - 2*kViewHorizenlSpacing, kBackBtnHeightWidth);
    _saveBtn.frame = CGRectMake(CGRectGetWidth(self.frame) - kButtonWidth - kViewHorizenlSpace, 70-kButtonHeight-10, kButtonWidth, kButtonHeight);
}

@end
