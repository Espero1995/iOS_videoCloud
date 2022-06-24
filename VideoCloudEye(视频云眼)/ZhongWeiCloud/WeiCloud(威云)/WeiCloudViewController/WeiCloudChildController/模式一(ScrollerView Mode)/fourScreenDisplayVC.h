//
//  fourScreenDisplayVC.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/7/20.
//  Copyright © 2018年 张策. All rights reserved.
//


@interface fourScreenDisplayVC : BaseViewController

@property (nonatomic,assign)BOOL bIsEncrypt;
@property (nonatomic, copy) NSString * key;
/*解码器*/
@property (nonatomic,assign)JW_CIPHER_CTX cipher;

@end
