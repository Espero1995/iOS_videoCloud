//
//  Toast.m
//
//  Created by Yu on 15/7/31.
//

#import "Toast.h"

static const CGFloat ToastCornerRadius        = 10.0;//背景圆角
static const CGFloat ToastOpacity             = 0.70;//背景颜色的透明度

static const CGFloat ToastMaxMessageLines     = 0;//文本行数 0表示无限制
static const CGFloat ToastFontSize            = 15.0;//文本字体大小


static const CGFloat ToastMaxWidth            = 0.8;      // 80% of parent view width
static const CGFloat ToastMaxHeight           = 0.8;      // 80% of parent view height
static const CGFloat ToastHorizontalPadding   = 10.0;
static const CGFloat ToastVerticalPadding     = 10.0;
static const CGFloat ToastMinWidth            = 108.0;

static const NSTimeInterval ToastFadeDuration = 0.2;//动画持续时间
static const NSTimeInterval DefaultDurationTime=2;

static const CGFloat ToastImageSize=55;//图片尺寸
static const CGFloat ToastImageBgSize=60;//图片占位尺寸

@interface Toast ()
{
    CGRect wrapperFrame;
    
    CGRect messageFrame;
    
    CGRect imageFrame;
}

@property(nonatomic,strong)NSTimer *delTimer;//删除timer

@property(nonatomic,strong)UIView *wrapperView;//toast界面

@property(nonatomic,strong)UILabel *messageLabel;//文本

@property(nonatomic,strong)UIImageView *imageView;//图片

@property(assign,nonatomic)ToastStyle defaultStyle;

@property(nonatomic)BOOL isShowLoading;

@property(nonatomic)MBProgressHUD *loadingHUD;

@end

@implementation Toast

@synthesize delTimer;

@synthesize wrapperView;

@synthesize messageLabel;

@synthesize imageView;

+(Toast*)shareInstance
{
    static Toast *mToast=nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        mToast=[[Toast alloc] init];
        
        mToast.defaultStyle=ToastStyleDark;
        
    });
    
    return mToast;
}

///显示纯文字(默认时间2秒)
+(void)showInfo:(NSString*)txt
{
    [[Toast shareInstance] showToast:txt Duration:DefaultDurationTime Image:nil IsDefaultImg:YES];
}

+(void)showLoading:(UIView*)parentView
{
    [Toast showLoading:parentView Tips:NSLocalizedString(@"加载中，请稍候...", nil)];
}

+(void)showLoading:(UIView*)parentView Tips:(NSString*)tips
{
    [[Toast shareInstance] showLoading:parentView Tips:tips];
}

+(void)dissmiss
{
    [[Toast shareInstance] dismiss];
}

+(void)setStyle:(ToastStyle)style
{
    [Toast shareInstance].defaultStyle=style;
}

+(ToastStyle)getStyle
{
    return [Toast shareInstance].defaultStyle;
}

//--------------------------------------------showLoading----------------------------------------------//

-(void)showLoading:(UIView*)parentView Tips:(NSString*)tips
{
    if (!self.isShowLoading) {
        self.loadingHUD = [MBProgressHUD showHUDAddedTo:parentView animated:YES];
        
        if (tips) {
            self.loadingHUD.label.text = tips;
        }
        
        self.loadingHUD.bezelView.backgroundColor=[UIColor blackColor];
        self.loadingHUD.label.textColor=[UIColor whiteColor];
        
        for (UIView *view in self.loadingHUD.bezelView.subviews) {
            if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
                [((UIActivityIndicatorView*)view) setColor:[UIColor whiteColor]];
                break;
            }
        }
        
        self.isShowLoading=YES;
    }
}

-(void)dismiss
{
    if (self.isShowLoading) {
        if (self.loadingHUD) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 [self.loadingHUD hideAnimated:YES];
            });
        }
        self.isShowLoading=NO;
    }
}

//--------------------------------------------method----------------------------------------------//
//--------------------------------------------showView
-(void)showToast:(NSString*)msg Duration:(NSTimeInterval)time Image:(NSString*)image IsDefaultImg:(BOOL)isDefaultImg
{
    if (delTimer!=nil) {
        [delTimer invalidate];
        delTimer=nil;
    }
    
//    UIView *view = [[UIApplication sharedApplication].delegate window];
    UIView *view = [[UIApplication sharedApplication] keyWindow];
    
    if(self.isShowLoading){//加载中时，不显示图片
        image=nil;
    }
    
    if (isDefaultImg) {
        if (image) {
            [self createToastView:view Message:msg Image:[self image:[UIImage imageWithContentsOfFile:[self getImageFromBundle:image]] withTintColor:[self getTextColorForStyle]]];
        }else{
            [self createToastView:view Message:msg Image:nil];
        }
    }else{
        [self createToastView:view Message:msg Image:[UIImage imageNamed:image]];
    }
    
    if(self.isShowLoading){//加载中时，toast显示在下方
        wrapperView.center=CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 4 * 3);
    }else{
        wrapperView.center=CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 2);
    }
    
    [self showToastView:time];
}

//--------------------------------------------createView
-(void)createToastView:(UIView*)view Message:(NSString*)msg Image:(UIImage*)image
{
    //背景
    if (!wrapperView) {
        wrapperView = [[UIView alloc] init];
        
        wrapperView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
        
        wrapperView.layer.cornerRadius = ToastCornerRadius;
        
        [view addSubview:wrapperView];
        
        wrapperView.userInteractionEnabled=NO;
        
        wrapperView.alpha=0.0;
    }
    
    
    wrapperView.backgroundColor = [[self getBgColorForStyle] colorWithAlphaComponent:ToastOpacity];
    
    //文本
    if (!messageLabel) {
        messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = ToastMaxMessageLines;
        messageLabel.font = [UIFont systemFontOfSize:ToastFontSize];
        messageLabel.textAlignment=NSTextAlignmentCenter;
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;//以单词为单位换行，以单词为单位截断。
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.alpha = 1.0;
        
        messageLabel.userInteractionEnabled=NO;
        
        [wrapperView addSubview:messageLabel];
    }else{
        messageLabel.alpha = 0;
    }
    
    messageLabel.textColor = [self getTextColorForStyle];
    messageLabel.text = msg;
    
    //计算尺寸
    CGSize maxSizeMessage = CGSizeMake((view.bounds.size.width * ToastMaxWidth), view.bounds.size.height * ToastMaxHeight);
    
    CGSize expectedSizeMessage = [self sizeForString:msg Font:messageLabel.font ConstrainedToSize:maxSizeMessage LineBreakMode:messageLabel.lineBreakMode];
    
    CGFloat messageWidth = expectedSizeMessage.width;
    CGFloat messageHeight = expectedSizeMessage.height;
    
    CGFloat wrapperWidth =messageWidth + ToastHorizontalPadding*2;
    CGFloat wrapperHeight =messageHeight + ToastVerticalPadding*2;
    
    if (wrapperWidth<ToastMinWidth) {
        wrapperWidth=ToastMinWidth;
        messageWidth=wrapperWidth-ToastHorizontalPadding*2;
    }
    
    CGFloat imageWidth=0;
    CGFloat imageHeight=0;
    
    //图片
    if (image) {
        if (!imageView) {
            imageView=[[UIImageView alloc] init];
            imageView.contentMode=UIViewContentModeScaleAspectFit;
            
            imageView.userInteractionEnabled=NO;
            
            [wrapperView addSubview:imageView];
        }else{
            imageView.alpha=0;
        }
        imageFrame=CGRectMake((wrapperWidth-ToastImageSize)/2, ToastHorizontalPadding+(ToastImageBgSize-ToastImageSize)/2, ToastImageSize, ToastImageSize);
        [imageView setImage:image];
        imageWidth=ToastImageBgSize;
        imageHeight=ToastImageBgSize;
    }else{
        if (imageView) {
            [imageView removeFromSuperview];
            imageView=nil;
        }
    }
    
    wrapperHeight =wrapperHeight+imageHeight;
    
    wrapperFrame=CGRectMake(0, 0, wrapperWidth, wrapperHeight);
    
    messageFrame=CGRectMake(ToastHorizontalPadding, ToastVerticalPadding+imageHeight, messageWidth, messageHeight);
    ;
}

//--------------------------------------------showOrHide
-(void)showToastView:(NSTimeInterval)time
{
    if (wrapperView==nil) {
        return;
    }
    [UIView animateWithDuration:ToastFadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         wrapperView.frame=wrapperFrame;
                         wrapperView.alpha = 1.0;
                         messageLabel.frame=messageFrame;
                         messageLabel.alpha=1.0;
                         if (imageView) {
                             imageView.frame=imageFrame;
                             imageView.alpha=1.0;
                         }
                         if(self.isShowLoading){//加载中时，toast显示在下方
                             wrapperView.center=CGPointMake([wrapperView superview].bounds.size.width / 2, [wrapperView superview].bounds.size.height / 4 * 3);
                         }else{
                             wrapperView.center=CGPointMake([wrapperView superview].bounds.size.width / 2, [wrapperView superview].bounds.size.height / 2);
                         }
                     } completion:^(BOOL finished) {
                         
                         if (delTimer!=nil) {
                             [delTimer invalidate];
                             delTimer=nil;
                         }
                         
                         delTimer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(hideToastView) userInfo:nil repeats:NO];
                         
                     }];
}

-(void)hideToastView
{
    if (wrapperView==nil) {
        return;
    }
    [UIView animateWithDuration:ToastFadeDuration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         wrapperView.alpha = 0.0;
                         messageLabel.alpha=0.0;
                         if (imageView) {
                             imageView.alpha=0.0;
                         }
                     } completion:^(BOOL finished) {
                         [self destoryToast];
                     }];
}

//--------------------------------------------destoryMethod
-(void)destoryToast
{
    if (delTimer!=nil) {
        [delTimer invalidate];
        delTimer=nil;
    }
    if (messageLabel!=nil) {
        [messageLabel removeFromSuperview];
        messageLabel=nil;
    }
    if (imageView!=nil) {
        [imageView removeFromSuperview];
        imageView=nil;
    }
    if (wrapperView!=nil) {
        [wrapperView removeFromSuperview];
        wrapperView=nil;
    }
}

///根据Style获取背景颜色
-(UIColor*)getBgColorForStyle
{
    if (!self.defaultStyle) {
        return [UIColor blackColor];
    }
    if (self.defaultStyle==ToastStyleLight) {
        return [UIColor whiteColor];
    }
    return [UIColor blackColor];
}

///根据Style获取文字颜色
-(UIColor*)getTextColorForStyle
{
    if (!self.defaultStyle) {
        return [UIColor whiteColor];
    }
    if (self.defaultStyle==ToastStyleLight) {
        return [UIColor blackColor];
    }
    return [UIColor whiteColor];
}

///在Bundle中获取图片
-(NSString*)getImageFromBundle:(NSString*)name
{
    NSBundle *bundle = [NSBundle bundleForClass:Toast.class];
    NSURL *url = [bundle URLForResource:@"Toast" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];
    NSString *path = [imageBundle pathForResource:name ofType:@"png"];
    return path;
}

///改变图片颜色
-(UIImage*)image:(UIImage*)image withTintColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [image drawInRect:rect];
    CGContextSetFillColorWithColor(c, [color CGColor]);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextFillRect(c, rect);
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

///获取字体宽度和高度
-(CGSize)sizeForString:(NSString *)string Font:(UIFont *)font ConstrainedToSize:(CGSize)constrainedSize LineBreakMode:(NSLineBreakMode)lineBreakMode
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
    CGRect boundingRect = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    //ceilf   如果参数是小数，则求最小的整数但不小于本身
    return CGSizeMake(ceilf(boundingRect.size.width), ceilf(boundingRect.size.height));
}

//--------------------------------------------delegate----------------------------------------------//

#pragma MBProgressHUDDelegate
-(void)hudWasHidden:(MBProgressHUD *)hud
{
    
}

@end
