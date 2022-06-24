//
//  showRockerBtnView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/24.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol showRockerBtnViewDelegate<NSObject>
- (void)showRockerBtnClick;//滚轮按钮点击事件（此控件待定)
@end

@interface showRockerBtnView : UIView
/*滚轮按钮*/
@property (nonatomic,strong)UIButton * showRockerBtn;

@property (nonatomic,assign) id <showRockerBtnViewDelegate>delegate;
@end
