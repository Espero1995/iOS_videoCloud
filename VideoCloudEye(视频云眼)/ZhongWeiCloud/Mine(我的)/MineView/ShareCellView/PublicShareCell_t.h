//
//  PublicShareCell_t.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/8.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyShareModel.h"
@class shared;
@interface PublicShareCell_t : UITableViewCell
/*图片*/
@property (nonatomic,strong) UIImageView * headImage;
/*名称*/
@property (nonatomic,strong) UILabel * NameLabel;
/*消息*/
@property (nonatomic,strong) UILabel * MessageLabel;
/**/
@property (nonatomic,strong) UILabel * idLabel;
/**/
@property (nonatomic,strong) shared * lis_model;

- (void)setModel:(shared *)model;
@end
