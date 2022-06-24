//
//  UIMacros.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2019/1/7.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#ifndef UIMacros_h
#define UIMacros_h

/**********************************NEW UI*************************************/

/**
 *  view灰色
 */
#define COLOR_VIEW_BREAK [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1]

#define COLOR_TEXT [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1]

/*
 颜色设置
 */
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f) //获取RGB颜色
//十六进制颜色 - > RGB颜色
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//选中边框的颜色
//#define MAIN_COLOR [UIColor colorWithRed:56.0/255.0 green:173.0/255.0 blue:255.0/255.0 alpha:1.0]
//主色调
#define MAIN_COLOR [UIColor colorWithRed:45.0/255.0 green:45/255.0 blue:85/255.0 alpha:1.0]
//背景颜色
#define BG_COLOR [UIColor colorWithRed:238/255.0 green:239/255.0 blue:244/255.0 alpha:1]

/*
  字体大小
 */
#define FONTB(size)  ([UIFont boldSystemFontOfSize:size])

#define FONT(size)  ([UIFont systemFontOfSize:size])

/*
 尺寸设置 导航栏与状态栏其顺序不可替换
 */
#define StatusBar 20 // 状态栏高度
#define iPhoneXStatusBar 44 //iPhone X 状态栏高度
#define NavBarHeight 44 // NavBar高度

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

#endif /* UIMacros_h */
