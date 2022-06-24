//
//  Defines.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2017/8/10.
//  Copyright © 2017年 张策. All rights reserved.
//

#ifndef Defines_h
#define Defines_h

typedef NS_ENUM(NSUInteger, MoveCellState) {
    MoveCellStateFourScreen = 0,
    MoveCellStateOneScreen,
    MoveCellStateFourScreen_HengPing,
    MoveCellStateOneScreen_HengPing
};

typedef NS_ENUM(NSUInteger,APP_Environment) {
    Environment_unKnow = 1,
    Environment_official,
    Environment_test
};

typedef NS_ENUM(NSUInteger,CameraListDisplayMode){
    CameraListDisplayMode_littleMode,
    CameraListDisplayMode_largeMode,
    CameraListDisplayMode_fourScreenMode,
};

typedef NS_ENUM(NSUInteger,AlarmType){
    //1和2统一归为移动侦测报警
    AlarmType_artificialVideo = 1,//人工视频报警
    AlarmType_motion,//运动目标检测报警
    AlarmType_remnant,//遗留物检测报警
    AlarmType_objectRemoved,//物体移除检测报警
    AlarmType_tripwire,//绊线检测报警
    AlarmType_intrusion,//入侵检测报警
    AlarmType_retrograde,//逆行检测报警
    AlarmType_hover,//徘徊检测报警
    AlarmType_traffic,//流量统计报警
    AlarmType_density,//密度检测报警
    AlarmType_abnormalVideo,//视频异常检测报警
    AlarmType_fastMoving,//快速移动报警
    AlarmType_FIRE_EXIT,//消防通道占用检测
    AlarmType_SMOKE_AND_FIRE,//烟火检测
    AlarmType_TRAFFIC_LANE_PARK,//异常停车检测
    AlarmType_abnormalTemperature = 30,//体温异常报警
};

//告警查询方式
typedef NS_ENUM(NSUInteger,AlarmVideoType){
    AlarmVideoType_shortVideo = 0,//短视频
    AlarmVideoType_CloudVideo,//云端录像
    AlarmVideoType_SDVideo,//SD卡录像
};

#endif /* Defines_h */
