//
//  LiveListModel.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/1/24.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveListModel : NSObject
@property (nonatomic,strong)NSArray * liveChans;
@end

@interface liveChans : NSObject
@property (nonatomic,assign) NSInteger status;
@property (nonatomic,copy) NSString * dev_id;
@property (nonatomic,copy) NSString * chan_id;
@property (nonatomic,copy) NSString * cover_uri;
@property (nonatomic,strong)NSMutableDictionary * play_info;//包含了hls_uri  rtmp_uri  state  start_time  mrts
@property (nonatomic,copy) NSString * name;
@property (nonatomic,copy) NSString * desc;
- (void)setValue:(id)value forUndefinedKey:(NSString *)key;
@end
