//
//  LoginButton.h
//  ButtonAnimation
//
//  Created by KeyTaotao on 15/12/24.
//  Copyright © 2015年 KeyTaotao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpinerLayer.h"

typedef void(^Completion)();

@interface LoginButton : UIButton

@property (nonatomic,retain) SpinerLayer *spiner;

-(void)setCompletion:(Completion)completion;

-(void)StartAnimation;

-(void)ErrorRevertAnimationCompletion:(Completion)completion;

-(void)RevertAnimationCompletion:(Completion)completion;

-(void)ExitAnimationCompletion:(Completion)completion;


@property (nonatomic,assign) CFTimeInterval shrinkDuration;

@property (nonatomic,retain) CAMediaTimingFunction *shrinkCurve;

@property (nonatomic,retain) CAMediaTimingFunction *expandCurve;

@property (nonatomic,strong) Completion block;

@property (nonatomic,retain) UIColor *color;
@end
