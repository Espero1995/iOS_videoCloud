//
//  MonitoringViewController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/4/13.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "MonitoringVCnew.h"

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
/*底部View*/
//#import "realtimeBottomView.h"
#import "MonitoringBottomView.h"
/*单屏幕view*/
#import "OnlyPlayBackVC.h"
/*返回按钮视图*/
#import "BackBtnView.h"
/*流量与网速显示*/
#import "SpeedAndflowView.h"
/*标题名字显示*/
#import "DeviceTitleView.h"
/*滚轮按钮显示*/
#import "ZMRocker.h"
/*工具条显示*/
#import "controlViewInFullScreen.h"
/*云存储界面*/
#import "MyCloudStorageVC.h"
/*能力集信息*/
#import "FeatureModel.h"


#import "FileVideoController.h"
#import "FileImageController.h"
#import "SegmentViewController.h"

static const CGFloat MinimumPressDuration = 0.3;
#define InitScreenNum_4 4
#define InitScreenNum_1 1
#define ONECELL @"OneTableViewCell"
typedef NS_ENUM(NSInteger, shortcutType)
{
    shortcutType_Video,
    shortcutType_pic
};
@interface MonitoringVCnew ()
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
MonitorBottomViewDelegate,
BackBtnViewDelegate,//返回按钮代理协议
controlViewInFullScreenDelegate,//工具栏的代理协议
ZMRockerDelegate,//滚轮按钮显示协议
UIGestureRecognizerDelegate
>
@property (weak, nonatomic) IBOutlet UIView *VideoViewBack;
@property (weak, nonatomic) IBOutlet UIButton *btn_stop;
@property (weak, nonatomic) IBOutlet UIButton *btn_sound;
@property (weak, nonatomic) IBOutlet UIButton *btn_screen;
@property (weak, nonatomic) IBOutlet UIButton *btn_hd;
/*三码流选择框*/
@property (strong, nonatomic) IBOutlet UIView *threeStreamView;
/*全屏时的三码流选择框*/
@property (nonatomic,strong) UIView *fullScreenthreeStreamView;
/*全屏的流畅按钮*/
@property (nonatomic,strong) UIButton *fd_fullBtn;
/*全屏的标清按钮*/
@property (nonatomic,strong) UIButton *sd_fullBtn;
/*全屏的高清按钮*/
@property (nonatomic,strong) UIButton *hd_fullBtn;
@property (weak, nonatomic) IBOutlet UIButton *btn_full;
@property (weak, nonatomic) IBOutlet UIButton *btn_cam;
@property (weak, nonatomic) IBOutlet UIButton *btn_video;
/*对讲按钮*/
@property (strong, nonatomic) IBOutlet UIButton *btn_talk;


@property (weak, nonatomic) IBOutlet UIView *btnBack;
@property (weak, nonatomic) IBOutlet MoveCollectionView *collectionView;
@property (nonatomic,strong) NSIndexPath *selectIndexPath;
@property (nonatomic,strong) NSArray * dataArr;
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) UIView * navView;
@property (nonatomic,strong) UILabel * titleLable;
@property (nonatomic,assign) int cellTag;
@property (nonatomic,assign) int i;
@property (nonatomic,assign) int control_num;
@property (nonatomic,assign) CGFloat heigh_c;
@property (nonatomic,assign) NSInteger cellCount;
/*列表消失的背景按钮*/
@property (nonatomic,strong)UIButton *disBtn;
/*频道列表选择*/
@property (nonatomic,strong)MoreChooseView *chooseTabView;
/*控制云台View*/
@property (nonatomic,strong)ControlView *controlView;
/*中心日期View*/
@property (nonatomic,strong)CenterTimeView *centerTimeView;
/*进度条*/
@property (nonatomic,strong)TXHRrettyRuler *rulerView;
/*当前暂无录像图片*/
@property (nonatomic,strong)UIImageView *noImageView;
/*进度条时间显示*/
@property (nonatomic,strong)TimeView *timeViewnew;
/*滑动View*/
@property (nonatomic,strong)UIScrollView *bottowScrollerView;
/*pagecontrol*/
@property (nonatomic,strong)UIPageControl *pageControl;
/*图片截图 保存录像*/
@property (nonatomic, strong)ALAssetsLibrary *assetsLibrary;
/*是否中心录像*/
@property (nonatomic,assign)BOOL isCenter;
/*播放速度*/
@property (nonatomic,assign)int speedInt;
/*是否播放*/
@property (nonatomic,assign)BOOL againPlay;
/*是否可以截屏*/
@property (nonatomic,assign)BOOL isCanCut;
/*是否全屏*/
@property (nonatomic,assign)BOOL isFull;
/*是否为直播*/
@property (nonatomic,assign)BOOL isLive;
/*是否hd*/
@property (nonatomic,assign)BOOL isHd;
/*是否正在录像*/
@property (nonatomic,assign)BOOL isRecord;
/*时间模型数组*/
@property (nonatomic,strong)NSMutableArray *videoTimeModelArr;
/*进度条定位的秒*/
@property (nonatomic,copy)NSString *secStr;
/*操作异步串行队列*/
@property (nonatomic,strong)dispatch_queue_t myActionQueue;
/*具体时间*/
@property (nonatomic,copy)NSString *timeMinStr;

@property (nonatomic,strong)NSMutableDictionary *tagDic;

@property (nonatomic,assign)CGRect oldRect;

@property (nonatomic,assign)NSIndexPath * clickAddBtnIndexPath;

@property (nonatomic,strong)MoveViewCell_c * clickCell;

@property (nonatomic, strong)UIView * deleteBgView;

@property (nonatomic, strong)UIImageView * deleteImageV;

@property (nonatomic, assign)CGRect  normalCellRect;
/*通道名称*/
@property (nonatomic, strong) NSMutableArray * chanName_arr;

@property (nonatomic,strong) NSMutableArray * aliasArr;
/*底部的View*/
@property (nonatomic,strong) MonitoringBottomView * bottomView;
/*返回按钮视图*/
@property (nonatomic,strong) BackBtnView *BackBtnView1;
/*流量与网速显示*/
@property (nonatomic,strong) SpeedAndflowView *SpeedAndflowView1;
/*标题名字显示*/
@property (nonatomic,strong) DeviceTitleView *DeviceTitleView1;
/*滚轮按钮显示*/
@property (nonatomic,strong) ZMRocker *ZMRocker1;
/*工具条显示*/
@property (nonatomic,strong) controlViewInFullScreen *controlFunctionView;
/*获取到录制的那个button*/
@property (nonatomic,strong) UIButton *recordBtn;
/*设备列表数组*/
@property (nonatomic,strong) NSMutableArray * deviceData;
@property (nonatomic,strong) dev_list * VideolistModel;

/*对讲的overView*/
@property (nonatomic,strong) UIView * ovreView;
@property (nonatomic,assign) CGFloat heigh_v;
@property (nonatomic,assign) int playBack_h;
/*当前选择的通道*/
@property (nonatomic,strong) NSIndexPath *currentSelectIndexPath;

@property  BOOL isAppear;//用来显示工具条是否显示
@property (nonatomic,assign)BOOL IsRockLock;

/*能力集信息的model*/
@property (nonatomic,strong)FeatureModel *feature;
@property (nonatomic,assign) JWVideoTypeStatus videoTypeStatus;//当前是什么清晰度

@property (nonatomic,strong)NSTimer * shortCutShowTimer;
@property (nonatomic,strong) UIView * bgView;
@property (nonatomic,strong) UIImageView * cutImage;
/** 标识视频快捷的背景 */
@property (nonatomic, strong) UIView* videoBgView;
/** video图片 */
@property (nonatomic, strong) UIImageView* videoLogo;
@property (nonatomic, assign) BOOL b_I_Frame_Start;/**< I帧已经开始播放 */
@property (nonatomic,strong)NSTimer *timer;

@end

@implementation MonitoringVCnew
{
    /*全局旋转变量*/
    UIDeviceOrientation _orientation;
    /*移动删除*/
    BOOL delete;
    /*判断是否开启声音*/
    BOOL isCloseSound;
    /*判断是否是开启高清*/
//    BOOL isCloseHd;
}

//=========================system=========================
#pragma mark - VC的生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;//设置屏幕常亮
    _chanName_arr = [NSMutableArray array];
    /*
    if ([[self.chan_alias allKeys] count] >0) {
        int num = (int)[[self.chan_alias allKeys] count];
        for (int i = 1; i<=num; i++) {
            NSString * key = [NSString stringWithFormat:@"%d",i];
            NSString * str = [self.chan_alias objectForKey:key];
            [_chanName_arr addObject:str];
        }
     */
        /*
        NSLog(@"-------%@-------",_chanName_arr);
        NSLog(@"%@",self.chan_alias);
         */
   // }
    
    for (int i = 0; i < self.chans.count; i++) {
        NSString * aliasStr = [self.chans[i] objectForKey:@"alias"];
        NSString * nameStr = [self.chans[i] objectForKey:@"name"];
        
        [_aliasArr addObject:aliasStr];
        [_chanName_arr addObject:nameStr];
    }
    NSLog(@"筛选出来的名字为：alias：%@===name:%@==chans:%@",_aliasArr,_chanName_arr,self.chans);
}

#pragma mark ------------ view将要显示消失
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //    [self btnStopClick:self.btn_stop];
    [[HDNetworking sharedHDNetworking]canleAllHttp];
    [self btnStopClick:self.btn_stop];
//     NSLog(@"viewWillDisappear:新写实时播放即将消失");
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

#pragma mark  --------------  UI
- (void)viewDidLoad {
    [super viewDidLoad];
    //TODO是否开启功能点
    [self initIsOpenFunction];
    //能力集合model初始化
    self.feature = [[FeatureModel alloc]init];
    //设置能力集合
    [self setDeviceFeature:self.listModel];
    
    self.b_I_Frame_Start = NO;
    [self setUpUI];
    [self createCollectionView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.isAppear = 0;
    self.IsRockLock = NO;

    [self addObserver];
    [self changeFourScreenToOneBigScreen];
    
    //为了使得选择三码流的view消失
    UITapGestureRecognizer *threeStreamTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(threeStreamViewTapped:)];
    threeStreamTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:threeStreamTap];
}

-(void)threeStreamViewTapped:(UITapGestureRecognizer*)tap
{
    self.threeStreamView.hidden = YES;
    self.fullScreenthreeStreamView.hidden = YES;
}

//=========================init=========================
#pragma mark ----- 创建全屏时的控件
- (void)createFullScreenControls{
    //TODO
    //工具条的显示
    [self.view addSubview:self.controlFunctionView];
    [self.controlFunctionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-16);
        make.right.equalTo(self.view.mas_right).offset(-30);
        make.size.mas_equalTo(CGSizeMake(0.7*iPhoneHeight, 0.7*iPhoneHeight/9));
    }];
    //返回按钮
    [self.view addSubview:self.BackBtnView1];
    [self.BackBtnView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.left.equalTo(self.view.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    //流量与网速显示
    [self.view addSubview:self.SpeedAndflowView1];
    self.SpeedAndflowView1.speedLabel.text = @"236K/S";
    self.SpeedAndflowView1.flowLabel.text = @"1.20MB";
    [self.SpeedAndflowView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    /*标题暂时不需要
    self.DeviceTitleView1.deviceTitleName_lb.text = [NSString stringWithFormat:@"%@监控",self.titleName?self.titleName:@"视频"];
    [self.view addSubview:self.DeviceTitleView1];
    [self.DeviceTitleView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(200, 15));
    }];
     */
    
    //滚轮按钮显示2.0
    [self.view addSubview:self.ZMRocker1];
    [self.ZMRocker1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).offset(-156);
        make.left.equalTo(self.view.mas_left).offset(25);
        make.size.mas_equalTo(CGSizeMake(117, 117));
    }];
}

#pragma mark ----- 退出全屏时移除控件
- (void)removeFullScreenControls{
    [self.controlFunctionView removeFromSuperview];//TODO
    [self.BackBtnView1 removeFromSuperview];
    [self.SpeedAndflowView1 removeFromSuperview];
    [self.DeviceTitleView1 removeFromSuperview];
    [self.ZMRocker1 removeFromSuperview];
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

//销毁通知
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stop_PlayMovie) name:HIDELOADVIEW object:nil];

}

- (void)setUpUI
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
//    self.title = @"视频监控";
    self.title = [NSString stringWithFormat:@"%@监控",self.titleName?self.titleName:@"视频"];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    //导航栏按钮
    [self cteateNavBtn];
    //初始化位全屏
    self.isFull = NO;
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
    
    [self.bottowScrollerView addSubview:self.controlView];
    [self.bottowScrollerView addSubview:self.centerTimeView];
    //添加无视频图像
    [self.centerTimeView addSubview:self.noImageView];
    [self.view addSubview:self.pageControl];
    
    //将垃圾桶（删除）加到视图中
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
    
    //底部视图（历史记录）
    [self.view addSubview:self.bottomView];
    
}
#pragma mark 【自动播放，变单屏】把四分屏变为单屏
- (void)changeFourScreenToOneBigScreen
{
    [self.collectionView layoutIfNeeded];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    MoveViewCell_c *cellView =(MoveViewCell_c *)[self.collectionView cellForItemAtIndexPath:indexPath];
    _oldRect = cellView.frame;
    
    NSData *oldRect_fourScreen = [NSKeyedArchiver archivedDataWithRootObject:[NSValue valueWithCGRect:cellView.frame]];
    [[NSUserDefaults standardUserDefaults] setObject:oldRect_fourScreen forKey:OLDRECT_FOURSCREEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.collectionView.currentState = MoveCellStateOneScreen;
    //这边原本应该获取到self.collectionView.frame的frame但是不知道为什么是获取的错误的值，则，先用固定值，写好，后面再改。
    //[cellView setFrame:CGRectMake(0 ,0, 414 , 225.333)];
    
    if (iPhone_6Plus_TO_8Plus)
    {
        [cellView setFrame:CGRectMake(0 ,0, 414 , 225.333)];
    }
    else if(iPhone_6_TO_8)
    {
        [cellView setFrame:CGRectMake(0 ,0, 375, 200)];
    }else if (iPhone_5_Series)
    {
        [cellView setFrame:CGRectMake(0 ,0, 320, 164)];
    }
    [self.collectionView bringSubviewToFront:cellView];
    
    NSDictionary * dic = @{@"isBig":@"YES",@"selectIndexPath":indexPath};
    [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
    
    NSDictionary * dic2 = @{@"hasHengPing":@"NO"};
    [[NSNotificationCenter defaultCenter]postNotificationName:HASHENGPING object:nil userInfo:dic2];
    
    NSDictionary * dic3 = @{@"ScrollViewScroEnable":@"YES"};
    [[NSNotificationCenter defaultCenter]postNotificationName:SCROLLVIEWSCROENABLE object:nil userInfo:dic3];
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
{
    
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
        return CGSizeMake(iPhoneHeight/2-0.5,iPhoneWidth/2);//-22去掉
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
        return CGSizeMake(iPhoneHeight,iPhoneWidth);//-44去掉，没有下面的工具条了
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

//    if (indexPath == self.selectIndexPath) {
//        return;
//    }else{
        self.btn_sound.selected = NO;
        self.btn_hd.selected = NO;

        for (int i = 0; i<4; i++) {
            NSIndexPath * index = [NSIndexPath indexPathForItem:i inSection:0];
            MoveViewCell_c * cell0 = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:index];
            if (cell0.isPlay == YES) {
                [cell0.videoManage JWPlayerManageSetAudioIsOpen:NO];

            }
        }
    
    if (self.isFull) {
        //修改工具栏布局
        [self setDeviceFeature:cell.listModel];
        [self.controlFunctionView changeLayoutOfFeature:self.feature.isTalk andCloudDeck:self.feature.isCloudDeck];
    }
    
   
    
//    }
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
    //++++++++++++++++++++
    if (cell.listModel.name) {
        self.title = [NSString stringWithFormat:@"%@监控",cell.listModel.name];
        self.DeviceTitleView1.deviceTitleName_lb.text = [NSString stringWithFormat:@"%@监控",cell.listModel.name];
    }else{
        self.title = [NSString stringWithFormat:@"视频监控"];
        self.DeviceTitleView1.deviceTitleName_lb.text = [NSString stringWithFormat:@"视频监控"];
    }
    NSLog(@"视频监控的名称是：%@===cell.listModel.name：%@",cell.listModel.name,cell.listModel);
    //++++++++++++++++++++
    if (cell.videoTypeStatus == JWVideoTypeStatusNomal) {
        [self.btn_hd setTitle:@"标清" forState:UIControlStateNormal];
        [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_sd", nil)] forState:UIControlStateNormal];
        self.videoTypeStatus = JWVideoTypeStatusNomal;
    }else if (cell.videoTypeStatus == JWVideoTypeStatusHd){
        [self.btn_hd setTitle:@"高清" forState:UIControlStateNormal];
        [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_hd", nil)] forState:UIControlStateNormal];
        self.videoTypeStatus = JWVideoTypeStatusHd;
    }else if (cell.videoTypeStatus == JWVideoTypeStatusFluency){
        [self.btn_hd setTitle:@"流畅" forState:UIControlStateNormal];
        [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_fd", nil)] forState:UIControlStateNormal];
        self.videoTypeStatus = JWVideoTypeStatusFluency;
    }
    
    
    self.selectIndexPath = indexPath;
    self.collectionView.selectIndexPath = indexPath;
    

    [self selectZhuangtai];

    
    NSLog(@"点击section%ld的第%ld个cell===self.selectIndexPath：%@===self.collectionView.selectIndexPath:%@===cell.cellTag:%d===cell.tag:%ld",(long)indexPath.section,indexPath.row,self.selectIndexPath,self.collectionView.selectIndexPath,cell.cellTag,(long)cell.tag);
}


#pragma mark ------工具条隐藏消失
- (void)videoViewBackanimation
{
    //    NSLog(@"出现了");
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.controlFunctionView.alpha = 1;
        self.BackBtnView1.alpha = 1;
        self.SpeedAndflowView1.alpha = 1;
        self.DeviceTitleView1.alpha = 1;
        
    } completion:^(BOOL finished) {
        if (finished) {
            [self performSelector:@selector(videoViewBackHidden) withObject:nil afterDelay:5];
            _isAppear = 0;
        }
    }];
}
- (void)videoViewBackHidden
{
    [UIView animateWithDuration:0.3 animations:^{
        self.controlFunctionView.alpha = 0;
        self.BackBtnView1.alpha = 0;
        self.SpeedAndflowView1.alpha = 0;
        self.DeviceTitleView1.alpha = 0;
        self.fullScreenthreeStreamView.hidden = YES;
        if (self.IsRockLock) {
            self.ZMRocker1.hidden = NO;
        }else{
            self.ZMRocker1.hidden = YES;
        }
        
        _isAppear = 1;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        //        NSLog(@"消失啦！");
    }];
}

#pragma mark ==================== 各类手势监听
#pragma mark ----- 单击手势
- (void)selectZhuangtai{
    if (_isAppear) {
        [self videoViewBackanimation];
        _isAppear = 0;
        
    }else{
        [self videoViewBackHidden];
        _isAppear = 1;
    }
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
    if (self.videoTypeStatus == JWVideoTypeStatusHd) {
       // self.clickCell.HD = YES;//需要同步修改
        //播放主码流//
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
    else {
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
    
    //视图和model绑定（为了显示名字）
    cell.listModel = self.listModel;
    
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

    if (self.videoTypeStatus == JWVideoTypeStatusHd) {
       // cell.HD = YES; //需要同步修改
        cell.videoTypeStatus = JWVideoTypeStatusHd;
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
    else if(self.videoTypeStatus == JWVideoTypeStatusNomal){
      //  cell.HD = NO; //需要同步修改
        cell.videoTypeStatus = JWVideoTypeStatusNomal;
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
    else if (self.videoTypeStatus == JWVideoTypeStatusFluency)//流畅
    {
        cell.videoTypeStatus = JWVideoTypeStatusFluency;
        //播放子码流//self.bIsEncrypt/self.key(cell.listModel.enable_sec/cell.listModel.dev_p_code)
        [cell.videoManage JWPlayerManageBeginPlayVideoWithVideoType:JWVideoTypeStatusFluency BIsEncrypt:cell.listModel.enable_sec Key:self.listModel.dev_p_code BIsAP:NO completionBlock:^(JWErrorCode errorCode) {
            errorCode = JW_SUCCESS;
            if (errorCode == JW_SUCCESS) {
                //播放成功可以截图
                self.isCanCut = YES;
                //[XHToast showTopWithText:@"获取流畅视频成功1" topOffset:160];
                // cell.loadView.hidden = YES;
                NSLog(@"播放流畅成功");
            }if (errorCode == JW_FAILD) {
                //[XHToast showTopWithText:@"获取流畅视频失败" topOffset:160];
                self.isCanCut = NO;
                //cell.loadView.hidden = YES;
                [[NSNotificationCenter defaultCenter]postNotificationName:PLAYFAIL object:nil];
                NSLog(@"播放流畅失败");
            }
        }];
    }
    
    //重新取流时声音开关的判断
    if (isCloseSound == NO) {
        [cell.videoManage JWPlayerManageSetAudioIsOpen:YES];
    }else{
        [cell.videoManage JWPlayerManageSetAudioIsOpen:NO];
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
            if (self.isFull) {//修改过
                self.navigationController.navigationBarHidden = YES;
            }else{
                self.navigationController.navigationBarHidden = NO;
            }
            self.deleteImageV.hidden = NO;
            self.deleteBgView.hidden = NO;
            delete = YES;
            self.deleteBgView.backgroundColor = [UIColor redColor];
            self.deleteImageV.image = [UIImage imageNamed:@"delete_open"];
        }else if([[noti.userInfo objectForKey:@"message"]isEqualToString:@"undelete"])
        {
            if (self.isFull) {//修改过
                self.navigationController.navigationBarHidden = YES;
            }else{
                self.navigationController.navigationBarHidden = NO;
            }
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
    [self.navigationController setNavigationBarHidden:YES animated:NO];//修改过的删除
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
    [self.controlFunctionView.suspendBtn setBackgroundImage:[UIImage imageNamed:@"realTimePause_n"] forState:UIControlStateNormal];
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
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.navView];
    if (self.isFull == YES) {
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset((iPhoneHeight-iPhoneWidth)/2);
            make.top.equalTo(self.view.mas_top).offset(44);
            make.right.equalTo(self.view.mas_right).offset(-(iPhoneHeight-iPhoneWidth)/2);
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
        }];
  
    }else{
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(50);
            make.top.equalTo(self.view.mas_top).offset(iPhoneHeight/2-90+44);//TODO
            make.right.equalTo(self.view.mas_right).offset(-50);
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
        }];
    }
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.tableView);
        make.bottom.mas_equalTo(self.tableView.mas_top);
        make.height.mas_equalTo(@44);
    }];
    
    [self createTableView];
}
- (void)disBtnClick
{
    [self.tableView removeFromSuperview];
    self.tableView = nil;
    [self.navView removeFromSuperview];
    self.navView = nil;
    [self.disBtn removeFromSuperview];
    self.disBtn = nil;
}
#pragma mark ------创建tableview并设置代理
// 创建tableView
-(void)createTableView{

    
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
    return self.chans.count;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * str = @"MyCell";
    PassageWay_t * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        
        cell = [[PassageWay_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    /*//之前用单独的通道别名，现在用能力集里面的通道信息
    if (indexPath.row<_chanName_arr.count) {
        cell.titleLbel.text = [NSString stringWithFormat:@"%@",_chanName_arr[indexPath.row]];
    }else{
        cell.titleLbel.text = [NSString stringWithFormat:@"通道00%ld",(long)indexPath.row+1];
    }
     */

    if (self.aliasArr.count > 0 && ![unitl isNull:self.aliasArr[indexPath.row]]) {
        cell.titleLbel.text = [NSString stringWithFormat:@"%@",self.aliasArr[indexPath.row]];
    }else{
        if (self.chanName_arr.count > 0 && ![unitl isNull:self.chanName_arr[indexPath.row]]) {
            cell.titleLbel.text = [NSString stringWithFormat:@"%@",self.chanName_arr[indexPath.row]];
        }else{
            cell.titleLbel.text = [NSString stringWithFormat:@"通道00%ld",(long)indexPath.row+1];
        }
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
            self.videoTypeStatus = JWVideoTypeStatusNomal;
            [SXLReachability SXL_hasNetwork:^(ReachabilityStatus netStatus) {
                if (netStatus == ReachabilityStatusReachableViaWWAN) {
                   // [self netWorkAlert];
                    [Toast showInfo:netWorkReminder];
                      [self getVideoAddress];
                }else{
                   [self getVideoAddress];
                }
            }];
        }
}
#pragma 使用流量播放提醒
- (void)netWorkAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提醒"message:@"您确定使用移动流量观看视频？"preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self getVideoAddress];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark ------------ 按钮状态初始化
- (void)setUpBtn//nvr 日历时间
{
    [self.btn_screen setImage:[UIImage imageNamed:@"one_h"] forState:UIControlStateHighlighted];
    [self.btn_screen setImage:[UIImage imageNamed:@"one_n"] forState:UIControlStateSelected];
    
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
        return;
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
//        UIButton *btn = (UIButton *)sender;
//        btn.selected = !btn.selected;
        //TODO判断声音按钮的状态
        [self judgeIsCloseSound];
        
        if (cell.isPlay == YES) {
            if (isCloseSound == NO) {//btn.selected
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

#pragma mark  -------------- 高清按钮的响应事件【小屏状态】
/*
//高清按钮
- (IBAction)btnHdClick:(id)sender {
    if (_selectIndexPath == nil) {
        return;
    }else{
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        
        [self judgeIsCloseHd];
        
//        UIButton *btn = (UIButton *)sender;
//        btn.selected = !btn.selected;

        NSLog(@"切换清晰度");
        
        if (cell.isPlay) {
            if (isCloseHd == NO) {
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
*/

//三码流切换按钮
- (IBAction)btnHdClick:(id)sender {
    if (_selectIndexPath == nil) {
        [XHToast showTopWithText:@"请选择您想要的通道列表" topOffset:160];
        return;
    }else{
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        if (cell.isPlay) {
            self.threeStreamView.hidden = NO;
        }else{
            [XHToast showTopWithText:@"视频未播放" topOffset:160];
        }
    }
}
//流畅
- (IBAction)fluentDClick:(id)sender {
//    [XHToast showTopWithText:@"暂时不支持流畅播放" topOffset:160];
    if (self.videoTypeStatus == JWVideoTypeStatusFluency) {
        return;
    }
    self.videoTypeStatus = JWVideoTypeStatusFluency;
    [self.btn_hd setTitle:@"流畅" forState:UIControlStateNormal];
    [XHToast showTopWithText:@"流畅" topOffset:160];
    [self judgeIsRecord];//如果正在录像就停止录制
    [self getVideoAddress];
}
//标清
- (IBAction)sdClick:(id)sender {
//    if (isCloseHd == YES) {
//        [XHToast showTopWithText:@"当前已为标清" topOffset:160];
//    }else{
//        isCloseHd = YES;
//        [self.btn_hd setTitle:@"标清" forState:UIControlStateNormal];
//        [XHToast showTopWithText:@"标清" topOffset:160];
//        [self judgeIsRecord];//如果正在录像就停止录制
//        [self getVideoAddress];
//    }
    if (self.videoTypeStatus == JWVideoTypeStatusNomal) {
        return;
    }
    self.videoTypeStatus = JWVideoTypeStatusNomal;
    [self.btn_hd setTitle:@"标清" forState:UIControlStateNormal];
    [XHToast showTopWithText:@"标清" topOffset:160];
    [self judgeIsRecord];//如果正在录像就停止录制
    [self getVideoAddress];
}

//高清
- (IBAction)hdClick:(id)sender {
//    if (isCloseHd == NO) {
//        [XHToast showTopWithText:@"当前已为高清" topOffset:160];
//    }else{
//        isCloseHd = NO;
//        [self.btn_hd setTitle:@"高清" forState:UIControlStateNormal];
//        [XHToast showTopWithText:@"高清" topOffset:160];
//        [self judgeIsRecord];//如果正在录像就停止录制
//        [self getVideoAddress];
//    }
    if (self.videoTypeStatus == JWVideoTypeStatusHd) {
        return;
    }
    self.videoTypeStatus = JWVideoTypeStatusHd;
    [self.btn_hd setTitle:@"高清" forState:UIControlStateNormal];
    [XHToast showTopWithText:@"高清" topOffset:160];
    [self judgeIsRecord];//如果正在录像就停止录制
    [self getVideoAddress];
}


#pragma mark  -------------- 全屏按钮的响应事件
//全屏按钮
- (IBAction)btnFullClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (self.isFull == NO) {
        [self.btn_full setImage:[UIImage imageNamed:@"small_n"] forState:UIControlStateNormal];
        
        
        self.btnBack.hidden = YES;
        
        [self rightHengpinAction_xiugai];

    }else{
        
        //移除全屏时屏幕上的控件
        [self removeFullScreenControls];
        self.btnBack.hidden = NO;
        
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
        

        
        //        CGFloat layoutFloat = 375/244;
        //        [self.VideoViewBackLayout setConstant:layoutFloat];
        
        
        
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
            make.bottom.equalTo(self.VideoViewBack.mas_bottom).offset(0);
            make.right.equalTo(self.VideoViewBack.mas_right).offset(0);
        }];

        [self createFullScreenControls];
        //声音
        if (isCloseSound) {
            [self.controlFunctionView.voiceBtn setBackgroundImage:[UIImage imageNamed:@"realTimejingyin_n"] forState:UIControlStateNormal];
        }else{
            [self.controlFunctionView.voiceBtn setBackgroundImage:[UIImage imageNamed:@"realTimeShengyin_n"] forState:UIControlStateNormal];
        }
        //高清
//        if (isCloseHd) {
//            [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_sd", nil)] forState:UIControlStateNormal];
//        }else{
//            [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_hd", nil)] forState:UIControlStateNormal];
//        }
        
        
        if(self.videoTypeStatus == JWVideoTypeStatusHd){
            [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_hd", nil)] forState:UIControlStateNormal];
        }else if (self.videoTypeStatus == JWVideoTypeStatusNomal){
            [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_sd", nil)] forState:UIControlStateNormal];
        }else if (self.videoTypeStatus == JWVideoTypeStatusFluency){
            [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_fd", nil)] forState:UIControlStateNormal];
        }
        
        
        //判断是否关闭视频播放
        if (cell.isPlay == YES) {
            [self.controlFunctionView.suspendBtn setBackgroundImage:[UIImage imageNamed:@"realTimePause_n"] forState:UIControlStateNormal];
        }else{
            [self.controlFunctionView.suspendBtn setBackgroundImage:[UIImage imageNamed:@"realTimeplay_n"] forState:UIControlStateNormal];
        }
        //判断是否在录制
        if (self.isRecord == YES) {
            [self.controlFunctionView.videoBtn setBackgroundImage:[UIImage imageNamed:@"zirealTimeVideo_close"] forState:UIControlStateNormal];
        }else{
            [self.controlFunctionView.videoBtn setBackgroundImage:[UIImage imageNamed:@"zirealTimeVideo_n"] forState:UIControlStateNormal];
        }
        
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
//            if (iPhone6) {
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
        
        BOOL isplay = [cell.videoManage JWPlayerManageGetPlayState];
        if (isplay == YES) {
            //播放截图音效
            [self playSoundEffect:@"capture.caf"];
            UIImage *ima = [self snapshot:cell.playView];
            [XHToast showBottomWithText:@"已保存截图到我的文件"];
            [self createShortcutPicToFilebIsVideo:NO shortCutImage:ima bIsFullScreen:NO];
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
                        NSString *imgNameStr = [NSString stringWithFormat:@"文件格式:jpeg    截图时间:%@    关联设备通道:%@",DateTimeStr,self.navigationItem.title];
                        [weakSelf saveSmallImageWithImage:ima Url:@"" AtDirectory:pathStr ImaNameStr:imgNameStr];
                    }
                }
            });
        }else{
            [XHToast showBottomWithText:@"视频未播放"];
        }
        
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
            [self.btn_video setBackgroundImage:[UIImage imageNamed:@"shootVideo_redable"] forState:UIControlStateNormal];
        }else{
            [XHToast showBottomWithText:@"视频录制成功，已保存到我的文件"];
            btn.selected = NO;
            [cell.videoManage JWPlayerManageStopRecord];
            self.isRecord = NO;
            UIImage *ima = [self snapshot:cell.playView];
            [self createShortcutPicToFilebIsVideo:YES shortCutImage:ima bIsFullScreen:NO];
            [self.btn_video setBackgroundImage:[UIImage imageNamed:@"shootVideo_able"] forState:UIControlStateNormal];
        }
    }else{
        [XHToast showCenterWithText:@"请先单击选中您想要截图的视频窗口" duration:1.0f];
    }
}

#pragma mark  -------------- 对讲按钮
- (IBAction)btnTalkClick:(id)sender {

    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        BOOL isplay = [cell.videoManage JWPlayerManageGetPlayState];
        if (isplay == NO) {
            [XHToast showBottomWithText:@"视频未播放"];
            return;
        }else{
            [XHToast showBottomWithText:NSLocalizedString(@"该设备不支持对讲功能", nil)];
        }
    }else{
        [XHToast showCenterWithText:@"请先单击选中您想要对讲的视频窗口" duration:1.0f];
    }
    

    
    /*
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        BOOL isplay = [cell.videoManage JWPlayerManageGetPlayState];
        if (isplay == NO) {
            [XHToast showBottomWithText:@"视频未播放"];
            return;
        }else{
            [cell.videoManage JWPlayerManageStartAudioTalkWithCompletionBlock:^(JWErrorCode errorCode) {
                if (errorCode == 0) {
                    [XHToast showTopWithText:@"麦克风:开" topOffset:160];
                    [self createOvreUI];
                    self.currentSelectIndexPath = _selectIndexPath;
                }else{
                    [XHToast showBottomWithText:[NSString stringWithFormat:@"开启对讲失败，错误码：%ld",(long)errorCode]];
                }
            }];
        }
    }else{
        [XHToast showCenterWithText:@"请先单击选中您想要对讲的视频窗口" duration:1.0f];
    }
     */
}

#pragma mark - 竖屏SD录像回放点击事件
- (IBAction)sdBtnVerticalClick:(id)sender
{
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.selectIndexPath];
        
        if (cell.listModel) {
            if ([[unitl get_User_id] isEqualToString:cell.listModel.owner_id]) {//自己设备
                [self setDeviceFeature:cell.listModel];
                if ([cell.listModel.enableSD isEqualToString:@"1"]) {
                    //[XHToast showCenterWithText:@"SD录像回放"];
                    OnlyPlayBackVC * playVC = [[OnlyPlayBackVC alloc]init];
                    playVC.titleName = cell.listModel.name;
                    playVC.listModel = cell.listModel;
                    playVC.bIsEncrypt = cell.listModel.enable_sec;
                    playVC.key = cell.listModel.dev_p_code;
                    playVC.isDeviceVideo = YES;
//                    playVC.bIsAP = self.bIsAP;
                    [self.navigationController pushViewController:playVC animated:YES];
                }else{
                    [XHToast showCenterWithText:NSLocalizedString(@"未检测到设备上的SD卡", nil)];
                }
            }else{//好友分享
                shareFeature *shareFeature = cell.listModel.ext_info.shareFeature;
                
                if ([shareFeature.hp intValue]== 1) {
                    if (cell.listModel.enableOperator == 1) {
                        if ([cell.listModel.enableSD isEqualToString:@"1"]) {
                            OnlyPlayBackVC * playVC = [[OnlyPlayBackVC alloc]init];
                            playVC.titleName = cell.listModel.name;
                            playVC.listModel = cell.listModel;
                            playVC.bIsEncrypt = cell.listModel.enable_sec;
                            playVC.key = cell.listModel.dev_p_code;
                            playVC.isDeviceVideo = YES;
//                            playVC.bIsAP = self.bIsAP;
                            [self.navigationController pushViewController:playVC animated:YES];
                        }else{
                            [XHToast showCenterWithText:NSLocalizedString(@"未检测到设备上的SD卡", nil)];
                        }
                    }else{
                        [XHToast showCenterWithText:NSLocalizedString(@"非分享时间段内无法查看设备录像", nil)];
                    }
                }else{
                    [XHToast showCenterWithText:NSLocalizedString(@"您的好友未将设备录像权限分享给您", nil)];
                }
            }
        }else{
            [XHToast showTopWithText:NSLocalizedString(@"请选择您想要的通道列表(设备)", nil) topOffset:160];
        }
        
    }else{
        [XHToast showTopWithText:NSLocalizedString(@"请先选择您想观看的相机(设备)", nil) topOffset:160];
    }
}





#pragma mark - 判断竖屏下按钮的显示状态
- (IBAction)cloudBtnVerticalClick:(id)sender
{
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        BOOL isplay = [cell.videoManage JWPlayerManageGetPlayState];
        if (isplay == NO) {
            [XHToast showBottomWithText:NSLocalizedString(@"视频未播放", nil)];
            return;
        }else{
            [XHToast showBottomWithText:NSLocalizedString(@"该设备不支持云存功能", nil)];
        }
    }else{
        [XHToast showCenterWithText:@"请先单击选中您想要对讲的视频窗口" duration:1.0f];
    }
}


- (void)createOvreUI{
    
    _ovreView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-_playBack_h-64)];
    _ovreView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_ovreView];
    [_ovreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.VideoViewBack.mas_bottom).offset(0);
        make.left.equalTo(self.VideoViewBack.mas_left).offset(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.right.equalTo(self.VideoViewBack.mas_right).offset(0);
    }];
    
    //创建UIImageView，添加到界面
    if (iPhone_5_Series) {
        _heigh_v = 100;
    }else{
        _heigh_v = 150;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(iPhoneWidth/2-115, _heigh_v, 230, 40)];
    [self.ovreView addSubview:imageView];
    //创建一个数组，数组中按顺序添加要播放的图片（图片为静态的图片）
    NSMutableArray *imgArray = [NSMutableArray array];
    for (int i=1; i<3; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"duijiang%d.png",i]];
        [imgArray addObject:image];
    }
    //把存有UIImage的数组赋给动画图片数组
    imageView.animationImages = imgArray;
    //设置执行一次完整动画的时长
    imageView.animationDuration = 6*0.15;
    //动画重复次数 （0为重复播放）
    imageView.animationRepeatCount = 0;
    //开始播放动画
    [imageView startAnimating];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(iPhoneWidth/2-50, 150, 54, 21)];
    label.text = @"对讲中";
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    [self.ovreView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.ovreView.mas_left).offset(iPhoneWidth/2-27);
        make.bottom.equalTo(imageView.mas_bottom).offset(0);
    }];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 65, 65);
    button.backgroundColor = [UIColor redColor];
    button.layer.cornerRadius = 32.5;
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setBackgroundImage:[UIImage imageNamed:@"redyuan"] forState:UIControlStateNormal];
    [button setTitle:@"挂断" forState:UIControlStateNormal];
    [self.ovreView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.ovreView.mas_left).offset(iPhoneWidth/2-32.5);
        make.top.equalTo(label.mas_bottom).offset(65);
        make.right.equalTo(self.ovreView.mas_left).offset(iPhoneWidth/2+32.5);
    }];
    [button addTarget:self action:@selector(stopTalkWith) forControlEvents:UIControlEventTouchUpInside];
}

- (void)stopTalkWith{
    //self.currentSelectIndexPath = _selectIndexPath;
    if (self.currentSelectIndexPath == _selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        [cell.videoManage JWPlayerManageEndAudioTalkWithCompletionBlock:^(JWErrorCode errorCode) {
            [XHToast showTopWithText:@"麦克风:关" topOffset:160];
            [self.ovreView removeFromSuperview];
        }];
    }else{
        [XHToast showTopWithText:@"请选择您之前所选择的通道" topOffset:160];
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
        if (self.selectedIndex && self.b_I_Frame_Start) {
            [self saveSmallImageWithImage:ima Url:@"" AtDirectory:saveCutImageBaseURLDirectory ImaNameStr:_listModel.ID];
            NSLog(@"【moitoringVC】保存截图的id：%@",_listModel.ID);
            NSDictionary * dic = @{@"updataImageID":_listModel.ID,@"selectedIndex":self.selectedIndex};
            NSLog(@"更新cutimage的dic：%@",dic);
            [[NSNotificationCenter defaultCenter]postNotificationName:UpDataCutImageWithID object:nil userInfo:dic];
           }
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
- (void)judgeIsRecord1
{
    if (self.isRecord) {
        [self videoBtnClick:self.recordBtn];
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


//=========================delegate=========================
/*
#pragma mark ----- 点击云存储方法
- (void)saveBtnClick
{
    NSLog(@"代理点击saveBtnClick");
    MySingleton *singleton = [MySingleton shareInstance];
    //    NSLog(@"用户名字：%@",singleton.userNameStr);
    //    NSLog(@"model传进来的名字：%@",self.listModel.owner_name);
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.collectionView.selectIndexPath];
        if ([singleton.userNameStr isEqualToString:self.listModel.owner_name]) {
            if (cell.listModel) {
                [self setDeviceFeature:cell.listModel];
                if (self.feature.isCloudStorage) {
                    MyCloudStorageVC *myCloudVC = [[MyCloudStorageVC alloc]init];
                    myCloudVC.deviceId = cell.listModel.ID;
                    if(![NSString isNull:cell.listModel.name]){
                        myCloudVC.deviceName = cell.listModel.name;
                    }else{
                        myCloudVC.deviceName = cell.listModel.type;
                    }
                    [self.navigationController pushViewController:myCloudVC animated:YES];
                }else{
                    [XHToast showTopWithText:@"该设备不支持云存功能" topOffset:160];
                }
                
            }else{
                [XHToast showTopWithText:@"请选择您想要的通道列表(设备)" topOffset:160];
            }
        }else{
            [XHToast showTopWithText:@"该设备为分享设备无法购买云存" topOffset:160];
        }
        
    }else{
        [XHToast showTopWithText:@"请先选择您想观看的相机(设备)" topOffset:160];
    }
}
 */
#pragma mark ----- 点击历史回放的方法
- (void)historyBtnClick
{
    if (self.selectIndexPath) {

        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.collectionView.selectIndexPath];
        if (cell.listModel) {
            OnlyPlayBackVC * playbackVC = [[OnlyPlayBackVC alloc]init];
            playbackVC.titleName = cell.listModel.name;
            playbackVC.listModel = cell.listModel;
            playbackVC.bIsEncrypt = cell.listModel.enable_sec;
            playbackVC.key = cell.listModel.dev_p_code;
            [self.navigationController pushViewController:playbackVC animated:YES];
        }else{
            [XHToast showTopWithText:@"请选择您想要的通道列表" topOffset:160];
        }
    }else{
        [XHToast showTopWithText:@"请先选择您想观看的相机" topOffset:160];
    }
   
}

#pragma mark ----- 返回按钮的代理方法
- (void)backBtnClick{
    //     [XHToast showTopWithText:@"点击了返回按钮" topOffset:160];
    //移除全屏时屏幕上的所有控件
    [self removeFullScreenControls];
    
    //判断是否关闭声音
    if (isCloseSound) {
        [self.btn_sound setImage:[UIImage imageNamed:@"sound_close_n"] forState:UIControlStateNormal];
    }else{
        [self.btn_sound setImage:[UIImage imageNamed:@"sound_open_n"] forState:UIControlStateNormal];
    }
//    //判断是否关闭高清
//    if (isCloseHd) {
//        [self.btn_hd setTitle:@"标清" forState:UIControlStateNormal];
//    }else{
//        [self.btn_hd setTitle:@"高清" forState:UIControlStateNormal];
//    }
    //判断是否关闭高清
    if (self.videoTypeStatus == JWVideoTypeStatusHd)
    {
        [self.btn_hd setTitle:@"高清" forState:UIControlStateNormal];
    }
    else if(self.videoTypeStatus == JWVideoTypeStatusNomal)
    {
        [self.btn_hd setTitle:@"标清" forState:UIControlStateNormal];
    }
    else if (self.videoTypeStatus == JWVideoTypeStatusFluency)
    {
        [self.btn_hd setTitle:@"流畅" forState:UIControlStateNormal];
    }
    
    
    //判断是否关闭录制
    if (self.isRecord) {
        [self.btn_video setBackgroundImage:[UIImage imageNamed:@"shootVideo_redable"] forState:UIControlStateNormal];
    }else{
        [self.btn_video setBackgroundImage:[UIImage imageNamed:@"shootVideo_able"] forState:UIControlStateNormal];
    }
    
    
    [self.btn_full setImage:[UIImage imageNamed:@"full_n"] forState:UIControlStateNormal];
    //[self shupinAction];

    [self shupinAction_xiugai];
    self.btnBack.hidden = NO;
}

#pragma mark ----- 暂停按钮点击事件【大屏状态】
- (void)suspendBtnClick:(id)sender{
    if (_selectIndexPath == nil) {
        return;
    }else{
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        UIButton *btn = (UIButton *)sender;
        btn.selected = !btn.selected;
        
        if (cell.isPlay) {//btn.selected
            [XHToast showTopWithText:@"视频停止" topOffset:160];
            [self stopVideo];//视频停止播放
            [btn setBackgroundImage:[UIImage imageNamed:@"realTimeplay_n"] forState:UIControlStateNormal];
        }else{
            [XHToast showTopWithText:@"视频播放" topOffset:160];
            NSIndexPath * indexPath = [_collectionView indexPathForCell:cell];
            self.clickAddBtnIndexPath = indexPath;
            self.selectIndexPath = self.clickAddBtnIndexPath;
            self.collectionView.selectIndexPath = self.clickAddBtnIndexPath;
            [btn setBackgroundImage:[UIImage imageNamed:@"realTimePause_n"] forState:UIControlStateNormal];
            [self getVideoAddress];
        }
    }
}
#pragma mark ----- 音量按钮点击事件【大屏状态】
- (void)voiceBtnClick:(id)sender{
    if (_selectIndexPath == nil) {
        return;
    }else{
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        UIButton *btn = (UIButton *)sender;
//        btn.selected = !btn.selected;
        if (isCloseSound) {
            [btn setBackgroundImage:[UIImage imageNamed:@"realTimeShengyin_n"] forState:UIControlStateNormal];
            isCloseSound = NO;
        }else{
            [btn setBackgroundImage:[UIImage imageNamed:@"realTimejingyin_n"] forState:UIControlStateNormal];
            isCloseSound = YES;
        }
        
        if (cell.isPlay == YES) {
            if (!isCloseSound) {//btn.selected
                [XHToast showTopWithText:@"声音:开" topOffset:160];
                [cell.videoManage JWPlayerManageSetAudioIsOpen:YES];
            }else{
                [XHToast showTopWithText:@"声音:关" topOffset:160];
                [cell.videoManage JWPlayerManageSetAudioIsOpen:NO];
            }
        }
    }
}

#pragma mark ----- 锁定滚轮按钮点击事件【大屏状态】
- (void)lockRockerBtnClick:(id)sender{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [XHToast showTopWithText:@"滚轮已锁定" topOffset:160];
        self.ZMRocker1.hidden = NO;
        self.IsRockLock = YES;
    }else{
        [XHToast showTopWithText:@"滚轮已解锁" topOffset:160];
        self.IsRockLock = NO;
        self.ZMRocker1.hidden = YES;
    }
}
#pragma mark ----- 麦克风按钮点击事件【大屏状态】
- (void)talkBtnClick:(id)sender{
    //    UIButton *btn = (UIButton *)sender;
    //    btn.selected = !btn.selected;
    //    if (btn.selected) {
    //        [XHToast showTopWithText:@"麦克风:开" topOffset:160];
    //    }else{
    //        [XHToast showTopWithText:@"麦克风:关" topOffset:160];
    //    }
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        UIButton *btn = (UIButton *)sender;
        btn.selected = !btn.selected;
        if (btn.selected) {
            [cell.videoManage JWPlayerManageStartAudioTalkWithCompletionBlock:^(JWErrorCode errorCode) {
                if (errorCode == 0) {
                    [XHToast showTopWithText:@"麦克风:开" topOffset:160];
                }else{
                    [XHToast showBottomWithText:[NSString stringWithFormat:@"开启对讲失败，错误码：%ld",(long)errorCode]];
                }
            }];
        }else{
            [cell.videoManage JWPlayerManageEndAudioTalkWithCompletionBlock:^(JWErrorCode errorCode) {
                [XHToast showTopWithText:@"麦克风:关" topOffset:160];
            }];
        }
    }else{
        [XHToast showTopWithText:@"请先单击选中您想要对讲的视频窗口" topOffset:160 duration:1.0f];
    }
    
    
}
#pragma mark ----- 截图按钮点击事件【大屏状态】
- (void)screenshotBtnClick:(id)sender{
    //    [XHToast showTopWithText:@"已保存截图到我的文件" topOffset:160];
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        //    播放截图音效
        [self playSoundEffect:@"capture.caf"];
        UIImage *ima = [self snapshot:cell.playView];
        [XHToast showTopWithText:@"已保存截图到我的文件" topOffset:160];
        WeakSelf(self);
        [self createShortcutPicToFilebIsVideo:NO shortCutImage:ima bIsFullScreen:YES];
        dispatch_async(dispatch_queue_create("photoScreenshot", NULL), ^{
            @synchronized (self) {
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
                    NSString *imgNameStr = [NSString stringWithFormat:@"文件格式:jpeg    截图时间:%@    关联设备通道:%@",DateTimeStr,self.navigationItem.title];
                    [weakSelf saveSmallImageWithImage:ima Url:@"" AtDirectory:pathStr ImaNameStr:imgNameStr];
                }
            }
        });
    }else{
        [XHToast showTopWithText:@"请先单击选中您想要截图的视频窗口" topOffset:160 duration:1.0f];
    }
}
#pragma mark ----- 录屏按钮点击事件【大屏状态】
- (void)videoBtnClick:(id)sender{
    if (_selectIndexPath) {
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        //        UIButton *btn = (UIButton *)sender;
        self.recordBtn = (UIButton *)sender;
        
        //判断是否在录制
//        if (self.isRecord == NO) {
//            [self.recordBtn setBackgroundImage:[UIImage imageNamed:@"zirealTimeVideo_close"] forState:UIControlStateNormal];
//        }else{
//            [self.recordBtn setBackgroundImage:[UIImage imageNamed:@"zirealTimeVideo_n"] forState:UIControlStateNormal];
//        }
        
        
        BOOL isplay = [cell.videoManage JWPlayerManageGetPlayState];
        if (isplay == NO &&!self.isRecord) {
            [XHToast showTopWithText:@"视频未播放" topOffset:160];
            return;
        }
        //播放录音音效
        [self playSoundEffect:@"record.caf"];
        if (!self.isRecord) {
            [XHToast showTopWithText:@"视频开始录制" topOffset:160];
            [self.recordBtn setBackgroundImage:[UIImage imageNamed:@"zirealTimeVideo_close"] forState:UIControlStateNormal];
            self.recordBtn.selected = YES;
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
            [XHToast showTopWithText:@"视频录制成功，已保存到我的文件" topOffset:160];
            [self.recordBtn setBackgroundImage:[UIImage imageNamed:@"zirealTimeVideo_n"] forState:UIControlStateNormal];
            self.recordBtn.selected = NO;
            UIImage * ima = [self snapshot:cell.playView];
            [self createShortcutPicToFilebIsVideo:YES shortCutImage:ima bIsFullScreen:YES];
            [cell.videoManage JWPlayerManageStopRecord];
            self.isRecord = NO;
        }
    }else{
        [XHToast showTopWithText:@"请先单击选中您想要录制的视频窗口" topOffset:160 duration:1.0f];
    }
}
#pragma mark - 关闭加载视频动画
- (void)stop_PlayMovie{
    _timer =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hidden_loadview) userInfo:nil repeats:YES];
    [self hidden_loadview];
    self.b_I_Frame_Start = YES;
}
- (void)hidden_loadview
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:self.collectionView.selectIndexPath];
        cell.loadView.hidden = YES;
    });
    
    [self stopTimer];
}
- (void)stopTimer
{
    [_timer invalidate];   // 将定时器从运行循环中移除，
    _timer = nil;
}


#pragma mark ----- 创建三码流大屏选择View
- (void)createFullScreenThreeStreamView{
    [self.view addSubview:self.fullScreenthreeStreamView];
    [self.fullScreenthreeStreamView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30);
        make.bottom.equalTo(self.view.mas_bottom).offset(-(0.7*iPhoneHeight/9+30));
        make.size.mas_equalTo(CGSizeMake(0.7*iPhoneHeight/9, 0.7*iPhoneHeight/3+15));
    }];
    //流畅按钮
    [self.fullScreenthreeStreamView addSubview:self.fd_fullBtn];
    [self.fd_fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.fullScreenthreeStreamView.mas_bottom).offset(0);
        make.centerX.equalTo(self.fullScreenthreeStreamView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(0.7*iPhoneHeight/9, 0.7*iPhoneHeight/9));
    }];
    //标清按钮
    [self.fullScreenthreeStreamView addSubview:self.sd_fullBtn];
    [self.sd_fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.fullScreenthreeStreamView.mas_centerY);
        make.centerX.equalTo(self.fullScreenthreeStreamView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(0.7*iPhoneHeight/9, 0.7*iPhoneHeight/9));
    }];
    //高清按钮
    [self.fullScreenthreeStreamView addSubview:self.hd_fullBtn];
    [self.hd_fullBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fullScreenthreeStreamView.mas_top).offset(0);
        make.centerX.equalTo(self.fullScreenthreeStreamView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(0.7*iPhoneHeight/9, 0.7*iPhoneHeight/9));
    }];
}

#pragma mark ----- 高清切换按钮点击事件【大屏状态】
/*
- (void)hdBtnClick:(id)sender{
    if (_selectIndexPath == nil) {
        return;
    }else{
         MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        UIButton *btn = (UIButton *)sender;
        if (isCloseHd) {
            [btn setBackgroundImage:[UIImage imageNamed:@"realTimeHd_h"] forState:UIControlStateNormal];
            isCloseHd = NO;
        }else{
            [btn setBackgroundImage:[UIImage imageNamed:@"realTimeHd_n"] forState:UIControlStateNormal];
            isCloseHd = YES;
        }
       
        if (cell.isPlay) {
            if (!isCloseHd) {
                [XHToast showTopWithText:@"高清" topOffset:160];
                [self judgeIsRecord1];//如果正在录像就停止录制
                [self getVideoAddress];
            }
            else{
                [XHToast showTopWithText:@"流畅" topOffset:160];
                [self judgeIsRecord1];//如果正在录像就停止录制
                [self getVideoAddress];
            }
        }
    }
    
}
 */

//大屏三码流切换按钮
- (void)hdBtnClick:(id)sender{
    
    if (_selectIndexPath == nil) {
        [XHToast showTopWithText:@"请选择您想要的通道列表" topOffset:160];
        return;
    }else{
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
        if (cell.isPlay == YES){
            [self createFullScreenThreeStreamView];
            self.fullScreenthreeStreamView.hidden = NO;
        }else{
            [XHToast showTopWithText:@"视频未播放" topOffset:160];
        }
    }
}

//流畅
- (void)fdFullClick{
//    [XHToast showTopWithText:@"暂时不支持流畅播放" topOffset:160];
    if (self.videoTypeStatus == JWVideoTypeStatusFluency) {
        return;
    }
    [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_fd", nil)] forState:UIControlStateNormal];
    [XHToast showTopWithText:@"流畅" topOffset:160];
    [self judgeIsRecord1];//如果正在录像就停止录制
    self.videoTypeStatus = JWVideoTypeStatusFluency;
    [self getVideoAddress];
}
//标清
- (void)sdFullClick{
//    if (isCloseHd == YES) {
//        [XHToast showTopWithText:@"当前已为标清" topOffset:160];
//    }else{
//        isCloseHd = YES;
//        [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_sd", nil)] forState:UIControlStateNormal];
//        [XHToast showTopWithText:@"标清" topOffset:160];
//        [self judgeIsRecord1];//如果正在录像就停止录制
//        [self getVideoAddress];
//    }
    if (self.videoTypeStatus == JWVideoTypeStatusNomal) {
        return;
    }
    [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_sd", nil)] forState:UIControlStateNormal];
    [XHToast showTopWithText:@"标清" topOffset:160];
    [self judgeIsRecord1];//如果正在录像就停止录制
    self.videoTypeStatus = JWVideoTypeStatusNomal;
    [self getVideoAddress];
}
//高清
- (void)hdFullClick{
//    if (isCloseHd == NO) {
//        [XHToast showTopWithText:@"当前已为高清" topOffset:160];
//    }else{
//        isCloseHd = NO;
//        [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_hd", nil)] forState:UIControlStateNormal];
//        [XHToast showTopWithText:@"高清" topOffset:160];
//        [self judgeIsRecord1];//如果正在录像就停止录制
//        [self getVideoAddress];
//    }
    
    if (self.videoTypeStatus == JWVideoTypeStatusHd) {
        return;
    }
    [self.controlFunctionView.hdBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_hd", nil)] forState:UIControlStateNormal];
    [XHToast showTopWithText:@"高清" topOffset:160];
    [self judgeIsRecord1];//如果正在录像就停止录制
    self.videoTypeStatus = JWVideoTypeStatusHd;
    [self getVideoAddress];
    
}


#pragma mark----------滚轮的代理协议-----------
-(void)rockerDidChangeDirection:(ZMRocker *)rocker{
    //    up down left right   1-2-3-4   center-0
    // MM_Log_AndLine(@"%ld",(long)rocker.direction);
    switch (rocker.direction) {
        case 1:
        {
            _control_num = 1;
            [self ControlFunc];
        }
            break;
        case 2:
        {
            _control_num = 2;
            [self ControlFunc];
        }
            break;
        case 3:
        {
            _control_num = 3;
            [self ControlFunc];
        }
            break;
        case 4:
        {
            _control_num = 4;
            [self ControlFunc];
        }
            break;
        case 0:
        {
            [self controlStop];
        }
            break;
        default:
            break;
    }
}


//=========================lazy loading=========================
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
/*
//控制云台View
- (ControlView *)controlView
{
    if (!_controlView) {
        _controlView = [ControlView viewFromXib];
        _controlView.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight);
        _controlView.delegate = self;
    }
    return _controlView;
}*/
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
- (MonitoringBottomView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[MonitoringBottomView alloc]init];
        _bottomView.hidden = YES;
        _bottomView.delegate = self;
    }
    return _bottomView;
}
//工具栏的懒加载
-(controlViewInFullScreen *)controlFunctionView{
    if (!_controlFunctionView) {
        _controlFunctionView = [[controlViewInFullScreen alloc]initLayoutOfFeature:self.feature.isTalk andCloudDeck:self.feature.isCloudDeck];
        _controlFunctionView.delegate = self;
    }
    return _controlFunctionView;
}

//返回按钮的懒加载
-(BackBtnView *)BackBtnView1{
    if (!_BackBtnView1) {
        _BackBtnView1 = [[BackBtnView alloc]init];
        _BackBtnView1.delegate = self;
    }
    return _BackBtnView1;
}
//流量与网速显示
-(SpeedAndflowView *)SpeedAndflowView1{
    if (!_SpeedAndflowView1) {
        _SpeedAndflowView1 = [[SpeedAndflowView alloc]init];
        _SpeedAndflowView1.hidden = YES;
    }
    return _SpeedAndflowView1;
}
//标题名字显示
- (DeviceTitleView *)DeviceTitleView1{
    if (!_DeviceTitleView1) {
        _DeviceTitleView1 = [[DeviceTitleView alloc]init];
    }
    return _DeviceTitleView1;
}
//滚轮按钮显示2.0
- (ZMRocker *)ZMRocker1
{
    if (!_ZMRocker1) {
        _ZMRocker1 =[[ZMRocker alloc]initWithFrame:CGRectMake(0, 0, 117, 117)];
        _ZMRocker1.hidden = YES;
        _ZMRocker1.delegate = self;
    }
    return _ZMRocker1;
}

#pragma mark ----- 大屏三码流选择View
-(UIView *)fullScreenthreeStreamView{
    if (!_fullScreenthreeStreamView) {
        _fullScreenthreeStreamView = [[UIView alloc]init];
        _fullScreenthreeStreamView.backgroundColor = [UIColor clearColor];
        _fullScreenthreeStreamView.hidden = YES;
    }
    return _fullScreenthreeStreamView;
}

#pragma mark ----- 全屏流畅按钮懒加载
-(UIButton *)fd_fullBtn{
    if (!_fd_fullBtn) {
        _fd_fullBtn = [[UIButton alloc]init];
        [_fd_fullBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_fd", nil)] forState:UIControlStateNormal];
        [_fd_fullBtn addTarget:self action:@selector(fdFullClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fd_fullBtn;
}
#pragma mark ----- 全屏标清按钮懒加载
-(UIButton *)sd_fullBtn{
    if (!_sd_fullBtn) {
        _sd_fullBtn = [[UIButton alloc]init];
        [_sd_fullBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_sd", nil)] forState:UIControlStateNormal];
        [_sd_fullBtn addTarget:self action:@selector(sdFullClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sd_fullBtn;
}
#pragma mark ----- 全屏高清按钮懒加载
-(UIButton *)hd_fullBtn{
    if (!_hd_fullBtn) {
        _hd_fullBtn = [[UIButton alloc]init];
        [_hd_fullBtn setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"realTime_hd", nil)] forState:UIControlStateNormal];
        [_hd_fullBtn addTarget:self action:@selector(hdFullClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hd_fullBtn;
}

- (NSMutableArray *)aliasArr
{
    if (!_aliasArr) {
        _aliasArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _aliasArr;
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, iPhoneWidth, iPhoneWidth-44) style:UITableViewStylePlain];
        [_tableView registerNib:[UINib nibWithNibName:@"OneTableViewCell" bundle:nil] forCellReuseIdentifier:ONECELL];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
        _tableView.backgroundColor = [UIColor yellowColor];
        _tableView.alwaysBounceVertical = NO;
        UIView * footView = [[UIView alloc]init];
        _tableView.tableFooterView = footView;
    }
    return _tableView;
}
//导航栏
- (UIView *)navView
{
    if (!_navView) {
        _navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,100, 44)];
        _navView.backgroundColor = [UIColor colorWithHexString:@"38adff"];
        //添加导航栏标题
        [_navView addSubview:self.titleLable];
        [_titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(_navView);
        }];
    }
    return _navView;
}
//导航栏标题
- (UILabel *)titleLable
{
    if (!_titleLable) {
        _titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
        _titleLable.font = [UIFont systemFontOfSize:15];
        _titleLable.textAlignment = NSTextAlignmentCenter;
        _titleLable.textColor = [UIColor whiteColor];
        _titleLable.text = @"通道列表";
    }
    return _titleLable;
}


#pragma mark ----- 停止视频播放的按钮
- (void)stopVideo{
    if (_selectIndexPath == nil) {
        
    }else{
        NSLog(@"停止");
        self.clickCell.loadView.hidden = YES;
        [[HDNetworking sharedHDNetworking]canleAllHttp];
        //如果正在录像就停止录制
        [self judgeIsRecord];
        MoveViewCell_c * cell = (MoveViewCell_c *)[_collectionView cellForItemAtIndexPath:_selectIndexPath];
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

#pragma mark ----- 设置能力集合
///设置能力集合
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
//                NSLog(@"存在Feature");
        NSString *featureStr = listModel.ext_info.Feature;
//                NSLog(@"featureStr:%@",featureStr);
        self.feature.isWiFi = [[featureStr substringWithRange:NSMakeRange(0,1)] intValue];
        self.feature.isTalk = [[featureStr substringWithRange:NSMakeRange(2,1)] intValue];
        self.feature.isCloudDeck = [[featureStr substringWithRange:NSMakeRange(4,1)] intValue];
        self.feature.isCloudStorage = [[featureStr substringWithRange:NSMakeRange(6,1)] intValue];
        self.feature.isP2P = [[featureStr substringWithRange:NSMakeRange(8,1)] intValue];
    }
    //判断支不支持对讲
        if (self.feature.isTalk) {
            [self.btn_talk setImage:[UIImage imageNamed:@"talkback_able"] forState:UIControlStateNormal];
        }else{
            [self.btn_talk setImage:[UIImage imageNamed:@"talkback_unable"] forState:UIControlStateNormal];
        }
    
    NSLog(@"isWiFi:%d,isTalk:%d,isCloudDeck:%d,isCloudStorage:%d,isP2P:%d",self.feature.isWiFi,self.feature.isTalk,self.feature.isCloudDeck,self.feature.isCloudStorage,self.feature.isP2P);
}

//初始化是否开启功能点
- (void)initIsOpenFunction{
    //声音的关闭与开启
    isCloseSound = YES;
    [self.btn_sound setImage:[UIImage imageNamed:@"sound_close_n"] forState:UIControlStateNormal];
    //高清的关闭与开启
//    isCloseHd = YES;
    self.videoTypeStatus = JWVideoTypeStatusNomal;//默认标清
    [self.btn_hd setTitle:@"标清" forState:UIControlStateNormal];
    //录像的关闭与开启
    [self.btn_video setBackgroundImage:[UIImage imageNamed:@"shootVideo_able"] forState:UIControlStateNormal];
}

//判断是否关闭声音
- (void)judgeIsCloseSound{
    if (isCloseSound) {//判断是否关闭声音
        [self.btn_sound setImage:[UIImage imageNamed:@"sound_open_n"] forState:UIControlStateNormal];
        isCloseSound = NO;
    }else{
        [self.btn_sound setImage:[UIImage imageNamed:@"sound_close_n"] forState:UIControlStateNormal];
        isCloseSound = YES;
    }
}

/*
//判断是否关闭高清
- (void)judgeIsCloseHd{
    if (isCloseHd) {//判断是否关闭高清
        [self.btn_hd setImage:[UIImage imageNamed:@"hd_h"] forState:UIControlStateNormal];
        isCloseHd = NO;
    }else{
        [self.btn_hd setImage:[UIImage imageNamed:@"hd_n"] forState:UIControlStateNormal];
        isCloseHd = YES;
    }
    
}
*/

#pragma mark - 截图则在右下角出现的缩略图，可以点击进入相应的文件列表
- (void)createShortcutPicToFilebIsVideo:(BOOL)isVideo shortCutImage:(UIImage *)image bIsFullScreen:(BOOL)fullscreen
{
    self.bgView.hidden = NO;
    self.cutImage.hidden = NO;
    if (isVideo) {
        self.videoBgView.hidden = NO;
        self.videoLogo.hidden = NO;
    }else{
        self.videoBgView.hidden = YES;
        self.videoLogo.hidden = YES;
    }
    self.bgView.tag = isVideo? 1001:1002;
    CGFloat videoHeight = CGRectGetHeight(self.VideoViewBack.frame);
    CGFloat videoWidth = CGRectGetWidth(self.VideoViewBack.frame);
    NSLog(@"变为全屏后，播放器界面的大小：%f===%f",videoHeight,videoWidth);
    [self.cutImage setImage:image];
    
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.VideoViewBack).offset(10);
        make.bottom.mas_equalTo(self.VideoViewBack.mas_bottom).offset(-54);
        make.height.mas_equalTo(videoHeight/3);
        make.width.mas_equalTo(videoWidth/3);
        [self.bgView layoutIfNeeded];
    }];
    [self.cutImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(_bgView).offset(1);
        make.bottom.right.mas_equalTo(_bgView).offset(-1);
        [self.cutImage layoutIfNeeded];
    }];
    
    //    [UIView animateWithDuration:3.0 animations:^{
    //        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
    //            make.left.mas_equalTo(self.VideoViewBack).offset(10);
    //            make.bottom.mas_equalTo(self.VideoViewBack.mas_bottom).offset(-54);
    //            make.height.mas_equalTo(videoHeight/3);
    //            make.width.mas_equalTo(videoWidth/3);
    //            [self.bgView layoutIfNeeded];
    //        }];
    //        [self.cutImage mas_remakeConstraints:^(MASConstraintMaker *make) {
    //            make.left.top.mas_equalTo(_bgView).offset(4);
    //            make.bottom.right.mas_equalTo(_bgView).offset(-4);
    //            [self.cutImage layoutIfNeeded];
    //        }];
    //    }];
    
    _shortCutShowTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hideShortcutPic) userInfo:nil repeats:NO];
    
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    singleFingerOne.delegate = self;
    [_bgView addGestureRecognizer:singleFingerOne];
}
- (UIView *)bgView
{
    if (!_bgView) {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor lightGrayColor];
        [self.VideoViewBack addSubview:_bgView];
        CGFloat videoHeight = CGRectGetHeight(self.VideoViewBack.frame);
        CGFloat videoWidth = CGRectGetWidth(self.VideoViewBack.frame);
        [_bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.VideoViewBack);
            make.bottom.mas_equalTo(self.VideoViewBack);
            make.height.mas_equalTo(videoHeight);
            make.width.mas_equalTo(videoWidth);
            // [_bgView layoutIfNeeded];
        }];
    }
    return _bgView;
}
- (UIImageView *)cutImage{
    if (!_cutImage) {
        _cutImage = [[UIImageView alloc]init];
        [_bgView addSubview:_cutImage];
        [_cutImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(_bgView).offset(1);
            make.bottom.right.mas_equalTo(_bgView).offset(-1);
            //  [_cutImage layoutIfNeeded];
        }];
    }
    return _cutImage;
}
- (UIView *)videoBgView
{
    if (!_videoBgView) {
        _videoBgView = [[UIView alloc]init];
        _videoBgView.backgroundColor = [UIColor blackColor];
        _videoBgView.alpha = 0.7;
        [_cutImage addSubview:_videoBgView];
        [_videoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(_cutImage);
            make.bottom.mas_equalTo(_cutImage);
            make.height.mas_equalTo(@15);
        }];
        _videoBgView.hidden = YES;
    }
    return _videoBgView;
}
- (UIImageView *)videoLogo
{
    if (!_videoLogo) {
        _videoLogo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"videoLogo"]];
        [_videoBgView addSubview:_videoLogo];
        [_videoLogo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_videoBgView.mas_left).offset(4);
            make.top.bottom.mas_equalTo(_videoBgView);
            make.width.mas_equalTo(@20);
        }];
        _videoLogo.hidden = YES;
    }
    return _videoLogo;
}

#pragma mark 使得截图快速进入文件夹，3秒消失
- (void)hideShortcutPic
{
    self.bgView.hidden = YES;
    self.cutImage.hidden = YES;
}

//处理单指事件
- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)sender
{
    NSLog(@"点击快速跳转到文件：%ld",sender.view.tag);
    float arch = 0;
    self.navigationController.view.transform = CGAffineTransformMakeRotation(arch);
    self.navigationController.view.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    if (sender.view.tag == 1001) {//视频
        //进入图片保存文件界面
        FileVideoController * videoVC = [[FileVideoController alloc]init];
        FileImageController * imageVC = [[FileImageController alloc]init];
        SegmentViewController * segmentVC = [[SegmentViewController alloc]init];
        segmentVC.bIsVideo = YES;
        segmentVC.editing = YES;
        [segmentVC setViewControllers:@[videoVC,imageVC]];
        [segmentVC setTitles:@[@"视频",@"图片"]];
        [self.navigationController pushViewController:segmentVC animated:YES];
    }
    else if (sender.view.tag == 1002)
    {
        //进入录制视频保存文件界面
        FileVideoController * videoVC = [[FileVideoController alloc]init];
        FileImageController * imageVC = [[FileImageController alloc]init];
        SegmentViewController * segmentVC = [[SegmentViewController alloc]init];
        segmentVC.bIsVideo = NO;
        segmentVC.editing = YES;
        [segmentVC setViewControllers:@[videoVC,imageVC]];
        [segmentVC setTitles:@[@"视频",@"图片"]];
        [self.navigationController pushViewController:segmentVC animated:YES];
    }
}
@end
