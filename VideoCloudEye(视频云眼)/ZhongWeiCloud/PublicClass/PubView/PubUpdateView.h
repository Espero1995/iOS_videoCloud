//
//  PubUpdateView.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/17.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PubUpdateView;
@protocol PubUpdateView_Delegete <NSObject>

- (void)PubUpdateView_LeftBtnClick:(PubUpdateView *)view;
- (void)PubUpdateView_RightBtnClick:(PubUpdateView *)view;

@end
@interface PubUpdateView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lab_headTitle;

@property (weak, nonatomic) IBOutlet UILabel *lab_topTitle;

@property (weak, nonatomic) IBOutlet UILabel *lab_bottowTitle;
@property (weak, nonatomic) IBOutlet UIButton *btn_left;
@property (weak, nonatomic) IBOutlet UIButton *btn_right;

@property (nonatomic,weak) id<PubUpdateView_Delegete>delegete;

+(instancetype)viewFromXib;

@end
