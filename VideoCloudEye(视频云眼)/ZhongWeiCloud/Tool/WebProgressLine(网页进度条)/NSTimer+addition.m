//
//  NSTimer+addition.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/10.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "NSTimer+addition.h"

@implementation NSTimer (addition)
- (void)pause {
    if (!self.isValid) return;
    [self setFireDate:[NSDate distantFuture]];
}

- (void)resume {
    if (!self.isValid) return;
    [self setFireDate:[NSDate date]];
}

- (void)resumeWithTimeInterval:(NSTimeInterval)time {
    if (!self.isValid) return;
    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:time]];
}

+ (NSTimer *)subScheduledTimerWithTimeInterval:(NSTimeInterval)ti repeats:(BOOL)yesOrNo block:(void(^)(NSTimer *timer))block {
    
    return [self scheduledTimerWithTimeInterval:ti target:self selector:@selector(timeFired:) userInfo:block repeats:yesOrNo];
}

+ (void)timeFired:(NSTimer *)timer {
    void(^block)(NSTimer *timer) = timer.userInfo;
    
    if (block) {
        block(timer);
    }
}
@end
