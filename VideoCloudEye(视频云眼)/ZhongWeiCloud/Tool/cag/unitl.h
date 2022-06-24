//
//  unitl.h
//  ZhongWeiEyes
//
//  Created by 苏旋律 on 17/5/26.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum{
    rippleEffect = 0, //波纹效果
    cube,//立体翻转效果
    suckEffect,//像被吸入瓶子的效果
    oglflip,//翻转
    pageCurl,//翻页效果
    pageUnCurl,//反翻页效果
    cameraIrisHollowOpen,//开镜头效果
    cameraIrisHollowClose,//关镜头效果
    fade,//淡入淡出
    push,//推进效果
    reveal,//揭开效果
    moveIn,//慢慢进入并覆盖效果
    fromBottom,//下翻页效果
    fromTop,//上翻页效果
    fromLeft,//左翻转效果
    fromRight//右翻转效果
} PushControllerAnimation;


@interface unitl : NSObject
CGFloat FitWidth(CGFloat width);
CGFloat FitHeight(CGFloat height);



/**
 根据字符串，判断其是否为空

 @param str 传进来的字符串
 @return 是否为空bool值
 */
+ (BOOL)isNull:(NSString*) str;

/**
 生成保存以及取的key

 @param suffix 后缀
 @param key 固定的字符串key
 @return 拼接好的带有id的key
 */
+ (NSString *)getKeyWithSuffix:(NSString *)suffix Key:(NSString *)key;

/**
 判断这个key是否有保存

 @param key key
 @return 是否保存bool值
 */
+ (BOOL)isSaveWithKey:(NSString *)key;

/**
 根据key保存数据

 @param key key
 @param data 任意数据
 */
+ (void)saveDataWithKey:(NSString *)key Data:(id)data;

/**
 保存需要序列化的数据，如model类

 @param key key
 @param data model类型数据
 */
+ (void)saveNeedArchiverDataWithKey:(NSString *)key Data:(id)data;

/**
 根据key获取数据

 @param key key
 @return 获取之前保存的数据
 */
+ (id)getDataWithKey:(NSString *)key;

/**
 根据key获取被序列号的数据

 @param key key
 @return 获取被序列号的数据
 */
+ (id)getNeedArchiverDataWithKey:(NSString *)key;

/**
 根据指定key，清除数据

 @param key key
 */
+ (void)clearDataWithKey:(NSString *)key;


/*******************账号信息相关********************/

/**
 一键打印 User_id 和accessToken
 */
+ (void)log_user_Info;

/**
 判断是否是邮箱登录的账号
 */
+ (BOOL)isEmailAccountType;
/**
 判断是否是海外用户
 */
+ (BOOL)isOverseasCustomers;
/**
 获取用户model
 
 @return  获取用户model
 */
+ (UserModel *)getUserModel;
/**
 获取账号的uer_id

 @return  获取账号的uer_id
 */
+ (NSString *)get_User_id;

/**
 获取账户的accessToken

 @return accessToken
 */
+ (NSString *)get_accessToken;

/**
 获取uuid

 @return uuid
 */
+ (NSString *)getKeyChain;

/**
 获取账户的user_mobile
 */
+ (NSString *)get_user_mobile;

/**
 获取当前用户上次刷新成功的时候的RefreshToken的刷新时间

 @return RefreshToken的刷新时间
 */
+ (NSString *)get_refreshTime;

/**
 上次刷新RefreshToken是否成功(注：默认为：NO)只是上个请求是否成功的标记

 @return 刷新RefreshToken是否成功
 */
+ (BOOL)isRefreshTokenSucceed_sign;

/**
上次刷新RefreshToken是否成功

@return 刷新RefreshToken是否成功
*/
+ (BOOL)isRefreshTokenSucceed;

/**
    判断手机是否处于方法模式 YES：是放大模式；NO：标准模式
 */
+ (BOOL)isZoomMode;
/*******************获取首页摄像机model********************/

/**
 获取当前用户的 根据userID保存的摄像头model列表

 @return 摄像头model列表arr
 */
+ (NSArray *)getCameraModel;

/**
 根据userID保存当前的的摄像头model列表数组

 @param cameraModelArr 当前需要保存的摄像头列表数组
 */
+ (void)saveCameraModel:(NSMutableArray *)cameraModelArr;

/**
 清除根据userID存在本地的摄像头列表数组
 */
+ (void)clearCameraModel;

//****************  ***【添加组别之后】***


/**
 获取当前组别的名称和ID

 @return 组别的名称和ID
 */
+ (NSMutableArray *)getGroupNameAndIDArr;

/**
 根据userID，保存当前组别的名称和ID

 @param dataArr 组别的名称和ID
 */
+ (void)saveGroupNameAndIDArr:(NSMutableArray *)dataArr;

/**
 获取当前正在显示的组别的在整个后台给的数据中的index

 @return GroupIndex
 */
+ (NSInteger)getCurrentDisplayGroupIndex;


/**
 根据userID，保存当前正在显示的组别设备的index

 @param index index
 */
+ (void)saveCurrentDisplayGroupIndex:(NSInteger)index;

/**
 清除，根据userID，保存的当前正在显示的组别设备的index
 */
+ (void)clearCurrentDisplayGroupIndex;



/**
 【置顶】当前选中的组别,置顶，并保存，【注释：现在选择的实现方式是，我们自己实现，后台不实现，故写本地方法】

 @param index 当前组别的index
 */
+ (void)stickGroupIndex:(NSInteger)index;


/**
 因为后台约定，获取保存的数据的最后一个是默认组别的数据

 @return 返回【我的设备】默认组别里面的数据
 */
+ (NSArray *)getDefalutGroupDeviceModel;

/**
 根据当前正在显示组别的index 获取 当前用户的根据userID保存的摄像头model列表
 【注意：根据保存的时候的arr,根据其index取出相应组别的组的信息以及里面的设备信息】
 @return 带有组别信息的和设备列表arr
 */

+ (NSMutableArray *)getCameraGroupModelIndex:(NSInteger )index;
/**
 根据当前正在显示组别的index 获取 当前用户的根据userID保存的摄像头model列表
 【注意：根据保存的时候的arr,根据其index取出相应组别里面的设备信息】
 @return 只有该组别里面设备列表arr
 */
+ (NSMutableArray *)getCameraGroupDeviceModelIndex:(NSInteger)index;

/**
 【用于排序后，保存某一分组的排序后的设备列表】

 @param GroupDevModel 排序后的组的设备列表
 @param index 该列表在的组的index
 */
+ (void)saveCameraGroupDeviceModelData:(NSMutableArray *)GroupDevModel Index:(NSInteger)index;

/**
 更加groupID查询这个id在当前传入数据的分组数据中的index

 @param groupID 需要查找的groupID
 @return 这个groupID在所要查询的数据中的index
 */
+ (NSInteger)getCorrectIndexWithGroupID:(NSString *)groupID NeedFindData:(NSMutableArray *)data;

///**
// 改变本地存储的设备model的某一条属性
//
// @param devID <#devID description#>
// @return <#return value description#>
// */
//+ (NSMutableArray *)changeAppointDeviceModelPropertyDeviceID:(NSString *)devID;


/**
 获取当前用户下，所有的设备列表，不区分组别。

 @return 所有设备列表
 */
+ (NSMutableArray *)getAllDeviceCameraModel;


/**
 获取所有的当前完整的组设备信息，带组别和设备，区分组别。

 @return 完整的组设备信息
 */
+ (NSMutableArray *)getAllGroupCameraModel;
/**
 根据userID保存当前的当前用户所有组别以及摄像头model列表数组
 【注意：这里保存的是以后台返回deviceGroup的model形式的arr】
 @param cameraModelArr 当前需要保存的摄像头列表数组
 */
+ (void)saveAllGroupCameraModel:(NSMutableArray *)cameraModelArr;

/**
 清除根据userID存在本地的整个Group的摄像头列表数组
 */
+ (void)clearAllGroupCameraModel;


/*******************获取当前记录下的需要呈现的视图********************/


/**
 当前camera List是什么展示模式

 @return 当前camera List展示模式
 */
+ (CameraListDisplayMode)CameraListDisplayMode;

/*******************获取当前时间相关********************/

/**
 获取当前时间

 @return 字符串类型时间
 */
+ (NSString*)getCurrentTimes;

/**
 获取当前时间的时间戳

 @return 当前时间的时间戳
 */
+ (NSString *)getNowTimeTimestamp;

/**
 获取当天0时刻的时间戳
 
 @return 当天0时刻的时间戳
 */
+ (int)getNowadaysZeroTimeStamp;


/**
 获取当前时间与指定时间的时间戳的差值（秒数）

 @param AppointdTimeStamp 指定时间时间戳
 @return 差值
 */
+ (int)getNowTimeTimestampWithAppointdTimeStampDifference:(int)AppointdTimeStamp;

/**
 传入标准指定时间以及指定输出格式，输出当前指定时间时间戳
 
 @param formatTime 指定时间
 @param format 指定时间的格式 (@"YYYY-MM-dd HH:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
 @return 输出当前指定时间时间戳
 */
+ (NSInteger)timeSwitchTimeStamp:(NSString *)formatTime andFormatter:(NSString *)format;

/**
 传入时间戳以及指定输出格式，输出当前指定时间戳对应的时间
 
 @param timeStamp 想要转换的时间戳
 @param format 指定时间的格式 (@"YYYY-MM-dd HH:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
 @param tenBit 是否是ios 10位的 时间戳 一般服务器给的是13位的，需要处理
 @return 输出指定时间戳的对应时间
 */
+ (NSString *)timeStampSwitchTime:(int)timeStamp andFormatter:(NSString *)format IsTenBit:(BOOL)tenBit;

/*******************获取当前视图相关********************/
/**
 获取当前的主window
 
 @return 当前主window
 */
+ (UIWindow *)mainWindow;

/**
 获取当前最上层显示的VC

 @return 当前显示的vc
 */
+ (UIViewController *)currentTopViewController;
+ (UIViewController *)_topViewController:(UIViewController *)vc;
/*******************字典转换成json字符串********************/

/**
 字典转json字符串

 @param dictionary 传入字典
 @return 转好的json字符串
 */
+ (NSString *)dictionaryToJSONString:(NSDictionary *)dictionary;

/**
  处理后台返回的json(或NSDictionary)形式字符串,返回可用字典

 @param str 处理后台返回的json(或NSDictionary)形式字符串
 @return 字典
 */
+ (NSDictionary *)JSONStringToDictionary:(NSString *)JSONString;

/*******************获取当前app环境********************/
/**
 获取当前app的环境

 @return 当前app的环境
 */
+ (APP_Environment)environment;


/**
获取iPhone 的导航栏高度
 @return 高度
 */
+ (float)getiPhoneNav_StatusHeight;
/**
获取iPhone 的工具栏高度
@return 高度
 */
+ (float)getiPhoneToolBarHeight;

/**
 转场动画效果
 */
+ (CATransition *)pushAnimationWith:(PushControllerAnimation)animation fromController:(id)delegate;
/**
 判断手机类型
 */
+ (NSString *)getDeviceType;
/**
 获取手机屏幕尺寸
 */
+ (NSString *)getDeviceScreenSize;

/**
 警告框(特定的访问权限的提示框)
 */
+ (void)createAlertActionWithTitle:(NSString *)title message:(NSString *)message andController:(UIViewController *)controller;

/**
 获取当前手机语言是否是中文
 @return 是否是中文
 */
+ (BOOL)currentLanguageisSimplifiedChinese;

/**
 当前账号是否是主账号
 @return 是否是主账号
 */
+ (BOOL)getMainAccount;

/**
     当前账号是否是文件夹模式
     @return 是否是文件夹模式
 */
+ (BOOL)isHasTreeNode;

/**
    当前账号是否是通道列表
    @return 是否是通道列表
*/
+ (BOOL)isHasChannelList;

//以二进制方式打印数组
//data 待打印二进制
//length待打印长度
+ (void)bytearrtostr:(Byte *)data length:(int)length;
//用来把已经分成每一帧的裸码流写成h264的文件
+ (void)writeFrameToH264File:(uint8_t *)frame FrameSize:(uint32_t)frameSize;

//************************************ 判断时间轴时间是否超过录像能播放的最大时间方法 **********************************
/**
 保存下显示的时间轴的最新能播放的日期，秒为单位【转换成一天中的秒数，不是距离1970年的秒数】
 
 @param second 秒数
 */
+ (void)saveTimeRulerLastVideoTimeBySecond:(NSInteger)second;

/**
 获取保存下来的显示时间轴最新能播放的时间
 
 @return 返回最新能播放的时间
 */
+ (NSInteger)getTimeRulerLastVideoTimeBySecond;

/**
 判断当前时间轴滚动的位置之后是否还有录像
 
 @param second 当前时间轴
 @return 如果时间轴的时间比能播放的最迟时间大，则返回YES，表示超过，不发送播放。反之NO，没超过，正常发送播放请求、
 */
+ (BOOL)isBeyondLastVideoListTimeLimit:(NSInteger)second;
@end
