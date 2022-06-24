//
//  TYViedoToolBarView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/11/2.
//  Copyright © 2018 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYViedoToolBarView : UIView
//视频信息展示Label
@property (nonatomic,weak,readonly) UILabel *viedoInfoLabel;
//保存按钮
@property (nonatomic,strong) UIButton *saveBtn;
@end

