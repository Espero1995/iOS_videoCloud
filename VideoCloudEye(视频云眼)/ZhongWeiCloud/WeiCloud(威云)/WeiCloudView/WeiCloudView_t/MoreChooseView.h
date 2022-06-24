//
//  MoreChooseView.h
//  封装二级选择列表
//
//  Created by 张策 on 16/10/27.
//  Copyright © 2016年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Masonry.h"
#define  SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define  SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
@class dev_list;
@protocol MoreChooseViewDelegate <NSObject>

- (void)pushSelectDataArr:(NSMutableArray *)selectDataArr;
- (void)didSelectedCellIndex:(NSIndexPath *)index WithDeviceModel:(dev_list *)deviceModel isNVR:(BOOL)isNvr;
@end

@interface MoreChooseView : UIView
@property (nonatomic,weak)id<MoreChooseViewDelegate>moreDelegate;
@property (nonatomic,assign)BOOL isSingle;
- (void)loadList;
@end
