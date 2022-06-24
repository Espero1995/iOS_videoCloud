//
//  LiveCollectionCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/16.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveCollectionCell : UICollectionViewCell
/*直播图片*/
@property (strong, nonatomic) IBOutlet UIImageView *LiveImg;
/*点赞按钮*/
@property (strong, nonatomic) IBOutlet UIButton *praiseBtn;
/*浏览次数*/
@property (strong, nonatomic) IBOutlet UILabel *viewedCount;
/*直播标题*/
@property (strong, nonatomic) IBOutlet UILabel *LiveTitleLb;
@end
