//
//  LocBannerView.h
//  HybridDevelopedApp
//
//  Created by Espero on 2019/1/14.
//  Copyright © 2019 Espero. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LocBannerView;

/**
 * @brief 轮播图代理方法
 * @author Espero
 * @version 1.0
 */
@protocol LocBannerViewDelegate <NSObject>

/**
 * @discussion 协议方法实现方式
 * optional 可选 (默认是必须实现的)
 */
@optional
/**
 * @brief 轮播图点击代理协议方法
 * @param bannerView 点击的轮播图
 * @param currentIndex 当前点击的位置
 */
- (void)selectImage:(LocBannerView *)bannerView currentImage:(NSInteger)currentIndex;

@end

@interface LocBannerView : UIView
/**
 * @discussion 代理属性
 */
@property (nonatomic, weak) id <LocBannerViewDelegate> delegate;

/**
 * @brief 销毁定时器类方法
 * @discussion 在Controller销毁时销毁定时器
 */
+ (void)destroyTimer;

/**
 * @brief 声明一个自定义的构造方法
 * @discussion 让外界的对象用来初始化bannerView并展示
 * @param addImageArray banner的数据源(本地图片名数组)
 * @return self
 */
- (id)initWithFrame:(CGRect)frame andImageArray:(NSMutableArray *)addImageArray;

@end
