//
//  SpeedAndflowView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/1/24.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpeedAndflowView : UIView
/*流量显示*/
@property (nonatomic,strong)UIImageView * showSpeedAndflowLabelBgview;
/*网速*/
@property (nonatomic,strong)UILabel * speedLabel;
/*流量*/
@property (nonatomic,strong)UILabel * flowLabel;
@end
