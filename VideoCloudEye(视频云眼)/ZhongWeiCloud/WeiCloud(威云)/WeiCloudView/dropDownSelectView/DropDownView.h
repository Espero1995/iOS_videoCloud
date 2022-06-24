//
//  DropDownView.h
//  ZhongWeiCloud
//
//  Created by Espero on 2018/3/3.
//  Copyright © 2018年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

/*代理协议*/
@protocol DropDownViewDelegate <NSObject>
- (void)DropDownBtn1Click:(NSString *)seletedTitle;
- (void)DropDownBtn2Click:(NSString *)seletedTitle;
- (void)DropDownBtn3Click:(NSString *)seletedTitle;
- (void)DropDownBtn4Click:(NSString *)seletedTitle;
@end

@interface DropDownView : UIView

@property (strong, nonatomic) IBOutlet UIView *innerView;

/*title*/
@property (strong, nonatomic) IBOutlet UILabel *innerTitle;
//1/2/3/4
@property (strong, nonatomic) IBOutlet UIButton *selectBtn1;
@property (strong, nonatomic) IBOutlet UIButton *selectBtn2;
@property (strong, nonatomic) IBOutlet UIButton *selectBtn3;
@property (strong, nonatomic) IBOutlet UIButton *selectBtn4;

@property (nonatomic, weak)UIViewController *parentVC;
+ (instancetype)defaultPopupViewandTitleArr:(NSArray *)titleArr;

/*代理协议*/
@property (nonatomic,weak)id<DropDownViewDelegate>DropDownViewDelegate;
@end
