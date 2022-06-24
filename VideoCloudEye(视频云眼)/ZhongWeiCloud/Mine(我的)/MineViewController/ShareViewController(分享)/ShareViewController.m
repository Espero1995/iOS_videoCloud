//
//  ShareViewController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/5.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "ShareViewController.h"
#import "MyShareController.h"
#import "OtherShareController.h"
#import "SharetoPoliceVC.h"
#import "ZCTabBarController.h"

@interface ShareViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, weak) UIButton *selectButton;
@property (nonatomic, weak) UIScrollView *titleScrollView;
@property (nonatomic, weak) UIScrollView *contentScrollView;
@property (nonatomic,strong) UIView * blueView;
@end

@implementation ShareViewController
//==========================system==========================
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//        [self.videoManage stopCloudPlay];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"设备共享", nil);
    self.view.backgroundColor = BG_COLOR;
   
    [self cteateNavBtn];
    [self setupTitleScrollView];
    [self setupContentScrollView];
    [self setupAllChildViewController];
    [self setupAllTitle];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


//==========================init==========================
// 设置标题
- (void)setupAllTitle
{
    NSInteger count = self.childViewControllers.count;
    CGFloat x = 0;
    CGFloat w = iPhoneWidth/2;//3
    CGFloat h = 40;
    
    for (int i = 0; i < count; i++) {
        UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        titleButton.tag = i;
        UIViewController *vc = self.childViewControllers[i];
        [titleButton setTitle:vc.title forState:UIControlStateNormal];
        [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        x  = i * w;
        titleButton.frame = CGRectMake(x, 0, w, h);
        
        // 监听按钮标题
        [titleButton addTarget:self action:@selector(titleClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.titleScrollView addSubview:titleButton];
        
        [self.buttons addObject:titleButton];
        
        if (i == 0) {
            [self titleClick:titleButton];
        }
    }
    _blueView = [[UIView alloc]initWithFrame:CGRectMake(0, 37.5, iPhoneWidth/2, 2.5)];//3
    self.blueView.backgroundColor = MAIN_COLOR;
    [self.titleScrollView addSubview:self.blueView];
    self.titleScrollView.backgroundColor = [UIColor colorWithHexString:@"#f4f4f4"];
    self.titleScrollView.contentSize = CGSizeMake(count * w, 0);
    self.titleScrollView.showsHorizontalScrollIndicator = NO;
    
    // 设置内容滚动视图滚动范围
    self.contentScrollView.backgroundColor = BG_COLOR;
    self.contentScrollView.contentSize = CGSizeMake(count * iPhoneWidth, 0);
    self.contentScrollView.bounces = NO;
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.delegate = self;
    
}

// 添加顶部的标题滚动视图
- (void)setupTitleScrollView
{
    UIScrollView *titleScrollView = [[UIScrollView alloc] init];
    CGFloat y = 0;
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = 40;
    titleScrollView.frame = CGRectMake(0, y, w, h);
    _titleScrollView = titleScrollView;
    [self.view addSubview:titleScrollView];
    
}

//添加所有的子控制器
- (void)setupAllChildViewController
{
    MyShareController * myShareVC = [[MyShareController alloc]init];
    [self addChildViewController:myShareVC];
    myShareVC.title = NSLocalizedString(@"我的分享", nil);//我分享的设备
    OtherShareController * otherShareVC = [[OtherShareController alloc]init];
    otherShareVC.title = NSLocalizedString(@"他人分享", nil);//别人分享的设备
    [self addChildViewController:otherShareVC];
//    SharetoPoliceVC *sharePVC = [[SharetoPoliceVC alloc]init];
//    sharePVC.title = @"分享至公安";
//    [self addChildViewController:sharePVC];
}


//添加底部的内容滚动视图
- (void)setupContentScrollView
{
    UIScrollView *contentScrollView = [[UIScrollView alloc] init];
    CGFloat y = CGRectGetMaxY(_titleScrollView.frame);
    CGFloat w = self.view.bounds.size.width;
    CGFloat h = self.view.bounds.size.height - y;
    _contentScrollView = contentScrollView;
    contentScrollView.frame = CGRectMake(0, y, w, h);
    
    [self.view addSubview:contentScrollView];
}


// 切换控制器的view
- (void)setupOneChildViewController:(NSInteger)i{
    
    UIViewController *vc = self.childViewControllers[i];
    
    if (vc.view.superview == nil) {
        CGFloat x = i * [UIScreen mainScreen].bounds.size.width;
        vc.view.frame = CGRectMake(x, 0, iPhoneWidth, self.contentScrollView.frame.size.height);
        [self.contentScrollView addSubview:vc.view];
    }
    
}

//==========================method==========================
// 选中按钮
- (void)selButton:(UIButton *)button
{
    // 让按钮标题颜色变成红色
    _selectButton.transform = CGAffineTransformIdentity;
    [_selectButton setTitleColor:[UIColor colorWithHexString:@"313335"] forState:UIControlStateNormal];
    [button setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    
    _selectButton = button;
    
}

// 点击标题就会调用
- (void)titleClick:(UIButton *)button
{
    NSInteger i = button.tag;
    
    [self selButton:button];
    
    [self setupOneChildViewController:i];
    if (i == 1) {
        _blueView.frame = CGRectMake(iPhoneWidth/2, 37.5, iPhoneWidth/2, 2.5);//3
    }
    /*
    else if (i == 2){
        _blueView.frame = CGRectMake(2*iPhoneWidth/3, 37.5, iPhoneWidth/3, 2.5);
    }
     */
     else{
        _blueView.frame = CGRectMake(0, 37.5, iPhoneWidth/2, 2.5);//3
    }
    CGFloat x = i * [UIScreen mainScreen].bounds.size.width;
    
    self.contentScrollView.contentOffset = CGPointMake(x, 0);
    
}

//==========================delegate==========================
#pragma mark - UIScrollViewDelegate
// 只要滚动scrollView就会调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

// 滚动完成的时候调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger i = scrollView.contentOffset.x / iPhoneWidth;
    if (i==1) {
        _blueView.frame = CGRectMake(iPhoneWidth/2, 37.5, iPhoneWidth/2, 2.5);//3
    }
    /*
    else if (i == 2){
        _blueView.frame = CGRectMake(2*iPhoneWidth/3, 37.5, iPhoneWidth/3, 2.5);
    }
    */
    else{
        _blueView.frame = CGRectMake(0, 37.5, iPhoneWidth/2, 2.5);//3
    }
    UIButton *btn = self.buttons[i];
    
    [self selButton:btn];
    
    [self setupOneChildViewController:i];
    
}
//==========================lazy loading==========================
#pragma mark ----- 懒加载
- (NSMutableArray *)buttons
{
    if (_buttons == nil) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}


@end
