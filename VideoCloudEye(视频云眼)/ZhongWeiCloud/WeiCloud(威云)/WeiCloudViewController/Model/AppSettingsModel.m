//
//  AppSettingsModel.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/7/4.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "AppSettingsModel.h"


@implementation AppSettingsModel
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.message forKey:@"message_AppSetting"];
    [aCoder encodeObject:self.dev forKey:@"dev_AppSetting"];
    [aCoder encodeObject:self.find forKey:@"find_AppSetting"];
    [aCoder encodeObject:self.mine forKey:@"mine_AppSetting"];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.message = [aDecoder decodeObjectForKey:@"message_AppSetting"];
        self.dev = [aDecoder decodeObjectForKey:@"dev_AppSetting"];
        self.find = [aDecoder decodeObjectForKey:@"find_AppSetting"];
        self.mine = [aDecoder decodeObjectForKey:@"mine_AppSetting"];
    }
    return self;
}
@end
