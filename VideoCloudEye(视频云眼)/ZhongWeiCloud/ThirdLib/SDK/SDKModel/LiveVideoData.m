//
//  LiveVideoData.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/1/25.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "LiveVideoData.h"

@implementation LiveVideoData

@synthesize data;
@synthesize dataLen;
@synthesize utcTimeStamp;
@synthesize timeStamp;
@synthesize frameType;
@synthesize codecId;
@synthesize avcPacketType;
@synthesize compositionTime;
- (id) init {
    self = [super init];
    if (self) {
        data = NULL;
        dataLen = 0;
        frameType = 0;
        utcTimeStamp = 0;
        timeStamp = 0;
        codecId = 0;
        avcPacketType = 0;
        compositionTime = 0;
    }
    return self;
}

- (void) dealloc {
    if(data != NULL)
        free(data);
}
@end
