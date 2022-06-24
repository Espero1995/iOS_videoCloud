//
//  NSDictionaryEX.m
//

#import "NSDictionaryEX.h"
#import "NSStringEX.h"

@implementation NSDictionary (EX)

+ (id)dictionaryWithArray:(NSArray *)array{
    NSMutableDictionary * mapDic = [[NSMutableDictionary alloc] init];
    for(NSString * map in array){
        [mapDic setValue:[NSNumber numberWithBool:YES] forKey:map];
    }
    return mapDic;
}

- (NSString*)urlEncodedString
{
    // 91手机助手dylib的JSONString方法冲突
#ifdef PLUGIN_FOR_TAOBAO
    NSString *jsonString = [self tbJSONString];
#else
    NSString *jsonString = [self JSONString];
#endif
    return [jsonString urlEncodedString];
}

- (BOOL)arrayIsKeys:(NSArray *)array{
    BOOL allIn = YES;
    for(NSString * item in array){
        if(nil == [self valueForKey:item]){//只要出现一个key不存在，说明这个不是allKeys的一个子集
            allIn = NO;
            break;
        }
    }
    return allIn;
}
- (id)safeValueForKey:(NSString *)key{
    
    // 不用valueForKey的原因
    // http://blog.sina.com.cn/s/blog_4aacd7af01012b1o.html
    id value = [self objectForKey:key];
    if([value isKindOfClass:[NSNull class]]){
        value = nil;
    }
    return value;
}

- (id)safeObjectForKey:(NSString *)key{
    id value = [self objectForKey:key];
    if([value isKindOfClass:[NSNull class]]){
        value = nil;
    }
    return value;
}

- (NSString*)skuDictionaryToDescription
{
    NSArray* allKeys = [self allKeys];
    
    NSMutableString* result = [NSMutableString stringWithCapacity:60];
    for (int i = 0; i < [allKeys count]; i ++)
    {
        [result appendFormat:@"%@：%@", allKeys[i], [self objectForKey:allKeys[i]]];
        if (i < [allKeys count] - 1)
        {
            [result appendString:@"，"];
        }
    }
    return result;
}

- (void)safeSetObject:(id)anObject forKey:(id <NSCopying>)aKey
{
    if ([self isKindOfClass:[NSMutableDictionary class]] && nil != aKey && nil != anObject) {
        [(NSMutableDictionary *)self setObject:anObject forKey:aKey];
    }
}

- (void)safeSetValue:(id)value forKey:(NSString *)key
{
    if (key && [key isKindOfClass:[NSString class]]) {
        [self setValue:value forKey:key];
    }
}

@end

/************************************************分割线*****************************************/

@implementation NSDictionary (HYUtil)

+ (NSDictionary *)dictionaryWithContentsOfData:(NSData *)data
{
    CFPropertyListRef plist =  CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (__bridge CFDataRef)data, kCFPropertyListImmutable, NULL);
    NSDictionary *result = (__bridge_transfer NSDictionary *)plist;
    if ([result isKindOfClass:[NSDictionary class]]) {
        return result;
    }
    else {
//        CFRelease(plist);
        return nil;
    }
}

- (BOOL)isEmpty
{
    return ([self count] == 0);
}

- (id)objectForKeyCheck:(id)aKey
{
    if (aKey == nil) {
        return nil;
    }
    
    id value = [self objectForKey:aKey];
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}

- (id)objectForKeyCheck:(id)key class:(__unsafe_unretained Class)aClass
{
    return [self objectForKeyCheck:key class:aClass defaultValue:nil];
}

- (id)objectForKeyCheck:(id)key class:(__unsafe_unretained Class)aClass defaultValue:(id)defaultValue
{
    id value = [self objectForKeyCheck:key];
    if (![value isKindOfClass:aClass]) {
        return defaultValue;
    }
    return value;
}

- (NSArray *)arrayForKey:(id)key
{
    return [self arrayForKey:key defaultValue:nil];
}

- (NSArray *)arrayForKey:(id)key defaultValue:(NSArray *)defaultValue
{
    return [self objectForKeyCheck:key class:[NSArray class] defaultValue:defaultValue];
}

- (NSMutableArray *)mutableArrayForKey:(id)key
{
    return [self mutableArrayForKey:key defaultValue:nil];
}

- (NSMutableArray *)mutableArrayForKey:(id)key defaultValue:(NSArray *)defaultValue
{
    return [self objectForKeyCheck:key class:[NSMutableArray class] defaultValue:defaultValue];
}

- (NSDictionary *)dictionaryForKey:(id)key
{
    return [self dictionaryForKey:key defaultValue:nil];
}

- (NSDictionary *)dictionaryForKey:(id)key defaultValue:(NSDictionary *)defaultValue
{
    return [self objectForKeyCheck:key class:[NSDictionary class] defaultValue:defaultValue];
}

- (NSMutableDictionary *)mutableDictionaryForKey:(id)key
{
    return [self mutableDictionaryForKey:key defaultValue:nil];
}

- (NSMutableDictionary *)mutableDictionaryForKey:(id)key defaultValue:(NSDictionary *)defaultValue
{
    return [self objectForKeyCheck:key class:[NSMutableDictionary class] defaultValue:defaultValue];
}

- (NSData *)dataForKey:(id)key
{
    return [self dataForKey:key defaultValue:nil];
}

- (NSData *)dataForKey:(id)key defaultValue:(NSData *)defaultValue
{
    return [self objectForKeyCheck:key class:[NSData class] defaultValue:defaultValue];
}

- (NSString *)stringForKey:(id)key
{
    return [self stringForKeyToString:key];
}

- (NSString *)stringForKeyToString:(id)key
{
    return [self stringForKey:key defaultValue:@""];
}

- (NSString *)stringForKey:(id)key defaultValue:(NSString *)defaultValue
{
    id value = [self objectForKeyCheck:key];
    
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }
    
    if (![value isKindOfClass:[NSString class]]) {
        return defaultValue;
    }
    return value;
}

- (NSNumber *)numberForKey:(id)key
{
    return [self numberForKey:key defaultValue:nil];
}

- (NSNumber *)numberForKey:(id)key defaultValue:(NSNumber *)defaultValue
{
    id value = [self objectForKeyCheck:key];
    
    if ([value isKindOfClass:[NSString class]]) {
        return [value numberValue];
    }
    
    if (![value isKindOfClass:[NSNumber class]]) {
        return defaultValue;
    }
    
    return value;
}

- (char)charForKey:(id)key
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value charValue];
    }
    else {
        return 0x0;
    }
}

- (unsigned char)unsignedCharForKey:(id)key
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value unsignedCharValue];
    }
    else {
        return 0x0;
    }
}

- (short)shortForKey:(id)key
{
    return [self shortForKey:key defaultValue:0];
}

- (short)shortForKey:(id)key defaultValue:(short)defaultValue
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value shortValue];
    }
    else {
        return defaultValue;
    }
}

- (unsigned short)unsignedShortForKey:(id)key
{
    return [self unsignedShortForKey:key defaultValue:0];
}

- (unsigned short)unsignedShortForKey:(id)key defaultValue:(unsigned short)defaultValue
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value unsignedShortValue];
    }
    else {
        return defaultValue;
    }
}

- (int)intForKey:(id)key
{
    return [self intForKey:key defaultValue:0];
}

- (int)intForKey:(id)key defaultValue:(int)defaultValue
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value intValue];
    }
    else {
        return defaultValue;
    }
}

- (unsigned int)unsignedIntForKey:(id)key
{
    return [self unsignedIntForKey:key defaultValue:0];
}

- (unsigned int)unsignedIntForKey:(id)key defaultValue:(unsigned int)defaultValue
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value unsignedIntValue];
    }
    else {
        return defaultValue;
    }
}

- (long)longForKey:(id)key
{
    return [self longForKey:key defaultValue:0];
}

- (long)longForKey:(id)key defaultValue:(long)defaultValue
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value longValue];
    }
    else {
        return defaultValue;
    }
}

- (unsigned long)unsignedLongForKey:(id)key
{
    return [self unsignedLongForKey:key defaultValue:0];
}

- (unsigned long)unsignedLongForKey:(id)key defaultValue:(unsigned long)defaultValue
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value unsignedLongValue];
    }
    else {
        return defaultValue;
    }
}

- (long long)longLongForKey:(id)key
{
    return [self longLongForKey:key defaultValue:0];
}

- (long long)longLongForKey:(id)key defaultValue:(long long)defaultValue
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value longLongValue];
    }
    else {
        return defaultValue;
    }
}

- (unsigned long long)unsignedLongLongForKey:(id)key
{
    return [self unsignedLongLongForKey:key defaultValue:0];
}

- (unsigned long long)unsignedLongLongForKey:(id)key defaultValue:(unsigned long long)defaultValue
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value unsignedLongLongValue];
    }
    else {
        return defaultValue;
    }
}

- (float)floatForKey:(id)key
{
    return [self floatForKey:key defaultValue:0.0];
}

- (float)floatForKey:(id)key defaultValue:(float)defaultValue
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        float result = [value floatValue];
        return isnan(result) ? defaultValue : result;
    }
    else {
        return defaultValue;
    }
}

- (double)doubleForKey:(id)key
{
    return [self doubleForKey:key defaultValue:0.0];
}

- (double)doubleForKey:(id)key defaultValue:(double)defaultValue
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        double result = [value doubleValue];
        return isnan(result) ? defaultValue : result;
    }
    else {
        return defaultValue;
    }
}

- (BOOL)boolForKey:(id)key
{
    return [self boolForKey:key defaultValue:NO];
}

- (BOOL)boolForKey:(id)key defaultValue:(BOOL)defaultValue
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value boolValue];
    }
    else {
        return defaultValue;
    }
}

- (NSInteger)integerForKey:(id)key
{
    return [self integerForKey:key defaultValue:0];
}

- (NSInteger)integerForKey:(id)key defaultValue:(NSInteger)defaultValue
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value integerValue];
    }
    else {
        return defaultValue;
    }
}

- (NSUInteger)unsignedIntegerForKey:(id)key
{
    return [self unsignedIntegerForKey:key defaultValue:0];
}

- (NSUInteger)unsignedIntegerForKey:(id)key defaultValue:(NSUInteger)defaultValue
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value unsignedIntegerValue];
    }
    else {
        return defaultValue;
    }
}

- (CGPoint)pointForKey:(id)key
{
    return [self pointForKey:key defaultValue:CGPointZero];
}

- (CGPoint)pointForKey:(id)key defaultValue:(CGPoint)defaultValue
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSString class]] && ![value isEmpty])
        return CGPointFromString(value);
    else if ([value isKindOfClass:[NSValue class]])
        return [value CGPointValue];
    else
        return defaultValue;
}

- (CGSize)sizeForKey:(id)key
{
    return [self sizeForKey:key defaultValue:CGSizeZero];
}

- (CGSize)sizeForKey:(id)key defaultValue:(CGSize)defaultValue
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSString class]] && ![value isEmpty])
        return CGSizeFromString(value);
    else if ([value isKindOfClass:[NSValue class]])
        return [value CGSizeValue];
    else
        return defaultValue;
}

- (CGRect)rectForKey:(id)key
{
    return [self rectForKey:key defaultValue:CGRectZero];
}

- (CGRect)rectForKey:(id)key defaultValue:(CGRect)defaultValue
{
    id value = [self objectForKeyCheck:key];
    if ([value isKindOfClass:[NSString class]] && ![value isEmpty])
        return CGRectFromString(value);
    else if ([value isKindOfClass:[NSValue class]])
        return [value CGRectValue];
    else
        return defaultValue;
}

@end

@implementation NSMutableDictionary (HYUtil)

- (void)setObjectCheck:(id)anObject forKey:(id <NSCopying>)aKey
{
    if (aKey == nil) {
        NSLog(@"%@ setObjectCheck: aKey 为 nil",self);
        return;
    }
    
    if (anObject == nil) {
        NSLog(@"%@ setObjectCheck: anObject 为 nil",self);
        return;
    }
    
    [self setObject:anObject forKey:aKey];
}

- (void)removeObjectForKeyCheck:(id)aKey
{
    if (aKey == nil) {
        NSLog(@"%@ removeObjectForKeyCheck: aKey 为 nil",self);
        return;
    }
    
    [self removeObjectForKey:aKey];
}

- (void)setChar:(char)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSNumber numberWithChar:value] forKey:key];
}

- (void)setUnsignedChar:(unsigned char)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSNumber numberWithUnsignedChar:value] forKey:key];
}

- (void)setShort:(short)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSNumber numberWithShort:value] forKey:key];
}

- (void)setUnsignedShort:(unsigned short)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSNumber numberWithUnsignedShort:value] forKey:key];
}

- (void)setInt:(int)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSNumber numberWithInt:value] forKey:key];
}

- (void)setUnsignedInt:(unsigned int)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSNumber numberWithUnsignedInt:value] forKey:key];
}

- (void)setLong:(long)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSNumber numberWithLong:value] forKey:key];
}

- (void)setUnsignedLong:(unsigned long)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSNumber numberWithUnsignedLong:value] forKey:key];
}

- (void)setLongLong:(long long)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSNumber numberWithLongLong:value] forKey:key];
}

- (void)setUnsignedLongLong:(unsigned long long)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSNumber numberWithUnsignedLongLong:value] forKey:key];
}

- (void)setFloat:(float)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSNumber numberWithFloat:value] forKey:key];
}

- (void)setDouble:(double)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSNumber numberWithDouble:value] forKey:key];
}

- (void)setBool:(BOOL)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSNumber numberWithBool:value] forKey:key];
}

- (void)setInteger:(NSInteger)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSNumber numberWithInteger:value] forKey:key];
}

- (void)setUnsignedInteger:(NSUInteger)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSNumber numberWithUnsignedInteger:value] forKey:key];
}

- (void)setPointValue:(CGPoint)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSValue valueWithCGPoint:value] forKey:key];
}

- (void)setSizeValue:(CGSize)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSValue valueWithCGSize:value] forKey:key];
}

- (void)setRectValue:(CGRect)value forKey:(id<NSCopying>)key
{
    [self setObjectCheck:[NSValue valueWithCGRect:value] forKey:key];
}

@end

/************************************************分割线*****************************************/

@implementation NSDictionary(NSArrayEXMethodsProtect)

- (id)safeObjectAtIndex:(NSUInteger)index
{
    return nil;
}

- (NSArray *)tm_AllKeys
{
    NSMutableArray *allValues = [NSMutableArray new];
    
    [self enumerateKeysAndObjectsUsingBlock: ^(id key, id object, BOOL *stop)
     {
         if (key != nil && object != nil)
         {
             [allValues addObject: key];
         }
     }];
    
    return allValues;
}

- (void)safeAddObject:(id)anObject
{
    // 兼容类型错误
}

- (void)safeInsertObject:(id)anObject atIndex:(NSUInteger)index
{
    // 兼容类型错误
}

- (id)anyObject
{
    return nil;
}

- (id)objectAtIndexCheck:(NSUInteger)index
{
    return nil;
}

- (id)objectAtIndexCheck:(NSUInteger)index class:(__unsafe_unretained Class)aClass
{
    return nil;
}

- (id)objectAtIndexCheck:(NSUInteger)index class:(__unsafe_unretained Class)aClass defaultValue:(id)defaultValue
{
    return nil;
}

- (NSArray *)arrayAtIndex:(NSUInteger)index
{
    return nil;
}

- (NSArray *)arrayAtIndex:(NSUInteger)index defaultValue:(NSArray *)defaultValue
{
    return nil;
}

- (NSMutableArray *)mutableArrayAtIndex:(NSUInteger)index
{
    return nil;
}

- (NSMutableArray *)mutableArrayAtIndex:(NSUInteger)index defaultValue:(NSArray *)defaultValue
{
    return nil;
}

- (NSDictionary *)dictionaryAtIndex:(NSUInteger)index
{
    return nil;
}

- (NSDictionary *)dictionaryAtIndex:(NSUInteger)index defaultValue:(NSDictionary *)defaultValue
{
    return nil;
}

- (NSMutableDictionary *)mutableDictionaryAtIndex:(NSUInteger)index
{
    return nil;
}

- (NSMutableDictionary *)mutableDictionaryAtIndex:(NSUInteger)index defaultValue:(NSDictionary *)defaultValue
{
    return nil;
}

- (NSData *)dataAtIndex:(NSUInteger)index
{
    return nil;
}

- (NSData *)dataAtIndex:(NSUInteger)index defaultValue:(NSData *)defaultValue
{
    return nil;
}

- (NSString *)stringAtIndex:(NSUInteger)index
{
    return nil;
}

- (NSString *)stringAtIndexToString:(NSUInteger)index
{
    return nil;
}

- (NSString *)stringAtIndex:(NSUInteger)index defaultValue:(NSString *)defaultValue
{
    return nil;
}

- (NSNumber *)numberAtIndex:(NSUInteger)index
{
    return nil;
}

- (NSNumber *)numberAtIndex:(NSUInteger)index defaultValue:(NSNumber *)defaultValue
{
    return nil;
}

- (char)charAtIndex:(NSUInteger)index
{
    return 0x0;
}

- (unsigned char)unsignedCharAtIndex:(NSUInteger)index
{
    return 0x0;
}

- (short)shortAtIndex:(NSUInteger)index
{
    return 0;
}

- (short)shortAtIndex:(NSUInteger)index defaultValue:(short)defaultValue
{
    return 0;
}

- (unsigned short)unsignedShortAtIndex:(NSUInteger)index
{
    return 0;
}

- (unsigned short)unsignedShortAtIndex:(NSUInteger)index defaultValue:(unsigned short)defaultValue
{
    return 0;
}

- (int)intAtIndex:(NSUInteger)index
{
    return 0;
}

- (int)intAtIndex:(NSUInteger)index defaultValue:(int)defaultValue
{
    return 0;
}

- (unsigned int)unsignedIntAtIndex:(NSUInteger)index
{
    return 0;
}

- (unsigned int)unsignedIntAtIndex:(NSUInteger)index defaultValue:(unsigned int)defaultValue
{
    return 0;
}

- (long)longAtIndex:(NSUInteger)index
{
    return 0;
}

- (long)longAtIndex:(NSUInteger)index defaultValue:(long)defaultValue
{
    return 0;
}

- (unsigned long)unsignedLongAtIndex:(NSUInteger)index
{
    return 0;
}

- (unsigned long)unsignedLongAtIndex:(NSUInteger)index defaultValue:(unsigned long)defaultValue
{
    return 0;
}

- (long long)longLongAtIndex:(NSUInteger)index
{
    return 0;
}

- (long long)longLongAtIndex:(NSUInteger)index defaultValue:(long long)defaultValue
{
    return 0;
}

- (unsigned long long)unsignedLongLongAtIndex:(NSUInteger)index
{
    return 0;
}

- (unsigned long long)unsignedLongLongAtIndex:(NSUInteger)index defaultValue:(unsigned long long)defaultValue
{
    return 0;
}

- (float)floatAtIndex:(NSUInteger)index
{
    return 0.0;
}

- (float)floatAtIndex:(NSUInteger)index defaultValue:(float)defaultValue
{
    return 0.0;
}

- (double)doubleAtIndex:(NSUInteger)index
{
    return 0.0;
}

- (double)doubleAtIndex:(NSUInteger)index defaultValue:(double)defaultValue
{
    return 0.0;
}

- (BOOL)boolAtIndex:(NSUInteger)index
{
    return NO;
}

- (BOOL)boolAtIndex:(NSUInteger)index defaultValue:(BOOL)defaultValue
{
    return NO;
}

- (NSInteger)integerAtIndex:(NSUInteger)index
{
    return 0;
}

- (NSInteger)integerAtIndex:(NSUInteger)index defaultValue:(NSInteger)defaultValue
{
    return 0;
}

- (NSUInteger)unsignedIntegerAtIndex:(NSUInteger)index
{
    return 0;
}

- (NSUInteger)unsignedIntegerAtIndex:(NSUInteger)index defaultValue:(NSUInteger)defaultValue
{
    return 0;
}

- (CGPoint)pointAtIndex:(NSUInteger)index
{
    return CGPointZero;
}

- (CGPoint)pointAtIndex:(NSUInteger)index defaultValue:(CGPoint)defaultValue
{
     return CGPointZero;
}

- (CGSize)sizeAtIndex:(NSUInteger)index
{
     return CGSizeZero;
}

- (CGSize)sizeAtIndex:(NSUInteger)index defaultValue:(CGSize)defaultValue
{
     return CGSizeZero;
}

- (CGRect)rectAtIndex:(NSUInteger)index
{
    return CGRectZero;
}

- (CGRect)rectAtIndex:(NSUInteger)index defaultValue:(CGRect)defaultValue
{
    return CGRectZero;
}

- (void)addObjects:(id)objects, ... NS_REQUIRES_NIL_TERMINATION{ }

- (void)addObjectCheck:(id)anObject{ }

- (void)addChar:(char)value{ }

- (void)addUnsignedChar:(unsigned char)value{ }

- (void)addShort:(short)value{ }

- (void)addUnsignedShort:(unsigned short)value{ }

- (void)addInt:(int)value{ }

- (void)addUnsignedInt:(unsigned int)value{ }

- (void)addLong:(long)value{ }

- (void)addUnsignedLong:(unsigned long)value{ }

- (void)addLongLong:(long long)value{ }

- (void)addUnsignedLongLong:(unsigned long long)value{ }

- (void)addFloat:(float)value{ }

- (void)addDouble:(double)value{ }

- (void)addBool:(BOOL)value{ }

- (void)addInteger:(NSInteger)value{ }

- (void)addUnsignedInteger:(NSUInteger)value{ }

- (void)addPointValue:(CGPoint)value{ }

- (void)addSizeValue:(CGSize)value{ }

- (void)addRectValue:(CGRect)value{ }

- (void)insertObjectCheck:(id)anObject atIndex:(NSUInteger)index{ }

- (void)insertChar:(char)value atIndex:(NSUInteger)index{ }

- (void)insertUnsignedChar:(unsigned char)value atIndex:(NSUInteger)index{ }

- (void)insertShort:(short)value atIndex:(NSUInteger)index{ }

- (void)insertUnsignedShort:(unsigned short)value atIndex:(NSUInteger)index{ }

- (void)insertInt:(int)value atIndex:(NSUInteger)index{ }

- (void)insertUnsignedInt:(unsigned int)value atIndex:(NSUInteger)index{ }

- (void)insertLong:(long)value atIndex:(NSUInteger)index{ }

- (void)insertUnsignedLong:(unsigned long)value atIndex:(NSUInteger)index{ }

- (void)insertLongLong:(long long)value atIndex:(NSUInteger)index{ }

- (void)insertUnsignedLongLong:(unsigned long long)value atIndex:(NSUInteger)index{ }

- (void)insertFloat:(float)value atIndex:(NSUInteger)index{ }

- (void)insertDouble:(double)value atIndex:(NSUInteger)index{ }

- (void)insertBool:(BOOL)value atIndex:(NSUInteger)index{ }

- (void)insertInteger:(NSInteger)value atIndex:(NSUInteger)index{ }

- (void)insertUnsignedInteger:(NSUInteger)value atIndex:(NSUInteger)index{ }

- (void)insertPointValue:(CGPoint)value atIndex:(NSUInteger)index{ }

- (void)insertSizeValue:(CGSize)value atIndex:(NSUInteger)index{ }

- (void)insertRectValue:(CGRect)value atIndex:(NSUInteger)index{ }

- (void)replaceObjectCheckAtIndex:(NSUInteger)index withObject:(id)anObject{ }

- (void)replaceCharAtIndex:(NSUInteger)index withChar:(char)value{ }

- (void)replaceUnsignedCharAtIndex:(NSUInteger)index withUnsignedChar:(unsigned char)value{ }

- (void)replaceShortAtIndex:(NSUInteger)index withShort:(short)value{ }

- (void)replaceUnsignedShortAtIndex:(NSUInteger)index withUnsignedShort:(unsigned short)value{ }

- (void)replaceIntAtIndex:(NSUInteger)index withInt:(int)value{ }

- (void)replaceUnsignedIntAtIndex:(NSUInteger)index withUnsignedInt:(unsigned int)value{ }

- (void)replaceLongAtIndex:(NSUInteger)index withLong:(long)value{ }

- (void)replaceUnsignedLongAtIndex:(NSUInteger)index withUnsignedLong:(unsigned long)value{ }

- (void)replaceLongLongAtIndex:(NSUInteger)index withLongLong:(long long)value{ }

- (void)replaceUnsignedLongLongAtIndex:(NSUInteger)index withUnsignedLongLong:(unsigned long long)value{ }

- (void)replaceFloatAtIndex:(NSUInteger)index withFloat:(float)value{ }

- (void)replaceDoubleAtIndex:(NSUInteger)index withDouble:(double)value{ }

- (void)replaceBoolAtIndex:(NSUInteger)index withBool:(BOOL)value{ }

- (void)replaceIntegerAtIndex:(NSUInteger)index withInteger:(NSInteger)value{ }

- (void)replaceUnsignedIntegerAtIndex:(NSUInteger)index withUnsignedInteger:(NSUInteger)value{ }

- (void)replacePointValueAtIndex:(NSUInteger)index withPointValue:(CGPoint)value{ }

- (void)replaceSizeValueAtIndex:(NSUInteger)index withSizeValue:(CGSize)value{ }

- (void)replaceRectValueAtIndex:(NSUInteger)index withRectValue:(CGRect)value{ }


@end