//
//  VideoModel.m
//  FFmpeg_Test
//
//  Created by 张策 on 16/11/1.
//  Copyright © 2016年 xiayuanquan. All rights reserved.
//

#import "VideoModel.h"



@implementation VideoModel
-(void)encodeWithCoder:(NSCoder *)aCoder

{
    [aCoder encodeInteger:self.nDepId forKey:@"nDepId"];
    
    [aCoder encodeInteger:self.nChannelId forKey:@"nChannelId"];

    [aCoder encodeInteger:self.uChannelType forKey:@"uChannelType"];

    [aCoder encodeInteger:self.uIsOnLine forKey:@"uIsOnLine"];

    [aCoder encodeInteger:self.uVideoState forKey:@"uVideoState"];

    [aCoder encodeInteger:self.uChannelState forKey:@"uChannelState"];

    [aCoder encodeInteger:self.uRecordState forKey:@"uRecordState"];
    
    [aCoder encodeObject:self.sFdId forKey:@"sFdId"];
    
    [aCoder encodeObject:self.sChannelName forKey:@"sChannelName"];
}

-(id)initWithCoder:(NSCoder *)aDecoder

{
    
    self = [super init];
    
    if(self)
        
    {
        
        self.nDepId = (int)[aDecoder decodeIntegerForKey:@"nDepId"];
         self.nChannelId = (int)[aDecoder decodeIntegerForKey:@"nChannelId"];
         self.uChannelType = (int)[aDecoder decodeIntegerForKey:@"uChannelType"];
         self.uIsOnLine = (int)[aDecoder decodeIntegerForKey:@"uIsOnLine"];
         self.uVideoState = (int)[aDecoder decodeIntegerForKey:@"uVideoState"];
         self.uChannelState = (int)[aDecoder decodeIntegerForKey:@"uChannelState"];
         self.uRecordState = (int)[aDecoder decodeIntegerForKey:@"uRecordState"];
        
        self.sFdId = [aDecoder decodeObjectForKey:@"sFdId"];
        
        self.sChannelName = [aDecoder decodeObjectForKey:@"sChannelName"];

    }
    return self;
}


@end
