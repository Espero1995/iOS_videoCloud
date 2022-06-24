//
//  MessageCell_t.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 17/2/15.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell_t : UITableViewCell
/*图片*/
@property (nonatomic,strong) UIImageView * headImage;
/*提醒图片*/
@property (nonatomic,strong) UIImageView * attentionImage;
/*名称*/
@property (nonatomic,strong) UILabel * NameLabel;
/*消息*/
@property (nonatomic,strong) UILabel * MessageLabel;
/*时间*/
@property (nonatomic,strong) UILabel * TimeLabel;
/*标签图片*/
@property (nonatomic,strong) UIImageView *iconImage;

@end
