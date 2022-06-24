//
//  InputWifiView.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/25.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InputWifiView;
@protocol InputWifiViewDelegate <NSObject>

- (void)InputWifiViewBtnJoinClick:(InputWifiView *)inPutView;

@end

@interface InputWifiView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lab_wifiName;
@property (weak, nonatomic) IBOutlet UITextField *fied_passWord;
@property (nonatomic,weak)id<InputWifiViewDelegate>delegate;
+(instancetype)viewFromXib;

@end
