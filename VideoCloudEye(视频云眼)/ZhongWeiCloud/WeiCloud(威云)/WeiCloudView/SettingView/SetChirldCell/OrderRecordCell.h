//
//  OrderRecordCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2017/12/5.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderRecordCell : UITableViewCell
//套餐类型
@property (nonatomic,strong) UILabel *typeLb;
//生效时间
@property (nonatomic,strong) UILabel * effectTimeLb;
//到期时间
@property (nonatomic,strong) UILabel * expireTimeLb;

@end
