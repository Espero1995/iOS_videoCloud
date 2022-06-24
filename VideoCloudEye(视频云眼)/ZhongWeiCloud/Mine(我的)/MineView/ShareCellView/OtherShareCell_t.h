//
//  OtherShareCell_t.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/10.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OtherShareModel.h"
@class OtherShareCell_t;
@protocol otherShareDelegate<NSObject>
- (void)cancelShareBtnClick:(OtherShareCell_t *)cell;

@end

@class others_shared;
@interface OtherShareCell_t : UITableViewCell
/*图片*/
@property (nonatomic,strong) UIImageView * headImage;
/*名称*/
@property (nonatomic,strong) UILabel * NameLabel;
/*消息*/
@property (nonatomic,strong) UILabel * MessageLabel;
/**/
@property (nonatomic,strong) others_shared * lis_model;
/**
 * 取消分享按钮
 */
@property (nonatomic, strong) UIButton* cancelShareBtn;
/**
 * 代理指针
 */
@property (nonatomic, assign) id<otherShareDelegate>delegate;



- (void)setModel:(others_shared *)model;

@end
