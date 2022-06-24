//
//  MyShareCell_t.h
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/10.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyShareModel.h"
@interface MyShareCell_t : UITableViewCell
/*图片*/
@property (nonatomic,strong) UIImageView * headImage;
/*名称*/
@property (nonatomic,strong) UILabel * NameLabel;
/*消息*/
@property (nonatomic,strong) UILabel * MessageLabel;

@end
