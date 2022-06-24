//
//  HomeShareView.m
//  mb
//
//  Created by Boris on 2018/5/21.
//  Copyright © 2018年 laborc. All rights reserved.
//

#import "HomeShareView.h"
#import "HomeShareCollectionCell.h"
#import "Masonry.h"
#import "UIView+MJ.h"
#define kHomeShareCollectionCell @"HomeShareCollectionCell"
#define backViewWidth ([UIScreen mainScreen].bounds.size.width - 80)
@interface HomeShareView()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSString *_title;
}
@property (nonatomic, strong) NSMutableArray *titleSource;
@property (nonatomic, strong) NSMutableArray *imgeSource;
@end

@implementation HomeShareView

@synthesize shareWindow;

-(NSMutableArray *)titleSource
{
    if (!_titleSource) {
        self.titleSource = [NSMutableArray array];
    }
    return _titleSource;
}

- (NSMutableArray *)imgeSource
{
    if (!_imgeSource) {
        self.imgeSource = [NSMutableArray array];
    }
    return _imgeSource;
}

- (UIWindow *)shareWindow {
    if(!shareWindow) {
        shareWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        shareWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        shareWindow.userInteractionEnabled = YES;
        [shareWindow makeKeyAndVisible];
    }
    return shareWindow;
}


- (UIView *)backView
{
    if (!_backView) {
        self.backView = [UIView new];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.layer.masksToBounds = YES;
        _backView.layer.cornerRadius = 10;
    }
    return _backView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        self.titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _titleLabel;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout alloc] ;
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        self.collectionView = [[UICollectionView alloc] initWithFrame:(CGRectZero) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.scrollEnabled = NO;
        _collectionView.collectionViewLayout =layout;
        _collectionView.backgroundColor = [UIColor whiteColor];
//        _collectionView.backgroundColor = [UIColor redColor];
        [_collectionView registerClass:[HomeShareCollectionCell class] forCellWithReuseIdentifier:kHomeShareCollectionCell];

        
    }
    return _collectionView;
}


- (UIButton *)cancleBtn
{
    if (!_cancleBtn) {
        self.cancleBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_cancleBtn addTarget:self action:@selector(tapGestureAction) forControlEvents:(UIControlEventTouchUpInside)];
        [_cancleBtn setImage:[UIImage imageNamed:@"H5ShareCancelBtn"] forState:(UIControlStateNormal)];
    }
    return _cancleBtn;
}


+ (HomeShareView *)shareView{
    static dispatch_once_t once;
    static HomeShareView *sharedView;
    dispatch_once(&once, ^ {
        sharedView = [[HomeShareView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        sharedView.backgroundColor = [UIColor  colorWithWhite:0.3 alpha:0.5];
    });
    return sharedView;
}



+ (void)showWithTitle:(NSString *)title titArray:(NSArray *)titleArray imgArray:(NSArray *)imgArray select:(void(^)(NSInteger row))indexBlock
{
 
    NSMutableArray *titSource = [NSMutableArray arrayWithArray:titleArray];
    NSMutableArray *imgSource = [NSMutableArray arrayWithArray:imgArray];
    [[HomeShareView shareView] showWithTag:title titArray:titSource imgArray:imgSource select:^(NSInteger row) {
        indexBlock ? indexBlock(row) : nil;
    }];
}


- (void)showWithTag:(NSString *)title titArray:(NSArray *)titleArray imgArray:(NSArray *)imgArray select:(void(^)(NSInteger row))indexBlock
{
    _title = title;
    if(!self.superview){
        [self.shareWindow addSubview:self];
    }
    [self.titleSource removeAllObjects];
    [self.titleSource addObjectsFromArray:titleArray];
    [self.imgeSource removeAllObjects];
    [self.imgeSource addObjectsFromArray:imgArray];
    [self addSubview:self.backView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.collectionView];
    [self addSubview:self.cancleBtn];
    [self makeSubViewsLayout];
    self.alpha = 1;
    
    if (indexBlock) {
        self.block = ^(NSInteger row) {
            indexBlock(row);
        };
    }
    
}


- (void)tapGestureAction {
    [self dismiss];
}


- (void)dismiss{
    
    NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
    [windows removeObject:shareWindow];
    shareWindow = nil;
    [self.backView removeFromSuperview];
    self.backView = nil;
    [self.titleLabel removeFromSuperview];
    self.titleLabel = nil;
    [self.collectionView removeFromSuperview];
    self.collectionView = nil;
    [self.cancleBtn removeFromSuperview];
    self.cancleBtn = nil;
    [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
        if([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
            [window makeKeyWindow];
            *stop = YES;
        }
    }];
    
}




// 给控件做约束
- (void)makeSubViewsLayout
{
    
    int rowCount = self.titleSource.count % 3 == 0 ? 0 : 1 + (int)self.titleSource.count / 3;
    CGFloat titleHeight = (_title.length == 0 || _title == nil) ? 0 : [self returnHeightWithString:_title width:backViewWidth size:14];
    CGFloat easyHeight = (_title.length == 0 || _title == nil) ? 6 : 16;

    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(40);
        make.right.equalTo(self.mas_right).offset(-40);
        make.centerY.equalTo(self.mas_centerY).offset(-30);
        make.height.mas_equalTo(easyHeight + titleHeight + 40 + backViewWidth/3 * 0.9 * rowCount);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX).offset(0);
        make.width.mas_equalTo(180);
        make.top.equalTo(self.backView.mas_top).offset(easyHeight);
        make.height.mas_equalTo(titleHeight);
    }];
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.text = _title;
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backView.mas_left);
        make.right.equalTo(self.backView.mas_right);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.bottom.mas_equalTo(self.backView.mas_bottom).offset(-10);
    }];

    [self.cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.backView.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    
    
    
}

#pragma mark collection
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.titleSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HomeShareCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHomeShareCollectionCell forIndexPath:indexPath];
    cell.headerImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", self.imgeSource[indexPath.row]]];
    cell.conLabel.text = self.titleSource[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return  CGSizeMake(backViewWidth/3, backViewWidth/3 * 0.9);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(15, 0, 5, 0);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.block) {
        [self tapGestureAction];
        self.block(indexPath.row);
    }
}

// 根据字符串自适应高度
- (CGFloat)returnHeightWithString:(NSString *)str width:(CGFloat)width size:(CGFloat)size
{
    CGRect r = [str boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:size]} context:nil];
    return r.size.height;
}


@end
