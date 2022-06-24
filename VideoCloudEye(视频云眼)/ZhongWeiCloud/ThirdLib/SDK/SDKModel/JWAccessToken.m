//
//  ZWAccessToken.m
//  ZWCloudSdk
//
//  Created by 张策 on 17/4/11.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "JWAccessToken.h"

@interface JWAccessToken ()<NSCoding>

@end

@implementation JWAccessToken
-(void)encodeWithCoder:(NSCoder *)aCoder

{
    [aCoder encodeObject:self.accessToken forKey:@"accessToken"];
    [aCoder encodeInteger:self.expire forKey:@"expire"];
    
    [aCoder encodeObject:self.userid forKey:@"userId"];
    
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.accessToken =[aDecoder decodeObjectForKey:@"accessToken"];
        self.expire = (int)[aDecoder decodeIntegerForKey:@"expire"];
        self.userid = [aDecoder decodeObjectForKey:@"userId"];
    }
    return self;
}

@end
