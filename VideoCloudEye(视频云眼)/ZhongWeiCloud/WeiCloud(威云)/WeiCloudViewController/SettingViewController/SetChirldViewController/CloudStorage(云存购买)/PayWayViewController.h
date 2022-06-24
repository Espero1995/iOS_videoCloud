//
//  PayWayViewController.h
//  ZhongWeiCloud
//
//  Created by Espero on 2017/11/23.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
//#import "SetMealTypeModel.h"
#import "MealTypeModel.h"
@interface PayWayViewController : BaseViewController
@property (nonatomic,strong) MealTypeModel *payMealModel;
@property (nonatomic,copy) NSString  *deviceID;
@property (nonatomic, assign) BOOL isMyVCJumpTo;/**< 判断当前云存购买界面是否从【我的】界面来，或者首页【设置】来。 */

@end
