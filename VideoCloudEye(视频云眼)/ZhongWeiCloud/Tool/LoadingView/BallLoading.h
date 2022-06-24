//
//  BallLoading.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/13.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BallLoading : UIView

-(void)startLoading;
-(void)stopLoading;

+(void)showBallInView:(UIView*)view andTip:(NSString *)tip;
+(void)hideBallInView:(UIView*)view;
@end
