//
//  SharedSheetView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/7/12.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SharedSheetViewDelegate <NSObject>
//点击分享给手机好友
- (void)sharetoPhoneClick;
//点击分享给微信
- (void)sharetoWeChatClick;
@end

@interface SharedSheetView : UIView

/*代理方法*/
@property (nonatomic) id<SharedSheetViewDelegate> delegate;


/**
 返回这个View
 
 @param frame view的大小
 @return 返回这个View
 */
- (instancetype)initWithframe:(CGRect) frame;
//分享视图展示
- (void)shareSheetViewShow;

@end
