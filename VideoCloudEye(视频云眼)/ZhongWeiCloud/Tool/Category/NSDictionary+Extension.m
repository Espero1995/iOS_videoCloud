//
//  NSDictionary+Extension.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/9/12.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "NSDictionary+Extension.h"

#import "NSArray+Extension.h"

@implementation NSDictionary (Extension)

- (NSDictionary *)dictionaryByReplacingNulls {

    const NSMutableDictionary *replaced = [self mutableCopy];

    const id nul = [NSNull null];

    for (NSString *key in self) {

        id object = [self objectForKey:key];

        if (object == nul) [replaced removeObjectForKey:key];

        else if ([object isKindOfClass:[NSDictionary class]]) [replaced setObject:[object dictionaryByReplacingNulls] forKey:key];

        else if ([object isKindOfClass:[NSArray class]]) [replaced setObject:[object arrayByReplacingNulls] forKey:key];
  
    }

    return [NSDictionary dictionaryWithDictionary:[replaced copy]];
  
}

@end
