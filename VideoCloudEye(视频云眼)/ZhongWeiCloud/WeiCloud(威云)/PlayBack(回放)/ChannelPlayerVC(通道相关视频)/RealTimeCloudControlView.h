//
//  RealTimeCloudControlView.h
//  ZhongWeiCloud
//
//  Created by 王攀登 on 2022/6/30.
//  Copyright © 2022 苏旋律. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZMRocker.h"

NS_ASSUME_NONNULL_BEGIN

@interface RealTimeCloudControlView : UIView

@property (nonatomic,strong) ZMRocker *normalZMRocker;//竖屏下的滚动控制
@property (nonatomic,strong) UILabel *titleLabel;

- (instancetype)initWithTargetVC:(UIViewController *)targetVC;

@property (nonatomic, copy) void (^hitTestPostBlock)(BOOL enable);

@property (nonatomic, copy) void (^electronicControlSubtraceBlock)(void);
@property (nonatomic, copy) void (^electronicControlPlusBlock)(void);
@property (nonatomic, copy) void (^electronicControlVCStopBlock)(void);

@end

NS_ASSUME_NONNULL_END
