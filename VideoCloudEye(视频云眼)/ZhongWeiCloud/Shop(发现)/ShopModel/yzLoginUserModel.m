//
//  yzLoginUserModel.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/6/20.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "yzLoginUserModel.h"

@implementation yzLoginUserModel
-(void)encodeWithCoder:(NSCoder *)aCoder

{
    [aCoder encodeObject:self.access_token forKey:@"access_token_youzan"];
    [aCoder encodeObject:self.cookie_key forKey:@"cookie_key_youzan"];
    [aCoder encodeObject:self.cookie_value forKey:@"cookie_value_youzan"];
}

-(id)initWithCoder:(NSCoder *)aDecoder

{
    self = [super init];
    
    if(self)
    
    {
        self.access_token =[aDecoder decodeObjectForKey:@"access_token_youzan"];
        self.cookie_key =[aDecoder decodeObjectForKey:@"cookie_key_youzan"];
        self.cookie_value =[aDecoder decodeObjectForKey:@"cookie_value_youzan"];
    }
    return self;
}
@end
