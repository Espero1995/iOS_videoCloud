//
//  MonitoringBottomView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/4/3.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MonitorBottomViewDelegate <NSObject>

- (void)historyBtnClick;

@end
@interface MonitoringBottomView : UIView

@property (nonatomic,strong) UILabel * historyLabel;

@property (nonatomic,strong) UIButton * historyBtn;

@property (nonatomic,assign) id <MonitorBottomViewDelegate>delegate;
@end
