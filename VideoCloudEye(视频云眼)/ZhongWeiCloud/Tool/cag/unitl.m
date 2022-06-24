//
//  unitl.m
//  ZhongWeiEyes
//
//  Created by 苏旋律 on 17/5/26.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "unitl.h"
#import "SSKeychain.h"
#import <sys/utsname.h>
@implementation unitl

CGFloat FitWidth(CGFloat width) {
    
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat result = width / 414.0 * w;
    
   // result /= 2.;
    
    return result;
}

CGFloat FitHeight(CGFloat height) {
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    CGFloat result = height / 736.0 * h;
    
    //result /= 2.;
    
    return result;
}

///1.判断字符串是否为空
+(BOOL)isNull:(NSString*) str
{
    if([str isKindOfClass:[NSNull class]]||str==nil||str==NULL||[str isEqualToString:@"(null)"]||[str isEqualToString:@"<null>"]||[str isEqual:[NSNull class]]){
        return YES;
    }else{
        NSString *str1=[str stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([str1 isEqualToString:@""]||str1.length<1) {
            return YES;
        }
        return NO;
    }
}

//************************************************ 本地持有化 *******************************
+(NSString *)getKeyWithSuffix:(NSString *)suffix Key:(NSString *)key
{
    return  [NSString stringWithFormat:@"%@%@",key,suffix];
}

//判断是否 有这个key存储的数据
+(BOOL)isSaveWithKey:(NSString *)key
{
    id data = [[NSUserDefaults standardUserDefaults]objectForKey:key];
    if (data) {
        return YES;
    }else{
        return NO;
    }
}
//******************************************  保存 *******************************************
//根据key和数据，出入本地
+(void)saveDataWithKey:(NSString *)key Data:(id)data
{
    NSUserDefaults *default2 = [NSUserDefaults standardUserDefaults];
    [default2 setObject:data forKey:key];
    [default2 synchronize];
}
//保存需要归档的数据
+(void)saveNeedArchiverDataWithKey:(NSString *)key Data:(id)data
{
    if ([data respondsToSelector:@selector(encodeWithCoder:)] == NO) {
         NSLog(@"对象存入失败！对象必须实现NSCoding 协议的 encodeWithCoder:方法");
        return;
    }
    NSData *data2 = [NSKeyedArchiver archivedDataWithRootObject:data];
    [[NSUserDefaults standardUserDefaults] setObject:data2 forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//******************************************  获取 *******************************************
+(id)getDataWithKey:(NSString *)key
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([user objectForKey:key]) {
        NSMutableArray * data = [user objectForKey:key];
        return data;
    }else{
        return nil;
    }
}
+(id)getNeedArchiverDataWithKey:(NSString *)key
{
    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:key];
    if (data == nil) {
        return nil;
    }
    NSMutableArray * unarchiverData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return unarchiverData;
}


//根据 key 清除本地缓存
+(void)clearDataWithKey:(NSString *)key{
    if (key) {
        //清空NSUserDefaults中的用户信息
        NSUserDefaults *OrderDefaults = [NSUserDefaults standardUserDefaults];
        [OrderDefaults removeObjectForKey:key];
        [OrderDefaults synchronize];
    }else{
        NSLog(@"没有东西可以清理~");
    }
}

/**
 一键打印 User_id 和accessToken
 */
+ (void)log_user_Info
{
    NSLog(@"【用户认证信息】 user_id：%@ ===== access_token：%@",[unitl get_User_id],[unitl get_accessToken]);
}


 //判断是否是海外用户
+ (BOOL)isOverseasCustomers
{
    UserModel *userModel;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    if (userModel.accountType == 2 && !isSimplifiedChinese) {
        return YES;
    }else{
        return NO;
    }
}

//判断是否是邮箱登录的账号
+ (BOOL)isEmailAccountType
{
    UserModel *userModel;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    if (userModel.accountType == 1) {
        return NO;
    }else{
        return YES;
    }
}
//获取用户model
+ (UserModel *)getUserModel
{
    UserModel *userModel;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return userModel;
}
+ (NSString *)get_User_id
{
    NSString * temp_UserId_Str;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        temp_UserId_Str = userModel.user_id;
    }
    return temp_UserId_Str;
}
+ (NSString *)get_accessToken
{
    NSString * temp_accessToken_Str;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        temp_accessToken_Str = userModel.access_token;
    }
    return temp_accessToken_Str;
}

+ (NSString *)get_user_mobile
{
    NSString * temp_Mobile_Str;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        temp_Mobile_Str = userModel.mobile;
    }
    return temp_Mobile_Str;
}

+ (NSString *)getKeyChain
{
    NSError *error= nil;
    NSString *accountID = nil;
    accountID = [SSKeychain passwordForService:@"elastosClientIdentifier" account:@"elastosClientAccount" error:&error];
    if (error) {
        NSLog(@"getKeyChain error:%@", error.localizedDescription);
    }
    
    if ([accountID isEqualToString:@""] || accountID == nil) {
        // 随机生成一个UUID，只需要生成一次
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef stringRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
        accountID = (__bridge NSString *)stringRef;
        accountID = [accountID stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        [SSKeychain setPassword:accountID forService:@"elastosClientIdentifier" account:@"elastosClientAccount" error:&error];
        CFRelease(stringRef);
        CFRelease(uuidRef);
    }
    return accountID;
}
+ (NSString *)get_refreshTime
{
    NSString * temp_refreshTime_Str;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        temp_refreshTime_Str = userModel.refreshTime;
    }
    return temp_refreshTime_Str;
}
+ (BOOL)isRefreshTokenSucceed_sign
{
    BOOL isRefreshTokenSucceed = NO;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL]) {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:USERMODEL];
        UserModel *userModel = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        isRefreshTokenSucceed = userModel.isRefreshTimeSucceed;
    }
    return isRefreshTokenSucceed;
}
+ (BOOL)isRefreshTokenSucceed
{
     // 是否在近期被刷新过 
    int nowTimeStamp = [[unitl getNowTimeTimestamp] intValue];
    int lastSucceedRefreshTime = [[unitl get_refreshTime] intValue];
    BOOL isRefreshTokenSucceed_sign = [unitl isRefreshTokenSucceed_sign];
    if (lastSucceedRefreshTime) {
        if (nowTimeStamp - lastSucceedRefreshTime < 10 && isRefreshTokenSucceed_sign) {// 如果当前时间与最近刷新时间少于10秒, 并且是成功的
            return YES;
        }else{
            return NO;
        }
    }else
    {
        return NO;
    }
}


/**
 获取当前组别的名称和ID
 
 @return 组别的名称和ID
 */
+ (NSMutableArray *)getGroupNameAndIDArr
{
    NSString * GroupNameAndIDArr_KeyStr = [unitl getKeyWithSuffix:[unitl get_User_id] Key:GroupNameAndIDArr_key];
    NSMutableArray * tempArr = [unitl getDataWithKey:GroupNameAndIDArr_KeyStr];
    return tempArr;
}

/**
 根据userID，保存当前组别的名称和ID
 
 @param dataArr 组别的名称和ID
 */
+ (void)saveGroupNameAndIDArr:(NSMutableArray *)dataArr
{
    NSInteger groupCount = dataArr.count;
    NSMutableArray * tempGroupArr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < groupCount; i++) {
        NSMutableDictionary * tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [tempDic setObject:((deviceGroup*)dataArr[i]).groupName forKey:@"groupName"];
        [tempDic setObject:((deviceGroup*)dataArr[i]).groupId forKey:@"groupID"];
        [tempGroupArr addObject:tempDic];
    }
    NSString * GroupNameAndIDArr_KeyStr = [unitl getKeyWithSuffix:[unitl get_User_id] Key:GroupNameAndIDArr_key];
    [unitl saveDataWithKey:GroupNameAndIDArr_KeyStr Data:tempGroupArr];
}

/**
 获取当前用户的 根据userID保存的摄像头model列表
 
 @return 摄像头model列表arr
 */
+ (NSArray *)getCameraModel
{
    NSArray * tempArr;
    NSString * userIDStr = [unitl get_User_id];
    NSString * saveVideoListKey = [unitl getKeyWithSuffix:VIDEOLISTMODEL Key:userIDStr];
    tempArr = [unitl getNeedArchiverDataWithKey:saveVideoListKey];
    return tempArr;
}

/**
 根据userID保存当前的的摄像头model列表数组
 
 @param cameraModelArr 当前需要保存的摄像头列表数组
 */
+ (void)saveCameraModel:(NSMutableArray *)cameraModelArr
{
    NSString * userIDStr = [unitl get_User_id];
    NSString * saveVideoListKey = [unitl getKeyWithSuffix:VIDEOLISTMODEL Key:userIDStr];
    [unitl saveNeedArchiverDataWithKey:saveVideoListKey Data:cameraModelArr];
}

/**
 清除根据userID存在本地的摄像头列表数组
 */
+ (void)clearCameraModel
{
    NSString * userIDStr = [unitl get_User_id];
    NSString * saveVideoListKey = [unitl getKeyWithSuffix:VIDEOLISTMODEL Key:userIDStr];
    [unitl clearDataWithKey:saveVideoListKey];
}

/**
 获取当前正在显示的组别的在整个后台给的数据中的index
 
 @return GroupIndex
 */
+ (NSInteger)getCurrentDisplayGroupIndex
{
    NSString * key = [unitl getKeyWithSuffix:[unitl get_User_id] Key:CurrentDisplayGroupIndex];
    if (key == nil) {
        return 0;
    }
    NSInteger index = [[unitl getDataWithKey:key] integerValue];
    return index;
}

/**
 根据userID，保存当前正在显示的组别设备的index
 
 @param index index
 */
+ (void)saveCurrentDisplayGroupIndex:(NSInteger)index
{
    NSString * key = [unitl getKeyWithSuffix:[unitl get_User_id] Key:CurrentDisplayGroupIndex];
    [unitl saveDataWithKey:key Data:[NSString stringWithFormat:@"%ld",index]];
}

/**
 清除，根据userID，保存的当前正在显示的组别设备的index
 */
+ (void)clearCurrentDisplayGroupIndex
{
    NSString * key = [unitl getKeyWithSuffix:[unitl get_User_id] Key:CurrentDisplayGroupIndex];
    [unitl clearDataWithKey:key];
}

/**
 【置顶】当前选中的组别,置顶，并保存，【注释：现在选择的实现方式是，我们自己实现，后台不实现，故写本地方法】
 
 @param index 当前组别的index
 */
+ (void)stickGroupIndex:(NSInteger)index
{
    NSMutableArray * tempArr_all = [NSMutableArray arrayWithCapacity:0];
    tempArr_all = [unitl getAllGroupCameraModel];
    NSMutableArray * temArr_index = [NSMutableArray arrayWithCapacity:0];
    temArr_index = [unitl getCameraGroupDeviceModelIndex:index];
    ((deviceGroup *)temArr_index).top = YES;//设置当前组里面的信息是置顶属性
    
    [tempArr_all removeObjectAtIndex:index];
    [tempArr_all insertObject:temArr_index atIndex:0];
    
    [unitl saveAllGroupCameraModel:tempArr_all];
}

/**
 因为后台约定，获取保存的数据的最后一个是默认组别的数据
 
 @return 返回【我的设备】默认组别里面的数据
 */
+ (NSArray *)getDefalutGroupDeviceModel
{
    NSString * key = [unitl getKeyWithSuffix:[unitl get_User_id] Key:saveAllGroupCameraModel_key];
    NSArray * tempArr = [unitl getNeedArchiverDataWithKey:key];
    if (tempArr == nil) {
        return nil;
    }
    NSInteger defaultGroupIndex = tempArr.count - 1;
    return tempArr[defaultGroupIndex];
}

/**
 根据当前正在显示组别的index 获取 当前用户的根据userID保存的摄像头model列表
 【注意：根据保存的时候的arr,根据其index取出相应组别里面的设备信息】
 @return 只有该组别里面设备列表arr
 */
+ (NSMutableArray *)getCameraGroupDeviceModelIndex:(NSInteger)index
{
    NSString * key = [unitl getKeyWithSuffix:[unitl get_User_id] Key:saveAllGroupCameraModel_key];
    NSArray * tempArr = [unitl getNeedArchiverDataWithKey:key];
    NSInteger maxIndex = tempArr.count - 1;
    NSMutableArray * returnArr = [NSMutableArray arrayWithCapacity:0];
    if (index <= maxIndex) {
        returnArr = (NSMutableArray *)((deviceGroup*)tempArr[index]).dev_list;
    }else
    {
        NSLog(@"【unitl】getCameraGroupDeviceModelIndex方法，取出相应组别的设备的index越界！maxIndex+1：%ld index:%ld",maxIndex+1,index);
        return nil;
    }
    return returnArr;
}

/**
 【用于排序后，保存某一分组的排序后的设备列表】
 
 @param GroupDevModel 排序后的组的设备列表
 @param index 该列表在的组的index
 */
+ (void)saveCameraGroupDeviceModelData:(NSMutableArray *)GroupDevModel Index:(NSInteger)index
{
    NSMutableArray * tempAllGroupArr = [NSMutableArray arrayWithCapacity:0];
    tempAllGroupArr = [unitl getAllGroupCameraModel];
    if (index < tempAllGroupArr.count) {
        [(NSMutableArray *)((deviceGroup *)tempAllGroupArr[index]).dev_list removeAllObjects];
        [(NSMutableArray *)((deviceGroup *)tempAllGroupArr[index]).dev_list addObjectsFromArray:(NSMutableArray *)GroupDevModel];
        [unitl saveAllGroupCameraModel:tempAllGroupArr];
    }else
    {
        NSLog(@"【unitl】saveCameraGroupDeviceModelData方法，取出相应组别的设备的index越界！index：%ld tempAllGroupArr.count:%ld",index,tempAllGroupArr.count);
    }
}

/**
 更加groupID查询这个id在当前传入数据的分组数据中的index
 
 @param groupID 需要查找的groupID
 @return 这个groupID在所要查询的数据中的index
 */
+ (NSInteger)getCorrectIndexWithGroupID:(NSString *)groupID NeedFindData:(NSMutableArray *)data
{
    NSInteger dataCount = [data count];
    NSInteger retureIndex = 0;
    for (int i = 0; i < dataCount; i++) {
        NSString * groupID_needFindData = ((deviceGroup *)data[i]).groupId;
        if ([groupID isEqualToString:groupID_needFindData]) {
            retureIndex = (NSInteger)i;
            NSLog(@"【unitl】getCorrectIndexWithGroupID方法，根据groupID获取到的在新数据中的index是：%ld",retureIndex);
        }
    }
    return retureIndex;
}

/**
 根据当前正在显示组别的index 获取 当前用户的根据userID保存的摄像头model列表
 【注意：根据保存的时候的arr,根据其index取出相应组别的组的信息以及里面的设备信息】
 @return 带有组别信息的和设备列表arr
 */
+ (NSMutableArray *)getCameraGroupModelIndex:(NSInteger )index
{
    NSString * key = [unitl getKeyWithSuffix:[unitl get_User_id] Key:saveAllGroupCameraModel_key];
    NSArray * tempArr = [unitl getNeedArchiverDataWithKey:key];
    NSInteger maxIndex = tempArr.count - 1;
    NSMutableArray * returnArr = [NSMutableArray arrayWithCapacity:0];
    if (index <= maxIndex) {
        returnArr = tempArr[index];
    }else
    {
        NSLog(@"【unitl】getCameraGroupModelIndex方法，取出相应组别的设备的index越界！maxIndex+1：%ld index:%ld",maxIndex+1,index);
        return nil;
    }
    return returnArr;
}

/**
 获取当前用户下，所有的设备列表，不区分组别。
 
 @return 所有设备列表
 */
+ (NSMutableArray *)getAllDeviceCameraModel
{
    NSMutableArray * tempAllGroupArr = [NSMutableArray arrayWithCapacity:0];
    tempAllGroupArr = [unitl getAllGroupCameraModel];
    NSInteger tempAllGroupArrCount = [tempAllGroupArr count];
    NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0 ; i < tempAllGroupArrCount; i++) {
        [tempArr addObjectsFromArray:(NSArray *)[unitl getCameraGroupDeviceModelIndex:i]];
    }
    return tempArr;
}

/**
 获取所有的当前完整的组设备信息
 
 @return 完整的组设备信息
 */
+ (NSMutableArray *)getAllGroupCameraModel
{
    NSString * key = [unitl getKeyWithSuffix:[unitl get_User_id] Key:saveAllGroupCameraModel_key];
    NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
    tempArr = [unitl getNeedArchiverDataWithKey:key];
    return tempArr;
}

/**
 根据userID保存当前的当前用户所有组别以及摄像头model列表数组
 【注意：这里保存的是以后台返回deviceGroup的model形式的arr】
 
 @param cameraModelArr 当前需要保存的摄像头列表数组
 */
+ (void)saveAllGroupCameraModel:(NSMutableArray *)cameraModelArr
{
    NSString * key = [unitl getKeyWithSuffix:[unitl get_User_id] Key:saveAllGroupCameraModel_key];
    [unitl saveNeedArchiverDataWithKey:key Data:cameraModelArr];
}

/**
 清除根据userID存在本地的整个Group的摄像头列表数组
 */
+ (void)clearAllGroupCameraModel
{
    NSString * key = [unitl getKeyWithSuffix:[unitl get_User_id] Key:saveAllGroupCameraModel_key];
    [unitl clearDataWithKey:key];
}



/**
 判断手机是否处于方法模式 YES：是放大模式；NO：标准模式
 */
+(BOOL)isZoomMode{
    CGFloat scale = [[UIScreen mainScreen] scale];
    BOOL isZoom = false;
    if (scale == 2) {
        if (iPhoneWidth == 320) {
            //iPhone6设备放大模式（也包括5s标准）
            isZoom = YES;
        }
        if (iPhoneWidth == 375) {
            //iPhone6设备标准模式
            isZoom = NO;
        }
    }
    
    if(scale == 3){
        if (iPhoneWidth == 375) {
            //iPhone6 Plus设备放大模式
            isZoom = YES;
        }
        if (iPhoneWidth == 414) {
            //iPhone6 Plus设备标准模式
            isZoom = NO;
        }
    }
    return isZoom;
}

+ (CameraListDisplayMode)CameraListDisplayMode
{
    NSString * tempStr = [unitl getDataWithKey:CURRENTDISPLAYMODE];
    if ([tempStr isEqualToString:@"CameraListDisplayMode_littleMode"]) {
        return CameraListDisplayMode_littleMode;//小图模式
    }else if([tempStr isEqualToString:@"CameraListDisplayMode_largeMode"]){
        return CameraListDisplayMode_largeMode;//大图模式
    }else if ([tempStr isEqualToString:@"CameraListDisplayMode_fourScreenMode"])
    {
        return CameraListDisplayMode_fourScreenMode;//4瓶模式
    }else
    {
        return CameraListDisplayMode_littleMode;//默认是小图模式
    }
}

//获取当前window
+ (UIWindow *)mainWindow
{
    UIApplication *app = [UIApplication sharedApplication];
    if ([app.delegate respondsToSelector:@selector(window)])
    {
        return [app.delegate window];
    }
    else
    {
        return [app keyWindow];
    }
}

//获取当前的时间
+(NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    //NSLog(@"currentTimeString =  %@",currentTimeString);
    
    return currentTimeString;
    
}

+(NSString *)getNowTimeTimestamp{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    return timeSp;
}

//当天0时刻的时间戳
+ (int)getNowadaysZeroTimeStamp
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:[NSDate date]];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    NSTimeInterval ts = (double)(int)[[calendar dateFromComponents:components] timeIntervalSince1970];
    int zeroTimeStamp = round(ts);//四舍五入
    return zeroTimeStamp;
}



+ (int)getNowTimeTimestampWithAppointdTimeStampDifference:(int)AppointdTimeStamp
{
    int nowTimeTimeStamp = [[unitl getNowTimeTimestamp] intValue];
    int difference = nowTimeTimeStamp - AppointdTimeStamp;
    return difference;
}

/**
 传入标准指定时间以及指定输出格式，输出当前指定时间时间戳
 
 @param formatTime 指定时间
 @param format 指定时间的格式 (@"YYYY-MM-dd HH:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
 @return 输出当前指定时间时间戳
 */
+ (NSInteger)timeSwitchTimeStamp:(NSString *)formatTime andFormatter:(NSString *)format
{    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format]; //
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate* date = [formatter dateFromString:formatTime]; //-将字符串按formatter转成nsdate
    //时间转时间戳的方法:
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    return timeSp;
}

/**
 传入时间戳以及指定输出格式，输出当前指定时间戳对应的时间
 
 @param timeStamp 想要转换的时间戳
 @param format 指定时间的格式 (@"YYYY-MM-dd HH:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
 @param tenBit 是否是ios 10位的 时间戳 一般服务器给的是13位的，需要处理
 @return 输出指定时间戳的对应时间
 */
+ (NSString *)timeStampSwitchTime:(int)timeStamp andFormatter:(NSString *)format IsTenBit:(BOOL)tenBit
{
    NSTimeInterval interval= tenBit? (timeStamp) : (timeStamp / 1000.0);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:format];
    NSString *currentDateStr = [dateFormatter stringFromDate:date];
    return currentDateStr;
}

//字典转换为json字符串
+ (NSString *)dictionaryToJSONString:(NSDictionary *)dictionary
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *jsonTemp = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        NSString *jsonResult = [jsonTemp stringByReplacingOccurrencesOfString:@" " withString:@""];
    return jsonResult;
}
+ (NSDictionary *)JSONStringToDictionary:(NSString *)JSONString
{
    NSDictionary *dataDict;
    if(JSONString)
    {
        // 字符串进行UTF8编码, 编码为流
        NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
        // 将流转换为字典
        dataDict = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
    }
    return dataDict;
}

//判断当前程序的环境
+(APP_Environment)environment
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:Environment]) {
        NSString * URLStr = [[NSUserDefaults standardUserDefaults]objectForKey:Environment];
        if ([URLStr isEqualToString:official_Environment_key]) {
            return Environment_official;
        }else if([URLStr isEqualToString:test_Environment_key]){
            return Environment_test;
        }
    }
    return Environment_unKnow;
}

+ (UIViewController *)currentTopViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}
+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
}

+ (float)getiPhoneNav_StatusHeight
{
    if (iPhone_X_) {
        return iPhoneXStatus_NavBar;
    }else{
        return Status_NavBar;
    }
}

+ (float)getiPhoneToolBarHeight
{
    if (iPhone_X_) {
        return iphoneXToolBarHeight;
    }else{
        return commonToolBarHeight;
    }
}



#pragma - mark - 页面跳转动画
+ (CATransition *)pushAnimationWith:(PushControllerAnimation)animation fromController:(id)delegate {
    CATransition * transition = [CATransition animation];
    //transition.duration = 0.6f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    switch (animation) {
        case 0:
            transition.type = @"rippleEffect";
            break;
        case 1:
            transition.type = @"cube";
            break;
        case 2:
            transition.type = @"suckEffect";
            break;
        case 3:
            transition.type = @"oglflip";
            break;
        case 4:
            transition.type = @"pageCurl";
            break;
        case 5:
            transition.type = @"pageUnCurl";
            break;
        case 6:
            transition.type = @"cameraIrisHollowOpen";
            break;
        case 7:
            transition.type = @"cameraIrisHollowClose";
            break;
        case 8:
            transition.type = @"fade";
            break;
        case 9:
            transition.type = @"push";
            break;
        case 10:
            transition.type = @"reveal";
            break;
        case 11:
            transition.type = @"moveIn";
            break;
        case 12:
            transition.type = @"fromBottom";
            break;
        case 13:
            transition.type = @"fromTop";
            break;
        case 14:
            transition.type = @"fromLeft";
            break;
        case 15:
            transition.type = @"fromRight";
            break;
        default:
            break;
    }
    transition.subtype = kCATransitionMoveIn;
    transition.delegate = delegate;
    return transition;
}


/**
    判断手机类型
 */
+ (NSString *)getDeviceType
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    //------------------------------iPhone---------------------------
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"] ||
        [platform isEqualToString:@"iPhone3,2"] ||
        [platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"] ||
        [platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"] ||
        [platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"] ||
        [platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"] ||
        [platform isEqualToString:@"iPhone9,3"]) return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"] ||
        [platform isEqualToString:@"iPhone9,4"]) return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone10,1"] ||
        [platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"] ||
        [platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"] ||
        [platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    if ([platform isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
    if ([platform isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,4"] ||
        [platform isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
    
    //------------------------------iPad--------------------------
    if ([platform isEqualToString:@"iPad1,1"]) return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"] ||
        [platform isEqualToString:@"iPad2,2"] ||
        [platform isEqualToString:@"iPad2,3"] ||
        [platform isEqualToString:@"iPad2,4"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad3,1"] ||
        [platform isEqualToString:@"iPad3,2"] ||
        [platform isEqualToString:@"iPad3,3"]) return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"] ||
        [platform isEqualToString:@"iPad3,5"] ||
        [platform isEqualToString:@"iPad3,6"]) return @"iPad 4";
    if ([platform isEqualToString:@"iPad4,1"] ||
        [platform isEqualToString:@"iPad4,2"] ||
        [platform isEqualToString:@"iPad4,3"]) return @"iPad Air";
    if ([platform isEqualToString:@"iPad5,3"] ||
        [platform isEqualToString:@"iPad5,4"]) return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad6,3"] ||
        [platform isEqualToString:@"iPad6,4"]) return @"iPad Pro 9.7-inch";
    if ([platform isEqualToString:@"iPad6,7"] ||
        [platform isEqualToString:@"iPad6,8"]) return @"iPad Pro 12.9-inch";
    if ([platform isEqualToString:@"iPad6,11"] ||
        [platform isEqualToString:@"iPad6,12"]) return @"iPad 5";
    if ([platform isEqualToString:@"iPad7,1"] ||
        [platform isEqualToString:@"iPad7,2"]) return @"iPad Pro 12.9-inch 2";
    if ([platform isEqualToString:@"iPad7,3"] ||
        [platform isEqualToString:@"iPad7,4"]) return @"iPad Pro 10.5-inch";
    
    //------------------------------iPad Mini-----------------------
    if ([platform isEqualToString:@"iPad2,5"] ||
        [platform isEqualToString:@"iPad2,6"] ||
        [platform isEqualToString:@"iPad2,7"]) return @"iPad mini";
    if ([platform isEqualToString:@"iPad4,4"] ||
        [platform isEqualToString:@"iPad4,5"] ||
        [platform isEqualToString:@"iPad4,6"]) return @"iPad mini 2";
    if ([platform isEqualToString:@"iPad4,7"] ||
        [platform isEqualToString:@"iPad4,8"] ||
        [platform isEqualToString:@"iPad4,9"]) return @"iPad mini 3";
    if ([platform isEqualToString:@"iPad5,1"] ||
        [platform isEqualToString:@"iPad5,2"]) return @"iPad mini 4";
    
    //------------------------------iTouch------------------------
    if ([platform isEqualToString:@"iPod1,1"]) return @"iTouch";
    if ([platform isEqualToString:@"iPod2,1"]) return @"iTouch2";
    if ([platform isEqualToString:@"iPod3,1"]) return @"iTouch3";
    if ([platform isEqualToString:@"iPod4,1"]) return @"iTouch4";
    if ([platform isEqualToString:@"iPod5,1"]) return @"iTouch5";
    if ([platform isEqualToString:@"iPod7,1"]) return @"iTouch6";
    
    //------------------------------Samulitor-------------------------------------
    if ([platform isEqualToString:@"i386"] ||
        [platform isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    
    return @"Unknown";
}

/**
获取手机尺寸
 */

+ (NSString *)getDeviceScreenSize
{
    NSString *phoneStr = [self getDeviceType];
    if ([phoneStr isEqualToString:@"iPhone 4"]||[phoneStr isEqualToString:@"iPhone 4S"]) {
        return @"3.5";
    }else if ([phoneStr isEqualToString:@"iPhone 5"]||[phoneStr isEqualToString:@"iPhone 5c"]||[phoneStr isEqualToString:@"iPhone 5s"]||[phoneStr isEqualToString:@"iPhone SE"]){
        return @"4.0";
    }else if ([phoneStr isEqualToString:@"iPhone 6"]||[phoneStr isEqualToString:@"iPhone 6s"]||[phoneStr isEqualToString:@"iPhone 7"]||[phoneStr isEqualToString:@"iPhone 8"]){
        return @"4.7";
    }else if ([phoneStr isEqualToString:@"iPhone 6 Plus"]||[phoneStr isEqualToString:@"iPhone 6s Plus"]||[phoneStr isEqualToString:@"iPhone 7 Plus"]||[phoneStr isEqualToString:@"iPhone 8 Plus"]){
        return @"5.5";
    }else if ([phoneStr isEqualToString:@"iPhone X"]||[phoneStr isEqualToString:@"iPhone XS"]){
        return @"5.8";
    }else if ([phoneStr isEqualToString:@"iPhone XR"]){
        return @"6.1";
    }else if ([phoneStr isEqualToString:@"iPhone XS Max"]){
        return @"6.5";
    }
    return @"Unknown";
}

#pragma mark - 警告框(特定的访问权限的提示框)
+ (void)createAlertActionWithTitle:(NSString *)title message:(NSString *)message andController:(UIViewController *)controller
{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *setAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"设置", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"好", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertCtrl addAction:setAction];
    [alertCtrl addAction:okAction];
    
    [controller presentViewController:alertCtrl animated:YES completion:nil];
}


+ (void)bytearrtostr:(Byte *)data length:(int)length
{
    char char_1 = '1',char_0 = '0';
    char *chars = (char *)malloc(length*8+1);
    chars[length*8] = '\n';
    for(int i=0;i<length;i++)
    {
        Byte bb = data[i];
        for(int j=0;j<8;j++)
        {
            if(((bb>>j)&0x01) == 1)
            {
                chars[i*8+j] = char_1;
            }else{
                chars[i*8+j] = char_0;
            }
        }
        char temp = 0;
        temp =  chars[i*8+0];chars[i*8+0] = chars[i*8+7];chars[i*8+7] = temp;
        temp =  chars[i*8+1];chars[i*8+1] = chars[i*8+6];chars[i*8+6] = temp;
        temp =  chars[i*8+2];chars[i*8+2] = chars[i*8+5];chars[i*8+5] = temp;
        temp =  chars[i*8+3];chars[i*8+3] = chars[i*8+4];chars[i*8+4] = temp;
    }
    NSString *string = [NSString stringWithCString:chars encoding:NSUTF8StringEncoding];
    NSLog(@"binnary string = %@",string);
}


//当前语言是否是简体中文
+ (BOOL)currentLanguageisSimplifiedChinese
{
    NSArray *languages = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
    NSString *currentLanguage = languages.firstObject;
//    NSLog(@"curentLanguage:%@",currentLanguage);
    if ([currentLanguage rangeOfString:@"zh-Hans-CN"].location != NSNotFound) {
        return YES;
    }else{
        return NO;
    }
}

/**
 当前账号是否是主账号
 @return 是否是主账号
 */
+ (BOOL)getMainAccount
{
    UserModel *userModel = [unitl getUserModel];
//    NSLog(@"用户类型:%d",userModel.user_type);
    if (userModel.user_type == 10) {
        return YES;
    }else{
        return NO;
    }
}

/**
 当前账号是否是文件夹模式
 @return 是否是文件夹模式
 */
+ (BOOL)isHasTreeNode
{
    //有无树节点
    NSUserDefaults *treeNodeDefault = [NSUserDefaults standardUserDefaults];
    BOOL isTreeNode = [[treeNodeDefault objectForKey:IS_TREE_NODE] boolValue];
    return isTreeNode;
}
/**
当前账号是否是通道列表
@return 是否是通道列表
*/
+ (BOOL)isHasChannelList
{
    //最后的列表展示是否是通道
    NSUserDefaults *channelModeDefault = [NSUserDefaults standardUserDefaults];
    BOOL isChannelList = [[channelModeDefault objectForKey:IS_CHANNEL_MODE] boolValue];
    return isChannelList;
}

//    char * s = "GoldenGlobalView";
//    char d[20];
//    char e[20];
//    char * cha = "cha";
//    memcpy(d, s + 12, 4);
//    memcpy(e, s + 12 * sizeof(char), 4 * sizeof(char));
//    printf("d 是： %s || e 是： %s /n   sizeof(char) = %lu  sizeof(cha) = %lu  ",d,e,sizeof(char),sizeof(cha));
//    memcpy(d, s, strlen(s));
//    printf("d = %s  || strlen(s)= %lu /n",d,strlen(s));
+ (void)writeFrameToH264File:(uint8_t *)frame FrameSize:(uint32_t)frameSize
{
    static FILE *_debugFile = NULL;
    static int _debugCount = 500;
    if (_debugCount > 0)
    {
        NSString * filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString * NSfilePath = [filePath stringByAppendingPathComponent:@"test_new_callback"];
        const char * fileName = [NSfilePath cStringUsingEncoding:NSUTF8StringEncoding];
        if (!_debugFile)
        {
            _debugFile = fopen(fileName, "wb+");
            NSLog(@"正在写入文件名1：%s 大小：%u",fileName,frameSize);
        }
        if (_debugFile)
        {
            fwrite(frame, 1, frameSize, _debugFile);
            NSLog(@"正在写入文件名2：%s 大小：%u 文件： %p",frame,frameSize,_debugFile);
        }
        NSLog(@"正在写入文件名3：%@ 大小：%u",filePath,frameSize);
        --_debugCount;
    }
    if (_debugCount <= 0)
    {
        if (_debugFile)
        {
            fclose(_debugFile);
            _debugFile = NULL;
            NSLog(@"写入文件完成！ 大小：%u",frameSize);
        }
    }
}

//************************************ 判断时间轴时间是否超过录像能播放的最大时间方法 **********************************
/**
 保存下显示的时间轴的最新能播放的日期，秒为单位【转换成一天中的秒数，不是距离1970年的秒数】
 
 @param second 秒数
 */
+ (void)saveTimeRulerLastVideoTimeBySecond:(NSInteger)second
{
    NSString * currentTimeRulerLastTimeStr = @"currentTimeRulerLastTimeStr";
    [unitl saveDataWithKey:currentTimeRulerLastTimeStr Data:[NSNumber numberWithInteger:second]];
}

/**
 获取保存下来的显示时间轴最新能播放的时间
 
 @return 返回最新能播放的时间
 */
+ (NSInteger)getTimeRulerLastVideoTimeBySecond
{
    NSString * currentTimeRulerLastTimeStr = @"currentTimeRulerLastTimeStr";
    NSInteger LastSecond = [[unitl getDataWithKey:currentTimeRulerLastTimeStr] integerValue];
    return LastSecond;
}

/**
 判断当前时间轴滚动的位置之后是否还有录像
 
 @param second 当前时间轴
 @return 如果时间轴的时间比能播放的最迟时间大，则返回YES，表示超过，不发送播放。反之NO，没超过，正常发送播放请求、
 */
+ (BOOL)isBeyondLastVideoListTimeLimit:(NSInteger)second
{
    NSInteger videoLastTime = [unitl getTimeRulerLastVideoTimeBySecond];
    NSLog(@"对比时间 videoLastTime:%ld === second:%ld",(long)videoLastTime,second);
    if (second < videoLastTime) {
        return NO;//时间轴时间小于能播放的最大时间，表示没超过，返回NO
    }else
    {
        return YES;
    }
}

@end
