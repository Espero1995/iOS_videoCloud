//
//  QChooseDialog.m
//  App
//
//  Created by Espero on 2017/9/5.
//  Copyright © 2017年 Espero. All rights reserved.
//

#import "ChooseDialog.h"

@implementation ChooseDialog

+(void)createWithSystemStyle:(UINavigationController*)con Title:(NSString*)title Message:(NSString*)msg Array:(NSArray*)strArr CallBack:(void (^)(NSInteger index))callback
{
//    if ([CommonUtils isNull:title]) {
//        return;
//    }
    
    if (strArr==nil||[strArr count]==0) {
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    for (NSInteger i=0; i<strArr.count; i++) {
        UIAlertAction *btnAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@",[strArr objectAtIndex:i]] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            if (callback) {
                callback(i);
            }
        }];
       [btnAction setValue:[UIColor redColor] forKey:@"titleTextColor"];//设置颜色
        
        [alertController addAction:btnAction];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {}];//UIAlertActionStyleCancel
    
//    [cancelAction setValue:[UIColor blackColor] forKey:@"titleTextColor"];//设置颜色
    
    
    [alertController addAction:cancelAction];
    
    [con presentViewController:alertController animated:YES completion:nil];
}

@end
