//
//  smallScreenFolderVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2019/10/17.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface smallScreenFolderVC : BaseViewController
@property (nonatomic,assign)BOOL bIsEncrypt;
@property (nonatomic, copy) NSString * key;
/*解码器*/
@property (nonatomic,assign)JW_CIPHER_CTX cipher;
/*查询该文件夹的设备列表所需的parentID*/
@property (nonatomic,copy) NSString *nodeId;
@end
