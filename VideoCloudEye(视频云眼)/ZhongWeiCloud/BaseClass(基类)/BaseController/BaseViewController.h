//
//  BaseViewController.h
//  ZhongWeiEyes
//
//  Created by 张策 on 16/10/21.
//  Copyright © 2016年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
- (void)setUpNavBack;
- (void)cteateNavBtn;
- (void)createNavEmptyBtn;
- (void)createNavBlackBtn;
///返回上一页
- (void)returnVC;
@end
