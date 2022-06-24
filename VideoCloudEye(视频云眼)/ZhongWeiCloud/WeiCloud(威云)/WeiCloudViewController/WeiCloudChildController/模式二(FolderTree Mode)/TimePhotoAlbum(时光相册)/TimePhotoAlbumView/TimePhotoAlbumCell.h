//
//  TimePhotoAlbumCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/10/17.
//  Copyright © 2018 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TimePhotoAlbumCell;

/*代理协议*/
@protocol TimePhotoAlbumCellDelegate <NSObject>
//gif下载
- (void)AlbumPhotoDownload:(TimePhotoAlbumCell *)cell;
//gif分享
- (void)AlbumPhotoShare:(TimePhotoAlbumCell *)cell;
@end

@interface TimePhotoAlbumCell : UITableViewCell
//播放按钮
@property (strong, nonatomic) IBOutlet UIImageView *albunTimePlayImg;
//时间
@property (strong, nonatomic) IBOutlet UILabel *albumTimeLb;
//gif图片
@property (strong, nonatomic) IBOutlet UIImageView *albumImgView;
//下载按钮
@property (strong, nonatomic) IBOutlet UIButton *downloadBtn;
//分享按钮
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;
//等待按钮
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;
/*代理协议*/
@property (nonatomic,weak)id<TimePhotoAlbumCellDelegate>delegate;
@end
