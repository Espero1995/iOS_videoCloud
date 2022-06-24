//
//  NSString+Compatibility.m
//

#import "NSString+Compatibility.h"

@implementation NSString(Compatibility)


-(CGSize)textSize:(UIFont *)font
{
    CGSize size;
    if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_7_0) {
        size = ([self length] > 0) ? [self sizeWithAttributes:font?@{NSFontAttributeName:font}:nil] : CGSizeZero;
    } else {
        size = ([self length] > 0) ? [self sizeWithFont:font] : CGSizeZero;
    }
    
    return size;
}


-(CGSize)mulitilineTextSize:(UIFont *)font maxSize:(CGSize)maxSize mode:(NSLineBreakMode)mode
{
    CGSize size;
    if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_7_0) {
        size = [self length] > 0 ? [self boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) attributes:font?@{NSFontAttributeName:font}:nil context:nil].size : CGSizeZero;
        
        if (CGSizeEqualToSize(size,CGSizeZero)) {
            size = [self length] > 0 ? [self boundingRectWithSize:maxSize options:(NSStringDrawingUsesFontLeading) attributes:font?@{NSFontAttributeName:font}:nil context:nil].size : CGSizeZero;
        }
    } else {
        size  = [self length] > 0 ? [self sizeWithFont:font constrainedToSize:maxSize lineBreakMode:mode] : CGSizeZero;
    }
    
    return size;
}

-(void)drawAtPoint:(CGPoint)point font:(UIFont *)font
{

    if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_7_0) {
        ([self length] > 0) ? [self drawAtPoint:point withAttributes:font?@{NSFontAttributeName:font}:nil] : CGSizeZero;
    } else {
        ([self length] > 0) ? [self drawAtPoint:point withFont:font] : CGSizeZero;
    }
}


-(void)drawInRect:(CGRect)rect font:(UIFont *)font
{
    if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_7_0) {
        ([self length] > 0) ? [self drawInRect:rect withAttributes:font?@{NSFontAttributeName:font}:nil] : CGSizeZero;
    } else {
        ([self length] > 0) ? [self drawInRect:rect withFont:font] : CGSizeZero;
    }
}

@end
