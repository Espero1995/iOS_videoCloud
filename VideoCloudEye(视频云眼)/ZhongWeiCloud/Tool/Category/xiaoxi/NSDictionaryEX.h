//
//  NSDictionaryEX.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSDictionary (EX)

+ (id)dictionaryWithArray:(NSArray *)array;
- (BOOL)arrayIsKeys:(NSArray *)array;

- (id)safeValueForKey:(NSString *)key;

- (id)safeObjectForKey:(NSString *)key;

- (NSString*)skuDictionaryToDescription;

- (NSString*)urlEncodedString;

- (void)safeSetObject:(id)anObject forKey:(id <NSCopying>)aKey;

- (void)safeSetValue:(id)value forKey:(NSString *)key;

@end

/************************************************分割线*****************************************/


@interface NSDictionary (HYUtil)

/*!
 @method dictionaryWithContentsOfData:
 @abstract 把NSData数据转成NSDictionary
 @result 返回NSDictionary
 */
+ (NSDictionary *)dictionaryWithContentsOfData:(NSData *)data;

/*!
 @method isEmpty
 @abstract 是否空,字典里没有对象也是为YES；
 @result 返回bool
 */
- (BOOL)isEmpty;

/*!
 @method objectForKeyCheck
 @abstract 检查是否aKey为nil 和 NSNull null如果是返回nil
 @result 返回对象
 */
- (id)objectForKeyCheck:(id)aKey;

/*!
 @method objectForKeyCheck:class:
 @abstract 获取指定key的对象
 @param key 键
 @param aClass 检查类型
 @result 返回对象
 */
- (id)objectForKeyCheck:(id)key class:(__unsafe_unretained Class)aClass;

/*!
 @method objectForKeyCheck:class:defaultValue:
 @abstract 获取指定key的对象
 @param key 键
 @param aClass 检查类型
 @param defaultValue 获取失败要返回的值
 @result 返回对象，获取失败为指定的defaultValue
 */
- (id)objectForKeyCheck:(id)key class:(__unsafe_unretained Class)aClass defaultValue:(id)defaultValue;

/*!
 @method arrayForKey:
 @abstract 获取指定key的NSArray类型值
 @param key 键
 @result 返回NSArray，获取失败为nil
 */
- (NSArray *)arrayForKey:(id)key;

/*!
 @method arrayForKey:defaultValue:
 @abstract 获取指定key的NSArray类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回NSArray，获取失败为指定的defaultValue
 */
- (NSArray *)arrayForKey:(id)key defaultValue:(NSArray *)defaultValue;

/*!
 @method mutableArrayForKey:
 @abstract 获取指定key的NSMutableArray类型值
 @param key 键
 @result 返回NSMutableArray，获取失败为nil
 */
- (NSMutableArray *)mutableArrayForKey:(id)key;

/*!
 @method mutableArrayForKey:defaultValue:
 @abstract 获取指定key的NSMutableArray类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回NSMutableArray，获取失败为指定的defaultValue
 */
- (NSMutableArray *)mutableArrayForKey:(id)key defaultValue:(NSArray *)defaultValue;

/*!
 @method dictionaryForKey:
 @abstract 获取指定key的NSDictionary类型值
 @param key 键
 @result 返回NSDictionary，获取失败为nil
 */
- (NSDictionary *)dictionaryForKey:(id)key;

/*!
 @method dictionaryForKey:defaultValue:
 @abstract 获取指定key的NSDictionary类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回NSDictionary，获取失败为指定的defaultValue
 */
- (NSDictionary *)dictionaryForKey:(id)key defaultValue:(NSDictionary *)defaultValue;

/*!
 @method mutableDictionaryForKey:
 @abstract 获取指定key的NSMutableDictionary类型值
 @param key 键
 @result 返回NSMutableDictionary，获取失败为nil
 */
- (NSMutableDictionary *)mutableDictionaryForKey:(id)key;

/*!
 @method mutableDictionaryForKey:defaultValue:
 @abstract 获取指定key的NSMutableDictionary类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回NSMutableDictionary，获取失败为指定的defaultValue
 */
- (NSMutableDictionary *)mutableDictionaryForKey:(id)key defaultValue:(NSDictionary *)defaultValue;

/*!
 @method dataForKey:
 @abstract 获取指定key的NSData类型值
 @param key 键
 @result 返回NSData，获取失败为nil
 */
- (NSData *)dataForKey:(id)key;

/*!
 @method dataForKey:defaultValue:
 @abstract 获取指定key的NSData类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回NSData，获取失败为指定的defaultValue
 */
- (NSData *)dataForKey:(id)key defaultValue:(NSData *)defaultValue;

/*!
 @method stringForKey:
 @abstract 获取指定key的NSString类型值
 @param key 键
 @result 返回NSString，获取失败为nil
 */
- (NSString *)stringForKey:(id)key;

/*!
 @method stringForKeyToString:
 @abstract 获取指定key的NSString类型值
 @param key 键
 @result 返回字NSString，获取失败为@""
 */
- (NSString *)stringForKeyToString:(id)key;

/*!
 @method stringForKey:defaultValue:
 @abstract 获取指定key的NSString类型值,获取失败返回为指定的defaultValue
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回NSString，获取失败为指定的defaultValue
 */
- (NSString *)stringForKey:(id)key defaultValue:(NSString *)defaultValue;

/*!
 @method numberForKey:
 @abstract 获取指定key的NSNumber类型值
 @param key 键
 @result 返回NSNumber，获取失败为nil
 */
- (NSNumber *)numberForKey:(id)key;

/*!
 @method numberForKey:defaultValue:
 @abstract 获取指定key的NSNumber类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回NSNumber，获取失败为指定的defaultValue
 */
- (NSNumber *)numberForKey:(id)key defaultValue:(NSNumber *)defaultValue;

/*!
 @method charForKey:
 @abstract 获取指定key的NSNumber类型值
 @param key 键
 @result 返回char
 */
- (char)charForKey:(id)key;

/*!
 @method unsignedCharForKey:
 @abstract 获取指定key的unsigned char类型值
 @param key 键
 @result 返回unsigned char
 */
- (unsigned char)unsignedCharForKey:(id)key;

/*!
 @method shortForKey:
 @abstract 获取指定key的short类型值
 @param key 键
 @result 返回short，获取失败为0
 */
- (short)shortForKey:(id)key;

/*!
 @method shortForKey:defaultValue:
 @abstract 获取指定key的short类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回short，获取失败为指定的defaultValue
 */
- (short)shortForKey:(id)key defaultValue:(short)defaultValue;

/*!
 @method unsignedShortForKey:
 @abstract 获取指定key的unsigned short类型值
 @param key 键
 @result 返回unsigned short，获取失败为0
 */
- (unsigned short)unsignedShortForKey:(id)key;

/*!
 @method unsignedShortForKey:defaultValue:
 @abstract 获取指定key的unsigned short类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回unsigned short，获取失败为指定的defaultValue
 */
- (unsigned short)unsignedShortForKey:(id)key defaultValue:(unsigned short)defaultValue;

/*!
 @method intForKey:
 @abstract 获取指定key的int类型值
 @param key 键
 @result 返回int，获取失败为0
 */
- (int)intForKey:(id)key;

/*!
 @method intForKey:defaultValue:
 @abstract 获取指定key的int类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回int，获取失败为指定的defaultValue
 */
- (int)intForKey:(id)key defaultValue:(int)defaultValue;

/*!
 @method unsignedIntForKey:
 @abstract 获取指定key的unsigned int类型值
 @param key 键
 @result 返回unsigned int，获取失败为0
 */
- (unsigned int)unsignedIntForKey:(id)key;

/*!
 @method unsignedIntForKey:defaultValue:
 @abstract 获取指定key的unsigned int类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回unsigned int，获取失败为指定的defaultValue
 */
- (unsigned int)unsignedIntForKey:(id)key defaultValue:(unsigned int)defaultValue;

/*!
 @method longForKey:
 @abstract 获取指定key的long类型值
 @param key 键
 @result 返回long，获取失败为0
 */
- (long)longForKey:(id)key;

/*!
 @method longForKey:defaultValue:
 @abstract 获取指定key的long类型值
 @param defaultValue 获取失败要返回的值
 @result 返回long，获取失败为指定的defaultValue
 */
- (long)longForKey:(id)key defaultValue:(long)defaultValue;

/*!
 @method unsignedLongForKey:
 @abstract 获取指定key的unsigned long类型值
 @param key 键
 @result 返回unsigned long，获取失败为0
 */
- (unsigned long)unsignedLongForKey:(id)key;

/*!
 @method unsignedLongForKey:defaultValue:
 @abstract 获取指定key的unsigned long类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回unsigned long，获取失败为指定的defaultValue
 */
- (unsigned long)unsignedLongForKey:(id)key defaultValue:(unsigned long)defaultValue;

/*!
 @method longLongForKey:
 @abstract 获取指定key的long long类型值
 @param key 键
 @result 返回long long，获取失败为0
 */
- (long long)longLongForKey:(id)key;

/*!
 @method longLongForKey:defaultValue:
 @abstract 获取指定key的long long类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回long long，获取失败为指定的defaultValue
 */
- (long long)longLongForKey:(id)key defaultValue:(long long)defaultValue;

/*!
 @method unsignedLongLongForKey:
 @abstract 获取指定key的unsigned long long类型值
 @param key 键
 @result 返回unsigned long long，获取失败为0
 */
- (unsigned long long)unsignedLongLongForKey:(id)key;

/*!
 @method unsignedLongLongForKey:defaultValue:
 @abstract 获取指定key的unsigned long long类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回unsigned long long，获取失败为指定的defaultValue
 */
- (unsigned long long)unsignedLongLongForKey:(id)key defaultValue:(unsigned long long)defaultValue;

/*!
 @method floatForKey:
 @abstract 获取指定key的float类型值
 @param key 键
 @result 返回float，获取失败为0.0
 */
- (float)floatForKey:(id)key;

/*!
 @method floatForKey:defaultValue:
 @abstract 获取指定key的float类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回float，获取失败为指定的defaultValue
 */
- (float)floatForKey:(id)key defaultValue:(float)defaultValue;

/*!
 @method doubleForKey:
 @abstract 获取指定key的double类型值
 @param key 键
 @result 返回double，获取失败为0.0
 */
- (double)doubleForKey:(id)key;

/*!
 @method doubleForKey:defaultValue:
 @abstract 获取指定key的double类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回double，获取失败为指定的defaultValue
 */
- (double)doubleForKey:(id)key defaultValue:(double)defaultValue;

/*!
 @method boolForKey:
 @abstract 获取指定key的BOOL类型值
 @param key 键
 @result 返回BOOL，获取失败为NO
 */
- (BOOL)boolForKey:(id)key;

/*!
 @method boolForKey:
 @abstract 获取指定key的BOOL类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回BOOL，获取失败为指定的defaultValue
 */
- (BOOL)boolForKey:(id)key defaultValue:(BOOL)defaultValue;

/*!
 @method integerForKey:
 @abstract 获取指定key的NSInteger类型值
 @param key 键
 @result 返回NSInteger，获取失败为0
 */
- (NSInteger)integerForKey:(id)key;

/*!
 @method integerForKey:defaultValue:
 @abstract 获取指定key的NSInteger类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回NSInteger，获取失败为指定的defaultValue
 */
- (NSInteger)integerForKey:(id)key defaultValue:(NSInteger)defaultValue;

/*!
 @method unsignedIntegerForKey:
 @abstract 获取指定key的NSUInteger类型值
 @param key 键
 @result 返回NSUInteger，获取失败为0
 */
- (NSUInteger)unsignedIntegerForKey:(id)key;

/*!
 @method unsignedIntegerForKey:defaultValue:
 @abstract 获取指定key的NSUInteger类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回NSUInteger，获取失败为指定的defaultValue
 */
- (NSUInteger)unsignedIntegerForKey:(id)key defaultValue:(NSUInteger)defaultValue;

/*!
 @method pointForKey:
 @abstract 获取指定key的CGPoint类型值
 @param key 键
 @result 返回CGPoint，获取失败为CGPointZero
 */
- (CGPoint)pointForKey:(id)key;

/*!
 @method pointForKey:defaultValue:
 @abstract 获取指定key的CGPoint类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回CGPoint，获取失败为指定的defaultValue
 */
- (CGPoint)pointForKey:(id)key defaultValue:(CGPoint)defaultValue;

/*!
 @method sizeForKey:
 @abstract 获取指定key的CGSize类型值
 @param key 键
 @result 返回CGPoint，获取失败为CGSizeZero
 */
- (CGSize)sizeForKey:(id)key;

/*!
 @method sizeForKey:defaultValue:
 @abstract 获取指定key的CGSize类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回CGSize，获取失败为指定的defaultValue
 */
- (CGSize)sizeForKey:(id)key defaultValue:(CGSize)defaultValue;

/*!
 @method rectForKey:
 @abstract 获取指定key的CGRect类型值
 @param key 键
 @result 返回CGPoint，获取失败为CGRectZero
 */
- (CGRect)rectForKey:(id)key;

/*!
 @method rectForKey:
 @abstract 获取指定key的CGRect类型值
 @param key 键
 @param defaultValue 获取失败要返回的值
 @result 返回CGRect，获取失败为指定的defaultValue
 */
- (CGRect)rectForKey:(id)key defaultValue:(CGRect)defaultValue;

@end



@interface NSMutableDictionary (HYUtil)

/*!
 @method setObjectCheck:forKey:
 @abstract 检查设置指定key和anObject是不是为nil;不是则设置
 @param value 值
 @param key 键
 */
- (void)setObjectCheck:(id)anObject forKey:(id <NSCopying>)aKey;

/*!
 @method removeObjectForKeyCheck:
 @abstract 检查移除的key是不是为nil;不是则移除
 @param aKey 键
 */
- (void)removeObjectForKeyCheck:(id)aKey;

/*!
 @method setChar:forKey:
 @abstract 设置指定key的char类型值
 @param value 值
 @param key 键
 */
- (void)setChar:(char)value forKey:(id<NSCopying>)key;

/*!
 @method setUnsignedChar:forKey:
 @abstract 设置指定key的unsigned char类型值
 @param value 值
 @param key 键
 */
- (void)setUnsignedChar:(unsigned char)value forKey:(id<NSCopying>)key;

/*!
 @method setShort:forKey:
 @abstract 设置指定key的short类型值
 @param value 值
 @param key 键
 */
- (void)setShort:(short)value forKey:(id<NSCopying>)key;

/*!
 @method setUnsignedShort:forKey:
 @abstract 设置指定key的unsigned short类型值
 @param value 值
 @param key 键
 */
- (void)setUnsignedShort:(unsigned short)value forKey:(id<NSCopying>)key;

/*!
 @method setInt:forKey:
 @abstract 设置指定key的int类型值
 @param value 值
 @param key 键
 */
- (void)setInt:(int)value forKey:(id<NSCopying>)key;

/*!
 @method setUnsignedInt:forKey:
 @abstract 设置指定key的unsigned int类型值
 @param value 值
 @param key 键
 */
- (void)setUnsignedInt:(unsigned int)value forKey:(id<NSCopying>)key;

/*!
 @method setLong:forKey:
 @abstract 设置指定key的long类型值
 @param value 值
 @param key 键
 */
- (void)setLong:(long)value forKey:(id<NSCopying>)key;

/*!
 @method setUnsignedLong:forKey:
 @abstract 设置指定key的unsigned long类型值
 @param value 值
 @param key 键
 */
- (void)setUnsignedLong:(unsigned long)value forKey:(id<NSCopying>)key;

/*!
 @method setLongLong:forKey:
 @abstract 设置指定key的long long类型值
 @param value 值
 @param key 键
 */
- (void)setLongLong:(long long)value forKey:(id<NSCopying>)key;

/*!
 @method setUnsignedLongLong:forKey:
 @abstract 设置指定key的unsigned long long类型值
 @param value 值
 @param key 键
 */
- (void)setUnsignedLongLong:(unsigned long long)value forKey:(id<NSCopying>)key;

/*!
 @method setFloat:forKey:
 @abstract 设置指定key的float类型值
 @param value 值
 @param key 键
 */
- (void)setFloat:(float)value forKey:(id<NSCopying>)key;

/*!
 @method setDouble:forKey:
 @abstract 设置指定key的double类型值
 @param value 值
 @param key 键
 */
- (void)setDouble:(double)value forKey:(id<NSCopying>)key;

/*!
 @method setBool:forKey:
 @abstract 设置指定key的BOOL类型值
 @param value 值
 @param key 键
 */
- (void)setBool:(BOOL)value forKey:(id<NSCopying>)key;

/*!
 @method setInteger:forKey:
 @abstract 设置指定key的NSInteger类型值
 @param value 值
 @param key 键
 */
- (void)setInteger:(NSInteger)value forKey:(id<NSCopying>)key;

/*!
 @method setUnsignedInteger:forKey:
 @abstract 设置指定key的NSUInteger类型值
 @param value 值
 @param key 键
 */
- (void)setUnsignedInteger:(NSUInteger)value forKey:(id<NSCopying>)key;

/*!
 @method setPointValue:forKey:
 @abstract 设置指定key的CGPoint类型值
 @param value 值
 @param key 键
 */
- (void)setPointValue:(CGPoint)value forKey:(id<NSCopying>)key;

/*!
 @method setSizeValue:forKey:
 @abstract 设置指定key的CGSize类型值
 @param value 值
 @param key 键
 */
- (void)setSizeValue:(CGSize)value forKey:(id<NSCopying>)key;

/*!
 @method setRectValue:forKey:
 @abstract 设置指定key的CGRect类型值
 @param value 值
 @param key 键
 */
- (void)setRectValue:(CGRect)value forKey:(id<NSCopying>)key;

@end

/************************************************分割线*****************************************/

@interface NSDictionary(NSArrayEXMethodsProtect)

- (id)safeObjectAtIndex:(NSUInteger)index;
- (NSArray *)tm_AllKeys;

- (void)safeAddObject:(id)anObject;

- (void)safeInsertObject:(id)anObject atIndex:(NSUInteger)index;

- (id)anyObject;

- (id)objectAtIndexCheck:(NSUInteger)index;

- (id)objectAtIndexCheck:(NSUInteger)index class:(__unsafe_unretained Class)aClass;

- (id)objectAtIndexCheck:(NSUInteger)index class:(__unsafe_unretained Class)aClass defaultValue:(id)defaultValue;

- (NSArray *)arrayAtIndex:(NSUInteger)index;

- (NSArray *)arrayAtIndex:(NSUInteger)index defaultValue:(NSArray *)defaultValue;

- (NSMutableArray *)mutableArrayAtIndex:(NSUInteger)index;

- (NSMutableArray *)mutableArrayAtIndex:(NSUInteger)index defaultValue:(NSArray *)defaultValue;

- (NSDictionary *)dictionaryAtIndex:(NSUInteger)index;

- (NSDictionary *)dictionaryAtIndex:(NSUInteger)index defaultValue:(NSDictionary *)defaultValue;

- (NSMutableDictionary *)mutableDictionaryAtIndex:(NSUInteger)index;

- (NSMutableDictionary *)mutableDictionaryAtIndex:(NSUInteger)index defaultValue:(NSDictionary *)defaultValue;

- (NSData *)dataAtIndex:(NSUInteger)index;

- (NSData *)dataAtIndex:(NSUInteger)index defaultValue:(NSData *)defaultValue;

- (NSString *)stringAtIndex:(NSUInteger)index;

- (NSString *)stringAtIndexToString:(NSUInteger)index;

- (NSString *)stringAtIndex:(NSUInteger)index defaultValue:(NSString *)defaultValue;

- (NSNumber *)numberAtIndex:(NSUInteger)index;

- (NSNumber *)numberAtIndex:(NSUInteger)index defaultValue:(NSNumber *)defaultValue;

- (char)charAtIndex:(NSUInteger)index;

- (unsigned char)unsignedCharAtIndex:(NSUInteger)index;

- (short)shortAtIndex:(NSUInteger)index;

- (short)shortAtIndex:(NSUInteger)index defaultValue:(short)defaultValue;

- (unsigned short)unsignedShortAtIndex:(NSUInteger)index;

- (unsigned short)unsignedShortAtIndex:(NSUInteger)index defaultValue:(unsigned short)defaultValue;

- (int)intAtIndex:(NSUInteger)index;

- (int)intAtIndex:(NSUInteger)index defaultValue:(int)defaultValue;

- (unsigned int)unsignedIntAtIndex:(NSUInteger)index;

- (unsigned int)unsignedIntAtIndex:(NSUInteger)index defaultValue:(unsigned int)defaultValue;

- (long)longAtIndex:(NSUInteger)index;

- (long)longAtIndex:(NSUInteger)index defaultValue:(long)defaultValue;

- (unsigned long)unsignedLongAtIndex:(NSUInteger)index;

- (unsigned long)unsignedLongAtIndex:(NSUInteger)index defaultValue:(unsigned long)defaultValue;

- (long long)longLongAtIndex:(NSUInteger)index;

- (long long)longLongAtIndex:(NSUInteger)index defaultValue:(long long)defaultValue;

- (unsigned long long)unsignedLongLongAtIndex:(NSUInteger)index;

- (unsigned long long)unsignedLongLongAtIndex:(NSUInteger)index defaultValue:(unsigned long long)defaultValue;

- (float)floatAtIndex:(NSUInteger)index;

- (float)floatAtIndex:(NSUInteger)index defaultValue:(float)defaultValue;

- (double)doubleAtIndex:(NSUInteger)index;

- (double)doubleAtIndex:(NSUInteger)index defaultValue:(double)defaultValue;

- (BOOL)boolAtIndex:(NSUInteger)index;

- (BOOL)boolAtIndex:(NSUInteger)index defaultValue:(BOOL)defaultValue;

- (NSInteger)integerAtIndex:(NSUInteger)index;

- (NSInteger)integerAtIndex:(NSUInteger)index defaultValue:(NSInteger)defaultValue;

- (NSUInteger)unsignedIntegerAtIndex:(NSUInteger)index;

- (NSUInteger)unsignedIntegerAtIndex:(NSUInteger)index defaultValue:(NSUInteger)defaultValue;

- (CGPoint)pointAtIndex:(NSUInteger)index;

- (CGPoint)pointAtIndex:(NSUInteger)index defaultValue:(CGPoint)defaultValue;

- (CGSize)sizeAtIndex:(NSUInteger)index;

- (CGSize)sizeAtIndex:(NSUInteger)index defaultValue:(CGSize)defaultValue;

- (CGRect)rectAtIndex:(NSUInteger)index;

- (CGRect)rectAtIndex:(NSUInteger)index defaultValue:(CGRect)defaultValue;

- (void)addObjects:(id)objects, ... NS_REQUIRES_NIL_TERMINATION;

- (void)addObjectCheck:(id)anObject;

- (void)addChar:(char)value;

- (void)addUnsignedChar:(unsigned char)value;

- (void)addShort:(short)value;

- (void)addUnsignedShort:(unsigned short)value;

- (void)addInt:(int)value;

- (void)addUnsignedInt:(unsigned int)value;

- (void)addLong:(long)value;

- (void)addUnsignedLong:(unsigned long)value;

- (void)addLongLong:(long long)value;

- (void)addUnsignedLongLong:(unsigned long long)value;

- (void)addFloat:(float)value;

- (void)addDouble:(double)value;

- (void)addBool:(BOOL)value;

- (void)addInteger:(NSInteger)value;

- (void)addUnsignedInteger:(NSUInteger)value;

- (void)addPointValue:(CGPoint)value;

- (void)addSizeValue:(CGSize)value;

- (void)addRectValue:(CGRect)value;

- (void)insertObjectCheck:(id)anObject atIndex:(NSUInteger)index;

- (void)insertChar:(char)value atIndex:(NSUInteger)index;

- (void)insertUnsignedChar:(unsigned char)value atIndex:(NSUInteger)index;

- (void)insertShort:(short)value atIndex:(NSUInteger)index;

- (void)insertUnsignedShort:(unsigned short)value atIndex:(NSUInteger)index;

- (void)insertInt:(int)value atIndex:(NSUInteger)index;

- (void)insertUnsignedInt:(unsigned int)value atIndex:(NSUInteger)index;

- (void)insertLong:(long)value atIndex:(NSUInteger)index;

- (void)insertUnsignedLong:(unsigned long)value atIndex:(NSUInteger)index;

- (void)insertLongLong:(long long)value atIndex:(NSUInteger)index;

- (void)insertUnsignedLongLong:(unsigned long long)value atIndex:(NSUInteger)index;

- (void)insertFloat:(float)value atIndex:(NSUInteger)index;

- (void)insertDouble:(double)value atIndex:(NSUInteger)index;

- (void)insertBool:(BOOL)value atIndex:(NSUInteger)index;

- (void)insertInteger:(NSInteger)value atIndex:(NSUInteger)index;

- (void)insertUnsignedInteger:(NSUInteger)value atIndex:(NSUInteger)index;

- (void)insertPointValue:(CGPoint)value atIndex:(NSUInteger)index;

- (void)insertSizeValue:(CGSize)value atIndex:(NSUInteger)index;

- (void)insertRectValue:(CGRect)value atIndex:(NSUInteger)index;

- (void)replaceObjectCheckAtIndex:(NSUInteger)index withObject:(id)anObject;

- (void)replaceCharAtIndex:(NSUInteger)index withChar:(char)value;

- (void)replaceUnsignedCharAtIndex:(NSUInteger)index withUnsignedChar:(unsigned char)value;

- (void)replaceShortAtIndex:(NSUInteger)index withShort:(short)value;

- (void)replaceUnsignedShortAtIndex:(NSUInteger)index withUnsignedShort:(unsigned short)value;

- (void)replaceIntAtIndex:(NSUInteger)index withInt:(int)value;

- (void)replaceUnsignedIntAtIndex:(NSUInteger)index withUnsignedInt:(unsigned int)value;

- (void)replaceLongAtIndex:(NSUInteger)index withLong:(long)value;

- (void)replaceUnsignedLongAtIndex:(NSUInteger)index withUnsignedLong:(unsigned long)value;

- (void)replaceLongLongAtIndex:(NSUInteger)index withLongLong:(long long)value;

- (void)replaceUnsignedLongLongAtIndex:(NSUInteger)index withUnsignedLongLong:(unsigned long long)value;

- (void)replaceFloatAtIndex:(NSUInteger)index withFloat:(float)value;

- (void)replaceDoubleAtIndex:(NSUInteger)index withDouble:(double)value;

- (void)replaceBoolAtIndex:(NSUInteger)index withBool:(BOOL)value;

- (void)replaceIntegerAtIndex:(NSUInteger)index withInteger:(NSInteger)value;

- (void)replaceUnsignedIntegerAtIndex:(NSUInteger)index withUnsignedInteger:(NSUInteger)value;

- (void)replacePointValueAtIndex:(NSUInteger)index withPointValue:(CGPoint)value;

- (void)replaceSizeValueAtIndex:(NSUInteger)index withSizeValue:(CGSize)value;

- (void)replaceRectValueAtIndex:(NSUInteger)index withRectValue:(CGRect)value;



@end