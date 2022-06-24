//
//  FolderTreeView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2019/10/14.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol folderTreeView_delegate <NSObject>

//获取树高和文件夹名
- (void)getTreeIndex:(NSInteger)treeIndex andNodeName:(NSString *)nodeName;

//获取叶子节点下的设备列表
- (void)getleafNodeDeviceList;

//首页初始化时的title
- (void)getleafRootTitle:(NSString *)titleStr andisOnlyRoot:(BOOL)isOnlyRoot;

@end


@interface FolderTreeView : UIView

@property (nonatomic, weak) id<folderTreeView_delegate>delegate;/**< 代理 */
/**
 * @brief 当前节点
 */
@property (nonatomic, copy) NSString *currentNodeId;

/**
 * @brief 退回上级页面 即树高减1
 */
- (void)popTableView;

//当前title名字(只用于一个根节点)
@property (nonatomic, copy) NSString *onlyRootTitle;
@end

