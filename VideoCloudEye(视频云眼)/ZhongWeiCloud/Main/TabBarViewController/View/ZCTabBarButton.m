//
//  ZCTabBarButton.m
//  ZCTabBarController
//
//  Created by 张策 on 15/12/4.
//  Copyright © 2015年 ZC. All rights reserved.
//

#import "ZCTabBarButton.h"
#import "ZCBadgeView.h"
#import "UIView+frame.h"
#define ZCImageRidio 0.7

@interface ZCTabBarButton ()

@property (nonatomic, weak) ZCBadgeView *badgeView;

@end
@implementation ZCTabBarButton


// 重写setHighlighted，取消高亮做的事情
- (void)setHighlighted:(BOOL)highlighted{}

// 懒加载badgeView
- (ZCBadgeView *)badgeView
{
    if (_badgeView == nil) {
        ZCBadgeView *btn = [ZCBadgeView buttonWithType:UIButtonTypeCustom];
        
        [self addSubview:btn];
        
        _badgeView = btn;
    }
    return _badgeView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // 设置字体颜色
        [self setTitleColor:[UIColor colorWithRed:135/255.0 green:135/255.0 blue:135/255.0 alpha:1] forState:UIControlStateNormal];
        [self setTitleColor:MAIN_COLOR forState:UIControlStateSelected];
        
        // 图片居中
        self.imageView.contentMode = UIViewContentModeCenter;
        // 文字居中
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        // 设置文字字体
        self.titleLabel.font = [UIFont systemFontOfSize:10];
        
    }
    return self;
}
// 传递UITabBarItem给tabBarButton,给tabBarButton内容赋值
- (void)setItem:(UITabBarItem *)item
{
    _item = item;
    
    [self observeValueForKeyPath:nil ofObject:nil change:nil context:nil];
    
    // KVO：时刻监听一个对象的属性有没有改变
    // 给谁添加观察者
    // Observer:按钮
    [item addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"selectedImage" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"badgeValue" options:NSKeyValueObservingOptionNew context:nil];
    
}

// 只要监听的属性一有新值，就会调用
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    [self setTitle:_item.title forState:UIControlStateNormal];
    
    [self setImage:_item.image forState:UIControlStateNormal];
    
    [self setImage:_item.selectedImage forState:UIControlStateSelected];
    
    // 设置badgeValue
    self.badgeView.badgeValue = _item.badgeValue;
}

// 修改按钮内部子控件的frame
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    if (iPhone_X_) {
        // 1.imageView
        CGFloat imageX = 0;
        CGFloat imageY = 5;
        CGFloat imageW = self.bounds.size.width;
        CGFloat imageH = self.bounds.size.height * ZCImageRidio;
        self.imageView.frame = CGRectMake(imageX, imageY, imageW, imageH/2);
        // 2.title
        CGFloat titleX = 0;
        CGFloat titleY = imageH/2 - 5;
        CGFloat titleW = self.bounds.size.width;
        CGFloat titleH = self.bounds.size.height - titleY;
        self.titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH/2);
    }else{
        // 1.imageView
        CGFloat imageX = 0;
        CGFloat imageY = 3;
        CGFloat imageW = self.bounds.size.width;
        CGFloat imageH = self.bounds.size.height * ZCImageRidio;
        self.imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
        
        // 2.title
        CGFloat titleX = 0;
        CGFloat titleY = imageH - 5;
        CGFloat titleW = self.bounds.size.width;
        CGFloat titleH = self.bounds.size.height - titleY;
        self.titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    }
    
    // 3.badgeView
    self.badgeView.x = self.bounds.size.width/2+3;
    self.badgeView.y = 0;
}

- (void)dealloc
{
    [_item removeObserver:self forKeyPath:@"title"];
    [_item removeObserver:self forKeyPath:@"image"];
    [_item removeObserver:self forKeyPath:@"selectedImage"];
    [_item removeObserver:self forKeyPath:@"badgeValue"];
}
@end
