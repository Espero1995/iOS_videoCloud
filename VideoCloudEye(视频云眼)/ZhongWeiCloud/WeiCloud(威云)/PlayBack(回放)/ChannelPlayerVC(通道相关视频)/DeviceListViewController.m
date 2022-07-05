//
//  DeviceListViewController.m
//  ZhongWeiCloud
//
//  Created by 王攀登 on 2022/6/30.
//  Copyright © 2022 苏旋律. All rights reserved.
//

#import "DeviceListViewController.h"
#import "ChannelCodeListModel.h"

@interface DeviceListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;


@end

@implementation DeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    [self initData];
    [self setupTitleView];
    [self setupMainUI];
}

- (void)initData {
    
}

- (void)setupTitleView {
    UIButton *leftChangeBtn = [UIButton new];
    [leftChangeBtn setTitle:@"<<" forState:UIControlStateNormal];
    [leftChangeBtn setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    [leftChangeBtn setTitleColor:UIColor.grayColor forState:UIControlStateHighlighted];
    [self.view addSubview:leftChangeBtn];
    UIButton *rightChangeBtn = [UIButton new];
    [rightChangeBtn setTitle:@">>" forState:UIControlStateNormal];
    [rightChangeBtn setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    [rightChangeBtn setTitleColor:UIColor.grayColor forState:UIControlStateHighlighted];
    [self.view addSubview:rightChangeBtn];
    [leftChangeBtn addTarget:self action:@selector(leftChangeAction) forControlEvents:UIControlEventTouchUpInside];
    [rightChangeBtn addTarget:self action:@selector(rightChangeAction) forControlEvents:UIControlEventTouchUpInside];
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor colorWithHexString:@"#282828"];
    titleLabel.text = NSLocalizedString(@"设备列表", nil);
    [self.view addSubview:titleLabel];
    [leftChangeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(25.f);
        make.centerY.equalTo(titleLabel);
        make.size.mas_equalTo(CGSizeMake(30, 20));
    }];
    [rightChangeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-25.f);
        make.centerY.equalTo(titleLabel);
        make.size.equalTo(leftChangeBtn);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0.f);
        make.top.offset(21.f);
    }];
}

- (void)setupMainUI {
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 120.0f;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[DeviceListCell class]
           forCellReuseIdentifier:NSStringFromClass([DeviceListCell class])];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(50.f);
        make.left.right.bottom.offset(0.f);
    }];
}

- (void)leftChangeAction {
    NSInteger currentRow = self.selectIndex.row;
    if (currentRow > 0 && currentRow <self.dataArray.count) {
        currentRow -= 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentRow inSection:0];
        if ([self.tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        }
    }
}

- (void)rightChangeAction {
    NSInteger currentRow = self.selectIndex.row;
    if (currentRow >= 0 && currentRow <self.dataArray.count-1) {
        currentRow += 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentRow inSection:0];
        if ([self.tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        }
    }
}

#pragma mark ----------- TableView Datasource && Deleagte -------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceListCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DeviceListCell class]) forIndexPath:indexPath];
    if (self.dataArray.count > indexPath.row) {
        ChannelCodeListModel *model = self.dataArray[indexPath.row];
        [cell configModel:model];
        [cell updateCellSelectedStatus:self.selectIndex.row == indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 61.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChannelCodeListModel *model = self.dataArray[indexPath.row];
    if (model.chanStatus == 0) {
        [XHToast showCenterWithText:NSLocalizedString(@"该设备不在线，无法进行查看", nil)];
        return;
    }
    self.selectIndex = indexPath;
    [self.tableView reloadData];
    if (self.changeDeviceBlock) {
        self.changeDeviceBlock(model, indexPath);
    }
}

@end




@interface DeviceListCell ()

@property (nonatomic, strong) UIImageView *logoImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *statusBgView;
@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation DeviceListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.contentView addSubview:self.logoImgView];
    [self.contentView addSubview:self.titleLabel];
    [self.logoImgView addSubview:self.statusBgView];
    [self.statusBgView addSubview:self.statusLabel];
    
    [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(25.f);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(65, 43));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.logoImgView.mas_right).offset(8.f);
        make.centerY.equalTo(self.contentView);
        make.right.lessThanOrEqualTo(self.contentView.mas_right).offset(-25);
    }];
    [self.statusBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.statusBgView);
    }];
}

- (void)configModel:(ChannelCodeListModel *)model {
    UIImage *image = [self getSmallImageWithUrl:@"" AtDirectory:getCutImageBaseURLDirectory ImaNameStr:model.deviceId];
    if (image) {
        self.logoImgView.image = image;
    }else{
        self.logoImgView.image = [UIImage imageNamed:@"img2"];
    }
    self.titleLabel.text = model.chanName;
    // 设备在线状态
    self.statusBgView.hidden = (model.chanStatus != 0);
}

// cell选中状态
- (void)updateCellSelectedStatus:(BOOL)selected {
    _titleLabel.textColor = [UIColor colorWithHexString:selected ? @"#2773f2" : @"#282828"];
}

- (UIImageView *)logoImgView {
    if (!_logoImgView) {
        _logoImgView = [UIImageView new];
    }
    return _logoImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#2773f2"];
    }
    return _titleLabel;
}

- (UIView *)statusBgView {
    if (!_statusBgView) {
        _statusBgView = [UIView new];
        _statusBgView.backgroundColor = UIColor.blackColor;
        _statusBgView.alpha = 0.7;
    }
    return _statusBgView;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [UILabel new];
        _statusLabel.font = [UIFont systemFontOfSize:14];
        _statusLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _statusLabel.text = @"不在线";
    }
    return _statusLabel;
}

- (UIImage*)getSmallImageWithUrl:(NSString*)imageUrl AtDirectory:(NSString*)directory ImaNameStr:(NSString *)nameStr {
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取路径
    //1、拼接目录
    NSString *path = [NSHomeDirectory() stringByAppendingString:directory];
    NSString* savePath = [path stringByAppendingString:[NSString stringWithFormat:@"/%@.jpg",nameStr]];
    [fileManager changeCurrentDirectoryPath:savePath];
    UIImage *cutIma =  [[UIImage alloc]initWithContentsOfFile:savePath];

    return cutIma;
}

@end
