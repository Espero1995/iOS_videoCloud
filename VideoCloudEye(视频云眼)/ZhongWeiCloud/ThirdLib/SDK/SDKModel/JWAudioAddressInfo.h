//
//  JWAudioAddressInfo.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/5/5.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
/// 此类视频地址相关对象

@class talk_addr;
@interface JWAudioAddressInfo : NSObject
@property (nonatomic,copy)NSString *talk_id;//对讲id

@property (nonatomic,strong)talk_addr *talk_addr;
@end

@interface talk_addr : NSObject
//对讲地址
@property (nonatomic,copy)NSString * t_ip;
//对讲端口端口
@property (nonatomic,assign)int t_port;

@end
