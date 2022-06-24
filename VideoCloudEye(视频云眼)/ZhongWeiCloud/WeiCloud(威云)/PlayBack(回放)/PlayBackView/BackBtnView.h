//
//  BackBtnView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/24.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BackBtnViewDelegate<NSObject>
- (void)backBtnClick;//返回点击事件
@end

@interface BackBtnView : UIView
/*返回按钮*/
@property (nonatomic,strong)UIButton * backBtn;

@property (nonatomic,assign) id <BackBtnViewDelegate>delegate;
@end
