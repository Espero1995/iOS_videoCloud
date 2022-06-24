//
//  AppSettingsModel.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/7/4.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSettingsModel : NSObject
@property (nonatomic, copy) NSString* message;/**< 标记 【消息】界面的开关 开：1；关：0 */
@property (nonatomic, copy) NSString* dev;/**< 标记 【设备】界面的开关 开：1；关：0 */
@property (nonatomic, copy) NSString* find;/**< 标记 【发现】界面的开关 开：1；关：0 */
@property (nonatomic, copy) NSString* mine;/**< 标记 【我的】界面的开关 开：1；关：0 */

@end
