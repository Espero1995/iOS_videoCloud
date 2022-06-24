//
//  LiveCollectedVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/15.
//  Copyright © 2018年 张策. All rights reserved.
//
#define headViewHeight 0.4*iPhoneWidth
#define  dataArrCount 7
#import "LiveCollectedVC.h"
/*直播的cell*/
#import "LiveCollectionCell.h"
/*刷新的控件*/
#import "YALSunnyRefreshControl.h"
/*直播详情界面*/
#import "LiveVideoVC.h"
#import "LiveListModel.h"
@interface LiveCollectedVC ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
>
/*collectionView*/
@property (nonatomic,strong) UICollectionView *collectionView;
/*刷新*/
@property (nonatomic,assign) BOOL refresh;
/*collectionView头部威直播的提示信息*/
@property (nonatomic,strong) UILabel *tipTitleLb;
/*collectionView头部点击更多的按钮*/
@property (nonatomic,strong) UIButton *moreLiveBtn;
/*collectionView底部无更多内容的提示信息*/
@property (nonatomic,strong) UILabel *tipNoInfoLb;
/*直播的视频数组*/
@property (nonatomic,strong) NSMutableArray * dataArr;
//生成一个随机数（10000~100000）
@property (nonatomic,assign) int randomNum;
@end

@implementation LiveCollectedVC

// 注意const的位置
static NSString *const cellId = @"cellId";
static NSString *const headerId = @"headerId";
static NSString *const footerId = @"footerId";
//=========================system=========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BG_COLOR;
    [self setUpUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//=========================init=========================
//页面初始化(UICollectionView)
- (void)setUpUI{

    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = RGB(255, 255, 255);
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, iPhoneHeight-headViewHeight-10-64-44));
    }];
    
    /** 注册单元格（注册cell、sectionHeader、sectionFooter）
     * description: 注册单元格的类型为 UICollectionViewCell ，如果子类化 UICollectionViewCell，这里可指定对应类。
     */
     [self.collectionView registerNib:[UINib nibWithNibName:@"LiveCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:cellId];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerId];
    
    //代理协议
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadLiveData)];
    [header beginRefreshing];
    self.collectionView.mj_header = header;
    
}

//=========================method=========================
//下载直播数据
- (void)loadLiveData{
    NSMutableDictionary * postDic = [[NSMutableDictionary alloc]initWithCapacity:0];
    [[HDNetworking sharedHDNetworking]GET:@"v1/live/list" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"直播：responseObejct:%@",responseObject);
        //if (responseObject[@"ret"] == 0) {
            LiveListModel *listModel = [LiveListModel mj_objectWithKeyValues:responseObject[@"body"]];
            self.dataArr = [NSMutableArray arrayWithArray:listModel.liveChans];
           [self.collectionView reloadData];
      //  }else{
        NSLog(@"获取直播数据失败。！=0");
      //  }
        [self.collectionView.mj_header endRefreshing];
    } failure:^(NSError * _Nonnull error) {
        [self.collectionView.mj_header endRefreshing];
    }];

    _refresh = NO;
    
}

//下拉刷新
-(void)setupRefreshControl{
    //    NSLog(@"下拉刷新");
}
-(void)sunnyControlDidStartAnimation{
    //    NSLog(@"下拉刷新");
}
//结束下拉刷新
-(IBAction)endAnimationHandle{
    //    NSLog(@"结束下拉刷新");
}
//上拉刷新响应
- (void)loadMoreData
{
    [self performSelector:@selector(endUpRefresh) withObject:nil afterDelay:2];
}
- (void)endUpRefresh
{
    [self.collectionView.mj_footer endRefreshing];
}


//点击更多直播按钮
-(void)clickMoreLive{
    [XHToast showCenterWithText:@"暂无更多直播"];
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
    return self.dataArr.count;
}

//实例化每个单元格
//使用 dequeueReusableCellWithReuseIdentifier 方法获得“复用”的单元格实例
//返回的 cell 依赖注册单元格类型，识别符 “DemoCell”也需要一致，否则，这里将返回 nil，导致崩溃。
//这里可以配置每个单元格显示内容，如单元格标题等。
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSInteger section = indexPath.section;
//    NSInteger row = indexPath.row;
    LiveCollectionCell *cell = (LiveCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];

    if (self.dataArr.count != 0) {
        liveChans * livechansModel = self.dataArr[indexPath.row];
        if (livechansModel.status == 1) {
            NSURL * imageURL = [NSURL URLWithString:livechansModel.cover_uri];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage * image = [UIImage imageWithData:imageData];
            cell.LiveImg.image = image;
            cell.LiveTitleLb.text = livechansModel.name;
            //生成一个随机数（10000~100000）
            _randomNum = (10000 + (arc4random() % 90001));
            cell.viewedCount.text = [NSString stringWithFormat:@"%d",self.randomNum];
        }
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
        //提示信息
        self.tipTitleLb.frame = CGRectMake(15, 0, self.view.frame.size.width, 44);
        self.tipTitleLb.text = @"威直播";
        [headerView addSubview:self.tipTitleLb];
        //按钮
        self.moreLiveBtn.frame = CGRectMake(self.view.frame.size.width-80, 0, 80, 44);
        [self.moreLiveBtn setTitle:@"更多 " forState:UIControlStateNormal];
        [self.moreLiveBtn setImage:[UIImage imageNamed:@"moreLive"] forState:UIControlStateNormal];
        [self.moreLiveBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.moreLiveBtn.imageView.image.size.width, 0, self.moreLiveBtn.imageView.image.size.width)];
        [self.moreLiveBtn setImageEdgeInsets:UIEdgeInsetsMake(0, self.moreLiveBtn.titleLabel.bounds.size.width, 0, -self.moreLiveBtn.titleLabel.bounds.size.width)];
        self.moreLiveBtn.titleLabel.font = [UIFont systemFontOfSize: 15];
        [self.moreLiveBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.moreLiveBtn addTarget:self action:@selector(clickMoreLive) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:self.moreLiveBtn];
        
        if (self.dataArr.count == 0) {
            self.moreLiveBtn.hidden = YES;
        }else{
            self.moreLiveBtn.hidden = NO;
        }
        
        return headerView;
    }
    //段尾
    else if ([kind isEqualToString:UICollectionElementKindSectionFooter]){
        UICollectionReusableView *footerView = [_collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footerId forIndexPath:indexPath];
        if (footerView == nil){
            footerView = [[UICollectionReusableView alloc] init];
        }
        footerView.backgroundColor = RGB(255, 255, 255);
        self.tipNoInfoLb.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
        self.tipNoInfoLb.font = FONT(15);
        self.tipNoInfoLb.textColor = [UIColor lightGrayColor];
        self.tipNoInfoLb.textAlignment = NSTextAlignmentCenter;
        [footerView addSubview:self.tipNoInfoLb];
        if (self.dataArr.count == 0) {
//            self.tipNoInfoLb.text = @"目前无任何直播~";
        }else{
            self.tipNoInfoLb.text = @"我也是有底线的哦~";
        }
        
        return footerView;
    }
    
    return nil;
}


#pragma mark ----- collectionView 布局
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (CGSize){(iPhoneWidth-10)/2,(iPhoneWidth-10)/(2*1.18)};//1.18是宽高比的倍率
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.f;
}

//头部的宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return (CGSize){self.view.frame.size.width,44};
}

//底部的宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return (CGSize){self.view.frame.size.width,60};
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
    LiveVideoVC * LiveVideo = [[LiveVideoVC alloc]init];
    liveChans * livechansModel = self.dataArr[indexPath.row];
    LiveVideo.play_info = livechansModel.play_info;
    LiveVideo.titleName = livechansModel.name;
    LiveVideo.liveDesc = livechansModel.desc;
    
     LiveCollectionCell *cell = (LiveCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];

    
    LiveVideo.viewCount = cell.viewedCount.text;
    [self.navigationController pushViewController:LiveVideo animated:YES];
}

//选择==============================

//=========================lazy loading=========================
#pragma mark ----- 懒加载部分
//collectionView懒加载
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        //自定义布局对象
        UICollectionViewFlowLayout *customLayout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:customLayout];
    }
    return _collectionView;
}

//collectionView头部威直播的提示信息懒加载
- (UILabel *)tipTitleLb{
    if (!_tipTitleLb) {
        _tipTitleLb = [[UILabel alloc]init];
    }
    return _tipTitleLb;
}

//collectionView头部点击更多的按钮懒加载
- (UIButton *)moreLiveBtn{
    if (!_moreLiveBtn) {
        _moreLiveBtn = [[UIButton alloc]init];
    }
    return _moreLiveBtn;
}

//collectionView头部暂无更多消息的提示信息懒加载
- (UILabel *)tipNoInfoLb{
    if (!_tipNoInfoLb) {
        _tipNoInfoLb = [[UILabel alloc]init];
    }
    return _tipNoInfoLb;
}
- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArr;
}

@end
