//
//  LiveViewController.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/10.
//  Copyright © 2018年 张策. All rights reserved.
//
#define headViewHeight 0.4*iPhoneWidth
#import "LiveViewController.h"
/*轮播图*/
#import "SDCycleScrollView.h"
/*直播集合的VC*/
#import "LiveCollectedVC.h"
/*搜索页面*/
#import "SearchLiveVC.h"
@interface LiveViewController ()
<
    SDCycleScrollViewDelegate
>
/*头视图：轮播图*/
@property (nonatomic, strong) UIView *headView;
@end

@implementation LiveViewController
//=========================system=========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"直播";
    self.view.backgroundColor = BG_COLOR;

    //设置导航栏上的按钮
//    [self setupNavBar];
    //设置头视图
    [self setupHeadView];
    //设置添加子视图
    [self setupAllChildViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//=========================init=========================
//设置导航栏上的搜索按钮
- (void)setupNavBar
{
    //搜索按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"searchLive"] style:UIBarButtonItemStylePlain target:self action:@selector(searchLive)];
}
//设置头视图
- (void)setupHeadView
{
    [self.view addSubview:self.headView];
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, headViewHeight));
    }];
    //设置轮播图
    [self setupTitleScrollView];
}

// 添加顶部的标题滚动视图
- (void)setupTitleScrollView
{
    UIView * ScrollBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, headViewHeight)];
    [self.headView addSubview:ScrollBackView];
    UIImage *placeholder1 = [UIImage imageNamed:@"zhineng1"];
    UIImage *placeholder2 = [UIImage imageNamed:@"zhineng2"];
    NSMutableArray *imaGroup = [NSMutableArray arrayWithObjects:placeholder1,placeholder2, nil];
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, iPhoneWidth, headViewHeight) delegate:self placeholderImage:placeholder1];
    cycleScrollView.localizationImageNamesGroup = imaGroup;
    cycleScrollView.pageControlBottomOffset = -8;
    
    [ScrollBackView addSubview:cycleScrollView];
}

//添加所有的子控制器
- (void)setupAllChildViewController
{
    LiveCollectedVC * LiveVC = [[LiveCollectedVC alloc]init];
    LiveVC.view.frame = CGRectMake(0, headViewHeight+10, iPhoneWidth, iPhoneHeight - headViewHeight);
    [self addChildViewController:LiveVC];
    [self.view addSubview:LiveVC.view];
}

//=========================method=========================
//搜索直播
- (void)searchLive{
    SearchLiveVC *searchVC = [[SearchLiveVC alloc]init];
    [self.navigationController pushViewController:searchVC animated:YES];
}
//=========================delegate=========================

//=========================lazy loading=========================
#pragma mark ----- 懒加载部分
//头部视图懒加载
-(UIView *)headView{
    if (!_headView) {
        _headView = [[UIView alloc]init];
        _headView.backgroundColor = BG_COLOR;
    }
    return _headView;
}

@end
