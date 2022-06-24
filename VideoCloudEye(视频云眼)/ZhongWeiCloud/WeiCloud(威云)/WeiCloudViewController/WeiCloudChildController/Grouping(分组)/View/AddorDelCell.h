//
//  AddorDelCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/29.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AddorDelCellDelegate <NSObject>
/*
 * 添加设备
 */
- (void)addDevClick;
/*
 * 移除设备
 */
- (void)deleteDevClick;
@end

@interface AddorDelCell : UITableViewCell
@property (nonatomic, weak) id<AddorDelCellDelegate> delegate;
@property (nonatomic, assign) BOOL isMyDevGroup;
@property (nonatomic, strong) NSArray *devModelArr;
@end
