//
//  WeiCloudShareView.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/12.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+ScottAlertView.h"
#import <ContactsUI/ContactsUI.h>

@class WeiCloudShareView;
@protocol WeiCloudShareViewDelegate <NSObject>
//电话本按钮
- (void)weiCloudShareBtnPhoneClick;
- (void)weiCloudShareBtnShareClick:(WeiCloudShareView *)shareView;
@optional
- (void)weiCloudShareBtnCancelClick;


@end
@interface WeiCloudShareView : UIView
@property (nonatomic,weak)id<WeiCloudShareViewDelegate>shareDelegate;
@property (weak, nonatomic) IBOutlet UITextField *fied_phone;

+(instancetype)viewFromXib;
@end
