//
//  TBMALaw2PCMConverter.h
//  ProjectLibrary
//
//  Created by alby ho on 12-9-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBMALaw2PCMConverter : NSObject

+ (NSData *)decodeWithData:(NSData *)data;
+ (NSData *)encodeWithData:(NSData *)data;

@end
