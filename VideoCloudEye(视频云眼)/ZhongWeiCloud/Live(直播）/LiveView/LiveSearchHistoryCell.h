//
//  LiveSearchHistoryCell.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/17.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveSearchHistoryCell : UICollectionViewCell
/*搜索内容前面的图标*/
@property (strong, nonatomic) IBOutlet UIImageView *searchIcon_img;
/*搜索内容*/
@property (strong, nonatomic) IBOutlet UILabel *searchContent_lb;

@end
