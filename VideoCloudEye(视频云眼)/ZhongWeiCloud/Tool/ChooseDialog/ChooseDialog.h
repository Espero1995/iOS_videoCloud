//
//  QChooseDialog.h
//  App
//
//  Created by Espero on 2017/9/5.
//  Copyright © 2017年 Espero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseDialog : NSObject

///显示选择框(系统样式)，title，arr必须
+(void)createWithSystemStyle:(UINavigationController*)con Title:(NSString*)title Message:(NSString*)msg Array:(NSArray*)strArr CallBack:(void (^)(NSInteger index))callback;

@end
