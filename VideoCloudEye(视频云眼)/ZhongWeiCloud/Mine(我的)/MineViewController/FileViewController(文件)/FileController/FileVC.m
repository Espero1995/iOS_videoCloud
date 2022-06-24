//
//  FileVC.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/10/25.
//  Copyright © 2018 张策. All rights reserved.
//

#import "FileVC.h"
#include <sys/param.h>
#include <sys/mount.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
//========Model========
//腾讯API
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
//微信
#import "WXApi.h"
#import "FileModel.h"
#import "UIImage+GIF.h"
//========View========
#import "FileCollectionCell.h"
#import "FileShowView.h"
#import "EmptyDataBGView.h"
//分享弹框
#import "HomeShareView.h"
//========VC========
#import "ZCTabBarController.h"
#import "TYVideoPlayerController.h"
@interface FileVC ()
<
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    FileShowViewDelegate,
    UIAlertViewDelegate
>
{
    UIButton *_selectBtn;//选择按钮
    UIButton *_allChooseBtn;//全选按钮
    /*区别是否是同一天*/
    NSString *tempDate;
    /*记录tableView的编辑状态*/
    BOOL isEditable;
}
@property (nonatomic,strong) UICollectionView *fileCollectionView;
@property (nonatomic,strong) NSMutableArray *fileArr;//文件数组
@property (nonatomic,strong) NSMutableArray *resultDateArr;//分组后的数组
@property (nonatomic,strong) UILabel *bottomLb;//底部的Lb(显示存储空间)
@property (nonatomic,strong) UIView *bottomEditView;//底部编辑操作的View
@property (nonatomic,strong) UIButton *deleteBtn;//删除按钮
@property (nonatomic,strong) FileShowView *fileView;
@property (nonatomic,strong) EmptyDataBGView *bgView;//无内容时背景图
@property (nonatomic,strong) NSMutableArray *chooseBtnArr;//所有文件有没有被选中
@property (nonatomic,strong) NSMutableArray *deleteArr;////删除按钮的数组
@property (nonatomic,strong) NSMutableArray *images;
@end

//注意const的位置
static NSString *const cellId = @"cellId";
static NSString *const headerId = @"headerId";
static NSString *const footerId = @"footerId";

@implementation FileVC

//=========================system=========================
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BG_COLOR;
    [self setNavBtn];
    self.navigationItem.title = NSLocalizedString(@"我的文件", nil);
    tempDate = @"tempDate";
    NSString *fileKey = [unitl getKeyWithSuffix:[unitl get_User_id] Key:@"MYFILE"];
    self.fileArr = [unitl getNeedArchiverDataWithKey:fileKey];
    self.fileArr = (NSMutableArray *)[[self.fileArr reverseObjectEnumerator] allObjects];
    
//    NSLog(@"self.fileArr:%@",self.fileArr);
    [self groupedFileByDate:self.fileArr];
    [self setUpUI];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//=========================init=========================
- (void)setNavBtn
{
    //编辑按钮
    _selectBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [_selectBtn setTitle:NSLocalizedString(@"选择", nil) forState:UIControlStateNormal];
    _selectBtn.titleLabel.font = FONT(16);
    [_selectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_selectBtn addTarget:self action:@selector(editClick) forControlEvents:UIControlEventTouchUpInside];
    _selectBtn.userInteractionEnabled = YES;
    _selectBtn.contentHorizontalAlignment =UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem* editRightItem = [[UIBarButtonItem alloc]initWithCustomView:_selectBtn];
    self.navigationItem.rightBarButtonItems = @[editRightItem];
    [self cteateNavBtn];
}
//页面初始化(UICollectionView)
- (void)setUpUI{
    if (self.fileArr.count == 0) {
        [self.view addSubview:self.bgView];
    }else{
        [self.view addSubview:self.fileCollectionView];
        [self.fileCollectionView mas_makeConstraints:^(MASConstraintMaker *make)
         {
             make.left.mas_equalTo(0);
             make.top.mas_equalTo(0);
             make.size.mas_equalTo(CGSizeMake(iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight));
         }];
        
        /** 注册单元格（注册cell、sectionHeader、sectionFooter）
         * description: 注册单元格的类型为 UICollectionViewCell ，如果子类化 UICollectionViewCell，这里可指定对应类。
         */
        [self.fileCollectionView registerNib:[UINib nibWithNibName:@"FileCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:cellId];
        [self.fileCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId];
        [self.fileCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerId];
        
        //代理协议
        self.fileCollectionView.delegate = self;
        self.fileCollectionView.dataSource = self;
    }

    //底部的label
    [self.view addSubview:self.bottomLb];
    [self.bottomLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(0);
        if (iPhone_X_) {
            make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 44));
        }else{
            make.size.mas_equalTo(CGSizeMake(iPhoneWidth, 25));
        }
    }];
}

//=========================method=========================
#pragma mark - 获取设备的存储空间大小
- (NSString *)getDivceSize
{
    // 总大小
    float totalsize = 0.0;
    /// 剩余大小
    float freesize = 0.0;
    /// 是否登录
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary){
        NSNumber *_free = [dictionary objectForKey:NSFileSystemFreeSize];
        freesize = [_free unsignedLongLongValue]*1.0/(1024);
        NSNumber *_total = [dictionary objectForKey:NSFileSystemSize];
        totalsize = [_total unsignedLongLongValue]*1.0/(1024);
    } else{
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
//    NSLog(@"totalsize = %.2f, freesize = %f",totalsize/1024/1024, freesize/1024/1024);
    return [NSString stringWithFormat:@"%@%0.1fG%@",NSLocalizedString(@"剩余", nil),freesize/1024/1024,NSLocalizedString(@"空间", nil)];
}

#pragma mark - 给数组分类别
-(void)groupedFileByDate:(NSMutableArray *)arr{
    NSMutableArray *tempArr;
    [self.resultDateArr removeAllObjects];
    for (int i = 0; i<arr.count; i++) {
        FileModel * model = arr[i];
        NSString *timeStr1= [NSString stringWithFormat:@"%@",model.date];
        NSString *currentDateStr = [timeStr1 substringToIndex:10];
        /**
         *  description: 当temp与当前循环元素相等且不为最后一次循环
         *  添加一个元素到同类别的已有的组别中
         */
        if (i != 0 && i != arr.count - 1) {
            
            if ([tempDate isEqualToString:currentDateStr]) {
                [tempArr addObject:arr[i]];
            } else {
                [self.resultDateArr addObject:tempArr];
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
                    [self.resultDateArr addObject:tempArr];
                }
            } else if (i == arr.count-1) {
                if ([tempDate isEqualToString: currentDateStr]) {
                    [tempArr addObject:arr[i]];
                    [self.resultDateArr addObject:tempArr];
                } else {
                    [self.resultDateArr addObject:tempArr];
                    tempArr = [NSMutableArray array];
                    [tempArr addObject:arr[i]];
                    [self.resultDateArr addObject:tempArr];
                }
            }
        }
    }
//            NSLog(@"日期组别：%@",self.resultDateArr);
}


#pragma mark - 编辑点击事件
- (void)editClick
{
    if (self.fileArr.count != 0) {
        self.fileCollectionView.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight-50);
        [self.chooseBtnArr removeAllObjects];
        isEditable = YES;
        //用来选择选中的数组TODO
        for (int i = 0; i < self.fileArr.count; i++) {
            NSString * btnStr = [NSString stringWithFormat:@"no"];
            [self.chooseBtnArr addObject:btnStr];
        }
        
        self.bottomLb.hidden = YES;
        [self resetNavBtn];
        [self.view addSubview:self.bottomEditView];
        [self.bottomEditView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view.mas_bottom).offset(0);
            make.left.equalTo(self.view.mas_left).offset(0);
            make.right.equalTo(self.view.mas_right).offset(0);
            make.height.mas_equalTo(@50);
        }];
        
        [self.bottomEditView addSubview:self.deleteBtn];
        [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bottomEditView.mas_centerX);
            make.centerY.equalTo(self.bottomEditView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(0.8*iPhoneWidth, 40));
        }];
        [self.fileCollectionView reloadData];
    }
    
}
//重设置导航栏按钮
- (void)resetNavBtn
{
    //取消按钮
    _selectBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 15)];
    [_selectBtn setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
    _selectBtn.titleLabel.font = FONT(16);
    [_selectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_selectBtn addTarget:self action:@selector(cancelEdit) forControlEvents:UIControlEventTouchUpInside];
    _selectBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:_selectBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    _allChooseBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    _allChooseBtn.titleLabel.font = FONT(16);
    _allChooseBtn.selected = NO;
    [_allChooseBtn setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
    [_allChooseBtn setContentHorizontalAlignment: UIControlContentHorizontalAlignmentLeft];
    [_allChooseBtn addTarget:self action:@selector(allChooseClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithCustomView:_allChooseBtn];
    self.navigationItem.leftBarButtonItems = @[leftItem];
}

#pragma mark - 取消编辑
- (void)cancelEdit
{
    for (int i = 0; i < self.fileArr.count; i++) {
        NSString * btnStr = [NSString stringWithFormat:@"no"];
        [self.chooseBtnArr replaceObjectAtIndex:i withObject:btnStr];
    }
    isEditable = NO;
    [self.deleteArr removeAllObjects];//移除所有被选中的
    self.bottomLb.hidden = NO;
    [self setNavBtn];
    //移除底部的编辑框
    self.fileCollectionView.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight);
    [self.bottomEditView removeFromSuperview];
    [self.fileCollectionView reloadData];
}

#pragma mark - 全选
- (void)allChooseClick
{
    if (_allChooseBtn.selected == NO) {
        _allChooseBtn.selected = YES;
        [_allChooseBtn setTitle:NSLocalizedString(@"取消全选", nil) forState:UIControlStateNormal];
        [self.deleteArr removeAllObjects];
        for (int i = 0; i<self.fileArr.count; i++) {
            NSString * btnStr = [NSString stringWithFormat:@"yes"];
            [self.chooseBtnArr replaceObjectAtIndex:i withObject:btnStr];
        }
        [self.deleteArr addObjectsFromArray:self.fileArr];
        
    }else{
        for (int i = 0; i<self.fileArr.count; i++) {
            NSString * btnStr = [NSString stringWithFormat:@"no"];
            [self.chooseBtnArr replaceObjectAtIndex:i withObject:btnStr];
        }
        
        _allChooseBtn.selected = NO;
        [_allChooseBtn setTitle:NSLocalizedString(@"全选", nil) forState:UIControlStateNormal];
        [self.deleteArr removeAllObjects];
    }

    [self.fileCollectionView reloadData];
}


#pragma mark - 删除
- (void)deleteClick
{
    if (self.deleteArr.count != 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"温馨提示", nil) message:NSLocalizedString(@"删除后不可恢复，确定要删除吗？", nil) preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"删除", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

            for (int i = 0; i<self.deleteArr.count; i++) {
                //删除本地数据
                FileModel *model = self.deleteArr[i];
                NSString *filePath = [NSString stringWithFormat:@"%@",[FileTool getFilePath:model.filePath]];
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                //重新分组
                [self.fileArr removeObject:model];
                [self groupedFileByDate:self.fileArr];
            }
            
            //删除查询的文件。
            NSString *fileKey = [unitl getKeyWithSuffix:[unitl get_User_id] Key:@"MYFILE"];
            NSMutableArray *tempArr = (NSMutableArray *)[[self.fileArr reverseObjectEnumerator] allObjects];
            [unitl saveNeedArchiverDataWithKey:fileKey Data:tempArr];
            [self.fileCollectionView reloadData];
            [self setUpUI];
            [self cancelEdit];
            
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

//=========================delegate=========================
#pragma mark ------collectionView代理方法
//有多少个章节（Section），如果省略，默认为1
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.resultDateArr.count;
}

// 每个章节中有多少个单元格（Cell）
//注意：这里返回的是每个章节的单元格数量，当有多个章节时，需要判断 section 参数，返回对应的数量。
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSMutableArray *tempArr1 = [NSMutableArray arrayWithCapacity:0];
    [tempArr1 addObjectsFromArray:self.resultDateArr[section]];
    return  tempArr1.count;
}

//实例化每个单元格
//使用 dequeueReusableCellWithReuseIdentifier 方法获得“复用”的单元格实例
//返回的 cell 依赖注册单元格类型，识别符 “DemoCell”也需要一致，否则，这里将返回 nil，导致崩溃。
//这里可以配置每个单元格显示内容，如单元格标题等。
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    FileCollectionCell *cell = (FileCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    NSMutableArray *tempFileArr = [NSMutableArray arrayWithCapacity:0];
    [tempFileArr addObjectsFromArray:self.resultDateArr[section]];
    FileModel *model = tempFileArr[row];
    cell.model = model;

    if (model.type == 0) {
        cell.isVideoImg.image = [UIImage imageNamed:@"video_file_icon"];
    }else if (model.type == 1){
        cell.isVideoImg.image = [UIImage imageNamed:@"pic_file_icon"];
    }else{
        cell.isVideoImg.image = [UIImage imageNamed:@"gif_file_icon"];
    }
    
    if (isEditable == NO) {
        cell.chooseBtn.hidden = YES;
    }else{
//        NSLog(@"self.chooseBtnArr:::%@",self.chooseBtnArr);
        cell.chooseBtn.hidden = NO;
        //判断当前选择第几个
        NSInteger tempCount = 0;
        for (int i =0; i< indexPath.section; i++) {
            tempCount += [[self.resultDateArr objectAtIndex:i] count];
        }
        tempCount = tempCount + indexPath.row+1;
        if ([self.chooseBtnArr[tempCount-1] isEqualToString:@"yes"]) {
            cell.chooseBtn.selected = YES;
        }else{
            cell.chooseBtn.selected = NO;
        }
    }
    
    return cell;
}

// 和UITableView类似，UICollectionView也可设置段头段尾
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //段头
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]){
        UICollectionReusableView *headerView = [_fileCollectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerId forIndexPath:indexPath];
        if (headerView == nil){
            headerView = [[UICollectionReusableView alloc] init];
        }
        headerView.backgroundColor = [UIColor clearColor];
        [headerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        if (self.resultDateArr.count!=0) {
            UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, 25)];
            bgView.backgroundColor = RGB(210, 210, 210);
            bgView.alpha = 0.5;
            [headerView addSubview:bgView];
            UILabel *dateLb =[[UILabel alloc]init];
            FileModel *model = self.resultDateArr[indexPath.section][0];
            //时间
            dateLb.frame = CGRectMake(15, 0, iPhoneWidth, 25);
            dateLb.font = FONT(15);
            dateLb.textColor = RGB(50, 50, 50);
            dateLb.text = model.date;
            [headerView addSubview:dateLb];
        }
        
        return headerView;
    }
    //段尾
    else if ([kind isEqualToString:UICollectionElementKindSectionFooter]){
        UICollectionReusableView *footerView = [_fileCollectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footerId forIndexPath:indexPath];
        if (footerView == nil){
            footerView = [[UICollectionReusableView alloc] init];
        }
        return footerView;
    }
    
    return nil;
}


#pragma mark - collectionView 布局
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float width = (iPhoneWidth-12)/3.f;
    float height = width/1.5;
    return (CGSize){width,height};
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 3, 0, 3);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 3.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}

//头部的宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (self.resultDateArr.count!=0) {
        return (CGSize){self.view.frame.size.width,25};
    }else{
        return (CGSize){self.view.frame.size.width,0};
    }
    
}

//底部的宽高
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return (CGSize){self.view.frame.size.width,0};
}

// 选中某item是否开启
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
// 选中某item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //判断当前选择第几个
    NSInteger tempCount = 0;
    for (int i =0; i< indexPath.section; i++) {
        tempCount += [[self.resultDateArr objectAtIndex:i] count];
    }
    tempCount = tempCount + indexPath.row+1;
//    NSLog(@"我现在选择的是第%ld个",(long)tempCount);
    
    
    if (isEditable) {//可编辑状态下
        if ([self.chooseBtnArr[tempCount-1] isEqualToString:@"no"]) {//indexPath.row
            
            NSString * btnStr = [NSString stringWithFormat:@"yes"];
            [self.chooseBtnArr replaceObjectAtIndex:tempCount -1 withObject:btnStr];//indexPath.row
            
            [self.deleteArr addObject:[self.fileArr objectAtIndex:tempCount-1]];//indexPath.row
            [self.fileCollectionView reloadData];
        }else{
            NSString * btnStr = [NSString stringWithFormat:@"no"];
            [self.chooseBtnArr replaceObjectAtIndex:tempCount-1 withObject:btnStr];//indexPath.row
            [self.deleteArr removeObject:[self.fileArr objectAtIndex:tempCount-1]];//indexPath.row
            [self.fileCollectionView reloadData];
        }

    }else{
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        NSMutableArray *tempFileArr = [NSMutableArray arrayWithCapacity:0];
        [tempFileArr addObjectsFromArray:self.resultDateArr[section]];
        FileModel *fileModel = tempFileArr[row];
        if (fileModel.type == 0) {
            TYVideoPlayerController *videoVC = [[TYVideoPlayerController alloc] init];
            NSString *filePath = [NSString stringWithFormat:@"%@",[FileTool getFilePath:fileModel.filePath]];
            videoVC.streamURL = [NSURL fileURLWithPath:filePath];
            if (fileModel.createTime) {
                NSString *desc = [NSString stringWithFormat:@"%@:mp4    %@:%@    %@:%@",NSLocalizedString(@"文件格式", nil),NSLocalizedString(@"录制时间", nil),fileModel.createTime,NSLocalizedString(@"关联设备通道", nil),fileModel.name];
               videoVC.videoInfo = [self getDescFileInfo:desc andFilePath:filePath];
            }
            videoVC.titleName = fileModel.name;
            
            [self presentViewController:videoVC animated:YES completion:nil];
        }else{
            [self.fileView setFileModelInfo:fileModel];
            [self.fileView setFileViewShow];
        }
        
    }
    
}

#pragma mark - 下载gif到本地
- (void)downLoadFile:(FileModel *)model
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized: //已获取权限
//                    NSLog(@"有权限");
                    [self downloadLoc:model];
                    break;
                    
                case PHAuthorizationStatusDenied: //用户已经明确否认了这一照片数据的应用程序访问
//                    NSLog(@"无权限1");
                    {
                        // 创建一个UIAlertView并显示出来
                        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"已为“视频云眼”关闭照片", nil) message:NSLocalizedString(@"您可以在“设置”中为此应用打开照片", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"设置", nil) otherButtonTitles:NSLocalizedString(@"好", nil),nil];
                        [alertview show];
                    }
                    
                    break;
                    
                case PHAuthorizationStatusRestricted://此应用程序没有被授权访问的照片数据。可能是家长控制权限
//                    NSLog(@"无权限2");
                    {
                        // 创建一个UIAlertView并显示出来
                        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"已为“视频云眼”关闭照片", nil) message:NSLocalizedString(@"您可以在“设置”中为此应用打开照片", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"设置", nil) otherButtonTitles:NSLocalizedString(@"好", nil),nil];
                        [alertview show];
                    }
                    
                    break;
                    
                default://其他。。。
                    break;
            }
        });
    }];
}


- (void)downloadLoc:(FileModel *)model
{
    if (model.type == 1) {//图片
        NSString *filePath = [NSString stringWithFormat:@"%@",[FileTool getFilePath:model.filePath]];
        UIImage *image = [[UIImage alloc]initWithContentsOfFile:filePath];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image: didFinishSavingWithError: contextInfo:), nil);
    }else{//gif
        NSString *version = [UIDevice currentDevice].systemVersion;
        if (version.doubleValue >= 11.0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *filePath = [NSString stringWithFormat:@"%@",[FileTool getFilePath:model.filePath]];
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            [XHToast showCenterWithText:NSLocalizedString(@"保存成功", nil)];
                        }else{
                            [CircleLoading hideCircleInView:self.view];
                            [XHToast showCenterWithText:NSLocalizedString(@"保存失败", nil)];
                        }
                    });
                }];
            });
        } else {
            // 针对 9.0 以下的iOS系统进行处理
            [XHToast showCenterWithText:NSLocalizedString(@"iOS11以下无法保存gif图片，只能保存图片", nil)];
            NSString *filePath = [NSString stringWithFormat:@"%@",[FileTool getFilePath:model.filePath]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error){
                }];
            });
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error == nil) {
        [XHToast showCenterWithText:NSLocalizedString(@"保存成功", nil)];
    }
    else{
        ///图片未能保存到本地
        [XHToast showCenterWithText:NSLocalizedString(@"保存失败", nil)];
    }
}

#pragma mark - 分享
- (void)shareFile:(FileModel *)model
{
    [HomeShareView showWithTitle:NSLocalizedString(@"分享方式", nil) titArray:@[NSLocalizedString(@"QQ好友", nil), NSLocalizedString(@"QQ空间", nil), NSLocalizedString(@"微信好友", nil), NSLocalizedString(@"朋友圈", nil)] imgArray:@[@"H5QQ", @"H5QQzone", @"H5WeChat", @"H5CircleofFriends"] select:^(NSInteger row) {
        NSMutableDictionary *bodyDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [bodyDic setObject:model forKey:@"model"];
        [bodyDic setObject:NSLocalizedString(@"视频云眼", nil) forKey:@"title"];
        [bodyDic setObject:NSLocalizedString(@"截图", nil) forKey:@"desc"];
        
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
    NSString *title = body[@"title"];
    NSString *description = body[@"desc"];
    FileModel *model = body[@"model"];
    if (![TencentOAuth iphoneQQInstalled]) {
        NSLog(@"请移步 Appstore 去下载腾讯 QQ 客户端");
        [XHToast showCenterWithText:NSLocalizedString(@"你还没有安装QQ！", nil)];
    }else{
        NSString *filePath = [NSString stringWithFormat:@"%@",[FileTool getFilePath:model.filePath]];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        QQApiImageObject *imgObj = [QQApiImageObject objectWithData:fileData previewImageData:fileData title:title description:description];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
        //因为分享的是联系人和空间的结合体，下面的判断其实多此一举
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
    FileModel *model = body[@"model"];
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
        WXImageObject *ext = [WXImageObject object];
        NSString *filePath = [NSString stringWithFormat:@"%@",[FileTool getFilePath:model.filePath]];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        ext.imageData = fileData;
        message.mediaObject = ext;
        req.message = message;
        [WXApi sendReq:req];
    }else{
        [XHToast showCenterWithText:NSLocalizedString(@"你还没有安装微信！", nil)];
    }
}


#pragma mark - getter && setter
//collectionView
- (UICollectionView *)fileCollectionView
{
    if (!_fileCollectionView) {
        //自定义布局对象
        UICollectionViewFlowLayout *customLayout = [[UICollectionViewFlowLayout alloc]init];
        _fileCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:customLayout];
        customLayout.sectionHeadersPinToVisibleBounds=YES;
        _fileCollectionView.backgroundColor = [UIColor whiteColor];
        _fileCollectionView.showsVerticalScrollIndicator = NO;
    }
    return _fileCollectionView;
}
//底部Label
- (UILabel *)bottomLb
{
    if (!_bottomLb) {
        _bottomLb = [[UILabel alloc]init];
        _bottomLb.backgroundColor = RGB(210, 210, 210);
        _bottomLb.font = FONT(15);
        _bottomLb.textAlignment = NSTextAlignmentCenter;
        _bottomLb.alpha = 0.5;
        _bottomLb.text = [self getDivceSize];
    }
    return _bottomLb;
}
//文件数组
- (NSMutableArray *)fileArr
{
    if (!_fileArr) {
        _fileArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _fileArr;
}
//根据日期分类后的告警消息数组
-(NSMutableArray *)resultDateArr{
    if (!_resultDateArr) {
        _resultDateArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _resultDateArr;
}
#pragma mark - 展示的view
- (FileShowView *)fileView
{
    if (!_fileView) {
        _fileView = [[FileShowView alloc]initWithframe:CGRectMake(0, iPhoneHeight, iPhoneWidth, iPhoneHeight)];
        _fileView.delegate = self;
    }
    return _fileView;
}
//无内容时的背景图
-(EmptyDataBGView *)bgView{
    if (!_bgView) {
        _bgView = [[EmptyDataBGView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight-iPhoneNav_StatusHeight) bgColor:BG_COLOR bgImg:[UIImage imageNamed:@"noContent"] bgTip:NSLocalizedString(@"暂无相关文件", nil)];
    }
    return _bgView;
}
//底部编辑View
- (UIView *)bottomEditView
{
    if (!_bottomEditView) {
        _bottomEditView = [[UIView alloc]initWithFrame:CGRectZero];
        _bottomEditView.backgroundColor = RGB(244, 243, 243);
        _bottomEditView.layer.shadowColor = [UIColor blackColor].CGColor;
        _bottomEditView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        _bottomEditView.layer.shadowRadius = 3.0;
        _bottomEditView.layer.shadowOpacity = 0.3;
    }
    return _bottomEditView;
}
//删除按钮
- (UIButton *)deleteBtn
{
    if (!_deleteBtn) {
        _deleteBtn = [[UIButton alloc]init];
        [_deleteBtn setTitle:NSLocalizedString(@"删除", nil) forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _deleteBtn.backgroundColor = MAIN_COLOR;
        _deleteBtn.layer.cornerRadius = 20.f;
        [_deleteBtn addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

//选择按钮的数组
- (NSMutableArray *)chooseBtnArr
{
    if (!_chooseBtnArr) {
        _chooseBtnArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _chooseBtnArr;
}
//deleteArr;//删除按钮的数组
- (NSMutableArray *)deleteArr
{
    if (!_deleteArr) {
        _deleteArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _deleteArr;
}


#pragma mark - 获取文件的一些数据信息
- (NSString *)getDescFileInfo:(NSString*)desc andFilePath:(NSString *)filePath
{
    //省时
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    long dataLength = [data length];
    //图片存储大小
    NSString *storageStr = [self transformedValue:dataLength];
    NSString* resultName;
    resultName = [NSString stringWithFormat:@"%@:%@    %@",NSLocalizedString(@"文件大小", nil),storageStr,desc];
    return resultName;
}

/**
 根据图片大小转成相应的大小文件
 
 @param value 文件大小
 @return 返回字符串
 */
- (NSString *)transformedValue:(long)value
{
    double convertedValue = value;
    int multiplyFactor = 0;
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB", @"ZB", @"YB",nil];
    while (convertedValue > 1000) {
        convertedValue /= 1000;
        multiplyFactor++;
    }
    return [NSString stringWithFormat:@"%4.1f%@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}


//监听点击事件 代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([btnTitle isEqualToString:NSLocalizedString(@"设置", nil)]) {
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }
    
}

@end
