//
//  downLoadView.h
//  ZhongWeiEyes
//
//  Created by 苏旋律 on 17/5/31.
//  Copyright © 2017年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>


//#define TAG_CHOOSEFILEURLBTN  0x500//
//#define TAG_STARTTIMEBTN      0x501
//#define TAG_ENDTIMEBTN        0x502
#define TAG_STARTDOWNLOADBTN  0x503
#define TAG_CLOSEBTN          0x504

#define TAG_STARTIMESHOWBTN_DATE   0x505
#define TAG_ENDTIMESHOWBTN_DATE    0x506
#define TAG_STARTIMESHOWBTN_TIME   0x507
#define TAG_ENDTIMESHOWBTN_TIME    0x508


@protocol downLoadViewDelegate <NSObject>

- (void)downLoadViewAllAction:(UIButton *)sender;

@end

@interface downLoadView : UIView
@property (nonatomic , strong) id<downLoadViewDelegate>delegate;

@property (nonatomic , strong) UIButton    * startTimeShowBtn_date;
@property (nonatomic , strong) UIButton    * endTimeShowBtn_date;
@property (nonatomic , strong) UIButton    * startTimeShowBtn_time;
@property (nonatomic , strong) UIButton    * endTimeShowBtn_time;
@property (nonatomic , strong) UITextField * fileNameTF;

- (instancetype)initWithFrame:(CGRect)frame;
@end
