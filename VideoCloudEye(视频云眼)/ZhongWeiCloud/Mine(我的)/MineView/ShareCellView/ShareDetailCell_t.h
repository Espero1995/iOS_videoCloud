//
//  ShareDetailCell_t.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/6.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyShareModel.h"
@class ShareDetailCell_t;
@protocol ShareDetail_tDelegete <NSObject>

- (void)ShareDetail_tCancelBtnClick:(ShareDetailCell_t *)cell;

@end
@class user_list;
@interface ShareDetailCell_t : UITableViewCell
@property (nonatomic,strong) UIImageView * headImage;//图片
@property (nonatomic,strong) UILabel *remarkNameLb;//备注
@property (nonatomic,strong) UILabel *mobileLb;//手机号码

@property (nonatomic,strong) UIButton * cancelBtn;//取消分享按钮

@property (nonatomic,weak) id<ShareDetail_tDelegete>delegete;

@end
