//
//  MoveCollectionView.h
//  长按移动collection
//
//  Created by 张策 on 16/10/25.
//  Copyright © 2016年 张策. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoveViewCell_c.h"
#import "ZCVideoPlayView.h"
@class MoveCollectionView;
@protocol MoveCollectionCellViewDelegete <UICollectionViewDelegate>

@required
/**
 *  当数据源更新的到时候调用，必须实现，需将新的数据源设置为当前tableView的数据源(例如 :_data = newDataArray)
 *  @param newDataArray   更新后的数据源
 */
- (void)dragCellCollectionView:(MoveCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray;
@optional
/**
 *  某些indexPaths是不需要交换和晃动的，常见的比如添加按钮等，传入这些indexPaths数组排出交换和抖动操作
 *  @param collectionView   需要排除的indexPath数组，该数组中的indexPath无法长按抖动和交换
 */
- (NSArray<NSIndexPath *> *)excludeIndexPathsWhenMoveDragCellCollectionView:(MoveCollectionView *)collectionView;

/**
 *  某个cell将要开始移动的时候调用
 *  @param indexPath      该cell当前的indexPath
 */
- (void)dragCellCollectionView:(MoveCollectionView *)collectionView cellWillBeginMoveAtIndexPath:(NSIndexPath *)indexPath;
/**
 *  某个cell正在移动的时候
 */
- (void)dragCellCollectionViewCellisMoving:(MoveCollectionView *)collectionView;
/**
 *  cell移动完毕，并成功移动到新位置的时候调用
 */
- (void)dragCellCollectionViewCellEndMoving:(MoveCollectionView*)collectionView;
/**
 *  成功交换了位置的时候调用
 *  @param fromIndexPath    交换cell的起始位置
 *  @param toIndexPath      交换cell的新位置
 */
- (void)dragCellCollectionView:(MoveCollectionView *)collectionView moveCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end
@protocol MoveCollectionCellViewDataSoure<UICollectionViewDataSource>

@required
/**
 *  返回整个CollectionView的数据，必须实现，需根据数据进行移动后的数据重排
 */
- (NSArray *)dataSourceArrayOfCollectionView:(MoveCollectionView *)collectionView;

@end
@protocol MoveCollectionViewDelegate <NSObject>
//单机判断是否在播放
- (void)cellSelectClick:(BOOL)isPlay;

//双击全屏播放
- (void)cellFullPlay:(VideoModel *)videoModel;
@end


@interface MoveCollectionView : UICollectionView

/**
 *  数据源
 */
@property (nonatomic,strong)NSMutableArray *dataArr;
/**
 *  cell个数
 */

@property (nonatomic,assign)NSInteger cellCount;
/**
 *  cellSize
 */
@property (nonatomic,assign)CGSize cellSize;
@property (nonatomic,assign)NSInteger selectTag;

//选中的数据源
@property (nonatomic,strong)NSMutableArray *selectDataArr;
//视频管理者数组
@property (nonatomic,strong)NSMutableArray *videoManagesArr;
//音频管理者数组
@property (nonatomic,strong)NSMutableArray *audioManagesArr;
//历史已存
@property (nonatomic,strong)NSMutableDictionary *historyDic;
//历史开关
@property (nonatomic,assign)BOOL isHistory;

@property (nonatomic,strong)NSIndexPath *selectIndexPath;//记录当前点击的cell

@property (nonatomic, assign)MoveCellState currentState;
@property (nonatomic, assign)MoveCellState lastState;

@property (nonatomic,weak)id<MoveCollectionViewDelegate>moveDelegate;

@property (nonatomic, assign) id<MoveCollectionCellViewDelegete>delegate;
@property (nonatomic, assign) id<MoveCollectionCellViewDataSoure> dataSource;

/**长按多少秒触发拖动手势，默认1秒，如果设置为0，表示手指按下去立刻就触发拖动*/
@property (nonatomic, assign) NSTimeInterval minimumPressDuration;
/**是否开启拖动到边缘滚动CollectionView的功能，默认YES*/
@property (nonatomic, assign) BOOL edgeScrollEable;
/**是否开启拖动的时候所有cell抖动的效果，默认YES*/
@property (nonatomic, assign) BOOL shakeWhenMoveing;
/**抖动的等级(1.0f~10.0f)，默认4*/
@property (nonatomic, assign) CGFloat shakeLevel;
/**是否正在编辑模式，调用xwp_enterEditingModel和xw_stopEditingModel会修改该方法的值*/
@property (nonatomic, assign, readonly, getter=isEditing) BOOL isEdited;
@property (nonatomic, strong) NSIndexPath *originalIndexPath;
/**进入编辑模式，如果开启抖动会自动持续抖动，且不用长按就能出发拖动*/
- (void)xw_enterEditingModel;

/**退出编辑模式*/
- (void)xw_stopEditingModel;
@end
