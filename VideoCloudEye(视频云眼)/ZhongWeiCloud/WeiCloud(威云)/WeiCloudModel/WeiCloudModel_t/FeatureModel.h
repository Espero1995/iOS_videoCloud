//
//  FeatureModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/2/3.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeatureModel : NSObject
/*1.是否支持WiFi*/
@property (nonatomic,assign)int isWiFi;
/*2.是否支持对讲*/
@property (nonatomic,assign)int isTalk;
/*3.是否支持云平台*/
@property (nonatomic,assign)int isCloudDeck;
/*4.是否支持云存储*/
@property (nonatomic,assign)int isCloudStorage;
/*5.是否支持P2P */
@property (nonatomic,assign)int isP2P;
@end
