//
//  CommonMacros.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/3/21.
//  Copyright © 2018年 张策. All rights reserved.
//

#ifndef CommonMacros_h
#define CommonMacros_h


#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

/**
 *  weakSelf
 *
 *  @param type <#type description#>
 *
 *  @return <#return value description#>
 */
#define WeakSelf(type)  __weak typeof(type) weakSelf = type;
/**
 *  strongSelf
 *
 *  @param type <#type description#>
 *
 *  @return <#return value description#>
 */
#define StrongSelf(type)  __strong typeof(type) type = weak##type;
/*
 设备大小
 */
#define SCREEN_RECT ([UIScreen mainScreen].bounds)// 屏幕 rect
#define iPhoneWidth [UIScreen mainScreen].bounds.size.width
#define iPhoneHeight [UIScreen mainScreen].bounds.size.height

/*
 iOS系统判断
 */
#define iOS_6 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)&&([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) )
#define iOS_6_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)

#define iOS_7 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)&&([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0))
#define iOS_7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

#define iOS_8 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)&&([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0))
#define iOS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define iOS_9 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)&&([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0))
#define iOS_9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)

#define iOS_10 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)&&([[[UIDevice currentDevice] systemVersion] floatValue] < 11.0))
#define iOS_10_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define iOS_13 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 13.0)

/*
 尺寸大小
 */
//////////////////////////////////////////   ↓
#define iPhone_5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone_5s ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone_5c ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone_SE ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
//////////////////////////////////////////   ↑

//////////////////////////////////////////   ↓
#define iPhone_6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone_6_Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone_6s ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone_6s_Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone_7 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone_7_Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone_8 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone_8_Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
//////////////////////////////////////////   ↑

//////////////////////////////////////////   ↓
#define iPhone_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone_Xr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone_XsMAX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)


#define iPhone_11 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone_11Pro ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone_11ProMAX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone_12 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1170, 2532), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone_12Pro ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1170, 2532), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone_12ProMAX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1284, 2778), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone_13 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1170, 2532), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone_13Pro ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1170, 2532), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone_13ProMAX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1284, 2778), [[UIScreen mainScreen] currentMode].size) : NO)
//////////////////////////////////////////   ↑

#define iPhone_5_Series (iPhone_5||iPhone_5s||iPhone_5c||iPhone_SE)// 640, 1136
#define iPhone_6_TO_8 (iPhone_6||iPhone_6s||iPhone_7||iPhone_8)// 750, 1334
#define iPhone_6Plus_TO_8Plus (iPhone_6_Plus||iPhone_6s_Plus||iPhone_7_Plus||iPhone_8_Plus)// 1242, 2208
#define iPhone_X_ (iPhone_X||iPhone_Xs||iPhone_Xr||iPhone_XsMAX||iPhone_11||iPhone_11Pro||iPhone_11ProMAX||iPhone_13||iPhone_13Pro||iPhone_13ProMAX)// X及以上 刘海屏
#define iPhone_X_TO_Xs (iPhone_X||iPhone_Xs)// X Xs


#define Status_NavBar ((StatusBar) + (NavBarHeight)) //状态栏 ＋ 导航栏高度
#define iPhoneXStatus_NavBar ((iPhoneXStatusBar) + (NavBarHeight)) //iPhone X 状态栏 ＋ 导航栏高度

#define iphoneXToolBarHeight 83 //iphone X toolBar
#define commonToolBarHeight 50//普通设备的 toolBar


//获取iPhone 的导航栏高度
#define iPhoneNav_StatusHeight ([unitl getiPhoneNav_StatusHeight])
//获取iPhone 的工具栏高度
#define iPhoneToolBarHeight ([unitl getiPhoneToolBarHeight])

#define NavBarHeight_UserDefined 130 //自定义的nav的高度 【默认高度】
#define NavBarHeight_UserDefined_Up 80 //自定义的nav的高度 【上推高度】
#define NavBarHeightChangge_duringTime 0.4f //自定义nav动画时间
//导航栏是否透明来设置高度： 透明：64 ；不透明：0
#define hideNavHeight  0
#define SafeAreaBottomHeight (iPhoneHeight == 812.0 ? 34 : 0)

/*
 颜色设置
 */
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f) //获取RGB颜色

//选中边框的颜色
//#define MAIN_COLOR [UIColor colorWithRed:56.0/255.0 green:173.0/255.0 blue:255.0/255.0 alpha:1.0]
//主色调
#define MAIN_COLOR [UIColor colorWithRed:66.0/255.0 green:125.0/255.0 blue:255.0/255.0 alpha:1.0]
//背景颜色
#define BG_COLOR [UIColor colorWithRed:238/255.0 green:239/255.0 blue:244/255.0 alpha:1]

/*
 字体大小
 */
#define FONTB(size)  ([UIFont boldSystemFontOfSize:size])

#define FONT(size)  ([UIFont systemFontOfSize:size])

/**
 *  view灰色
 */
#define COLOR_VIEW_BREAK [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1]
#define COLOR_TEXT [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1]
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
/**
 *当前语言是否是简体中文
 */
#define isSimplifiedChinese ([unitl currentLanguageisSimplifiedChinese])
/**
 * 是否是海外用户
 */
#define isOverSeas ([unitl isOverseasCustomers])
/**
 * 是否是主账号
 */
#define isMainAccount ([unitl getMainAccount])
/**
 * 是否是文件夹模式
 */
#define isNodeTreeMode ([unitl isHasTreeNode])
/**
 * 是否是通道列表模式【区分设备列表模式】
 */
#define isChannelMode ([unitl isHasChannelList])

// 单例模式
#define SINGLETON_GENERATOR(class_name, shared_func_name)    \
static class_name * s_##class_name = nil;                       \
+ (class_name *)shared_func_name                                \
{                                                               \
static dispatch_once_t once;                                \
dispatch_once(&once, ^{                                     \
s_##class_name = [[super allocWithZone:NULL] init];     \
});                                                         \
return s_##class_name;                                      \
}                                                               \
+ (class_name *)allocWithZone:(NSZone *)zone                    \
{                                                               \
return s_##class_name;                                      \
}                                                               \
- (class_name *)copyWithZone:(NSZone *)zone                     \
{                                                               \
return self;                                                \
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// Device相关
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

// 是否是iOS 7或者更高版本
#define IS_IOS7_OR_HIGHER       SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")

// 是否是iOS 8或者更高版本
#define IS_IOS8_OR_HIGHER       SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")

// 是否是iOS 8或者更低版本
#define IS_IOS8_OR_BELOW        SYSTEM_VERSION_LESS_THAN(@"9.0")

// 是否是iOS 10或者更高版本
#define IS_IOS10_OR_HIGHER      SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"当前代码执行时间：Time: %f", -[startTime timeIntervalSinceNow])

#endif /* CommonMacros_h */
