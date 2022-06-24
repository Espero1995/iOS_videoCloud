//
//  NSString+Compatibility.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString(Compatibility)


//兼容 sizeWithAttributes与sizeWithFont
-(CGSize)textSize:(UIFont *)font;

//兼容 - (CGSize)drawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode
-(CGSize)mulitilineTextSize:(UIFont *)font maxSize:(CGSize)maxSize mode:(NSLineBreakMode)mode;


//兼容-(void)drawAtPoint:(CGPoint)point font:(UIFont *)font
-(void)drawAtPoint:(CGPoint)point font:(UIFont *)font;


//- (void)drawInRect:(CGRect)rect withAttributes:(NSDictionary *)attrs
-(void)drawInRect:(CGRect)rect font:(UIFont *)font;

@end
