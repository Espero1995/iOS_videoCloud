//
//  WebProgressLineLayer.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/10.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface WebProgressLineLayer : CAShapeLayer

+ (instancetype)layerWithFrame:(CGRect)frame;

- (void)finishedLoad;
- (void)startLoad;

- (void)closeTimer;
@end
