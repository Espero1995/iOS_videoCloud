//
//  userDefine_bg_view.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/7/23.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol userDefine_bg_view_Delegate <NSObject>
- (void)bg_view_TapAction:(UITapGestureRecognizer*)tap;
@end

@interface userDefine_bg_view : UIView
@property (nonatomic, assign) id<userDefine_bg_view_Delegate>delegate;/**< 代理 */

@end
