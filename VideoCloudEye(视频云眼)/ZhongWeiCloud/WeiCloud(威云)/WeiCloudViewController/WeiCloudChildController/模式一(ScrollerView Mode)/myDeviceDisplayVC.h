//
//  myDeviceDisplayVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/15.
//  Copyright © 2018年 张策. All rights reserved.
//


@interface myDeviceDisplayVC : BaseViewController

@property (nonatomic,assign)BOOL bIsEncrypt;
@property (nonatomic, copy) NSString * key;
/*解码器*/
@property (nonatomic,assign)JW_CIPHER_CTX cipher;
@end
