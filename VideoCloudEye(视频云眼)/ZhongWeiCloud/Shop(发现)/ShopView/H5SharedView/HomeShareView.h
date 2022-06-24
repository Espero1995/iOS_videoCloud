//
//  HomeShareView.h
//  mb
//
//  Created by Boris on 2018/5/21.
//  Copyright © 2018年 laborc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
typedef void(^SelectIndexBlock)(NSInteger row);
// 分享视图
@interface HomeShareView : UIView
@property (nonatomic, strong, readonly) UIWindow *shareWindow;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *cancleBtn;
@property (nonatomic, copy) SelectIndexBlock block;
+ (void)showWithTitle:(NSString *)title titArray:(NSArray *)titleArray imgArray:(NSArray *)imgArray select:(void(^)(NSInteger row))indexBlock;
@end
