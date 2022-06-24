//
//  ControlView.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/16.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ControlViewDelegate <NSObject>

- (void)ControlViewBtnTopClick;
- (void)ControlViewBtnLeftClick;
- (void)ControlViewBtnDownClick;
- (void)ControlViewBtnRightClick;
- (void)ControlViewBtnTopInside;
- (void)ControlViewBtnLeftInside;
- (void)ControlViewBtnDownInside;
- (void)ControlViewBtnRightInside;


@end

@interface ControlView : UIView
@property (nonatomic,weak)id<ControlViewDelegate>delegate;
+(instancetype)viewFromXib;
@end
