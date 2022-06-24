
//
//  NSStringEx.h
//

#import <UIKit/UIKit.h>

@interface NSString (EX)

//constructor ex
+ (id)stringWithInt:(int)intValue;

//Application Path
//+ (NSString *)HomePath;
//+ (NSString *)TempPath;
//+ (NSString *)DocPath;
//+ (NSString *)LibPath;
//+ (NSString *)AppPath;

+ (NSString *)UUID;

+ (NSArray *)splitString:(NSString *)string forWidth:(NSInteger)width useFont:(UIFont *)font;

//按字节长度拆分
+ (NSArray *)splitString:(NSString *)string forLength:(NSInteger)length;

//将格式为2011-03-33 12:33:32 转化为 2011-03-22
- (NSString *)tmDateString;

//当前时间标准格式2012-03-33 12:33:32 
+ (NSString *)normalDateString;

- (NSUInteger)hexValue;

- (UIColor *)toUIColor;

+ (NSString *) spacesForFont:(UIFont *)f Width:(CGFloat)width;

- (NSString *)md5Value;

- (NSString *)trim;

// 去掉字符串中的html特殊字符，类似	&#39;
//-(NSString*)decodeHtmlUnicodeCharacters;

//增加淘客ID等统计信息，strPid和pid写死，unionId去掉前缀“mm_”和后缀“_***” 
- (NSString *)formatTaoke;

//加密用API
+ (NSString *)getRandUUIDKey;

+ (BOOL)genHYSecretKey:(char *)secretKey length:(int)len rear:(const char *)uuidRear outData:(int16_t *)oData outLen:(int *)oLen;

+ (BOOL)decHYSecretKey:(int16_t *)gSecretKey length:(int)len rear:(const char *)uuidRear outData:(char *)oData outLen:(int *)oLen;

+ (BOOL)desEncrypt:(char *)sData length:(int)len key:(NSString *)cipherKey outData:(char *)oData outLen:(size_t *)oLen;

+ (BOOL)desDecrypt:(const char *)sData  length:(int)len key:(NSString *)cipherKey outData:(char *)oData outLen:(size_t *)oLen;

// 判断是否有前缀，大小写不敏感
- (BOOL)hasPrefixCaseInsensitive:(NSString *)aString;

//是否已经有分辨率连接 
//- (NSRange)rangeOfTFSSuffix;

// percent escaped code
- (NSString *)escapedURLString;
- (NSString *)originalURLString;

- (NSString *)majorVersion;
- (NSString *)minorVersion;

//- (BOOL)isPureNumber;
//- (NSString *)floatValueExceptChar;

+ (NSString *)graceWeightValue:(double)weight;

- (NSString *)stringByRemovingControlCharacters;

- (BOOL)containsString:(NSString*)substring;

//将火眼中支持的类型由整数转换为标准字符串
+ (NSString *)zbarType2String:(NSInteger)type;

- (NSString*) urlEncodedString;

+ (NSString *)removeHHYLTags:(NSString *)html;

+ (NSDictionary *)getParams:(NSString *)query;

- (BOOL)isValidString;

@end


/************************************************分割线*****************************************/
@interface NSString (HYUtil)

/*!
 @method charValue
 @abstract 把字符串转为char类型
 @result 返回char
 */
- (char)theCharValue;

/*!
 @method unsignedCharValue
 @abstract 把字符串转为unsigned char类型
 @result 返回unsigned char
 */
- (unsigned char)unsignedCharValue;

/*!
 @method shortValue
 @abstract 把字符串转为short类型
 @result 返回short
 */
- (short)shortValue;

/*!
 @method unsignedShortValue
 @abstract 把字符串转为unsigned short类型
 @result 返回unsigned short
 */
- (unsigned short)unsignedShortValue;

/*!
 @method unsignedIntValue
 @abstract 把字符串转为unsigned int类型
 @result 返回unsigned int
 */
- (unsigned int)unsignedIntValue;

/*!
 @method longValue
 @abstract 把字符串转为long类型
 @result 返回long
 */
- (long)longValue;

/*!
 @method unsignedLongValue
 @abstract 把字符串转为unsigned long类型
 @result 返回unsigned long
 */
- (unsigned long)unsignedLongValue;

/*!
 @method unsignedLongLongValue
 @abstract 把字符串转为unsigned long long类型
 @result 返回unsigned long long
 */
- (unsigned long long)unsignedLongLongValue;

/*!
 @method unsignedIntegerValue
 @abstract 把字符串转为NSUInteger类型
 @result 返回NSUInteger
 */
- (NSUInteger)unsignedIntegerValue;

/*!
 @method numberValue
 @abstract 把字符串转为NSNumber类型
 @result 返回NSNumber
 */
- (NSNumber *)numberValue;

/*!
 @method isEmpty
 @abstract 是否没有字符串；没有字符串为YES;
 @result 返回BOOL
 */
- (BOOL)isEmpty;


// date
+ (NSString *) stringFromDate:(NSDate *)date;

// contains all digit
- (BOOL)isContainAllDigits;

//利用正则表达式验证邮箱的合法性
-(BOOL)isValidateEmail:(NSString *)email;

// 算出字符串的高度
+ (CGFloat) heightOfString:(NSString *)str withFontSize:(NSInteger)size withTotalMargin:(CGFloat)margin;


@end


