//
//  SegmentViewController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/3/22.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "SegmentViewController.h"
#import "ZCTabBarController.h"
#import "VideoCell_c.h"


@interface SegmentViewController ()
<
UIScrollViewDelegate,
SegmentControl_Delegete
>
{
    CGFloat vcWidth;  // 每个子视图控制器的视图的宽
    CGFloat vcHeight; // 每个子视图控制器的视图的高
    UISegmentedControl * segment;

    //编辑按钮
    UIButton * _editButton;
    BOOL _isDrag;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic,strong) UILabel * deleteLabel;
@end

@implementation SegmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BG_COLOR;
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    [self setupScrollView];
    [self setupViewControllers];
    [self setupSegmentControl];
    [self cteateNavBtn];
    [self createEdit];
    //_editing = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    [self.videoManage stopCloudPlay];
    
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
}
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

/** 设置scrollView */
- (void)setupScrollView
{
    CGFloat Y = 0.0f;
    if (self.navigationController != nil && ![self.navigationController isNavigationBarHidden]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        Y = 0.0f;
    }
    
    vcWidth = self.view.frame.size.width;
    vcHeight = self.view.frame.size.height - Y;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, Y, vcWidth, vcHeight)];
    scrollView.contentSize = CGSizeMake(vcWidth * self.viewControllers.count, vcHeight);
    scrollView.contentOffset = CGPointMake(_bIsVideo?0:vcWidth, 0);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator   = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate      = self;
    scrollView.bounces = NO;
   // scrollView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
   // [self.scrollView setBackgroundColor:[UIColor redColor]];
}

/** 设置子视图控制器，这个方法必须在viewDidLoad方法里执行，否则子视图控制器各项属性为空 */
- (void)setupViewControllers
{
    int cnt = (int)self.viewControllers.count;
    for (int i = 0; i < cnt; i++) {
        UIViewController *vc = self.viewControllers[i];
        [self addChildViewController:vc];
        
        vc.view.frame = CGRectMake(vcWidth * i, 0, vcWidth, vcHeight);
        [self.scrollView addSubview:vc.view];
    }
}
/** 设置segment */
- (void)setupSegmentControl
{
    NSArray *titleArr = @[@"视频",@"图片"];
    segment = [[UISegmentedControl alloc]initWithItems:titleArr];
    segment.layer.cornerRadius = 15;
    segment.clipsToBounds = YES;
    segment.layer.borderWidth = 1.0f;
    segment.layer.borderColor = RGB(255, 255, 255).CGColor;
    segment.frame = CGRectMake(0, 0, 150, 30);
    //默认选中项
    segment.selectedSegmentIndex = self.bIsVideo?0:1;
    //设置镂空颜色
    segment.tintColor = [UIColor whiteColor];
    
    [segment addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged];
    segment.layer.cornerRadius = 15;
    self.navigationItem.titleView = segment;
  
}
- (void)segmentChange:(UISegmentedControl *)seg{
    if (seg.selectedSegmentIndex == 0) {
        _editing = NO;
    }else if(seg.selectedSegmentIndex == 1){
        _editing = YES;
    }


    [_deleteLabel removeFromSuperview];
    CGFloat X = seg.selectedSegmentIndex * self.view.frame.size.width;
    [self.scrollView setContentOffset:CGPointMake(X, 0) animated:YES];
}
- (void)createEdit{
    _editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [_editButton setTitle:@"选择" forState:UIControlStateNormal];
    [_editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//MAIN_COLOR
    [_editButton addTarget:self action:@selector(SegmentControlEditCollectCell:) forControlEvents:UIControlEventTouchUpInside];

    _editButton.highlighted = YES;
    _editButton.userInteractionEnabled = YES;
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:_editButton];
    _editButton.contentHorizontalAlignment =UIControlContentHorizontalAlignmentRight;
//    UIBarButtonItem * rightSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
//    rightSpace.width = 0;
    self.navigationItem.rightBarButtonItem = rightItem;// @[rightSpace,rightItem];
    
}
- (BOOL)SegmentControlEditCollectCell:(SegmentViewController *)segmentController{
    self.scrollView.scrollEnabled = NO;
    if (_editing == YES) {
        if (self.delegete && [self.delegete respondsToSelector:@selector(SegmentControlEditCollectCell:)]) {
           BOOL delete = [self.delegete SegmentControlEditCollectCell:self];
            if (delete) {
                segment.enabled = NO;
                segment.userInteractionEnabled = NO;
                [self createDeleteButton];
                
                [self createNavButton];
            }
        }
       
    }else{
        if (self.delegeSoure && [self.delegeSoure respondsToSelector:@selector(SegmentControlEditCollectCell:)]) {
           BOOL delete =  [self.delegeSoure SegmentControlEditCollectCell:self];
            if (delete) {
                segment.enabled = NO;
                segment.userInteractionEnabled = NO;
                [self createDeleteButton];
                
                [self createNavButton];
            }
        }
    }
    return YES;
}

#pragma mark ------删除和已读按钮的创建和响应事件
//创建删除按钮
- (void)createDeleteButton
{
    _deleteLabel= [[UILabel alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 60)];
    _deleteLabel.backgroundColor = BG_COLOR;
    [self.view addSubview:_deleteLabel];
    [self.view bringSubviewToFront:_deleteLabel];
    [_deleteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.height.mas_equalTo(@60);
    }];
    
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteBtn.backgroundColor =MAIN_COLOR;
    _deleteBtn.layer.cornerRadius = 6;
    [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];

    [_deleteBtn setTitleColor:[UIColor colorWithHexString:@"ffffff"] forState:UIControlStateNormal];
    
    _deleteBtn.userInteractionEnabled = YES;
    [_deleteBtn addTarget:self action:@selector(SegmentControlDeleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_deleteBtn];
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.deleteLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(0.75*iPhoneWidth, 40));
    }];
    [self.view bringSubviewToFront:_deleteBtn];
}

//删除cell
- (void)SegmentControlDeleteBtnClick:(SegmentViewController *)segmentController
{
        if (_editing == YES) {
            if (self.delegete && [self.delegete respondsToSelector:@selector(SegmentControlDeleteBtnClick:)]) {
                [self.delegete SegmentControlDeleteBtnClick:self];
            }
//            NSLog(@"删除图片");
        }else{
            if (self.delegeSoure && [self.delegeSoure respondsToSelector:@selector(SegmentControlDeleteBtnClick:)]) {
                [self.delegeSoure SegmentControlDeleteBtnClick:self];
            }
//            NSLog(@"删除视频");
        }
}


#pragma mark ------取消和全选按钮
//创建取消，全选按钮（编辑状态）
- (void)createNavButton{
    
    _editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [_editButton setTitle:@"取消" forState:UIControlStateNormal];
    [_editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//MAIN_COLOR
    [_editButton addTarget:self action:@selector(SegmentControlCancleEdit:) forControlEvents:UIControlEventTouchUpInside];
    _editButton.userInteractionEnabled = YES;
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:_editButton];
    _editButton.contentHorizontalAlignment =UIControlContentHorizontalAlignmentRight;
    self.navigationItem.rightBarButtonItem = rightItem;
    
    _allChoose = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 14)];
    [_allChoose setTitle:@"全选" forState:UIControlStateNormal];
    [_allChoose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//MAIN_COLOR
    [_allChoose addTarget:self action:@selector(SegmentControlChooseAllCell:) forControlEvents:UIControlEventTouchUpInside];

    _allChoose.highlighted = YES;
    _allChoose.userInteractionEnabled = YES;
    _allChoose.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:_allChoose];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    
}
//全选cell
- (void)SegmentControlChooseAllCell:(SegmentViewController *)segmentController{
    
    if (_editing == YES) {
        
        if (self.delegete && [self.delegete respondsToSelector:@selector(SegmentControlChooseAllCell:)]) {
            [self.delegete SegmentControlChooseAllCell:self];
        }

    }else{
        if (self.delegeSoure && [self.delegeSoure respondsToSelector:@selector(SegmentControlChooseAllCell:)]) {
            [self.delegeSoure SegmentControlChooseAllCell:self];
        }
    }
}

//取消编辑按钮todotodo
- (void)SegmentControlCancleEdit:(SegmentViewController *)segmentController
{
    segment.enabled = YES;
    segment.userInteractionEnabled = YES;
    self.scrollView.scrollEnabled = YES;
    if (_editing == YES) {
        if (self.delegete && [self.delegete respondsToSelector:@selector(SegmentControlCancleEdit:)]) {
            [self.delegete SegmentControlCancleEdit:self];
        }
        
        _editButton.selected = NO;
        
        //编辑按钮
        [self createEdit];
        [self cteateNavBtn];
        [_deleteLabel removeFromSuperview];
        [_deleteBtn removeFromSuperview];
        [_allChoose removeFromSuperview];

    }else{
    
        if (self.delegeSoure && [self.delegeSoure respondsToSelector:@selector(SegmentControlCancleEdit:)]) {
            [self.delegeSoure SegmentControlCancleEdit:self];
        }
        
        _editButton.selected = NO;
        
        //编辑按钮
        [self createEdit];
        [self cteateNavBtn];
        [_deleteLabel removeFromSuperview];
         [_deleteBtn removeFromSuperview];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    _isDrag = YES;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / scrollView.frame.size.width;
    segment.selectedSegmentIndex = index;
    if (index == 0) {
        _editing = NO;
    }else{
        _editing = YES;
    }
    _isDrag = NO;
}

#pragma mark - JRSegmentControlDelegate

- (void)segmentControl:(UISegmentedControl *)segment didSelectedIndex:(NSInteger)index {
    if (index == 0) {
        _editing = NO;
    }else if (index == 1){
        _editing = YES;
    }
    CGFloat X = index * self.view.frame.size.width;
    [self.scrollView setContentOffset:CGPointMake(X, 0) animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setDefaultNav
{
    [self SegmentControlCancleEdit:self];
}

@end
