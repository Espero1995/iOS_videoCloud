//
//  AdvertiseView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/30.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kUserDefaults [NSUserDefaults standardUserDefaults]
static NSString *const adImageName = @"adImageName";
static NSString *const adUrl = @"adUrl";
@interface AdvertiseView : UIView

/** 显示广告页面方法*/
- (void)show;

/** 图片路径*/
@property (nonatomic, copy) NSString *filePath;
/**请求出错的时候的图片*/
@property (nonatomic, strong) UIImage *defaultImg;
@end
