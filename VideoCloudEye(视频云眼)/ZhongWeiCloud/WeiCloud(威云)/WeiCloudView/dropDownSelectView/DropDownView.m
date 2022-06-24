//
//  DropDownView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/3.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "DropDownView.h"
#import "UIViewController+LewPopupViewController.h"
#import "LewPopupViewAnimationDrop.h"

@interface DropDownView()
{
    NSString *selectedStr;
}
@end

@implementation DropDownView

- (id)initWithFrame:(CGRect)frame andTitleArr:(NSArray *)titleArr
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil];
        _innerView.frame = frame;
        _innerView.layer.cornerRadius = 5.0f;
        self.innerTitle.text = titleArr[0];
       
        [self.selectBtn1 setTitle:titleArr[1] forState:UIControlStateNormal];
        [self.selectBtn2 setTitle:titleArr[2] forState:UIControlStateNormal];
        [self.selectBtn3 setTitle:titleArr[3] forState:UIControlStateNormal];
        [self.selectBtn4 setTitle:titleArr[4] forState:UIControlStateNormal];
        [self addSubview:_innerView];
    }
    return self;
}


+ (instancetype)defaultPopupViewandTitleArr:(NSArray *)titleArr{
    return [[DropDownView alloc]initWithFrame:CGRectMake(0, 0, 0.6*iPhoneWidth, 230) andTitleArr:titleArr];
}



- (IBAction)btn1Click:(id)sender {
    [_parentVC lew_dismissPopupViewWithanimation:[LewPopupViewAnimationDrop new]];
    UIButton *btn = (UIButton *)sender;
    selectedStr = btn.titleLabel.text;
    if (self.DropDownViewDelegate &&[self.DropDownViewDelegate respondsToSelector:@selector(DropDownBtn1Click:)]) {
        [self.DropDownViewDelegate DropDownBtn1Click:selectedStr];
    }
}

- (IBAction)btn2Click:(id)sender {
    [_parentVC lew_dismissPopupViewWithanimation:[LewPopupViewAnimationDrop new]];
    UIButton *btn = (UIButton *)sender;
    selectedStr = btn.titleLabel.text;
    if (self.DropDownViewDelegate &&[self.DropDownViewDelegate respondsToSelector:@selector(DropDownBtn2Click:)]) {
        [self.DropDownViewDelegate DropDownBtn2Click:selectedStr];
    }
}

- (IBAction)btn3Click:(id)sender {
    [_parentVC lew_dismissPopupViewWithanimation:[LewPopupViewAnimationDrop new]];
    UIButton *btn = (UIButton *)sender;
    selectedStr = btn.titleLabel.text;
    if (self.DropDownViewDelegate &&[self.DropDownViewDelegate respondsToSelector:@selector(DropDownBtn3Click:)]) {
        [self.DropDownViewDelegate DropDownBtn3Click:selectedStr];
    }
}

- (IBAction)btn4Click:(id)sender {
    [_parentVC lew_dismissPopupViewWithanimation:[LewPopupViewAnimationDrop new]];
    UIButton *btn = (UIButton *)sender;
    selectedStr = btn.titleLabel.text;
    if (self.DropDownViewDelegate &&[self.DropDownViewDelegate respondsToSelector:@selector(DropDownBtn4Click:)]) {
        [self.DropDownViewDelegate DropDownBtn4Click:selectedStr];
    }
}

@end
