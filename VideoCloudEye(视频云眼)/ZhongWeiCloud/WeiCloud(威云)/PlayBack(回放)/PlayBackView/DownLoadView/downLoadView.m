//
//  downLoadView.m
//  ZhongWeiEyes
//
//  Created by 苏旋律 on 17/5/31.
//  Copyright © 2017年 张策. All rights reserved.
//

#import "downLoadView.h"

static const CGFloat  LabelLeftOffset = 30.0;
static const CGFloat  LabelTopOffset  = 28.0;


@interface downLoadView ()
@property (nonatomic , strong) UILabel * downLoadLb;
@property (nonatomic , strong) UILabel * fileNameLb;
//@property (nonatomic , strong) UILabel * saveURLLb;
@property (nonatomic , strong) UILabel * startTimeLb;
@property (nonatomic , strong) UILabel * endTimeLb;

@property (nonatomic , strong) UIView  * lineV1;
@property (nonatomic , strong) UIView  * lineV2;
@property (nonatomic , strong) UIView  * lineV3;
@property (nonatomic , strong) UIView  * lineV4;
@property (nonatomic , strong) UIView  * lineV5;

//@property (nonatomic , strong) UIButton    * chooseFileURLBtn;
@property (nonatomic , strong) UIButton    * startTimeBtn;
@property (nonatomic , strong) UIButton    * endTimeBtn;

@property (nonatomic , strong) UIButton    * startDownLoadBtn;
@property (nonatomic , strong) UIButton    * closeBtn;


@end

@implementation downLoadView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.downLoadLb];
        [self addSubview:self.fileNameLb];
       // [self addSubview:self.saveURLLb];
        [self addSubview:self.startTimeLb];
        [self addSubview:self.endTimeLb];
        
        [self addSubview:self.lineV1];
        [self addSubview:self.lineV2];
        [self addSubview:self.lineV3];
        [self addSubview:self.lineV4];
        [self addSubview:self.lineV5];
        
        [self addSubview:self.fileNameTF];
       // [self addSubview:self.chooseFileURLBtn];
        [self addSubview:self.startTimeBtn];
        [self addSubview:self.endTimeBtn];
        [self addSubview:self.startTimeShowBtn_date];
        [self addSubview:self.endTimeShowBtn_date];
        
        [self addSubview:self.startDownLoadBtn];
        [self addSubview:self.closeBtn];
        
        [self addSubview:self.endTimeShowBtn_time];
        [self addSubview:self.startTimeShowBtn_time];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


#pragma mark -layoutSubviews
- (void)layoutSubviews
{
    [super layoutSubviews];
    WS(weakSelf);
    
    [_downLoadLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf);
        make.top.mas_equalTo(FitHeight(30));
    }];
    
    [_lineV1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(weakSelf);
        make.top.mas_equalTo(weakSelf).offset(FitHeight(100));
        make.height.mas_equalTo(@1);
    }];
    [_fileNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).offset(FitWidth(LabelLeftOffset));
        make.top.mas_equalTo(weakSelf.lineV1.mas_bottom).offset(FitHeight(LabelTopOffset));
    }];
    [_fileNameTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(- FitWidth(LabelLeftOffset));
        make.top.mas_equalTo(weakSelf.lineV1.mas_bottom).offset(FitHeight(LabelTopOffset));
    }];
    
//    [_lineV2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(weakSelf).offset(FitWidth(LabelLeftOffset));
//        make.right.mas_equalTo(weakSelf);
//        make.top.mas_equalTo(weakSelf.lineV1.mas_bottom).offset(FitHeight(80));
//        make.height.mas_equalTo(@1);
//    }];
//    [_saveURLLb mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(weakSelf).offset(FitWidth(LabelLeftOffset));
//        make.top.mas_equalTo(weakSelf.lineV2.mas_bottom).offset(FitHeight(LabelTopOffset));
//    }];
//    [_chooseFileURLBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(weakSelf).offset(- FitWidth(LabelLeftOffset));
//        make.top.mas_equalTo(weakSelf.lineV2.mas_bottom).offset(FitHeight(15));
//    }];
    
    
    [_lineV3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).offset(FitWidth(30));
        make.right.mas_equalTo(weakSelf);
        make.top.mas_equalTo(weakSelf.lineV1.mas_bottom).offset(FitHeight(80));
        make.height.mas_equalTo(@1);
    }];
    [_startTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).offset(FitWidth(LabelLeftOffset));
        make.top.mas_equalTo(weakSelf.lineV3.mas_bottom).offset(FitHeight(LabelTopOffset));
    }];
    [_startTimeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf).offset( - FitWidth(LabelLeftOffset));
        make.top.mas_equalTo(weakSelf.lineV3.mas_bottom).offset(FitHeight(LabelTopOffset));
        make.height.mas_equalTo(FitHeight(27));
        make.width.mas_equalTo(FitWidth(28));
    }];
    [_startTimeShowBtn_time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.startTimeBtn.mas_left).offset(- FitWidth(22));
        make.top.mas_equalTo(weakSelf.lineV3.mas_bottom).offset(FitHeight(15));
    }];
    [_startTimeShowBtn_date mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.startTimeShowBtn_time.mas_left).offset(- FitWidth(18));
        make.top.mas_equalTo(weakSelf.lineV3.mas_bottom).offset(FitHeight(15));
    }];

    
    
    [_lineV4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).offset(FitWidth(LabelLeftOffset));
        make.right.mas_equalTo(weakSelf);
        make.top.mas_equalTo(weakSelf.lineV3.mas_bottom).offset(FitHeight(80));
        make.height.mas_equalTo(@1);
    }];
    [_endTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf).offset(FitWidth(LabelLeftOffset));
        make.top.mas_equalTo(weakSelf.lineV4.mas_bottom).offset(FitHeight(LabelTopOffset));
    }];
    [_endTimeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf).offset( - FitWidth(LabelLeftOffset));
        make.top.mas_equalTo(weakSelf.lineV4.mas_bottom).offset(FitHeight(LabelTopOffset));
        make.height.mas_equalTo(FitHeight(27));
        make.width.mas_equalTo(FitWidth(28));
    }];
    [_endTimeShowBtn_time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.endTimeBtn.mas_left).offset( - FitWidth(22));
        make.top.mas_equalTo(weakSelf.lineV4.mas_bottom).offset(FitHeight(15));
    }];
    [_endTimeShowBtn_date mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.endTimeShowBtn_time.mas_left).offset( - FitWidth(18));
        make.top.mas_equalTo(weakSelf.lineV4.mas_bottom).offset(FitHeight(15));
    }];
    
    
    [_lineV5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(weakSelf);
        make.top.mas_equalTo(weakSelf.lineV4.mas_bottom).offset(FitHeight(80));
        make.height.mas_equalTo(@1);
    }];
    
    [_startDownLoadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf);
        make.top.mas_equalTo(weakSelf.lineV5.mas_bottom).offset(FitHeight(30));
        make.height.mas_equalTo(FitHeight(60));
        make.width.mas_equalTo(FitWidth(200));
    }];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf).offset( - FitWidth(24));
        make.top.mas_equalTo(weakSelf).offset(FitHeight(30));
        make.size.mas_equalTo(CGSizeMake(FitWidth(37), FitHeight(37)));
    }];
    
}
#pragma mark - target && action
- (void)downLoadViewAllAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(downLoadViewAllAction:)] && self.delegate) {
        [self.delegate downLoadViewAllAction:sender];
    }
}

#pragma mark - getter && setter 
- (UILabel *)downLoadLb
{
    if (_downLoadLb == nil) {
        _downLoadLb = [[UILabel alloc]initWithFrame:CGRectZero];
        _downLoadLb.text = @"下载录像";
        _downLoadLb.textColor = [UIColor colorWithHexString:@"#555555"];
        _downLoadLb.font = [UIFont systemFontOfSize:16];
    }
    return _downLoadLb;
}
- (UILabel *)fileNameLb
{
    if (_fileNameLb == nil) {
        _fileNameLb = [[UILabel alloc]initWithFrame:CGRectZero];
        _fileNameLb.text = @"文件名";
        _fileNameLb.textColor = [UIColor colorWithHexString:@"#282828"];
        _fileNameLb.font = [UIFont systemFontOfSize:13];
    }
    return _fileNameLb;
}
//- (UILabel *)saveURLLb
//{
//    if (_saveURLLb == nil) {
//        _saveURLLb = [[UILabel alloc]initWithFrame:CGRectZero];
//        _saveURLLb.text = @"保存路径";
//        _saveURLLb.textColor = [UIColor colorWithHexString:@"#282828"];
//        _saveURLLb.font = [UIFont systemFontOfSize:13];
//    }
//    return _saveURLLb;
//}
- (UILabel *)startTimeLb
{
    if (_startTimeLb == nil) {
        _startTimeLb = [[UILabel alloc]initWithFrame:CGRectZero];
        _startTimeLb.text = @"开始时间";
        _startTimeLb.textColor = [UIColor colorWithHexString:@"#282828"];
        _startTimeLb.font = [UIFont systemFontOfSize:13];
    }
    return _startTimeLb;
}
- (UILabel *)endTimeLb
{
    if (_endTimeLb == nil) {
        _endTimeLb = [[UILabel alloc]initWithFrame:CGRectZero];
        _endTimeLb.text = @"结束时间";
        _endTimeLb.textColor = [UIColor colorWithHexString:@"#282828"];
        _endTimeLb.font = [UIFont systemFontOfSize:13];
    }
    return _endTimeLb;
}

- (UITextField *)fileNameTF
{
    if (_fileNameTF == nil) {
        _fileNameTF = [[UITextField alloc]initWithFrame:CGRectZero];
        [_fileNameTF setPlaceholder:@"请输入文件名"];
        [_fileNameTF setValue:[UIColor colorWithHexString:@"a8a8a8"] forKeyPath:@"_placeholderLabel.textColor"];
        [_fileNameTF setValue:[UIFont systemFontOfSize:13] forKeyPath:@"_placeholderLabel.font"];
    }
    return _fileNameTF;
}

//- (UIButton *)chooseFileURLBtn
//{
//    if (_chooseFileURLBtn == nil) {
//        _chooseFileURLBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _chooseFileURLBtn.tag = TAG_CHOOSEFILEURLBTN;
//        _chooseFileURLBtn.layer.borderWidth = 1.0f;
//        _chooseFileURLBtn.layer.borderColor = [UIColor colorWithHexString:@"#dddddd"].CGColor;
//        _chooseFileURLBtn.layer.masksToBounds = YES;
//        _chooseFileURLBtn.layer.cornerRadius = 8.0;
//        _chooseFileURLBtn.backgroundColor = [UIColor colorWithHexString:@"#f7f7f7"];
//        [_chooseFileURLBtn setTitle:@"点击选择路径" forState:UIControlStateNormal];
//        [_chooseFileURLBtn setTitleColor:[UIColor colorWithHexString:@"#4186ff"] forState:UIControlStateNormal];
//        _chooseFileURLBtn.titleLabel.font = [UIFont systemFontOfSize:11];
//        [_chooseFileURLBtn addTarget:self action:@selector(downLoadViewAllAction:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _chooseFileURLBtn;
//}

- (UIButton *)startTimeBtn
{
    if (_startTimeBtn == nil) {
        _startTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //_startTimeBtn.tag = TAG_STARTTIMEBTN;
        [_startTimeBtn setImage:[UIImage imageNamed:@"rili"] forState:UIControlStateNormal];
        [_startTimeBtn setImage:[UIImage imageNamed:@"rili"] forState:UIControlStateHighlighted];
       // [_startTimeBtn addTarget:self action:@selector(downLoadViewAllAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startTimeBtn;
}

- (UIButton *)endTimeBtn
{
    if (_endTimeBtn == nil) {
        _endTimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //_endTimeBtn.tag = TAG_ENDTIMEBTN;
        [_endTimeBtn setImage:[UIImage imageNamed:@"rili"] forState:UIControlStateNormal];
        [_endTimeBtn setImage:[UIImage imageNamed:@"rili"] forState:UIControlStateHighlighted];
        //[_endTimeBtn addTarget:self action:@selector(downLoadViewAllAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _endTimeBtn;
}

- (UIButton *)startTimeShowBtn_date
{
    if (_startTimeShowBtn_date == nil) {
        _startTimeShowBtn_date = [UIButton buttonWithType:UIButtonTypeCustom];
        _startTimeShowBtn_date.tag = TAG_STARTIMESHOWBTN_DATE;
        [_startTimeShowBtn_date setTitleColor:[UIColor colorWithHexString:@"a8a8a8"] forState:UIControlStateNormal];
        _startTimeShowBtn_date.titleLabel.font = [UIFont systemFontOfSize:13];
        NSDate *date = [NSDate date]; // 获得时间对象
        NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
        [forMatter setDateFormat:@"yyyy年MM月dd日"];
        NSString *dateStr = [forMatter stringFromDate:date];
        [_startTimeShowBtn_date setTitle:[NSString stringWithFormat:@"%@",dateStr] forState:UIControlStateNormal];
        [_startTimeShowBtn_date addTarget:self action:@selector(downLoadViewAllAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startTimeShowBtn_date;
}
- (UIButton *)endTimeShowBtn_date
{
    if (_endTimeShowBtn_date == nil) {
        _endTimeShowBtn_date = [UIButton buttonWithType:UIButtonTypeCustom];
        _endTimeShowBtn_date.tag = TAG_ENDTIMESHOWBTN_DATE;
        [_endTimeShowBtn_date setTitleColor:[UIColor colorWithHexString:@"a8a8a8"] forState:UIControlStateNormal];
        _endTimeShowBtn_date.titleLabel.font = [UIFont systemFontOfSize:13];
        NSDate *date = [NSDate date]; // 获得时间对象
        NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
        [forMatter setDateFormat:@"yyyy年MM月dd日"];
        NSString *dateStr = [forMatter stringFromDate:date];
        [_endTimeShowBtn_date setTitle:[NSString stringWithFormat:@"%@",dateStr] forState:UIControlStateNormal];
        [_endTimeShowBtn_date addTarget:self action:@selector(downLoadViewAllAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _endTimeShowBtn_date;
}
- (UIButton *)startTimeShowBtn_time
{
    if (_startTimeShowBtn_time == nil) {
        _startTimeShowBtn_time = [UIButton buttonWithType:UIButtonTypeCustom];
        _startTimeShowBtn_time.tag = TAG_STARTIMESHOWBTN_TIME;
        [_startTimeShowBtn_time setTitleColor:[UIColor colorWithHexString:@"a8a8a8"] forState:UIControlStateNormal];
        _startTimeShowBtn_time.titleLabel.font = [UIFont systemFontOfSize:13];
        NSDate *date = [NSDate date]; // 获得时间对象
        NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
        [forMatter setDateFormat:@"HH:mm:ss"];
        NSString *dateStr = [forMatter stringFromDate:date];
        [_startTimeShowBtn_time setTitle:[NSString stringWithFormat:@"%@",dateStr] forState:UIControlStateNormal];
        [_startTimeShowBtn_time addTarget:self action:@selector(downLoadViewAllAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startTimeShowBtn_time;
}
- (UIButton *)endTimeShowBtn_time
{
    if (_endTimeShowBtn_time == nil) {
        _endTimeShowBtn_time = [UIButton buttonWithType:UIButtonTypeCustom];
        _endTimeShowBtn_time.tag = TAG_ENDTIMESHOWBTN_TIME;
        [_endTimeShowBtn_time setTitleColor:[UIColor colorWithHexString:@"a8a8a8"] forState:UIControlStateNormal];
        _endTimeShowBtn_time.titleLabel.font = [UIFont systemFontOfSize:13];
        NSDate *date = [NSDate date]; // 获得时间对象
        NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
        [forMatter setDateFormat:@"HH:mm:ss"];
        NSString *dateStr = [forMatter stringFromDate:date];
        [_endTimeShowBtn_time setTitle:[NSString stringWithFormat:@"%@",dateStr] forState:UIControlStateNormal];
        [_endTimeShowBtn_time addTarget:self action:@selector(downLoadViewAllAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _endTimeShowBtn_time;
}

- (UIButton *)startDownLoadBtn
{
    if (_startDownLoadBtn == nil) {
        _startDownLoadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _startDownLoadBtn.tag = TAG_STARTDOWNLOADBTN;
        _startDownLoadBtn.backgroundColor = [UIColor colorWithHexString:@"#38adff"];
        [_startDownLoadBtn setTitle:@"下载" forState:UIControlStateNormal];
        [_startDownLoadBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        _startDownLoadBtn.layer.masksToBounds = YES;
        _startDownLoadBtn.layer.cornerRadius = FitHeight(30);
        [_startDownLoadBtn addTarget:self action:@selector(downLoadViewAllAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startDownLoadBtn;
}

- (UIButton *)closeBtn
{
    if (_closeBtn == nil) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.tag = TAG_CLOSEBTN;
        [_closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(downLoadViewAllAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UIView *)lineV1
{
    if (_lineV1 == nil) {
        _lineV1 = [[UIView alloc]initWithFrame:CGRectZero];
        _lineV1.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    }
    return _lineV1;
}
- (UIView *)lineV2
{
    if (_lineV2 == nil) {
        _lineV2 = [[UIView alloc]initWithFrame:CGRectZero];
        _lineV2.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    }
    return _lineV2;
}
- (UIView *)lineV3
{
    if (_lineV3 == nil) {
        _lineV3 = [[UIView alloc]initWithFrame:CGRectZero];
        _lineV3.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    }
    return _lineV3;
}
- (UIView *)lineV4
{
    if (_lineV4 == nil) {
        _lineV4 = [[UIView alloc]initWithFrame:CGRectZero];
        _lineV4.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    }
    return _lineV4;
}
- (UIView *)lineV5
{
    if (_lineV5 == nil) {
        _lineV5 = [[UIView alloc]initWithFrame:CGRectZero];
        _lineV5.backgroundColor = [UIColor colorWithHexString:@"#f1f1f1"];
    }
    return _lineV5;
}
@end
