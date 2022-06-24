//
//  EnlargeimageView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/8/17.
//  Copyright © 2018年 张策. All rights reserved.
//

#import "EnlargeimageView.h"
@interface EnlargeimageView ()
<
    UIScrollViewDelegate
>
@property (nonatomic,strong) UIScrollView *scanImg;//放大的图片
@property (nonatomic,strong) UIView *enlargeImageView;
@end

@implementation EnlargeimageView

- (instancetype)initWithframe:(CGRect) frame
{
    self = [super initWithFrame:CGRectMake(0, 0, iPhoneWidth, iPhoneHeight)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


#pragma mark - 放大图片
- (void)enlargeImageClick
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    
    CGFloat bili = (CGFloat)(70.000/105.000);
    
    [self addSubview:self.scanImg];
    [self.scanImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, iPhoneWidth*bili));
    }];
    
    [self.scanImg addSubview:self.enlargeImageView];
    [self.enlargeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.scanImg.mas_centerX);
        make.centerY.equalTo(self.scanImg.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, iPhoneWidth*bili));
    }];
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    imageView.userInteractionEnabled = YES;
    [self.enlargeImageView addSubview:imageView];
    imageView.image = self.enlargeImage;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.enlargeImageView.mas_centerX);
        make.centerY.equalTo(self.enlargeImageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(iPhoneWidth, iPhoneWidth*bili));
    }];
    
}


#pragma mark - 手势触控
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self enlargeImageShowDismiss];
}
#pragma mark - 图片消失
- (void)enlargeImageShowDismiss
{
    [self.scanImg removeFromSuperview];
    [self.enlargeImageView removeFromSuperview];
    self.scanImg = nil;
    self.enlargeImageView = nil;
    [self removeFromSuperview];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.enlargeImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect frame = self.enlargeImageView.frame;
    frame.origin.x = (self.scanImg.frame.size.width - self.enlargeImageView.frame.size.width) > 0 ? (self.scanImg.frame.size.width - self.enlargeImageView.frame.size.width) * 0.5 : 0;
    frame.origin.y = (self.scanImg.frame.size.height - self.enlargeImageView.frame.size.height) > 0 ? (self.scanImg.frame.size.height - self.enlargeImageView.frame.size.height) * 0.5 : 0;
    self.enlargeImageView.frame = frame;
    self.scanImg.contentSize = CGSizeMake(self.enlargeImageView.frame.size.width, self.enlargeImageView.frame.size.height);
}


- (UIScrollView *)scanImg
{
    if (!_scanImg) {
        _scanImg = [[UIScrollView alloc]initWithFrame:CGRectZero];
        _scanImg.minimumZoomScale = 1.f;
        _scanImg.maximumZoomScale = 5.f;
        _scanImg.showsHorizontalScrollIndicator = NO;
        _scanImg.showsVerticalScrollIndicator = NO;
        _scanImg.delegate = self;
    }
    return _scanImg;
}

- (UIView *)enlargeImageView
{
    if (!_enlargeImageView) {
        _enlargeImageView = [[UIView alloc]initWithFrame:CGRectZero];
        _enlargeImageView.backgroundColor = [UIColor clearColor];
    }
    return _enlargeImageView;
}


@end
