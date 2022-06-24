//
//  ValueAddedCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/10.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ValueAddedCellDelegate<NSObject>
- (void) CloudStorageViewClick;//云存储
@end
@interface ValueAddedCell : UITableViewCell
@property (nonatomic,weak)id<ValueAddedCellDelegate>delegate;
@end
