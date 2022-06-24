//
//  OneTableViewCell.h
//  封装二级选择列表
//
//  Created by 张策 on 16/10/27.
//  Copyright © 2016年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OneTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lab_title;
@property (weak, nonatomic) IBOutlet UILabel *lab_count;

@end
