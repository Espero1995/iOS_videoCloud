//
//  CustomTextField.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/5/8.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (instancetype)initWithPlaceholder:(NSString *)text
{
    self = [super init];
    if (self) {
        [self createCustomTFWithPlaceholder:text];
    }
    return self;
}

- (void)createCustomTFWithPlaceholder:(NSString *)text
{
    self.placeholder = text;
    self.backgroundColor = [UIColor colorWithHexString:@"#f8f8f8"];
    self.layer.borderColor = [UIColor colorWithHexString:@"#c0c0c0"].CGColor;
    self.layer.borderWidth = 1.0f;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8.0f;
}

// 控制还未输入时文本的位置，缩进40
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds, 20, 0);
}
// 控制输入后文本的位置，缩进20
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds, 20, 0);
}

////控制placeHolder的位置
//-(CGRect)placeholderRectForBounds:(CGRect)bounds
//{
//    CGRect inset = CGRectMake(bounds.origin.x+15, bounds.origin.y, bounds.size.width -15, bounds.size.height);
//    return inset;
//}
@end
