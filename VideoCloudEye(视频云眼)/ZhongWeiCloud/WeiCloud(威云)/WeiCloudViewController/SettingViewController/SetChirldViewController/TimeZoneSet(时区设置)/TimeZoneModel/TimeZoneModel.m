//
//  TimeZoneModel.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/12/29.
//  Copyright © 2018 张策. All rights reserved.
//

#import "TimeZoneModel.h"

@implementation TimeZoneModel
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.timeZone forKey:@"timeZone"];
    [aCoder encodeObject:self.dayLight forKey:@"dayLight"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.timeZone =[aDecoder decodeObjectForKey:@"timeZone"];
        self.dayLight =[aDecoder decodeObjectForKey:@"dayLight"];
    }
    return self;
}
@end

@implementation dayLightModel
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:(int)self.Type forKey:@"Type"];
    [aCoder encodeInteger:(int)self.Offset forKey:@"Offset"];
    [aCoder encodeObject:self.BeginDate forKey:@"BeginDate"];
    [aCoder encodeObject:self.EndDate forKey:@"EndDate"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.Type = (int)[aDecoder decodeIntegerForKey:@"Type"];
        self.Offset = (int)[aDecoder decodeIntegerForKey:@"Offset"];
        self.BeginDate =[aDecoder decodeObjectForKey:@"BeginDate"];
        self.EndDate =[aDecoder decodeObjectForKey:@"EndDate"];
    }
    return self;
}
@end
