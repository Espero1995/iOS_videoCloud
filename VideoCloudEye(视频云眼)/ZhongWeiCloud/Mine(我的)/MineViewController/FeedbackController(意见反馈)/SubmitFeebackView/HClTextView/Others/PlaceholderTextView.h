//
//  PlaceholderTextView.h
//  Kurrent
//
//  Created by hcl on 15/9/14.
//  Copyright (c) 2015年 Kurrent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceholderTextView : UITextView

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) UIFont *placeholderFont;

//允许输入的最大长度
@property (nonatomic, assign) NSInteger maxLength;
//是否显示 计数器 label
@property (nonatomic, assign) BOOL showWordCountLabel;


@end
