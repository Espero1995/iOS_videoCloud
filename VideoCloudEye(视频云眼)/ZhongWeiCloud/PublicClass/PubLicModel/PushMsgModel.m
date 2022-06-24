//
//  PushMsgModel.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/24.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "PushMsgModel.h"

@implementation PushMsgModel
-(void)encodeWithCoder:(NSCoder *)aCoder

{
    [aCoder encodeObject:self.alarmId forKey:@"alarmId"];
    
    [aCoder encodeObject:self.deviceId forKey:@"deviceId"];
    [aCoder encodeObject:self.deviceName forKey:@"deviceName"];
    [aCoder encodeObject:self.alarmPic forKey:@"alarmPic"];

    [aCoder encodeInteger:self.alarmType forKey:@"alarmType"];
    [aCoder encodeInteger:self.alarmTime forKey:@"alarmTime"];

    [aCoder encodeBool:self.markread forKey:@"markread"];
}

-(id)initWithCoder:(NSCoder *)aDecoder

{
    
    self = [super init];
    
    if(self)
        
    {
        self.alarmId =[aDecoder decodeObjectForKey:@"alarmId"];
        self.deviceId =[aDecoder decodeObjectForKey:@"deviceId"];
        self.deviceName =[aDecoder decodeObjectForKey:@"deviceName"];
        self.alarmPic =[aDecoder decodeObjectForKey:@"alarmPic"];
        self.alarmType = (int)[aDecoder decodeIntegerForKey:@"alarmType"];
        self.alarmTime = (int)[aDecoder decodeIntegerForKey:@"alarmTime"];
        self.markread = [aDecoder decodeBoolForKey:@"markread"];
    }
    return self;
}

@end
