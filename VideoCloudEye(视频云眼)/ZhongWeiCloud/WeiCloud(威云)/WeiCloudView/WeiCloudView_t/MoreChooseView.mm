//
//  MoreChooseView.m
//  封装二级选择列表
//
//  Created by 张策 on 16/10/27.
//  Copyright © 2016年 张策. All rights reserved.
//

#define ONECELL @"OneTableViewCell"

#import "NSString+Md5String.h"

//newsdk
#import "VmNet.h"
#import "VmType.h"
#import "ErrorCode.h"

//model

#import "VideoModel.h"

#import "MoreChooseView.h"
//一级目录cell
#import "OneTableViewCell.h"
//二级目录cell
#import "TableChooseCell.h"

#import "PassageWay_t.h"

#import "WeiCloudListModel.h"

@interface MoreChooseView ()<UITableViewDelegate,UITableViewDataSource>

//顶部导航栏
@property (nonatomic,strong)UIView *navView;
//导航栏标题
@property (nonatomic,strong)UILabel *titleLable;
//全选按钮
@property (nonatomic,strong)UIButton *allChooseBtn;
//一级列表
@property (nonatomic,strong)UITableView *oneTableView;
//二级列表
@property (nonatomic,strong)UITableView *twoTableView;
//一级数据源
@property (nonatomic,strong)NSMutableArray *oneDataArr;
//二级数据源
@property (nonatomic,strong)NSMutableArray *twoDataArr;
//已选数据源
@property (nonatomic,strong)NSMutableArray *selectDataArr;
//是否全选
@property (nonatomic,assign)BOOL ifAllSelected;
//底部确定按钮
@property (nonatomic,strong)UIButton *okBtn;
//二级菜单返回按钮
@property (nonatomic,strong)UIButton *backBtn;

@end

@implementation MoreChooseView

//导航栏
- (UIView *)navView
{
    if (!_navView) {
        _navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
        _navView.backgroundColor = MAIN_COLOR;
        //添加导航栏标题
        [_navView addSubview:self.titleLable];
        _titleLable.center = _navView.center;
        
        //添加全选按钮
        [_navView addSubview:self.allChooseBtn];
        [self.allChooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_navView.mas_right).offset(-8);
            make.top.equalTo(_navView.mas_top);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(44);
        }];
        
        //添加返回按钮
        [_navView addSubview:self.backBtn];
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_navView.mas_left).offset(8);
            make.top.equalTo(_navView.mas_top);
            make.height.mas_equalTo(44);
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
        _titleLable.text = NSLocalizedString(@"通道列表", nil);
    }
    return _titleLable;
}
//返回按钮
- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [[UIButton alloc]init];
        [_backBtn setTitle:NSLocalizedString(@"返回", nil) forState:UIControlStateNormal];
        _backBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(showFirstView) forControlEvents:UIControlEventTouchUpInside];
        _backBtn.alpha = 0;
    }
    return _backBtn;
}
//全选按钮
- (UIButton *)allChooseBtn
{
    if (!_allChooseBtn) {
        _allChooseBtn = [[UIButton alloc]init];
        [_allChooseBtn setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
        [_allChooseBtn setTitle:NSLocalizedString(@"取消全选", nil) forState:UIControlStateSelected];
        _allChooseBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _allChooseBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        _allChooseBtn.hidden = YES;
        _ifAllSelected = NO;

        [_allChooseBtn addTarget:self action:@selector(ChooseAllClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _allChooseBtn;
}
//一级列表
- (UITableView *)oneTableView
{
    if (_oneTableView == nil) {
        _oneTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, self.bounds.size.width , self.bounds.size.height-88) style:UITableViewStylePlain];
        _oneTableView.delegate = self;
        _oneTableView.dataSource = self;
        [_oneTableView registerNib:[UINib nibWithNibName:@"OneTableViewCell" bundle:nil] forCellReuseIdentifier:ONECELL];
        
        UIView *footView = [[UIView alloc]init];
        _oneTableView.tableFooterView = footView;
    }
    return _oneTableView;
}
//二级列表
- (UITableView *)twoTableView
{
    if (_twoTableView == nil) {
        _twoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, self.bounds.size.width , self.bounds.size.height-44-44) style:UITableViewStylePlain];
        _twoTableView.delegate = self;
        _twoTableView.dataSource = self;
        _twoTableView.alpha = 0;
        UIView *footView = [[UIView alloc]init];
        _twoTableView.tableFooterView = footView;
    }
    return _twoTableView;
}
//预览按钮
- (UIButton *)okBtn
{
    if (!_okBtn) {
        _okBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-44, self.bounds.size.width, 44)];
        _okBtn.backgroundColor = [UIColor colorWithHexString:@"38adff"];
        [_okBtn setTitle:NSLocalizedString(@"播放", nil) forState:UIControlStateNormal];
        [_okBtn setTintColor:[UIColor whiteColor]];
        [_okBtn addTarget:self action:@selector(okBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _okBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _okBtn.alpha = 0;
    }
    return _okBtn;
}
//一组数据源
- (NSMutableArray *)oneDataArr
{
    if (!_oneDataArr) {
        _oneDataArr = [NSMutableArray array];
    }
    return _oneDataArr;
}
//二组数据源
- (NSMutableArray *)twoDataArr
{
    if (!_twoDataArr) {
        _twoDataArr = [NSMutableArray array];
    }
    return _twoDataArr;
}

//已选数据源
- (NSMutableArray *)selectDataArr
{
    if (!_selectDataArr) {
        _selectDataArr = [NSMutableArray array];
    }
    return _selectDataArr;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sutUpUI];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self sutUpUI];
    }
    return self;
}

- (void)sutUpUI
{
    
    [self loadList];
//    self.backgroundColor = [UIColor whiteColor];
    //添加导航栏
    [self addSubview:self.navView];
    //添加一级列表
    [self addSubview:self.oneTableView];
   // [self addSubview:self.twoTableView];
    //默认多选
    self.isSingle = NO;
}


- (void)loadList
{
    [self.oneDataArr removeAllObjects];
    NSArray *tempArr = [[unitl getAllDeviceCameraModel] copy];
    for (int i = 0; i < tempArr.count; i++) {
        dev_list *VideolistModel =  tempArr[i];
        if (VideolistModel.chan_size == 1) {
            if (VideolistModel.status == 1) {
             [self.oneDataArr addObject:VideolistModel];
            }
        }
    }
    if (self.oneDataArr.count > 0) {
        [self.oneTableView reloadData];
    }

    /*
    //一级列表
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"oneDataArr"]) {
        self.oneDataArr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"oneDataArr"]];
    }else{
        //获取一级列表
        TVmDepTree depTrees[100];
        unsigned int depTreesX ;
        int getDepTreesInt = VmNet_GetDepTrees(1, 100, depTrees, depTreesX);
        if (getDepTreesInt == 0) {
            for (int i = 0; i<depTreesX; i++) {
                TVmDepTree depTreesT = depTrees[i];
                NSString *str=[[NSString alloc] initWithCString:(const char*)depTreesT.sDepName encoding:NSUTF8StringEncoding];
                [self.oneDataArr addObject:str];
            }
            [self.oneTableView reloadData];
            NSArray *oneDataArr = [NSArray arrayWithArray:self.oneDataArr];
            [[NSUserDefaults standardUserDefaults]setObject:oneDataArr forKey:@"oneDataArr"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    //二级列表
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"twoDataArr"]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:@"twoDataArr"];
        NSArray *dataArr =  [NSKeyedUnarchiver unarchiveObjectWithData:data];
        //使用一个数组来接受数据
        self.twoDataArr = [NSMutableArray arrayWithArray:dataArr];
    }else{
        //获取二级列表
        TVmChannel channel[100];
        unsigned int channelX;
        int getChannelsInt = VmNet_GetChannels(1, 100, 0, channel, channelX);
        if (getChannelsInt == 0) {
            for (int i = 0; i<channelX; i++) {
                TVmChannel channelT = channel[i];
                //模型赋值
                VideoModel *videoModel = [[VideoModel alloc]init];
                videoModel.nDepId = channelT.nDepId;
                videoModel.sFdId = [[NSString alloc] initWithCString:(const char*)channelT.sFdId encoding:NSASCIIStringEncoding];
                videoModel.nChannelId = channelT.nChannelId;
                videoModel.uChannelType = channelT.uChannelType;
                videoModel.sChannelName = [[NSString alloc] initWithCString:(const char*)channelT.sChannelName encoding:NSUTF8StringEncoding];
                videoModel.uIsOnLine = channelT.uIsOnLine;
                videoModel.uVideoState = channelT.uVideoState;
                videoModel.uChannelState = channelT.uChannelState;
                videoModel.uRecordState = channelT.uRecordState;
                [self.twoDataArr addObject:videoModel];
            }

            NSArray *array = [NSArray arrayWithArray:self.twoDataArr];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
            [[NSUserDefaults standardUserDefaults]setObject:data forKey:@"twoDataArr"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
     */
}
- (void)loadTwoData:(NSIndexPath *)index
{
    /*
    realTimeVC.listModel = listModel;
    realTimeVC.chan_size = listModel.chan_size;
    realTimeVC.chan_alias = listModel.chan_alias;
    realTimeVC.bIsEncrypt = listModel.enable_sec;
    realTimeVC.key = listModel.dev_p_code;
     */
/*
    [self.twoDataArr removeAllObjects];
    dev_list *VideolistModel = self.oneDataArr[index.row];
    NSDictionary * nameDic = VideolistModel.chan_alias;
    NSDictionary * chan_alias = nameDic;
    NSMutableArray * chanName_arr = [NSMutableArray array];
    if ([[chan_alias allKeys] count] >0) {
        int num = (int)[[chan_alias allKeys] count];
        for (int i = 1; i<=num; i++) {
            NSString * key = [NSString stringWithFormat:@"%d",i];
            NSString * strr = [chan_alias objectForKey:key];
            [chanName_arr addObject:strr];
        }
        NSLog(@"-------%@-------",chanName_arr);
        NSLog(@"%@",chan_alias);
    }
    self.twoDataArr = chanName_arr;
    [self.twoTableView reloadData];
 */
}
- (BOOL)judgeDeviceIsNVRWithIndex:(NSIndexPath *)index
{
    [self.twoDataArr removeAllObjects];
    dev_list *VideolistModel = self.oneDataArr[index.row];
    NSDictionary * nameDic = VideolistModel.chan_alias;
    NSDictionary * chan_alias = nameDic;
    NSMutableArray * chanName_arr = [NSMutableArray array];
    if ([[chan_alias allKeys] count] >0) {
        int num = (int)[[chan_alias allKeys] count];
        for (int i = 1; i<=num; i++) {
            NSString * key = [NSString stringWithFormat:@"%d",i];
            NSString * strr = [chan_alias objectForKey:key];
            [chanName_arr addObject:strr];
        }
        NSLog(@"-------%@-------",chanName_arr);
        NSLog(@"%@",chan_alias);
    }
    self.twoDataArr = chanName_arr;
    if (self.twoDataArr.count == 0) {
        return NO;
    }else{
        return YES;
    }
}

#pragma mark ------tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _oneTableView) {
        return _oneDataArr.count;
    }
    else
        return _twoDataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [unitl clearDataWithKey:@"NT4Tableview"];
    if (tableView == _oneTableView) {
        /*
        OneTableViewCell *oneCell = [tableView dequeueReusableCellWithIdentifier:ONECELL];
        oneCell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        oneCell.lab_title.text = _oneDataArr[indexPath.row];
        oneCell.lab_count.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.twoDataArr.count];
        return oneCell;
         */
        static NSString * str = @"MyCell";
        PassageWay_t * cell = [tableView dequeueReusableCellWithIdentifier:str];
        if(!cell){
            cell = [[PassageWay_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
        }
        dev_list *VideolistModel = self.oneDataArr[indexPath.row];
        if (indexPath.row<self.oneDataArr.count) {
            if ([unitl isNull:VideolistModel.name]) {
                cell.titleLbel.text = [NSString stringWithFormat:@"%@", VideolistModel.type];
            }else{
                cell.titleLbel.text = [NSString stringWithFormat:@"%@", VideolistModel.name];
            }
        }else{
            cell.titleLbel.text = [NSString stringWithFormat:@"%@00%ld",NSLocalizedString(@"通道", nil),(long)indexPath.row+1];
        }
        return cell;
        
    }else{
        /*
        NSString * identifier = [NSString stringWithFormat:@"cellId%ld",(long)indexPath.row];
        TableChooseCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[TableChooseCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        VideoModel *videoModel = [_twoDataArr objectAtIndex:indexPath.row];
        ;
        cell.titleLabel.text = videoModel.sChannelName;
        [cell UpdateCellWithState:_ifAllSelected];
        
        return cell;
         */
    
        static NSString * str = @"MyCell";
        PassageWay_t * cell = [tableView dequeueReusableCellWithIdentifier:str];
        if(!cell){
            cell = [[PassageWay_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
        }
       // dev_list *VideolistModel = self.twoDataArr[indexPath.row];
        if (indexPath.row<self.twoDataArr.count) {
            cell.titleLbel.text = [NSString stringWithFormat:@"%@", self.twoDataArr[indexPath.row]];
        }else{
            cell.titleLbel.text = [NSString stringWithFormat:@"%@00%ld",NSLocalizedString(@"通道", nil),(long)indexPath.row+1];
        }
        return cell;
    }
 
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (tableView == _oneTableView) {
       dev_list *VideolistModel = self.oneDataArr[indexPath.row];
      [self didSelectedCellIndex:indexPath WithDeviceModel:VideolistModel isNVR:NO];
    }
    
    
//    if (tableView == _oneTableView) {
//       BOOL isNVR = [self judgeDeviceIsNVRWithIndex:indexPath];
//        if (isNVR) {
//            [self loadTwoData:indexPath];
//            //展现二级界面
//            [self showSecondView];
//        }else{
//            dev_list *VideolistModel = self.oneDataArr[indexPath.row];
//            [self didSelectedCellIndex:indexPath WithDeviceID:VideolistModel.ID isNVR:isNVR];
//        }
//    }else{
//         dev_list *VideolistModel = self.oneDataArr[indexPath.row];
//        [self didSelectedCellIndex:indexPath WithDeviceID:VideolistModel.ID isNVR:YES];
//
//        /*
//        TableChooseCell * cell = [tableView cellForRowAtIndexPath:indexPath];
//        VideoModel *videoModel = self.twoDataArr[indexPath.row];
//        [cell UpdateCellWithState:!cell.isSelected];
//        if (cell.isSelected) {
//            //添加已选数组
//            [self.selectDataArr addObject:videoModel];
//        }
//        //单选状态
//        if (self.isSingle) {
//            [self okBtnClick];
//            return;
//        }
//        else if(cell.isSelected == NO)
//        {
//            //并不是全选状态
//            _ifAllSelected = NO;
//            self.allChooseBtn.selected = NO;
//            //删除上一个添加的数组
//            [self.selectDataArr removeLastObject];
//        }
//         */
//    }

}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didSelectedCellIndex:(NSIndexPath *)index WithDeviceModel:(dev_list *)deviceModel isNVR:(BOOL)isNvr
{
    if (self.moreDelegate && [self.moreDelegate respondsToSelector:@selector(didSelectedCellIndex:WithDeviceModel:isNVR:)]) {
        [self.moreDelegate didSelectedCellIndex:index WithDeviceModel:deviceModel isNVR:isNvr];
    }
}


#pragma mark ------全选按钮相应
-(void)ChooseAllClick:(UIButton *)button{
    _ifAllSelected = !_ifAllSelected;
    _allChooseBtn.selected = !_allChooseBtn.selected;
    if (_ifAllSelected) {
        [_twoTableView reloadData];
        //删除所有已选 添加全部数组
        [self.selectDataArr removeAllObjects];
        for (VideoModel *videoModel in self.twoDataArr) {
            [self.selectDataArr addObject:videoModel];
        }
    }
    else{
        [_twoTableView reloadData];
        //删除已选数组
        [self.selectDataArr removeAllObjects];
    }
}

#pragma mark ------预览按钮响应
- (void)okBtnClick
{
    for (VideoModel *videoModel in self.selectDataArr) {
        NSLog(@"已选通道=======%@",videoModel.sChannelName);
    }
    if (self.moreDelegate && [self.moreDelegate respondsToSelector:@selector(pushSelectDataArr:)]) {
        [self.moreDelegate pushSelectDataArr:self.selectDataArr];
    }
}
#pragma mark ------二级界面相关展现
- (void)showSecondView
{
    [UIView animateWithDuration:0.5 animations:^{
        //添加二级列表
        [self addSubview:self.twoTableView];
        //添加底部预览按钮
        [self addSubview:self.okBtn];
        _oneTableView.alpha = 0;
        _twoTableView.alpha = 1;
        if (self.isSingle) {
            _allChooseBtn.alpha = 0;
        }else{
            _allChooseBtn.alpha = 1;
        }
        _okBtn.alpha = 1;
        _backBtn.alpha = 1;
    }];
}
#pragma mark ------一级界面相关展现
- (void)showFirstView
{
    //返回时二级界面消失
    [self.twoTableView removeFromSuperview];
    self.twoTableView = nil;
    //删除所有已选数组
    [self.selectDataArr removeAllObjects];
    [UIView animateWithDuration:0.5 animations:^{
        _oneTableView.alpha = 1;
        _twoTableView.alpha = 0;
        _allChooseBtn.alpha = 0;
        _okBtn.alpha = 0;
        _backBtn.alpha = 0;
    }];
}

@end
