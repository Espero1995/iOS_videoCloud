//
//  DeviceSetPopUpView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/25.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceSetBtnView.h"
@protocol DeviceSetPopUpViewDelegate <NSObject>
//刷新封面
- (void)refreshCoverBtnViewClick;
//分享
- (void)shareBtnViewClick;
//云存储
- (void)cloudBtnViewClick;
//设置
- (void)setBtnViewClick;
//时光相册
- (void)timeAlbumBtnViewClick;
@end

@interface DeviceSetPopUpView : UIView

@property (nonatomic) CGFloat touchPointX;
@property (nonatomic) CGFloat touchPointY;

@property (nonatomic,strong) DeviceSetBtnView *refreshCoverBtnView;//刷新封面
@property (nonatomic,strong) DeviceSetBtnView *shareBtnView;//分享
@property (nonatomic,strong) DeviceSetBtnView *cloudBtnView;//购买云存
@property (nonatomic,strong) DeviceSetBtnView *setBtnView;//设置
@property (nonatomic,strong) DeviceSetBtnView *timeAlbumView;//时光相册
/*代理方法*/
@property (nonatomic) id<DeviceSetPopUpViewDelegate>delegate;

/**
 返回这个View
 
 @param frame view的大小
 @return 返回这个View
 */
- (instancetype)initWithframe:(CGRect) frame;

//设置弹出框视图展示
- (void)setPopUpViewShow;
@end
