//
//  SetScopeTimeCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/5/21.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetScopeTimeCell : UITableViewCell

@property (nonatomic,strong) UILabel* scopeTimeLb;//时间范围
@property (nonatomic,strong) UILabel *scopeTipLb;//范围提示语
@property (nonatomic,strong) UIButton* chooseBtn;//选择按钮
@property (nonatomic,strong) UIImageView *isChoosedImg;//是否选择的图片
@end
