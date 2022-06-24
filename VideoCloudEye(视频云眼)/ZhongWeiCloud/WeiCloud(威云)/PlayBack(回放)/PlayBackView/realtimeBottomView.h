//
//  realtimeBottomView.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/1/23.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol realtimeBottomViewDelegate <NSObject>

- (void)saveBtnClick;
- (void)historyBtnClick;

@end

@interface realtimeBottomView : UIView

@property (nonatomic,strong) UILabel * saveLabel;
@property (nonatomic,strong) UILabel * historyLabel;

@property (nonatomic,strong) UIButton * saveBtn;
@property (nonatomic,strong) UIButton * historyBtn;

@property (nonatomic,assign) id <realtimeBottomViewDelegate>delegate;

@end
