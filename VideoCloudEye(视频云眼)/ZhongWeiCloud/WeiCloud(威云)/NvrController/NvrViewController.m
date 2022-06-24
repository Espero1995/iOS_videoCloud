//
//  NvrViewController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/12.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "NvrViewController.h"
#import "PassageWayController.h"
#import "ZCTabBarController.h"
#import "NvrCell_c.h"
@interface NvrViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>
//背景view
@property (weak, nonatomic) IBOutlet UIView *VideoViewBack;

@property (nonatomic,strong) UICollectionView * collectionView;
@end

@implementation NvrViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self cteateNavBtn];
    [self createCollectionView];
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
    
    
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    
}

- (void)createCollectionView{
    //自动布局类
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth,200) collectionViewLayout:layout];
    //代理
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    //注册
    [_collectionView registerClass:[NvrCell_c class] forCellWithReuseIdentifier:@"cell"];
    [self.VideoViewBack addSubview:_collectionView];
    
    
}
#pragma mark ------ UICollectionView代理方法
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(iPhoneWidth/2-6, 100);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
//分组数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}
//每组cell个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return 4;
}
//创建cell
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NvrCell_c * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NvrCell_c * cell = (NvrCell_c *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.VideoViewBank.backgroundColor = [UIColor colorWithHexString:@"#38adff"];
    PassageWayController * passageWayVC = [[PassageWayController alloc]init];
    [self.navigationController pushViewController:passageWayVC animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
