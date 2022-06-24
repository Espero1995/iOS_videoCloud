//
//  FileShowView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/10/26.
//  Copyright © 2018 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileModel.h"
@protocol FileShowViewDelegate <NSObject>
- (void)downLoadFile:(FileModel *)model;//下载文件
- (void)shareFile:(FileModel *)model;//分享文件
@end
@interface FileShowView : UIView


@property (nonatomic,strong) FileModel *fileModel;

/*代理方法*/
@property (nonatomic) id<FileShowViewDelegate>delegate;

/**
 返回这个View
 @param frame view的大小
 @return 返回这个View
 */
- (instancetype)initWithframe:(CGRect) frame;
//设置弹出框视图展示
- (void)setFileViewShow;

- (void)setFileModelInfo:(FileModel *)model;

@end

