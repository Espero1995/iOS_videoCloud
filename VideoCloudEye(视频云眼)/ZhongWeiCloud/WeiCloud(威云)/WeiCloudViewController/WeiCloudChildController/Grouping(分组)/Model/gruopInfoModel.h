//
//  gruopInfoModel.h
//  ZhongWeiCloud
//
//  Created by 高凌峰 on 2018/8/31.
//  Copyright © 2018年 苏旋律. All rights reserved.
//


#import <Foundation/Foundation.h>
@class gruopListModel,deviceGroupModel,deviceListModel,ext_infoModel,shareFeatureModel;
@interface gruopInfoModel : NSObject


@property (nonatomic,copy)   NSString *ret;
@property (nonatomic,copy)   NSString *info;
@property (nonatomic,strong) NSArray<gruopListModel *>*body;
- (void)setValue:(id)value forUndefinedKey:(NSString *)key;

@end

@interface gruopListModel : NSObject


@property (nonatomic,strong)  NSArray<deviceGroupModel *> *deviceGroup;
//@property (nonatomic,strong)  NSArray<deviceListModel *> *deviceList;
- (void)setValue:(id)value forUndefinedKey:(NSString *)key;

@end



//@interface deviceGroupModel : NSObject
//
//@property (nonatomic,strong)  NSArray *devcieIds;/**< 设备分组里面的设备id */
//@property (nonatomic,copy)   NSString *ownerId;/**< 分组拥有者的id */
//@property (nonatomic,copy)   NSDictionary *channels;/**< 通道 *///这个给定的json里面没有数据是个字典。
//@property (nonatomic,copy)   NSString *groupName;/**< 分组的名称 */
//@property (nonatomic,copy)   NSString *silentMode;/**< //一键切换在家模式(0/1)(意义同设备) */
//@property (nonatomic,copy)   NSString * createDate;/**< 分组创建的日期 */
//@property (nonatomic,copy)   NSString *groupId;/**< 分组的id */
//@property (nonatomic,copy)   NSString *enableSensibility;/**< //一键关闭/启用移动侦测(0/1)(意义同设备) */
//@property (nonatomic,assign) BOOL top;/**< 是否置顶 */
//@property (nonatomic,strong)  NSArray<deviceListModel *> *deviceList;
//@end

@interface deviceListModel : NSObject


@property (nonatomic,copy)   NSString *grantPlanId;
@property (nonatomic,assign) BOOL is_public;
@property (nonatomic,copy)   NSString *status;
@property (nonatomic,copy)   NSString *owner_id;
@property (nonatomic,copy)   NSString *chan_size;
@property (nonatomic,copy)   NSString *dev_p_code;
@property (nonatomic,copy)   NSString *enableSD;
@property (nonatomic,copy)   NSString *enableOperator;
@property (nonatomic,assign) BOOL enable_sec;
@property (nonatomic,copy)   NSString *enableInfrared;
@property (nonatomic,copy)   NSString *name;
@property (nonatomic,copy)   NSString *version;
@property (nonatomic,copy)   NSString *type;
@property (nonatomic,copy)   NSString *ID;
@property (nonatomic,copy)   NSString *firstOnlineDate;
@property (nonatomic,copy)   NSString *owner_name;
@property(nonatomic,strong)  NSArray *chans;
@property (nonatomic,copy)   NSString *silentMode;
@property (nonatomic,copy)   NSString *autoUpgrade;
@property (nonatomic,copy)   NSString *sharePolice;
@property (nonatomic,copy)   NSString *enableCloud;
@property (nonatomic,copy)   NSString *vsample;
@property (nonatomic,copy)   NSString *device_class;
@property (nonatomic,copy)   NSString *groupId;
@property (nonatomic,copy)   NSString *chan_alias;
@property (nonatomic,copy)   NSString *importDate;
@property (nonatomic,copy)   NSString *enableSensibility;
@property (nonatomic,copy)   NSString *grantInfo;
@property (nonatomic,copy)   NSArray<ext_infoModel *>*ext_info;


@end

@interface ext_infoModel : NSObject


@property (nonatomic,copy)   NSString *Feature;//能力集合
@property (nonatomic,copy)   NSArray<shareFeatureModel *>*shareFeature;


@end

@interface shareFeatureModel : NSObject


@property (nonatomic,copy)   NSString *hp;
@property (nonatomic,copy)   NSString *rtv;
@property (nonatomic,copy)   NSString *timeLimit;
@property (nonatomic,copy)   NSString *endTime;
@property (nonatomic,copy)   NSString *ptz;
@property (nonatomic,copy)   NSString *volice;
@property (nonatomic,copy)   NSString *alarm;
@property (nonatomic,copy)   NSString *startTime;
@property (nonatomic,copy)   NSString *talk;


@end


