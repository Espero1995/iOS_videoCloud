//
//  NSStringEx.m
//

#import "NSStringEX.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "UIColorEX.h"
//#import "RegexKitLite.h"
//#import "DebugTool.h"
#import "NSString+Compatibility.h"
//#import "DynamicDimensionManager.h"



static char HexStringToInt(char *word)
{
    int str_len = (int)strlen(word);
    int sum = 0;
    for (int i=0; i<str_len; i++) {
        sum *= 16;
        sum += word[i];
    }
    
    return sum;
}

const char mUUIDFront[16] = "04fb8d33efa63464";

@implementation NSString (EX)

- (BOOL)isValidString
{
    if(!self || 0 == self.length ){
        return NO;
    }
    
    NSString* newStr = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if((0 == newStr.length) || [newStr isEqualToString:@"(null)"]){
        return NO;
    }
    
    return YES;
}



+ (id)stringWithInt:(int)intValue
{
    return [NSString stringWithFormat:@"%d",intValue];
}

+ (NSString *)UUID
{
	CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef strUuid = CFUUIDCreateString(kCFAllocatorDefault,uuid);
	NSString * str = [NSString stringWithString:(__bridge NSString *)strUuid];
	CFRelease(strUuid);
	CFRelease(uuid);
	return str;	
}


+ (NSArray *) splitString:(NSString *)string forWidth:(NSInteger)width useFont:(UIFont *)font
{
    if(nil == string || width <= 0 || font == nil)
    {
        return nil;
    }
    NSMutableArray* array = [[NSMutableArray alloc] init];
    NSString* content = [[NSString alloc] initWithString:string];
    
startup:
    if([content length] > 0)
    {
        if([content textSize:font].width <= width)
        {
            [array addObject:content];
        }
        else 
        {
            for(NSUInteger i = [content length] - 1; i > 0; --i)
            {
                NSString* substr = [content substringToIndex:i];
                if([substr textSize:font].width <= width)
                {
                    NSInteger index = i;
                    //                    if(isalpha([content characterAtIndex:i])) // english char
                    //                    {
                    //                        while(index >= 0 && !isspace([content characterAtIndex:index])) //backward to whitespace
                    //                            --index;
                    //                        if(index == 0)
                    //                            index = 1; // 如果宽度过小,一个单词都不能容下,就一行一个字符
                    //                    }
                    
                    if(index != i)
                    {
                        NSString* line = [content substringToIndex:index];
                        [array addObject:line];
                    }else
                    {
                        [array addObject:substr];
                    }
                    
                    content = [NSString stringWithString:[content substringFromIndex:index]];
                    content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    goto startup;
                }
            }
        }
    }
    
    return array;
}

+ (NSArray *)splitString:(NSString *)string forLength:(NSInteger)length
{
    if(nil == string){
        return nil;
    }
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    int lastStart = 0;
    for (int i=0; i<string.length; i++){
        NSString *subString = [string substringWithRange:NSMakeRange(lastStart, i+1-lastStart)];
        NSUInteger cLength = [subString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        if (cLength > length){
            NSString *subString2 = [string substringWithRange:NSMakeRange(lastStart, i-lastStart)];
            [array addObject:subString2];
            lastStart = i;
        }
        else if (cLength == length){
            lastStart = i+1;
            [array addObject:subString];
        }
    }
    
    if (lastStart != string.length){
        NSString *lastSub = [string substringWithRange:NSMakeRange(lastStart, string.length-lastStart)];
        [array addObject:lastSub];
    }
    
    return array;
}


- (NSString *)tmDateString{
    static NSDateFormatter * inFormatter = nil;
    static NSDateFormatter * outFormatter = nil;
    if (inFormatter == nil)
    {
        inFormatter = [[NSDateFormatter alloc] init];
        [inFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    if (outFormatter == nil)
    {
        outFormatter = [[NSDateFormatter alloc] init];
        [outFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    
    NSString * dateString =[outFormatter stringFromDate:
                            [inFormatter dateFromString:self]];
    return dateString;
}

+ (NSString *)normalDateString{
    static NSDateFormatter * inFormatter = nil;
    
    if (inFormatter == nil)
    {
        inFormatter = [[NSDateFormatter alloc] init];
        [inFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    NSString * dateString =[inFormatter stringFromDate:[NSDate date]];
    
    return dateString; 
}

- (NSUInteger)hexValue
{
    NSUInteger result = 0;
    NSString *newString = self;
    if([newString hasPrefix:@"#"])
    {
        newString = [self substringFromIndex:1];
    }
    else if([newString hasPrefix:@"0x"])
    {
        newString = [self substringFromIndex:2];
    }
    if(newString.length == 3)
    {
        unichar str[6] = {0};
        for(int i = 0; i < 3; i++)
        {
            unichar ch = [newString characterAtIndex:i];
            str[i*2] = ch;
            str[i*2+1] = ch;
        }
        newString = [NSString stringWithCharacters:str length:6];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:newString];
    [scanner scanHexInt:(unsigned int *)&result];
    return result;
}

- (UIColor *)toUIColor{
    UIColor * color = nil;
    if ([self length] > 0) 
    {
        int hValue;
        sscanf([self cStringUsingEncoding:NSASCIIStringEncoding], "%x", &hValue);
        color = [UIColor colorWithHexValue:hValue];
    }
    return color;
}
+ (NSString *) spacesForFont:(UIFont *)f Width:(CGFloat)width
{
    // 计算空格数量
	NSString * space_string = @" ";
	CGSize space_size = [space_string textSize:f];
	
	int nSpaceNum = (width/space_size.width) + 1; 
    //int nSpaceNum = (width)/5 + 1;
	char* spaceArray = (char*)malloc(nSpaceNum);
	memset(spaceArray, 32, nSpaceNum);
	spaceArray[nSpaceNum-1] = 0;
	NSString* nsspaceArray = [NSString stringWithUTF8String:spaceArray];
	free(spaceArray);  
	return nsspaceArray;	
}

- (NSString *)md5Value
{
    const char* str = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, strlen(str), result);
    
	NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
	for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
		[ret appendFormat:@"%02x",result[i]];
	}
	return ret;
}

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

//// 去掉字符串中的html特殊字符，类似	&#39;
//-(NSString*)decodeHtmlUnicodeCharacters
//{
//    NSString* result = [self mutableCopy];
//    NSArray* matches = [result arrayOfCaptureComponentsMatchedByRegex: @"\\&#([\\d]+);"];
//    
//    if (![matches count]) 
//        return result;
//    
//    for (int i=0; i<[matches count]; i++) {
//        NSArray* array = [matches objectAtIndex: i];
//        NSString* charCode = [array objectAtIndex: 1];
//        int code = [charCode intValue];
//        NSString* character = [NSString stringWithFormat:@"%C", (unsigned short)code];
//        result = [result stringByReplacingOccurrencesOfString: [array objectAtIndex: 0]
//                                                   withString: character];      
//    }   
//    return result;  
//}

- (NSString *)formatTaoke{

    NSString * tempStr = self;
    NSRange range = [tempStr rangeOfString:@"mm_"];
    if([tempStr length]  > range.location + range.length ){
        tempStr = [tempStr substringFromIndex:range.location + range.length];
        range = [tempStr rangeOfString:@"_"];
        if(NSNotFound != range.location){
            tempStr = [tempStr substringToIndex:range.location];
            return tempStr;
        }
    }
    return nil;
}
+ (NSString *)getRandUUIDKey{
    //用于加密AppSecret的随机串.不要和uuidRear放在一起
    return @"B3948C7F80FA4C6C8559772CF792F378";
}

+ (BOOL)genHYSecretKey:(char *)secretKey length:(int)len rear:(const char *)uuidRear outData:(int16_t *)oData outLen:(int *)oLen{
    if(32 != len){
        [NSException raise:@"Len Error" format:@"Length must 32 bytes"];
        return NO;
    }
    else {
        int index = 0;
        for(int i=0;i<16;i++){
            oData[index++] = secretKey[i] + mUUIDFront[i];
            oData[index++] = mUUIDFront[i];
        }
        for(int j=0;j<16;j++){
            oData[index++] = uuidRear[j];
            oData[index++] = secretKey[16 + j] + uuidRear[j];
            
        }
    }
    *oLen = 64;
    return YES;
}

+ (BOOL)decHYSecretKey:(int16_t *)gSecretKey length:(int)len rear:(const char *)uuidRear outData:(char *)oData outLen:(int *)oLen{
    if(64 != len){
        [NSException raise:@"secretKey Error" format:@"secretKey must 64 bytes"];
        return NO;
    }
    else{
        int index = 0;
        for(int i=0;i<16;i++){
            oData[i] = gSecretKey[index++] - mUUIDFront[i];
            index++;
        }
        for(int j=0;j<16;j++){
            index++;
            oData[16 + j] = gSecretKey[index++] - uuidRear[j];
        }
    }
    *oLen = 32;
    return YES;
}
+ (BOOL)desEncrypt:(char *)sData length:(int)len key:(NSString *)cipherKey outData:(char *)oData outLen:(size_t *)oLen{
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES, 
                                          
                                          0,
                                          
                                          [cipherKey UTF8String], 
                                          
                                          kCCKeySizeDES,
                                          NULL, 
                                          
                                          sData, 
                                          
                                          len,
                                          
                                          oData, 
                                          
                                          
                                          1024,
                                          
                                          oLen);
    if(kCCSuccess == cryptStatus){
        return YES;
    }
    return NO;
}

+ (BOOL)desDecrypt:(const char *)sData  length:(int)len key:(NSString *)cipherKey outData:(char *)oData outLen:(size_t *)oLen{
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES, 
                                          
                                          0,
                                          
                                          [cipherKey UTF8String], 
                                          
                                          kCCKeySizeDES,
                                          
                                          NULL, 
                                          
                                          sData, 
                                          
                                          len,
                                          
                                          oData, 
                                          
                                          
                                          1024,
                                          
                                          oLen);
    if(kCCSuccess == cryptStatus){
        return YES;
    }
    return NO;
}

- (BOOL)hasPrefixCaseInsensitive:(NSString *)aString {
    if (!aString) 
        return NO;
    NSRange range = [self rangeOfString:aString options:NSCaseInsensitiveSearch];
    if (NSNotFound == range.location)
        return NO;
    if (range.location != 0)
        return NO;
    return YES;
}

//- (NSRange)rangeOfTFSSuffix{
//    NSString * regex = @"_\\d+[xX]\\d+\\w*\\.(jpg|png|jpeg)$";
//    NSRange range =  [self rangeOfRegex:regex];
//    // 此时要判断是不是以_sum.jpg结尾的
//    if (range.location == NSNotFound)
//    {
//        // http://baike.corp.taobao.com/index.php/CS_RD/tfs/http_server
//        regex = @"_(sum|(q|Q)\\d+).(jpg|png|jpeg)$";
//        range =  [self rangeOfRegex:regex];
//    }
//    
//    return range;
//}

- (NSString *)escapedURLString
{
    NSString *ret = self;
    char *src = (char *)[self UTF8String];
    if (src){
        NSMutableString *tmp = [NSMutableString string];
        int ind = 0;
        int length = strlen(src);
        while (ind < length) {
            // The characters which are not ASII code and the signals such as
            // ';',':','#' and so on should be converted to percent escape code
            // when they are used as url arguments.
            // You can find official references from http://developer.apple.com/libraray/ios/#documentation/Cocoa/Refer
            if (src[ind] < 0
                || ( ' ' == src[ind]
                    || ':' == src[ind]
                    || '/' == src[ind]
                    || '%' == src[ind]
                    || '#' == src[ind]
                    || ';' == src[ind]
                    || '@' == src[ind]))
            {
                [tmp appendFormat:@"%%%X",(unsigned char)src[ind++]];
            }
            else{
                [tmp appendFormat:@"%c",src[ind++]];
            }
        }
        
        ret = tmp;
    }
    
    return ret;
}

- (NSString *)originalURLString
{
    NSString *ret = self;
    const char *src = [self UTF8String];
    
    if (src){
        int src_len = strlen(src);
        char *tmp = (char *)malloc(src_len+1);
        char word[3] = {0};
        unsigned char c = 0;
        int ind = 0;
        
        bzero(tmp, src_len+1);
        
        while (ind < src_len) {
            if ('%' == src[ind]){
                bzero(word, 3);
                word[0] = src[ind + 1];
                word[1] = src[ind + 2];
                
                c = HexStringToInt(word);
                
                sprintf(tmp, "%s%c", tmp, c);
                
                ind += 3;
            }
            else{
                sprintf(tmp, "%s%c", tmp, src[ind++]);
            }
        }
        
        ret = [NSString stringWithUTF8String:tmp];
        
        free(tmp);
    }
    
    return ret;
}

- (NSString *)majorVersion
{
    // 2.0.2
    NSArray* parts = [self componentsSeparatedByString:@"."];
    if ([parts count] == 3)
    {
        return parts[0];
    }
    return @"";
}

- (NSString *)minorVersion
{
    NSArray* parts = [self componentsSeparatedByString:@"."];
    if ([parts count] == 3)
    {
        return [NSString stringWithFormat:@"%@.%@", parts[1], parts[2]];
    }
    return @"";
}

//- (BOOL)isPureNumber
//{    
//    NSString *num = [self stringByMatching:@"\\d+\\.*\\d*"];
//    
//    if (num.length > 0) {
//        return YES;
//    } else {
//        return NO;
//    }
//}
//
//- (NSString *)floatValueExceptChar
//{
//    NSString *num = [self stringByMatching:@"\\d+\\.?\\d*"];
//    return num;
//}

+ (NSString *)graceWeightValue:(double)weight
{
    NSString* raw = [NSString stringWithFormat:@"%.3f", weight];
    if ([raw rangeOfString:@"."].length == 0)
    {
        return raw;
    }
    else
    {
        int l = [raw length];
        int i = l - 1;
        while (i >= 0)
        {
            unichar c = [raw characterAtIndex:i];
            if (c == '0')
            {
                l --;
            }
            else if (c == '.')
            {
                l --;
                break;
            }
            else
            {
                break;
            }
            i--;
        }
        return [raw substringWithRange:NSMakeRange(0, l)];
    }
}

- (NSString *)stringByRemovingControlCharacters
{
    NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];
    NSRange range = [self rangeOfCharacterFromSet:controlChars];
    if (range.location != NSNotFound) {
        NSMutableString *mutable = [NSMutableString stringWithString:self];
        while (range.location != NSNotFound) {
            [mutable deleteCharactersInRange:range];
            range = [mutable rangeOfCharacterFromSet:controlChars];
        }
        return mutable;
    }
    return self;
}


- (BOOL)containsString:(NSString*)substring
{
    NSRange range = [self rangeOfString:substring];
    BOOL found = (range.location != NSNotFound);
    return found;
}


/** decoded symbol type. */
//typedef enum zbar_symbol_type_zbarSDK_e {
//    ZBAR_NONE        =      0,  /**< no symbol decoded */
//    ZBAR_PARTIAL     =      1,  /**< intermediate status */
//    ZBAR_EAN2        =      2,  /**< GS1 2-digit add-on */
//    ZBAR_EAN5        =      5,  /**< GS1 5-digit add-on */
//    ZBAR_EAN8        =      8,  /**< EAN-8 */
//    ZBAR_UPCE        =      9,  /**< UPC-E */
//    ZBAR_ISBN10      =     10,  /**< ISBN-10 (from EAN-13). @since 0.4 */
//    ZBAR_UPCA        =     12,  /**< UPC-A */
//    ZBAR_EAN13       =     13,  /**< EAN-13 */
//    ZBAR_ISBN13      =     14,  /**< ISBN-13 (from EAN-13). @since 0.4 */
//    ZBAR_COMPOSITE   =     15,  /**< EAN/UPC composite */
//    ZBAR_I25         =     25,  /**< Interleaved 2 of 5. @since 0.4 */
//    ZBAR_DATABAR     =     34,  /**< GS1 DataBar (RSS). @since 0.11 */
//    ZBAR_DATABAR_EXP =     35,  /**< GS1 DataBar Expanded. @since 0.11 */
//    ZBAR_CODABAR     =     38,  /**< Codabar. @since 0.11 */
//    ZBAR_CODE39      =     39,  /**< Code 39. @since 0.4 */
//    ZBAR_PDF417      =     57,  /**< PDF417. @since 0.6 */
//    ZBAR_QRCODE      =     64,  /**< QR Code. @since 0.10 */
//    ZBAR_CODE93      =     93,  /**< Code 93. @since 0.11 */
//    ZBAR_CODE128     =    128,  /**< Code 128 */
//
//    /** mask for base symbol type.
//     * @deprecated in 0.11, remove this from existing code
//     */
//    ZBAR_SYMBOL      = 0x00ff,
//    /** 2-digit add-on flag.
//     * @deprecated in 0.11, a ::ZBAR_EAN2 component is used for
//     * 2-digit GS1 add-ons
//     */
//    ZBAR_ADDON2      = 0x0200,
//    /** 5-digit add-on flag.
//     * @deprecated in 0.11, a ::ZBAR_EAN5 component is used for
//     * 5-digit GS1 add-ons
//     */
//    ZBAR_ADDON5      = 0x0500,
//    /** add-on flag mask.
//     * @deprecated in 0.11, GS1 add-ons are represented using composite
//     * symbols of type ::ZBAR_COMPOSITE; add-on components use ::ZBAR_EAN2
//     * or ::ZBAR_EAN5
//     */
//    ZBAR_ADDON       = 0x0700,
//} zbar_symbol_type_t_zbarSDK;

/**
 *	将火眼中支持的类型由整数转换为标准字符串，对应关系参见http://baike.corp.taobao.com/index.php/Huoyansdk
 *
 *	@param	type	条码的整数类型(注意此处传来的是子类型)
 *
 *	@return	条码类型的标准字符串
 */
+ (NSString *)zbarType2String:(NSInteger)type
{
    switch (type) {
        case 0x1:
            return @"EAN13";
        case 0x2:
            return @"EAN8";
        case 0x4:
            return @"UPCA";
        case 0x8:
            return @"UPCE";
        case 0x10:
            return @"CODE39";
        case 0x20:
            return @"CODE128";
        default:
            break;
    }
    return nil;
}


- (NSString*) urlEncodedString
{
    
    CFStringRef encodedCFString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                          (__bridge CFStringRef) self,
                                                                          nil,
                                                                          CFSTR("?!@#$^&%*+,:;='\"`<>()[]{}/\\| "),
                                                                          kCFStringEncodingUTF8);
    
    NSString *encodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString*) encodedCFString];
    
    if(!encodedString)
        encodedString = @"";
    
    return encodedString;
}

+ (NSString *)removeHHYLTags:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    
    while (![scanner isAtEnd])
    {
        // find start of tag
        [scanner scanUpToString:@"<" intoString:nil] ;
        
        // find end of tag
        [scanner scanUpToString:@">" intoString:&text] ;
        
        // replace the found tag with a space
        // (you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    
    return html;
}


+ (NSDictionary *)getParams:(NSString *)query
{
    NSArray *kvCouples = [query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    for (int i=0; i<kvCouples.count; i++){
        NSString *kv = [kvCouples objectAtIndex:i];
        NSArray *kvArray = [kv componentsSeparatedByString:@"="];
        NSString *key = nil;
        NSString *value = nil;
        if (kvArray.count >= 2)
        {
            key = [kvArray objectAtIndex:0];
            if (kvArray.count == 2)
            {
                value = [kvArray objectAtIndex:1];
            }
            else
            {
                value = [kv substringFromIndex:(key.length+1)];
            }
        }

        if (key.length > 0 && value.length > 0){
            [dict setObject:value forKey:key];
        }
    }
    
    return dict;
}

//利用正则表达式验证邮箱的合法性
-(BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailPre evaluateWithObject:email];
}

@end


/************************************************分割线*****************************************/

#define HY_CONVERT_USING(strtowhat) {\
char buf[24];\
if ([self getCString:buf maxLength:24 encoding:NSASCIIStringEncoding]) \
return strtowhat(buf, NULL, 10);\
} \
return strtowhat([self UTF8String], NULL, 10);


@implementation NSString (HYUtil)

- (char)theCharValue
{
    const char *str = [self UTF8String];
    return str[0];
}

- (unsigned char)unsignedCharValue
{
    const char *str = [self UTF8String];
    return (unsigned char)str[0];
}

- (short)shortValue
{
    int i = [self intValue];
    return (short)i;
}

- (unsigned short)unsignedShortValue
{
    return (unsigned short)[self unsignedLongValue];
}

- (unsigned int)unsignedIntValue
{
    return (unsigned int)[self unsignedLongValue];
}

- (long)longValue
{
    HY_CONVERT_USING(strtol);
}

- (unsigned long)unsignedLongValue
{
    HY_CONVERT_USING(strtoul);
}

- (unsigned long long)unsignedLongLongValue
{
    HY_CONVERT_USING(strtoull);
}

- (NSUInteger)unsignedIntegerValue
{
    return (NSUInteger)[self unsignedLongValue];
}

- (NSNumber *)numberValue
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    return [formatter numberFromString:self];
}

- (BOOL)isEmpty
{
    return (self.length == 0);
}

/// date related
+ (NSString *) stringFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *strResult=[dateFormatter stringFromDate:date];
    
    int a=1,b=2;
    
    
    return strResult;
}



- (BOOL)isContainAllDigits{
    for (NSInteger i=0; i<self.length; i++) {
        if ( ([self substringWithRange:NSMakeRange(i, 1)].theCharValue<'0') || ([self substringWithRange:NSMakeRange(i, 1)].theCharValue>'9') ) {
            return NO;
        }
    }
    return YES;
}


+ (CGFloat)heightOfString:(NSString *)str withFontSize:(NSInteger)size withTotalMargin:(CGFloat)margin{
    if (16==size) {
//        return  [DynamicDimensionManager  sharedManager].fontHeightOf14+
//        [str   // get txt msg
//         sizeWithFontSize:RCS_Font_Arial_size_16 displaySize:CGSizeMake(SCREEN_WIDTH-margin, CGFLOAT_MAX)].height;
    }
    return 0;

}

@end


