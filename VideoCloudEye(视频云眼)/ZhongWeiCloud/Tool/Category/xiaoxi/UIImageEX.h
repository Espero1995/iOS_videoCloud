//
//  UIImageEX.h
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@interface UIImage (EX)

+ (UIImage*) imageWithIconFont:(NSString*) title size:(CGFloat)fontsize color:(UIColor *)color;

+ (UIImage *) alphaImage:(CGFloat)alpha width:(CGFloat)width height:(CGFloat)height;

+ (UIImage *)imageWithColor:(UIColor *)color withSize:(CGSize)size;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size andCornerRadius:(CGFloat)radius;    /// added by minjie, to create round corner images for buttons


+ (UIImage *)imageFromBase64String:(NSString *)string;

- (UIImage*)iconImageWithWidth:(double)width height:(double)height cornerRadius:(double)radius;
- (UIImage*)iconImageWithWidth:(double)width height:(double)height cornerRadius:(double)radius border:(double)border borderColor:(UIColor*)color;

- (UIImage*)iconImageWithWidth:(double)width cornerRadius:(double)radius;
//- (UIImage*)iconImageWithWidth:(double)width andCornerRadius:(double)radius border:(double)border borderColor:(UIColor*)color;

//上圆角
- (UIImage *)topCornerWithWidth:(double)width height:(double)height cornerRadius:(double)radius;

//下圆角
- (UIImage *)bottomCornerWithWidth:(double)width height:(double)height cornerRadius:(double)radius;

//中间不变 两边拉伸
- (UIImage *)stretchableBothSides:(CGFloat)left width:(CGFloat)toWidth;

//上下不变 拉中间
- (UIImage *)stretchableTopBottom:(int)top height:(CGFloat)toHeight local:(BOOL)isLocal;

- (UIImage*)circleImage;
- (UIImage*)grayImage;
- (UIImage*)linghtImage;
- (UIImage*)scaleToSize:(CGSize)size;
- (UIImage*)scaleToSize:(CGSize)size tiled:(BOOL)tiled;
- (UIImage*)stackBlur:(NSUInteger)inradius;

- (UIImage *)addCorner:(UIImage *)cornerIcon;

- (UIImage *)imageByApplyingAlpha:(CGFloat) alpha;
+ (UIImage *)constuctImageWithColor:(UIColor *)originColor toSize:(CGSize)size;
/**
 修正照片方向,图片创建是必须带scale和orientation参数
 */
- (UIImage *)fixOrientation;
//- (UIImage *)fixOrientationWithOrientation:(UIImageOrientation )orientation;  ///<  直接取图片的方向，有时是不正确的，必须要从asset里面取

+(UIImage*)imageFromSampleBuffer:(CMSampleBufferRef)nextBuffer;
+(UIImage*)cropImage:(UIImage*)originalImage withRect:(CGRect)inRect;
+(UIImage*)getSafeImage:(UIImage*)inImg;

+ (CGRect)convertCropRect:(CGRect)cropRect forImage:(UIImage*)inImage;

/**
 Image drawn with bazier path.
 @param path The bezier path to draw.
 @param color The stroke color for bezier path.
 @param backgroundColor The fill color for bezier path.
 */
+ (UIImage *)imageWithBezierPath:(UIBezierPath *)path color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;

+ (UIImage *)roundedImageWithSize:(CGSize)size color:(UIColor *)color radius:(CGFloat)radius;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

- (UIImage *)clipImageWithPath:(CGMutablePathRef)path;

- (UIImage *)mergeImagesAndRects:(UIImage *)firstImage, ... NS_REQUIRES_NIL_TERMINATION;

- (UIImage *)mergeImage:(UIImage *)imageB atPoint:(CGPoint)startPoint alpha:(float)alpha;

+ (UIImage *)generatePureColorImage:(UIColor*)color size:(CGSize)size;

//add by ywt
- (UIImage*)scaleImageToScale:(float)scaleSize;
- (UIImage *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize;
- (NSData *)compressImageData:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize;

+ (NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize;
//add by guming
#pragma mark 等比率缩放
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;
#pragma mark 裁剪图片 自适应某个view
+ (UIImage *)cutImage:(UIImage*)image custView:(UIView *)view;
+ (UIImage *)cutImage:(UIImage *)image ToSize:(CGSize)size;
@end
