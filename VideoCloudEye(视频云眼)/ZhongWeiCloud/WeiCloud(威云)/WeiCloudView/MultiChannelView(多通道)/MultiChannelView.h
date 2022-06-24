//
//  MultiChannelView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2019/11/12.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MultiChannelModel;
@class chansModel;
@protocol MultiChannelViewDelegate <NSObject>
//单设备多通道
- (void)didSelectedCellIndex:(NSIndexPath *)index withChannelModel:(MultiChannelModel *)channelModel;
//该列表下的多通道【区别于上面的方法：此处的多通道时由在获取设备列表时获得】
- (void)didSelectedCellIndex:(NSIndexPath *)index withChansModel:(chansModel *)model;
//该列表下所有设备展示
@optional
- (void)didSelectedCellIndex:(NSIndexPath *)index WithDeviceModel:(dev_list *)deviceModel isNVR:(BOOL)isNvr;



@end

@interface MultiChannelView : UIView

@property (nonatomic,weak)id<MultiChannelViewDelegate>channelDelegate;

/**
 返回这个View
 @param frame view的大小
 @param isMultiChannel 是否是多通道
 @param devId 设备Id
 @param model 设备model
 @return 返回这个View
 */
- (instancetype)initWithFrame:(CGRect)frame isMultiChannel:(BOOL)isMultiChannel devId:(NSString *)devId andDevModel:(dev_list *)model;

@end

