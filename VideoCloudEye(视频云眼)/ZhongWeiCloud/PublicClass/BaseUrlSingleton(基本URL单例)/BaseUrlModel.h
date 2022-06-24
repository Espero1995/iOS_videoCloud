//
//  BaseUrlModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/11/8.
//  Copyright © 2018 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseUrlModel : NSObject
//广告URL
@property (nonatomic, strong) NSArray *advertisingUrl;
//用户协议URL
@property (nonatomic, copy) NSString *userAgreementUrl;
//APP帮助文档URL
@property (nonatomic, copy) NSString *appHelpUrl;
//APP下载页URL
@property (nonatomic, copy) NSString *appDownloadUrl;
//轮播图基础URL
@property (nonatomic, copy) NSString *bannerBaseUrl;
@end

