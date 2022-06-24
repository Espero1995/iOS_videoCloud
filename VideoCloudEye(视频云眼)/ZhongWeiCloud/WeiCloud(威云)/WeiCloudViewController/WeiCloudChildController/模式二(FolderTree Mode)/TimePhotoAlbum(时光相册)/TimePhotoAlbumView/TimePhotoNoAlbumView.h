//
//  TimePhotoNoAlbumView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/10/18.
//  Copyright © 2018 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TimePhotoNoAlbumViewDelegate <NSObject>
- (void)cloudStorageBtnClick;//云存购买
@end
@interface TimePhotoNoAlbumView : UIView
@property (nonatomic,weak)id<TimePhotoNoAlbumViewDelegate>delegate;
@property (nonatomic,strong)UIButton *cloudBtn;
/*
 *  description: 数据源 弹出位置 宽度 单个cell高度
 */
- (instancetype)initWithFrame : (CGRect) frame
                      bgColor : (UIColor *) bgColor
                        bgImg : (UIImage *) bgImg
                        bgTip : (NSString *)tipStr;
@end

