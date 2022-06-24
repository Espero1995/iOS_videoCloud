//
//  ZCTabBar.m
//  ZCTabBarController
//
//  Created by 张策 on 15/12/4.
//  Copyright © 2015年 ZC. All rights reserved.
//
#import "ZCTabBar.h"
#import "ZCTabBarButton.h"
#define ZCImageRidio 0.7
#import "UIView+frame.h"
#import "CenterBtn.h"




@interface ZCTabBar ()

@property (nonatomic, weak) CenterBtn *plusButton;

@property (nonatomic, weak) UIButton *selectedButton;
//是否登录 是否认证
@property (nonatomic,assign) BOOL isState;



@end
@implementation ZCTabBar

- (NSMutableArray *)buttons
{
    if (_buttons == nil) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

- (void)setSelectTag:(NSInteger)selectTag
{
    _selectTag = selectTag;
    for (ZCTabBarButton *view in self.subviews) {
        if ([view isKindOfClass:[ZCTabBarButton class]]) {
            if (view.tag == selectTag) {
                view.selected = YES;
            }else{
                view.selected = NO;
            }
        }
    }
}

- (void)setItems:(NSArray *)items
{
    _items = items;
 
    // 遍历模型数组，创建对应tabBarButton
    for (UITabBarItem *item in _items) {
        
        ZCTabBarButton *btn = [ZCTabBarButton buttonWithType:UIButtonTypeCustom];
        
        // 给按钮赋值模型，按钮的内容由模型对应决定
        btn.item = item;
        
        btn.tag = self.buttons.count;
       // NSLog(@"设置item的tag的地方:%ld===self.buttons.count:%ld",btn.tag,self.buttons.count);
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
        
        if (btn.tag == 0) { // 选中第0个
            [self btnClick:btn];
        }
        
        [self addSubview:btn];
        
        // 把按钮添加到按钮数组
        [self.buttons addObject:btn];
    }
}

// 点击tabBarButton调用
-(void)btnClick:(UIButton *)button
{
    
   
//    if(button.tag == 0){
        _selectedButton.selected = NO;
        button.selected = YES;
        _selectedButton = button;
        
        // 通知tabBarVc切换控制器，
        if ([_delegate respondsToSelector:@selector(tabBar:didClickButton:)]) {
            [_delegate tabBar:self didClickButton:button.tag];
        }
//    }else{
////         [self chackBtnTapped];
//        if (_isState&&_isState) {
//            _selectedButton.selected = NO;
//            button.selected = YES;
//            _selectedButton = button;
//            // 通知tabBarVc切换控制器，
//            if ([_delegate respondsToSelector:@selector(tabBar:didClickButton:)]) {
//                [_delegate tabBar:self didClickButton:button.tag];
//            }
//        }
//    }
}

// 点击中间按钮调用
- (void)centerBtnClick
{
    if ([_delegate respondsToSelector:@selector(centerBtnClick)]) {
        [_delegate centerBtnClick];
    }

}

- (CenterBtn *)plusButton
{
    if (_plusButton == nil) {
        CGFloat w = self.bounds.size.width;
        CGFloat btnW = w / (self.items.count+1 );
        CGFloat btnH = self.bounds.size.height;
        CenterBtn *btn = [[CenterBtn alloc]initWithFrame:CGRectMake(0, 0, btnW, btnH)];
        btn.backgroundColor = [UIColor clearColor];
        [btn setImage:[UIImage imageNamed:@"home_weiyun_h"] forState:UIControlStateNormal];
//        [btn setTitle:@"发布寻车" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(centerBtnClick) forControlEvents:UIControlEventTouchUpInside];
        // 默认按钮的尺寸跟背景图片一样大
        // sizeToFit:默认会根据按钮的背景图片或者image和文字计算出按钮的最合适的尺寸
//        [btn sizeToFit];
        _plusButton = btn;
        [self addSubview:_plusButton];
    }
    return _plusButton;
}



// self.items UITabBarItem模型，有多少个子控制器就有多少个UITabBarItem模型
// 调整子控件的位置
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    CGFloat btnW = w / (self.items.count);
    CGFloat btnH = self.bounds.size.height;
    
    
    int i = 0;
    // 设置tabBarButton的frame
    for (UIView *tabBarButton in self.buttons) {
//        if (i == 1) {
//            i = 2;
//        }
        btnX = i * btnW;
        tabBarButton.frame = CGRectMake(btnX, btnY, btnW, btnH);
        i++;
    }
    
//    // 设置添加按钮的位置
//    self.plusButton.center = CGPointMake(btnW+btnW/2, h * 0.5);
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
