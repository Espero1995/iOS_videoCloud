//
//  MyShareModel.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/10.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "MyShareModel.h"

@implementation MyShareModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"deviceID": @"id",
             @"userList":@"user_list",
             };
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.deviceID forKey:@"deviceID"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.userList forKey:@"userList"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.name =[aDecoder decodeObjectForKey:@"name"];
        self.deviceID =[aDecoder decodeObjectForKey:@"deviceID"];
        self.userList =[aDecoder decodeObjectForKey:@"userList"];
    }
    return self;
}


@end

@implementation shared

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"ID": @"id"};
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.mobile forKey:@"mobile"];
    [aCoder encodeObject:self.mail forKey:@"mail"];
    [aCoder encodeObject:self.remarks forKey:@"remarks"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.ID =[aDecoder decodeObjectForKey:@"ID"];
        self.name =[aDecoder decodeObjectForKey:@"name"];
        self.mobile =[aDecoder decodeObjectForKey:@"mobile"];
        self.mail =[aDecoder decodeObjectForKey:@"mail"];
        self.remarks =[aDecoder decodeObjectForKey:@"remarks"];
    }
    return self;
}


@end
