//
//  ShareDetailCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/9/3.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ShareDetailCell;
@protocol ShareDetailCellDelegate <NSObject>
- (void)ShareDetailRemarkClick:(ShareDetailCell *)cell;
@end

@interface ShareDetailCell : UITableViewCell
@property (nonatomic,strong) UIImageView * headImage;//图片
@property (nonatomic,strong) UILabel *remarkNameLb;//备注
@property (nonatomic,strong) UILabel *mobileLb;//手机号码
@property (nonatomic,strong) UIButton *remarksBtn;//备注按钮

@property (nonatomic,weak) id<ShareDetailCellDelegate>delegate;
@end
