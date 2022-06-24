//
//  ClearCacheManager.h
//  IntelligentLife
//
//  Created by Espero on 2017/9/24.
//  Copyright © 2017年 Espero. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClearCacheManager : NSObject

///缓存搜索的数组
+(void)SearchText:(NSString *)seaTxt;
///清除缓存数组
+(void)removeAllArray;

@end
