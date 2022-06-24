//
//  UIImageEX.m
//

#import "UIImageEX.h"

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

void clipRoundRectangle(CGContextRef context,CGRect rrect,CGFloat radius)
{
    CGContextBeginPath(context);
	// In order to create the 4 arcs correctly, we need to know the min, mid and max positions
	// on the x and y lengths of the given rectangle.
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy    1       9       5
	// maxy    8       7       6
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
	
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	// Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	// Close the path
	CGContextClosePath(context);
    
    CGContextClip(context);
    
}

void clipTopCornerRectangle(CGContextRef context,CGRect rrect,CGFloat radius)
{
    CGContextBeginPath(context);
	// In order to create the 4 arcs correctly, we need to know the min, mid and max positions
	// on the x and y lengths of the given rectangle.
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect),maxy = CGRectGetMaxY(rrect);
	
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy    1       9       5
	// maxy    8       7       6
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
	
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, 0);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, 0);
    // Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	// Close the path
	CGContextClosePath(context);
    
    CGContextClip(context);
    
}

void clipBottomCornerRectangle(CGContextRef context,CGRect rrect,CGFloat radius)
{
    CGContextBeginPath(context);
	// In order to create the 4 arcs correctly, we need to know the min, mid and max positions
	// on the x and y lengths of the given rectangle.
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect),maxy = CGRectGetMaxY(rrect);
	
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy    1       9       5
	// maxy    8       7       6
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
	
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    // Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, 0);
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, 0);
	// Close the path
	CGContextClosePath(context);
    
    CGContextClip(context);
    
}

@implementation UIImage (EX)

+ (UIImage*) imageWithIconFont:(NSString*) title size:(CGFloat)fontsize color:(UIColor *)color
{
    UILabel *iconFontLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fontsize, fontsize)];
    iconFontLabel.font = [UIFont fontWithName:@"iconfont" size:fontsize];
    iconFontLabel.textAlignment = UITextAlignmentCenter;
    iconFontLabel.backgroundColor = [UIColor clearColor];
    [iconFontLabel setTextColor:color];
    iconFontLabel.text = title;
    
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(fontsize, fontsize), NO, [[UIScreen mainScreen] scale]);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [iconFontLabel.layer renderInContext:context];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


+ (UIImage *)imageFromBase64String:(NSString *)string
{
    NSData *_decodedImageData = [[NSData alloc] initWithBase64EncodedString:string options:0];
    return [UIImage imageWithData:_decodedImageData];
}

+ (UIImage *)alphaImage:(CGFloat)alpha width:(CGFloat)width height:(CGFloat)height
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();   //1
	CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);  //2
    
    // And draw with a blue fill color
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, alpha);
    CGContextSetLineWidth(context, 0);
    CGContextAddRect(context, CGRectMake(0, 0, width, height));
    CGContextDrawPath(context, kCGPathFillStroke);
    
	CGImageRef cgimg = CGBitmapContextCreateImage(context);
    UIImage * img = [UIImage imageWithCGImage:cgimg];
    
	if(cgimg)
    {
        CGImageRelease(cgimg);
    }
    
	if(context)
    {
        CGContextRelease (context);
    }
	if(colorSpace)
    {
        CGColorSpaceRelease(colorSpace);
    }
    
    return img;
}
- (UIImage*)iconImageWithWidth:(double)width height:(double)height cornerRadius:(double)radius border:(double)border borderColor:(UIColor*)color
{

    CGFloat scale = [UIScreen mainScreen].scale;
	width = width*scale;
    height = height * scale;
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();   //1
	CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace,kCGImageAlphaPremultipliedFirst);  //2
    
    clipRoundRectangle(context, CGRectMake(0, 0, width, height), radius);
    
    CGRect drawRect = CGRectZero;
    drawRect.origin.x = border;
    drawRect.origin.y = border;
    drawRect.size.width = width - 2* border;
    drawRect.size.height = height - 2 * border;
    CGContextDrawImage(context, drawRect, self.CGImage);
    
    
	CGImageRef cgimg = CGBitmapContextCreateImage(context);
	UIImage *img = [UIImage imageWithCGImage:cgimg];
    
	if(cgimg)
    {
        CGImageRelease(cgimg);
    }
    
	if(context)
    {
        CGContextRelease (context);
    }
	if(colorSpace)
    {
        CGColorSpaceRelease(colorSpace);
    }
    
	return img;
    
}
- (UIImage*)iconImageWithWidth:(double)width cornerRadius:(double)radius border:(double)border borderColor:(UIColor*)color {
	
	CGFloat scale = [UIScreen mainScreen].scale;
    width = width*scale;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();//1
	CGContextRef context = CGBitmapContextCreate(nil, width, width, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);//2
    
	CGSize imgSize = self.size;
	CGFloat mid = width/2;
	
#define useContext 1
    
    if (radius > 0.0f)
    {
        // use context
#if useContext
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0, 0); //3
        CGContextAddLineToPoint(context, 0, 1);
        
        CGContextMoveToPoint(context, 0, 1);
        CGContextMoveToPoint(context, 0, 2);
        
        CGContextAddArcToPoint(context, 0, 0, mid, 0, radius);
        CGContextAddArcToPoint(context, width, 0, width, mid, radius);
        CGContextAddArcToPoint(context, width, width, mid, width, radius);
        CGContextAddArcToPoint(context, 0, width, 0, mid, radius);
        CGContextClosePath(context) ;                                              //4
#else
        // use path
        CGMutablePathRef paths = CGPathCreateMutable();
        CGPathMoveToPoint(paths, nil, 0, mid);
        CGPathAddArcToPoint(paths, nil, 0, 0, mid, 0, radius);
        CGPathAddArcToPoint(paths,nil, width, 0, width, mid, radius);
        CGPathAddArcToPoint(paths,nil, width, width, mid, width, radius);
        CGPathAddArcToPoint(paths,nil,0, width, 0, mid, radius);
        CGContextAddPath(context, paths);
        CGPathRelease(paths);
#endif
        
        CGContextClip(context);
    }
                                       //5
    
    if (radius > 0.0f || border > 0.0f)
    {
        CGContextSetStrokeColorWithColor(context, color.CGColor);                  //6
        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0, mid);
        CGContextAddArcToPoint(context, 0, 0, mid, 0, radius);
        CGContextAddArcToPoint(context, width, 0, width, mid, radius);
        CGContextAddArcToPoint(context, width, width, mid, width, radius);
        CGContextAddArcToPoint(context, 0, width, 0, mid, radius);
        CGContextClosePath(context);
        CGContextSetLineWidth(context, border);
        CGContextDrawPath(context,kCGPathFillStroke);
    }
    
	if(imgSize.width>imgSize.height){
		double rate = imgSize.width/imgSize.height;
        
		CGContextDrawImage(context, CGRectMake(floor(-(rate-1)/2*width)+border, border, floor(rate*width)-2*border, floor(width)-2*border), self.CGImage);
	}
	else{
		double rate = imgSize.height/imgSize.width;
        
		CGContextDrawImage(context, CGRectMake(0+border, floor(-(rate-1)/2*width)+border, floor(width)-2*border, floor(rate*width)-2*border), self.CGImage);
	}
    
	CGImageRef cgimg = CGBitmapContextCreateImage(context);
	UIImage *img = [UIImage imageWithCGImage:cgimg];
    
	if(cgimg) CGImageRelease(cgimg);
	if(context) CGContextRelease (context);
	if(colorSpace) CGColorSpaceRelease(colorSpace);
    
	return img;
}

- (UIImage*)circleImage
{
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGSize size = [self size];
	
    CGFloat width = size.width * scale;
	CGFloat height = size.height * scale;
	    
    CGFloat radius = width <= height ? width/2:height/2;
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(nil, radius*2, radius*2, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    
	CGContextBeginPath(context);
	CGContextAddArc(context,radius,radius,radius,0,2*M_PI,1);
	CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, radius*2, radius*2), self.CGImage);
    
	CGImageRef cgimg = CGBitmapContextCreateImage(context);
	UIImage *img = [UIImage imageWithCGImage:cgimg];

	if(cgimg) CGImageRelease(cgimg);
	if(context) CGContextRelease (context);
	if(colorSpace) CGColorSpaceRelease(colorSpace);
    
	return img;
}

- (UIImage*)iconImageWithWidth:(double)width height:(double)height cornerRadius:(double)radius
{
    return [self iconImageWithWidth:width height:height cornerRadius:radius border:0.0 borderColor:[UIColor clearColor]];
}

- (UIImage*)iconImageWithWidth:(double)width cornerRadius:(double)radius{
	return [self iconImageWithWidth:width cornerRadius:radius border:0.0 borderColor:[UIColor clearColor]];
}

- (UIImage *)topCornerWithWidth:(double)width height:(double)height cornerRadius:(double)radius
{
    CGFloat scale = [UIScreen mainScreen].scale;
    width  = width * scale;
    height = height * scale;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();   //1
	CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace,kCGImageAlphaPremultipliedFirst);  //2
    
    clipTopCornerRectangle(context, CGRectMake(0, 0, width, height), radius);
    
    CGRect drawRect = CGRectZero;
    drawRect.origin.x = 0;
    drawRect.origin.y = 0;
    drawRect.size.width = width;
    drawRect.size.height = height;
    CGContextDrawImage(context, drawRect, self.CGImage);
    
	CGImageRef cgimg = CGBitmapContextCreateImage(context);
	UIImage *img = [UIImage imageWithCGImage:cgimg];

	if(cgimg)
    {
        CGImageRelease(cgimg);
    }
    
	if(context)
    {
        CGContextRelease (context);
    }
	if(colorSpace)
    {
        CGColorSpaceRelease(colorSpace);
    }
    
	return img;
}

- (UIImage *)bottomCornerWithWidth:(double)width height:(double)height cornerRadius:(double)radius
{
    CGFloat scale = [UIScreen mainScreen].scale;
    width = width * scale;
    height = height * scale;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();   //1
	CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace,kCGImageAlphaPremultipliedFirst);  //2
    
    clipBottomCornerRectangle(context, CGRectMake(0, 0, width, height), radius);
    
    CGRect drawRect = CGRectZero;
    drawRect.origin.x = 0;
    drawRect.origin.y = 0;
    drawRect.size.width = width;
    drawRect.size.height = height;
    CGContextDrawImage(context, drawRect, self.CGImage);
    
	CGImageRef cgimg = CGBitmapContextCreateImage(context);
	UIImage *img = [UIImage imageWithCGImage:cgimg];
    
	if(cgimg)
    {
        CGImageRelease(cgimg);
    }
    
	if(context)
    {
        CGContextRelease (context);
    }
	if(colorSpace)
    {
        CGColorSpaceRelease(colorSpace);
    }
    
	return img;
}

-(UIImage*)grayImage{
	
    
    CGSize size = [self size];
	
    //	int _tmp = 1 ;
    //	DeviceType _type = [[MSFImagePool defaultPool] deviceVersion];
    //
    //	if(DeviceiPhone4 == _type || DeviceiPodTouch4G == _type) _tmp = 2 ;
    //
    int width = size.width ;
	int height = size.height ;
	
	if ([self respondsToSelector:@selector(scale)]) {
		int scale = 2;
		width = width*scale;
		height = height*scale;
	}
	
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
	
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
	
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    //  CGContextDrawImage(context, CGRectMake(0, 0, width, height), img.CGImage);
	
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
			
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
			
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
	
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
	
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
	if (pixels) {
        free(pixels);
	}
	UIImage *resultUIImage = nil;
	if ([self respondsToSelector:@selector(scale)]) {
		resultUIImage = [UIImage imageWithCGImage:image scale:2 orientation:[self imageOrientation]];
	}else {
		resultUIImage = [UIImage imageWithCGImage:image];
	}
    
    
	
    // we're done with image now too
	if (image) {
		CGImageRelease(image);
	}
    
	
    return resultUIImage;
}

-(UIImage*)linghtImage{
	
	
    CGSize size = [self size];
	
	
    int width = size.width ;
	int height = size.height;
	if ([self respondsToSelector:@selector(scale)]) {
		int scale = 2;
		width = scale * width;
		height = scale *height;
	}
	
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
	
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
	
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    //  CGContextDrawImage(context, CGRectMake(0, 0, width, height), img.CGImage);
	
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
			
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            float _gray = 0.8f;
			
            uint32_t gray = _gray * rgbaPixel[RED] + _gray * rgbaPixel[GREEN] + _gray * rgbaPixel[BLUE];
			
            // set the pixels to gray
            //rgbaPixel[ALPHA] = 0.5f ;
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
	
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
	
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
	if (pixels) {
		free(pixels);
	}
	
	
    // make a new UIImage to return
    UIImage *resultUIImage = nil;
	if ([self respondsToSelector:@selector(scale)]) {
		resultUIImage = [UIImage imageWithCGImage:image scale:2 orientation:[self imageOrientation]];
	}else {
		resultUIImage= [UIImage imageWithCGImage:image];
	}
    
	
	
    // we're done with image now too
	if (image) {
		CGImageRelease(image);
	}
	
	
    return resultUIImage;
}

-(UIImage*)scaleToSize:(CGSize)size
{
    return [self scaleToSize:size tiled:NO];
}

- (UIImage*)scaleToSize:(CGSize)size tiled:(BOOL)tiled
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);

    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, size.width, size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, 1.0);
    if (tiled) {
        CGContextDrawTiledImage(ctx, area, self.CGImage);
    } else {
        CGContextDrawImage(ctx, area, self.CGImage);
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage*) stackBlur:(NSUInteger)inradius
{
	int radius = (int)inradius; // Transform unsigned into signed for further operations
	
	if (radius<1){
		return self;
	}
	
    //	return [other applyBlendFilter:filterOverlay  other:self context:nil];
	// First get the image into your data buffer
	
	CGImageRef inImage = self.CGImage;
	CFDataRef m_DataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    int w = (int)CGImageGetWidth(inImage);
	int h = (int)CGImageGetHeight(inImage);
    
    int length = (int)CFDataGetLength(m_DataRef);
    if(length == w*h){//如果是8位图 不处理
        return self;
    }
    
	UInt8 * m_PixelBuf = (UInt8 *) CFDataGetBytePtr(m_DataRef);
	CGContextRef ctx = CGBitmapContextCreate(m_PixelBuf,
											 CGImageGetWidth(inImage),
											 CGImageGetHeight(inImage),
											 CGImageGetBitsPerComponent(inImage),
											 CGImageGetBytesPerRow(inImage),
											 CGImageGetColorSpace(inImage),
											 CGImageGetBitmapInfo(inImage)
											 );
	
    
    
	int wm=w-1;
	int hm=h-1;
	int wh=w*h;
	int div=radius+radius+1;
	
	int *r=malloc(wh*sizeof(int));
	int *g=malloc(wh*sizeof(int));
	int *b=malloc(wh*sizeof(int));
	memset(r,0,wh*sizeof(int));
	memset(g,0,wh*sizeof(int));
	memset(b,0,wh*sizeof(int));
	int rsum,gsum,bsum,x,y,i,p,yp,yi,yw;
	int *vmin = malloc(sizeof(int)*MAX(w,h));
	memset(vmin,0,sizeof(int)*MAX(w,h));
	int divsum=(div+1)>>1;
	divsum*=divsum;
	int *dv=malloc(sizeof(int)*(256*divsum));
	for (i=0;i<256*divsum;i++){
		dv[i]=(i/divsum);
	}
	
	yw=yi=0;
	
	int *stack=malloc(sizeof(int)*(div*3));
	int stackpointer;
	int stackstart;
	int *sir;
	int rbs;
	int r1=radius+1;
	int routsum,goutsum,boutsum;
	int rinsum,ginsum,binsum;
	memset(stack,0,sizeof(int)*div*3);
	
	for (y=0;y<h;y++){
		rinsum=ginsum=binsum=routsum=goutsum=boutsum=rsum=gsum=bsum=0;
		
		for(int i=-radius;i<=radius;i++){
			sir=&stack[(i+radius)*3];
			/*			p=m_PixelBuf[yi+MIN(wm,MAX(i,0))];
			 sir[0]=(p & 0xff0000)>>16;
			 sir[1]=(p & 0x00ff00)>>8;
			 sir[2]=(p & 0x0000ff);
			 */
			int offset=(yi+MIN(wm,MAX(i,0)))*4;
			sir[0]=m_PixelBuf[offset];
			sir[1]=m_PixelBuf[offset+1];
			sir[2]=m_PixelBuf[offset+2];
			
			rbs=r1-abs(i);
			rsum+=sir[0]*rbs;
			gsum+=sir[1]*rbs;
			bsum+=sir[2]*rbs;
			if (i>0){
				rinsum+=sir[0];
				ginsum+=sir[1];
				binsum+=sir[2];
			} else {
				routsum+=sir[0];
				goutsum+=sir[1];
				boutsum+=sir[2];
			}
		}
		stackpointer=radius;
		
		
		for (x=0;x<w;x++){
			r[yi]=dv[rsum];
			g[yi]=dv[gsum];
			b[yi]=dv[bsum];
			
			rsum-=routsum;
			gsum-=goutsum;
			bsum-=boutsum;
			
			stackstart=stackpointer-radius+div;
			sir=&stack[(stackstart%div)*3];
			
			routsum-=sir[0];
			goutsum-=sir[1];
			boutsum-=sir[2];
			
			if(y==0){
				vmin[x]=MIN(x+radius+1,wm);
			}
			
			/*			p=m_PixelBuf[yw+vmin[x]];
			 
			 sir[0]=(p & 0xff0000)>>16;
			 sir[1]=(p & 0x00ff00)>>8;
			 sir[2]=(p & 0x0000ff);
			 */
			int offset=(yw+vmin[x])*4;
			sir[0]=m_PixelBuf[offset];
			sir[1]=m_PixelBuf[offset+1];
			sir[2]=m_PixelBuf[offset+2];
			rinsum+=sir[0];
			ginsum+=sir[1];
			binsum+=sir[2];
			
			rsum+=rinsum;
			gsum+=ginsum;
			bsum+=binsum;
			
			stackpointer=(stackpointer+1)%div;
			sir=&stack[((stackpointer)%div)*3];
			
			routsum+=sir[0];
			goutsum+=sir[1];
			boutsum+=sir[2];
			
			rinsum-=sir[0];
			ginsum-=sir[1];
			binsum-=sir[2];
			
			yi++;
		}
		yw+=w;
	}
	for (x=0;x<w;x++){
		rinsum=ginsum=binsum=routsum=goutsum=boutsum=rsum=gsum=bsum=0;
		yp=-radius*w;
		for(i=-radius;i<=radius;i++){
			yi=MAX(0,yp)+x;
			
			sir=&stack[(i+radius)*3];
			
			sir[0]=r[yi];
			sir[1]=g[yi];
			sir[2]=b[yi];
			
			rbs=r1-abs(i);
			
			rsum+=r[yi]*rbs;
			gsum+=g[yi]*rbs;
			bsum+=b[yi]*rbs;
			
			if (i>0){
				rinsum+=sir[0];
				ginsum+=sir[1];
				binsum+=sir[2];
			} else {
				routsum+=sir[0];
				goutsum+=sir[1];
				boutsum+=sir[2];
			}
			
			if(i<hm){
				yp+=w;
			}
		}
		yi=x;
		stackpointer=radius;
		for (y=0;y<h;y++){
			//			m_PixelBuf[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
			int offset=yi*4;
			m_PixelBuf[offset]=dv[rsum];
			m_PixelBuf[offset+1]=dv[gsum];
			m_PixelBuf[offset+2]=dv[bsum];
			rsum-=routsum;
			gsum-=goutsum;
			bsum-=boutsum;
			
			stackstart=stackpointer-radius+div;
			sir=&stack[(stackstart%div)*3];
			
			routsum-=sir[0];
			goutsum-=sir[1];
			boutsum-=sir[2];
			
			if(x==0){
				vmin[y]=MIN(y+r1,hm)*w;
			}
			p=x+vmin[y];
			
			sir[0]=r[p];
			sir[1]=g[p];
			sir[2]=b[p];
			
			rinsum+=sir[0];
			ginsum+=sir[1];
			binsum+=sir[2];
			
			rsum+=rinsum;
			gsum+=ginsum;
			bsum+=binsum;
			
			stackpointer=(stackpointer+1)%div;
			sir=&stack[(stackpointer)*3];
			
			routsum+=sir[0];
			goutsum+=sir[1];
			boutsum+=sir[2];
			
			rinsum-=sir[0];
			ginsum-=sir[1];
			binsum-=sir[2];
			
			yi+=w;
		}
	}
	free(r);
	free(g);
	free(b);
	free(vmin);
	free(dv);
	free(stack);
	CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	
	//	CFRelease(m_DataRef);
	UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);	
	CFRelease(m_DataRef);
	return finalImage;
}

- (UIImage *)addCorner:(UIImage *)cornerIcon
{
    CGSize size = [self size];
    int width = size.width ;
	int height = size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();   //1
	CGContextRef context = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpace,kCGImageAlphaPremultipliedFirst);  //2
    
    // And draw with a blue fill color
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), self.CGImage);
    
    CGSize cornerSize = cornerIcon.size;
    CGContextDrawImage(context, CGRectMake(width - cornerSize.width, 0, cornerSize.width, cornerSize.height), cornerIcon.CGImage);
    
	CGImageRef cgimg = CGBitmapContextCreateImage(context);
    UIImage * img = [UIImage imageWithCGImage:cgimg];
    
	if(cgimg)
    {
        CGImageRelease(cgimg);
    }
    
	if(context)
    {
        CGContextRelease (context);
    }
	if(colorSpace)
    {
        CGColorSpaceRelease(colorSpace);
    }
    
    return img;
}

- (UIImage *)stretchableBothSides:(CGFloat)left width:(CGFloat)toWidth
{
    CGSize size = [self size];
    
    if(left > size.width)
    {
        return self;
    }
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat contextWidth = toWidth * scale;
    CGFloat width = size.width * scale ;
    CGFloat height = size.height * scale;
    CGFloat offset = left * scale;
    CGFloat centerWidth = (width - offset*2);//中间宽
    
    CGRect rect1 = CGRectMake(0, 0, offset, height);
    CGImageRef imageRef1 = CGImageCreateWithImageInRect(self.CGImage, rect1);
    
    CGRect rect2 = CGRectMake(offset, 0, centerWidth, height);
    CGImageRef imageRef2 = CGImageCreateWithImageInRect(self.CGImage, rect2);
   
    CGRect rect3 = CGRectMake(offset + centerWidth, 0, offset, height);
    CGImageRef imageRef3 = CGImageCreateWithImageInRect(self.CGImage, rect3);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();   //1
	CGContextRef context = CGBitmapContextCreate(nil, contextWidth, height, 8, 0, colorSpace,kCGImageAlphaPremultipliedFirst);  //2
    
    width = (contextWidth  - centerWidth)/2;
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef1);
    CGContextDrawImage(context, CGRectMake(width, 0, centerWidth, height), imageRef2);
    CGContextDrawImage(context, CGRectMake(width + centerWidth, 0, width, height), imageRef3);
    
	CGImageRef cgimg = CGBitmapContextCreateImage(context);
    UIImage * img = [UIImage imageWithCGImage:cgimg];
    
	if (cgimg) CGImageRelease(cgimg);
	if (context) CGContextRelease (context);
	if (colorSpace) CGColorSpaceRelease(colorSpace);
    if (imageRef1) CGImageRelease(imageRef1);
    if (imageRef2) CGImageRelease(imageRef2);
    if (imageRef3) CGImageRelease(imageRef3);
    
    return img;
}

//中间不变 上下拉伸
- (UIImage *)stretchableTopBottom:(int)top height:(CGFloat)toHeight local:(BOOL)isLocal
{
    CGSize size = [self size];
    
    if(top > size.height)
    {
        return self;
    }
    CGFloat scale = 0;
    if(isLocal)
    {
        scale = self.scale;
    }
    else
    {
       scale = [[UIScreen mainScreen] scale]; 
    }
    
    CGFloat contextHeight = toHeight * scale;
    CGFloat width = size.width * scale ;
    CGFloat height = size.height * scale;
    CGFloat offsetY = top * scale;
    CGFloat topHeight = offsetY;
    CGFloat centerHeight = (height - offsetY*2);//中间高
    
    CGRect rect1 = CGRectMake(0, 0, width, offsetY);
    CGImageRef imageRef1 = CGImageCreateWithImageInRect(self.CGImage, rect1);
    
    CGRect rect2 = CGRectMake(0, offsetY, width, centerHeight);
    CGImageRef imageRef2 = CGImageCreateWithImageInRect(self.CGImage, rect2);
    
    CGRect rect3 = CGRectMake(0,offsetY + centerHeight, width, offsetY);
    CGImageRef imageRef3 = CGImageCreateWithImageInRect(self.CGImage, rect3);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();   //1
	CGContextRef context = CGBitmapContextCreate(nil, width, contextHeight, 8, 0, colorSpace,kCGImageAlphaPremultipliedLast);  //2

    height = topHeight;
    offsetY = contextHeight - height;
    CGContextDrawImage(context, CGRectMake(0 , offsetY, width, height), imageRef1);
    
    height = contextHeight - topHeight*2;
    offsetY -= height;
    CGContextDrawImage(context, CGRectMake(0, offsetY, width, height), imageRef2);
    

    height = topHeight;
    offsetY -= height;
    CGContextDrawImage(context, CGRectMake(0, offsetY, width, height), imageRef3);

	CGImageRef cgimg = CGBitmapContextCreateImage(context);
    UIImage * img = [UIImage imageWithCGImage:cgimg];
    
	if (cgimg) CGImageRelease(cgimg);
	if (context) CGContextRelease (context);
	if (colorSpace) CGColorSpaceRelease(colorSpace);
    if (imageRef1) CGImageRelease(imageRef1);
    if (imageRef2) CGImageRelease(imageRef2);
    if (imageRef3) CGImageRelease(imageRef3);
    
    return img;
}

+ (UIImage *)constuctImageWithColor:(UIColor *)originColor toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGRect drawRect = CGRectMake(0, 0, size.width, size.height);
    [originColor set];
    UIRectFill(drawRect);
    UIImage *drawnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return drawnImage;
}

- (UIImage *)imageByApplyingAlpha:(CGFloat) alpha
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color withSize:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


// 修正照片方向
- (UIImage *)fixOrientation
{    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp)
        return self;
    
    return [self fixOrientationWithOrientation:self.imageOrientation];
}

- (UIImage *)fixOrientationWithOrientation:(UIImageOrientation)orientation
{
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (orientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (orientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+(UIImage*)imageFromSampleBuffer:(CMSampleBufferRef)nextBuffer;
{
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(nextBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    // Get the number of bytes per row for the pixel buffer.
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height.
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space.
    static CGColorSpaceRef colorSpace = NULL;
    if (colorSpace == NULL) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace == NULL) {
            // Handle the error appropriately.
            return nil;
        }
    }
    
    // Get the base address of the pixel buffer.
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
    // Create a Quartz direct-access data provider that uses data we supply.
    CGDataProviderRef dataProvider =
    CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    // Create a bitmap image from data supplied by the data provider.
    CGImageRef cgImage =
    CGImageCreate(width, height, 8, 32, bytesPerRow,
                  colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                  dataProvider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    
    // Create and return an image object to represent the Quartz image.
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0f orientation:UIImageOrientationRight];
    CGImageRelease(cgImage);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}


+ (CGRect)convertCropRect:(CGRect)cropRect forImage:(UIImage*)inImage{
    UIImage *originalImage = inImage;
    
    CGSize size = originalImage.size;
    CGFloat x = cropRect.origin.x;
    CGFloat y = cropRect.origin.y;
    CGFloat width = cropRect.size.width;
    CGFloat height = cropRect.size.height;
    UIImageOrientation imageOrientation = originalImage.imageOrientation;
    if (imageOrientation == UIImageOrientationRight || imageOrientation == UIImageOrientationRightMirrored) {
        cropRect.origin.x = y;
        cropRect.origin.y = size.width - cropRect.size.width - x;
        cropRect.size.width = height;
        cropRect.size.height = width;
    } else if (imageOrientation == UIImageOrientationLeft || imageOrientation == UIImageOrientationLeftMirrored) {
        cropRect.origin.x = size.height - cropRect.size.height - y;
        cropRect.origin.y = x;
        cropRect.size.width = height;
        cropRect.size.height = width;
    } else if (imageOrientation == UIImageOrientationDown || imageOrientation == UIImageOrientationDownMirrored) {
        cropRect.origin.x = size.width - cropRect.size.width - x;;
        cropRect.origin.y = size.height - cropRect.size.height - y;
    }
    
    return cropRect;
}

+(UIImage*)cropImage:(UIImage*)originalImage withRect:(CGRect)inRect;
{
    CGRect theRect  = inRect;
    theRect.size.width = ((int)inRect.size.width+4)/8*8;
    theRect.size.height = ((int)inRect.size.height+4)/8*8;
    theRect.origin.x += (inRect.size.width-theRect.size.width)/2;
    theRect.origin.y += (inRect.size.height-theRect.size.height)/2;
    CGRect actualRect = [UIImage convertCropRect:theRect forImage:originalImage];
    CGImageRef croppedCGImage = CGImageCreateWithImageInRect(originalImage.CGImage ,actualRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedCGImage scale:1.0f orientation:originalImage.imageOrientation];
    CGImageRelease(croppedCGImage);
    
    return croppedImage;
}

+ (UIImage*)getSafeImage:(UIImage*)inImg
{
    if(inImg==nil)return nil;
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);

    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    {
        CGRect theFrame = [UIScreen mainScreen].bounds;
        
        CGRect theRect = {0,0,320,theFrame.size.height};
        static CGColorSpaceRef colorSpace = NULL;
        if (colorSpace == NULL) {
            colorSpace = CGColorSpaceCreateDeviceRGB();
            if (colorSpace == NULL) {
                // Handle the error appropriately.
                return nil;
            }
        }
        [inImg drawInRect:theRect];
    }
    
    UIGraphicsPopContext();
    
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    
    // here is that final Image I am storing into Saved Photo Albums/ Library
    // UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil);
    UIGraphicsEndImageContext();
    return  screenshot;
}

+ (UIImage *)imageWithBezierPath:(UIBezierPath *)path color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor {
    UIGraphicsBeginImageContextWithOptions((CGSizeMake(path.bounds.origin.x * 2 + path.bounds.size.width, path.bounds.origin.y * 2 + path.bounds.size.height)), NO, .0);
    
    if (backgroundColor) {
        [backgroundColor set];
        [path fill];
    }
    if (color) {
        [color set];
        [path stroke];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)roundedImageWithSize:(CGSize)size color:(UIColor *)color radius:(CGFloat)radius {
    CGRect rect = CGRectZero;
    rect.size = size;
    
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    
    return [UIImage imageWithBezierPath:path color:color backgroundColor:color];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, .0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [color set];
    CGContextFillRect(context, CGRectMake(.0, .0, size.width, size.height));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size andCornerRadius:(CGFloat)radius{
    UIGraphicsBeginImageContextWithOptions(size, NO, .0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 移动到初始点
    CGContextMoveToPoint(context, radius, 0);
    
    // 绘制第1条线和第1个1/4圆弧
    CGContextAddLineToPoint(context, size.width - radius, 0);
    CGContextAddArc(context, size.width - radius, radius, radius, -0.5 * M_PI, 0.0, 0);
    
    CGContextAddLineToPoint(context, size.width, size.height - radius);
    CGContextAddArc(context, size.width - radius, size.height - radius, radius, 0.0, 0.5 * M_PI, 0);
    
    CGContextAddLineToPoint(context, radius, size.height);
    CGContextAddArc(context, radius, size.height - radius, radius, 0.5 * M_PI, M_PI, 0);
    
    CGContextAddLineToPoint(context, 0, radius);
    CGContextAddArc(context, radius, radius, radius, M_PI, 1.5 * M_PI, 0);
    
    // 闭合路径
    CGContextClosePath(context);

    [color set];
    // fill the color
    CGContextDrawPath(context, kCGPathFill);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}







- (UIImage *)clipImageWithPath:(CGMutablePathRef)path
{
    if(self == nil || path == NULL)
        return nil;
    
    CGColorSpaceRef colorRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(nil, self.size.width, self.size.height, 8, self.size.width * 4, colorRef, kCGImageAlphaPremultipliedFirst);
    CGContextAddPath(contextRef, path);
    CGContextClip(contextRef);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
    CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
    UIImage* imageDst = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorRef);
    
    return imageDst;
}

- (UIImage *)mergeImagesAndRects:(UIImage *)firstImage, ...
{
    va_list args_list;
    va_start(args_list, firstImage);
    
    CGColorSpaceRef colorRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(nil, self.size.width, self.size.height, 8, self.size.width * 4, colorRef, kCGImageAlphaPremultipliedFirst);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
    
    for(UIImage *image = firstImage; image != nil; image = va_arg(args_list, UIImage *))
    {
        NSValue *rectNumber = va_arg(args_list, NSValue *);
        CGRect rectValue = [rectNumber CGRectValue];
        rectValue.origin.y = self.size.height - rectValue.size.height - rectValue.origin.y;
        CGContextDrawImage(contextRef, rectValue, image.CGImage);
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);
    UIImage* imageDst = [UIImage imageWithCGImage:imageRef scale:1 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorRef);
    
    return imageDst;
}

- (UIImage *)mergeImage:(UIImage *)imageB atPoint:(CGPoint)startPoint alpha:(float)alpha
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width, self.size.height), YES, 0.0);
    
    [self drawAtPoint: CGPointMake(0,0)];
    
    [imageB drawAtPoint: startPoint blendMode:kCGBlendModeNormal alpha:alpha];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)generatePureColorImage:(UIColor*)color size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, .0);
    [color set];
    UIBezierPath* path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
    [path fill];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//add by ywt
//先按原图的size宽高比缩放到需求的120~1024内。比如说裁剪成最长边是1024，根据宽高比算出另一边，进行尺寸缩放。
- (UIImage*)scaleImageToScale:(float)scaleSize{
    if (scaleSize - 1 < 0.0001 &&  scaleSize - 1 > -0.0001) {
        return self;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width * scaleSize, self.size.height * scaleSize), NO,[UIScreen mainScreen].scale);
    
    [self drawInRect:CGRectMake(0, 0, self.size.width * scaleSize, self.size.height * scaleSize)];

    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

//尺寸解决后再进行大小的压缩，比如就规定最大是500*1024B
- (UIImage *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize {
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    return compressedImage;
}

- (NSData *)compressImageData:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize {
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    return imageData;
}


+ (NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize
{
    //先调整分辨率
    CGSize newSize = CGSizeMake(source_image.size.width, source_image.size.height);
    
    CGFloat tempHeight = newSize.height / 1024;
    CGFloat tempWidth = newSize.width / 1024;
    
    if (tempWidth > 1.0 && tempWidth >= tempHeight) {
        newSize = CGSizeMake(source_image.size.width / tempWidth, source_image.size.height / tempWidth);
    }
    else if (tempHeight > 1.0 && tempWidth <= tempHeight){
        newSize = CGSizeMake(source_image.size.width / tempHeight, source_image.size.height / tempHeight);
    }
    
    NSLog(@"source_image:width = %f,height = %f",source_image.size.width,source_image.size.height);
        NSLog(@"UIImageEX: new size: %@", NSStringFromCGSize(newSize));
    UIGraphicsBeginImageContext(newSize);
    [source_image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"newImage:width = %f,height = %f",newImage.size.width,newImage.size.height);
    
    
    //调整大小 （由于缩放比例参数效果与实际存在偏差，采用渐进式）
    NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
    NSUInteger sizeOrigin = [imageData length];
    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    NSLog(@"====imageData.length = %ld",(unsigned long)imageData.length);
    if (maxSize != 0 && sizeOriginKB > maxSize) {
        
        CGFloat compression = 0.9f;
        CGFloat maxCompression = 0.1f;
        NSData *finallImageData = UIImageJPEGRepresentation(newImage, compression);
        while ([finallImageData length]/1024 > maxSize && compression > maxCompression) {
            @autoreleasepool {
                compression -= 0.1; //0.9~0.1范围，每次对缩放比例减去0.1，如果还是过于频繁可适当增加差值
                finallImageData = UIImageJPEGRepresentation(newImage, compression);
            }
        }
        UIImage *finalImage = [UIImage imageWithData:finallImageData];
        NSLog(@"finalImage:width = %f,height = %f",finalImage.size.width,finalImage.size.height);
        NSLog(@"====finallImageData.length = %ld",(unsigned long)finallImageData.length);
        
        return finallImageData;
    }
    UIImage *resultImage = [UIImage imageWithData:imageData];
    
    NSLog(@"resultImage:width = %f,height = %f",resultImage.size.width,resultImage.size.height);
    NSLog(@"====resultimageData.length = %ld",(unsigned long)imageData.length);
    
    return imageData;
}


#pragma mark 等比率缩放
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
    
}

#pragma mark 裁剪图片 自适应某个view
//+ (UIImage *)cutImage:(UIImage*)image custView:(UIView *)view
//{
//
//    //压缩图片
//    CGSize newSize;
//    CGImageRef imageRef = nil;
//
//    if ((image.size.width / image.size.height) < (view.size.width / view.size.height)) {
//        newSize.width = image.size.width;
//        newSize.height = image.size.width * view.size.height / view.size.width;
//
//        imageRef = CGImageCreateWithImageInRect([image CGImage],CGRectMake(0,fabs(image.size.height - newSize.height) / 2,newSize.width, newSize.height));
//
//    } else {
//        newSize.height = image.size.height;
//        newSize.width = image.size.height * view.size.width / view.size.height;
//
//        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(fabs(image.size.width - newSize.width) / 2,0, newSize.width, newSize.height));
//    }
//    return [UIImage imageWithCGImage:imageRef];
//}

+ (UIImage *)cutImage:(UIImage *)image ToSize:(CGSize)size
{
    CGSize imgSize = image.size;
    if (imgSize.width < size.width ){
        size.width = imgSize.width;
    }
    if(imgSize.height < size.height) {
        size.height = imgSize.height;
    }
    CGRect rect = CGRectMake(0, 0, size.width, size.height);//创建矩形框
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
    
}

@end
