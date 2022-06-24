//
//  TimePhotoAlbumVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/10/15.
//  Copyright © 2018 张策. All rights reserved.
//
#define TIMEPHOTOALBUMCELL @"TimePhotoAlbumCell"
#import "TimePhotoAlbumVC.h"
#import "UIImage+GIF.h"
//========Model========
//腾讯API
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
//微信
#import "WXApi.h"
#import "UIImageView+PlayGIF.h"
#import "TimePhotoAlbumModel.h"
#import "FileModel.h"
//========View========
#import "TimePhotoAlbumCell.h"
#import "TimePhotoNoAlbumView.h"
#import "CircleLoading.h"
#import "CircleSuccessLoading.h"
//分享弹框
#import "HomeShareView.h"
//========VC========
#import "ZCTabBarController.h"
#import "MyCloudStorageVC.h"
@interface TimePhotoAlbumVC ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    TimePhotoAlbumCellDelegate,
    TimePhotoNoAlbumViewDelegate
>
{
    /*区别是否是同一天*/
    NSString *tempDate;
}
@property (nonatomic,strong)UITableView *tv_list;
@property (nonatomic,strong)NSMutableArray *TimeAlbumArr;
@property (nonatomic,strong)TimePhotoNoAlbumView *bgView;//无内容时背景图
@end

@implementation TimePhotoAlbumVC

- (void)viewDidLoad {
    tempDate = @"tempDate";
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"时光相册", nil);
    self.view.backgroundColor = BG_COLOR;
    [self cteateNavBtn];
    //表视图布局
    [self.view addSubview:self.tv_list];
    [self.tv_list mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        make.width.mas_equalTo(iPhoneWidth);
    }];
    [self loadAlbumPhoto];
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


-(void)loadAlbumPhoto
{
    NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [postDic setObject:self.listModel.ID forKey:@"dev_id"];
    [postDic setObject:@"" forKey:@"craeteDate"];

    [[HDNetworking sharedHDNetworking]POST:@"v1/device/getcloudphoto" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject：%@",responseObject);
        int ret = [responseObject[@"ret"]intValue];
        if (ret == 0) {
            NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
            tempArr = [TimePhotoAlbumModel mj_objectArrayWithKeyValuesArray:responseObject[@"body"][@"urlList"]];
            
            for (int i = 0; i < tempArr.count; i++) {
                TimePhotoAlbumModel *model = tempArr[i];
                if (i%4 == 1) {
                    model.image = [UIImage imageNamed:@"album_placeholder0"];
                }else if (i%4 == 2){
                    model.image = [UIImage imageNamed:@"album_placeholder1"];
                }else if (i%4 == 3){
                    model.image = [UIImage imageNamed:@"album_placeholder2"];
                }else{
                    model.image = [UIImage imageNamed:@"album_placeholder3"];
                }
                model.isUsed = NO;
            }
            //按照日期分组
            [self groupedAlbumByDate:tempArr];
            if (self.TimeAlbumArr.count == 0) {
                [self.view addSubview:self.bgView];
            }else{
                [self.bgView removeFromSuperview];
            }
            [self.tv_list reloadData];
        }else{
            if (self.TimeAlbumArr.count == 0) {
                [self.tv_list reloadData];
            }
        }
        
    } failure:^(NSError * _Nonnull error) {
        if (self.TimeAlbumArr.count == 0) {
            [self.tv_list reloadData];
        }
    }];
}

#pragma mark - 给数组分类别
-(void)groupedAlbumByDate:(NSMutableArray *)arr{
    NSMutableArray *tempArr;
    [self.TimeAlbumArr removeAllObjects];
    for (int i = 0; i<arr.count; i++) {
        TimePhotoAlbumModel * model = arr[i];
        NSString * timeStr1= [NSString stringWithFormat:@"%@",model.createDate];
        NSString *currentDateStr = [timeStr1 substringToIndex:6];
        /**
         *  description: 当temp与当前循环元素相等且不为最后一次循环
         *  添加一个元素到同类别的已有的组别中
         */
        if (i != 0 && i != arr.count - 1) {
            
            if ([tempDate isEqualToString:currentDateStr]) {
                [tempArr addObject:arr[i]];
            } else {
                [self.TimeAlbumArr addObject:tempArr];
                tempArr = [NSMutableArray array];
                tempDate = currentDateStr;
                [tempArr addObject:arr[i]];
            }
            
        } else {
            if (i == 0) {
                tempArr = [NSMutableArray array];
                tempDate = currentDateStr;
                [tempArr addObject:arr[i]];
                if (arr.count == 1) {
                    [self.TimeAlbumArr addObject:tempArr];
                }
            } else if (i == arr.count-1) {
                if ([tempDate isEqualToString: currentDateStr]) {
                    [tempArr addObject:arr[i]];
                    [self.TimeAlbumArr addObject:tempArr];
                } else {
                    [self.TimeAlbumArr addObject:tempArr];
                    tempArr = [NSMutableArray array];
                    [tempArr addObject:arr[i]];
                    [self.TimeAlbumArr addObject:tempArr];
                }
            }
        }
    }
//        NSLog(@"日期组别：%@",self.TimeAlbumArr);
}



//=========================delegate=========================
#pragma mark - tableViewDelegate
//组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.TimeAlbumArr.count;
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *tempArr1 = [NSMutableArray arrayWithCapacity:0];
    [tempArr1 addObjectsFromArray:self.TimeAlbumArr[section]];
    return  tempArr1.count;
}

//head高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}
//head的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = BG_COLOR;
    TimePhotoAlbumModel *albumModel = self.TimeAlbumArr[section][0];
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateString = albumModel.createDate;
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    NSDate *date =[dateFormat dateFromString:dateString];
    NSDateFormatter* dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:[NSString stringWithFormat:@"yyyy%@MM%@",NSLocalizedString(@"年", nil),NSLocalizedString(@"月", nil)]];
    NSString *publishtimeStr = [dateFormat2 stringFromDate:date];
    
    UILabel *dateTipLb1 = [[UILabel alloc]init];
    if (section == 0) {
       dateTipLb1.frame = CGRectMake(0.05*iPhoneWidth, 15, self.view.frame.size.width, 20);
    }else{
        dateTipLb1.frame = CGRectMake(0.05*iPhoneWidth, 5, self.view.frame.size.width, 20);
    }
    dateTipLb1.font = FONT(24);
    dateTipLb1.textColor = RGB(0, 0, 0);
    dateTipLb1.text = [NSString stringWithFormat:@"%@",publishtimeStr];
    [headView addSubview:dateTipLb1];
    
    return headView;
}

//每行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (0.9*iPhoneWidth)/1.65+25;//倍率显示cell的高度
}

//每行的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    TimePhotoAlbumCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //解决xib复用数据混乱问题
    if (nil == cell) {
        cell= (TimePhotoAlbumCell *)[[[NSBundle  mainBundle]  loadNibNamed:@"TimePhotoAlbumCell" owner:self options:nil]  lastObject];
    }else
        {
            while ([cell.contentView.subviews lastObject] != nil)
            {
                [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];
            }
        }

    
    NSMutableArray *tempDateArr = [NSMutableArray arrayWithCapacity:0];
    [tempDateArr addObjectsFromArray:self.TimeAlbumArr[section]];
    TimePhotoAlbumModel *albumModel = tempDateArr[row];
    
    cell.albumImgView.image = albumModel.image;
    albumModel.isUsed = NO;
    
    //时间
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyyMMdd"];
    NSString *dateString = albumModel.createDate;
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    NSDate *date =[dateFormat dateFromString:dateString];
    NSDateFormatter* dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:[NSString stringWithFormat:@"MM%@dd%@",NSLocalizedString(@"月", nil),NSLocalizedString(@"日", nil)]];//yyyy年
    NSString *publishtimeStr = [dateFormat2 stringFromDate:date];
    cell.albumTimeLb.text = publishtimeStr;
    
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
 
}

//每一行的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    TimePhotoAlbumCell *cell = [self.tv_list cellForRowAtIndexPath:indexPath];
    
    NSMutableArray *tempDateArr = [NSMutableArray arrayWithCapacity:0];
    [tempDateArr addObjectsFromArray:self.TimeAlbumArr[section]];
    TimePhotoAlbumModel *albumModel = tempDateArr[row];
    
    NSString *tempBaseUrl;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:Environment]) {
        NSString * URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:Environment];
        if ([URLStr isEqualToString:official_Environment_key]) {
            tempBaseUrl = BASEURL_officialEnvironment;
        }else if([URLStr isEqualToString:test_Environment_key]){
            tempBaseUrl = BASEURL_testEnvironment;
        }
    }
    
    NSString *URLStr = [NSString stringWithFormat:@"%@v1/device/downGif?access_token=%@&user_id=%@&gif_url=%@",tempBaseUrl,[unitl get_accessToken],[unitl get_User_id],albumModel.url];
    NSURL *URL = [NSURL URLWithString:URLStr];
    
    if (albumModel.isUsed) {
        if ([cell.albumImgView isGIFPlaying]) {
            [cell.albumImgView stopGIF];
            cell.albunTimePlayImg.hidden = NO;
        }else{
            [cell.albumImgView startGIF];
            cell.albunTimePlayImg.hidden = YES;
        }
    }else{
        cell.albunTimePlayImg.hidden = YES;
        [cell.activityIndicator startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:URL];
            cell.albumImgView.gifData = imageData;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *imgArr = [self loadGifImageArr:URL];
                if (imgArr.count != 0 ) {
                    albumModel.image = (UIImage *)(imgArr[0]);
                    [cell.albumImgView startGIF];
                    [cell.activityIndicator stopAnimating];
                }
                albumModel.isUsed = YES;
            });
        });
    }
  
}

#pragma mark - 获取gif的第一帧
- (NSArray *)loadGifImageArr:(NSURL *)fileUrl
{
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)fileUrl, NULL);
    size_t gifCount = CGImageSourceGetCount(gifSource);
    NSMutableArray *frames = [[NSMutableArray alloc]init];
    for (size_t i = 0; i< gifCount; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        [frames addObject:image];
        CGImageRelease(imageRef);
    }
    return frames;
}

#pragma mark - 下载gif
- (void)AlbumPhotoDownload:(TimePhotoAlbumCell *)cell
{
    NSIndexPath * indexPath = [self.tv_list indexPathForCell:cell];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSString *modelfileName = [NSString stringWithFormat:@"/%@/file/%@",[unitl get_user_mobile],cell.albumTimeLb.text];
    
    if ([FileTool isFileExist:modelfileName]) {
        UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"文件已存在，确定要重新下载？", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //创建文件路径
            NSString *fileName = [NSString stringWithFormat:@"/%@/file",[unitl get_user_mobile]];
            [FileTool createRootFilePath:fileName];
            
            [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"相册下载中，请稍候...", nil)];
            NSMutableArray *tempDateArr = [NSMutableArray arrayWithCapacity:0];
            [tempDateArr addObjectsFromArray:self.TimeAlbumArr[section]];
            TimePhotoAlbumModel *albumModel = tempDateArr[row];
            
            NSString *tempBaseUrl;
            if ([[NSUserDefaults standardUserDefaults]objectForKey:Environment]) {
                NSString * URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:Environment];
                if ([URLStr isEqualToString:official_Environment_key]) {
                    tempBaseUrl = BASEURL_officialEnvironment;
                }else if([URLStr isEqualToString:test_Environment_key]){
                    tempBaseUrl = BASEURL_testEnvironment;
                }
            }
            
            NSString *URLStr = [NSString stringWithFormat:@"%@v1/device/downGif?access_token=%@&user_id=%@&gif_url=%@",tempBaseUrl,[unitl get_accessToken],[unitl get_User_id],albumModel.url];
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLStr]]
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                       if (!connectionError) {
                                           NSString *modelfileName = [NSString stringWithFormat:@"/Documents/%@/file/%@",[unitl get_user_mobile],cell.albumTimeLb.text];
                                           
                                           NSString *filePath = [NSString stringWithFormat:@"%@",[FileTool getFilePath:modelfileName]];
                                           //将文件写入刚才创建的文件夹内
                                           if ([data writeToFile:filePath atomically:YES]) {
                                               NSLog(@"文件存储的路径：%@",filePath);
                                               //取出图片的第一帧作为封面存到文件模型中
//                                               [self saveFileModelPath:modelfileName];
                                               [CircleLoading hideCircleInView:self.view];
                                               [CircleSuccessLoading showSucInView:self.view andTip:NSLocalizedString(@"已下载到我的文件", nil)];
                                           }else{
                                               [CircleLoading hideCircleInView:self.view];
                                               [XHToast showCenterWithText:NSLocalizedString(@"下载失败", nil)];
                                           }
                                       } else {
                                           [CircleLoading hideCircleInView:self.view];
                                           [XHToast showCenterWithText:NSLocalizedString(@"下载失败", nil)];
                                       }
                                   }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alertCtrl addAction:okAction];
        [alertCtrl addAction:cancelAction];
        [self presentViewController:alertCtrl animated:YES completion:nil];
        
    }else{
        //创建文件路径
        NSString *fileName = [NSString stringWithFormat:@"/%@/file",[unitl get_user_mobile]];
        [FileTool createRootFilePath:fileName];
        
        [CircleLoading showCircleInView:self.view andTip:NSLocalizedString(@"相册下载中，请稍候...", nil)];
        NSMutableArray *tempDateArr = [NSMutableArray arrayWithCapacity:0];
        [tempDateArr addObjectsFromArray:self.TimeAlbumArr[section]];
        TimePhotoAlbumModel *albumModel = tempDateArr[row];
        
        
        NSString *tempBaseUrl;
        if ([[NSUserDefaults standardUserDefaults]objectForKey:Environment]) {
            NSString * URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:Environment];
            if ([URLStr isEqualToString:official_Environment_key]) {
                tempBaseUrl = BASEURL_officialEnvironment;
            }else if([URLStr isEqualToString:test_Environment_key]){
                tempBaseUrl = BASEURL_testEnvironment;
            }
        }
        
        NSString *URLStr = [NSString stringWithFormat:@"%@v1/device/downGif?access_token=%@&user_id=%@&gif_url=%@",tempBaseUrl,[unitl get_accessToken],[unitl get_User_id],albumModel.url];
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLStr]]
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (!connectionError) {
                                       //                                     NSString *modelfileName = [FileTool createFileName];
                                       NSString *modelfileName = [NSString stringWithFormat:@"/Documents/%@/file/%@",[unitl get_user_mobile],cell.albumTimeLb.text];
                                       
                                       NSString *filePath = [NSString stringWithFormat:@"%@",[FileTool getFilePath:modelfileName]];
                                       //将文件写入刚才创建的文件夹内
                                       if ([data writeToFile:filePath atomically:YES]) {
                                           NSLog(@"文件存储的路径：%@",filePath);
                                           //取出图片的第一帧作为封面存到文件模型中
//                                           NSArray *imgArr = [self loadGifImageArr:[NSURL URLWithString:URLStr]];
                                           [self saveFileModelPath:modelfileName];
                                           [CircleLoading hideCircleInView:self.view];
                                           [CircleSuccessLoading showSucInView:self.view andTip:NSLocalizedString(@"已下载到我的文件", nil)];
                                       }else{
                                           [CircleLoading hideCircleInView:self.view];
                                           [XHToast showCenterWithText:NSLocalizedString(@"下载失败", nil)];
                                       }
                                   } else {
                                       [CircleLoading hideCircleInView:self.view];
                                       [XHToast showCenterWithText:NSLocalizedString(@"下载失败", nil)];
                                   }
                               }];
    }

}


#pragma mark - 存储文件model
- (void)saveFileModelPath:(NSString *)filePath
{
    NSString *fileKey = [unitl getKeyWithSuffix:[unitl get_User_id] Key:@"MYFILE"];
    if ([unitl getNeedArchiverDataWithKey:fileKey]) {
        NSLog(@"数组已经有了，我们下载第二个了哦");
        NSMutableArray *tempArr = [unitl getNeedArchiverDataWithKey:fileKey];
        
        FileModel *model = [[FileModel alloc]init];
        model.name = self.navigationItem.title;
        model.date = [self getFileCreateTime:NO];
        model.createTime = [self getFileCreateTime:YES];
        model.type = 2;
        model.filePath = filePath;
        [tempArr addObject:model];
        [unitl saveNeedArchiverDataWithKey:fileKey Data:tempArr];
    }else{
        NSLog(@"数组还没有，第一次我还不存在，现在创建哦");
        NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
        FileModel *model = [[FileModel alloc]init];
        model.name = self.navigationItem.title;
        model.date = [self getFileCreateTime:NO];
        model.createTime = [self getFileCreateTime:YES];
        model.type = 2;
        model.filePath = filePath;
        [tempArr addObject:model];
        [unitl saveNeedArchiverDataWithKey:fileKey Data:tempArr];
    }
}

#pragma mark - 获取当前时间
-(NSString *)getFileCreateTime:(BOOL)isDesc
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    if (isDesc) {
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }else{
        [formatter setDateFormat:@"YYYY.MM.dd"];
    }
    NSDate *date = [NSDate date];
    NSString *dateTimeStr = [formatter stringFromDate:date];
    return dateTimeStr;
}


#pragma mark - 分享gif
- (void)AlbumPhotoShare:(TimePhotoAlbumCell *)cell
{
    NSIndexPath * indexPath = [self.tv_list indexPathForCell:cell];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NSMutableArray *tempDateArr = [NSMutableArray arrayWithCapacity:0];
    [tempDateArr addObjectsFromArray:self.TimeAlbumArr[section]];
    TimePhotoAlbumModel *albumModel = tempDateArr[row];
    NSMutableDictionary *bodyDic = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSString *tempBaseUrl;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:Environment]) {
        NSString * URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:Environment];
        if ([URLStr isEqualToString:official_Environment_key]) {
            tempBaseUrl = BASEURL_officialEnvironment;
        }else if([URLStr isEqualToString:test_Environment_key]){
            tempBaseUrl = BASEURL_testEnvironment;
        }
    }
    
    NSString *URLStr = [NSString stringWithFormat:@"%@v1/device/downGif?access_token=%@&user_id=%@&gif_url=%@",tempBaseUrl,[unitl get_accessToken],[unitl get_User_id],albumModel.url];
    [bodyDic setObject:URLStr forKey:@"link"];
    [bodyDic setObject:@"https://img.yzcdn.cn/upload_files/2018/06/26/Fr0VGlHiFYK9rwEqYqGp3gGtK7wu.jpg!200x200.jpg" forKey:@"imgUrl"];
    [bodyDic setObject:@"时光相册" forKey:@"title"];
    [bodyDic setObject:@"留住每一份感动" forKey:@"desc"];

    [HomeShareView showWithTitle:NSLocalizedString(@"分享方式", nil) titArray:@[NSLocalizedString(@"QQ好友", nil), NSLocalizedString(@"QQ空间", nil), NSLocalizedString(@"微信好友", nil), NSLocalizedString(@"朋友圈", nil)] imgArray:@[@"H5QQ", @"H5QQzone", @"H5WeChat", @"H5CircleofFriends"] select:^(NSInteger row) {
        
        switch (row) {
            case 0:
                [self QQSeriesSharedClick:0 andSharedBody:bodyDic];//QQ
                break;
            case 1:
                [self QQSeriesSharedClick:1 andSharedBody:bodyDic];//QQ空间
                break;
            case 2:
                [self WeChatSeriesSharedClick:0 andSharedBody:bodyDic];//微信
                break;
            case 3:
                [self WeChatSeriesSharedClick:1 andSharedBody:bodyDic];//朋友圈
                break;
                
            default:
                break;
        }
        
    }];
}

#pragma mark - QQ系列分享【0：QQ，1：QQ空间】
- (void)QQSeriesSharedClick:(NSInteger)isQQ andSharedBody:(NSDictionary *)body
{
    NSString *link = body[@"link"];
    NSString *title = body[@"title"];
    NSString *description = body[@"desc"];
    NSString *previewImageUrl = body[@"imgUrl"];
    if (![TencentOAuth iphoneQQInstalled]) {
        NSLog(@"请移步 Appstore 去下载腾讯 QQ 客户端");
        [XHToast showCenterWithText:NSLocalizedString(@"你还没有安装QQ！", nil)];
    }else{
        QQApiNewsObject *newsObj = [QQApiNewsObject
                                    objectWithURL:[NSURL URLWithString:link]
                                    title:title
                                    description:description
                                    previewImageURL:[NSURL URLWithString:previewImageUrl]];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
        QQApiSendResultCode sent;
        if (isQQ == 0) {
            //将内容分享到qq
            sent = [QQApiInterface sendReq:req];
        }else{
            //将内容分享到qzone
            sent = [QQApiInterface SendReqToQZone:req];
        }
    }
}

#pragma mark - 微信系列分享【0：微信，1：朋友圈】
- (void)WeChatSeriesSharedClick:(NSInteger)isWeChat andSharedBody:(NSDictionary *)body
{
    NSString *link = body[@"link"];
    NSString *title = body[@"title"];
    NSString *description = body[@"desc"];
    NSString *previewImageUrl = body[@"imgUrl"];
    
    //微信好友分享
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;//不是文档类型
        
        //分享场景：WXSceneSession = 好友列表 WXSceneTimeline = 朋友圈 WXSceneFavorite = 收藏
        if (isWeChat == 0) {
            req.scene = WXSceneSession;
        }else{
            req.scene = WXSceneTimeline;
        }
        
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = title;//分享标题
        message.description = description;//分享描述
        
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:previewImageUrl]];
        [message setThumbImage:[UIImage imageWithData:data]];//分享图片,使用SDK的setThumbImage方法可压缩图片大小
        //创建多媒体对象
        WXWebpageObject *webObj = [WXWebpageObject object];
        webObj.webpageUrl = link;//分享链接
        //完成发送对象实例
        message.mediaObject = webObj;
        req.message = message;
        [WXApi sendReq:req];
    }else{
        [XHToast showCenterWithText:NSLocalizedString(@"你还没有安装微信！", nil)];
    }
}


#pragma mark - 无设备时云存购买的代理方法
- (void)cloudStorageBtnClick
{
    if ([self.listModel.enableCloud intValue] == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        MyCloudStorageVC *myCloudVC = [[MyCloudStorageVC alloc]init];
        myCloudVC.deviceId = self.listModel.ID;
        if(![NSString isNull:self.listModel.name]){
            myCloudVC.deviceName = self.listModel.name;
        }else{
            myCloudVC.deviceName = self.listModel.type;
        }
        myCloudVC.deviceImgUrl = self.listModel.ext_info.dev_img;
        [self.navigationController pushViewController:myCloudVC animated:YES];
    }
}



#pragma mark - TableView 占位图
- (UIImage *)xy_noDataViewImage {
    return [UIImage imageNamed:@"noContent"];
}

- (NSString *)xy_noDataViewMessage {
    return NSLocalizedString(@"未查询到相册，请检查您的网络", nil);
}

- (NSNumber *)xy_noDataViewCenterYOffset
{
    return @10;
}


#pragma mark - getter && setter
//表视图
-(UITableView *)tv_list{
    if (!_tv_list) {
        _tv_list = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tv_list.backgroundColor = BG_COLOR;
        _tv_list.delegate = self;
        _tv_list.dataSource = self;
        _tv_list.showsVerticalScrollIndicator = NO;
        UIView *footView = [[UIView alloc]init];
        _tv_list.tableFooterView = footView;
        _tv_list.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tv_list;
}

- (NSMutableArray *)TimeAlbumArr
{
    if (!_TimeAlbumArr) {
        _TimeAlbumArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _TimeAlbumArr;
}

//无内容时的背景图
-(TimePhotoNoAlbumView *)bgView{
    if (!_bgView) {
        if ([self.listModel.enableCloud intValue] == 1) {
            if (self.listModel.status == 1) {
                _bgView = [[TimePhotoNoAlbumView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight) bgColor:BG_COLOR bgImg:[UIImage imageNamed:@"groupNoDevice"] bgTip:NSLocalizedString(@"云存开通后无法立即为您展示时光相册", nil)];
            }else{
                _bgView = [[TimePhotoNoAlbumView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight) bgColor:BG_COLOR bgImg:[UIImage imageNamed:@"groupNoDevice"] bgTip:NSLocalizedString(@"当前设备不在线", nil)];
            }
            
        }else{
            _bgView = [[TimePhotoNoAlbumView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight) bgColor:BG_COLOR bgImg:[UIImage imageNamed:@"groupNoDevice"] bgTip:NSLocalizedString(@"未开通云存储功能，请先开通", nil)];
        }
        if ([self.listModel.enableCloud intValue] == 1) {
            [_bgView.cloudBtn setTitle:NSLocalizedString(@"稍后再试", nil) forState:UIControlStateNormal];
        }else{
            [_bgView.cloudBtn setTitle:NSLocalizedString(@"立即开通", nil) forState:UIControlStateNormal];
        }
        _bgView.delegate = self;
    }
    return _bgView;
}

@end
