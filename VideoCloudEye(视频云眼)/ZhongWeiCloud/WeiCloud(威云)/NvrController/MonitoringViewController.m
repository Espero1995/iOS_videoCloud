//
//  MonitoringViewController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/13.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "MonitoringViewController.h"

#import "PassageWay_t.h"
#import "MoreChooseView.h"
#import "MoveCollectionView.h"
#import "ZCTabBarController.h"
#import "SZCalendarPicker.h"
#import "XHToast.h"
#import "VideoModel.h"
#import "TXHRrettyRuler.h"
#import "TimeView.h"
#import "ControlView.h"
#import "CenterTimeView.h"
#import "ZCVideoTimeModel.h"
#import "WeiCloudListModel.h"
#import "TimeListModel.h"
#import "PushMsgModel.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>


#import "JWOpenSdk.h"
#import "JWPlayerManage.h"
#import "JWDeviceRecordFile.h"

static const CGFloat MinimumPressDuration = 0.3;
typedef NS_ENUM(NSInteger, shortcutType)
{
    shortcutType_Video,
    shortcutType_pic
};

@interface MonitoringViewController ()
<
MoveCollectionViewDelegate,
TXHRrettyRulerDelegate,
ControlViewDelegate,
CenterTimeViewDelegate,
MoveCollectionViewDelegate,
MoveViewCell_cDelegete,
MoreChooseViewDelegate,
MoveCollectionCellViewDelegete,
MoveCollectionCellViewDataSoure,
UIScrollViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UITableViewDelegate,
UITableViewDataSource,
UIGestureRecognizerDelegate
>
@property (weak, nonatomic) IBOutlet UIView *VideoViewBack;
@property (weak, nonatomic) IBOutlet UIButton *btn_stop;
@property (weak, nonatomic) IBOutlet UIButton *btn_sound;
@property (weak, nonatomic) IBOutlet UIButton *btn_screen;
@property (weak, nonatomic) IBOutlet UIButton *btn_hd;
@property (weak, nonatomic) IBOutlet UIButton *btn_full;
@property (weak, nonatomic) IBOutlet UIButton *btn_cam;
@property (weak, nonatomic) IBOutlet UIButton *btn_video;
@property (weak, nonatomic) IBOutlet UILabel *lab_jieTu;
@property (weak, nonatomic) IBOutlet UIView *btnBack;
@property (weak, nonatomic) IBOutlet MoveCollectionView *collectionView;
@property (nonatomic,strong) NSIndexPath *selectIndexPath;
@property (nonatomic,strong) NSArray * dataArr;
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,assign) int cellTag;
@property (nonatomic,assign) int i;
@property (nonatomic,assign) int control_num;
@property (nonatomic,assign) CGFloat heigh_c;
@property (nonatomic,assign) NSInteger cellCount;
//列表消失的背景按钮
@property (nonatomic,strong)UIButton *disBtn;
//频道列表选择
@property (nonatomic,strong)MoreChooseView *chooseTabView;
//控制云台View
@property (nonatomic,strong)ControlView *controlView;
//中心日期View
@property (nonatomic,strong)CenterTimeView *centerTimeView;
//进度条
@property (nonatomic,strong)TXHRrettyRuler *rulerView;
//当前暂无录像图片
@property (nonatomic,strong)UIImageView *noImageView;
//进度条时间显示
@property (nonatomic,strong)TimeView *timeViewnew;
//滑动View
@property (nonatomic,strong)UIScrollView *bottowScrollerView;
//pagecontrol
@property (nonatomic,strong)UIPageControl *pageControl;
//图片截图 保存录像
@property (nonatomic, strong)ALAssetsLibrary *assetsLibrary;
//是否中心录像
@property (nonatomic,assign)BOOL isCenter;
//播放速度
@property (nonatomic,assign)int speedInt;
//是否播放
@property (nonatomic,assign)BOOL againPlay;
//是否可以截屏
@property (nonatomic,assign)BOOL isCanCut;
//是否全屏
@property (nonatomic,assign)BOOL isFull;
//是否为直播
@property (nonatomic,assign)BOOL isLive;
//是否hd
@property (nonatomic,assign)BOOL isHd;
//是否正在录像
@property (nonatomic,assign)BOOL isRecord;
//时间模型数组
@property (nonatomic,strong)NSMutableArray *videoTimeModelArr;
//进度条定位的秒
@property (nonatomic,copy)NSString *secStr;
//操作异步串行队列
@property (nonatomic,strong)dispatch_queue_t myActionQueue;
//具体时间
@property (nonatomic,copy)NSString *timeMinStr;

@property (nonatomic,strong)NSMutableDictionary *tagDic;

@property (nonatomic,assign)CGRect oldRect;

@property (nonatomic,assign)NSIndexPath * clickAddBtnIndexPath;

@property (nonatomic,strong)MoveViewCell_c * clickCell;

@property (nonatomic, strong)UIView * deleteBgView;

@property (nonatomic, strong)UIImageView * deleteImageV;

@property (nonatomic, assign)CGRect  normalCellRect;

@property (nonatomic, strong) NSMutableArray * chanName_arr;
@end

@implementation MonitoringViewController

{
    //全局旋转变量
    UIDeviceOrientation _orientation;
    
    BOOL delete;//移动删除
    
}
#pragma mark  -------------- 懒加载成员变量
//列表消失背景按钮
- (UIButton *)disBtn
{
    if (self.isFull == YES) {
        if (!_disBtn) {
            _disBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, iPhoneHeight, iPhoneWidth)];
            _disBtn.backgroundColor = [UIColor lightGrayColor];
            _disBtn.alpha = 0.5;
            [_disBtn addTarget:self action:@selector(disBtnClick) forControlEvents:UIControlEventTouchUpInside];
        }

    }else{
    if (!_disBtn) {
        _disBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
        _disBtn.backgroundColor = [UIColor lightGrayColor];
        _disBtn.alpha = 0.5;
        [_disBtn addTarget:self action:@selector(disBtnClick) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _disBtn;
}
//频道选择列表
- (MoreChooseView *)chooseTabView
{
    if (self.isFull == YES) {
        if (!_chooseTabView) {
            _chooseTabView = [[MoreChooseView alloc]initWithFrame:CGRectMake(0, 0,iPhoneWidth, iPhoneHeight/2+60)];
            _chooseTabView.moreDelegate = self;
        }
    }else{
    if (!_chooseTabView) {
        _chooseTabView = [[MoreChooseView alloc]initWithFrame:CGRectMake(0, iPhoneHeight/2-30, iPhoneWidth-100 , iPhoneHeight/2+60)];
        _chooseTabView.moreDelegate = self;
    }
    }
    return _chooseTabView;
}

//时间模型数组
- (NSMutableArray *)videoTimeModelArr
{
    if (!_videoTimeModelArr) {
        _videoTimeModelArr = [NSMutableArray array];
    }
    return _videoTimeModelArr;
}
//图片保存者
- (ALAssetsLibrary *)assetsLibrary
{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc]init];
    }
    return _assetsLibrary;
}
//进度条
- (TXHRrettyRuler *)rulerView
{
    if (!_rulerView) {
        _rulerView = [[TXHRrettyRuler alloc] initWithFrame:CGRectMake(20, 85, [UIScreen mainScreen].bounds.size.width - 20 * 2, 75)];
        _rulerView.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
        _rulerView.rulerDeletate = self;
    }
    return _rulerView;
}
//没有视频图像
- (UIImageView *)noImageView
{
    if (!_noImageView) {
        _noImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"movie"]];
        _noImageView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-40)/2, 105, 45, 40);
    }
    return _noImageView;
}
//控制云台View
- (ControlView *)controlView
{
    if (!_controlView) {
        _controlView = [ControlView viewFromXib];
        _controlView.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight);
        _controlView.delegate = self;
    }
    return _controlView;
}
//中心日期View
- (CenterTimeView *)centerTimeView
{
    if (!_centerTimeView) {
        _centerTimeView = [CenterTimeView viewFromXib];
        _centerTimeView.frame = CGRectMake(iPhoneWidth, 0, iPhoneWidth, iPhoneWidth);
        _centerTimeView.delegate = self;
    }
    return _centerTimeView;
}
//滑动View
- (UIScrollView *)bottowScrollerView
{
    if (!_bottowScrollerView) {
        _bottowScrollerView = [[UIScrollView alloc]init];
        _bottowScrollerView.delegate = self;
        // 设置内容大小
        self.bottowScrollerView.contentSize = CGSizeMake(iPhoneWidth*2, 0);
        // 是否反弹
        _bottowScrollerView.bounces = NO;
        // 是否分页
        _bottowScrollerView.pagingEnabled = YES;
        _bottowScrollerView.showsVerticalScrollIndicator = NO;
        // 提示用户,Indicators flash
        [_bottowScrollerView flashScrollIndicators];
        // 是否同时运动,lock
        _bottowScrollerView.directionalLockEnabled = YES;
    }
    return _bottowScrollerView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.numberOfPages = 2;//总的图片页数
        _pageControl.currentPage = 0; //当前页
        _pageControl.pageIndicatorTintColor = [UIColor colorWithHexString:@"dddddd"];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"aeaeae"];
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}

//日期
- (TimeView *)timeViewnew
{
    if (!_timeViewnew) {
        _timeViewnew = [TimeView viewFromXib];
    }
    return _timeViewnew;
}
- (dispatch_queue_t)myActionQueue
{
    if (!_myActionQueue) {
        _myActionQueue = dispatch_queue_create("actionQueue", NULL);
    }
    return _myActionQueue;
}

 - (UIView *)deleteBgView
{
    if (!_deleteBgView) {
        _deleteBgView = [[UIView alloc]initWithFrame:CGRectZero];
        _deleteBgView.hidden = YES;
        _deleteBgView.backgroundColor = [UIColor colorWithRed:6.0/255.0 green:120.0/255.0 blue:239.0/255.0 alpha:1.0];
    }
    return _deleteBgView;
}

- (UIImageView *)deleteImageV
{
    if (!_deleteImageV) {
        _deleteImageV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"delete_close"]];
        _deleteImageV.hidden = YES;
    }
    return _deleteImageV;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
     self.automaticallyAdjustsScrollViewInsets = NO;
    self.pageControl.frame = CGRectMake(0, iPhoneHeight-30, iPhoneWidth, 30);
    _heigh_c = self.VideoViewBack.frame.size.height-44;
    if (_screenNum == 1) {
       // [_collectionView scrollToItemAtIndexPath:_selectIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;//设置屏幕常亮
    _chanName_arr = [NSMutableArray array];
    if ([[self.chan_alias allKeys] count] >0) {
        int num = (int)[[self.chan_alias allKeys] count];
        for (int i = 1; i<=num; i++) {
            NSString * key = [NSString stringWithFormat:@"%d",i];
            NSString * str = [self.chan_alias objectForKey:key];
            [_chanName_arr addObject:str];
        }
        
        NSLog(@"-------%@-------",_chanName_arr);
        NSLog(@"%@",self.chan_alias);
    }
}

#pragma mark ------——------ view将要显示消失
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self btnStopClick:self.btn_stop];
    [[HDNetworking sharedHDNetworking]canleAllHttp];
    [self btnStopClick:self.btn_stop];
    for (int i = 0; i < 4; i++) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:indexPath];
        [cell.videoManage JWPlayerManageEndPlayVideoWithBIsStop:NO CompletionBlock:^(JWErrorCode errorCode) {
            
            if (errorCode == JW_SUCCESS) {
                NSLog(@"停止成功");
            }else{
                NSLog(@"停止失败");
            }
        }];
    }
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    [UIApplication sharedApplication].idleTimerDisabled = NO;    //设置屏幕关闭常亮
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark  --------------  UI
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self createCollectionView];
    self.automaticallyAdjustsScrollViewInsets = NO;
   // self.btn_cam.userInteractionEnabled = NO;
   // self.btn_video.userInteractionEnabled = NO;
    
    [self addObserver];
}

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updatePlayImage) name:PLAYFAIL object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopPlayMovie) name:PLAYSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeScreenNumValue:) name:DOUBLETAPNOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeSelectedIndex:) name:MOVEINDEXNOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(LongPressGestureChangeSelectedIndex:) name:CHANGGESELECTEDVALUE object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moveToDelete:) name:MOVETODELETENOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(bottowScrollerViewScroEable:) name:SCROLLVIEWSCROENABLE object:nil];
}

- (void)setUpUI
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    self.title = @"视频监控";
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    //导航栏按钮
    [self cteateNavBtn];
    //初始化位全屏
    self.isFull = NO;
    //初始化是否hd
    self.isHd = NO;
    //初始化未录制
    self.isRecord = NO;
    //初始化是否重新播放
    self.againPlay = NO;
    //创建按钮相关
    [self setUpBtn];
    //添加播放界面
    [self addPlayVideoView];
    
    self.cellCount = 4;//默认进来是4个窗口
    
    
    //添加滑动视图
    [self.view addSubview:self.bottowScrollerView];
    [self.bottowScrollerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lab_jieTu.mas_top).offset(35);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
    }];

    [self.bottowScrollerView addSubview:self.controlView];
    [self.bottowScrollerView addSubview:self.centerTimeView];
    //添加无视频图像
    [self.centerTimeView addSubview:self.noImageView];
    [self.view addSubview:self.pageControl];
    
    
    [self.view addSubview:self.deleteBgView];
    [self.deleteBgView addSubview:self.deleteImageV];
    
    [self.deleteBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.top.mas_equalTo(self.view.mas_top).offset(20);
        make.height.mas_equalTo(@44);
    }];
    
    [self.deleteImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.deleteBgView.center);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
}
#pragma mark -------------- 添加播放视图
- (void)addPlayVideoView
{
    self.isCanCut = NO;
}

#pragma mark ------——------ collectionview 和代理方法
- (void)createCollectionView{
    _screenNum = 4;
    _i = 0;
    _dataArr = @[@"1",@"2",@"3",@"4"];
    //代理
    _collectionView.moveDelegate = self;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.shakeLevel = 0.5f;
    _collectionView.cellCount = 4;
    _collectionView.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    _collectionView.scrollEnabled = NO;
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.VideoViewBack.mas_top).offset(0);
        make.left.equalTo(self.VideoViewBack.mas_left).offset(0);
        make.right.equalTo(self.VideoViewBack.mas_right).offset(0);
        make.bottom.equalTo(self.VideoViewBack.mas_bottom).offset(-44);
    }];

    [_collectionView setMinimumPressDuration:MinimumPressDuration];
}
- (NSArray *)dataSourceArrayOfCollectionView:(MoveCollectionView *)collectionView{
    return _dataArr;
}
- (void)dragCellCollectionView:(MoveCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray{
    _dataArr = newDataArray;
}

//最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

//最小列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
#pragma mark ------ UICollectionView代理方法
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{/*
    if (_screenNum == 4) {
        _bottowScrollerView.scrollEnabled = NO;
        _bottowScrollerView.contentOffset = CGPointZero;
        _pageControl.currentPage = 0;
        if (self.isFull == YES) {
            return CGSizeMake(iPhoneHeight/2-0.5,iPhoneWidth/2-22);
        }else{

            if (iPhone_6_TO_8) {
                return CGSizeMake(iPhoneWidth/2-0.5,99.5);
            }
            if (iPhone_5_Series) {
                return CGSizeMake(iPhoneWidth/2-0.5,81.5);
            }
            return CGSizeMake(iPhoneWidth/2-0.5,112.33);
        }

    }else{
        _bottowScrollerView.scrollEnabled = YES;
        if (self.isFull == YES) {
            return CGSizeMake(iPhoneHeight,iPhoneWidth - 44);
        }else{
            if (iPhone_6_TO_8) {
                return CGSizeMake(iPhoneWidth-0.5,200);
            }
            if (iPhone_5_Series) {
                return CGSizeMake(iPhoneWidth-0.5,164);
            }
            return CGSizeMake(iPhoneWidth,225);
        }    }
  */
    
    if (self.collectionView.currentState == MoveCellStateFourScreen)
    {
        _bottowScrollerView.scrollEnabled = NO;
        _bottowScrollerView.contentOffset = CGPointZero;
        _pageControl.currentPage = 0;
        
        if (iPhone_6_TO_8) {
            return CGSizeMake(iPhoneWidth/2-0.5,99.5);
        }
        if (iPhone_5_Series) {
            return CGSizeMake(iPhoneWidth/2-0.5,81.5);
        }
        return CGSizeMake(iPhoneWidth/2-0.5,112.33);
    }
    else if(self.collectionView.currentState == MoveCellStateFourScreen_HengPing)
    {
        _bottowScrollerView.scrollEnabled = NO;
        _bottowScrollerView.contentOffset = CGPointZero;
        _pageControl.currentPage = 0;
        return CGSizeMake(iPhoneHeight/2-0.5,iPhoneWidth/2-22);
    }
    else if(self.collectionView.currentState == MoveCellStateOneScreen)
    {
        _bottowScrollerView.scrollEnabled = YES;
        if (iPhone_6_TO_8) {
            return CGSizeMake(iPhoneWidth-0.5,200);
        }
        if (iPhone_5_Series) {
            return CGSizeMake(iPhoneWidth-0.5,164);
        }
        return CGSizeMake(iPhoneWidth,225);
    }
    else//MoveCellStateOneScreen_HengPing
    {
        _bottowScrollerView.scrollEnabled = YES;
        return CGSizeMake(iPhoneHeight,iPhoneWidth - 44);
    }
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
    
    return self.cellCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    // 每次先从字典中根据IndexPath取出唯一标识符
    NSString *identifier = [self.tagDic objectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
    // 如果取出的唯一标示符不存在，则初始化唯一标示符，并将其存入字典中，对应唯一标示符注册Cell
    if (identifier == nil) {
        identifier = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
        [self.tagDic setValue:identifier forKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
        // 注册Cell
        //注册重复使用的cell
        [collectionView registerNib:[UINib nibWithNibName:@"MoveViewCell_c" bundle:nil] forCellWithReuseIdentifier:identifier];
    }
    MoveViewCell_c *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.delegete = self;
    cell.cellTag = (int)indexPath.row;
    /*
    //调试用
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor redColor];
    }else if (indexPath.row == 1)
    {
        cell.backgroundColor = [UIColor orangeColor];
    }
    else if (indexPath.row == 2)
    {
        cell.backgroundColor = [UIColor purpleColor];
    }
    */
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.btn_cam.userInteractionEnabled = YES;
    self.btn_video.userInteractionEnabled = YES;
    MoveViewCell_c *cell = (MoveViewCell_c *)[collectionView cellForItemAtIndexPath:indexPath];

    if (indexPath == self.selectIndexPath) {
        return;
    }else{
        self.btn_sound.selected = NO;
        self.btn_hd.selected = NO;
        self.isHd = NO;
        for (int i = 0; i<4; i++) {
            NSIndexPath * index = [NSIndexPath indexPathForItem:i inSection:0];
            MoveViewCell_c * cell0 = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:index];
            if (cell0.isPlay == YES) {
                [cell0.videoManage JWPlayerManageSetAudioIsOpen:NO];

            }
        }
        
    }
    for (int i = 0; i<4; i++) {
        NSIndexPath * index = [NSIndexPath indexPathForItem:i inSection:0];
        MoveViewCell_c * cell1 = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:index];
        
        [cell1.layer setBorderColor:[UIColor clearColor].CGColor];
    }

    if (self.collectionView.currentState == MoveCellStateOneScreen ||
        self.collectionView.currentState == MoveCellStateOneScreen_HengPing) {
        NSLog(@"大屏不加边框");
    }else{
        [cell.layer setBorderColor:MAIN_COLOR.CGColor];
        [cell.layer setBorderWidth:1];
        [cell.layer setMasksToBounds:YES];
    }
   //需要同步修改
//    if (cell.isPlay == YES) {
//        if (cell.HD == YES) {
//            self.btn_hd.selected = YES;
//        }else{
//            self.btn_hd.selected = NO;
//        }
//    }
    self.selectIndexPath = indexPath;
    self.collectionView.selectIndexPath = indexPath;
    
    NSLog(@"点击section%ld的第%ld个cell===self.selectIndexPath：%@===self.collectionView.selectIndexPath:%@===cell.cellTag:%d===cell.tag:%ld",(long)indexPath.section,indexPath.row,self.selectIndexPath,self.collectionView.selectIndexPath,cell.cellTag,(long)cell.tag);
}


#pragma mark ------获取实时音视频地址
- (void)getVideoAddress_new
{
    
    [[HDNetworking sharedHDNetworking]canleAllHttp];
    /*
   // NSIndexPath * indexPath = [NSIndexPath indexPathForItem:_cellTag inSection:0];
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.collectionView.selectIndexPath];
    JWPlayerManage * playerManage = [JWOpenSdk createPlayerManageWithDevidId:self.listModel.ID ChannelNo:_chan_way];
    cell.videoManage = playerManage;
    [cell.videoManage JWPlayerManageSetPlayerView:cell.playView];
    cell.isPlay = YES;
    cell.addBtn.hidden = YES;
    cell.chan_id = _chan_way;
    NSLog(@"测试cellTag=== 0 updatePlayImage === self.collectionView.selectIndexPath==%@===self.selectIndexPath:%@",self.collectionView.selectIndexPath,self.selectIndexPath);
    */
    /**可以用self.clickCell，代替cell，以便，直接点击addBtn就可以知道哪个cell，并播放，不用选中之后在播放了。
     这里，先修改好横屏切换的问题。在完善这个。*/
    //注释：这里先这样，这样写，在停止播放的时候，视频的最后一帧会留在上面，但是不知道为什么其中有一个视频的一帧不会，会直接黑，要做统一留最后一帧的。注意排排除。
    
    
    JWPlayerManage * playerManage = [JWOpenSdk createPlayerManageWithDevidId:self.listModel.ID ChannelNo:_chan_way];
    self.clickCell.videoManage = playerManage;
    [self.clickCell.videoManage JWPlayerManageSetPlayerView:self.clickCell.playView];
    self.clickCell.isPlay = YES;

    self.clickCell.addBtn.hidden = YES;
    self.clickCell.addBtn_new.hidden = YES;
    self.clickCell.reStartBtn.hidden = YES;
    self.clickCell.loadView.hidden = NO;
 
    self.clickCell.chan_id = _chan_way;
    
    
    //正在直播
    self.isLive = YES;

    [self.clickCell.loadView showAnimated:YES];
    if (self.isHd) {
       // self.clickCell.HD = YES; //需要同步修改
        //播放主码流
        [self.clickCell.videoManage JWPlayerManageBeginPlayVideoWithVideoType:JWVideoTypeStatusHd BIsEncrypt:self.bIsEncrypt Key:self.key BIsAP:NO completionBlock:^(JWErrorCode errorCode) {
            errorCode = JW_SUCCESS;
            if (errorCode == JW_SUCCESS) {
                //播放成功可以截图
                self.isCanCut = YES;
               // [XHToast showTopWithText:@"获取高清视频成功" topOffset:160];
                self.clickCell.loadView.hidden = YES;
                NSLog(@"播放高清成功");
            }if (errorCode == JW_FAILD) {
               // [XHToast showTopWithText:@"获取高清视频失败" topOffset:160];
                self.isCanCut = NO;
                self.clickCell.loadView.hidden = YES;
                [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
                NSLog(@"播放高清失败");
            }
        }];
    }
    else{
       // self.clickCell.HD = NO; //需要同步修改
        //播放子码流
        [self.clickCell.videoManage JWPlayerManageBeginPlayVideoWithVideoType:JWVideoTypeStatusNomal BIsEncrypt:self.bIsEncrypt Key:self.key BIsAP:NO completionBlock:^(JWErrorCode errorCode) {
            errorCode = JW_SUCCESS;
            if (errorCode == JW_SUCCESS) {
                //播放成功可以截图
                self.isCanCut = YES;
                //[XHToast showTopWithText:@"获取流畅视频成功1" topOffset:160];
                self.clickCell.loadView.hidden = YES;
                NSLog(@"播放流畅成功");
            }if (errorCode == JW_FAILD) {
                //[XHToast showTopWithText:@"获取流畅视频失败" topOffset:160];
                self.isCanCut = NO;
                self.clickCell.loadView.hidden = YES;
                [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
                NSLog(@"播放流畅失败");
            }
        }];
    }
}

#pragma mark ------获取实时音视频地址
- (void)getVideoAddress
{
    NSLog(@"打印看看设备在不在线：%ld",(long)self.listModel.status);
    
    [[HDNetworking sharedHDNetworking]canleAllHttp];

     // NSIndexPath * indexPath = [NSIndexPath indexPathForItem:_cellTag inSection:0];
     MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.collectionView.selectIndexPath];
     JWPlayerManage * playerManage = [JWOpenSdk createPlayerManageWithDevidId:self.listModel.ID ChannelNo:cell.chan_way];
     cell.videoManage = playerManage;
     [cell.videoManage JWPlayerManageSetPlayerView:cell.playView];
     cell.isPlay = YES;
    
    if (self.listModel.status == 1) {
        cell.loadView.hidden = NO;
        cell.addBtn.hidden = YES;
        cell.addBtn_new.hidden = YES;
        cell.reStartBtn.hidden = YES;
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
    }
    
    
    
    
     cell.chan_id = cell.chan_way;
     cell.closeBtn.hidden = YES;
     NSLog(@"测试cellTag=== 0 updatePlayImage === self.collectionView.selectIndexPath==%@===self.selectIndexPath:%@",self.collectionView.selectIndexPath,self.selectIndexPath);
    
   
     
    /**可以用self.clickCell，代替cell，以便，直接点击addBtn就可以知道哪个cell，并播放，不用选中之后在播放了。
     这里，先修改好横屏切换的问题。在完善这个。*/
    //注释：这里先这样，这样写，在停止播放的时候，视频的最后一帧会留在上面，但是不知道为什么其中有一个视频的一帧不会，会直接黑，要做统一留最后一帧的。注意排排除。
    
    /*
    JWPlayerManage * playerManage = [JWOpenSdk createPlayerManageWithDevidId:self.listModel.ID ChannelNo:_chan_way];
    self.clickCell.videoManage = playerManage;
    [self.clickCell.videoManage JWPlayerManageSetPlayerView:self.clickCell.playView];
    self.clickCell.isPlay = YES;
    self.clickCell.addBtn.hidden = YES;
    self.clickCell.addBtn_new.hidden = YES;
    self.clickCell.reStartBtn.hidden = YES;
    self.clickCell.chan_id = _chan_way;
    */
    
    //正在直播
    self.isLive = YES;
    
    [cell.loadView showAnimated:YES];

    if (self.isHd) {
       // cell.HD = YES; //需要同步修改
        //播放主码流
        [cell.videoManage JWPlayerManageBeginPlayVideoWithVideoType:JWVideoTypeStatusHd BIsEncrypt:self.bIsEncrypt Key:self.key BIsAP:NO completionBlock:^(JWErrorCode errorCode) {
            errorCode = JW_SUCCESS;
            if (errorCode == JW_SUCCESS) {
                //播放成功可以截图
                self.isCanCut = YES;
                // [XHToast showTopWithText:@"获取高清视频成功" topOffset:160];
                cell.loadView.hidden = YES;
                NSLog(@"播放高清成功");
            }if (errorCode == JW_FAILD) {
                // [XHToast showTopWithText:@"获取高清视频失败" topOffset:160];
                self.isCanCut = NO;
                cell.loadView.hidden = YES;
                NSLog(@"播放高清失败");
                [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
            }
        }];
    }
    else{
       // cell.HD = NO; //需要同步修改
        //播放子码流
        [cell.videoManage JWPlayerManageBeginPlayVideoWithVideoType:JWVideoTypeStatusNomal BIsEncrypt:self.bIsEncrypt Key:self.key BIsAP:NO completionBlock:^(JWErrorCode errorCode) {
            errorCode = JW_SUCCESS;
            if (errorCode == JW_SUCCESS) {
                //播放成功可以截图
                self.isCanCut = YES;
                //[XHToast showTopWithText:@"获取流畅视频成功1" topOffset:160];
                cell.loadView.hidden = YES;
                NSLog(@"播放流畅成功");
            }if (errorCode == JW_FAILD) {
                //[XHToast showTopWithText:@"获取流畅视频失败" topOffset:160];
                self.isCanCut = NO;
                cell.loadView.hidden = YES;
                [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
                NSLog(@"播放流畅失败");
            }
        }];
    }
}


#pragma mark - 通知实现
- (void)updatePlayImage
{
    /*
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:_cellTag inSection:0];
    NSLog(@"测试cellTag=== 1 updatePlayImage ===cellTag：%d",self.cellTag);
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:indexPath];
    cell.reStartBtn.hidden = NO;
    */
    /*
    self.clickCell.reStartBtn.hidden = NO;
    self.clickCell.loadView.hidden = YES;
    */
    if (!self.collectionView.selectIndexPath) {
        
    }else{
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.collectionView.selectIndexPath];
        cell.reStartBtn.hidden = NO;
        cell.addBtn.hidden = YES;
        cell.addBtn_new.hidden = YES;
        cell.loadView.hidden = YES;
    }
}

- (void)stopPlayMovie{
        self.clickCell.loadView.hidden = YES;
}

- (void)changeScreenNumValue:(NSNotification*)noti
{
    if (noti.userInfo) {
        NSString * str = [noti.userInfo objectForKey:@"isBig"];
        NSIndexPath * selecedIndex = [noti.userInfo objectForKey:@"selectIndexPath"];
        self.selectIndexPath = selecedIndex;
        self.collectionView.selectIndexPath = selecedIndex;
        if ([str  isEqualToString:@"YES"]) {
            self.screenNum = 1;
            self.btn_screen.selected = YES;
        }else{
            self.screenNum = 4;
            self.btn_screen.selected = NO;
        }
    }
}
#pragma mark - cell被移动后，cell.indexPath 的变化
- (void)changeSelectedIndex:(NSNotification*)noti
{
    if (noti.userInfo) {
        NSIndexPath * moveToIndex = [noti.userInfo objectForKey:@"moveToIndex"];
        self.selectIndexPath = moveToIndex;
        self.collectionView.selectIndexPath = moveToIndex;
        self.cellTag = (int)moveToIndex.row;
        NSLog(@"改变cell位置之后，新的moveindex：%@===self.cellTag:%d",self.selectIndexPath,self.cellTag);
    }
}
//代替didSelected的点击选中改变self.selectIndexPath
- (void)LongPressGestureChangeSelectedIndex:(NSNotification *)noti
{
    if (noti.userInfo) {
        self.selectIndexPath = [noti.userInfo objectForKey:@"selectIndexPath"];
    }
}

- (void)moveToDelete:(NSNotification *)noti
{
    if (noti.userInfo) {
        if (self.isFull) {
            [self refreshMoveTodeleteViewFrameWhenHengPing];
        }else{
            [self refreshMoveTodeleteViewFrameWhenshuPing];
        }
        if ([[noti.userInfo objectForKey:@"message"]isEqualToString:@"delete"]) {
            self.navigationController.navigationBarHidden = NO;//TODO
            self.deleteImageV.hidden = NO;
            self.deleteBgView.hidden = NO;
            delete = YES;
            self.deleteBgView.backgroundColor = [UIColor redColor];
            self.deleteImageV.image = [UIImage imageNamed:@"delete_open"];
        }else if([[noti.userInfo objectForKey:@"message"]isEqualToString:@"undelete"])
        {
            self.navigationController.navigationBarHidden =  NO;//TODO
            self.deleteImageV.hidden = NO;
            self.deleteBgView.hidden = NO;
            delete = NO;
            self.deleteBgView.backgroundColor = MAIN_COLOR;
            self.deleteImageV.image = [UIImage imageNamed:@"delete_close"];
        }
        else
        {
            if (delete) {
                [[NSNotificationCenter defaultCenter]postNotificationName:DELETEPLAYCELL object:nil userInfo:@{@"":@""}];
            }
            if (!self.isFull) {
                self.navigationController.navigationBarHidden = NO;
            }
            self.deleteImageV.hidden = YES;
            self.deleteBgView.hidden = YES;
        }
    }
}
//横屏，全屏的时候
- (void)refreshMoveTodeleteViewFrameWhenHengPing
{
    [self.deleteBgView removeFromSuperview];
    [self.deleteImageV removeFromSuperview];
    [self.view addSubview:self.deleteBgView];
    [self.deleteBgView addSubview:self.deleteImageV];
    [self.deleteBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.top.mas_equalTo(self.view.mas_top).offset(0);
        make.height.mas_equalTo(@44);
    }];
    
    [self.deleteImageV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.deleteBgView.mas_top);
        make.centerX.mas_equalTo(self.deleteBgView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}
//竖屏，正常的时候
- (void)refreshMoveTodeleteViewFrameWhenshuPing
{
    [self.deleteBgView removeFromSuperview];
    [self.deleteImageV removeFromSuperview];
//    [self.view addSubview:self.deleteBgView];
//    [self.navigationItem.titleView addSubview:self.deleteBgView];// = ;
    [self.navigationController.navigationBar addSubview:self.deleteBgView];
    [self.deleteBgView addSubview:self.deleteImageV];
    [self.deleteBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.top.mas_equalTo(self.view.mas_top).offset(-44);//todo 20
        make.height.mas_equalTo(@44);//todo 44
    }];
    
    [self.deleteImageV mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.deleteBgView.mas_top);
        make.centerX.mas_equalTo(self.deleteBgView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(44, 44));//44 todo
    }];
}

- (void)bottowScrollerViewScroEable:(NSNotification*)noti
{
    if (noti) {
        if ([[noti.userInfo objectForKey:@"ScrollViewScroEnable"]isEqualToString:@"YES"]) {
            self.bottowScrollerView.scrollEnabled = YES;
        }else
        {
            self.bottowScrollerView.scrollEnabled = NO;
        }
    }
}

#pragma mark ------------- 选择通道按钮和双击放大

- (void)MoveViewCell_cAddBtnClick:(MoveViewCell_c *)cell{

    for (int i = 0; i<4; i++) {
        NSIndexPath * index = [NSIndexPath indexPathForItem:i inSection:0];
        MoveViewCell_c * cell1 = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:index];
        [cell1.layer setBorderColor:[UIColor clearColor].CGColor];
    }
    [cell.layer setBorderColor:[UIColor colorWithHexString:@"#38adff"].CGColor];
    [cell.layer setBorderWidth:1];
    [cell.layer setMasksToBounds:YES];

    NSIndexPath * indexPath = [_collectionView indexPathForCell:cell];
    self.clickAddBtnIndexPath = indexPath;
   // self.clickCell = cell;
    self.selectIndexPath = self.clickAddBtnIndexPath;
    self.collectionView.selectIndexPath = self.clickAddBtnIndexPath;
    
   // _cellTag = cell.cellTag;//注释：这里的cell.cellTag因为是indexpath.row来的，所以cell移动过后，还是默认为3.
    NSLog(@"测试cellTag=== 2 cell.tag:%d=====indexPath:%@ ===indexPath_test:%@",cell.cellTag,_clickAddBtnIndexPath,indexPath);
    [self showTableView];
    
}
- (void)cellFullPlay:(VideoModel *)videoModel
{
    [self btnScreenClick:self.btn_screen];
}

#pragma mark - ------------- 播放失败，不用选择，直接播放当前通道视频
- (void) MoveViewCell_cReStartBtnClick:(MoveViewCell_c *)cell
{
    NSIndexPath * indexPath = [_collectionView indexPathForCell:cell];
    self.clickAddBtnIndexPath = indexPath;
    self.selectIndexPath = self.clickAddBtnIndexPath;
    self.collectionView.selectIndexPath = self.clickAddBtnIndexPath;
    NSLog(@"测试cellTag=== 2【新+号】indexPath：%@",indexPath);

    [self getVideoAddress];
}
#pragma  mark - ------------- 删除过cell，新的选择通道btn
- (void) MoveViewCell_caddBtn_new_Click:(MoveViewCell_c *)cell
{
    for (int i = 0; i<4; i++) {
        NSIndexPath * index = [NSIndexPath indexPathForItem:i inSection:0];
        MoveViewCell_c * cell1 = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:index];
        [cell1.layer setBorderColor:[UIColor clearColor].CGColor];
    }
    [cell.layer setBorderColor:[UIColor colorWithHexString:@"#38adff"].CGColor];
    [cell.layer setBorderWidth:1];
    [cell.layer setMasksToBounds:YES];
    
    NSIndexPath * indexPath = [_collectionView indexPathForCell:cell];
    self.clickAddBtnIndexPath = indexPath;
    //self.clickCell = cell;
    self.selectIndexPath = self.clickAddBtnIndexPath;
    self.collectionView.selectIndexPath = self.clickAddBtnIndexPath;
    
    NSLog(@"测试cellTag=== 2 【新】cell.tag:%d=====indexPath:%@ ===indexPath_test:%@",cell.cellTag,_clickAddBtnIndexPath,indexPath);
    [self showTableView];
}

#pragma mark 删除cell
- (void) MoveViewCell_deleteClick:(MoveViewCell_c *)cell
{
    NSIndexPath * currentIndexPath = [_collectionView indexPathForCell:cell];

//    NSLog(@"currentIndexPath :%@====cell:%@",currentIndexPath,cell);
    NSDictionary * dic = @{@"currentIndexPath":currentIndexPath};
    
    [[NSNotificationCenter defaultCenter]postNotificationName:DELETEPLAYCELL object:nil userInfo:dic];
}

#pragma mark ------     列表展示 消失
//展示频道列表
- (void)showTableView
{
    [self.view addSubview:self.disBtn];
    [self.view addSubview:self.chooseTabView];
    if (self.isFull == YES) {
        [_chooseTabView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset((iPhoneHeight-iPhoneWidth)/2);
            make.top.equalTo(self.view.mas_top).offset(0);
            make.right.equalTo(self.view.mas_right).offset(-(iPhoneHeight-iPhoneWidth)/2);
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
        }];
  
    }else{
    [_chooseTabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(50);
        make.top.equalTo(self.view.mas_top).offset(iPhoneHeight/2-90);//TODO
        make.right.equalTo(self.view.mas_right).offset(-50);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
    }];
    }
    [self createTableView];
}
- (void)disBtnClick
{
    [self.chooseTabView removeFromSuperview];
    self.chooseTabView = nil;
    [self.disBtn removeFromSuperview];
    self.disBtn = nil;
}
#pragma mark ------创建tableview并设置代理
// 创建tableView
-(void)createTableView{
    if (self.isFull == YES) {
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, iPhoneWidth, iPhoneWidth-44) style:UITableViewStylePlain];
    }else{
        self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, iPhoneWidth-100, iPhoneHeight/2-14) style:UITableViewStylePlain];
    }
    //设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    self.tableView.alwaysBounceVertical = NO;
    UIView * footView = [[UIView alloc]init];
    self.tableView.tableFooterView = footView;
    [self.chooseTabView addSubview:self.tableView];
}
//行高

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _chan_size;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * str = @"MyCell";
    PassageWay_t * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        
        cell = [[PassageWay_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
        
    }
    if (indexPath.row<_chanName_arr.count) {
        cell.titleLbel.text = [NSString stringWithFormat:@"%@",_chanName_arr[indexPath.row]];
    }else{
        cell.titleLbel.text = [NSString stringWithFormat:@"通道00%ld",(long)indexPath.row+1];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    for (int i = 0; i<_chan_size; i++) {
//        NSIndexPath * index = [NSIndexPath indexPathForItem:i inSection:0];
//        PassageWay_t * cell1 = [_tableView cellForRowAtIndexPath:index];
//        cell1.chooseBtn.selected = NO;
//    }
        PassageWay_t * cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.chooseBtn.selected == NO) {
            cell.chooseBtn.selected = YES;
            _chan_way = (int)indexPath.row+1;
            
            MoveViewCell_c * cell = (MoveViewCell_c *)[self.collectionView cellForItemAtIndexPath: self.collectionView.selectIndexPath];
            cell.chan_way = (int)indexPath.row + 1;

            [self disBtnClick];
            [self getVideoAddress];
        }
}

#pragma mark ------------ 按钮状态初始化
- (void)setUpBtn//nvr 日历时间
{
    [self.btn_screen setImage:[UIImage imageNamed:@"one_h"] forState:UIControlStateHighlighted];
    [self.btn_screen setImage:[UIImage imageNamed:@"one_n"] forState:UIControlStateSelected];
    [self.btn_sound setImage:[UIImage imageNamed:@"sound_open_n"] forState:UIControlStateSelected];
    [self.btn_hd setImage:[UIImage imageNamed:@"hd_h"] forState:UIControlStateSelected];
    [self.btn_cam setBackgroundImage:[UIImage imageNamed:@"screenshot1111_h"] forState:UIControlStateSelected];
    [self.btn_video setBackgroundImage:[UIImage imageNamed:@"video_h"] forState:UIControlStateSelected];
    
    //今日时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-M-d"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    [self.centerTimeView.btn_time setTitle:currentTime forState:UIControlStateNormal];
    
    //中心录像
    self.isCenter = NO;
    //是否可以截屏
    self.isCanCut = NO;
}


#pragma mark ------控制云台代理
//向上
- (void)ControlViewBtnTopClick{
    _control_num = 1;
    [self ControlFunc];
}
//停止向上
- (void)ControlViewBtnTopInside{
    [self controlStop];
}
//向下
- (void)ControlViewBtnDownClick{
    _control_num = 2;
    [self ControlFunc];
    
}
//停止向下
- (void)ControlViewBtnDownInside{
    [self controlStop];
}
//向左
- (void)ControlViewBtnLeftClick{
    _control_num = 3;
    [self ControlFunc];
    
}
//停止向左
- (void)ControlViewBtnLeftInside{
    [self controlStop];
}
//向右
- (void)ControlViewBtnRightClick{
    _control_num = 4;
    [self ControlFunc];
    
}
//停止向右
- (void)ControlViewBtnRightInside{
    [self controlStop];
}

#pragma mark - 云台控制
- (void)ControlFunc
{
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
    NSNumber * chan_num = [NSNumber numberWithInteger:cell.chan_id];
    NSNumber * cmd_num = [NSNumber numberWithInteger:_control_num];
    NSMutableDictionary * changeDic = [NSMutableDictionary dictionary];
    [changeDic setObject:self.listModel.ID forKey:@"dev_id"];
    [changeDic setObject:chan_num forKey:@"chan_id"];
    [changeDic setObject:cmd_num forKey:@"cmd"];
    [changeDic setObject:@"5" forKey:@"speed"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/ptz/start" parameters:changeDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSLog(@"开始控制成功");
            
        }
        NSLog(@"%d",ret);
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"失败了");
    }];
}
#pragma mark - 云台控制--停止
- (void)controlStop{
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
    NSNumber * chan_num = [NSNumber numberWithInteger:cell.chan_id];
    NSMutableDictionary * changeDic = [NSMutableDictionary dictionary];
    [changeDic setObject:self.listModel.ID forKey:@"dev_id"];
    [changeDic setObject:chan_num forKey:@"chan_id"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/ptz/stop" parameters:changeDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSLog(@"停止控制成功");
        }
        NSLog(@"%d",ret);
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"失败了");
    }];
}

#pragma mark  --------------  停止按钮的响应方法和触发事件
//停止按钮
- (IBAction)btnStopClick:(id)sender {
    if (_selectIndexPath == nil) {
        
    }else{
    NSLog(@"停止");
        self.clickCell.loadView.hidden = YES;
    [[HDNetworking sharedHDNetworking]canleAllHttp];
    //如果正在录像就停止录制
    [self judgeIsRecord];
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (cell.isPlay == YES) {
        //截取正在播放的视频保存到沙盒
        if (self.isCanCut) {
            [self backCutImage];
        }
        cell.isPlay = NO;
      [cell.videoManage JWPlayerManageEndPlayVideoWithBIsStop:YES CompletionBlock:^(JWErrorCode errorCode) {
    if (errorCode == JW_SUCCESS) {
                cell.addBtn.hidden = YES;
                cell.reStartBtn.hidden = NO;
                cell.closeBtn.hidden = NO;
                NSLog(@"停止成功");
            }else{
                NSLog(@"停止失败");
            }
        }];
    }else{
        cell.isPlay = NO;
     [cell.videoManage JWPlayerManageEndPlayVideoWithBIsStop:YES CompletionBlock:^(JWErrorCode errorCode) {
    if (errorCode == JW_SUCCESS) {
                cell.addBtn.hidden = YES;
                cell.reStartBtn.hidden = NO;
                cell.closeBtn.hidden = NO;
                NSLog(@"停止成功");
            }else{
                NSLog(@"停止失败");
            }
        }];
    }
    }
}

#pragma mark  -------------- 声音按钮的响应方法
//声音按钮
- (IBAction)btnSoundClick:(id)sender {
    if (_selectIndexPath == nil) {
        return;
    }else{
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        UIButton *btn = (UIButton *)sender;
        btn.selected = !btn.selected;
        if (cell.isPlay == YES) {
            if (btn.selected) {
                [XHToast showTopWithText:@"声音:开" topOffset:160];
                [cell.videoManage JWPlayerManageSetAudioIsOpen:YES];
            }else{
                [XHToast showTopWithText:@"声音:关" topOffset:160];
                [cell.videoManage JWPlayerManageSetAudioIsOpen:NO];
            }
        }
    }
}

#pragma mark  -------------- 分屏按钮的相应事件
//分屏按钮
- (IBAction)btnScreenClick:(id)sender {

    if (self.selectIndexPath == nil) {
        return;
    }else{
        UIButton * btn = (UIButton *)sender;
        btn.selected= !btn.selected;
        if (btn.selected) {
            self.screenNum = 1;
        }else{
            self.screenNum = 4;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:SPLITSCREENNOTIFICATION object:nil];
    }
    /*
    if (_selectIndexPath = nil) {
        
    }else{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    _i ++;
    NSLog(@"%d",_i);
    _dataArr = @[@"1",@"2",@"3",@"4"];
    //代理
    if (self.isFull == YES) {
        if (_i%2==1) {
            _screenNum = 1;
            _collectionView.shakeLevel = 0;
            _collectionView.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
            _collectionView.scrollEnabled = NO;
            [_collectionView setMinimumPressDuration:MinimumPressDuration];
            
            
            _collectionView.backgroundColor = [UIColor clearColor];
            _collectionView.cellSize = CGSizeMake(iPhoneHeight,iPhoneWidth-44);
            _collectionView.cellCount = 4;
            _collectionView.scrollEnabled = NO;
            _collectionView.moveDelegate = self;
            [self.collectionView reloadData];
            
            [_collectionView scrollToItemAtIndexPath:_selectIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        }else{
            _screenNum = 4;
            [self createCollectionView];
            [self.collectionView reloadData];
        }
        
    }else{
        if (_i%2==1) {
            _screenNum = 1;
            _collectionView.shakeLevel = 0;
            _collectionView.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
            _collectionView.scrollEnabled = NO;
            [_collectionView setMinimumPressDuration:MinimumPressDuration];
        
        
            _collectionView.backgroundColor = [UIColor clearColor];
            _collectionView.cellSize = CGSizeMake(iPhoneWidth-1,_heigh_c);
            _collectionView.cellCount = 4;
            _collectionView.scrollEnabled = NO;
            _collectionView.moveDelegate = self;
            [self.collectionView reloadData];
            [_collectionView scrollToItemAtIndexPath:_selectIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }else{
        _screenNum = 4;
        [self createCollectionView];
        [self.collectionView reloadData];
    }
    }
    NSLog(@"分屏");
    }
     */
}

#pragma mark  -------------- 高清按钮的响应事件
//高清按钮
- (IBAction)btnHdClick:(id)sender {
    if (_selectIndexPath == nil) {
        
    }else{
        UIButton *btn = (UIButton *)sender;
        btn.selected = !btn.selected;
        self.isHd = btn.selected;
        NSLog(@"切换清晰度");
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        if (cell.isPlay) {
            if (self.isHd) {
                [XHToast showTopWithText:@"高清" topOffset:160];
                [self judgeIsRecord];//如果正在录像就停止录制
                [self getVideoAddress];
            }
            else{
                [XHToast showTopWithText:@"流畅" topOffset:160];
                [self judgeIsRecord];//如果正在录像就停止录制
                [self getVideoAddress];
            }
        }
    }
}
#pragma mark  -------------- 全屏按钮的响应事件
//全屏按钮
- (IBAction)btnFullClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (self.isFull == NO) {
        [self.btn_full setImage:[UIImage imageNamed:@"small_n"] forState:UIControlStateNormal];
//        [self.view setNeedsLayout];
//        [self.view layoutIfNeeded];
       // [self rightHengpinAction];
        [self rightHengpinAction_xiugai];

    }else{
        [self.btn_full setImage:[UIImage imageNamed:@"full_n"] forState:UIControlStateNormal];
        //[self shupinAction];
        [self shupinAction_xiugai];

    }
    //[self setNeedsStatusBarAppearanceUpdate];
}
#pragma mark  -------------- 横屏
-(void)rightHengpinAction
{
    self.isFull = YES;
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [UIView animateWithDuration:0.25 animations:^{
        [self.VideoViewBack mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(0);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
        }];
        
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.VideoViewBack.mas_top).offset(0);
            make.left.equalTo(self.VideoViewBack.mas_left).offset(30);
            make.bottom.equalTo(self.VideoViewBack.mas_bottom).offset(-44);//-44
            make.right.equalTo(self.VideoViewBack.mas_right).offset(0);
        }];
        if (_screenNum == 1) {
            
            /*
            _collectionView.backgroundColor = [UIColor clearColor];
            //_collectionView.cellSize = CGSizeMake(150,150);//iPhoneHeight,iPhoneWidth-44
            _collectionView.cellSize = CGSizeMake(iPhoneHeight,iPhoneWidth-44);
            _collectionView.cellCount = 4;
            _collectionView.scrollEnabled = NO;
            _collectionView.moveDelegate = self;

        //[_collectionView scrollToItemAtIndexPath:_selectIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            NSLog(@"横屏的全屏=_selectIndexPath：%@",_selectIndexPath);
            
            [self.collectionView reloadData];

            */
            
            
          /*
            _collectionView.cellSize = CGSizeMake(iPhoneHeight,iPhoneWidth-44);

            _collectionView.moveDelegate = self;
            _collectionView.delegate = self;
            _collectionView.dataSource = self;
            _collectionView.cellCount = 4;
            _collectionView.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
            _collectionView.scrollEnabled = NO;
            
            [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.VideoViewBack.mas_top).offset(0);
                make.left.equalTo(self.VideoViewBack.mas_left).offset(0);
                make.right.equalTo(self.VideoViewBack.mas_right).offset(0);
                make.bottom.equalTo(self.VideoViewBack.mas_bottom).offset(-44);
            }];
            [self.collectionView reloadData];
*/
            
            
        }else{
            _screenNum = 4;
            [self createCollectionView];
            [self.collectionView reloadData];
        }
        
        
        [self.bottowScrollerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lab_jieTu.mas_top).offset(35);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
        }];
        if (self.isLive) {
            [self.bottowScrollerView setContentOffset:CGPointMake(0, 0)];
        }else{
            [self.bottowScrollerView setContentOffset:CGPointMake(iPhoneWidth, 0)];
        }
        self.pageControl.hidden = YES;
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
         
        //            self.VideoViewBank.transform = CGAffineTransformMakeRotation((90.0f * M_PI) / 180.0f);
        float arch = M_PI_2;
        //对navigationController.view 进行强制旋转
        self.navigationController.view.transform = CGAffineTransformMakeRotation(arch);
        self.navigationController.view.bounds = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
    }];
}

#pragma mark  -------------- 竖屏
-(void)shupinAction
{
    CGFloat bili = (CGFloat)(375.0000/244.000);
    
    CGFloat viewWidth;
    if (self.isFull == YES) {
        viewWidth  = (CGFloat)self.view.height;
    }else{
        viewWidth  = (CGFloat)self.view.width;
    }
    CGFloat h  = (CGFloat)viewWidth/bili;
    self.isFull = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [UIView animateWithDuration:0.25 animations:^{
        [self.VideoViewBack mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(64);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.height.equalTo(@(h));
        }];
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.VideoViewBack.mas_top).offset(0);
            make.left.equalTo(self.VideoViewBack.mas_left).offset(0);
            make.bottom.equalTo(self.VideoViewBack.mas_bottom).offset(-44);
            make.right.equalTo(self.VideoViewBack.mas_right).offset(0);
        }];
        if (_screenNum == 1) {
            _collectionView.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
            _collectionView.scrollEnabled = NO;
            [_collectionView setMinimumPressDuration:0.5];
            
            
            _collectionView.backgroundColor = [UIColor clearColor];
            _collectionView.cellSize = CGSizeMake(iPhoneWidth-1,_heigh_c);
            _collectionView.scrollEnabled = NO;
            _collectionView.moveDelegate = self;
            
            [_collectionView scrollToItemAtIndexPath:_selectIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            
        }else{
            [self createCollectionView];
            [self.collectionView reloadData];
        }
        
        [self.btn_cam mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.VideoViewBack.mas_bottom).offset(30);
        }];
        
        //        CGFloat layoutFloat = 375/244;
        //        [self.VideoViewBackLayout setConstant:layoutFloat];
        
        [self.bottowScrollerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lab_jieTu.mas_top).offset(35);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
        }];
        
        if (self.isLive) {
            [self.bottowScrollerView setContentOffset:CGPointMake(0, 0)];
        }else{
            [self.bottowScrollerView setContentOffset:CGPointMake(iPhoneWidth, 0)];
        }
        
        self.pageControl.hidden = NO;
        
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        float arch = 0;
        //对navigationController.view 进行强制旋转
        self.navigationController.view.transform = CGAffineTransformMakeRotation(arch);
        self.navigationController.view.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
}

#pragma mark  -----------以下修改，还没有全部修复完成。todo
#pragma mark  -------------- 横屏
-(void)rightHengpinAction_xiugai
{
    
    self.isFull = YES;
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
     self.normalCellRect = cell.frame;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        float arch = M_PI_2;
        //对navigationController.view 进行强制旋转
        self.navigationController.view.transform = CGAffineTransformMakeRotation(arch);
        self.navigationController.view.bounds = CGRectMake(0, 0,SCREEN_HEIGHT, SCREEN_WIDTH);//这里是旋转后的，3，为宽，4为高。因为旋转后，参数互调。
        
        [self.VideoViewBack mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(0);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
        }];
        /*//调试用
        self.VideoViewBack.backgroundColor = [UIColor lightGrayColor];
        self.view.backgroundColor = [UIColor blueColor];
         */
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.VideoViewBack.mas_top).offset(0);
            make.left.equalTo(self.VideoViewBack.mas_left).offset(0);
            make.bottom.equalTo(self.VideoViewBack.mas_bottom).offset(-44);
            make.right.equalTo(self.VideoViewBack.mas_right).offset(0);
        }];

        if (self.collectionView.currentState == MoveCellStateOneScreen) {//_screenNum == 1
            //[self.collectionView.collectionViewLayout invalidateLayout];
            /*
            NSLog(@"横屏的全屏=_selectIndexPath：%@",_selectIndexPath);
            _oldRect = self.clickCell.frame;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.clickCell mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.top.mas_equalTo(self.view);
                    make.bottom.mas_equalTo(self.view).offset(-44);
                }];
                [self.view bringSubviewToFront:self.clickCell];
            });
             */
             
            //_collectionView.backgroundColor = [UIColor clearColor];
            //_collectionView.cellSize = CGSizeMake(150,150);//iPhoneHeight,iPhoneWidth-44
            
            
//            _collectionView.scrollEnabled = NO;
//
            /*
            NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
            
            [_collectionView scrollToItemAtIndexPath:tempIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            NSLog(@"横屏的全屏=_selectIndexPath：%@===tempIndexPath:%@",_selectIndexPath,tempIndexPath);
            */
            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self.clickCell mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.left.right.top.mas_equalTo(self.view);
//                    make.bottom.mas_equalTo(self.view).offset(-44);
//                }];
//                [self.view bringSubviewToFront:self.clickCell];
//            });
            
            self.collectionView.currentState = MoveCellStateOneScreen_HengPing;
            self.collectionView.lastState = MoveCellStateOneScreen;
            //[self.collectionView reloadData];//需要

            [UIView animateWithDuration:0.03 animations:^{
                [self.collectionView reloadData];
            } completion:^(BOOL finished) {
                [self.collectionView scrollToItemAtIndexPath:self.selectIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            }];
            //需要
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
//                
//                [self.collectionView scrollToItemAtIndexPath:self.selectIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//                NSLog(@"横屏的全屏=_selectIndexPath：%@===tempIndexPath:%@",_selectIndexPath,tempIndexPath);
//            });
            NSDictionary * dic = @{@"hasHengPing":@"YES"};
            [[NSNotificationCenter defaultCenter]postNotificationName:HASHENGPING object:nil userInfo:dic];
        }else if(self.collectionView.currentState == MoveCellStateFourScreen){
            self.collectionView.currentState = MoveCellStateFourScreen_HengPing;
            [self.collectionView reloadData];
        }

        [self.bottowScrollerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lab_jieTu.mas_top).offset(35);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
        }];
        if (self.isLive) {
            [self.bottowScrollerView setContentOffset:CGPointMake(0, 0)];
        }else{
            [self.bottowScrollerView setContentOffset:CGPointMake(iPhoneWidth, 0)];
        }
        self.pageControl.hidden = YES;
//        [self.view setNeedsLayout];
//        [self.view layoutIfNeeded];
       // }
    }];
}

#pragma mark  -------------- 竖屏
-(void)shupinAction_xiugai
{
    CGFloat bili = (CGFloat)(375.0000/244.000);
    
    CGFloat viewWidth;
    if (self.isFull == YES) {
        viewWidth  = (CGFloat)self.view.height;
    }else{
        viewWidth  = (CGFloat)self.view.width;
    }
    CGFloat h  = (CGFloat)viewWidth/bili;
    self.isFull = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [UIView animateWithDuration:0.25 animations:^{
        [self.VideoViewBack mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(64);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.height.equalTo(@(h));
        }];
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.VideoViewBack.mas_top).offset(0);
            make.left.equalTo(self.VideoViewBack.mas_left).offset(0);
            make.bottom.equalTo(self.VideoViewBack.mas_bottom).offset(-44);
            make.right.equalTo(self.VideoViewBack.mas_right).offset(0);

        }];
        if (self.collectionView.currentState == MoveCellStateOneScreen_HengPing) {
            /*
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.clickCell.frame = _oldRect;
                [self.view bringSubviewToFront:self.clickCell];
            });
             */
            /*
            _collectionView.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
            _collectionView.scrollEnabled = NO;
            [_collectionView setMinimumPressDuration:0.5];
            
            
            _collectionView.backgroundColor = [UIColor clearColor];
            _collectionView.cellSize = CGSizeMake(iPhoneWidth-1,_heigh_c);
            _collectionView.scrollEnabled = NO;
            _collectionView.moveDelegate = self;
            */
            //[_collectionView scrollToItemAtIndexPath:_selectIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
     
            /*
            self.collectionView.currentState = MoveCellStateOneScreen;
            
            if (iPhone_6_TO_8) {
               self.collectionView.cellSize  = CGSizeMake(iPhoneWidth-0.5,200);
            }
            if (iPhone_5_Series) {
                self.collectionView.cellSize = CGSizeMake(iPhoneWidth-0.5,164);
            }
            if (iPhone_6Plus_TO_8Plus) {
                self.collectionView.cellSize = CGSizeMake(iPhoneWidth,225);
            }
*/
            self.collectionView.currentState = MoveCellStateOneScreen;
            self.collectionView.lastState = MoveCellStateOneScreen_HengPing;
            //[self.collectionView reloadData];
            
            [UIView animateWithDuration:0.03 animations:^{
                [self.collectionView reloadData];

            } completion:^(BOOL finished) {
                [self.collectionView scrollToItemAtIndexPath:self.selectIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            }];
            
            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self.collectionView scrollToItemAtIndexPath:self.selectIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//            });

        }else if(self.collectionView.currentState == MoveCellStateFourScreen_HengPing){
            self.collectionView.currentState = MoveCellStateFourScreen;
//            if (iPhone_6_TO_8) {
//                self.collectionView.cellSize  =  CGSizeMake(iPhoneWidth/2-0.5,99.5);
//            }
//            if (iPhone_5_Series) {
//                self.collectionView.cellSize  = CGSizeMake(iPhoneWidth/2-0.5,81.5);
//            }
//            if (iPhone_6Plus_TO_8Plus) {
//                self.collectionView.cellSize  = CGSizeMake(iPhoneWidth/2-0.5,112.33);
//            }
            [self.collectionView reloadData];
        }

        [self.btn_cam mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.VideoViewBack.mas_bottom).offset(30);
        }];
        
        [self.bottowScrollerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lab_jieTu.mas_top).offset(35);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
        }];
        
        if (self.isLive) {
            [self.bottowScrollerView setContentOffset:CGPointMake(0, 0)];
        }else{
            [self.bottowScrollerView setContentOffset:CGPointMake(iPhoneWidth, 0)];
        }
        
        self.pageControl.hidden = NO;
        
//        [self.view setNeedsLayout];
//        [self.view layoutIfNeeded];
        float arch = 0;
        //对navigationController.view 进行强制旋转
        self.navigationController.view.transform = CGAffineTransformMakeRotation(arch);
        self.navigationController.view.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
    NSDictionary * dic = @{@"oldRect":[NSValue valueWithCGRect:self.normalCellRect]};
    [[NSNotificationCenter defaultCenter]postNotificationName:DIRECTHENGPING object:nil userInfo:dic];
}
#pragma mark  -------------- 截图按钮
//截图按钮
- (IBAction)btnCamerClick:(id)sender {
    
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        //    播放截图音效
        [self playSoundEffect:@"capture.caf"];
        UIImage *ima = [self snapshot:cell.playView];
        [XHToast showBottomWithText:@"已保存截图到我的文件"];
        WeakSelf(self);
        dispatch_async(dispatch_queue_create("photoScreenshot", NULL), ^{
            @synchronized (self) {
                [self createShortcutPicToFile:shortcutType_pic shortCutImage:ima];
                //[weakSelf.assetsLibrary saveImage:ima toAlbum:PATHSCREENSHOT completion:nil failure:nil];
                if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
                    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
                    UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    NSString *pathStr = [NSString stringWithFormat:@"/Documents/%@/image",userModel.mobile];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateStyle:NSDateFormatterMediumStyle];
                    [formatter setTimeStyle:NSDateFormatterShortStyle];
                    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                    NSDate *date = [NSDate date];
                    NSString *DateTimeStr = [formatter stringFromDate:date];
                    [weakSelf saveSmallImageWithImage:ima Url:@"" AtDirectory:pathStr ImaNameStr:DateTimeStr];
                }
            }
        });
    }else{
        [XHToast showCenterWithText:@"请先单击选中您想要截图的视频窗口" duration:1.0f];
    }
}
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
#pragma mark - 截图则在右下角出现的缩略图，可以点击进入相应的文件列表
- (void)createShortcutPicToFile:(shortcutType)type shortCutImage:(UIImage *)image
{
    UIView * bgView = [[UIView alloc]initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.VideoViewBack addSubview:bgView];
    CGFloat videoHeight = CGRectGetHeight(self.VideoViewBack.frame);
    CGFloat videoWidth = CGRectGetWidth(self.VideoViewBack.frame);
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.VideoViewBack).offset(10);
        make.bottom.mas_equalTo(self.VideoViewBack.mas_bottom).offset(-54);
        make.height.mas_equalTo(videoHeight/3);
        make.width.mas_equalTo(videoWidth/3);
    }];
    
    UIImageView * cutImage = [[UIImageView alloc]initWithImage:image];
    [bgView addSubview:cutImage];
    [cutImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(bgView).offset(6);
    }];
    
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:Type:)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    singleFingerOne.delegate = self;
    [bgView addGestureRecognizer:singleFingerOne];
    NSLog(@"截图展示的位置：%@",bgView);

    
    
    
}
//处理单指事件
- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)sender Type:(shortcutType)type
{
    NSLog(@"点击快速跳转到文件");
    
}

#pragma mark  -------------- 录制按钮
//录制按钮
- (IBAction)btnVideoClick:(id)sender {
    
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        UIButton *btn = (UIButton *)sender;
        BOOL isplay = [cell.videoManage JWPlayerManageGetPlayState];
        if (isplay == NO &&!self.isRecord) {
            [XHToast showBottomWithText:@"视频未播放"];
            return;
        }
        //播放录音音效
        [self playSoundEffect:@"record.caf"];
        if (!self.isRecord) {
            [XHToast showBottomWithText:@"视频开始录制"];
            btn.selected = YES;
            if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
                NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
                UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateStyle:NSDateFormatterMediumStyle];
                [formatter setTimeStyle:NSDateFormatterShortStyle];
                [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                NSDate *date = [NSDate date];
                NSString *DateTimeStr = [formatter stringFromDate:date];
                NSString *videoNameStr = [NSString stringWithFormat:@"文件格式:mp4    录像时间:%@    关联设备通道:%@",DateTimeStr,self.navigationItem.title];
                [cell.videoManage JWPlayerManageStartRecordWithPath:userModel.mobile fileName:videoNameStr];
            }
            self.isRecord = YES;
        }else{
            [XHToast showBottomWithText:@"视频录制成功，已保存到我的文件"];
            btn.selected = NO;
            [cell.videoManage JWPlayerManageStopRecord];
            self.isRecord = NO;
        }
    }else{
        [XHToast showCenterWithText:@"请先单击选中您想要截图的视频窗口" duration:1.0f];
    }
}
#pragma mark - - - 播放提示声
/*
void soundCompleteCalllback1(SystemSoundID soundID, void *clientData){
    NSLog(@"播放完成...");
}
 */
//todo
/** 播放音效文件 */
- (void)playSoundEffect:(NSString *)name{
    // 获取音效
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    
    // 1、获得系统声音ID
    SystemSoundID soundID = 0;
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    
    //    // 如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
    //    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    /*
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCalllback1, NULL);
     */
    //todo
    
    // 2、播放音频
    AudioServicesPlaySystemSound(soundID); // 播放音效
}
#pragma mark - 得到截图

- (UIImage *)snapshot:(UIView *)view

{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size,YES,0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}
#pragma mark ------推出时截取图片
- (void)backCutImage
{
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
    UIImage *ima = [self snapshot:cell.playView];
    
    dispatch_async(dispatch_queue_create("backCutImage", NULL), ^{
        @synchronized (CUTLOCK) {
            [self saveSmallImageWithImage:ima Url:@"" AtDirectory:saveCutImageBaseURLDirectory ImaNameStr:_listModel.ID];
            NSLog(@"【moitoringVC】保存截图的id：%@",_listModel.ID);
            NSDictionary * dic = @{@"updataImageID":_listModel.ID,@"selectedIndex":self.selectedIndex};
            NSLog(@"更新cutimage的dic：%@",dic);
            [[NSNotificationCenter defaultCenter]postNotificationName:UpDataCutImageWithID object:nil userInfo:dic];
        }
    });
}

#pragma mark ------------ collectionView的代理方法
- (void)cellSelectClick:(BOOL)isPlay
{
    if (isPlay) {
        NSLog(@"播放中,单击");
    }
    else{
        NSLog(@"没有播放,单机");
    }
}



#pragma mark ------判断屏幕状态
-(void)panduanDevece_nvr:(NSNotification *)noit{

}

#pragma mark ------请求是否有回放录像
- (void)getRecordVideo:(NSString *)timeStr
{

    self.isLive = NO;
    self.againPlay = NO;

    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
    //时间戳
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss "];
    //今日零点
    NSString *beginTimeStr =[NSString stringWithFormat:@"%@ %@",timeStr,@"00:00:00"];
    NSDate *date = [formatter dateFromString:beginTimeStr];
    NSLog(@"%@", date);// 这个时间是格林尼治时间
    NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    int beginTimeInt = [dateStr intValue];
     [self.videoTimeModelArr removeAllObjects];
    //今日235959
    NSString *endTimeStr =[NSString stringWithFormat:@"%@ %@",timeStr,@"23:59:59"];
    NSDate *endDate = [formatter dateFromString:endTimeStr];
    NSLog(@"%@", endDate);// 这个时间是格林尼治时间
    NSString *dateEndStr = [NSString stringWithFormat:@"%ld", (long)[endDate timeIntervalSince1970]];
    int endTimeInt = [dateEndStr intValue];
    
    //当前时间戳给进度条
    NSDate* nowDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a= [nowDate timeIntervalSince1970];
    NSString*nowTimeStr = [NSString stringWithFormat:@"%0.f", a];
    int nowTimeInt = [nowTimeStr intValue];
    //搜索是否有回放录像 但是不立刻播放
    [cell.videoManage searchRecordVideoWithDevidId:_listModel.ID recVideoType:JWRecVideoTypeStatusLeading beginTime:date completionBlock:^(NSArray *recVideoTimeArr, JWErrorCode errorCode) {
        if (errorCode == JW_SUCCESS) {
            //回放时间数组
            if (recVideoTimeArr.count>0) {
                for (int i = 0; i<recVideoTimeArr.count; i++) {
                    JWDeviceRecordFile *records = recVideoTimeArr[i];
                    ZCVideoTimeModel *model = [[ZCVideoTimeModel alloc]init];
                    //起点距离今日00分钟
                    CGFloat beginMin = (records.start_time-beginTimeInt)/60.00;
                    //终点距离今日00分钟
                    CGFloat endMin = (records.stop_time-beginTimeInt)/60.00;
                    model.name = records.name;
                    model.benginTime = beginMin;
                    model.endTime = endMin;
                    [self.videoTimeModelArr addObject:model];
                    
                }  //添加进度条
                [self.centerTimeView addSubview:self.rulerView];
                self.rulerView.timeArr = [NSArray arrayWithArray:self. videoTimeModelArr];
                
                //当前时间指针起始位置
                self.rulerView.timeMiao = nowTimeInt;
                self.rulerView.levelCount = 0;
            }
            else{
                [XHToast showTopWithText:@"当前日期暂无录像" topOffset:160];
                self.isCanCut = NO;
                //没有图像时 进度条隐藏
                [self disRulerViewAndTimeView];
            }
        }
        if (errorCode == JW_FAILD) {
            [XHToast showTopWithText:@"当前日期暂无录像" topOffset:160];
            self.isCanCut = NO;
            //没有图像时 进度条隐藏
            [self disRulerViewAndTimeView];
        }
    }];
}
#pragma mark ------进度条和时间View消失
- (void)disRulerViewAndTimeView
{
    //没有图像时 进度条隐藏
    [self.rulerView removeFromSuperview];
    self.rulerView = nil;
    [self.timeViewnew removeFromSuperview];
    self.timeViewnew = nil;
    
}
- (void)stopMainBtnStop
{
    //    [self btnStopClick:self.btn_stop];
    self.isLive = NO;
}
#pragma mark ------centerTimeViewDelegate
- (void)CenterTimeViewCenterBtnClick:(BOOL)isCenter TimeStr:(NSString *)timeStr
{
    //    [[HDNetworking sharedHDNetworking]canleAllHttp];
    
    [self disRulerViewAndTimeView];
    self.timeStr = timeStr;
    self.isCenter = isCenter;
    [self getRecordVideo:self.timeStr];
}


#pragma mark ------保存录像代理
- (void)stopRecordBlockFunc
{

}

#pragma mark ------进度条代理
- (void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView {
}
//输出时间
- (void)txhTimeStr:(NSString *)timeStr MinValue:(CGFloat)minValue
{
    NSString *str = [NSString stringWithFormat:@"%.2f",minValue];
    NSArray *arr = [str componentsSeparatedByString:@"."];
    NSString *min = arr[0];
    
    int secValue = [min intValue]*60;
    self.secStr = [NSString stringWithFormat:@"%d",secValue];
    
    //小时
    float hour = [min intValue]/60;
    int hourInt;
    hourInt = floor(hour);
    NSString *hourStr = [NSString stringWithFormat:@"%02d",hourInt];
    //分钟
    int minutes =floor(minValue);
    int minutesInt = minutes%60;
    NSString *minutesStr = [NSString stringWithFormat:@"%02d",minutesInt];
    
    //秒
    NSString *strArr = arr[1];
    int mouse = [strArr intValue]*0.6;
    NSString *mouseStr = [NSString stringWithFormat:@"%02d",mouse];
    NSString *strrrrrrr = [NSString stringWithFormat:@"%@:%@:%@",hourStr,minutesStr,mouseStr];
    self.timeViewnew.lab_time.text = strrrrrrr;
    self.timeMinStr = strrrrrrr;
}
//刷新播放时间
- (void)reloadTimePlay
{
    [[HDNetworking sharedHDNetworking]canleAllHttp];
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
    //如果正在录像就停止录制
    [self judgeIsRecord];
    //切换为不是实时视频
    self.isLive = NO;
    //停止回放视频
    [cell.videoManage JWStreamPlayerManageEndRecPlayVideoWithCompletionBlock:^(JWErrorCode errorCode) {
        if (errorCode == JW_SUCCESS) {
            //时间戳
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
            //调整时间
            NSString *beginTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,self.timeMinStr];
            NSDate *date = [formatter dateFromString:beginTimeStr];
            
            //今日235959
            NSString *endTimeStr =[NSString stringWithFormat:@"%@ %@",self.timeStr,@"23:59:59"];
            NSDate *endDate = [formatter dateFromString:endTimeStr];
            
            if (self.isCenter == NO) {
                [cell.videoManage JWPlayerManageBeginPlayRecVideoWithVideoType:JWRecVideoTypeStatusLeading startTime:date endTime:endDate BIsEncrypt:self.bIsEncrypt Key:self.key completionBlock:^(JWErrorCode errorCode) {
                    if (errorCode == JW_SUCCESS) {
                        [XHToast showTopWithText:@"获取录像成功，准备开始播放" topOffset:160];
                        self.btn_hd.selected = NO;
                        NSLog(@"回放成功了");
                    }if (errorCode == JW_FAILD) {
                        [XHToast showTopWithText:@"获取录像失败" topOffset:160];
                        self.isCanCut = NO;
                        NSLog(@"回放失败了");
                    }
                }];

            }
            if (self.isCenter == YES) {
                [cell.videoManage JWPlayerManageBeginPlayRecVideoWithVideoType:JWRecVideoTypeStatusCenter startTime:date endTime:endDate BIsEncrypt:self.bIsEncrypt Key:self.key completionBlock:^(JWErrorCode errorCode) {
                    if (errorCode == JW_SUCCESS) {
                        [XHToast showTopWithText:@"获取录像成功，准备开始播放" topOffset:160];
                        self.btn_hd.selected = NO;
                        NSLog(@"回放成功了");
                    }if (errorCode == JW_FAILD) {
                        [XHToast showTopWithText:@"获取录像失败" topOffset:160];
                        self.isCanCut = NO;
                        NSLog(@"回放失败了");
                    }
                }];

            }
            
        }
        if (errorCode == JW_FAILD) {
            [XHToast showTopWithText:@"获取录像失败" topOffset:160];
            self.isCanCut = NO;
            NSLog(@"回放失败了");
        }
    }];
}
#pragma mark  -------------- 滚动式图代理方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
    [[HDNetworking sharedHDNetworking]canleAllHttp];
    //更新UIPageControl的当前页
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.frame;
    [_pageControl setCurrentPage:offset.x / bounds.size.width];
    if (offset.x == 0 && !cell.isPlay) {
//        self.videoManage.isStop = NO;
        //注释:nvr的查询录像
        if (cell.chan_way >0) {
           [self getVideoAddress];
        }
    }
    else if (offset.x == iPhoneWidth&&cell.isPlay) {
        _screenNum = 1;
        [self getRecordVideo:self.timeStr];
    }
}
#pragma mark ------判断当前是否录制
- (void)judgeIsRecord
{
    if (self.isRecord) {
        [self btnVideoClick:self.btn_video];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden
{
    if (self.isFull) {
        return YES;
    }
    else
        return NO;
    // 返回NO表示要显示，返回YES将hiden
}
@end
