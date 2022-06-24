//
//  MyCloudMealCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/26.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

/*代理协议*/
@protocol MyCloudMealCellDelegate <NSObject>
//立即使用
- (void)MyCloudMealCellExtendedUserClick;
@end

@interface MyCloudMealCell : UITableViewCell
/*套餐计划*/
@property (strong, nonatomic) IBOutlet UILabel *mealPlan_lb;
/*生效日期*/
@property (strong, nonatomic) IBOutlet UILabel *effectiveDate_lb;
/*立即使用的按钮*/
@property (strong, nonatomic) IBOutlet UIButton *extendedUserBtn;

/*代理协议*/
@property (nonatomic,weak)id<MyCloudMealCellDelegate>cellDelegate;

@end
