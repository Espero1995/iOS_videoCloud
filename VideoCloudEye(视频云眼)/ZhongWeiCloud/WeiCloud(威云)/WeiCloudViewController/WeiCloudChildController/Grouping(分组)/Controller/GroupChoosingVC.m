//
//  GroupChoosingVC.m
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/8/22.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "GroupChoosingVC.h"
//========Model========
#import "WeiCloudListModel.h"
//========View========
/*无内容是显示视图*/
#import "GroupNoDevBGView.h"
/*cell的样式*/
#import "GroupChooseCell.h"
//========VC========
#import "ZCTabBarController.h"
#import "GroupNamedVC.h"
@interface GroupChoosingVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    GroupNoDevBGViewDelegate
>
@property (nonatomic, strong) UITableView *groupTableview;/**< 暂时设备的tableview */
@property (nonatomic,strong) NSMutableArray *myChooseDeviceArr;//选择的结果数据源
@property (nonatomic,strong) NSMutableArray *btnArr;//按钮选择状态的数组
@property (nonatomic,strong) GroupNoDevBGView *bgView;//无内容时背景图

@property (nonatomic,assign)BOOL bIsEncrypt;
@property (nonatomic, copy) NSString * key;
/*解码器*/
@property (nonatomic,assign)JW_CIPHER_CTX cipher;

@end

@implementation GroupChoosingVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setDefaultParameters];
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    [self getDeviceData];
}
//获取当前显示的数据源
- (void)getDeviceData
{
    if (_chooseWay == 3) {
        self.deviceArr = [unitl getCameraGroupDeviceModelIndex:self.groupIndex];
    }else
    {
        self.deviceArr = [NSMutableArray arrayWithArray:((deviceGroup *)[unitl getDefalutGroupDeviceModel]).dev_list];
    }
    if (self.deviceArr.count == 0) {
        [self.view addSubview:self.bgView];
    }else
    {
        [self.bgView removeFromSuperview];
    }
    //按钮的选择状态
    for (int i = 0; i<self.deviceArr.count; i++) {
        NSString * btnStr = [NSString stringWithFormat:@"NO"];
        [self.btnArr addObject:btnStr];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//导航栏样式
- (void)setDefaultParameters
{
    if (self.chooseWay == 1) {//新添加组来添加设备
        self.navigationItem.title = NSLocalizedString(@"选择设备", nil);
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"下一步", nil) style:UIBarButtonItemStyleDone target:self action:@selector(nextStep)];
    }else if (self.chooseWay == 2){//有组后添加设备
        self.navigationItem.title = NSLocalizedString(@"选择设备", nil);
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"完成了", nil) style:UIBarButtonItemStyleDone target:self action:@selector(completeClick)];
    }else if (self.chooseWay == 3){//有组后删除设备
        self.navigationItem.title = NSLocalizedString(@"移除设备", nil);
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"完成了", nil) style:UIBarButtonItemStyleDone target:self action:@selector(completeClick)];
    }

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backClick)];
}

- (void)createUI
{
    //表视图布局
    [self.view addSubview:self.groupTableview];
    [self.groupTableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight));
    }];
}

#pragma mark - method
- (void)completeClick
{
    if (self.myChooseDeviceArr.count == 0) {
        [XHToast showCenterWithText:NSLocalizedString(@"你还没有选择任何设备", nil)];
    }else{
        NSLog(@"%@",self.myChooseDeviceArr);
        if (self.chooseWay == 2) {
            [Toast showLoading:self.view Tips:NSLocalizedString(@"添加中...", nil)];
            [self addDevtoGroup];//添加设备到组中
        }else{
            [Toast showLoading:self.view Tips:NSLocalizedString(@"移除中...", nil)];
            [self removeDevfromGroup];//从组中移除设备
        }
    }
}

#pragma mark - 添加设备到组中
- (void)addDevtoGroup
{
    [self RemoveOrAddGroupDeviceRequestIsRemove:NO];
}

#pragma mark - 从组中移除设备
- (void)removeDevfromGroup
{
    [self RemoveOrAddGroupDeviceRequestIsRemove:YES];
}

//删除或添加组内设备的请求
- (void)RemoveOrAddGroupDeviceRequestIsRemove:(BOOL)isRemove
{
    /*
     GET v1/devicegroup/ update
     Content-Type: application/x-www-form-urlencoded
     请求参数：
     access_token=<令牌> & user_id =<用户ID>& group_id=< group_id 组id>& jsonStr=< >
     & ruler= <int新增还是删除（1代表新增，-1代表删除）>
     jsonStr : {"channels":{},"devcieIds":["100000000000074","100000000000034","100000000000035","100000000000036"]}
     */
    NSMutableDictionary * JsonDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableDictionary * tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSMutableArray * devIdsArr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < self.myChooseDeviceArr.count; i++) {
        [devIdsArr addObject:((dev_list *)self.myChooseDeviceArr[i]).ID];
    }
    [JsonDic setObject:tempDic forKey:@"channels"];
    [JsonDic setObject:devIdsArr forKey:@"devcieIds"];
    NSString * jsonStr = [unitl dictionaryToJSONString:JsonDic];
    
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    int rulerValue = isRemove ? -1 : 1;
    [postDic setObject:self.groupModel.groupID forKey:@"group_id"];
    [postDic setObject:[NSNumber numberWithInt:rulerValue] forKey:@"ruler"];
    [postDic setObject:jsonStr forKey:@"jsonStr"];
    [[HDNetworking sharedHDNetworking] GET:@"v1/devicegroup/update" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"组别里 删除或添加设备：%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            [self UpDateGroupInfoIsRemove:isRemove];
            //[[NSNotificationCenter defaultCenter]postNotificationName:GroupCreateOrDeleteSuccess_updateUI object:nil];
        }else{
            [XHToast showCenterWithText:NSLocalizedString(@"删除分组失败，请稍候再试", nil)];
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"失败了");
        [XHToast showCenterWithText:NSLocalizedString(@"删除分组失败，请检查您的网络", nil)];
    }];
}
#pragma mark ==== 删除或添加设备之后更新设备列表。
- (void)UpDateGroupInfoIsRemove:(BOOL)isRemove
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSNumber *languageType;
    if (isSimplifiedChinese) {
        languageType = [NSNumber numberWithInt:1];
    }else{
        languageType = [NSNumber numberWithInt:2];
    }
    [dic setObject:languageType forKey:@"languageType"];
    [[HDNetworking sharedHDNetworking]GET:@"v1/devicegroup/listGroup" parameters:dic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
//        NSLog(@"查询分组信息:%@",responseObject);
        if (ret == 0) {
            WeiCloudListModel *listModel = [WeiCloudListModel mj_objectWithKeyValues:responseObject[@"body"]];
            
            NSInteger groupCount = listModel.deviceGroup.count;
            //保存组别中的组名和ID
            NSMutableArray * tempGroupArr = [NSMutableArray arrayWithCapacity:0];
            for (int i = 0; i < groupCount; i++) {
                NSMutableDictionary * tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
                [tempDic setObject:listModel.deviceGroup[i].groupName forKey:@"groupName"];
                [tempDic setObject:listModel.deviceGroup[i].groupId forKey:@"groupID"];
                [tempGroupArr addObject:tempDic];
            }
            NSString * GroupNameAndIDArr_KeyStr = [unitl getKeyWithSuffix:[unitl get_User_id] Key:GroupNameAndIDArr_key];
            [unitl saveDataWithKey:GroupNameAndIDArr_KeyStr Data:tempGroupArr];
            [unitl saveAllGroupCameraModel:[NSMutableArray arrayWithArray:listModel.deviceGroup]];
            
            [unitl saveCurrentDisplayGroupIndex:0];
            
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                [Toast dissmiss];
                [self.navigationController popViewControllerAnimated:YES];
                isRemove ? [XHToast showCenterWithText:NSLocalizedString(@"移除成功", nil)] : [XHToast showCenterWithText:NSLocalizedString(@"添加成功", nil)];
            });
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"查询分组 网络正在开小差...");
    }];
}


//下一步
- (void)nextStep
{
    GroupNamedVC * nameGroup = [[GroupNamedVC alloc]init];
    NSMutableArray * tempDeiceIds = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < self.myChooseDeviceArr.count; i++) {
        dev_list * model = (dev_list *)self.myChooseDeviceArr[i];
        [tempDeiceIds addObject:model.ID];
    }
    nameGroup.deviceIdsArr = tempDeiceIds;
    nameGroup.chansArr = nil;
    [self.navigationController pushViewController:nameGroup animated:YES];
}

//返回
- (void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
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

//=========================delegate=========================
#pragma mark - tableViewDelegate
//组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceArr.count;
}
//每行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

//每行的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger row = indexPath.row;
    
    static NSString *GroupChooseCell_Identifier = @"GroupChooseCell_Identifier";
    GroupChooseCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupChooseCell_Identifier];
    if(cell == nil){
        cell = [[GroupChooseCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GroupChooseCell_Identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    dev_list *dev_Model = self.deviceArr[indexPath.row];
    cell.deviceNameLb.text = dev_Model.name;
    
    self.bIsEncrypt = dev_Model.enable_sec;
    self.key = dev_Model.dev_p_code;
    NSMutableDictionary * changeDic = [NSMutableDictionary dictionary];
    [changeDic setObject:dev_Model.ID forKey:@"dev_id"];
    [changeDic setObject:@"1" forKey:@"chan_id"];
    
    NSString * imageName =  [cell.deviceImage.image accessibilityIdentifier];
    if (cell.deviceImage.image == nil || [imageName isEqualToString:@"img1"]) {
        cell.deviceImage.image = [UIImage imageNamed:@"img1"];
    }
    
    /*
    [[HDNetworking sharedHDNetworking]POST:@"v1/device/capture" parameters:changeDic IsToken:YES success:^(id  _Nonnull responseObject) {
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            [cell.deviceImage setImage:[self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:dev_Model.ID]];
            NSDictionary * dic = responseObject[@"body"];
            NSString * urlStr = [dic objectForKey:@"pic_url"];
            NSURL * picUrl = [NSURL URLWithString:urlStr];
            if (self.bIsEncrypt) {
                NSURLRequest *request = [NSURLRequest requestWithURL:picUrl];
                __block UIImage * image;
                [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                    const unsigned char *imageCharData=(const unsigned char*)[data bytes];
                    size_t len = [data length];
                    unsigned char outImageCharData[len];
                    size_t outLen = len;
                    if (len %16 == 0 && [((NSHTTPURLResponse *)response) statusCode] == 200) {
                        int decrptImageSucceed = jw_cipher_decrypt(self.cipher,imageCharData,len,outImageCharData, &outLen);
                        if (decrptImageSucceed == 1) {
                            NSData *imageData = [[NSData alloc]initWithBytes:outImageCharData length:outLen];
                            image  = [UIImage imageWithData:imageData];
                            if (image) {
                                cell.deviceImage.image = image;
                            }else{
                                dispatch_async(dispatch_get_main_queue(),^{
                                    UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:dev_Model.ID];
                                        cell.deviceImage.image = cutIma?cutIma:[UIImage imageNamed:@"img1"];
                                });
                            }
                        }else{
                            dispatch_async(dispatch_get_main_queue(),^{
                                UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:dev_Model.ID];
                                cell.deviceImage.image = cutIma?cutIma:[UIImage imageNamed:@"img1"];
                            });
                        }
                    }else{
                        dispatch_async(dispatch_get_main_queue(),^{
                            UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:dev_Model.ID];
                            cell.deviceImage.image = cutIma?cutIma:[UIImage imageNamed:@"img1"];
                        });
                    }
                }];
            }else{
                UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:dev_Model.ID];
                if (cutIma) {
                    [cell.deviceImage sd_setImageWithURL:picUrl placeholderImage:cutIma];
                }else{
                    [cell.deviceImage sd_setImageWithURL:picUrl placeholderImage:[UIImage imageNamed:@"img1"]];
                }
            }
        }else{
               dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:dev_Model.ID];
                if (cutIma) {
                    cell.deviceImage.image = cutIma;
                }else{
                    cell.deviceImage.image = [UIImage imageNamed:@"img1"];
                }
            });
        }
    } failure:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:dev_Model.ID];
            if (cutIma) {
                cell.deviceImage.image = cutIma;
            }else{
                cell.deviceImage.image = [UIImage imageNamed:@"img1"];
            }
        });
    }];
    */

    if ([self.btnArr[row] isEqualToString:@"YES"]) {
        cell.chooseBtn.selected = YES;
    }else{
        cell.chooseBtn.selected = NO;
    }
    
    return cell;
}
//每一行的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    
    GroupChooseCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.chooseBtn.selected == NO) {
        cell.chooseBtn.selected = YES;
        [self.myChooseDeviceArr addObject:self.deviceArr[indexPath.row]];
        self.navigationItem.title = [NSString stringWithFormat:@"%@(%lu)",NSLocalizedString(@"选择设备", nil),(unsigned long)self.myChooseDeviceArr.count];
    }else{
        cell.chooseBtn.selected = NO;
        [self.myChooseDeviceArr removeObject:self.deviceArr[indexPath.row]];
        if (self.myChooseDeviceArr.count == 0) {
            self.navigationItem.title = NSLocalizedString(@"选择设备", nil);
        }else{
            self.navigationItem.title = [NSString stringWithFormat:@"%@(%lu)",NSLocalizedString(@"选择设备", nil),(unsigned long)self.myChooseDeviceArr.count];
        }
    }
    
    if ([self.btnArr[row] isEqualToString:@"NO"]) {
        NSString * btnStr = [NSString stringWithFormat:@"YES"];
        [self.btnArr replaceObjectAtIndex:row withObject:btnStr];
    }else{
        NSString * btnStr = [NSString stringWithFormat:@"NO"];
        [self.btnArr replaceObjectAtIndex:row withObject:btnStr];
    }
}
#pragma mark - 无设备时点击商城的代理方法
- (void)shopBtnClick
{
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
    tabVC.tabLastSelectedIndex = 0;
    tabVC.selectedIndex = 2;
    tabVC.tabSelectIndex = 2;
}
#pragma mark ======  getter && setter
//表视图懒加载
-(UITableView *)groupTableview{
    if (!_groupTableview) {
        _groupTableview = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _groupTableview.delegate=self;
        _groupTableview.dataSource=self;
        _groupTableview.backgroundColor = BG_COLOR;
        _groupTableview.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return _groupTableview;
}


//选择的结果数据源
- (NSMutableArray *)myChooseDeviceArr
{
    if (!_myChooseDeviceArr) {
        _myChooseDeviceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _myChooseDeviceArr;
}

//无内容时的背景图
-(GroupNoDevBGView *)bgView{
    if (!_bgView) {
        _bgView = [[GroupNoDevBGView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight) bgColor:BG_COLOR bgImg:[UIImage imageNamed:@"groupNoDevice"] bgTip:NSLocalizedString(@"你还没有设备可选择", nil)];
    }
    _bgView.delegate = self;
    return _bgView;
}
//按钮选择状态的数组
- (NSMutableArray *)btnArr
{
    if (!_btnArr) {
        _btnArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _btnArr;
}

- (void)dealloc
{
    jw_cipher_release(_cipher);
}
/*解码器*/
- (JW_CIPHER_CTX)cipher
{
    if (_cipher == nil) {
        if (self.key && self.bIsEncrypt) {
            size_t len = strlen([self.key cStringUsingEncoding:NSASCIIStringEncoding]);
            _cipher =  jw_cipher_create((const unsigned char*)[self.key cStringUsingEncoding:NSASCIIStringEncoding], len);
            NSLog(@"创建cipher：%p",&_cipher);
        }
    }
    return _cipher;
}

@end
