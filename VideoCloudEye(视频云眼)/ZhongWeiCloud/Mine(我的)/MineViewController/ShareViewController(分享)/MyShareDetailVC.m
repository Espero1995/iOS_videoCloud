//
//  MyShareDetailVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/19.
//  Copyright © 2018年 张策. All rights reserved.
//
#define headViewHeight 124
#import "MyShareDetailVC.h"
#import "ShareDetailCell_t.h"
#import "ZCTabBarController.h"
//通讯录
#import "SXAddressBookManager.h"
#import <ContactsUI/ContactsUI.h>
#import <AddressBook/AddressBook.h>
#import "WeiCloudListModel.h"
#import "ScottAlertController.h"
#import "UIImage+image.h"
#import "WeiCloudShareView.h"

#import "YALSunnyRefreshControl.h"
@interface MyShareDetailVC ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UISearchBarDelegate,
    UISearchResultsUpdating,
    UIAlertViewDelegate,
    ShareDetail_tDelegete,
    CNContactPickerDelegate,
    WeiCloudShareViewDelegate
>
{
    long index;
}

@property (nonatomic,strong) UITableView * tableView;

/*头视图：搜索框+搜索电话View*/
@property (nonatomic, strong) UIView *headView;

@property (nonatomic,copy) NSMutableString * nameStr;

@property (nonatomic,copy) NSMutableString * userID;

@property (nonatomic,copy) NSMutableString * user_id;

/*手机号*/
@property (nonatomic,copy)NSString *iphoneNumberStr;
/*分享的数据*/
@property (nonatomic,strong)dev_list *shareModel;

/*搜索控制器*/
@property(nonatomic,strong)UISearchController *searchController;
/*搜索框*/
@property (nonatomic, strong) UISearchBar *searchBar;
/*满足搜索条件的数组*/
@property (strong, nonatomic)NSMutableArray  *searchList;
/*刷新控件*/
@property (nonatomic,strong) YALSunnyRefreshControl *sunnyRefreshControl;

@end

@implementation MyShareDetailVC
//==========================system==========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title =@"分享人列表";
    self.view.backgroundColor = BG_COLOR;
    _nameStr = [NSMutableString string];
    _userID = [NSMutableString string];
    _user_id = [NSMutableString string];
    [self getShareDeviceList];
    [self cteateNavBtn];
    //设置头视图
    [self setupHeadView];
    [self createTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    if (self.searchController.active) {
        self.searchController.active = NO;
        [self.searchController.searchBar removeFromSuperview];
    }
}

//==========================init==========================
#pragma mark ------创建头部视图
- (void)setupHeadView{
    [self.view addSubview:self.headView];
    self.headView.backgroundColor = [UIColor yellowColor];
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, headViewHeight));
    }];
    //设置搜索框
    [self setupSearchBar];
    //设置添加手机联系人页面
    [self setupPhoneView];
}

#pragma mark ------创建tableview
// 创建tableView
-(void)createTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, headViewHeight, self.view.width, self.view.height-124-64) style:UITableViewStylePlain];
    //设置代理
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = BG_COLOR;
    UIView *footView = [[UIView alloc]init];
    self.tableView.tableFooterView = footView;
    
    [self.view addSubview:self.tableView];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getShareDeviceList)];
    [header beginRefreshing];
    self.tableView.mj_header = header;
    
}

-(void)setupRefreshControl{
    self.sunnyRefreshControl = [YALSunnyRefreshControl attachToScrollView:self.tableView
                                                                   target:self
                                                            refreshAction:@selector(sunnyControlDidStartAnimation)];
    
}

//设置搜索框
- (void)setupSearchBar
{
    //创建searchBar
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, iPhoneWidth, 44)];
    //默认提示文字
    searchBar.placeholder = @"输入设备名称";

    //代理
    searchBar.delegate = self;
    //光标颜色
    searchBar.tintColor = MAIN_COLOR;
    //拿到searchBar的输入框
    UITextField *searchTextField = [searchBar valueForKey:@"_searchField"];
    
    //字体大小
    searchTextField.font = [UIFont systemFontOfSize:15];
    
    //输入框取消的圆圈按钮（系统自带）
    searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    //拿到取消按钮
    UIButton *cancleBtn = [searchBar valueForKey:@"cancelButton"];
    //设置按钮上的文字
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    //设置按钮上文字的颜色
    [cancleBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    self.searchBar = searchBar;
    [self.headView addSubview:self.searchBar];
}

//设置添加手机联系人页面
- (void)setupPhoneView{
    UIView * topView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, iPhoneWidth, 80)];
    topView.backgroundColor = [UIColor whiteColor];
    
    UIButton * addBtn = [FactoryUI createButtonWithFrame:CGRectMake(iPhoneWidth/2-8, 13, 16, 28) title:nil titleColor:nil imageName:@"iphone" backgroundImageName:nil target:self selector:@selector(addContacts)];
    [topView addSubview:addBtn];
    UILabel * label = [FactoryUI createLabelWithFrame:CGRectMake(iPhoneWidth/2-100, 50, 200, 12) text:@"添加手机联系人"  font:[UIFont systemFontOfSize:13]];
    label.textColor = [UIColor colorWithHexString:@"848484"];
    label.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:label];
    
    [self.headView addSubview:topView];
}


//==========================method==========================
- (void)getShareDeviceList{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:_dev_id forKey:@"dev_id"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/device/share/device-shared-info" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            [self.dataArr removeAllObjects];
            shared *listModel = [shared mj_objectWithKeyValues:responseObject[@"body"]];
            self.dataArr = [NSMutableArray arrayWithArray:listModel.user_list];
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }
        else{
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }
        
    } failure:^(NSError * _Nonnull error) {
        [self.tableView.mj_header endRefreshing];
    }];
    
}

-(void)sunnyControlDidStartAnimation{
    [self performSelector:@selector(getShareDeviceList) withObject:nil afterDelay:2];
}
//结束下拉刷新
-(IBAction)endAnimationHandle{
    [self.sunnyRefreshControl endRefreshing];
}
//上拉刷新响应
- (void)loadMoreData
{
    [self performSelector:@selector(endUpRefresh) withObject:nil afterDelay:2];
}
- (void)endUpRefresh
{
    [self.tableView.mj_footer endRefreshing];
}

//取消分享
- (void)cancleShareDevice{
    NSMutableDictionary * guardDic = [NSMutableDictionary dictionary];
    [guardDic setObject:_dev_id forKey:@"dev_id"];
    [guardDic setObject:_user_id forKey:@"shared_user"];
    
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/share/delete" parameters:guardDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"取消分享成功");
        int ret = [responseObject[@"ret"]intValue];
        NSLog(@"ret=%d",ret);
        if (ret == 0) {
            [self.dataArr removeObjectAtIndex:index];
            [self.tableView reloadData];
        }
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"取消分享失败");
    }];
}

- (void)addContacts{
    [self checkStatus2];
}

- (void)checkStatus2
{
    WeakSelf(self);
    [[SXAddressBookManager manager]checkStatusAndDoSomethingSuccess:^{
        
        NSLog(@"已经有权限，做相关操作，可以做读取通讯录等操作");
        [weakSelf openAddressPhone];
    } failure:^{
        
        NSLog(@"未得到权限，做相关操作，可以做弹窗询问等操作");
        
    }];
}
//打开通讯录
- (void)openAddressPhone
{
    [[SXAddressBookManager manager]presentPageOnTarget:self chooseAction:^(SXPersonInfoEntity *person) {
        NSLog(@"%@---%@",person.fullname,person.phoneNumber);
        NSString *nameStr = [NSString stringWithFormat:@"（%@）",person.fullname];
        //处理86号码
        self.iphoneNumberStr = [NSString formatPhoneNum:person.phoneNumber];
        NSString *newString = [NSString stringWithFormat:@"%@%@",self.iphoneNumberStr,nameStr];
        [self performSelector:@selector(openNewShareViewWithPhoneStr:) withObject:newString afterDelay:0.05];
    }];
}

- (void)openNewShareViewWithPhoneStr:(NSString *)newString
{
    UIImage *img = [UIImage scott_screenShot];
    UIImage *bufferIma = [UIImage scott_blurImage:img blur:0.4];
    WeiCloudShareView *customActionSheet = [WeiCloudShareView viewFromXib];
    customActionSheet.shareDelegate = self;
    customActionSheet.fied_phone.text = newString;
    ScottAlertViewController *alertController = [ScottAlertViewController alertControllerWithAlertView:customActionSheet preferredStyle:ScottAlertControllerStyleAlert transitionAnimationStyle:ScottAlertTransitionStyleFade];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:bufferIma];
    imgView.contentMode=UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds=YES;
    imgView.userInteractionEnabled = YES;
    alertController.backgroundView = imgView;
    alertController.tapBackgroundDismissEnable = YES;
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)pressBtn{
    //让用户给权限,没有的话会被拒的各位
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (error) {
                NSLog(@"weishouquan ");
            }else
            {
                NSLog(@"chenggong ");//用户给权限了
                CNContactPickerViewController * picker = [CNContactPickerViewController new];
                picker.delegate = self;
                picker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];//只显示手机号
                [self presentViewController: picker  animated:YES completion:nil];
            }
        }];
    }
    
    if (status == CNAuthorizationStatusAuthorized) {//有权限时
        CNContactPickerViewController * picker = [CNContactPickerViewController new];
        picker.delegate = self;
        picker.displayedPropertyKeys = @[CNContactPhoneNumbersKey];
        [self presentViewController: picker  animated:YES completion:nil];
    }
    else{
        NSLog(@"您未开启通讯录权限,请前往设置中心开启");
    }
    
}

//分享的网络请求
- (void)shareHttpFuncPhoneStr:(NSString *)phoneStr
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionary];
    [postDic setObject:_dev_id forKey:@"dev_id"];
    [postDic setObject:phoneStr forKey:@"to_mobile"];
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/share" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            [XHToast showCenterWithText:@"分享成功"];
        }
        else if (ret == 1102){
            [XHToast showCenterWithText:@"分享失败，您不是设备拥有者"];
        }
    } failure:^(NSError * _Nonnull error) {
        
    }];
}
//正则判断电话号正确格式
- (BOOL)validateMobile:(NSString *)mobile
{
    // 130-139  150-153,155-159  180-189  145,147  170,171,173,176,177,178
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0-9])|(14[57])|(17[013678]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

//==========================delegate==========================
//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

//分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.searchController.active) {
        return self.searchList.count;
    }
    return _dataArr.count;
}

//cell
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * str = @"Cell";
    ShareDetailCell_t * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [[ShareDetailCell_t alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    if (self.searchController.active) {
        NSDictionary * dic = [NSDictionary dictionaryWithDictionary:_searchList[indexPath.row]];
        _nameStr = [dic valueForKey:@"name"];
        _userID = [dic valueForKey:@"id"];
        cell.NameLabel.text = _nameStr;
        cell.idLabel.text = _userID;
    }else{
        NSDictionary * dic = [NSDictionary dictionaryWithDictionary:_dataArr[indexPath.row]];
        _nameStr = [dic valueForKey:@"name"];
        _userID = [dic valueForKey:@"id"];
        cell.NameLabel.text = _nameStr;
        cell.idLabel.text = _userID;
    }
    cell.delegete = self;
    
    cell.headImage.image = [UIImage imageNamed:@"img2"];
    return cell;
    
}

//cell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;

}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [Toast showInfo:@"搜索中..."];
    [self.searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;

}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
  
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //    NSString *inputStr = searchText;
    //    [self.results removeAllObjects];
    //    for (ElderModel *model in self.dataArray) {
    //        if ([model.name.lowercaseString rangeOfString:inputStr.lowercaseString].location != NSNotFound) {
    //            [self.results addObject:model];
    //        }
    //    }
    //    [self.tableView reloadData];
}


- (void)weiCloudShareBtnShareClick:(WeiCloudShareView *)shareView
{
    //1如果有通讯录电话号码
    if (self.iphoneNumberStr.length>0) {
        //如果电话号码合法
        if ([self validateMobile:self.iphoneNumberStr]) {
            [self shareHttpFuncPhoneStr:self.iphoneNumberStr];
            [self getShareDeviceList];
        }
        //如果选择通讯录后又重新输入号码合法
        else if ([self validateMobile:shareView.fied_phone.text]){
            [self shareHttpFuncPhoneStr:shareView.fied_phone.text];
        }
        else{
            [XHToast showCenterWithText:@"请输入正确的手机号码"];
        }
        self.iphoneNumberStr = nil;
    }else{
        //没有通讯录直接输入 如果输入的号码合法
        if ([self validateMobile:shareView.fied_phone.text]) {
            [self shareHttpFuncPhoneStr:shareView.fied_phone.text];
        }
        else{
            [XHToast showCenterWithText:@"请输入正确的手机号码"];
        }
    }
}


//==========================lazy loading==========================
#pragma mark ----- 懒加载部分
//头部视图懒加载
-(UIView *)headView{
    if (!_headView) {
        _headView = [[UIView alloc]init];
        _headView.backgroundColor = BG_COLOR;
    }
    return _headView;
}

#pragma mark ----- 懒加载
- (NSMutableString *)dev_id{
    if (!_dev_id) {
        _dev_id = [NSMutableString string];
    }
    return _dev_id;
}
- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
