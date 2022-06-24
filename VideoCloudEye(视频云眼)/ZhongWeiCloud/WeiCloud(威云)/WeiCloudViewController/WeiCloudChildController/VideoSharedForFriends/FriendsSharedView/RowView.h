//
//  RowView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/6/28.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
/*代理协议*/
@protocol rowViewDelegate <NSObject>
//点击事件
- (void)didSelectRowView:(NSInteger )row;
@end

@interface RowView : UIView
@property (nonatomic,strong) UILabel *titleLb;//名称
@property (nonatomic,strong) UILabel *subTitleLb;//副标题
@property (nonatomic,strong) UIImageView *pushImage;//箭头
@property (nonatomic,assign) NSInteger row;
/*代理协议*/
@property (nonatomic,weak)id<rowViewDelegate>rowViewDelegate;

@end
