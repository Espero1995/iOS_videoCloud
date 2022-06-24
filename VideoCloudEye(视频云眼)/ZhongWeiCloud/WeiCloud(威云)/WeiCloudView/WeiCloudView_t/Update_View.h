//
//  PubUpdateView.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/17.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Update_View;
@protocol Update_View_Delegete <NSObject>

- (void)Update_View_LeftBtnClick:(Update_View *)view;
- (void)Update_View_RightBtnClick:(Update_View *)view;

@end
@interface Update_View : UIView


@property (weak, nonatomic) IBOutlet UILabel *lab_topTitle;
@property (weak, nonatomic) IBOutlet UIButton *btn_left;
@property (weak, nonatomic) IBOutlet UIButton *btn_right;

@property (nonatomic,weak) id<Update_View_Delegete>delegete;

+(instancetype)viewFromXib;

@end
