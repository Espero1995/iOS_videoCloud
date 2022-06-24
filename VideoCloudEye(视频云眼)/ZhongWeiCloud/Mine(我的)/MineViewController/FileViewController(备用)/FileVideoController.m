       //
//  FileVideoController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/3/21.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "FileVideoController.h"
#import "FileImageController.h"
#import "SegmentViewController.h"
#import "VideoCell_c.h"
#import "VideoViewController.h"
#import "TYVideoPlayerController.h"
#import "ZCTabBarController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface FileVideoController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
SegmentControl_Delegete
>
{
    BOOL _subing;
    BOOL _choosed;
}
@property (nonatomic,strong) UICollectionView * collectionView;

@property (nonatomic,strong) NSMutableArray * dataArray;
@property (nonatomic,strong) NSMutableArray * videoDataArr;
@property (nonatomic,strong) NSMutableArray * deleteArr;
@property (nonatomic,strong) NSMutableArray * delete_Arr;
@property (nonatomic,strong) NSMutableArray * btnArr;
//路径数组
@property (nonatomic,strong) NSMutableArray * pathArray;
@property (nonatomic,strong) NSMutableArray * imageArray;
@end

@implementation FileVideoController


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
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BG_COLOR;
    SegmentViewController *segVc = (SegmentViewController *)self.parentViewController;
    segVc.delegeSoure = self;
    _subing = NO;
    _choosed = NO;
    //返回按钮
    [self cteateNavBtn];
    //创建CollectionView
    [self createCollectionView];
    //数据
    [self createData];
}
- (void)createData{
    self.btnArr = [NSMutableArray array];
    self.imageArray = [NSMutableArray array];
    self.pathArray = [NSMutableArray array];
    self.deleteArr = [NSMutableArray array];
    self.delete_Arr = [NSMutableArray array];
    [self.videoDataArr removeAllObjects];
    [self.dataArray removeAllObjects];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         self.videoDataArr = [NSMutableArray arrayWithArray:[self getAllVieoData]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
}



#pragma mark ------得到所有视频文件路径数组
- (NSMutableArray *)getAllVieoData
{
    
    //创建可变数组存放所有视频路径
    NSMutableArray *videoArr = [NSMutableArray array];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        NSString *pathStr = [NSString stringWithFormat:@"/Documents/%@/video",userModel.mobile];
        //1、拼接目录
        NSString *path = [NSHomeDirectory() stringByAppendingString:pathStr];
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]enumeratorAtPath:path];
        
        for (NSString *fileName in enumerator)
        {
            
            BOOL isIma = [fileName hasSuffix:@".mp4"];
            NSString * btnStr = [NSString stringWithFormat:@"no"];
            [self.btnArr addObject:btnStr];
            //如果以mov结尾存入路径到数组
            if (isIma) {
                NSString *videoPath = [NSString stringWithFormat:@"%@/%@",path,fileName];
                [_pathArray insertObject:videoPath atIndex:0];
                NSURL *imaUrl = [NSURL fileURLWithPath:videoPath];
                UIImage *ima = [self thumbnailImageForVideo:imaUrl atTime:1];
                if (ima == nil) {
                    ima = [UIImage imageNamed:@"alarm"];
                    [self.imageArray insertObject:ima atIndex:0];
                }else{
                    [self.imageArray insertObject:ima atIndex:0];
                }
                
                //视频大小
                long length = [self fileSizeAtPath:videoPath];
                NSString* imagestorageStr = [self transformedValue:length];
                NSString* resultName = [NSString stringWithFormat:@"%@:%@  %@",NSLocalizedString(@"文件大小", nil),imagestorageStr,fileName];
                resultName = [resultName substringWithRange:NSMakeRange(0,resultName.length - 6)];
                [self.dataArray insertObject:resultName atIndex:0];
                [videoArr insertObject:videoPath atIndex:0];
            }
        }
    }
    
//    NSLog(@"设备结果：%@",videoArr);
    
    return videoArr;
}

//计算视频的大小
- (long long)fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

/**
 根据视频大小转成相应的大小文件
 
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


- (void)createCollectionView{
    //自动布局类
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight - 64) collectionViewLayout:layout];
    //代理
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = BG_COLOR;
    //注册
    [_collectionView registerClass:[VideoCell_c class] forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:_collectionView];


}
#pragma mark ------ UICollectionView代理方法
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(iPhoneWidth/2-5, (iPhoneWidth/2-5)/1.6);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 0, 0, 0);
}
//分组数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每组cell个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.videoDataArr.count;
}

//创建cell
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VideoCell_c * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//    cell.nameLabel.text = self.dataArray[indexPath.row];
    cell.ImageV.image = self.imageArray[indexPath.row];

    if (_subing == NO) {
        cell.chooseBtn.hidden = YES;
    }else{
        cell.chooseBtn.hidden = NO;
        if ([self.btnArr[indexPath.row] isEqualToString:@"yes"]) {
            cell.chooseBtn.selected = YES;
        }else{
            cell.chooseBtn.selected = NO;
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VideoCell_c *cell = (VideoCell_c *)[collectionView cellForItemAtIndexPath:indexPath];
    if (_subing == NO) {
        TYVideoPlayerController *videoVC = [[TYVideoPlayerController alloc] init];
        videoVC.streamURL = [NSURL fileURLWithPath:self.videoDataArr[indexPath.row]];
        videoVC.videoInfo = self.dataArray[indexPath.row];
        [self presentViewController:videoVC animated:YES completion:nil];
    }else if (_subing == YES){
        if ([self.btnArr[indexPath.row] isEqualToString:@"no"]) {
            NSString * btnStr = [NSString stringWithFormat:@"yes"];
            [self.btnArr replaceObjectAtIndex:indexPath.row withObject:btnStr];
            [_deleteArr addObject:[_pathArray objectAtIndex:indexPath.row]];
            [_delete_Arr addObject:[_videoDataArr objectAtIndex:indexPath.row]];
            [self.collectionView reloadData];
        }else{
            NSString * btnStr = [NSString stringWithFormat:@"no"];
            [self.btnArr replaceObjectAtIndex:indexPath.row withObject:btnStr];
            [_deleteArr removeObject:[_pathArray objectAtIndex:indexPath.row]];
            [_delete_Arr removeObject:[_videoDataArr objectAtIndex:indexPath.row]];
            [self.collectionView reloadData];
        }
    }
}

//编辑cell
- (BOOL)SegmentControlEditCollectCell:(SegmentViewController *)segmentController{
    
    if (_videoDataArr.count != 0) {
//        NSLog(@"编辑video的cell");
        _subing = YES;
        self.collectionView.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight - 64 - 60);
        [self.collectionView reloadData];
        return YES;
    }else{
        return NO;
    }
}
//取消编辑
- (void)SegmentControlCancleEdit:(SegmentViewController *)segmentController{
    
//    NSLog(@"取消编辑video的cell");
    _subing = NO;
    _choosed = NO;
    for (int i = 0; i < _videoDataArr.count; i++) {
        NSString * btnStr = [NSString stringWithFormat:@"no"];
        [self.btnArr replaceObjectAtIndex:i withObject:btnStr];
    }

    segmentController.allChoose.selected = NO;
    [self.deleteArr removeAllObjects];
    [self.delete_Arr removeAllObjects];
    self.collectionView.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight - 64);
    [self.collectionView reloadData];
}
//删除cell
- (void)SegmentControlDeleteBtnClick:(SegmentViewController *)segmentController{
    
//    NSLog(@"删除video的cell");
    if (self.deleteArr.count==0) {
        [XHToast showCenterWithText:@"未选择任何视频"];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除提醒"message:@"确定删除所选视频？删除后无法恢复！"preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
           
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                for (NSString * pathStr in self.deleteArr) {
                    //        NSLog(@"%@",pathStr);
                    NSFileManager * fileManager = [NSFileManager defaultManager];
                    [fileManager removeItemAtPath:pathStr error:nil];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_videoDataArr removeObjectsInArray:_delete_Arr];
                    [_deleteArr removeAllObjects];
                    [_delete_Arr removeAllObjects];
//                    [self createData];
                    _subing = NO;
                    [segmentController setDefaultNav];
                    [self.collectionView reloadData];
                });
            });
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
//全选cell
- (void)SegmentControlChooseAllCell:(SegmentViewController *)segmentController{
    
//    NSLog(@"全选video的cell");
    if (segmentController.allChoose.selected == NO) {
        segmentController.allChoose.selected = YES;
        [segmentController.allChoose setTitle:@"全不选" forState:UIControlStateNormal];
        _choosed = YES;
        [_deleteArr removeAllObjects];
        [_delete_Arr removeAllObjects];
        for (int i = 0; i < _videoDataArr.count; i++) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
            NSString * btnStr = [NSString stringWithFormat:@"yes"];
            [self.btnArr replaceObjectAtIndex:i withObject:btnStr];
            [_deleteArr addObjectsFromArray:_pathArray];
            [_delete_Arr addObjectsFromArray:_videoDataArr];
        }
    }else{
        [segmentController.allChoose setTitle:@"全选" forState:UIControlStateNormal];
        [_deleteArr removeAllObjects];
        [_delete_Arr removeAllObjects];
        for (int i = 0; i < _videoDataArr.count; i++) {
            
            NSString * btnStr = [NSString stringWithFormat:@"no"];
            [self.btnArr replaceObjectAtIndex:i withObject:btnStr];
        }
        segmentController.allChoose.selected = NO;
        _choosed = NO;

    }
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark ------截取视频图片第一帧
-(UIImage *) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
//    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
        assetImageGenerator.maximumSize = self.view.frame.size;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];


    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);

    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;

    return thumbnailImage;
}



#pragma mark - TableView 占位图
- (UIImage *)xy_noDataViewImage {
    return [UIImage imageNamed:@"contentnill"];
}

- (NSString *)xy_noDataViewMessage {
    return @"暂无相关视频";
}

- (NSNumber *)xy_noDataViewCenterYOffset
{
    return @10;
}

//==========================lazy loading==========================
#pragma mark - getter&&setter
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}



@end
