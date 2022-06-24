//
//  WeiCloudListModel.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/1/20.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <Foundation/Foundation.h>
@class deviceGroup,dev_list,ext_info,Feature_cms,shareFeature;
@interface WeiCloudListModel : NSObject<NSCoding>

@property (nonatomic,copy)NSArray<deviceGroup*> *deviceGroup;

@end

@interface deviceGroup : NSObject<NSCoding>

@property (nonatomic,strong)  NSArray *devcieIds;/**< 设备分组里面的设备id */
@property (nonatomic,copy)   NSString *ownerId;/**< 分组拥有者的id */
@property (nonatomic,copy)   NSDictionary *channels;/**< 通道 *///这个给定的json里面没有数据是个字典。
@property (nonatomic,copy)   NSString *groupName;/**< 分组的名称 */
@property (nonatomic,copy)   NSString *silentMode;/**< //一键切换在家模式(0/1)(意义同设备) */
@property (nonatomic,copy)   NSString * createDate;/**< 分组创建的日期 */
@property (nonatomic,copy)   NSString *groupId;/**< 分组的id */
@property (nonatomic,copy)   NSString *enableSensibility;/**< //一键关闭/启用移动侦测(0/1)(意义同设备) */
@property (nonatomic,assign) BOOL top;/**< 是否置顶 */
@property (nonatomic,strong)  NSArray<dev_list *> *dev_list;

@end


@interface dev_list : NSObject<NSCoding>
/*设备id*/
@property (nonatomic,copy)NSString *ID;
/*设备图片*/
@property (nonatomic,copy)NSString *vsample;
/*设备名称*/
@property (nonatomic,copy)NSString *name;
/*设备状态*/
@property (nonatomic,assign)NSInteger status;
/*版本号*/
@property (nonatomic,copy)NSString *version;
/*是否开放*/
@property (nonatomic,assign)BOOL is_public;
/*是否启用云安全机制:是否加密*/
@property (nonatomic,assign)BOOL enable_sec;
/*添加该设备的时间点*/
@property (nonatomic,copy)NSString *importDate;
/*设备验证码:密钥 key*/
@property(nonatomic , copy) NSString * dev_p_code;
/*设备型号*/
@property (nonatomic,copy)NSString *type;
/*通道数*/
@property (nonatomic,assign)int chan_size;
/*共享的用户ID*/
@property (nonatomic,copy)NSString *owner_id;
/*共享的用户名*/
@property (nonatomic,copy)NSString *owner_name;
/*通道别名*/
@property (nonatomic,strong)NSDictionary *chan_alias;
/*组的ID*/
@property (nonatomic,copy)NSString *groupId;
/**/
@property (nonatomic,strong)NSString *extParams;
/*设备类别:(区分是IPC还是网关)*/
@property (nonatomic,assign)int device_class;
/*通道列表:(chan_id:<通道ID>、name:通道名称(设备上报名称)、alias:通道别名)*/
@property (nonatomic,strong)NSArray *chans;
/*扩展信息:(Feature:<能力集合>、PortInfo:<报警端口信息>、DiskInfo:<磁盘信息>)*/
@property (nonatomic,strong)ext_info *ext_info;
/**
 * 标记在家模式的开关，在家：1，离家：0
 */
@property (nonatomic, copy) NSString* silentMode;
/**
 * 设备是否插入sd卡(0代表不支持,1代表支持)
 */
@property (nonatomic, copy) NSString* enableSD;
/**
 * 设备是否开通云存(0代表未开通,1代表开通)
 */
@property (nonatomic, copy) NSString* enableCloud;
/**
 * 在分享的时限内设备分享的权限是否能被操作(0代表不能,1代表能)
 */
@property (nonatomic,assign)int enableOperator;
/**
 *  是否开启移动侦测功能，1：开启，0：关闭
 */
@property (nonatomic, copy) NSString* enableSensibility;
/**
 * 红外功能的开关，红外开：1，关：0
 */
@property (nonatomic, copy) NSString* enableInfrared;
/**
 * 每个设备允许分享用户的个数
 */
@property (nonatomic, assign) int shraedLimit;
/**
 * 每个设备的通道数目
 */
@property (nonatomic, assign) long chanCount;

//新添加
@property (nonatomic, copy) NSString *grantPlanId;
@property (nonatomic, copy) NSString *firstOnlineDate;
@property (nonatomic, copy) NSString *autoUpgrade;
@property (nonatomic, copy) NSString *sharePolice;
@property (nonatomic, copy) NSString *grantInfo;


@property (nonatomic, strong) UIImageView* coverImageView;/**< 每个设备的封面展示图，由enable_sec和key，加密获取，有单独接口获取，处理并保存到model的该条属性中。 */


/*备注：*/
/**
 * description:
 *   一、Feature<能力集合>
 *    1:是否支持WIFI; 2:是否支持对讲; 3:是否支持云台; 4:是否支持云存储; 5:是否支持P2P
 *   二、PortInfo:<报警端口信息>
 *    1:报警输入端口数; 2:报警输出端口数
 *   三、DiskInfo:<磁盘信息>
 *    1:存储类型(数字1:SD；数字2:硬盘); 2:安装磁盘数(数字0:未安装；数字1:安装);
 *    3:当前的状态(数字0:正常；数字1:故障；数字2:未格式化；数字3:正在格式化)
 *
 *    e.g.  ext_info:{Feature:"1,0,0,1,0" PortInfo:"1,1", DiskInfo:"1,1,0"}
 */
- (void)setValue:(id)value forUndefinedKey:(NSString *)key;

@end

@interface ext_info : NSObject<NSCoding>
@property (nonatomic, copy) NSString* Feature;/**< 能力集 */
@property (nonatomic, copy) NSString* dev_img;/**< 设备图片地址 */
@property (nonatomic, copy) NSString* video_streams;/**< 视频流 */

@property (nonatomic, strong) Feature_cms* feature_cms;/**< cms配置的能力集 */
@property (nonatomic, strong) shareFeature* shareFeature;/**< 分享给其他用户 其他用户能拥有的相关能力集 */

@end

@interface Feature_cms : NSObject<NSCoding> //统一都是 0关，1开
@property (nonatomic, copy) NSString* apm;/**< AP模式 */
@property (nonatomic, copy) NSString* cloud;/**< 云存储 */
@property (nonatomic, copy) NSString* imf;/**< 图像翻转 */
@property (nonatomic, copy) NSString* lm;/**< 局域网模式*/
@property (nonatomic, copy) NSString* mdt;/**< Motion detection technology移动侦测*/
@property (nonatomic, copy) NSString* p2p;/**< p2p */
@property (nonatomic, copy) NSString* ptz;/**< 云台 */
@property (nonatomic, copy) NSString* scm;/**< SmartConfig模式 */
@property (nonatomic, copy) NSString* sm;/**< silentMode在家模式 */
@property (nonatomic, copy) NSString* talk;/**< 对讲 */
@property (nonatomic, copy) NSString* tdccm;/**< 二维码配置WiFi */
@property (nonatomic, copy) NSString* wdy;/**< 宽动态 */
@property (nonatomic, copy) NSString* wifi;/**< WiFi */
@end

@interface shareFeature : NSObject<NSCoding> // 分享给其他用户 其他用户能拥有的相关能力集
@property (nonatomic, copy) NSString* hp;/**< 历史回放 默认不支持*/
@property (nonatomic, copy) NSString* ptz;/**< 云台  默认不支持*/
@property (nonatomic, copy) NSString* rtv;/**< 实时视频  默认支持*/
@property (nonatomic, copy) NSString* talk;/**< 对讲  默认不支持*/
@property (nonatomic, copy) NSString* volice;/**< 声音  默认支持*/

@property (nonatomic, copy) NSString *timeLimit;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, copy) NSString *alarm;
@property (nonatomic, copy) NSString *startTime;


@end



