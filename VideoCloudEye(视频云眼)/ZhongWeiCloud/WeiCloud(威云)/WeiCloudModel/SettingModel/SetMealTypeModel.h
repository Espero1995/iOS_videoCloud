//
//  SetMealTypeModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2017/11/23.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetMealTypeModel : NSObject
//录像保存天数
@property (nonatomic,copy) NSString *days;
//套餐类型
@property (nonatomic,copy) NSString *type;
//套餐价格
@property (nonatomic,copy) NSString *price;
//是否是推荐类型
@property (nonatomic,assign) NSInteger isRecommend;
@end
