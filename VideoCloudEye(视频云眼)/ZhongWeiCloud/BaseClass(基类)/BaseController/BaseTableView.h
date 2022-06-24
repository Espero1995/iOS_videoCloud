//
//  BaseTableView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/13.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableView : UITableView
///设置无网络时的图片
- (void)set_noNetWork_img:(UIImage*)image andTip:(NSString *)tip;
@end
