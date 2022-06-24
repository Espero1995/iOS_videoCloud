//
//  ProgressBarView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/4/17.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressBarView : UIView
- (void) ProgressBarTip:(NSString *)tip totalCount:(int)totalCount andCurrentCount:(int)currentCount;
@end
