//
//  TimeZoneModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/12/29.
//  Copyright © 2018 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
@class dayLightModel;

@interface TimeZoneModel : NSObject
@property (nonatomic,copy) NSString *timeZone;
@property (nonatomic,strong) dayLightModel *dayLight;
@end

@interface dayLightModel : NSObject
@property (nonatomic,assign) int Type;
@property (nonatomic,assign) int Offset;
@property (nonatomic,copy) NSString *BeginDate;
@property (nonatomic,copy) NSString *EndDate;
@end

