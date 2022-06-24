//
//  FingerPrintLoginVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/29.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fingerPrintLoginManage.h"

typedef void (^ReturnLoginResultBlock)(fingerLoginResult LoginResult);

@interface FingerPrintLoginVC : UIViewController
@property (nonatomic, copy) ReturnLoginResultBlock returnLoginResultBlock;

- (void)faceIDLoginResult:(ReturnLoginResultBlock)result;
@end
