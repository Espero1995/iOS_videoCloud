//
//  NotificationMacros.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/4/4.
//  Copyright © 2018年 张策. All rights reserved.
//

#ifndef NotificationMacros_h
#define NotificationMacros_h
//通知
//删除cell
#define DELETEPLAYCELL @"deletePlayCell"
//重新开始播放
#define STARTCELLVIDEOMANAGER @"startCellVideoManager"
//全部暂停
#define STOPCELLVIDEOMANAGER @"stopCellVideoManager"
//截图
#define STARTSCREENSHOT @"startScreenshot"
//声音开关
#define SOUNDOPEN @"soundOpen"
//历史恢复开关开
#define HISTORYPLAYYES @"historyPlayYes"
//历史恢复开关关闭
#define HISTORYPLAYNO @"historyPlayNO"
//历史开关可选中
#define BTNHISTORYENAL @"btnHistoryEnal"
//停止回放界面视频音频播放
#define STOPRECORDPALYPLAY @"stopRecordPlayPlay"
//开始录像
#define BEGINSTARTRECORD @"beginStartRecord"
//结束录像
#define STOPRECORD @"stopRecord"
//结束全屏播放
#define STOPFULLPLAY @"stopFullPlay"
//开启云台控制
#define OPENSPET @"openSpet"
//关闭云台控制
#define CLOSESPET @"closeSpet"
//是否子码流
#define BOOLSUBSTREAM @"boolsubstream"
//码流监控
#define ONLINESTREAM @"onlineStream"
//进入后台停止播放
#define BEBACKGROUNDSTOP @"beBackgroundStop"
//进入前台重新播放
#define BEBEFORSTART @"beBeforStart"
//播放停止
#define VIDEOISSTOP @"videoIsStop"
//隐藏加载动画
#define HIDELOADVIEW @"hideloadview"
//token失败推出到登录界面
#define BACKLOGIN @"backLogin"

//码流回调回来的用来显示时间时间戳
#define RETURNTIMESTAMP @"returnTimeStamp"
//只用来跟动时间轴时间戳
#define RETURNTIMESTAMP_TIMERULER @"returnTimeStamp_timeruler"
//截图文夹名
#define PATHSCREENSHOT @"实时监控截图"
//视频文件夹名
#define PATHVIDEO @"实时监控视频"
//保存图片锁
#define CUTLOCK @"cutLock"
//推送
#define PUSH @"push"
//播放失败，用重新播放图标代替
#define PLAYFAIL @"playfail"

#define PLAYSUCCESS @"playsuccess"
//分屏通知
#define  SPLITSCREENNOTIFICATION @"SplitScreenNotification"
//双击
#define  DOUBLETAPNOTIFICATION   @"doubleTapNotification"
//移动后的index
#define MOVEINDEXNOTIFICATION @"moveIndexNotification"
//横屏过，通知，分屏方案不同
#define HASHENGPING @"hasHengPing"
//在四分屏的状态，直接横屏全屏
#define DIRECTHENGPING @"directHengPing"

//单击，集成在long手势上，在手势开始的时候，改变selected的值
#define CHANGGESELECTEDVALUE @"changgeSelectedIndex"

#define MOVETODELETENOTIFICATION @"movetodeleteNotification"
//竖屏单屏的时候，下面的scrollView可以滚动
#define SCROLLVIEWSCROENABLE @"ScrollViewScroEnable"

//截图后用来通知主界面更新这张图片
#define UpDataCutImageWithID @"UpDataCutImageWithID"

//设备删除或者添加刷新首页
#define ADDORDELETEDEVICE @"AddorDeleteDevice"
//通知支付成功后，跳转界面
#define PAYSUCCESSJUMPTOVC @"paySuccessJumpToVC"
//排序通知
#define UPDATESORT @"updateSort"

//userdefult
//token模型
#define JWACCESSTOKEN @"JWAccessToken"
//用户模型
#define USERMODEL @"userModel"
//用户id
#define USERID @"userId"
//令牌
#define TOKEN @"token"
//手机号码
#define PHONENUM @"phoneNumber"
//验证码
#define CODENUM @"codeNumber"
//用户登录的信息
#define USERLOGINMES @"usetLoginMes"
//是否登录
#define ISLOGIN @"isLogin"
//是否是hd
#define ISHD @"isHd"


//视频列表模型
#define VIDEOLISTMODEL @"VideoListModel"

#define Environment @"Environment"

#define VIDEOLISTMODEL_Name @"VIDEOLISTMODEL_Name"

//排序后保存的 带顺序的视频列表数据 【唯一，用户退出登录之后，则删除】
#define AFTERSORTVIDEOLISTARR  @"AfterSortVideoListArr"

//用来在缩略图跳转退回界面
#define SCREENSTATUS @"ScreenStatus"
#define SHU_PING @"shuping"
#define HENG_PING @"hengping"


//全局，流量提示语
#define netWorkReminder @"您当前正在使用2G/3G/4G流量观看视频！"
//RefreshToken 刷新token的同步锁
#define Refresh_Lock @"Refresh_Lock"

//标记播放器的声音、清晰度等参数记录本地的key
#define VideoPlayerParameters @"VideoPlayerParameters"
//有赞登录保存本地的model key
#define youzanLoginModel @"yzLoginUserModel"

//滚动首页列表，nav可以缩回小的状态。
#define tableviewScrollow_up @"tableviewScrollow_up"
#define tableviewScrollow_down @"tableviewScrollow_down"

/*******************/
#define OLDRECT_FOURSCREEN @"oldRect_fourScreen"
#define OLDRECT_FOURSCREEN_HENGPING @"oldRect_fourScreen_hengPing"


//暂时nav的状态 NAV_Status_UP NAV_Status_DOWN
#define NAV_Status @"NAV_Status"

//用于1.首页上面点击选择 和 左上角选择分组列表点击
#define chooseGroup @"chooseGroup"
//用于 刷新组以及组数据之后 更新title上面的分组btn
#define reloadGroupSCBtn @"reloadGroupSCBtn"

//重新检测WIFI网络情况
#define RECHECKNETSTATUS @"RECHECKNETSTATUS"

//IP
#define CURRENT_IP_KEY @"CURRENT_IP_KEY"
//IP类型
#define HTTP_TYPE @"HTTP_TYPE"
//是否有树节点
#define IS_TREE_NODE @"IS_TREE_NODE"
//是否是通道列表模式 (YES:通道列表；NO:设备列表)
#define IS_CHANNEL_MODE @"IS_CHANNEL_MODE"
//告警查询类型 短视频、云端、SD卡
#define ALARMVIDEOTYPE @"AlarmVideoType"

#endif /* NotificationMacros_h */
