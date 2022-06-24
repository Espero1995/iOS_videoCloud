//
//  AlarmMsgVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/8.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmMsgVC : BaseViewController
//设备数组
@property (nonatomic,strong) NSMutableArray *myResultDeviceArr;
//首页查询告警所需的设备ID
@property (nonatomic, copy) NSString *homeDevID;
@end
