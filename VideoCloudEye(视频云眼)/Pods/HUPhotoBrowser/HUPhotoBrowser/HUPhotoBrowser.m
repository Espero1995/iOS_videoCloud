//
//  HUPhotoBrowser.m
//  HUPhotoBrowser
//
//  Created by mac on 16/2/24.
//  Copyright (c) 2016年 jinhuadiqigan. All rights reserved.
//

#import "HUPhotoBrowser.h"
#import "HUPhotoBrowserCell.h"
#import "hu_const.h"
#import "HUWebImage.h"
#import "HUToast.h"

#define AnimateDuration     0.4
@interface HUPhotoBrowser () <UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout> {
    CGRect _endTempFrame;
    NSInteger _currentPage;
    NSIndexPath *_zoomingIndexPath;
    BOOL _imageDidLoaded;
    BOOL _animationCompleted;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *tmpImageView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *toolBar;
@property (nonatomic, weak) UILabel *countLab;
@property (nonatomic, strong) NSArray *URLStrings;
@property (nonatomic) NSInteger index;
@property (nonatomic) NSInteger imagesCount;
@property (nonatomic, copy) DismissBlock dismissDlock;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) UIView * backView;
@property (nonatomic, strong) UIButton * backButton;
@property(nonatomic,copy)void (^ shareButtonClickBlock)(NSInteger index);

@end

@implementation HUPhotoBrowser

- (void)dealloc {
    self.collectionView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)showFromImageView:(UIImageView *)imageView withURLStrings:(NSArray *)URLStrings placeholderImage:(UIImage *)image atIndex:(NSInteger)index dismiss:(DismissBlock)block {
    HUPhotoBrowser *browser = [[HUPhotoBrowser alloc] initWithFrame:kScreenRect];
    browser.imageView = imageView;
    browser.URLStrings = URLStrings;
    browser.imagesCount = URLStrings.count;
    [browser resetCountLabWithIndex:index+1];
    [browser configureBrowser];
    [browser animateImageViewAtIndex:index];
    browser.placeholderImage = image;
    browser.dismissDlock = block;
    
    return browser;
}


+ (instancetype)showFromImageView:(UIImageView *)imageView withImages:(NSArray *)images atIndex:(NSInteger)index dismiss:(DismissBlock)block {
    HUPhotoBrowser *browser = [[HUPhotoBrowser alloc] initWithFrame:kScreenRect];
    browser.imageView = imageView;
    browser.images = images;
    browser.imagesCount = images.count;
    [browser resetCountLabWithIndex:index+1];
    [browser configureBrowser];
    [browser animateImageViewAtIndex:index];
    browser.dismissDlock = block;
    
    return browser;
}

+ (instancetype)showFromImageView:(UIImageView *)imageView withURLStrings:(NSArray *)URLStrings atIndex:(NSInteger)index {
    
    return [self showFromImageView:imageView withURLStrings:URLStrings placeholderImage:nil atIndex:index dismiss:nil];
}

+ (instancetype)showFromImageView:(UIImageView *)imageView withImages:(NSArray *)images atIndex:(NSInteger)index {
    return [self showFromImageView:imageView withImages:images atIndex:index dismiss:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        [self addSubview:self.collectionView];
        
        [self setupToolBar];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadForScreenRotate) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoCellDidZooming:) name:kPhotoCellDidZommingNotification object:nil];
        
    }
    return self;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (self.URLStrings) {
        count = _URLStrings.count;
    }
    else if (self.images) {
        count = _images.count;
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HUPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoBrowserCellID forIndexPath:indexPath];
    cell.indexPath = indexPath;
    [cell resetZoomingScale];
    __weak __typeof(self) wself = self;
    cell.tapActionBlock = ^(UITapGestureRecognizer *sender) {
        [wself dismiss];
    };
    if (self.URLStrings) {
        NSURL *url = [NSURL URLWithString:self.URLStrings[indexPath.row]];
        if (indexPath.row != _index) {
            [cell.imageView hu_setImageWithURL:url placeholderImage:_placeholderImage];
        }
        else {
            UIImage *placeHolder = _tmpImageView.image;
            [cell.imageView hu_setImageWithURL:url placeholderImage:placeHolder completed:^(UIImage *image, NSError *error, NSURL *imageUrl) {
                if (!_imageDidLoaded) {
                    _imageDidLoaded = YES;
                    if (_animationCompleted) {
                        self.collectionView.hidden = NO;
                        [_tmpImageView removeFromSuperview];
                        _animationCompleted = NO;
                    }
                    
                }
            }];
        }
    }
    else if (self.images) {
        cell.imageView.image = self.images[indexPath.row];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return kScreenRect.size;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _currentPage = scrollView.contentOffset.x/kScreenWidth + 0.5;
    _countLab.text = [NSString stringWithFormat:@"%zd/%zd",_currentPage+1,_imagesCount];
    
    if (_zoomingIndexPath) {
        [self.collectionView reloadItemsAtIndexPaths:@[_zoomingIndexPath]];
        _zoomingIndexPath = nil;
    }
    
}

#pragma mark - notification handler

- (void)reloadForScreenRotate {
    _collectionView.frame = kScreenRect;
    
    [self.collectionView reloadData];
    self.collectionView.contentOffset = CGPointMake(kScreenWidth * _currentPage,0);
}

- (void)photoCellDidZooming:(NSNotification *)nofit {
    NSIndexPath *indexPath = nofit.object;
    _zoomingIndexPath = indexPath;
}

#pragma mark - getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.hidden = YES;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        
    }
    return _collectionView;
}

#pragma mark - private

- (void)configureBrowser {
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[HUPhotoBrowserCell class] forCellWithReuseIdentifier:kPhotoBrowserCellID];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)setupToolBar {
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-38, self.frame.size.width, 30)];
    _toolBar.backgroundColor = [UIColor clearColor];
    [self addSubview:_toolBar];
    
    UILabel *countLab = [[UILabel alloc] init];
    countLab.textColor = [UIColor whiteColor];
    countLab.layer.cornerRadius = 2;
    countLab.layer.masksToBounds = YES;
    countLab.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.4];
    countLab.font = [UIFont systemFontOfSize:13];
    countLab.textAlignment = NSTextAlignmentCenter;
    [_toolBar addSubview:countLab];
    _countLab = countLab;
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(_toolBar.frame.size.width-58, 1, 50, 28);
    deleteBtn.layer.cornerRadius = 2;
    [deleteBtn setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.4]];
    //    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [deleteBtn setImage:[UIImage imageNamed:@"delete_share"] forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [deleteBtn addTarget:self action:@selector(deleteImage) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:deleteBtn];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(_toolBar.frame.size.width-123, 1, 50, 28);
    shareBtn.layer.cornerRadius = 2;
    [shareBtn setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.4]];
    [shareBtn setImage:[UIImage imageNamed:@"fenxiang"] forState:UIControlStateNormal];
    [shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    shareBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [shareBtn addTarget:self action:@selector(shareImage) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:shareBtn];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(_toolBar.frame.size.width-188, 1, 50, 28);
    saveBtn.layer.cornerRadius = 2;
    [saveBtn setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.4]];
    [saveBtn setImage:[UIImage imageNamed:@"hold"] forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [saveBtn addTarget:self action:@selector(saveImae) forControlEvents:UIControlEventTouchUpInside];
    [_toolBar addSubview:saveBtn];
    
}
- (void)deleteImage{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"deleteImage" object:nil];
}
- (void)shareImage{
    [self setup];
}
- (void)setup{
    _toolBar.hidden = YES;
    _backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _backView.alpha = 1;
    _backView.backgroundColor = [UIColor clearColor];
    [self addSubview:_backView];
    //弹出菜单，添加半透明背景
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = CGRectMake(0, 0,kScreenWidth, kScreenHeight);
    _backButton.alpha = 0.3;
    _backButton.backgroundColor = [UIColor blackColor];
    [_backButton addTarget:self action:@selector(backViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.backView addSubview:_backButton];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.backView];
    CGFloat width = (self.bounds.size.width-200)/3;
    UIView * whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - 150, self.bounds.size.width, 150)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self.backButton addSubview:whiteView];
    UIButton * cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleBtn.frame = CGRectMake(0, 10+width, self.bounds.size.width, 140-width);
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancleBtn.layer.cornerRadius = 0.5f;
    cancleBtn.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor grayColor]);
    [cancleBtn addTarget:self action:@selector(backViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    [whiteView addSubview:cancleBtn];
    NSMutableArray *shareTitleArray = [[NSMutableArray alloc]initWithObjects:@"QQ",@"微信",@"朋友圈",nil];
    NSMutableArray *shareIconArray = [[NSMutableArray alloc]initWithObjects:@"QQ_n",@"weixin_n",@"pengyou_n",nil];
    
    
    for (int i = 0; i < shareIconArray.count; i ++) {
        
        UIButton *itemView = [UIButton buttonWithType:UIButtonTypeCustom];
        itemView.frame = CGRectMake(50*(i+1)+i*width,10,width,width+10);
        itemView.backgroundColor = [UIColor clearColor];
        itemView.tag = i;
        [itemView addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        [whiteView addSubview:itemView];
        
        //图标
        UIImageView *icon = [[UIImageView alloc]init];
        icon.frame = CGRectMake(10, 0,width-20,width-20);
        icon.backgroundColor = [UIColor clearColor];
        icon.image = [UIImage imageNamed:shareIconArray[i]];
        [itemView addSubview:icon];
        
        //标题
        UILabel *title = [[UILabel alloc]init];
        title.frame = CGRectMake(10, width-20, width-20,20);
        title.font = [UIFont systemFontOfSize:13];
        title.backgroundColor = [UIColor clearColor];
        title.text = shareTitleArray[i];
        title.textColor = [UIColor blackColor];
        title.textAlignment = NSTextAlignmentCenter;
        [itemView addSubview:title];
        
    }
}

- (void)backViewClicked:(id)sender{
    [self hide];
}

- (void)show{
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:_backView];
    [[[UIApplication sharedApplication] keyWindow] insertSubview:_backView aboveSubview:_backButton];
    
    [UIView animateWithDuration:AnimateDuration animations:^{
        
        self.backView.frame = CGRectMake(0, kScreenWidth - 200, kScreenHeight, 200);
        
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)hide{
    _toolBar.hidden = NO;
    [_backButton removeFromSuperview];
    
    [UIView animateWithDuration:AnimateDuration animations:^{
        
        self.backView.frame = CGRectMake(0, kScreenWidth,kScreenHeight,200);
        
    } completion:^(BOOL finished) {
        
    }];
    
    
}

- (void)share:(id)sender{
    UIButton *button = (UIButton *)sender;
    if (self.shareButtonClickBlock) {
        self.shareButtonClickBlock(button.tag);
        
    }
    HUPhotoBrowserCell *cell = (HUPhotoBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage inSection:0]];
    UIImage *shareImage = cell.imageView.image;
    if (button.tag==0) {
        NSLog(@"分享QQ");
    }else if(button.tag == 1){
        NSLog(@"分享微信");
    }else if (button.tag == 2){
        NSLog(@"分享朋友圈             ");
    }
}

- (void)animateImageViewAtIndex:(NSInteger)index {
    _index = index;
    CGRect startFrame = [self.imageView.superview convertRect:self.imageView.frame toView:[UIApplication sharedApplication].keyWindow];
    CGRect endFrame = kScreenRect;
    
    if (self.imageView.image) {
        UIImage *image = self.imageView.image;
        CGFloat ratio = image.size.width / image.size.height;
        
        if (ratio > kScreenRatio) {
            
            endFrame.size.width = kScreenWidth;
            endFrame.size.height = kScreenWidth / ratio;
            
        } else {
            endFrame.size.height = kScreenHeight;
            endFrame.size.width = kScreenHeight * ratio;
            
        }
        endFrame.origin.x = (kScreenWidth - endFrame.size.width) / 2;
        endFrame.origin.y = (kScreenHeight - endFrame.size.height) / 2;
        
    }
    
    _endTempFrame = endFrame;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
#endif
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:startFrame];
    tempImageView.image = self.imageView.image;
    tempImageView.contentMode = UIViewContentModeScaleAspectFit;
    [[UIApplication sharedApplication].keyWindow addSubview:tempImageView];
    _tmpImageView = tempImageView;
    
    if (self.URLStrings && !self.images) {
        NSString *key = [HUWebImageDownloader cacheKeyForURL:[NSURL URLWithString:self.URLStrings[_index]]];
        UIImage *image = [HUWebImageDownloader imageFromDiskCacheForKey:key];
        _imageDidLoaded = image != nil;
    }
    [self.collectionView setContentOffset:CGPointMake(kScreenWidth * index,0) animated:NO];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        tempImageView.frame = endFrame;
        
    } completion:^(BOOL finished) {
        _currentPage = index;
        _animationCompleted = YES;
        if (self.images || _imageDidLoaded || (self.URLStrings && !_imageDidLoaded)) {
            self.collectionView.hidden = NO;
            [tempImageView removeFromSuperview];
            _animationCompleted = NO;
        }
        
    }];
    
    
}

- (void)dismiss {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
#endif
    
    if (self.dismissDlock) {
        HUPhotoBrowserCell *cell = (HUPhotoBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage inSection:0]];
        self.dismissDlock(cell.imageView.image, _currentPage);
    }
    
    if (_currentPage != _index) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            
            [self removeFromSuperview];
        }];
        return;
    }
    
    CGRect endFrame = [self.imageView.superview convertRect:self.imageView.frame toView:[UIApplication sharedApplication].keyWindow];
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithFrame:_endTempFrame];
    tempImageView.image = self.imageView.image;
    tempImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.collectionView.hidden = YES;
    
    [[UIApplication sharedApplication].keyWindow addSubview:tempImageView];
    
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        tempImageView.frame = endFrame;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        [tempImageView removeFromSuperview];
        
    }];
    
}

- (void)resetCountLabWithIndex:(NSInteger)index {
    
    NSString *text = [NSString stringWithFormat:@"%zd%zd",_imagesCount,_imagesCount];
    CGFloat width = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}].width+8;
    _countLab.frame = CGRectMake(8, 1, MAX(50, width), 28);
    _countLab.text = [NSString stringWithFormat:@"%zd/%zd",index,_imagesCount];
}

- (void)saveImae {
    HUPhotoBrowserCell *cell = (HUPhotoBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage inSection:0]];
    UIImage *seavedImage = cell.imageView.image;
    if (seavedImage) {
        UIImageWriteToSavedPhotosAlbum(seavedImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    }
    
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    NSString *msg = nil ;
    if(error != nil){
        msg = @"保存图片失败";
    }
    else{
        msg = @"保存图片成功";
    }
    [HUToast showToastWithMsg:msg];
}

@end
