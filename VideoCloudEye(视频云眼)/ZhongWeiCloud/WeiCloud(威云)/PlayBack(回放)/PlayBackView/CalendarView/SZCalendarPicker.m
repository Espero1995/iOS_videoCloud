//
//  SZCalendarPicker.m
//  SZCalendarPicker
//
//  Created by Stephen Zhuang on 14/12/1.
//  Copyright (c) 2014年 Stephen Zhuang. All rights reserved.
//

#import "SZCalendarPicker.h"
#import "SZCalendarCell.h"
#import "UIColor+ZXLazy.h"
#import "ZCTitleView.h"

NSString *const SZCalendarCellIdentifier = @"cell";

@interface SZCalendarPicker ()
@property (nonatomic , weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic , weak) IBOutlet UILabel *monthLabel;
@property (nonatomic , weak) IBOutlet UIButton *previousButton;
@property (nonatomic , weak) IBOutlet UIButton *nextButton;
@property (nonatomic , strong) NSArray *weekDayArray;
@property (nonatomic , strong) UIView *mask;
@property (nonatomic,strong) ZCTitleView *titleView1;
@property (nonatomic,strong) NSMutableArray *videoRecordArr;
@end

@implementation SZCalendarPicker

- (void)drawRect:(CGRect)rect {
    //截图
    [self addTap];
    [self addSwipe];
    [self show];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_collectionView registerClass:[SZCalendarCell class] forCellWithReuseIdentifier:SZCalendarCellIdentifier];
    _weekDayArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
}


- (void)customInterface
{
    
    CGFloat itemWidth = _collectionView.frame.size.width/7;
    CGFloat itemHeight = _collectionView.frame.size.height/7-3;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [_collectionView setCollectionViewLayout:layout animated:YES];
}
- (void)setIsDeviceVideo:(BOOL)isDeviceVideo
{
    //设备录像没有掩码
    _isDeviceVideo = isDeviceVideo;
}

- (void)setDev_ID:(NSString *)dev_ID
{
    if (self.isDeviceVideo == YES) {//设备录像没有掩码
    }else{
        _dev_ID = dev_ID;
        NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
        NSString *devID = self.dev_ID ? self.dev_ID : @"";
        NSLog(@"选择器的ID:%@",self.dev_ID);
        [postDic setObject:devID forKey:@"dev_id"];
        [postDic setObject:[NSNumber numberWithBool:self.isDeviceVideo] forKey:@"rec_type"];
        //先确认保证通道model是否有
        if ([MultiChannelDefaults getChannelModel]) {
            MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
            [postDic setObject:model.chanCode forKey:@"chan_code"];
        }
        
        [postDic setObject:[self getDateYearMonth] forKey:@"start_time"];
        [[HDNetworking sharedHDNetworking] POST:@"v1/media/record/month/list" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
            NSLog(@"日期查询的结果：%@",responseObject);
            
            if (![responseObject[@"body"] isEqual:[NSNull null]])
            {
                //过滤<null>
                NSString *newStr = responseObject[@"body"][@"oneMonth_recs"];
                for(int i =0; i < [newStr length]; i++){
                    [self.videoRecordArr addObject:[newStr substringWithRange:NSMakeRange(i,1)]];
                }
             }
            [_collectionView reloadData];
        } failure:^(NSError * _Nonnull error) {
            NSLog(@"首次查询失败了");
        }];
    }
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    [_monthLabel setText:[NSString stringWithFormat:@"%ld-%2ld",(long)[self year:date],(long)[self month:date]]];
}

#pragma mark - date

- (NSInteger)day:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components day];
}


- (NSInteger)month:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components month];
}

- (NSInteger)year:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components year];
}


- (NSInteger)firstWeekdayInThisMonth:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar setFirstWeekday:1];//1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [calendar dateFromComponents:comp];
    
    NSUInteger firstWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    return firstWeekday - 1;
}

- (NSInteger)totaldaysInThisMonth:(NSDate *)date{
    NSRange totaldaysInMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return totaldaysInMonth.length;
}

- (NSInteger)totaldaysInMonth:(NSDate *)date{
    NSRange daysInLastMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return daysInLastMonth.length;
}

- (NSDate *)lastMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

- (NSDate*)nextMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = +1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

#pragma -mark collectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return _weekDayArray.count;
    } else {
        return 42;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SZCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SZCalendarCellIdentifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        [cell.dateLabel setText:_weekDayArray[indexPath.row]];
        [cell.dateLabel setTextColor:[UIColor blackColor]];
        cell.circleView.hidden = YES;
    } else {
        NSInteger daysInThisMonth = [self totaldaysInMonth:_date];
        NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
        NSInteger day = 0;
        NSInteger i = indexPath.row;
        
        if (i < firstWeekday) {
            [cell.dateLabel setText:@""];
            cell.circleView.hidden = YES;
        }else if (i > firstWeekday + daysInThisMonth - 1){
            [cell.dateLabel setText:@""];
            cell.circleView.hidden = YES;
        }else{
            day = i - firstWeekday + 1;
            [cell.dateLabel setText:[NSString stringWithFormat:@"%li",(long)day]];
            [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#6f6f6f"]];
            if (self.videoRecordArr.count != 0) {
                if ([self.videoRecordArr[day-1] isEqualToString:@"1"]) {
                    cell.circleView.hidden = NO;
                }else{
                    cell.circleView.hidden = YES;
                }
            }else{
                cell.circleView.hidden = YES;
            }
            
            //this month
            if ([_today isEqualToDate:_date]) {
                if (day == [self day:_date]) {
                    [cell.dateLabel setTextColor:RGB(255, 74, 51)];//[UIColor redColor]
                    if (self.videoRecordArr.count != 0) {
                        if ([self.videoRecordArr[day-1] isEqualToString:@"1"]) {
                            cell.circleView.hidden = NO;
                        }else{
                            cell.circleView.hidden = YES;
                        }
                    }else{
                        cell.circleView.hidden = YES;
                    }
                    
                } else if (day > [self day:_date]) {
                    [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#b3b3b3"]];
                    cell.circleView.hidden = YES;
                }
            } else if ([_today compare:_date] == NSOrderedAscending) {
                [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#b3b3b3"]];
                cell.circleView.hidden = YES;
            }
        }
    }
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        NSInteger daysInThisMonth = [self totaldaysInMonth:_date];
        NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
        
        NSInteger day = 0;
        NSInteger i = indexPath.row;
        
        if (i >= firstWeekday && i <= firstWeekday + daysInThisMonth - 1) {
            day = i - firstWeekday + 1;
            
            //this month
            if ([_today isEqualToDate:_date]) {
                if (day <= [self day:_date]) {
                    return YES;
                }
            } else if ([_today compare:_date] == NSOrderedDescending) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.date];
    NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
    
    NSInteger day = 0;
    NSInteger i = indexPath.row;
    day = i - firstWeekday + 1;
    if (self.calendarBlock) {
        self.calendarBlock(day, [comp month], [comp year]);
    }
    
    [self hide];
}

//将NSDate转成想要的格式，其格式：YYYYMM
- (NSString *)getYearandMonthStr:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY"];
    NSInteger currentYear=[[formatter stringFromDate:date] integerValue];
    [formatter setDateFormat:@"MM"];
    NSInteger currentMonth=[[formatter stringFromDate:date]integerValue];
    return [NSString stringWithFormat:@"%ld%02ld",currentYear,currentMonth];
}
//获取当前的年月，其格式：YYYYMM
- (NSString *)getDateYearMonth {
    NSDate *newDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:newDate];
    NSInteger year = [dateComponent year];
    NSInteger month = [dateComponent month];
    return [NSString stringWithFormat:@"%ld%02ld",(long)year,(long)month];
}

- (IBAction)previouseAction:(UIButton *)sender
{
    if (self.isDeviceVideo == YES) {//设备录像没有掩码
        [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlDown animations:^(void) {
            self.date = [self lastMonth:self.date];
        } completion:nil];
        [_collectionView reloadData];
    }else{
        //判断翻页的时期是否已经大于当前日期，如果是则不需要请求，否则需由请求。
        NSString *currentMonthStr = [self getDateYearMonth];
        NSString *nextMonthStr = [self getYearandMonthStr:[self lastMonth:self.date]];
//         NSLog(@"当前日期是：%@；下个月的日期是：%@",currentMonthStr,nextMonthStr);
        if ([currentMonthStr intValue] < [nextMonthStr intValue]) {//不需要查询了
            [self.videoRecordArr removeAllObjects];
            [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlDown animations:^(void) {
                self.date = [self lastMonth:self.date];
            } completion:nil];
            [_collectionView reloadData];
        }else{
            [Toast showLoading:self Tips:@""];
            [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlDown animations:^(void) {
                self.date = [self lastMonth:self.date];
            } completion:nil];
            NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
            [postDic setObject:self.dev_ID forKey:@"dev_id"];
            [postDic setObject:[NSNumber numberWithBool:self.isDeviceVideo] forKey:@"rec_type"];
            [postDic setObject:[self getYearandMonthStr:self.date] forKey:@"start_time"];//[self lastMonth:self.date]
            //先确认保证通道model是否有
            if ([MultiChannelDefaults getChannelModel]) {
                MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
                [postDic setObject:model.chanCode forKey:@"chan_code"];
            }
            NSLog(@"postDic:%@",postDic);
            [[HDNetworking sharedHDNetworking] POST:@"v1/media/record/month/list" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
                NSLog(@"responseObject:%@",responseObject);
                int ret = [responseObject[@"ret"]intValue];
                if (ret == 0) {
                    NSString *newStr = responseObject[@"body"][@"oneMonth_recs"];
                    [self.videoRecordArr removeAllObjects];
                    for(int i =0; i < [newStr length]; i++){
                        [self.videoRecordArr addObject:[newStr substringWithRange:NSMakeRange(i,1)]];
                    }
                    
                    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
                    dispatch_after(time, dispatch_get_main_queue(), ^(void){
                        [Toast dissmiss];
                        [_collectionView reloadData];
                    });
                }else{
                    //失败了就清空日期列表
                    [self.videoRecordArr removeAllObjects];
                    [Toast dissmiss];
                    [_collectionView reloadData];
                }
                
            } failure:^(NSError * _Nonnull error) {
                [Toast dissmiss];
                [self.videoRecordArr removeAllObjects];
                [_collectionView reloadData];
            }];
        }
    }
}

- (IBAction)nexAction:(UIButton *)sender
{
    if (self.isDeviceVideo == YES) {
        [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlUp animations:^(void) {
            self.date = [self nextMonth:self.date];
        } completion:nil];
        [_collectionView reloadData];
    }else{
        //判断翻页的时期是否已经大于当前日期，如果是则不需要请求，否则需由请求。
        NSString *currentMonthStr = [self getDateYearMonth];
        NSString *nextMonthStr = [self getYearandMonthStr:[self nextMonth:self.date]];
//        NSLog(@"当前日期是：%@；下个月的日期是：%@",currentMonthStr,nextMonthStr);
        if ([currentMonthStr intValue] < [nextMonthStr intValue]) {//不需要查询了
            [self.videoRecordArr removeAllObjects];
            [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlUp animations:^(void) {
                self.date = [self nextMonth:self.date];
            } completion:nil];
            [_collectionView reloadData];
        }else{
            [Toast showLoading:self Tips:@""];
            [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlUp animations:^(void) {
                self.date = [self nextMonth:self.date];
            } completion:nil];
            NSMutableDictionary *postDic = [NSMutableDictionary dictionaryWithCapacity:0];
            [postDic setObject:self.dev_ID forKey:@"dev_id"];
            [postDic setObject:[NSNumber numberWithBool:self.isDeviceVideo] forKey:@"rec_type"];
            [postDic setObject:[self getYearandMonthStr:self.date] forKey:@"start_time"];//[self nextMonth:self.date]
            //先确认保证通道model是否有
            if ([MultiChannelDefaults getChannelModel]) {
                MultiChannelModel *model = [MultiChannelDefaults getChannelModel];
                [postDic setObject:model.chanCode forKey:@"chan_code"];
            }
            
            [[HDNetworking sharedHDNetworking] POST:@"v1/media/record/month/list" parameters:postDic IsToken:YES success:^(id  _Nonnull responseObject) {
                NSLog(@"responseObject:%@",responseObject);
                int ret = [responseObject[@"ret"]intValue];
                if (ret == 0) {
                    NSString *newStr = responseObject[@"body"][@"oneMonth_recs"];
                    [self.videoRecordArr removeAllObjects];
                    for(int i =0; i < [newStr length]; i++){
                        [self.videoRecordArr addObject:[newStr substringWithRange:NSMakeRange(i,1)]];
                    }
                    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
                    dispatch_after(time, dispatch_get_main_queue(), ^(void){
                        [Toast dissmiss];
                        [_collectionView reloadData];
                    });
                }else{
                    //失败了就清空日期列表
                    [self.videoRecordArr removeAllObjects];
                    [Toast dissmiss];
                    [_collectionView reloadData];
                }
                
            } failure:^(NSError * _Nonnull error) {
                [Toast dissmiss];
                [self.videoRecordArr removeAllObjects];
                [_collectionView reloadData];
            }];
        }
       
    }

}



//点击x
- (IBAction)btnClick:(id)sender {
    [self hide];
}

+ (instancetype)showOnView:(UIView *)view
{
    SZCalendarPicker *calendarPicker = [[[NSBundle mainBundle] loadNibNamed:@"SZCalendarPicker" owner:self options:nil] firstObject];
    calendarPicker.mask = [[UIView alloc] initWithFrame:view.bounds];
    calendarPicker.mask.backgroundColor = [UIColor blackColor];
    calendarPicker.mask.alpha = 0.3;
    [view addSubview:calendarPicker.mask];
    [view addSubview:calendarPicker];
    return calendarPicker;
}

- (void)show
{
    self.transform = CGAffineTransformTranslate(self.transform, 0,  self.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.titleView1.transform = CGAffineTransformIdentity;
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL isFinished) {
        [self customInterface];
    }];
}

- (void)hide
{
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.transform = CGAffineTransformTranslate(self.transform, 0,  self.frame.size.height);
        self.mask.alpha = 0;
    } completion:^(BOOL isFinished) {
        [self.mask removeFromSuperview];
        [self removeFromSuperview];
    }];
}


- (void)addSwipe
{
    UISwipeGestureRecognizer *swipLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nexAction:)];
    swipLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipLeft];
    
    UISwipeGestureRecognizer *swipRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previouseAction:)];
    swipRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipRight];
    
    UISwipeGestureRecognizer *swipUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nexAction:)];
    swipUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:swipUp];
    
    UISwipeGestureRecognizer *swipDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previouseAction:)];
    swipDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:swipDown];
}

- (void)addTap
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self.mask addGestureRecognizer:tap];
}

#pragma mark - getter && setter
- (NSMutableArray *)videoRecordArr
{
    if (!_videoRecordArr) {
        _videoRecordArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _videoRecordArr;
}


@end
