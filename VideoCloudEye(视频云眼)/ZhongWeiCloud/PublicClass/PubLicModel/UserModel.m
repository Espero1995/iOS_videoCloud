//
//  UsetModel.m
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/20.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "UserModel.h"
#import "NSString+Md5String.h"

@implementation UserModel


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

}

- (void)setImg:(NSString *)img
{
    _img = [NSString isNullToString:img];
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.user_id forKey:@"user_id"];
    [aCoder encodeObject:self.user_name forKey:@"user_name"];
    [aCoder encodeObject:self.mobile forKey:@"mobile"];
    [aCoder encodeObject:self.mail forKey:@"mail"];
    [aCoder encodeObject:self.img forKey:@"img"];
    [aCoder encodeObject:self.access_token forKey:@"access_token"];
    [aCoder encodeObject:self.refresh_token forKey:@"refresh_token"];
    [aCoder encodeInteger:self.expires_in forKey:@"expires_in"];
    [aCoder encodeInteger:self.accountType forKey:@"accountType"];
    [aCoder encodeInteger:self.user_type forKey:@"user_type"];
    [aCoder encodeObject:self.refreshTime forKey:@"refreshTime"];
    [aCoder encodeBool:self.isRefreshTimeSucceed forKey:@"isRefreshTimeSucceed"];
    [aCoder encodeObject:self.wechat_id forKey:@"wechat_id"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self){
        self.user_id =[aDecoder decodeObjectForKey:@"user_id"];
        self.user_name =[aDecoder decodeObjectForKey:@"user_name"];
        self.mobile =[aDecoder decodeObjectForKey:@"mobile"];
        self.mail =[aDecoder decodeObjectForKey:@"mail"];
        self.img =[aDecoder decodeObjectForKey:@"img"];
        self.access_token =[aDecoder decodeObjectForKey:@"access_token"];
        self.refresh_token =[aDecoder decodeObjectForKey:@"refresh_token"];
        self.expires_in = (int)[aDecoder decodeIntegerForKey:@"expires_in"];
        self.accountType = (int)[aDecoder decodeIntegerForKey:@"accountType"];
        self.user_type = (int)[aDecoder decodeIntegerForKey:@"user_type"];
        self.refreshTime =[aDecoder decodeObjectForKey:@"refreshTime"];
        self.isRefreshTimeSucceed = [aDecoder decodeBoolForKey:@"isRefreshTimeSucceed"];
        self.wechat_id =[aDecoder decodeObjectForKey:@"wechat_id"];
    }
    return self;
}
@end
