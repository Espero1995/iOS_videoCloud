//
//  fourScreenChannelVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/10/17.
//  Copyright © 2019 苏旋律. All rights reserved.
//
#define LeftSpace 7
#define  headViewHeight iPhoneWidth/4
#import "fourScreenChannelVC.h"
//========Model========
/*通道的model*/
#import "ChannelCodeListModel.h"
/*能力集信息*/
#import "FeatureModel.h"
//========View========
/*轮播图*/
#import "SDCycleScrollView.h"
/*设备cell*/
#import "fourScreenChannelCell.h"
//========VC========
/*工具栏*/
#import "ZCTabBarController.h"
/*实时通道单屏*/
#import "RealTimeChannelVC.h"
/*录像回放*/
#import "ChannelPlayBackVC.h"
/*告警消息列表*/
#import "AlarmMsgVC.h"
@interface fourScreenChannelVC ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    fourChannelCellDelegate,
    SDCycleScrollViewDelegate
>
/*collectionView*/
@property (nonatomic,strong) UICollectionView *collectionView;
/*视频数组*/
@property (nonatomic,strong) NSMutableArray * dataArr;

@property (nonatomic,assign) BOOL refresh;//刷新
@property (nonatomic,strong) UIImage *cutImage;//截图
@property (nonatomic,strong) ChannelCodeListModel * channelModel;

@property (nonatomic,strong)FeatureModel *feature;//能力集信息的model
/*头视图：轮播图*/
@property (nonatomic, strong) UIView *headView;
@end

@implementation fourScreenChannelVC
// 注意const的位置
static NSString *const headerId = @"headerId";
static NSString *const cellId = @"cellId";
static NSString *const footerId = @"footerId";

- (void)viewDidLoad {
    [super viewDidLoad];
    //能力集合model初始化
    self.feature = [[FeatureModel alloc]init];
    self.view.backgroundColor = BG_COLOR;
    [self setUpUI];
    [self setupTitleScrollView];//广告
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    //截图
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updataCutImageWithID:) name:UpDataCutImageWithID object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.collectionView.mj_header endRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//=========================init=========================
// 添加顶部的标题滚动视图
- (void)setupTitleScrollView
{
    UIView * ScrollBackView = [[UIView alloc]initWithFrame:CGRectMake(LeftSpace, 7, iPhoneWidth-14, headViewHeight)];
    ScrollBackView.backgroundColor = [UIColor clearColor];
    ScrollBackView.layer.masksToBounds = YES;
    ScrollBackView.layer.cornerRadius = 4.f;
    [self.headView addSubview:ScrollBackView];
    //加载本地的广告资源
    UIImage *placeholder2 = [UIImage imageNamed:NSLocalizedString(@"banner2", nil)];
    UIImage *placeholder3 = [UIImage imageNamed:NSLocalizedString(@"banner3", nil)];
    NSMutableArray *imaGroup = [NSMutableArray arrayWithObjects:placeholder2,placeholder3, nil];
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, iPhoneWidth-14, headViewHeight) delegate:self placeholderImage:placeholder2];//placeholder1
    cycleScrollView.localizationImageNamesGroup = imaGroup;
    cycleScrollView.pageControlBottomOffset = -8;
    [ScrollBackView addSubview:cycleScrollView];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [dic setValue:userModel.access_token forKey:@"access_token"];
        [dic setValue:userModel.user_id forKey:@"user_id"];
    }
    if (isSimplifiedChinese) {
        [dic setValue:@"10000" forKey:@"data_key"];
    }else{
        [dic setValue:@"20000" forKey:@"data_key"];
    }
    [[HDNetworking sharedHDNetworking]GET:@"v1/user/pubdata/get" parameters:dic success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSMutableString *jsonDataString=[NSMutableString string];
            NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
            jsonDataString = responseObject[@"body"][@"pub_data"][@"top_banner"];
            BaseUrlModel *urlModel = [BaseUrlDefaults geturlModel];
            if (((NSArray *)jsonDataString).count > 0) {
                for (int i = 1; i<((NSArray *)jsonDataString).count; i++) {//0
                    [tempArr addObject:[NSString stringWithFormat:@"%@%@",urlModel.bannerBaseUrl,((NSArray *)jsonDataString)[i]]];
                }
                NSMutableArray *imaGroup = [NSMutableArray arrayWithCapacity:0];
                for (int i =0; i<tempArr.count; i++) {
                    NSURL *picUrl = [NSURL URLWithString:tempArr[i]];
                    UIImage *placeholder =[[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:picUrl]];
                    if (placeholder) {
                        [imaGroup addObject:placeholder];
                    }
                }
                NSURL * picUrl0 = [NSURL URLWithString:tempArr[0]];
                UIImage *placeholder1 =[[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:picUrl0]];
                SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, iPhoneWidth-14, headViewHeight) delegate:self placeholderImage:placeholder1];
                cycleScrollView.backgroundColor = BG_COLOR;
                cycleScrollView.localizationImageNamesGroup = imaGroup;
                cycleScrollView.pageControlBottomOffset = -8;
                [ScrollBackView addSubview:cycleScrollView];
            }
        }
    } failure:^(NSError * _Nonnull error) {
        //加载本地的广告资源
        UIImage *placeholder2 = [UIImage imageNamed:NSLocalizedString(@"banner2", nil)];
        UIImage *placeholder3 = [UIImage imageNamed:NSLocalizedString(@"banner3", nil)];
        NSMutableArray *imaGroup = [NSMutableArray arrayWithObjects:placeholder2,placeholder3, nil];//placeholder1,
        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, iPhoneWidth-14, headViewHeight) delegate:self placeholderImage:placeholder2];
        cycleScrollView.backgroundColor = BG_COLOR;
        cycleScrollView.localizationImageNamesGroup = imaGroup;
        cycleScrollView.pageControlBottomOffset = -8;
        [ScrollBackView addSubview:cycleScrollView];
    }];
}
//页面初始化(UICollectionView)
- (void)setUpUI{
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(iPhoneHeight - iPhoneToolBarHeight - iPhoneNav_StatusHeight);
        make.width.mas_equalTo(iPhoneWidth);
    }];
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadPublicListData)];
    [header beginRefreshing];
    self.collectionView.mj_header = header;
}


//=========================method=========================
#pragma mark -----网络加载公共设备数据信息
- (void)loadPublicListData
{
    _refresh = NO;
    [self.dataArr removeAllObjects];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:self.nodeId forKey:@"nodeId"];
    [[HDNetworking sharedHDNetworking]GET:@"open/deviceTree/listNodeChanCodesGroup" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"通道四分屏：%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSArray *deviceGroup = responseObject[@"body"][@"deviceGroup"];
            if (deviceGroup.count != 0) {
                NSArray *channelCodeList = deviceGroup[0][@"channelCodeList"];
                self.dataArr = [ChannelCodeListModel mj_objectArrayWithKeyValuesArray:channelCodeList];
            }
            [self.collectionView reloadData];
            [self.collectionView.mj_header endRefreshing];        }
        else {
            [self.collectionView reloadData];
            [self.collectionView.mj_header endRefreshing];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.collectionView reloadData];
        [self.collectionView.mj_header endRefreshing];
    }];
}



#pragma mark -----截图方法
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

//通知方法
#pragma mark - 截图通知方法
- (void)updataCutImageWithID:(NSNotification *)noti
{
    if (noti) {
        NSString * cutImageID = [noti.userInfo objectForKey:@"updataImageID"];
        NSIndexPath *indexPath = [noti.userInfo objectForKey:@"selectedIndex"];
        UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:cutImageID];
        dispatch_async(dispatch_get_main_queue(), ^{
            fourScreenChannelCell *cell = (fourScreenChannelCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            cell.ima_photo.image = cutIma;
        });
    }
}

//截图保存并返回显示
- (void)saveSmallImageWithImage:(UIImage*)image Url:(NSString*)imageUrl AtDirectory:(NSString*)directory ImaNameStr:(NSString *)imaNameStr
{
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //1、拼接目录
    NSString *path = [NSHomeDirectory() stringByAppendingString:directory];
    NSString* savePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@.jpg",imaNameStr]];
    [fileManager changeCurrentDirectoryPath:savePath];
    NSLog(@"【monitoringVC】截图保存路径：%@",savePath);
    
    [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    BOOL ret = [fileManager createFileAtPath:savePath contents:UIImagePNGRepresentation(image) attributes:nil];
    if (!ret) {
        NSLog(@"【monitoringVC】截图保存路径 文件 创建失败");
    }
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
    fourScreenChannelCell *cell = (fourScreenChannelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.delegate = self;
    
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

#pragma mark ----- collectionView 布局
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float width = (iPhoneWidth-21)/2.f;
    float height = width*13/23+30;
    return (CGSize){width,height};//计算方式：根据图片的比例去计算高度
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 7, 7, 7);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 7.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
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
        [headerView addSubview:self.headView];
        return headerView;
    }//段尾
    else if ([kind isEqualToString:UICollectionElementKindSectionFooter]){
        UICollectionReusableView *footerView = [_collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footerId forIndexPath:indexPath];
        if (footerView == nil){
            footerView = [[UICollectionReusableView alloc] init];
        }
        footerView.backgroundColor = BG_COLOR;
        return footerView;
    }
    return nil;
}


//头部的宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return (CGSize){self.view.frame.size.width,headViewHeight+14};
}

//底部的宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return (CGSize){self.view.frame.size.width,0};
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
    if (self.dataArr.count!= 0) {
        ChannelCodeListModel *channelModel = self.dataArr[indexPath.row];
        //单屏
        self.tabBarController.tabBar.hidden=YES;
        RealTimeChannelVC *realTimeVC = [[RealTimeChannelVC alloc]init];
        realTimeVC.channelModel = channelModel;
        realTimeVC.selectedIndex = indexPath;    //通过通道数目来判别是否是多通道【注：=0的判断是为了防止后台在搭建新的环境时，未设置通道数目字段】
                    //此外还需判断listModel的chans属性的count来兼容老版本的多通道
        //        if (channelModel.chans.count<=1 && listModel.chanCount <= 1) {
        //            realTimeVC.isMultiChannel = NO;
        //        }else{
        //            realTimeVC.isMultiChannel = YES;
        //        }
        realTimeVC.postDataSources = self.dataArr;
        [unitl saveDataWithKey:SCREENSTATUS Data:SHU_PING];
        [self.navigationController pushViewController:realTimeVC animated:YES];
    }
}

#pragma mark - cell的代理方法

#pragma mark - SD卡按钮的代理方法
- (void)fourChannelCellSDVideoClick:(fourScreenChannelCell *)cell
{
   NSLog(@"SD卡录像点击事件");
   if (cell.channelModel) {
       ChannelPlayBackVC * playbackVC = [[ChannelPlayBackVC alloc]init];
       playbackVC.channelModel = cell.channelModel;
       playbackVC.key = cell.channelModel.dev_p_code;
       playbackVC.isDeviceVideo = YES;
       [self.navigationController pushViewController:playbackVC animated:YES];
   }
}


#pragma mark - 云端录像按钮的代理方法
- (void)fourChannelCellCloudVideoClick:(fourScreenChannelCell *)cell
{
    NSLog(@"云端录像点击事件");
    if (cell.channelModel) {
        ChannelPlayBackVC * playbackVC = [[ChannelPlayBackVC alloc]init];
        playbackVC.channelModel = cell.channelModel;
        playbackVC.key = cell.channelModel.dev_p_code;
        playbackVC.isDeviceVideo = NO;
        [self.navigationController pushViewController:playbackVC animated:YES];
    }
}

#pragma mark - 告警消息按钮的代理方法
- (void)fourChannelCellAlarmVideoClick:(fourScreenChannelCell *)cell
{
     NSLog(@"告警点击事件");
//    AlarmMsgVC *alarmVC = [[AlarmMsgVC alloc]init];
//    alarmVC.homeDevID = cell.model.ID;
//    [self.navigationController pushViewController:alarmVC animated:YES];
}

//=========================lazy loading=========================
#pragma mark ----- lazyLoading
//collectionView懒加载
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        //自定义布局对象
        UICollectionViewFlowLayout *customLayout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:customLayout];
        /** 注册单元格（注册cell、sectionHeader、sectionFooter）
         * description: 注册单元格的类型为 UICollectionViewCell ，如果子类化 UICollectionViewCell，这里可指定对应类。
         */
        [_collectionView registerNib:[UINib nibWithNibName:@"fourScreenChannelCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:cellId];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerId];
        //代理协议
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = BG_COLOR;
        _collectionView.showsVerticalScrollIndicator = NO;
    }
    return _collectionView;
}

//视频数组
- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArr;
}

#pragma mark ----- 设置能力集合
//设置能力集合
- (void)setDeviceFeature:(dev_list*)listModel{
    //1.判断Feature这个key到底在不在
    if (!listModel.ext_info.Feature) {
        //        NSLog(@"不存在Feature");
        self.feature.isWiFi = 0;
        self.feature.isTalk = 0;
        self.feature.isCloudDeck = 0;
        self.feature.isCloudStorage = 0;
        self.feature.isP2P = 0;
    }else{
        //        NSLog(@"存在Feature");
        NSString *featureStr = listModel.ext_info.Feature;
        //        NSLog(@"featureStr:%@",featureStr);
        self.feature.isWiFi = [[featureStr substringWithRange:NSMakeRange(0,1)] intValue];
        self.feature.isTalk = [[featureStr substringWithRange:NSMakeRange(2,1)] intValue];
        self.feature.isCloudDeck = [[featureStr substringWithRange:NSMakeRange(4,1)] intValue];
        self.feature.isCloudStorage = [[featureStr substringWithRange:NSMakeRange(6,1)] intValue];
        self.feature.isP2P = [[featureStr substringWithRange:NSMakeRange(8,1)] intValue];
    }
    // NSLog(@"self.feature.isWiFi:%d,%d,%d,%d,%d",self.feature.isWiFi,self.feature.isTalk,self.feature.isCloudDeck,self.feature.isCloudStorage,self.feature.isP2P);
}

//头部视图懒加载
-(UIView *)headView{
    if (!_headView) {
        _headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, headViewHeight)];
        _headView.backgroundColor = BG_COLOR;
    }
    return _headView;
}

@end
