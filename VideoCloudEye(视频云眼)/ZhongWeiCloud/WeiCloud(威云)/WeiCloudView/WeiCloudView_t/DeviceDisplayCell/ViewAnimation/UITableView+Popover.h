//
//  UITableView+Popover.h
//  SSTableViewPopover
//
//  Created by Mrss on 16/1/26.
//  Copyright © 2016年 expai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PopoverItem;
typedef NS_ENUM(NSInteger, ShowPopoverType) {
   ShowPopoverType_LineStyle = 1,    //一条直线样式
   ShowPopoverType_four_SquareStyle, //4个item，方块样式
};

typedef void(^PopoverItemSelectHandler)(PopoverItem *popoverItem);

@interface PopoverItem : NSObject

@property (nonatomic,readonly,  copy) NSString *name;
@property (nonatomic,readonly,strong) UIImage *image;
@property (nonatomic,readonly,  copy) PopoverItemSelectHandler handler;

+ (instancetype)itemWithName:(NSString *)name
                       image:(UIImage *)image
             selectedHandler:(PopoverItemSelectHandler)handler;

@end

@interface UITableView (Popover)

- (void)showPopoverWithItems:(NSArray <PopoverItem *>*)items
                   ShowStyle:(ShowPopoverType)showStyle
                forIndexPath:(NSIndexPath *)indexPath;
- (void)removePopView;
@end
