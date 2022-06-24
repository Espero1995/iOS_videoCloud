//
//  AlarmViewController.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/16.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface AlarmViewController : BaseViewController

@property (nonatomic,copy) NSString * timeString;

@property (nonatomic,assign)BOOL bIsEncrypt;

@property (nonatomic, copy) NSString * key;

@property (nonatomic,assign)JW_CIPHER_CTX cipher;//解码器
@end
