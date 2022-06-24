//
//  FolderTreeModel.h
//  ZhongWeiCloud
//
//  Created by Espero on 2019/10/15.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FolderTreeModel : NSObject
/**
 * @brief 节点ID
 */
@property (nonatomic, copy) NSString *nodeId;
/**
 * @brief 节点名
 */
@property (nonatomic, copy) NSString *nodeName;
/**
 * @brief 父节点ID
 */
@property (nonatomic, copy) NSString *parentId;
/**
 * @brief 创建人的ID
 */
@property (nonatomic, copy) NSString *createId;
/**
 * @brief 是否拥有孩子
 */
@property (nonatomic, assign) BOOL hasChildren;
/**
 * @brief 节点描述
 */
@property (nonatomic, copy) NSString *desc;
/**
 * @brief 在线通道数目
 */
@property (nonatomic, assign) NSString *channelOnlineCount;

/**
 * @brief 总通道数目
 */
@property (nonatomic, assign) NSString *channelCount;


@end

