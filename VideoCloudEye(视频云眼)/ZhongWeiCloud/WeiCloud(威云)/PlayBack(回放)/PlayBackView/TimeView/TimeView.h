//
//  TimeView.h
//  ZhongWeiEyes
//
//  Created by 张策 on 16/12/23.
//  Copyright © 2016年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lab_time;
+(instancetype)viewFromXib;
@end
