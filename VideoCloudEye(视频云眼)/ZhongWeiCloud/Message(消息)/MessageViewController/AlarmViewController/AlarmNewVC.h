//
//  AlarmNewVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/12.
//  Copyright © 2018年 张策. All rights reserved.
//


@interface AlarmNewVC : BaseViewController

@property (nonatomic,copy) NSString * timeString;
@property (nonatomic,assign)BOOL bIsEncrypt;
@property (nonatomic, copy) NSString * key;
/*解码器*/
@property (nonatomic,assign)JW_CIPHER_CTX cipher;
//设备数组
@property (nonatomic,strong) NSMutableArray *myResultDeviceArr;

@end
