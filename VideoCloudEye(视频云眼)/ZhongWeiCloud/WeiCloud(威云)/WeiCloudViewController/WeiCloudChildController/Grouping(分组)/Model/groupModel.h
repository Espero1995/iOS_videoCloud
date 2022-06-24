//
//  groupModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/27.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface groupModel : NSObject
@property (nonatomic,copy) NSString *groupName;
@property (nonatomic,assign) BOOL isCurrent;
@property (nonatomic, copy) NSString* groupID;/**< 组的ID */

@end
