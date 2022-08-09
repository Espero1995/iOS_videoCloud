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

#define WEIClOUDCELLT @"smallScreenChannelCell"

@interface SearchVideoVC ()
<
    UISearchBarDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
    smallScreenChannelCellDelegate
>

/*搜索框*/
@property (nonatomic,strong) customSearchBar *searchBar;
/*表视图*/
@property (nonatomic,strong) UITableView *tv_list;
/*提示信息*/
@property (nonatomic,strong) UILabel *tipTitleLb;
/*所有的数据模型*/
@property (nonatomic,strong)NSMutableArray * dataArr;
/*用来提供搜索的名字arr*/
@property (nonatomic,strong)NSMutableArray * nameDataArr;
/*搜索结果arr*/
@property (nonatomic,strong)NSMutableArray * searchResults;
/*搜索结果arr到全部数组中找到展示的model*/
@property (nonatomic,strong)NSMutableArray * showResultsArr;
/*搜索结果arr到全部数组中找到展示的model   和showResultsArr一样的内容，但是show要清空，所以点击的时候，用这个。*/
@property (nonatomic,strong)NSMutableArray * didSeleshowResultsArr;
///*是否在搜索中*/
//@property (nonatomic,assign)BOOL isSearch;
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
//    [self getAllVideoListData];
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
- (void)dealloc
{
    jw_cipher_release(_cipher);
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
    
    
    
//    self.dataArr = [unitl getAllDeviceCameraModel];
//    for (dev_list *model in self.dataArr) {
//        [self.nameDataArr addObject:model.name];
//    }
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
//    if (self.isSearch) {
//        if (self.showResultsArr.count == 0){
//            return 0;
//        }else{
//            return self.showResultsArr.count;
//        }
//    }else{
        return self.dataArr.count;
//    }
    
    /*
    if (self.showResultsArr.count == 0) {
        return self.dataArr.count;
    }else{
        return self.showResultsArr.count;
    }*/
    //self.dataArr.count / self.showResultsArr.count
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
  
//    if (self.isSearch) {//搜索时的数据源
//        DeviceSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:WEIClOUDCELLT];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        if (self.showResultsArr.count != 0 && self.showResultsArr.count > indexPath.row) {
//            dev_list *listModel = self.showResultsArr[indexPath.row];
//            cell.model = listModel;
//            self.bIsEncrypt = listModel.enable_sec;
//            self.key = listModel.dev_p_code;
//
//            NSMutableDictionary * changeDic = [NSMutableDictionary dictionary];
//            [changeDic setObject:listModel.ID forKey:@"dev_id"];
//            [changeDic setObject:@"1" forKey:@"chan_id"];
//            /*
//            if (listModel.status == 1) {
//                [[HDNetworking sharedHDNetworking]POST:@"v1/device/capture" parameters:changeDic IsToken:YES success:^(id  _Nonnull responseObject) {
//                    int ret = [responseObject[@"ret"]intValue];
//                    if (ret == 0) {
//                        [cell.ima_photo setImage:[self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID]];
//                        NSDictionary * dic = responseObject[@"body"];
//                        NSString * urlStr = [dic objectForKey:@"pic_url"];
//                        NSURL * picUrl = [NSURL URLWithString:urlStr];
//                        //                    NSLog(@"图片的URL：%@",dic);
//                        if (self.bIsEncrypt) {
//                            NSURLRequest *request = [NSURLRequest requestWithURL:picUrl];
//                            __block UIImage * image;
//
//                            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
//                                const unsigned char *imageCharData=(const unsigned char*)[data bytes];
//                                size_t len = [data length];
//
//                                unsigned char outImageCharData[len];
//                                size_t outLen = len;
//
//                                if (len %16 == 0 && [((NSHTTPURLResponse *)response) statusCode] == 200) {
//                                    int decrptImageSucceed = jw_cipher_decrypt(self.cipher,imageCharData,len,outImageCharData, &outLen);
//                                    if (decrptImageSucceed == 1) {
//                                        NSData *imageData = [[NSData alloc]initWithBytes:outImageCharData length:outLen];
//                                        image  = [UIImage imageWithData:imageData];
//                                        if (image) {
//                                            cell.ima_photo.image = image;
//                                        }else{
//                                            dispatch_async(dispatch_get_main_queue(),^{
//                                                UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
//                                                cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img2"];
//                                            });
//                                        }
//                                    }else{
//                                        dispatch_async(dispatch_get_main_queue(),^{
//                                            UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
//                                            cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img2"];
//                                        });
//                                    }
//                                }else{
//                                    dispatch_async(dispatch_get_main_queue(),^{
//                                        UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
//                                        cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img2"];
//                                    });
//                                }
//                            }];
//                        }else{
//                            UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
//
//
//                            if (cutIma) {
//                                [cell.ima_photo sd_setImageWithURL:picUrl placeholderImage:cutIma];
//                            }else{
//                                [cell.ima_photo sd_setImageWithURL:picUrl placeholderImage:[UIImage imageNamed:@"img2"]];
//                            }
//                        }
//
//                    }else{
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
//                            if (cutIma) {
//                                cell.ima_photo.image = cutIma;
//                            }else{
//                                cell.ima_photo.image = [UIImage imageNamed:@"img2"];
//                            }
//                        });
//                    }
//                } failure:^(NSError * _Nonnull error) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
//                        if (cutIma) {
//                            cell.ima_photo.image = cutIma;
//                        }else{
//                            cell.ima_photo.image = [UIImage imageNamed:@"img2"];
//                        }
//                    });
//                }];
//            }
//            */
//        }
//
//        return cell;
//
//    }else{//未搜索时的数据源
//        DeviceSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:WEIClOUDCELLT];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        dev_list *listModel = self.dataArr[indexPath.row];
//        cell.model = listModel;
//        self.bIsEncrypt = listModel.enable_sec;
//        self.key = listModel.dev_p_code;
//        NSMutableDictionary * changeDic = [NSMutableDictionary dictionary];
//        [changeDic setObject:listModel.ID forKey:@"dev_id"];
//        [changeDic setObject:@"1" forKey:@"chan_id"];
//        /*
//        if (listModel.status == 1) {
//            [[HDNetworking sharedHDNetworking]POST:@"v1/device/capture" parameters:changeDic IsToken:YES success:^(id  _Nonnull responseObject) {
//                int ret = [responseObject[@"ret"]intValue];
//                if (ret == 0) {
//                    [cell.ima_photo setImage:[self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID]];
//                    NSDictionary * dic = responseObject[@"body"];
//                    NSString * urlStr = [dic objectForKey:@"pic_url"];
//                    NSURL * picUrl = [NSURL URLWithString:urlStr];
//                    if (self.bIsEncrypt) {
//                        NSURLRequest *request = [NSURLRequest requestWithURL:picUrl];
//                        __block UIImage * image;
//
//                        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
//                            const unsigned char *imageCharData=(const unsigned char*)[data bytes];
//                            size_t len = [data length];
//
//                            unsigned char outImageCharData[len];
//                            size_t outLen = len;
//
//                            if (len %16 == 0 && [((NSHTTPURLResponse *)response) statusCode] == 200) {
//                                int decrptImageSucceed = jw_cipher_decrypt(self.cipher,imageCharData,len,outImageCharData, &outLen);
//                                if (decrptImageSucceed == 1) {
//                                    NSData *imageData = [[NSData alloc]initWithBytes:outImageCharData length:outLen];
//                                    image  = [UIImage imageWithData:imageData];
//                                    if (image) {
//                                        cell.ima_photo.image = image;
//                                    }else{
//                                        dispatch_async(dispatch_get_main_queue(),^{
//                                            UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
//                                            cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img2"];
//                                        });
//                                    }
//                                }else{
//                                    dispatch_async(dispatch_get_main_queue(),^{
//                                        UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
//                                        cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img2"];
//                                    });
//                                }
//                            }else{
//                                dispatch_async(dispatch_get_main_queue(),^{
//                                    UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
//                                    cell.ima_photo.image = cutIma?cutIma:[UIImage imageNamed:@"img2"];
//                                });
//                            }
//                        }];
//                    }else{
//                        UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
//
//                        if (cutIma) {
//                            [cell.ima_photo sd_setImageWithURL:picUrl placeholderImage:cutIma];
//                        }else{
//                            [cell.ima_photo sd_setImageWithURL:picUrl placeholderImage:[UIImage imageNamed:@"img2"]];
//                        }
//                    }
//
//                }else{
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
//                        if (cutIma) {
//                            cell.ima_photo.image = cutIma;
//                        }else{
//                            cell.ima_photo.image = [UIImage imageNamed:@"img2"];
//                        }
//                    });
//                }
//            } failure:^(NSError * _Nonnull error) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    UIImage *cutIma = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:listModel.ID];
//                    if (cutIma) {
//                        cell.ima_photo.image = cutIma;
//                    }else{
//                        cell.ima_photo.image = [UIImage imageNamed:@"img2"];
//                    }
//                });
//            }];
//        }
//        */
//        return cell;
//    }
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
    
//    if (self.isSearch){//搜索时的数据源
//        dev_list *listModel = self.didSeleshowResultsArr[indexPath.row];
//
//        self.tabBarController.tabBar.hidden=YES;
//        RealTimeVideoVC * realTimeVC = [[RealTimeVideoVC alloc]init];
//        realTimeVC.listModel = listModel;
//        realTimeVC.chan_size = listModel.chan_size;
//        realTimeVC.chan_alias = listModel.chan_alias;
//        realTimeVC.bIsEncrypt = listModel.enable_sec;
//        realTimeVC.key = listModel.dev_p_code;
//        realTimeVC.selectedIndex = indexPath;
//        realTimeVC.dev_id = listModel.ID;
//        DeviceSearchCell *cell = [self.tv_list cellForRowAtIndexPath:indexPath];
//        realTimeVC.titleName = cell.lab_name.text;
//        //通过通道数目来判别是否是多通道【注：=0的判断是为了防止后台在搭建新的环境时，未设置通道数目字段】
//        //此外还需判断listModel的chans属性的count来兼容老版本的多通道
//        if (listModel.chans.count<=1 && listModel.chanCount <= 1) {
//            realTimeVC.isMultiChannel = NO;
//        }else{
//            realTimeVC.isMultiChannel = YES;
//        }
//
//        [unitl saveDataWithKey:SCREENSTATUS Data:SHU_PING];
//        [self.navigationController pushViewController:realTimeVC animated:YES];
//
//
//
//        /*
//        if (listModel.chan_size==1) {
//
//            //单屏
//            self.tabBarController.tabBar.hidden=YES;
//            RealTimeVideoVC * realTimeVC = [[RealTimeVideoVC alloc]init];
//            realTimeVC.listModel = listModel;
//            realTimeVC.chan_size = listModel.chan_size;
//            realTimeVC.chan_alias = listModel.chan_alias;
//            realTimeVC.bIsEncrypt = listModel.enable_sec;
//            realTimeVC.key = listModel.dev_p_code;
//            realTimeVC.selectedIndex = indexPath;
//            DeviceSearchCell *cell = [self.tv_list cellForRowAtIndexPath:indexPath];
//            realTimeVC.titleName = cell.lab_name.text;
//            [self.navigationController pushViewController:realTimeVC animated:YES];
//
//        }else{
//            //四分屏
//            self.tabBarController.tabBar.hidden=YES;
//            MonitoringVCnew * monitorVC = [[MonitoringVCnew alloc]init];
//            monitorVC.listModel = listModel;
//            monitorVC.chan_size = listModel.chan_size;
//            monitorVC.chan_alias = listModel.chan_alias;
//            monitorVC.bIsEncrypt = listModel.enable_sec;
//            monitorVC.key = listModel.dev_p_code;
//            monitorVC.selectedIndex = indexPath;
//            DeviceSearchCell *cell = [self.tv_list cellForRowAtIndexPath:indexPath];
//            monitorVC.titleName = cell.lab_name.text;
//            [self.navigationController pushViewController:monitorVC animated:YES];
//        }
//        */
//    }else{//未搜索时的数据源
//        dev_list *listModel = self.dataArr[indexPath.row];
//        self.tabBarController.tabBar.hidden=YES;
//        RealTimeVideoVC * realTimeVC = [[RealTimeVideoVC alloc]init];
//        realTimeVC.listModel = listModel;
//        realTimeVC.chan_size = listModel.chan_size;
//        realTimeVC.chan_alias = listModel.chan_alias;
//        realTimeVC.bIsEncrypt = listModel.enable_sec;
//        realTimeVC.key = listModel.dev_p_code;
//        realTimeVC.selectedIndex = indexPath;
//        realTimeVC.dev_id = listModel.ID;
//        DeviceSearchCell *cell = [self.tv_list cellForRowAtIndexPath:indexPath];
//        realTimeVC.titleName = cell.lab_name.text;
//        //通过通道数目来判别是否是多通道【注：=0的判断是为了防止后台在搭建新的环境时，未设置通道数目字段】
//        //此外还需判断listModel的chans属性的count来兼容老版本的多通道
//        if (listModel.chans.count<=1 && listModel.chanCount <= 1) {
//            realTimeVC.isMultiChannel = NO;
//        }else{
//            realTimeVC.isMultiChannel = YES;
//        }
//
//        [unitl saveDataWithKey:SCREENSTATUS Data:SHU_PING];
//        [self.navigationController pushViewController:realTimeVC animated:YES];
//
//
//    }
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
    [self loadSearchDataWithKey:searchBar.text];
    [self.searchBar resignFirstResponder];
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
    [self loadSearchDataWithKey:searchBar.text];
}

//- (void)filterBySubstring:(NSString*) subStr
//{
//
//    [self.showResultsArr removeAllObjects];//每次搜索时需要清空该数组
//
//    if (self.searchBar.text.length>0&&![ChineseInclude isIncludeChineseInString:self.searchBar.text]) {
//
//        for (int i=0; i<self.nameDataArr.count; i++) {
//            if ([ChineseInclude isIncludeChineseInString:self.nameDataArr[i]]) {
//                NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:self.nameDataArr[i]];
//                NSRange titleResult=[tempPinYinStr rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
//                if (titleResult.length>0) {
//                    [self.searchResults addObject:self.nameDataArr[i]];
//                    [self.showResultsArr addObject:self.dataArr[i]];//新加
//                }
//
//            }
//            else {
//                NSRange titleResult=[self.nameDataArr[i] rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
//                if (titleResult.length>0) {
//                    [self.searchResults addObject:self.nameDataArr[i]];
//                    [self.showResultsArr addObject:self.dataArr[i]];//新加
//                }
//            }
//        }
//
//
//    } else if (self.searchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:self.searchBar.text]) {
//
//        for (int i = 0; i < self.nameDataArr.count; i++) {
//            NSString *tempStr = self.nameDataArr[i];
//            NSRange titleResult=[tempStr rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];
//            if (titleResult.length>0) {
//                [self.searchResults addObject:tempStr];
//                 [self.showResultsArr addObject:self.dataArr[i]];//新加
//            }
//        }
//
//    }
//
//    NSLog(@"搜索结果self.searchResults:%@",self.searchResults);
//    if (self.searchResults.count >0) {
//
//        [self.searchResults removeAllObjects];
//
//        self.didSeleshowResultsArr = [self.showResultsArr mutableCopy];
//        NSLog(@"显示结果showResultsArr:%@",self.showResultsArr);
//        [self.tv_list reloadData];
//    }else{
//        if (subStr.length == 0) {
//            self.isSearch = NO;
//            [self.showResultsArr removeAllObjects];
//            [self.tv_list reloadData];
//        }else{
//             [self.tv_list reloadData];
//        }
//
//    }
//}

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
- (NSMutableArray *)nameDataArr
{
    if (!_nameDataArr) {
        _nameDataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _nameDataArr;
}
- (NSMutableArray *)searchResults
{
    if (!_searchResults) {
        _searchResults = [NSMutableArray arrayWithCapacity:0];
    }
    return _searchResults;
}
- (NSMutableArray *)showResultsArr
{
    if (!_showResultsArr) {
        _showResultsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _showResultsArr;
}
- (NSMutableArray *)didSeleshowResultsArr
{
    if (!_didSeleshowResultsArr) {
        _didSeleshowResultsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _didSeleshowResultsArr;
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
