//
//  LiveDescView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/2/5.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveDescView : UIView
/*直播名称*/
@property(nonatomic,strong) UILabel *liveName_lb;
/*直播观看数*/
@property(nonatomic,strong) UILabel *liveViewCount_lb;
/*直播内容介绍*/
@property(nonatomic,strong) UITextView *liveDesc_tv;
@end
