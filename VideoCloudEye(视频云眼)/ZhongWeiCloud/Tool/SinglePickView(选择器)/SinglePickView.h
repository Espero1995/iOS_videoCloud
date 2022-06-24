//
//  SinglePickView.h
//  App
//
//  Created by Yu on 16/6/22.
//  Copyright © 2016年 HangZhou ShuoChuang Technology Co.,Ltd. All rights reserved.
//


#import <UIKit/UIKit.h>


@protocol SinglePickViewDelegate <NSObject>

@optional

-(void)SinglePickViewTag:(NSInteger)t Select:(NSInteger)index Value:(NSString*)value;

@end


@interface SinglePickView: UIView<UIPickerViewDelegate,UIPickerViewDataSource>


@property(nonatomic)id<SinglePickViewDelegate> delegate;
@property (nonatomic,strong) UIPickerView *pickerView;
///是否正在显示
@property (nonatomic, getter = isShowing) BOOL show;


-(id)initWithArray:(NSArray*)ary Select:(NSInteger)sel Tag:(NSInteger)t;

- (void)show;

- (void)hide;

@end
