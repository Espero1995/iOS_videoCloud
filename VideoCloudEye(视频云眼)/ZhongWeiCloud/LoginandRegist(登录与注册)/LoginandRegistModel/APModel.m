//
//  APModel.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/5/21.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "APModel.h"

@implementation APModel
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.result forKey:@"result"];
    [aCoder encodeObject:self.ID forKey:@"ID_apModel"];
    [aCoder encodeObject:self.session forKey:@"session_apModel"];
    [aCoder encodeObject:self.params forKey:@"params"];
    [aCoder encodeObject:self.session_params forKey:@"session_params"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.result =[aDecoder decodeObjectForKey:@"result"];
        self.ID =[aDecoder decodeObjectForKey:@"ID_apModel"];
        self.session =[aDecoder decodeObjectForKey:@"session_apModel"];
        self.params =[aDecoder decodeObjectForKey:@"params"];
        self.session_params =[aDecoder decodeObjectForKey:@"session_params"];
    }
    return self;
}

@end
