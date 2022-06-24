//
//  CenterTimeView.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/16.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CenterTimeViewDelegate <NSObject>

//点击前端中心按钮
- (void)CenterTimeViewCenterBtnClick:(BOOL)isCenter TimeStr:(NSString *)timeStr;


@end

@interface CenterTimeView : UIView
@property (weak, nonatomic) IBOutlet UIButton *btn_time;//日期
@property (weak, nonatomic) IBOutlet UIButton *btn_center;//中心录像
@property (weak, nonatomic) IBOutlet UIButton *btn_front;//前端录像
@property (nonatomic,weak)id<CenterTimeViewDelegate>delegate;
//是否中心录像
@property (nonatomic,assign)BOOL isCenter;
+(instancetype)viewFromXib;
@end
