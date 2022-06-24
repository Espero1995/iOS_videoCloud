//
//  SetPickerView.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/28.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^MyBasicBlock)(id hour ,id min);
@interface SetPickerView : UIView
@property (retain, nonatomic) NSArray * hourPickerData;
@property (retain,nonatomic)  NSArray * minPickerData;
@property (retain, nonatomic) UIPickerView *pickerView;
@property (nonatomic,strong) UIButton * btnOK;

@property (nonatomic, copy) MyBasicBlock selectBlock;

- (void)popPickerView;


@end
