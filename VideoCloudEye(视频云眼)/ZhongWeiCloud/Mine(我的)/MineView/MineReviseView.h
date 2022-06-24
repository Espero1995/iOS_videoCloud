//
//  MineReviseView.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/8.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+ScottAlertView.h"


@protocol MineReviseViewDelegate <NSObject>
@optional
- (void)mineReviseBtnOkClick:(NSString *)nameStr;
- (void)mineReviseBtnCancelClick;


@end
@interface MineReviseView : UIView
@property (weak, nonatomic) IBOutlet UITextField *fied_name;
@property (nonatomic,weak)id<MineReviseViewDelegate>delegate;
+(instancetype)viewFromXib;

@end
