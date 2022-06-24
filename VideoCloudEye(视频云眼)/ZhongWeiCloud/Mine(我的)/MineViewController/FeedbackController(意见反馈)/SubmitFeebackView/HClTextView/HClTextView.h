//
//  HClTextView.h
//  Kurrent
//
//  Created by hcl on 15/9/14.
//  Copyright (c) 2015年 Kurrent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceholderTextView.h"
#define kWinsize [[UIScreen mainScreen] bounds].size

typedef NS_ENUM(NSUInteger, ClearButtonType) {
    ClearButtonNeverAppear,     // 默认隐藏
    ClearButtonAppearWhenEditing,   // 编辑时显示
    ClearButtonAppearAlways,        // 一直显示
};
@protocol HClTextViewDelegate;

@interface HClTextView : UIView
@property (nonatomic,assign) id delegate;
@property (assign, nonatomic) ClearButtonType clearButtonType;
///设置左侧Label文字(需优先设置,则会改变部分占位文字)!!!
- (void)setLeftTitleText:(NSString *)text;
///设置是否显示输入字数
- (void)setTextCountLabelHidden:(BOOL)hidden;
///设置是否显示底部分割线
- (void)setBottomDivLineHidden:(BOOL)hidden;
///设置显示的文字以及输入最多字数
- (void)setPlaceholder:(NSString *)placeText
           contentText:(NSString *)contentText
          maxTextCount:(NSUInteger)maxTextCount;
@end

@protocol HClTextViewDelegate <NSObject>

- (void)textViewDidChange:(UITextView *)textView;

@end