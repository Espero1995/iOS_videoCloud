//
//  SinglePickView.m
//  App
//
//  Created by Yu on 16/6/22.
//  Copyright © 2016年 HangZhou ShuoChuang Technology Co.,Ltd. All rights reserved.
//

#import "SinglePickView.h"

@interface SinglePickView ()
{
    UIView *rootView;
    
    UIButton *ok;
    UIButton *cancle;
    NSArray *array;
    NSInteger select_row;
    
    NSInteger tag;

}

@end

@implementation SinglePickView


#define _ROOTVIEW_HEIGHT_ (236.0f)

#define _VIEW_FRAME_START_ (CGRectMake(0, iPhoneHeight, iPhoneWidth, iPhoneHeight))
#define _VIEW_FRAME_END_ (CGRectMake(0, iPhoneHeight-_ROOTVIEW_HEIGHT_, iPhoneWidth, _ROOTVIEW_HEIGHT_))



-(id)initWithArray:(NSArray*)ary Select:(NSInteger)sel Tag:(NSInteger)t
{
    self=[super initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];

    if (self) {
        
        array=ary;
        
        tag=t;
        
        [self setBackgroundColor:RGBA(0, 0, 0, 0.5)];
        
        //[self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickCategory:)]];
        
        rootView=[[UIView alloc] initWithFrame:_VIEW_FRAME_START_];
        [rootView setBackgroundColor:RGBA(0xed, 0xed, 0xed, 1)];
        
        
        UIView *topbarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, 40)];
        [topbarView setBackgroundColor:MAIN_COLOR];
        
        cancle=[[UIButton alloc] initWithFrame:CGRectMake(10, 0, 60, 40)];
        [cancle setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        cancle.titleLabel.font = [UIFont systemFontOfSize: 18.0];
        [cancle setTitleColor:RGBA(0xed, 0xed, 0xed, 1) forState:UIControlStateNormal];
        cancle.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [cancle addTarget:self action:@selector(cancle:) forControlEvents:(UIControlEventTouchUpInside)];
        
        
        ok=[[UIButton alloc] initWithFrame:CGRectMake(iPhoneWidth - 70, 0, 60, 40)];
        [ok setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
        ok.titleLabel.font = [UIFont systemFontOfSize: 18.0];
        [ok setTitleColor:RGBA(0xed, 0xed, 0xed, 1) forState:UIControlStateNormal];
        ok.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [ok addTarget:self action:@selector(ok:) forControlEvents:(UIControlEventTouchUpInside)];
        
        [topbarView addSubview:cancle];
        [topbarView addSubview:ok];
        
        self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 20, iPhoneWidth, 216)];
        self.pickerView.showsSelectionIndicator = YES;
        self.pickerView.delegate = self;
        self.pickerView.dataSource =  self;
        
        [self.pickerView selectRow:sel inComponent:0 animated:YES];
        
        
        UIView *bule_line=[[UIView alloc] initWithFrame:CGRectMake(0, 107, iPhoneWidth, 42.5)];
        [bule_line setBackgroundColor:RGBA(0xda, 0xe8, 0xf1, 1)];
        
        [rootView addSubview:bule_line];
        [rootView addSubview:self.pickerView];
        [rootView addSubview:topbarView];
        
        select_row=sel;
        
        [self addSubview:rootView];
    }
    
    return self;
}

-(void)ok:(UIButton*)sender
{
    if (self.delegate) {
        [self.delegate SinglePickViewTag:tag Select:select_row Value:[array objectAtIndex:select_row]];
    }
    [self hide];
}


-(void)cancle:(UIButton*)sender
{
    [self hide];
}


- (void)show
{
    if (self.isShowing) {
        return;
    }
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    
    self.alpha = 0;
    
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 1;
        [rootView setFrame:_VIEW_FRAME_END_];
        self.show = YES;
    }];
}

- (void)hide
{
    if (!self.isShowing) {
        return;
        
    }
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 0;
        [rootView setFrame:_VIEW_FRAME_START_];
    } completion:^(BOOL finished) {
        self.show = NO;
        [self removeFromSuperview];
    }];
    
}

-(void)clickCategory:(UITapGestureRecognizer*)gestureRecognizer
{
    [self hide];
}

//- delegate
#pragma mark -UIPickerViewDelegate
//返回列数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//返回行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [array count];
}

//自定义行的高度
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [array objectAtIndex:row];
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    select_row=row;
}





@end
