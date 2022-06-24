//
//  MyFunctionCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/10.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyFunctionCellDelegate<NSObject>
- (void) myFileViewClick;//文件
- (void) myShareViewClick;//设备分享
- (void) myHelpViewClick;//常见问题
//- (void) myServiceViewClick;//客服中心
@end

@interface MyFunctionCell : UITableViewCell
@property (nonatomic,weak)id<MyFunctionCellDelegate>delegate;
@end
