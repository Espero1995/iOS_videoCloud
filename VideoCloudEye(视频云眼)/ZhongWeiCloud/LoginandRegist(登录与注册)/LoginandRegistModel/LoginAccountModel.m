//
//  LoginAccountModel.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/12/18.
//  Copyright © 2018 张策. All rights reserved.
//

#import "LoginAccountModel.h"

@implementation LoginAccountModel

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.phoneStr forKey:@"phoneStr"];
    [aCoder encodeObject:self.mailStr forKey:@"mailStr"];
    [aCoder encodeInteger:self.isPhoneLogin forKey:@"isPhoneLogin"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self){
        self.phoneStr = [aDecoder decodeObjectForKey:@"phoneStr"];
        self.mailStr = [aDecoder decodeObjectForKey:@"mailStr"];
        self.isPhoneLogin = (int)[aDecoder decodeIntegerForKey:@"isPhoneLogin"];
    }
    return self;
}
@end
