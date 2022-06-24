//
//  NoTimeShaftRulerModel.h
//  TimelineDemo
//
//  Created by Espero on 2019/10/22.
//  Copyright © 2019 Joyware Electronic co., LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoTimeShaftRulerModel : NSObject

/**
 * 开始时间(时间戳)
 */
@property (nonatomic, assign) int startTimestamp;

/**
 * 结束时间(时间戳)
 */
@property (nonatomic, assign) int endTimestamp;

/**
 * 时间段/差 ( 即 开始时间 - 结束时间 )
 */
@property (nonatomic, assign) int timeInterval;

/**
 * 开始位置
 */
@property (nonatomic, assign) float startLoc;

/**
 * 结束位置
 */
@property (nonatomic, assign) float endLoc;

@end

