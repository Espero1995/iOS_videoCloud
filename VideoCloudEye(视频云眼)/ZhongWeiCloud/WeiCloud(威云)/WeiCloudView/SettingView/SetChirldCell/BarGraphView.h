//
//  BarGraphView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/1.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarGraphView : UIView

-(instancetype)initWithFrame:(CGRect)frame;
- (void)createBarView:(NSArray *)weekValueArr;
@end
