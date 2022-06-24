//
//  LoginAccountModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/12/18.
//  Copyright © 2018 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginAccountModel : NSObject
@property (nonatomic,strong) NSString *mailStr;
@property (nonatomic,strong) NSString *phoneStr;
@property (nonatomic,assign) BOOL isPhoneLogin;
@end

