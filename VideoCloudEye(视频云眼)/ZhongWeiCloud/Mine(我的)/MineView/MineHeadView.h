//
//  MineHeadView.h
//  ZhongWeiCloud
//
//  Created by 张策 on 17/2/8.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MineHeadViewDelegate <NSObject>

- (void)mineHeadViewLabnameClick;

@end

@interface MineHeadView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *ima_photo;
@property (weak, nonatomic) IBOutlet UILabel *lab_name;
@property (nonatomic,weak)id<MineHeadViewDelegate>delegate;
+(instancetype)viewFromXib;
@end
