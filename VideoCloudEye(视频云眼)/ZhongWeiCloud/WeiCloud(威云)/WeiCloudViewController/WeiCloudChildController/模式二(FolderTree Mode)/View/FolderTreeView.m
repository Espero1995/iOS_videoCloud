//
//  FolderTreeView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2019/10/14.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import "FolderTreeView.h"
#import "FolderTreeModel.h"
#import "FolderTreeCell.h"
@interface FolderTreeView()
<
    UITableViewDelegate,
    UITableViewDataSource
>
{
    NSInteger treeIndex;//树的层数（根节点默认为1）
}
/**
 * @brief 文件树目录
 */
@property (nonatomic,strong)UITableView *tv_list;

/**
 * @brief 树数组
 */
@property (nonatomic, strong) NSMutableArray *treeArr;

/**
 * @brief 父节点
 */
@property (nonatomic, copy) NSString *previousNodeId;

/**
 * @brief 父节点名称数组
 */
@property (nonatomic, strong) NSMutableArray *fatherNameArr;

 
@end

@implementation FolderTreeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

#pragma mark - setUI
- (void)setUpUI
{
    treeIndex = 1;//默认从第一层开始作为根节点
    self.currentNodeId = @"";
    [self addSubview:self.tv_list];
    [self.fatherNameArr addObject:@"根目录"];
    //下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getNextNodeTreeList)];
    [header beginRefreshing];
    self.tv_list.mj_header = header;
}

#pragma mark - 获取下层节点请求
- (void)getNextNodeTreeList
{
  /*
   * description : GET /open/deviceTree/listNodes(获取指定父节点下单层设备树节点)
   *  param：access_token=<令牌> & user_id=<用户id>
   *  parentId：父节点id，为空则获取根节点列表
   */
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [postDic setObject:self.currentNodeId forKey:@"parentId"];
    
    [[HDNetworking sharedHDNetworking] GET:@"open/deviceTree/listNodes" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"节点目录:%@",responseObject);
        [self.treeArr removeAllObjects];
        int ret = [responseObject[@"ret"] intValue];
        if (ret == 0) {
            self.treeArr = [FolderTreeModel mj_objectArrayWithKeyValuesArray:responseObject[@"body"]];
            
            if (self.treeArr.count !=0) {
                if (self.treeArr.count == 1) {
                    FolderTreeModel *model = self.treeArr[0];
                    if (!model.hasChildren) {
                        if (treeIndex == 1) {
                            [self getleafRootTitle:@"根目录" andisOnlyRoot:NO];
                        }
                        self.previousNodeId = ((FolderTreeModel *)(self.treeArr[0])).parentId;
                    }else{
                        //进入设备列表界面
                        self.currentNodeId = model.nodeId;
                        [self getleafRootTitle:model.nodeName andisOnlyRoot:YES];
                        [self getleafNodeDeviceList];
                    }
                    
                }else{
                    if (treeIndex == 1) {
                        [self getleafRootTitle:@"根目录" andisOnlyRoot:NO];
                    }
                    self.previousNodeId = ((FolderTreeModel *)(self.treeArr[0])).parentId;
                }
                
            }
            
            
            [self.tv_list reloadData];
            [self.tv_list.mj_header endRefreshing];
        }else{
            
            [XHToast showCenterWithText:@"获取列表失败，稍候再试"];
            [self.tv_list reloadData];
            [self.tv_list.mj_header endRefreshing];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [XHToast showCenterWithText:@"获取列表失败，请检查您当前的网络"];
        [self.tv_list reloadData];
        [self.tv_list.mj_header endRefreshing];
    }];
    
}

#pragma mark - 获取首页初始化时的title
- (void)getleafRootTitle:(NSString *)titleStr andisOnlyRoot:(BOOL)isOnlyRoot
{
    if (self.delegate && [self respondsToSelector:@selector(getleafRootTitle:andisOnlyRoot:)]) {
        [self.delegate getleafRootTitle:titleStr andisOnlyRoot:isOnlyRoot];
    }
}


#pragma mark - 退回上级页面 即树高减1
- (void)popTableView
{
    treeIndex --;
    [self.fatherNameArr removeObjectAtIndex:treeIndex];
    
    if (treeIndex == 1) {
        self.currentNodeId = @"";
    }else{
        self.currentNodeId = self.previousNodeId;
    }
    
    [self getNextNodeTreeList];
    [self getTreeIndex:treeIndex andNodeName:self.fatherNameArr[treeIndex-1]];
}

#pragma mark - 获取树节点当前所处高度和名称
- (void)getTreeIndex:(NSInteger)treeIndex andNodeName:(NSString *)nodeName
{
    if (self.delegate && [self respondsToSelector:@selector(getTreeIndex:andNodeName:)]) {
        [self.delegate getTreeIndex:treeIndex andNodeName:nodeName];
    }

}

#pragma mark - 获取叶子节点下的设备列表
- (void)getleafNodeDeviceList
{
    if (self.delegate && [self respondsToSelector:@selector(getleafNodeDeviceList)]) {
        [self.delegate getleafNodeDeviceList];
    }
}


#pragma mark - delegate
#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.treeArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *FolderTreeCell_Identifier = @"FolderTreeCell_Identifier ";
    FolderTreeCell * cell = [tableView dequeueReusableCellWithIdentifier:FolderTreeCell_Identifier];
    if(!cell){
        cell = [[FolderTreeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FolderTreeCell_Identifier];
    }
    
    //确保不会由于数据缺失导致的闪退
    if (self.treeArr.count >= row) {
        FolderTreeModel *model = self.treeArr[row];
        cell.nodeNameLb.text = model.nodeName;
        NSString *totalCount = @"0";
        NSString *onlineCount = @"0";
        if (![NSString isNull:model.channelCount] && ![NSString isNull:model.channelOnlineCount]) {
            totalCount = model.channelCount;
            onlineCount = model.channelOnlineCount;
        }
        NSMutableAttributedString *channelStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"(%@/%@)",onlineCount,totalCount]];
        [channelStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:23/255.0 green:139/255.0 blue:54/255.0 alpha:1] range:NSMakeRange(1,onlineCount.length)];
        cell.channelLb.attributedText = channelStr;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //确保不会由于数据缺失导致的闪退
    if (self.treeArr.count >= row) {
        FolderTreeModel *model = self.treeArr[row];
        self.currentNodeId = model.nodeId;
        treeIndex++;
        [self.fatherNameArr addObject:model.nodeName];
        //进入设备列表界面
        NSString *title = [NSString stringWithFormat:@"%@(%@/%@)",model.nodeName,model.channelOnlineCount,model.channelCount];
        [self getTreeIndex:treeIndex andNodeName:title];
        if (model.hasChildren == 1) {
            [self getNextNodeTreeList];
        }else{
//            //进入设备列表界面
            [self getleafNodeDeviceList];
        }
    }
    
    
}

//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

//head的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 10)];
    headView.backgroundColor = BG_COLOR;
    return headView;
}


#pragma mark  setters && getters
-(UITableView *)tv_list
{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-iPhoneToolBarHeight-iPhoneNav_StatusHeight) style:UITableViewStyleGrouped];
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        _tv_list.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    }
    return _tv_list;
}

#pragma mark - 树数组
- (NSMutableArray *)treeArr
{
    if (!_treeArr) {
        _treeArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _treeArr;
}

- (NSMutableArray *)fatherNameArr
{
    if (!_fatherNameArr) {
        _fatherNameArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _fatherNameArr;
}

#pragma mark - TableView 占位图
- (UIImage *)xy_noDataViewImage {
    return [UIImage imageNamed:@"noContent"];
}

- (NSString *)xy_noDataViewMessage {
    return NSLocalizedString(@"暂无文件目录", nil);
}

- (NSNumber *)xy_noDataViewCenterYOffset
{
    return @10;
}

@end
