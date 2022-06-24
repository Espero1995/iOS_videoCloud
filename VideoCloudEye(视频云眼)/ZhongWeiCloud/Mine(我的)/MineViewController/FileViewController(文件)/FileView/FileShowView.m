//
//  FileShowView.m
//  ZhongWeiCloud
//
//  Created by Espero on 2018/10/26.
//  Copyright © 2018 张策. All rights reserved.
//

#import "FileShowView.h"
#import "UIImage+GIF.h"
@interface FileShowView()
<
    UIScrollViewDelegate
>
{
    BOOL _isAppear;
}

@property (nonatomic,strong) UIButton *backBtn;
@property (nonatomic,strong) UILabel *titleLb;
@property (nonatomic,strong) UIImageView *showImg;
@property (nonatomic,strong) UILabel *detailsLb;
@property (nonatomic,strong) UIView *toolBarView;
@property (nonatomic,strong) UIScrollView *scrollView;
@end
@implementation FileShowView

- (instancetype)initWithframe:(CGRect) frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.scrollView];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(iPhoneWidth, iPhoneHeight));
        }];
        
        [self.scrollView addSubview:self.showImg];
        
        [self addSubview:self.backBtn];
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(0);
            make.top.equalTo(self.mas_top).offset(iPhoneNav_StatusHeight-44);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
        [self addSubview:self.titleLb];
        [self.titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.backBtn.mas_centerY);
        }];
        
        [self addSubview:self.toolBarView];
        //图片信息展示
        [self.toolBarView addSubview:self.detailsLb];
        [self.detailsLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.toolBarView.mas_top).offset(1);
            make.left.equalTo(self.toolBarView.mas_left).offset(5);
            make.right.equalTo(self.toolBarView.mas_right).offset(-5);
            make.height.equalTo(@60);
        }];
        
        //分享按钮
        UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        shareBtn.frame = CGRectMake(self.toolBarView.frame.size.width-55, self.toolBarView.frame.size.height - 35, 50, 28);
        [shareBtn setImage:[UIImage imageNamed:@"fenxiang"] forState:UIControlStateNormal];
        [shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        shareBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [shareBtn addTarget:self action:@selector(shareFileClick) forControlEvents:UIControlEventTouchUpInside];
        [self.toolBarView addSubview:shareBtn];
        //保存按钮
        UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        saveBtn.frame = CGRectMake(self.toolBarView.frame.size.width-100, self.toolBarView.frame.size.height - 35, 50, 28);
        [saveBtn setImage:[UIImage imageNamed:@"hold"] forState:UIControlStateNormal];
        [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        saveBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [saveBtn addTarget:self action:@selector(downLoadFileClick) forControlEvents:UIControlEventTouchUpInside];
        [self.toolBarView addSubview:saveBtn];
        
        _isAppear = 1;
        //添加点击手势 消失工具条
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapGesture:)];
//        [self addGestureRecognizer:tap];
        
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapGesture:)];
        [singleTapGestureRecognizer setNumberOfTapsRequired:1];
        [self addGestureRecognizer:singleTapGestureRecognizer];

        
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapGesture:)];
        [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
        [self addGestureRecognizer:doubleTapGestureRecognizer];
        //这行很关键，意思是只有当没有检测到doubleTapGestureRecognizer 或者 检测doubleTapGestureRecognizer失败，singleTapGestureRecognizer才有效
        [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
        
    }
    
    return self;
}

//==========================method==========================
#pragma mark - 显示
- (void)setFileViewShow
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1.0f];
    [UIView animateWithDuration:0. animations:^{
        self.frame = CGRectMake(0, 0, iPhoneWidth, iPhoneHeight);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - 消失
- (void)setPopUpViewShowDismiss{
    //动画效果淡出
    [UIView animateWithDuration:0. animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        self.frame = CGRectMake(0, 0, 0, 0);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


//==========================method==========================
- (void)setFileModelInfo:(FileModel *)model
{
    self.fileModel = model;
    NSLog(@"model的路径：%@",model.filePath);
    if (model.type == 0) {//视频
        NSString *filePath = [NSString stringWithFormat:@"%@",[FileTool getFilePath:model.filePath]];
        self.detailsLb.text = [self getDescFileInfo:model.createTime andFilePath:filePath];
    }else if (model.type == 1){//图片
        NSString *filePath = [NSString stringWithFormat:@"%@",[FileTool getFilePath:model.filePath]];
        self.showImg.image = [[UIImage alloc]initWithContentsOfFile:filePath];
        self.titleLb.text = model.name;
        if (model.createTime) {
            NSString *desc = [NSString stringWithFormat:@"%@:jpeg    %@:%@    %@:%@",NSLocalizedString(@"文件格式", nil),NSLocalizedString(@"截图时间", nil),model.createTime,NSLocalizedString(@"关联设备通道", nil),model.name];
            self.detailsLb.text = [self getDescFileInfo:desc andFilePath:filePath];
        }
        
    }else{//GIF
        NSString *filePath = [NSString stringWithFormat:@"%@",[FileTool getFilePath:model.filePath]];
        NSData *imageData = [NSData dataWithContentsOfFile:filePath];
//        NSLog(@"data:%@",imageData);
        UIImage *image = [UIImage sd_animatedGIFWithData:imageData];
        self.showImg.image = image;
        self.titleLb.text = NSLocalizedString(@"时光相册", nil);
        if (model.createTime) {
            NSString *desc = [NSString stringWithFormat:@"%@:gif  %@:%@  %@:%@",NSLocalizedString(@"文件格式", nil),NSLocalizedString(@"下载时间", nil),model.createTime,NSLocalizedString(@"关联设备通道", nil),model.name];
            self.detailsLb.text = [self getDescFileInfo:desc andFilePath:filePath];
        }
        
    }
    
}



#pragma mark - 获取文件的一些数据信息
- (NSString *)getDescFileInfo:(NSString*)desc andFilePath:(NSString *)filePath
{
    //省时
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    long dataLength = [data length];
    UIImage *ima = [[UIImage alloc]initWithContentsOfFile:filePath];
    //图片存储大小
    NSString *storageStr = [self transformedValue:dataLength];
    NSString* resultName;
    if (self.fileModel.type == 0) {
        resultName = [NSString stringWithFormat:@"%@:%@    %@",NSLocalizedString(@"文件大小", nil),storageStr,desc];
    }else{
        //图片分辨率
        CGFloat fixelW = CGImageGetWidth(ima.CGImage);
        CGFloat fixelH = CGImageGetHeight(ima.CGImage);
        NSString *picResolution = [NSString stringWithFormat:@"%.0f × %.0f",fixelW,fixelH];
        resultName = [NSString stringWithFormat:@"%@:%@  %@:%@  %@",NSLocalizedString(@"文件大小", nil),storageStr,NSLocalizedString(@"图片分辨率", nil),picResolution,desc];
    }

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

#pragma mark - 关闭筛选消息视图
- (void)closeFileViewClick
{
    [self setPopUpViewShowDismiss];
}

#pragma mark - 下载文件
- (void)downLoadFileClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(downLoadFile:)]) {
        [self.delegate downLoadFile:self.fileModel];
    }
}

#pragma mark - 分享功能
- (void)shareFileClick
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareFile:)]) {
        [self.delegate shareFile:self.fileModel];
    }
}


#pragma mark - 点击手势
- (void)singleTapGesture:(UITapGestureRecognizer *)tap{
    if (_isAppear) {
        [self videoViewBackanimation];
        _isAppear = 0;
        
    }else{
        [self videoViewBackHidden];
        _isAppear = 1;
    }
}

#pragma mark - 点击按钮背景渐变效果
- (void)videoViewBackanimation
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.backBtn.hidden = NO;
        self.titleLb.hidden = NO;
        self.detailsLb.hidden = NO;
        self.toolBarView.hidden = NO;
    } completion:^(BOOL finished) {
        if (finished) {
            [self performSelector:@selector(videoViewBackHidden) withObject:nil afterDelay:5];
            _isAppear = 0;
        }
    }];
}

- (void)videoViewBackHidden
{
    [UIView animateWithDuration:0.3 animations:^{
        self.backBtn.hidden = YES;
        self.titleLb.hidden = YES;
        self.detailsLb.hidden = YES;
        self.toolBarView.hidden = YES;
        _isAppear = 1;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }];
}

- (void)doubleTapGesture:(UITapGestureRecognizer *)tap
{
    if (self.scrollView.zoomScale > 1.0) {// 已经放大 现在缩小
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
    else {
        // 已经缩小 现在放大
        // 方法一 以point为中心点进行放大
        CGPoint point = [tap locationInView:self.scrollView];
        CGRect zoomRect = [self zoomRectForScrollView:self.scrollView withScale:2.5 withCenter:point];
        [self.scrollView zoomToRect:zoomRect animated:YES];
        // 方法二 也可以通过这种方法 来放大 这种是直接放大 以scrollView的中心点
//        [self.scrollView setZoomScale:2.5 animated:YES];
    }
}


/**
 该方法返回的矩形适合传递给zoomToRect:animated:方法。
 
 @param scrollView UIScrollView实例
 @param scale 新的缩放比例（通常zoomScale通过添加或乘以缩放量而从现有的缩放比例派生而来)
 @param center 放大缩小的中心点
 @return zoomRect 是以内容视图为坐标系
 */
- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}


//==========================delegate==========================
//缩放的代理方法
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.showImg;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGRect frame = self.showImg.frame;
    frame.origin.y = (self.scrollView.frame.size.height - self.showImg.frame.size.height) > 0 ? (self.scrollView.frame.size.height - self.showImg.frame.size.height) * 0.5 : 0;
    frame.origin.x = (self.scrollView.frame.size.width - self.showImg.frame.size.width) > 0 ? (self.scrollView.frame.size.width - self.showImg.frame.size.width) * 0.5 : 0;
    self.showImg.frame = frame;
    
    self.scrollView.contentSize = CGSizeMake(self.showImg.frame.size.width, self.showImg.frame.size.height);
}


#pragma mark - getter && setter
//返回按钮
- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [[UIButton alloc]init];
        [_backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(closeFileViewClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}
//title
- (UILabel *)titleLb
{
    if (!_titleLb) {
        _titleLb = [[UILabel alloc]init];
        _titleLb.textColor = [UIColor whiteColor];
    }
    return _titleLb;
}
//展示图片
- (UIImageView *)showImg
{
    if (!_showImg) {
        _showImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, (iPhoneHeight-iPhoneWidth/1.5)/2, iPhoneWidth, iPhoneWidth/1.5)];
    }
    return _showImg;
}
//描述信息
- (UILabel *)detailsLb
{
    if (!_detailsLb) {
        _detailsLb = [[UILabel alloc]init];
        _detailsLb.font = FONT(14);
        _detailsLb.textColor = [UIColor whiteColor];
        _detailsLb.numberOfLines = 0;
        _detailsLb.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _detailsLb;
}

//工具条
- (UIView *)toolBarView
{
    if (!_toolBarView) {
        if (iPhone_X_) {
            _toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-120, self.frame.size.width, 100)];
        }else{
          _toolBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-100, self.frame.size.width, 100)];
        }
        [_toolBarView setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.5]];
    }
    return _toolBarView;
}

#pragma mark - scrollView
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 5.0;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

@end
