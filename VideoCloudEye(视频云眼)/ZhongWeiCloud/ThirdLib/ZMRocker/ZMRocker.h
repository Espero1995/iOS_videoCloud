//
//  ZMRocker.h
//  ZMRockerDemo
//
//  Created by 钱长存 on 15-1-26.
//  Copyright (c) 2015年 com.zmodo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RockStyle)
{
    RockStyleOpaque = 0,
    RockStyleTranslucent
};

typedef NS_ENUM(NSInteger, RockDirection)
{
    RockDirectionCenter = 0,
    RockDirectionUp,
    RockDirectionDown,
    RockDirectionLeft ,
    RockDirectionRight
};

@protocol ZMRockerDelegate;

@interface ZMRocker : UIView

@property (weak ,nonatomic) id <ZMRockerDelegate> delegate;
@property (nonatomic, readonly) RockDirection direction;

- (void)setRockerStyle:(RockStyle)style;

@end


@protocol ZMRockerDelegate <NSObject>
@optional
- (void)rockerDidChangeDirection:(ZMRocker *)rocker;
@end
