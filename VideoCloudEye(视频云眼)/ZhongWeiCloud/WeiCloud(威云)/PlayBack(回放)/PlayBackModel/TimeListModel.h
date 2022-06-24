//
//  TimeListModel.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/22.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeListModel : NSObject
@property (nonatomic,copy)NSArray *histList;
@end
@interface HisTimeListModel : NSObject
@property (nonatomic,assign)float uBeginTime;
@property (nonatomic,assign)float uEndTime;
@end
