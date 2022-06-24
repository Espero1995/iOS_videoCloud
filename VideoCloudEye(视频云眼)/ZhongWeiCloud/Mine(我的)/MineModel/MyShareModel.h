//
//  MyShareModel.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/10.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
@class shared;
@interface MyShareModel : NSObject
@property (nonatomic,copy) NSString * deviceID;
@property (nonatomic,copy) NSString * name;
@property (nonatomic,copy) NSArray <shared *>* userList;
@end

@interface shared : NSObject;
@property (nonatomic,copy)NSString *ID;//id
@property (nonatomic,copy)NSString *name;//设备名称
@property (nonatomic,copy)NSString *mobile;//设备名称
@property (nonatomic,copy)NSString *mail;//邮箱
@property (nonatomic,copy)NSString *remarks;//用户名
@end

//
//@interface MyShareModel : NSObject
//
//
//@property (nonatomic,copy)NSArray * shared;
//
//
//@end
//@interface shared : NSObject;
//
//@property (nonatomic,copy)NSMutableString *ID;//id
//@property (nonatomic,copy)NSString *name;//设备名称
//@property (nonatomic,copy)NSString *mobile;//设备名称
//@property (nonatomic,copy)NSString *mail;//邮箱
//@property (nonatomic,copy)NSString *remarks;//用户名
//@property (nonatomic,strong) NSMutableArray * user_list;
//
//@end
//@interface  user_list: NSObject
//
//@property (nonatomic,copy) NSString * user_id;
//
//@property (nonatomic,copy) NSString * name;
//
//@end
