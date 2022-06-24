//
//  APModel.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/5/21.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APModel : NSObject
@property (nonatomic, copy) NSString* result;/**< 结果 */
@property (nonatomic, copy) NSString* ID;/**< id */
@property (nonatomic, copy) NSString* session;/**< 主动传给设备的session */
@property (nonatomic, copy) NSString* params;/**< 参数 */
@property (nonatomic, copy) NSString* session_params;/**< 参数里面的session */
/*
 {
 result = 1,
 id = 2,
 session = 0,
 params = {
 session = 3036900992
 }
 }
 **/

@end
