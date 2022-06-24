//
//  AdvertiseVC.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/1.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^ CustomAdvertisementViewClickBlock)(void);
typedef void (^ CustomSkipButtonClickBlock)(void);
@interface AdvertiseVC : UIViewController
///图片链接
@property (nonatomic,copy) NSString *imageUrl;
@property (nonatomic,strong) AdUrlModel *adModel;
///持续时间
@property (nonatomic,assign) NSInteger duration;
///是否加载成功
@property (nonatomic,assign) BOOL isLoadSuccess;
///图片点击的block
@property (nonatomic,copy) CustomAdvertisementViewClickBlock imageClickBlock;
///跳过按钮的block
@property (nonatomic,copy) CustomSkipButtonClickBlock skipButtonClickBlock;

@end
