//
//  DeviceSortingVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/9.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "DeviceSortingVC.h"
//========Model========
#import "WeiCloudListModel.h"
//========View========
#import "DeviceSortCell.h"
//========VC========
#import "ZCTabBarController.h"

#define WEIClOUDCELLT @"DeviceSortCell"
@interface DeviceSortingVC ()
<
    UITableViewDelegate,
    UITableViewDataSource
>

/*表视图*/
@property (nonatomic,strong) UITableView *tv_list;
/*所有的数据模型*/
@property (nonatomic,strong)NSMutableArray * dataArr;
/*是否加密*/
@property (nonatomic,assign)BOOL bIsEncrypt;
/*加密的key*/
@property (nonatomic,copy)NSString * key;
/*解码器*/
@property (nonatomic,assign)JW_CIPHER_CTX cipher;
@end

@implementation DeviceSortingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"编辑顺序", nil);
    self.view.backgroundColor = BG_COLOR;
//    self.dataArr = (NSMutableArray *) [unitl getCameraModel];
    self.dataArr = [((deviceGroup *)[unitl getCameraGroupModelIndex:[unitl getCurrentDisplayGroupIndex]]).dev_list mutableCopy];
    
//    NSString * userIDStr = [unitl get_User_id];
//    NSString * saveVideoListKey = [unitl getKeyWithSuffix:AFTERSORTVIDEOLISTARR Key:userIDStr];
//    NSData * SaveListData = [[NSUserDefaults standardUserDefaults]objectForKey:saveVideoListKey];
//    NSMutableArray * videoListArr = [NSKeyedUnarchiver unarchiveObjectWithData:SaveListData];
//    
//    self.dataArr = [self sortWithAlreadyHaveOrderNetworkData:self.dataArr OrderlyData:videoListArr];
    
    
    [self setButtonitem];
    [self setUpUI];
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
}

//=========================init=========================
#pragma mark ------设置导航栏按钮和响应事件
- (void)setButtonitem{
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 40, 15)];
    [backBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backBtn.highlighted = YES;
    backBtn.userInteractionEnabled = YES;
    [backBtn addTarget:self action:@selector(cancelEditClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    UIBarButtonItem * leftSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    self.navigationItem.leftBarButtonItems = @[leftSpace,leftItem];
    UIButton *completeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [completeBtn setTitle:NSLocalizedString(@"保存", nil) forState:UIControlStateNormal];
    [completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [completeBtn addTarget:self action:@selector(completeClick) forControlEvents:UIControlEventTouchUpInside];
    completeBtn.highlighted = YES;
    completeBtn.userInteractionEnabled = YES;
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:completeBtn];
    UIBarButtonItem * rightSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    rightSpace.width = -10;
    self.navigationItem.rightBarButtonItems = @[rightItem,rightSpace];
}

-(void)setUpUI
{
    //表视图布局
    [self.view addSubview:self.tv_list];
    BOOL flag = !_tv_list.editing;
    [_tv_list setEditing:flag animated:YES];
}

//=========================method=========================
//取消返回
- (void)cancelEditClick
{
    CATransition *transition = [unitl pushAnimationWith:0 fromController:self];
    transition.delegate = (id)self.navigationController;
    transition.duration = 0.6f;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
//确定按钮
- (void)completeClick
{
//    NSData * videoListData = [NSKeyedArchiver archivedDataWithRootObject:self.dataArr];
//    NSString * userIDStr = [unitl get_User_id];
//    NSString * saveVideoListKey = [unitl getKeyWithSuffix:AFTERSORTVIDEOLISTARR Key:userIDStr];
//    [[NSUserDefaults standardUserDefaults]setObject:videoListData forKey:saveVideoListKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSMutableArray * tempVideoListModelArr_ALL = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i<self.dataArr.count; i++) {
        [tempVideoListModelArr_ALL addObject:self.dataArr[i]];
    }
//    [unitl saveCameraModel:tempVideoListModelArr_ALL];
    
    [unitl saveCameraGroupDeviceModelData:tempVideoListModelArr_ALL Index:[unitl getCurrentDisplayGroupIndex]];
//    + (void)saveCameraGroupDeviceModelData:(NSMutableArray *)GroupDevModel Index:(NSInteger)index
    
    
    
    
    
    //更新设备排序
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATESORT object:nil userInfo:nil];
    
    CATransition *transition = [unitl pushAnimationWith:0 fromController:self];
    transition.delegate = (id)self.navigationController;
    transition.duration = 0.6f;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
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

#pragma mark - 网络获取的视频列表【未排序】和本地【已经拍排序列表】进行排序操作
- (NSMutableArray * )sortWithAlreadyHaveOrderNetworkData:(NSMutableArray *)netData OrderlyData:(NSMutableArray *)orderlydata
{
    NSMutableArray * NetArr = [netData mutableCopy];
    NSMutableArray * orderlyArr = [orderlydata mutableCopy];
    NSMutableArray * tempReturnArr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < orderlyArr.count; i++) {
        for (int j = 0; j < NetArr.count ; j++) {
            NSString * netModelID = ((dev_list *)NetArr[j]).ID;
            NSString * orderlyModelID = ((dev_list *)orderlyArr[i]).ID;
            if ([netModelID isEqualToString:orderlyModelID]) {
                //[tempReturnArr insertObject:NetArr[j] atIndex:i];//这种如果网络数据中有删除，则会空下这个删除的位置。
                [tempReturnArr addObject:NetArr[j]];
                [NetArr removeObjectAtIndex:j];
            }
        }
    }
    if (NetArr.count > 0) {
        [tempReturnArr addObjectsFromArray:NetArr];
    }
    //    NSLog(@"排序好的数组是：%@ 个数：%ld",tempReturnArr,tempReturnArr.count);
    return tempReturnArr;
}


//=========================delegate=========================
#pragma mark -----tableViewDelegate
//组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

//每行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (iPhoneWidth <=375) {
        return iPhoneWidth/3.5;
    }else{
        return iPhoneWidth/4;//倍率显示cell的高度
    }
}

//每行的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceSortCell *cell = [tableView dequeueReusableCellWithIdentifier:WEIClOUDCELLT];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    dev_list *listModel = self.dataArr[indexPath.row];
    cell.model = listModel;
    self.bIsEncrypt = listModel.enable_sec;
    self.key = listModel.dev_p_code;

    NSMutableDictionary * changeDic = [NSMutableDictionary dictionary];
    [changeDic setObject:listModel.ID forKey:@"dev_id"];
    [changeDic setObject:@"1" forKey:@"chan_id"];
    /*
    if (listModel.status == 1) {
        [[HDNetworking sharedHDNetworking]POST:@"v1/device/capture" parameters:changeDic IsToken:YES success:^(id  _Nonnull responseObject) {
            int ret = [responseObject[@"ret"]intValue];
            if (ret == 0) {
                [cell.ima_photo setImage:[self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID]];
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
                                    cell.ima_photo.image = image;
                                }else{
                                    dispatch_async(dispatch_get_main_queue(),^{
                                        UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                                        cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img2"];
                                    });
                                }
                            }else{
                                dispatch_async(dispatch_get_main_queue(),^{
                                    UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                                    cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img2"];
                                });
                            }
                        }else{
                            dispatch_async(dispatch_get_main_queue(),^{
                                UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                                cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img2"];
                            });
                        }
                    }];
                }else{
                    UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                    
                    
                    if (cutIma) {
                        [cell.ima_photo sd_setImageWithURL:picUrl placeholderImage:cutIma];
                    }else{
                        [cell.ima_photo sd_setImageWithURL:picUrl placeholderImage:[UIImage imageNamed:@"img2"]];
                    }
                }
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                    if (cutIma) {
                        cell.ima_photo.image = cutIma;
                    }else{
                        cell.ima_photo.image = [UIImage imageNamed:@"img2"];
                    }
                });
            }
        } failure:^(NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
                if (cutIma) {
                    cell.ima_photo.image = cutIma;
                }else{
                    cell.ima_photo.image = [UIImage imageNamed:@"img2"];
                }
            });
        }];
    }
    */
    
    return cell;
}


#pragma mark - 设置区头
//区头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

//区头视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 10)];
    backView.backgroundColor = BG_COLOR;
    return backView;
}


#pragma mark 选择编辑模式，添加模式很少用,默认是删除
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark 排序 当移动了某一行时候会调用
//编辑状态下，只要实现这个方法，就能实现拖动排序
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // 取出要拖动的模型数据
    dev_list *devModel = self.dataArr[sourceIndexPath.row];
    //删除之前行的数据
    [self.dataArr removeObject:devModel];
    // 插入数据到新的位置
    [self.dataArr insertObject:devModel atIndex:destinationIndexPath.row];
}


- (void)dealloc
{
    jw_cipher_release(_cipher);
}

#pragma mark - getter&&setter
//表视图懒加载
-(UITableView *)tv_list{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight) style:UITableViewStylePlain];
        _tv_list.delegate=self;
        _tv_list.dataSource=self;
        _tv_list.backgroundColor = BG_COLOR;
        _tv_list.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
        [_tv_list registerNib:[UINib nibWithNibName:@"DeviceSortCell" bundle:nil] forCellReuseIdentifier:WEIClOUDCELLT];
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return _tv_list;
}
//设备数据源
- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArr;
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
