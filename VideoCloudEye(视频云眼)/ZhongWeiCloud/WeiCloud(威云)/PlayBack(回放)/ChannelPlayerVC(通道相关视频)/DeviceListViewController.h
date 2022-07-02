//
//  DeviceListViewController.h
//  ZhongWeiCloud
//
//  Created by 王攀登 on 2022/6/30.
//  Copyright © 2022 苏旋律. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ChannelCodeListModel;
@interface DeviceListViewController : UIViewController

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) NSIndexPath *selectIndex;
@property (nonatomic, copy) void (^changeDeviceBlock)(ChannelCodeListModel *model, NSIndexPath *selectIndex);

@end

@class ChannelCodeListModel;
@interface DeviceListCell : UITableViewCell

@property (nonatomic, copy) void (^changeDeviceBlock)(ChannelCodeListModel *model);
- (void)configModel:(ChannelCodeListModel *)model;
// cell选中状态
- (void)updateCellSelectedStatus:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
