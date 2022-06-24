//
//  FileImageController.m
//  ZhongWeiCloud
//
//  Created by 赵金强 on 2017/3/21.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "FileImageController.h"
#import "SegmentViewController.h"
#import "VideoCell_c.h"
#import "HUPhotoBrowser.h"
#import "ZCTabBarController.h"
#import "XLPhotoBrowser.h"
@interface FileImageController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
VideoCell_cDelegate,
SegmentControl_Delegete
>
{
    BOOL _editing;
    BOOL _choosed;
}
@property (nonatomic,strong) UICollectionView * collectionView;
//图片名字数组
@property (nonatomic,strong) NSMutableArray * dataArray;
//图片路径数组
@property (nonatomic,strong) NSMutableArray * imaDataArr;
//要删除的数组
@property (nonatomic,strong) NSMutableArray * deleteArr;
@property (nonatomic,strong) NSMutableArray * delete_Arr;
//路径数组
@property (nonatomic,strong) NSMutableArray * pathArray;
@property (nonatomic,strong) NSMutableArray * btnArr;
@end

@implementation FileImageController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = YES;
    [self addObserver];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    ZCTabBarController *tabVC = (ZCTabBarController *)self.tabBarController;
    tabVC.tabHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = BG_COLOR;
    SegmentViewController *segVc = (SegmentViewController *)self.parentViewController;
    segVc.delegete = self;
    _editing = NO;
    _choosed = NO;
    //返回按钮
    [self cteateNavBtn];
    //创建CollectionView
    [self createCollectionView];
    //数据
    [self createData];
}

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteFileImage) name:@"deleteImage" object:nil];
}

- (void)createData{
    self.btnArr = [NSMutableArray array];
    self.pathArray = [NSMutableArray array];
    self.deleteArr = [NSMutableArray array];
    self.delete_Arr = [NSMutableArray array];
    //删除所有之前存的图片名字
    [self.dataArray removeAllObjects];
    [self.imaDataArr removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时的操作
        //得到所有图片
        self.imaDataArr = [NSMutableArray arrayWithArray:[self getAllImaData]];
        dispatch_async(dispatch_get_main_queue(), ^{
            //页面刷新，也就是将加载好的东西放在那里或者调用什么方法
            [self.collectionView reloadData];
        });
    });
    
}

#pragma mark ------得到所有图片uiimage数组和图片名字
- (NSMutableArray *)getAllImaData
{
    //创建可变数组存放所有图片路径
    NSMutableArray *imaArr = [NSMutableArray array];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        NSString *pathStr = [NSString stringWithFormat:@"/Documents/%@/image",userModel.mobile];
        //1、拼接目录
        NSString *path = [NSHomeDirectory() stringByAppendingString:pathStr];
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager]enumeratorAtPath:path];
        
        for (NSString *fileName in enumerator)
        {
            BOOL isIma = [fileName hasSuffix:@".jpg"];
            NSString * btnStr = [NSString stringWithFormat:@"no"];
            [self.btnArr addObject:btnStr];
            //如果以jpg结尾存入路径到数组
            if (isIma) {
                NSString *imaPath = [NSString stringWithFormat:@"%@/%@",path,fileName];
                [_pathArray insertObject:imaPath atIndex:0];
                UIImage *ima = [[UIImage alloc]initWithContentsOfFile:imaPath];
                
                
                //耗时操作
//                NSData* imageData;
//
//                if (UIImagePNGRepresentation(ima) == nil) {
//                    imageData = UIImageJPEGRepresentation(ima, 1.0);
//                } else {
//                    imageData = UIImagePNGRepresentation(ima);
//                }
                //省时
                NSData *imageData = [[NSData alloc] initWithContentsOfFile:imaPath];
                
                long imageLength = [imageData length];
                //图片存储大小
                NSString* imagestorageStr = [self transformedValue:imageLength];
                //图片分辨率
                CGFloat fixelW = CGImageGetWidth(ima.CGImage);
                CGFloat fixelH = CGImageGetHeight(ima.CGImage);
                NSString *picResolution = [NSString stringWithFormat:@"%.0f × %.0f",fixelW,fixelH];
                
                NSString* resultName = [NSString stringWithFormat:@"%@:%@    %@:%@    %@",NSLocalizedString(@"文件大小", nil),imagestorageStr,NSLocalizedString(@"图片分辨率", nil),picResolution,fileName];//imagestorageStr
                resultName = [resultName substringWithRange:NSMakeRange(0,resultName.length - 6)];
                
                //得到所有图片名字
                [self.dataArray insertObject:resultName atIndex:0];
                //得到所有图片
                [imaArr insertObject:ima atIndex:0];
            }
        }
//        NSLog(@"设备名称：%@",self.dataArray);
        
    }
    return imaArr;
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
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
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
    return self.imaDataArr.count;
}
//创建cell
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VideoCell_c * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.ImageV.image = self.imaDataArr[indexPath.row];
//    cell.nameLabel.text = self.dataArray[indexPath.row];
    cell.playImage.hidden = YES;

    if (_editing == NO) {
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    VideoCell_c *cell = (VideoCell_c *)[collectionView cellForItemAtIndexPath:indexPath];
    if (_editing == NO) {
//        [HUPhotoBrowser showFromImageView:cell.ImageV withImages:self.imaDataArr atIndex:indexPath.row];
//        XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithImages:self.imaDataArr currentImageIndex:indexPath.row];
        XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithImages:self.imaDataArr andImagesName:self.dataArray currentImageIndex:indexPath.row];
        browser.browserStyle = XLPhotoBrowserStyleIndexLabel;

    }else if (_editing == YES){
        if ([self.btnArr[indexPath.row] isEqualToString:@"no"]) {
            NSString * btnStr = [NSString stringWithFormat:@"yes"];
            [self.btnArr replaceObjectAtIndex:indexPath.row withObject:btnStr];
            [_deleteArr addObject:[_pathArray objectAtIndex:indexPath.row]];
            [_delete_Arr addObject:[_imaDataArr objectAtIndex:indexPath.row]];
            [self.collectionView reloadData];
        }else{
            NSString * btnStr = [NSString stringWithFormat:@"no"];
            [self.btnArr replaceObjectAtIndex:indexPath.row withObject:btnStr];
            [_deleteArr removeObject:[_pathArray objectAtIndex:indexPath.row]];
            [_delete_Arr removeObject:[_imaDataArr objectAtIndex:indexPath.row]];
            [self.collectionView reloadData];
        }
        
    }

}
- (void)deleteFileImage{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger index = [defaults integerForKey:@"deleteImageIndex"];
    
//    NSLog(@"删除：%ld",(long)index);
    
    NSString * pathStr = [NSString stringWithFormat:@"%@",_imaDataArr[index]];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:pathStr error:nil];
//    [self createData];
    _editing = NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark ------cell点击代理
- (void)ImageVClick:(VideoCell_c *)cell
{
    
}
//编辑cell
- (BOOL)SegmentControlEditCollectCell:(SegmentViewController *)segmentController{
    if (_imaDataArr.count != 0) {
//        NSLog(@"编辑cell");
        _editing = YES;
        
        self.collectionView.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight - 64 - 60);
        [self.collectionView reloadData];
        return YES;
    }else{
        return NO;
    }
}
//取消编辑
- (void)SegmentControlCancleEdit:(SegmentViewController *)segmentController{
    
//    NSLog(@"取消编辑cell");
    _editing = NO;
    _choosed = NO;
    for (int i = 0; i < _imaDataArr.count; i++) {
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
    if (_delete_Arr.count==0) {
        [XHToast showCenterWithText:@"未选择任何图片"];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除提醒"message:@"确定删除所选图片？删除后无法恢复！"preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
                dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                   
                    for (NSString * pathStr in self.deleteArr) {
                        NSFileManager * fileManager = [NSFileManager defaultManager];
                        [fileManager removeItemAtPath:pathStr error:nil];
                    }
                  
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_imaDataArr removeObjectsInArray:_delete_Arr];
                        [_deleteArr removeAllObjects];
                        [_delete_Arr removeAllObjects];
//                        [self createData];
                        _editing = NO;
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

    NSLog(@"全选cell");
    if (segmentController.allChoose.selected == NO) {
        segmentController.allChoose.selected = YES;
        [segmentController.allChoose setTitle:@"全不选" forState:UIControlStateNormal];
        _choosed = YES;
        [_deleteArr removeAllObjects];
        [_delete_Arr removeAllObjects];
        for (int i = 0; i < _imaDataArr.count; i++) {
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
            
            NSString * btnStr = [NSString stringWithFormat:@"yes"];
            [self.btnArr replaceObjectAtIndex:i withObject:btnStr];
            [_deleteArr addObjectsFromArray:_pathArray];
            [_delete_Arr addObjectsFromArray:_imaDataArr];
        }
    }else{
        [segmentController.allChoose setTitle:@"全选" forState:UIControlStateNormal];
        _choosed = NO;
        [_deleteArr removeAllObjects];
        [_delete_Arr removeAllObjects];
        for (int i = 0; i < _imaDataArr.count; i++) {

            NSString * btnStr = [NSString stringWithFormat:@"no"];
            [self.btnArr replaceObjectAtIndex:i withObject:btnStr];
        }

        segmentController.allChoose.selected = NO;
        _choosed = NO;

    }
    [self.collectionView reloadData];
}

#pragma mark - TableView 占位图
- (UIImage *)xy_noDataViewImage {
    return [UIImage imageNamed:@"contentnull"];
}

- (NSString *)xy_noDataViewMessage {
    return @"暂无相关图片";
}

- (NSNumber *)xy_noDataViewCenterYOffset
{
    return @10;
}

//==========================lazy loading==========================
#pragma mark - getter && setter
- (NSMutableArray *)dataArray
{
    if (!_dataArray){
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


@end
