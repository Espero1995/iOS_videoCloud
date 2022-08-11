//
//  searchVideoVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/2/6.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "SearchVideoVC.h"
#import "ZCTabBarController.h"
/*自定义搜索框*/
#import "customSearchBar.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
#import "WeiCloudListModel.h"
#import "DeviceSearchCell.h"
#import "RealTimeVideoVC.h"
#import "MonitoringVCnew.h"
#import "ChannelCodeListModel.h"
#import "smallScreenChannelCell.h"
#import "RealTimeChannelVC.h"
#import "TTGTextTagCollectionView.h"

#define WEIClOUDCELLT @"smallScreenChannelCell"

@interface SearchVideoVC ()
<
    UISearchBarDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
    smallScreenChannelCellDelegate,
    TTGTextTagCollectionViewDelegate
>

/*搜索框*/
@property (nonatomic,strong) customSearchBar *searchBar;
//历史搜索
@property (nonatomic,strong) UILabel *historTitleyLabel;
@property (nonatomic,strong) TTGTextTagCollectionView *historyTagsView;
@property (nonatomic, strong) NSMutableArray *historyArrray;
/*表视图*/
@property (nonatomic,strong) UITableView *tv_list;
/*提示信息*/
@property (nonatomic,strong) UILabel *tipTitleLb;
/*搜索结果arr*/
@property (nonatomic,strong)NSMutableArray * dataArr;
/*是否加密*/
@property (nonatomic,assign)BOOL bIsEncrypt;
/*加密的key*/
@property (nonatomic,copy)NSString * key;
/*解码器*/
@property (nonatomic,assign)JW_CIPHER_CTX cipher;
@end

@implementation SearchVideoVC
//==========================system==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"搜索", nil);
    self.view.backgroundColor = BG_COLOR;
    
    //导航栏样式
    [self setNavigationUI];
    [self setUpUI];
    [self setupHistoryTagsView];
    [self searchResultShow:NO];
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
- (void)dealloc
{
    jw_cipher_release(_cipher);
}


#pragma mark --- history ----
- (void)setupHistoryTagsView {
    self.historTitleyLabel = [UILabel new];
    self.historTitleyLabel.textColor = [UIColor colorWithHexString:@"#666666"];
    self.historTitleyLabel.font = [UIFont systemFontOfSize:14.f];
    self.historTitleyLabel.text = @"历史搜索";
    [self.view addSubview:self.historTitleyLabel];
    [self.historTitleyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.inset(20);
        make.top.offset(16);
    }];
    
    self.historyTagsView = [TTGTextTagCollectionView new];
    self.historyTagsView.delegate = self;
    self.historyTagsView.verticalSpacing = 10;
    self.historyTagsView.horizontalSpacing = 8;
//    _tagView.alignment = TTGTagCollectionAlignmentFillByExpandingWidth;
//    _tagView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.historyTagsView];
    [self.historyTagsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.inset(20);
        make.top.equalTo(self.historTitleyLabel.mas_bottom).offset(10);
    }];
}

- (void)loadHistoryData {
    [self.historyArrray removeAllObjects];
    NSArray * savedArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"searchHistory"];
    NSArray *searchHistoryArray = (savedArray.count > 5) ? [savedArray subarrayWithRange:NSMakeRange(0, 5)] : savedArray;
    [self.historyArrray addObjectsFromArray:searchHistoryArray];
    
    [self.historyTagsView removeAllTags];
    NSMutableArray *textTags = [NSMutableArray new];
    [self.historyArrray enumerateObjectsUsingBlock:^(NSString *text, NSUInteger idx, BOOL * _Nonnull stop) {
        TTGTextTagStringContent *textTagContent = [[TTGTextTagStringContent alloc] initWithText:text textFont:[UIFont systemFontOfSize:14] textColor:[UIColor colorWithHexString:@"666666"]];
        TTGTextTagStyle *tagStyle = [[TTGTextTagStyle alloc] init];
        tagStyle.extraSpace  = CGSizeMake(30, 12);
        tagStyle.borderWidth = 0;
        tagStyle.shadowColor = UIColor.whiteColor;
        tagStyle.backgroundColor = [UIColor whiteColor];
        TTGTextTag *textTag = [[TTGTextTag alloc] initWithContent:textTagContent style:tagStyle];
        [textTags addObject:textTag];
    }];
    [self.historyTagsView addTags:textTags];
}

// 保存搜索历史标签
- (void)saveSearchHistoryWithString:(NSString *)string {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * searchHistoryArray = [NSMutableArray arrayWithArray:[userDefaults stringArrayForKey:@"searchHistory"]];
    
    NSString * searchKeyword = [NSString stringWithFormat:@"%@",string];
    // 如果该搜索关键字已存在，先删除，再插入在第一个 ，不存在 直接插入第一个
    if ([searchHistoryArray containsObject:searchKeyword]) {
        [searchHistoryArray removeObject:searchKeyword];
    }
    [searchHistoryArray insertObject:string atIndex:0];
    // 最多保存5个数据
    NSArray *saveArray = (searchHistoryArray.count > 5) ? [searchHistoryArray subarrayWithRange:NSMakeRange(0, 5)] : searchHistoryArray;
    // 保存历史搜索标签数据
    [userDefaults setObject:saveArray forKey:@"searchHistory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)textTagCollectionView:(TTGTextTagCollectionView *)textTagCollectionView didTapTag:(TTGTextTag *)tag atIndex:(NSUInteger)index {
    TTGTextTagStringContent *textContent = (TTGTextTagStringContent *)tag.content;
    [self loadSearchDataWithKey:textContent.text];
    [self searchResultShow:YES];
    [self saveSearchHistoryWithString:textContent.text];
}


//=========================init=========================
//导航栏样式
- (void)setNavigationUI{
    //去掉返回按钮，自己设置返回按钮
    [self.navigationItem setHidesBackButton:YES];
    //将searchBar添加上去
    [self.view addSubview:self.searchBar];
    self.searchBar.frame =CGRectMake(0, 5, 0.8*iPhoneWidth, 34);
    self.searchBar.backgroundColor = [UIColor whiteColor];
    self.searchBar.layer.cornerRadius = 5.f;
    self.searchBar.delegate = self;
    self.searchBar.placeholder = NSLocalizedString(@"请输入通道名称", nil);
    [self.searchBar setTintColor:MAIN_COLOR];
    [self.searchBar setImage:[UIImage imageNamed:@"homeSearch"]
            forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
//    self.isSearch = NO;
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
    [cancelBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    cancelBtn.frame = CGRectMake(0.8*iPhoneWidth, 0, 0.2*iPhoneWidth, 44);
    [cancelBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [showView addSubview:cancelBtn];
    
    self.navigationItem.titleView = showView;
    
}

-(void)setUpUI{
    //表视图布局
    [self.view addSubview:self.tv_list];
    [self.tv_list mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, iPhoneHeight-64));
    }];
}

//=========================method=========================
#pragma mark ----- 返回按钮
- (void)backClick{
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
        }
            
    } else {
        // 针对 13.0 以下的iOS系统进行处理
        searchTextField = [self.searchBar valueForKey:@"_searchField"];
        if(searchTextField) {
           //这里设置相关属性
        }
    }
    [searchTextField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 搜索数据
- (void)loadSearchDataWithKey:(NSString *)key
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:key?:@"" forKey:@"chanName"];
    [[HDNetworking sharedHDNetworking]GET:@"open/deviceTree/listNodeChanCodesGroup" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"首页通道model：%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSArray *deviceGroup = responseObject[@"body"][@"deviceGroup"];
            if (deviceGroup.count != 0) {
                NSArray *channelCodeList = deviceGroup[0][@"channelCodeList"];
                self.dataArr = [ChannelCodeListModel mj_objectArrayWithKeyValuesArray:channelCodeList];
            }
            [self.tv_list reloadData];
            [self.tv_list.mj_header endRefreshing];
        }
        else{
            [self.tv_list reloadData];
            [self.tv_list.mj_header endRefreshing];
        }
    } failure:^(NSError * _Nonnull error) {
        [self.tv_list reloadData];
        [self.tv_list.mj_header endRefreshing];
    }];
}

//=========================delegate=========================
#pragma mark -----tableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (iPhoneWidth <=375) {
        return iPhoneWidth/3.5;
    }else{
        return iPhoneWidth/4;//倍率显示cell的高度
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    smallScreenChannelCell *cell = [tableView dequeueReusableCellWithIdentifier:WEIClOUDCELLT];
    cell.cellDelegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.dataArr.count!=0) {
        ChannelCodeListModel *channelModel = self.dataArr[indexPath.row];
        //截图
        UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:channelModel.chanCode];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img1"];
        });
        cell.channelModel = channelModel;
    }
    return cell;
}

//每一行的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChannelCodeListModel *channelModel = self.dataArr[indexPath.row];
    RealTimeChannelVC *realTimeVC = [[RealTimeChannelVC alloc]init];
    realTimeVC.channelModel = channelModel;
    realTimeVC.selectedIndex = indexPath;
    realTimeVC.postDataSources = self.dataArr;
    [unitl saveDataWithKey:SCREENSTATUS Data:SHU_PING];
    [self.navigationController pushViewController:realTimeVC animated:YES];
}

//head的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = BG_COLOR;
    if (section == 0) {
        //提示信息
        self.tipTitleLb.frame = CGRectMake(15, 10, self.view.frame.size.width, 20);
        [headView addSubview:self.tipTitleLb];
    }
    return headView;
}

//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 35;
    }else{
        return 0;
    }
}


//通过滑动表视图来使得键盘消失
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[UIApplication sharedApplication]sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}
-(BOOL)resignFirstResponder
{
    [_searchBar resignFirstResponder];//使你想做的控件失去第一响应，一般情况就是搜索
    return YES;
}



//选择==============================
#pragma  mark ----- searchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
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
    //搜索完后，清空文本框内容
//    self.isSearch = YES;
//    [self filterBySubstring:searchBar.text];
    
    if (![NSString isNull:searchBar.text]) {
        [self loadSearchDataWithKey:searchBar.text];
        [self.searchBar resignFirstResponder];
        
        [self saveSearchHistoryWithString:searchBar.text];
        [self searchResultShow:YES];
    }
}

- (void)searchResultShow:(BOOL)show {
    self.historyTagsView.hidden = self.historTitleyLabel.hidden = show;
    self.tv_list.hidden = !show;
    if (!show) {
        [self loadHistoryData];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    
}

// UISearchBarDelegate定义的方法，当搜索文本框内文本改变时激发该方法
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
//    self.isSearch = YES;
//    [self filterBySubstring:searchBar.text];
//    [self loadSearchDataWithKey:searchBar.text];
    
    if ([NSString isNull:searchText]) {
        // 输入为空时，显示历史数据
        [self searchResultShow:NO];
    }
}

- (UIImage*)getSmallImageWithUrl:(NSString*)imageUrl AtDirectory:(NSString*)directory ImaNameStr:(NSString *)nameStr
{
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取路径
    //1、拼接目录
    NSString *path = [NSHomeDirectory() stringByAppendingString:directory];
    NSString* savePath = [path stringByAppendingString:[NSString stringWithFormat:@"%@.jpg",nameStr]];
    [fileManager changeCurrentDirectoryPath:savePath];
    UIImage *cutIma =  [[UIImage alloc]initWithContentsOfFile:savePath];
    
    return cutIma;
}


#pragma mark - getter&&setter
//searchBar懒加载
-(customSearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[customSearchBar alloc]init];
    }
    return _searchBar;
}
//表视图懒加载
-(UITableView *)tv_list{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tv_list.delegate=self;
        _tv_list.dataSource=self;
        _tv_list.backgroundColor = BG_COLOR;
        _tv_list.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
        [_tv_list registerNib:[UINib nibWithNibName:@"smallScreenChannelCell" bundle:nil] forCellReuseIdentifier:WEIClOUDCELLT];
        if (@available(iOS 11.0, *)) {
            _tv_list.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tv_list;
}
//提示信息
-(UILabel *)tipTitleLb{
    if (!_tipTitleLb) {
        _tipTitleLb = [[UILabel alloc]init];
        _tipTitleLb.text = NSLocalizedString(@"通道列表", nil);
        _tipTitleLb.textColor = [UIColor lightGrayColor];
        _tipTitleLb.font = FONT(15);
    }
    return _tipTitleLb;
}
- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArr;
}
- (NSMutableArray *)historyArrray
{
    if (!_historyArrray) {
        _historyArrray = [NSMutableArray arrayWithCapacity:5];
    }
    return _historyArrray;
}

/*解码器*/
- (JW_CIPHER_CTX)cipher
{
   // if (_cipher == nil) {
        if (self.key && self.bIsEncrypt) {
            size_t len = strlen([self.key cStringUsingEncoding:NSASCIIStringEncoding]);
            _cipher =  jw_cipher_create((const unsigned char*)[self.key cStringUsingEncoding:NSASCIIStringEncoding], len);
            NSLog(@"创建cipher：%p",&_cipher);
        }
   // }
    return _cipher;
}

#pragma mark - TableView 占位图
- (UIImage *)xy_noDataViewImage {
    return [UIImage imageNamed:@"noContent"];
}

- (NSString *)xy_noDataViewMessage {
    return NSLocalizedString(@"未搜索到任何通道", nil);
}

- (NSNumber *)xy_noDataViewCenterYOffset
{
    return @10;
}

@end
