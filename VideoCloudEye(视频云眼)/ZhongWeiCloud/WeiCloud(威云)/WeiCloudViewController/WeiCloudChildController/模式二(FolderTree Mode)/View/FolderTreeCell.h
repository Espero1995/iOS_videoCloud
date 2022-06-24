//
//  FolderTreeCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2019/10/15.
//  Copyright © 2019 苏旋律. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FolderTreeCell : UITableViewCell
/**
 * @brief 文件名
 */
@property (nonatomic, strong) UILabel *nodeNameLb;

/**
 * @brief 通道在线率
 */
@property (nonatomic, strong) UILabel *channelLb;
@end
