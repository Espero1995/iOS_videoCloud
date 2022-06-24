//
//  SetmealSelectedCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2017/11/23.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetmealSelectedCell : UITableViewCell
//天数
@property (nonatomic,strong) UILabel *daysLabel;
//套餐类型
@property (nonatomic,strong) UILabel *typeLabel;
//价格
@property (nonatomic,strong) UILabel *priceLabel;
//推荐图片
@property (nonatomic,strong) UIImageView *recommandImg;


//是否标记为优惠的套餐
@property (nonatomic,strong) UILabel *originalPriceLabel;
//划线的label
@property (nonatomic,strong) UILabel *lineImgLabel;

//推荐图片
@property (nonatomic,strong) UIView *BoxView;
//修改选择状态
- (void)changeSelectUI;
//取消被选择的状态
- (void)cancelSelectUI;
@end
