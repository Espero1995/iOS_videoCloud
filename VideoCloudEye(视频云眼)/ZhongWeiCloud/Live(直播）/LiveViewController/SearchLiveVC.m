//
//  SearchLiveVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/15.
//  Copyright © 2018年 张策. All rights reserved.
//
#import "SearchLiveVC.h"
#import "ZCTabBarController.h"
/*自定义搜索框*/
#import "customSearchBar.h"
/*搜索记录的cell*/
#import "LiveSearchHistoryCell.h"
/*清理缓存与存储的model*/
#import "ClearCacheManager.h"
@interface SearchLiveVC ()
<
    /*UISearchBarDelegate*/
    UISearchBarDelegate,
    /*UICollectionViewDelegate*/
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
>
/*搜索框*/
@property (nonatomic, strong) customSearchBar *searchBar;
/*collectionView*/
@property (nonatomic,strong) UICollectionView *collectionView;
/*搜索记录的数组*/
@property (nonatomic,strong) NSArray *searchHistoryArr;
/*清除历史记录按钮*/
@property (nonatomic,strong) UIButton *cleanCacheBtn;
/*collectionView头部提示信息*/
@property (nonatomic,strong) UILabel *tipLb;
/*collectionView头部暂无消息的提示信息*/
@property (nonatomic,strong) UILabel *tipNoInfoLb;
@end

@implementation SearchLiveVC

// 注意const的位置
static NSString *const cellId = @"cellId";
static NSString *const headerId = @"headerId";

//=========================system=========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BG_COLOR;
    //导航栏样式
    [self setNavigationUI];
    //页面初始化(UICollectionView)
    [self setUpUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    //读取缓存数据
    [self readNSUserDefaults];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//=========================init=========================
//导航栏样式
- (void)setNavigationUI{
    //去掉返回按钮，自己设置返回按钮
    [self.navigationItem setHidesBackButton:YES];
    //将searchBar添加上去
    [self.view addSubview:self.searchBar];
    self.searchBar.frame =CGRectMake(0, 0, 0.8*iPhoneWidth, 44);
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"请输入相关视频名称";
    [self.searchBar setTintColor:MAIN_COLOR];
    //改变searchBar位置
    {
        CGFloat height = self.searchBar.bounds.size.height;
        CGFloat top = (height - 30.0) / 2.0;
        CGFloat bottom = top;
        self.searchBar.contentInset = UIEdgeInsetsMake(top, 0, bottom, 0);
    }
    
    //第一时间响应到搜索框中
    UITextField *searchTextField;
    //拿到searchBar的输入框
    if (iOS_13) {
        // 针对 13.0 以上的iOS系统进行处理
        NSUInteger numViews = [self.searchBar.subviews count];
        for(int i = 0; i < numViews; i++) {
            if([[self.searchBar.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
                searchTextField = [self.searchBar.subviews objectAtIndex:i];
                }
        }
            if (searchTextField) {
            //这里设置相关属性
            }else{}
                
            } else {
                  // 针对 13.0 以下的iOS系统进行处理
                searchTextField = [self.searchBar valueForKey:@"_searchField"];
                if(searchTextField) {
                   //这里设置相关属性
                }else{}
    }
    
    [searchTextField setFont:[UIFont systemFontOfSize:15]];
     [searchTextField setValue:[UIFont systemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    [searchTextField becomeFirstResponder];
    
    UIView *showView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, 44)];
    [showView addSubview:self.searchBar];
    
    //设置取消按钮
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    cancelBtn.frame = CGRectMake(0.8*iPhoneWidth, 0, 0.2*iPhoneWidth, 44);
    [cancelBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [showView addSubview:cancelBtn];
    
    self.navigationItem.titleView = showView;

}

//页面初始化(UICollectionView)
- (void)setUpUI{
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = RGB(255, 255, 255);
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, iPhoneHeight-64));
    }];
    
    /** 注册单元格（注册cell、sectionHeader、sectionFooter）
     * description: 注册单元格的类型为 UICollectionViewCell ，如果子类化 UICollectionViewCell，这里可指定对应类。
     */
    [self.collectionView registerNib:[UINib nibWithNibName:@"LiveSearchHistoryCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:cellId];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId];
    
    //代理协议
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

//=========================method=========================
#pragma mark ----- 返回按钮
- (void)backClick{
     [self.navigationController popViewControllerAnimated:YES];
    //第一时间响应到搜索框中
    UITextField *searchTextField;
    //拿到searchBar的输入框
    if (iOS_13) {
        // 针对 13.0 以上的iOS系统进行处理
        NSUInteger numViews = [self.searchBar.subviews count];
        for(int i = 0; i < numViews; i++) {
            if([[self.searchBar.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
                searchTextField = [self.searchBar.subviews objectAtIndex:i];
                }
        }
            if (searchTextField) {
            //这里设置相关属性
            }else{}
                
            } else {
                  // 针对 13.0 以下的iOS系统进行处理
                searchTextField = [self.searchBar valueForKey:@"_searchField"];
                if(searchTextField) {
                   //这里设置相关属性
                }else{}
    }
    [searchTextField resignFirstResponder];
}

#pragma mark ----- 取出缓存的数据
-(void)readNSUserDefaults{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    //读取数组NSArray类型的数据
    NSArray * searchHistoryArr = [userDefaultes arrayForKey:@"searchLiveHistory"];
    self.searchHistoryArr = searchHistoryArr;
    [self.collectionView reloadData];
    //    NSLog(@"searchHistoryArr======%@",searchHistoryArr);
}
#pragma mark ----- 清除缓存数据
- (void)clickCleanLiveCache{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定清除历史记录？"message:@""preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [ClearCacheManager removeAllArray];
        _searchHistoryArr = nil;
        [self.collectionView reloadData];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

//=========================delegate=========================
#pragma mark ------collectionView代理方法
//有多少个章节（Section），如果省略，默认为1
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

// 每个章节中有多少个单元格（Cell）
//注意：这里返回的是每个章节的单元格数量，当有多个章节时，需要判断 section 参数，返回对应的数量。
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
        if (_searchHistoryArr.count>0) {
            return _searchHistoryArr.count;
        }else{
            return 0;
        }

}

//实例化每个单元格
//使用 dequeueReusableCellWithReuseIdentifier 方法获得“复用”的单元格实例
//返回的 cell 依赖注册单元格类型，识别符 “DemoCell”也需要一致，否则，这里将返回 nil，导致崩溃。
//这里可以配置每个单元格显示内容，如单元格标题等。
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
     LiveSearchHistoryCell *cell = (LiveSearchHistoryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    if (section == 0) {
        if (row%2 == 0) {
            cell.searchIcon_img.image = [UIImage imageNamed:@"tv_blue"];
        }else{
            cell.searchIcon_img.image = [UIImage imageNamed:@"tv_red"];
        }
        NSArray* reversedArray = [[_searchHistoryArr reverseObjectEnumerator] allObjects];
        cell.searchContent_lb.text = reversedArray[indexPath.row];
    }
    
    return cell;
}

// 和UITableView类似，UICollectionView也可设置段头段尾
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //段头
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]){
        UICollectionReusableView *headerView = [_collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerId forIndexPath:indexPath];
        if (headerView == nil){
            headerView = [[UICollectionReusableView alloc] init];
        }
        
        //如果没有搜索内容显示
        if (_searchHistoryArr.count == 0) {
            //清除这两个控件
            [self.cleanCacheBtn removeFromSuperview];
            [self.tipLb removeFromSuperview];
            
            //提示信息
             self.tipNoInfoLb.frame = CGRectMake(0, 0, self.view.frame.size.width, 45);
             self.tipNoInfoLb.text = @"暂无搜索记录~";
             self.tipNoInfoLb.textAlignment = NSTextAlignmentCenter;
             self.tipNoInfoLb.textColor = [UIColor lightGrayColor];
             self.tipNoInfoLb.font = FONT(15);
            [headerView addSubview:self.tipNoInfoLb];
            
        }else{
            //清除暂无搜索记录的控件
            [self.tipNoInfoLb removeFromSuperview];
            //提示信息
            self.tipLb.frame = CGRectMake(15, 15, self.view.frame.size.width, 30);
            self.tipLb.text = @"最近搜索";
            self.tipLb.textColor = [UIColor lightGrayColor];
            [headerView addSubview:self.tipLb];
            
            //按钮
           self.cleanCacheBtn.frame = CGRectMake(self.view.frame.size.width-100, 18, 100, 27);
            [self.cleanCacheBtn setTitle:@"清除历史记录" forState:UIControlStateNormal];
            self.cleanCacheBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            [self.cleanCacheBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [self.cleanCacheBtn addTarget:self action:@selector(clickCleanLiveCache) forControlEvents:UIControlEventTouchUpInside];
            [headerView addSubview:self.cleanCacheBtn];
        }
        
        
        
        return headerView;
    }
    
    return nil;
}


#pragma mark ----- collectionView 布局
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (iPhoneWidth <= 320){
        return (CGSize){(iPhoneWidth-5)/2,40};
    }else{
        return (CGSize){(iPhoneWidth-5)/2,50};
    }

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}

//头部的宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return (CGSize){self.view.frame.size.width,45};
}


#pragma mark ---- UICollectionViewDelegate
//选择==============================
// 选中某item是否开启
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
// 选中某item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSInteger section = indexPath.section;
//    NSInteger row = indexPath.row;
    LiveSearchHistoryCell *cell = (LiveSearchHistoryCell *)[collectionView cellForItemAtIndexPath:indexPath];
    //=====temp=====
//    NSString *tipStr = [NSString stringWithFormat:@"正在搜索:%@",cell.searchContent_lb.text];
//    NSLog(@"我选中了第%ld组第%ld个",(long)section,(long)row);
//    [XHToast showCenterWithText:tipStr];
    //=====temp=====
}

//选择==============================

#pragma  mark ----- searchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //第一时间响应到搜索框中
    UITextField *searchTextField;
    //拿到searchBar的输入框
    if (iOS_13) {
        // 针对 13.0 以上的iOS系统进行处理
        NSUInteger numViews = [self.searchBar.subviews count];
        for(int i = 0; i < numViews; i++) {
            if([[self.searchBar.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
                searchTextField = [self.searchBar.subviews objectAtIndex:i];
                }
        }
            if (searchTextField) {
            //这里设置相关属性
            }else{}
                
            } else {
                  // 针对 13.0 以下的iOS系统进行处理
                searchTextField = [self.searchBar valueForKey:@"_searchField"];
                if(searchTextField) {
                   //这里设置相关属性
                }else{}
    }
    [ClearCacheManager SearchText:searchTextField.text];//缓存搜索记录
    [self readNSUserDefaults];
    //=====temp=====
//    NSString *tipStr = [NSString stringWithFormat:@"正在搜索:%@",searchTextField.text];
//    [XHToast showCenterWithText:@"暂未开放搜索功能,敬请期待~"];
    //=====temp=====
    //搜索完后，清空文本框内容
    searchTextField.text = @"";
    [searchTextField resignFirstResponder];
}

//=========================lazy loading=========================
#pragma mark ----- 懒加载部分
//searchBar懒加载
-(customSearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[customSearchBar alloc]init];
    }
    return _searchBar;
}

//collectionView懒加载
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        //自定义布局对象
        UICollectionViewFlowLayout *customLayout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:customLayout];
    }
    return _collectionView;
}

//清除历史记录按钮懒加载
- (UIButton *)cleanCacheBtn{
    if (!_cleanCacheBtn) {
        _cleanCacheBtn = [[UIButton alloc]init];
    }
    return _cleanCacheBtn;
}

//collectionView头部提示信息懒加载
- (UILabel *)tipLb{
    if (!_tipLb) {
        _tipLb = [[UILabel alloc]init];
    }
    return _tipLb;
}

//collectionView头部暂无消息的提示信息懒加载
- (UILabel *)tipNoInfoLb{
    if (!_tipNoInfoLb) {
        _tipNoInfoLb = [[UILabel alloc]init];
    }
    return _tipNoInfoLb;
}

@end
