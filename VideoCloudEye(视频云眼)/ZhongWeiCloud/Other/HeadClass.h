//
//  HeadClass.h
//  ZhongWeiEyes
//
//  Created by 张策 on 16/10/20.
//  Copyright © 2016年 张策. All rights reserved.
//

#ifndef HeadClass_h
#define HeadClass_h
#import "Toast.h"
//网络请求
#import "HDNetworking.h"
//控制器基类
#import "BaseViewController.h"
//刷新
#import <MJRefresh.h>
//Bugly
#import <Bugly/Bugly.h>
//sdweb
#import <UIImageView+WebCache.h>
//转模型
#import <MJExtension.h>
//用户模型
#import "UserModel.h"
//图片毛玻璃
#import "UIImageView+LBBlurredImage.h"
#import "UIImage+ImageEffects.h"
//viewframe.h
#import "UIView+frame.h"
//颜色
#import "UIColor+Expand.h"
//图片视频写入
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
//提示
#import "XHToast.h"
//单例
#import "MySingleton.h"
#import "BaseUrlModel.h"//基础URLmodel
#import "AdUrlModel.h"//广告页model
#import "BaseUrlDefaults.h"
#import "LoginAccountModel.h"//登录信息
#import "LoginAccountDefaults.h"
//字符串代理
#import "NSString+Md5String.h"
//工厂UI
#import "FactoryUI.h"
//hud
#import "LBProgressHUD.h"
//视频流加解密
#import "jw_cipher.h"

#import "Defines.h"

#import "unitl.h"
#import "FileTool.h"

#import "GetAccountInfo.h"
//检查网络
#import "SXLReachability.h"
//等待加载框
#import "CircleLoading.h"

#import "CommonMacros.h"

#import "NotificationMacros.h"
#import "UIControl+JPBtnClickDelay.h"
#import "BaseTableView.h"
//选择
#import "ChooseDialog.h"
//单列宏
#import "HDSingleton.h"
#import "JWfileManager.h"
#import "WeiCloudListModel.h"
#import "JWcameraModelManger.h"
#import "NSDictionary+Extension.h"
#import "NSArray+Extension.h"

#import "UIMacros.h"
//导航栏退出样式
#import "UINavigationController+push_pop.h"

//获取通道model
#import "MultiChannelDefaults.h"
#import "MultiChannelModel.h"//通道model


//AVPlayer
#import "UILabel+LXLabel.h"
#import "UIColor+Expanded.h"
#import "LxButton.h"
#import "UIView+LX_Frame.h"
#import "LXAVPlayer.h"


#define IP [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_IP_KEY]
#define HTTPTYPE [[NSUserDefaults standardUserDefaults] objectForKey:HTTP_TYPE]//:21200
#define BASEURL_officialEnvironment [NSString stringWithFormat:@"%@://%@/vcloud/",HTTPTYPE,IP]
#define BASEURL_testEnvironment [NSString stringWithFormat:@"%@://%@/vcloud/",HTTPTYPE,IP]
/*********************************************************************************************************/

static NSString * const official_Environment_key = @"生产环境";//作为key
static NSString * const test_Environment_key = @"测试环境";



/***生产环境****/
//static NSString * const BASEURL_officialEnvironment = @"https://yun.joyware.com/vcloud/";
/***测试环境***/
//static NSString * const BASEURL_testEnvironment = @"http://y.yun.joyware.com/vcloud/";



/***方毅调试地址***/
//static NSString * const BASEURL_officialEnvironment = @"http://10.100.23.178:8088/vcloud/";

/***测试-阿里云***/
//static NSString * const BASEURL_testEnvironment = @"http://y.yun.joyware.com/vcloud";
/***测试-华为云***/
//static NSString * const BASEURL_testEnvironment = @"http://y.yun.joyware.com/vcloudhw";
/*********************************************************************************************************/

//当前app的版本号【上线修改版本号】
static NSString * const APPVERSION = @"1.3.2";

#define App_Name      ([[[NSBundle mainBundle] infoDictionary] safeObjectForKey:@"CFBundleDisplayName"])

#define App_Version   ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"])
 
/*********************************************************************************************************/

//平台：iOS & Android
//AppKey：24720803
//AppSecret：91abf6665743c16472cc4409ccf34f6a
//PackageName：com.joyware.CloudEye
//BundleId：com.zhongweidianzi.VideoEyes

//static NSString *const CloudPushAppKey = @"23639306";
//static NSString *const CloudPushAppSecret = @"0445529f89a89611b3419c1f2cfbd67d";

static NSString *const CloudPushAppKey = @"24720803";
static NSString *const CloudPushAppSecret = @"91abf6665743c16472cc4409ccf34f6a";


//测试用，看是否能推送
//static NSString *const CloudPushAppKey = @"LTAI4PCmZ1tfKLUn";
//static NSString *const CloudPushAppSecret = @"SJRUzmwA5rYFg6mEOxoPP7Mmcmlh33";

static NSString *const weixinAppID_test = @"wxc206490c80aae4b6";//wx936da82f3a43bfa6//新：wxc206490c80aae4b6
static NSString *const weixinAppSecret_test = @"26346cd956bb8843e09ac1a7e882091d";//4f3277cb16643ba0ce19b74296ac3edb//新：

static NSString *const weixinAppID_official = @"wx936da82f3a43bfa6";
static NSString *const weixinAppSecret_official = @"4f3277cb16643ba0ce19b74296ac3edb";

static NSString * const shiguangyushipingAPPID = @"1462030330";
static NSString * const shiguangyushipingAPPStroeURL = @"itms-apps://itunes.apple.com/cn/app/%E4%B8%AD%E5%A8%81%E8%A7%86%E4%BA%91/id1211581225?mt=8";

static NSString * const slideshowURL = @"http://zwsystatics-test.oss-cn-hangzhou.aliyuncs.com/";//轮播图的地址前缀

static NSString * const app_type = @"200";//iOS后台约定为200，安卓为100

static int const timeOutLimited = 15;//码流超时时间上限 15s
static int const FPS = 16;//frames per second
static float const SPF = 0.0625;//sencond per frames :number of seconds each frame
static int const heartBeat_intervalTime = 10;//心跳间隔时间

#define LOGINPHONE @"loginphone"
#define PSDSUFFIX @"Joyware2018"
#define FingerPrint_key @"FingerPrint"

#define BUGLY_APP_ID @"6f4000a01b"//buglyAPPID:6f1318b546

#define CURRENTDISPLAYMODE @"currentDisplayModeBigORMyDevice"//标记当前是大图模式还是小图模式

//ap模式下，请求后缀
#define WIFI_ADRESS @"RPC_JSON"

//获取截图地址的拼接url，需要最后一个/
#define getCutImageBaseURLDirectory @"/Documents/CutImage/"
#define saveCutImageBaseURLDirectory @"/Documents/CutImage"

//更新某一设备的活动检测
#define deviceisActivity @"deviceisActivity"
//更新组内所有的设备活动检测
#define allDeviceisActivity @"allDeviceisActivity"

#define RedDotTime 5//底部红点等待时间
//app tabbar下面标签栏的开关
#define AppSettings @"appSettings"

#define DefaultDeviceCoverImage [UIImage imageNamed:@"img2"]

#define groupBtnTag 22222
#define groupBtnLabelTag 33333

#define GroupNameAndIDArr_key @"GroupNameAndIDArr"
//创建/删除组别成功，通知更新UI，这里UI有3个方面，1.上面的btn，2.下面btn对应的界面 3.左上角的列表界面
#define GroupCreateOrDeleteSuccess_updateUI @"GroupCreateOrDeleteSuccess_updateUI"

//用来本地化当前显示的组别的key
#define CurrentDisplayGroupIndex @"CurrentDisplayGroupIndex"
//保存当前用户的完整带有组别的设备列表
#define saveAllGroupCameraModel_key @"saveAllGroupCameraModel_key"

//文件保存时候使用的KEY
#define MYFILE @"MYFILE"

//=================断网时暂时替代网址
//C11广告页图片地址
#define C11IMGURL @"http://zwsystatics-test.oss-cn-hangzhou.aliyuncs.com/advertising/200/1542854744277_engine-logo2.png"
//C11有赞链接地址
#define C11LINKURL @"https://h5.youzan.com/wscshop/goods/2ofc1qtfkg517?alias=2ofc1qtfkg517&reft=1542683426588&spm=f71861618&form=singlemessage"
//PT12广告页图片地址
#define PT12IMGURL @"http://zwsystatics-test.oss-cn-hangzhou.aliyuncs.com/advertising/200/1542854712868_engine-logo1.png"
//PT12有赞链接地址
#define PT12LINKURL @"https://h5.youzan.com/wscshop/goods/1y2ut6c8vscm3?alias=1y2ut6c8vscm3&reft=1542683468916&spm=f71861618&form=singlemessage"

//帮助文档链接地址
#define HELPLINK isSimplifiedChinese?@"http://yun.joyware.com/appHelp/index.html":@"http://yun.joyware.com/appHelp-en/"
//用户协议链接地址
#define USERAGREEMENTLINK isSimplifiedChinese?@"https://yun.joyware.com/sgyService/#/":@"http://y.yun.joyware.com/sgyService/#/en"
//APP下载链接地址
#define APPDOWNLOADLINK isSimplifiedChinese?@"http://yun.joyware.com/app":@"https://yun.joyware.com/app-download-en/"
//banner地址
#define APPBANNERLINK @"http://zwsystatics.oss-cn-hangzhou.aliyuncs.com/"
#endif /* HeadClass_h */

