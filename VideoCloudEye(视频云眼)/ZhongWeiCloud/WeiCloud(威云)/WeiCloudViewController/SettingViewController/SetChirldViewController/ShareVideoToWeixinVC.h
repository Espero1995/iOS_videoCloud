//
//  ShareVideoToWeixinVC.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/5/10.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareVideoToWeixinVC : BaseViewController
/**
 * 要分享的当前视频的截图
 */
@property (nonatomic, strong) UIImage* currentVideo_CutImage;

/**
 * devid
 */
@property (nonatomic, copy) NSString* dev_id;
/**
 * devName
 */
@property (nonatomic, copy) NSString* devName;
@end
