//
//  NSArray+Extension.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/9/12.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "NSArray+Extension.h"
#import "NSDictionary+Extension.h"

@implementation NSArray (Extension)

- (NSArray *)arrayByReplacingNulls  {

    NSMutableArray *replaced = [self mutableCopy];

    const id nul = [NSNull null];

    for (int idx = 0; idx < [replaced count]; idx++) {

        id object = [replaced objectAtIndex:idx];

        if (object == nul) [replaced removeObjectAtIndex:idx];

        else if ([object isKindOfClass:[NSDictionary class]]) [replaced replaceObjectAtIndex:idx withObject:[object dictionaryByReplacingNulls]];

        else if ([object isKindOfClass:[NSArray class]]) [replaced replaceObjectAtIndex:idx withObject:[object arrayByReplacingNulls]];

    }

    return [replaced copy];
 
}

@end
