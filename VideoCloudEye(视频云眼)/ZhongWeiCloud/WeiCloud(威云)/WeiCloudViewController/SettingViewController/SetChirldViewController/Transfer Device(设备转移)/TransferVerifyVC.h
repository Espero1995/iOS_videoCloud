//
//  TransferVerifyVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/4/8.
//  Copyright © 2018年 张策. All rights reserved.
//


@interface TransferVerifyVC : BaseViewController
/**
 * 用户想要转移的目标手机号
 */
@property (nonatomic, copy) NSString* transMobile;
/**
 * 用户想转移的设备id
 */
@property (nonatomic, copy) NSString* transDevId;


@end
