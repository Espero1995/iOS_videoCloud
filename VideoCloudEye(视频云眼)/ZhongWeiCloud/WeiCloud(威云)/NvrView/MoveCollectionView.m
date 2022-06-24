//
//  MoveCollectionView.m
//  长按移动collection
//
//  Created by 张策 on 16/10/25.
//  Copyright © 2016年 张策. All rights reserved.
//

#import "MoveCollectionView.h"

#import "MoveViewCell_c.h"
#import "VideoModel.h"
#import "ZCVideoManager.h"
#import "XHToast.h"
#import <AudioToolbox/AudioToolbox.h>

#define angelToRandian(x)  ((x)/180.0*M_PI)

typedef NS_ENUM(NSUInteger, XWDragCellCollectionViewScrollDirection) {
    XWDragCellCollectionViewScrollDirectionNone = 0,
    XWDragCellCollectionViewScrollDirectionLeft,
    XWDragCellCollectionViewScrollDirectionRight,
    XWDragCellCollectionViewScrollDirectionUp,
    XWDragCellCollectionViewScrollDirectionDown
};


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define CELL @"MoveViewCell"


@interface MoveCollectionView ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIGestureRecognizerDelegate
>

@property (nonatomic, weak) UICollectionViewCell *orignalCell;
@property (nonatomic, assign) CGPoint orignalCenter;
@property (nonatomic, strong) NSIndexPath *moveIndexPath;
@property (nonatomic, weak) UIView *tempMoveCell;
@property (nonatomic, weak) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) CADisplayLink *edgeTimer;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) XWDragCellCollectionViewScrollDirection scrollDirection;
@property (nonatomic, assign) CGFloat oldMinimumPressDuration;
@property (nonatomic, assign, getter=isObservering) BOOL observering;
@property (nonatomic) BOOL isPanning;
@property (nonatomic,strong)NSMutableDictionary *tagDic;

@property (nonatomic,assign) BOOL bHashengping;//是否横屏状态过来

//已选管理者字典
@property (nonatomic,strong)NSMutableDictionary *manageDic;
@property (nonatomic,strong)NSMutableArray *manageArr;

@property (nonatomic, assign)CGRect oldRect;//只记录没有全屏/横屏状态下的变化之前的frame。
@property (nonatomic, assign)BOOL   bIsBig;

@property (nonatomic, assign)CGRect noDoubleTohengpingOldRect;

@property (nonatomic,assign)BOOL onHengPingToBig;

@property (nonatomic, assign)int tempOrignalCellTag;
@property (nonatomic, assign)int tempMovedToCellTag;


@end

@implementation MoveCollectionView
@dynamic delegate;
@dynamic dataSource;
- (void)dealloc{
    [self xwp_removeContentOffsetObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self xwp_initializeProperty];
        //通道模式下不需要分屏
        if (!isChannelMode) {
            [self xwp_addGesture];
        }
        //添加监听
        [self xwp_addContentOffsetObserver];
        self.bIsBig = NO;
        self.currentState = MoveCellStateFourScreen;
        self.lastState = MoveCellStateFourScreen;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self xwp_initializeProperty];
        //通道模式下不需要分屏
        if (!isChannelMode) {
            [self xwp_addGesture];
        }
        [self xwp_addContentOffsetObserver];//添加监听
    }
    return self;
}

- (void)xwp_initializeProperty{
    _minimumPressDuration = 1;
    _edgeScrollEable = YES;
    _shakeWhenMoveing = YES;
    _shakeLevel = 4.0f;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(beginSplitScreen) name:SPLITSCREENNOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(HasHengPingToChangeSomeValue:) name:HASHENGPING object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deletePlayCell:) name:DELETEPLAYCELL object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(directHengPing:) name:DIRECTHENGPING object:nil];
}

#pragma mark - longPressGesture methods

/**
 *  添加一个自定义的滑动手势
 */
- (void)xwp_addGesture{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(xwp_longPressed:)];
    _longPressGesture = longPress;
    longPress.delegate = self;
    longPress.minimumPressDuration = _minimumPressDuration;
    [self addGestureRecognizer:longPress];
    
//    UIPanGestureRecognizer *panPress = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(xwp_panPress:)];
//    [self addGestureRecognizer:panPress];

    //双击手势
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
    [self addGestureRecognizer:doubleTapGestureRecognizer];
    
   // [doubleTapGestureRecognizer requireGestureRecognizerToFail:panPress];
    [longPress requireGestureRecognizerToFail:doubleTapGestureRecognizer];
}

/**
 监听，是否是手势触发还是collective触发的点击cell操作
 */

//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    NSLog(@" 输出点击的view的类名:%@==手势类名:%@", NSStringFromClass([touch.view class]),NSStringFromClass([touch.gestureRecognizers class]));
//    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIView"]||[NSStringFromClass([touch.view class])isEqualToString:@"ZCVideoPlayView"]) {//如果当前是Collection
//        //做自己想做的事
////        if ([NSStringFromClass([touch.gestureRecognizers class]) isEqualToString:@"__NSArrayI"]) {
////            return YES;
////        }
//        return NO;
//    }
//    return YES;
//}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


/**
 *  监听手势的改变
 */
- (void)xwp_longPressed:(UILongPressGestureRecognizer *)longPressGesture{
    
    if (self.currentState == MoveCellStateOneScreen || self.currentState == MoveCellStateOneScreen_HengPing) {
        NSLog(@"现在是竖屏【大屏】或者横屏【大屏】，禁止移动");
    }
    else
    {
        if (longPressGesture.state == UIGestureRecognizerStateBegan) {
            [self xwp_gestureBegan:longPressGesture];
        }
        if (longPressGesture.state == UIGestureRecognizerStateChanged) {
            [self xwp_gestureChange:longPressGesture];
        }
        if (longPressGesture.state == UIGestureRecognizerStateCancelled ||
            longPressGesture.state == UIGestureRecognizerStateEnded){
            [self xwp_gestureEndOrCancle:longPressGesture];
        }
    }
}
//- (void)xwp_panPress:(UIPanGestureRecognizer *)panPress
//{
//    if (panPress.state == UIGestureRecognizerStateBegan) {
//        [self xwp_gestureBegan:panPress];
//    }
//    if (panPress.state == UIGestureRecognizerStateChanged) {
//        [self xwp_gestureChange:panPress];
//    }
//    if (panPress.state == UIGestureRecognizerStateCancelled ||
//        panPress.state == UIGestureRecognizerStateEnded){
//        [self xwp_gestureEndOrCancle:panPress];
//    }
//}

/**
 *  手势开始
 */
- (void)xwp_gestureBegan:(UILongPressGestureRecognizer *)longPressGesture{
    //获取手指所在的cell
    _originalIndexPath = [self indexPathForItemAtPoint:[longPressGesture locationOfTouch:0 inView:longPressGesture.view]];
    [self addBordercolor:_originalIndexPath];
   // self.selectIndexPath = _originalIndexPath;
   // [[NSNotificationCenter defaultCenter]postNotificationName:CHANGGESELECTEDVALUE object:nil userInfo:@{@"selectIndexPath":self.selectIndexPath}];
    NSLog(@"长按手势开始，点击的cell的index==self.selectIndexPath：%@ ==== ==",self.selectIndexPath);
    if ([self xwp_indexPathIsExcluded:_originalIndexPath]) {
        return;
    }
    _isPanning = YES;
    MoveViewCell_c *cell = (MoveViewCell_c *)[self cellForItemAtIndexPath:_originalIndexPath];
    
    UIImage *snap;
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, 1.0f, 0);
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIView *tempMoveCell = [UIView new];
     
    tempMoveCell.layer.contents = (__bridge id)snap.CGImage;
    
    cell.hidden = YES;
    //记录cell，不能通过_originalIndexPath,在重用之后原indexpath所对应的cell可能不会是这个cell了
    _orignalCell = cell;
    //记录ceter，同理不能通过_originalIndexPath来获取cell
    _orignalCenter = cell.center;
    
    _tempMoveCell = tempMoveCell;
    
    _tempMoveCell.frame = cell.frame;
    [self addSubview:_tempMoveCell];
    //开启边缘滚动定时器
    [self xwp_setEdgeTimer];
    //开启抖动
    if (!_isEdited) {
       // [self xwp_shakeAllCell];
    }
    _lastPoint = [longPressGesture locationOfTouch:0 inView:longPressGesture.view];
    //通知代理
    if ([self.delegate respondsToSelector:@selector(dragCellCollectionView:cellWillBeginMoveAtIndexPath:)]) {
        [self.delegate dragCellCollectionView:self cellWillBeginMoveAtIndexPath:_originalIndexPath];
    }
}
/**
 *  手势拖动
 */
- (void)xwp_gestureChange:(UILongPressGestureRecognizer *)longPressGesture{
    //通知代理
    if ([self.delegate respondsToSelector:@selector(dragCellCollectionViewCellisMoving:)]) {
        [self.delegate dragCellCollectionViewCellisMoving:self];
    }
    CGFloat tranX = [longPressGesture locationOfTouch:0 inView:longPressGesture.view].x - _lastPoint.x;
    CGFloat tranY = [longPressGesture locationOfTouch:0 inView:longPressGesture.view].y - _lastPoint.y;
    _tempMoveCell.center = CGPointApplyAffineTransform(_tempMoveCell.center, CGAffineTransformMakeTranslation(tranX, tranY));
    _lastPoint = [longPressGesture locationOfTouch:0 inView:longPressGesture.view];
    [self xwp_moveCell];
}

/**
 *  手势取消或者结束
 */
- (void)xwp_gestureEndOrCancle:(UILongPressGestureRecognizer *)longPressGesture{
    NSDictionary * dic = @{@"message":@"cannel"};
    [[NSNotificationCenter defaultCenter] postNotificationName:MOVETODELETENOTIFICATION object:nil userInfo:dic];
    
    MoveViewCell_c *originalCell = (MoveViewCell_c *)[self cellForItemAtIndexPath:_originalIndexPath];
    self.userInteractionEnabled = NO;
    _isPanning = NO;
    [self xwp_stopEdgeTimer];
    //通知代理
    if ([self.delegate respondsToSelector:@selector(dragCellCollectionViewCellEndMoving:)]) {
        [self.delegate dragCellCollectionViewCellEndMoving:self];
    }
    [UIView animateWithDuration:0.25 animations:^{
        _tempMoveCell.center = _orignalCenter;
    } completion:^(BOOL finished) {
        [self xwp_stopShakeAllCell];
        [_tempMoveCell removeFromSuperview];
        originalCell.hidden = NO;
        _orignalCell.hidden = NO;
        self.userInteractionEnabled = YES;
        _originalIndexPath = nil;
    }];
}

#pragma mark - 这是点击边框
-(void)addBordercolor:(NSIndexPath*)indexs{
    /*
    for (UICollectionViewCell *subCell in self.subviews) {
        [subCell.layer setBorderColor:[UIColor clearColor].CGColor];
    }
    UICollectionViewCell *cell =[self cellForItemAtIndexPath:indexs];
    [cell.layer setBorderColor:MAIN_COLOR.CGColor];
    [cell.layer setBorderWidth:1];
    [cell.layer setMasksToBounds:YES];
     */
}
#pragma mark - 清除所有边框
- (void)clearAllBorderColor
{
    for (UICollectionViewCell *subCell in self.subviews) {
        [subCell.layer setBorderColor:[UIColor clearColor].CGColor];
    }
}

#pragma mark - setter methods

- (void)setMinimumPressDuration:(NSTimeInterval)minimumPressDuration{
    _minimumPressDuration = minimumPressDuration;
    _longPressGesture.minimumPressDuration = minimumPressDuration;
}

- (void)setShakeLevel:(CGFloat)shakeLevel{
    CGFloat level = MAX(1.0f, shakeLevel);
    _shakeLevel = MIN(level, 10.0f);
}

#pragma mark - timer methods

- (void)xwp_setEdgeTimer{
    if (!_edgeTimer && _edgeScrollEable) {
        _edgeTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(xwp_edgeScroll)];
        [_edgeTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)xwp_stopEdgeTimer{
    if (_edgeTimer) {
        [_edgeTimer invalidate];
        _edgeTimer = nil;
    }
}
#pragma mark - private methods

- (void)xwp_moveCell{
    for (MoveViewCell_c *cell in [self visibleCells]) {
        if ([self indexPathForCell:cell] == _originalIndexPath || [self xwp_indexPathIsExcluded:[self indexPathForCell:cell]]) {
            continue;
        }
        //计算中心距
        CGFloat spacingX = fabs(_tempMoveCell.center.x - cell.center.x);
        CGFloat spacingY = fabs(_tempMoveCell.center.y - cell.center.y);
       // NSLog(@"当前的移动的x和y,x:%f===y:%f",_tempMoveCell.center.x,_tempMoveCell.center.y);
        
        NSDictionary * dic;
        if (_tempMoveCell.center.y < 10) {
            dic = @{@"message":@"delete"};
            [[NSNotificationCenter defaultCenter] postNotificationName:MOVETODELETENOTIFICATION object:nil userInfo:dic];
        }else
        {
            dic = @{@"message":@"undelete"};
            [[NSNotificationCenter defaultCenter] postNotificationName:MOVETODELETENOTIFICATION object:nil userInfo:dic];
        }
        
        if (spacingX <= _tempMoveCell.bounds.size.width / 2.0f && spacingY <= _tempMoveCell.bounds.size.height / 2.0f) {
            _moveIndexPath = [self indexPathForCell:cell];//这里是如果0，1，2，3，其中3->0.则，moveindex却为0-1，不是0-0可能是系统自动移动到0-1之后记录的位置？
            _orignalCell = cell;
            _orignalCenter = cell.center;
            NSLog(@"测试中：_tempOrignalCellTag==%d",_tempOrignalCellTag);
            _tempMovedToCellTag = cell.cellTag;//这里的cell.cellTag，是被交换的那个cell的tag。这里需要将想要交换和被交换的celltag对调。
            NSLog(@"测试中：cell.cellTag==%d",cell.cellTag);
            //更新数据源
            [self xwp_updateDataSource];
            //移动
            NSLog(@"xwp_moveCell==移动的原indexpath：%@===_originalIndexPath:%@===_moveIndexPath:%@", [self cellForItemAtIndexPath:_originalIndexPath],_originalIndexPath,_moveIndexPath);
            //            cell.hidden = YES;
            [CATransaction begin];
            [self moveItemAtIndexPath:_originalIndexPath toIndexPath:_moveIndexPath];
            
            //cell.cellTag
            NSDictionary * dic = @{@"moveToIndex":_moveIndexPath};
            [[NSNotificationCenter defaultCenter]postNotificationName:MOVEINDEXNOTIFICATION object:nil userInfo:dic];
            self.selectIndexPath = _moveIndexPath;
            MoveViewCell_c *originalCell = (MoveViewCell_c *)[self cellForItemAtIndexPath:_originalIndexPath];
            MoveViewCell_c *movedCell = (MoveViewCell_c *)[self cellForItemAtIndexPath:_moveIndexPath];
//            originalCell.cellTag = _tempOrignalCellTag;
//            movedCell.cellTag = _tempMovedToCellTag;
            NSLog(@"测试中：手势取消或者结束：_originalIndexPath===%@ ==== moveIndexPath：===%@ ===originalCell.cellTag==：%d===movedCell.cellTag=%d===_tempOrignalCellTag:%d",_originalIndexPath,_moveIndexPath,originalCell.cellTag,movedCell.cellTag,_tempOrignalCellTag);

            [CATransaction setCompletionBlock:^{
                NSLog(@"动画完成");
            }];
            [CATransaction commit];
            //通知代理
            if ([self.delegate respondsToSelector:@selector(dragCellCollectionView:moveCellFromIndexPath:toIndexPath:)]) {
                [self.delegate dragCellCollectionView:self moveCellFromIndexPath:_originalIndexPath toIndexPath:_moveIndexPath];
            }
            //设置移动后的起始indexPath
            _originalIndexPath = _moveIndexPath;
            break;
        }
    }
}

/**
 *  更新数据源
 */
- (void)xwp_updateDataSource{
    NSMutableArray *temp = @[].mutableCopy;
    //获取数据源
    if ([self.dataSource respondsToSelector:@selector(dataSourceArrayOfCollectionView:)]) {
        [temp addObjectsFromArray:[self.dataSource dataSourceArrayOfCollectionView:self]];
    }
    //判断数据源是单个数组还是数组套数组的多section形式，YES表示数组套数组
    BOOL dataTypeCheck = ([self numberOfSections] != 1 || ([self numberOfSections] == 1 && [temp[0] isKindOfClass:[NSArray class]]));
    if (dataTypeCheck) {
        for (int i = 0; i < temp.count; i ++) {
            [temp replaceObjectAtIndex:i withObject:[temp[i] mutableCopy]];
        }
    }
    if (_moveIndexPath.section == _originalIndexPath.section) {
        NSMutableArray *orignalSection = dataTypeCheck ? temp[_originalIndexPath.section] : temp;
        if (_moveIndexPath.item > _originalIndexPath.item) {
            for (NSUInteger i = _originalIndexPath.item; i < _moveIndexPath.item ; i ++) {
                [orignalSection exchangeObjectAtIndex:i withObjectAtIndex:i + 1];//这里一个从初始index+1依次交换到目标moveindex，为什么不直接交换这2个index的数据？
            }
        }else{
            for (NSUInteger i = _originalIndexPath.item; i > _moveIndexPath.item ; i --) {
                [orignalSection exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
            }
        }
    }else{
        NSMutableArray *orignalSection = temp[_originalIndexPath.section];
        NSMutableArray *currentSection = temp[_moveIndexPath.section];
        [currentSection insertObject:orignalSection[_originalIndexPath.item] atIndex:_moveIndexPath.item];
        [orignalSection removeObject:orignalSection[_originalIndexPath.item]];
    }
    //将重排好的数据传递给外部
    if ([self.delegate respondsToSelector:@selector(dragCellCollectionView:newDataArrayAfterMove:)]) {
        [self.delegate dragCellCollectionView:self newDataArrayAfterMove:temp.copy];
    }
}

- (void)xwp_edgeScroll{
    [self xwp_setScrollDirection];
    switch (_scrollDirection) {
        case XWDragCellCollectionViewScrollDirectionLeft:{
            //这里的动画必须设为NO
            [self setContentOffset:CGPointMake(self.contentOffset.x - 4, self.contentOffset.y) animated:NO];
            _tempMoveCell.center = CGPointMake(_tempMoveCell.center.x - 4, _tempMoveCell.center.y);
            _lastPoint.x -= 4;
            
        }
            break;
        case XWDragCellCollectionViewScrollDirectionRight:{
            [self setContentOffset:CGPointMake(self.contentOffset.x + 4, self.contentOffset.y) animated:NO];
            _tempMoveCell.center = CGPointMake(_tempMoveCell.center.x + 4, _tempMoveCell.center.y);
            _lastPoint.x += 4;
            
        }
            break;
        case XWDragCellCollectionViewScrollDirectionUp:{
            [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y - 4) animated:NO];
            _tempMoveCell.center = CGPointMake(_tempMoveCell.center.x, _tempMoveCell.center.y - 4);
            _lastPoint.y -= 4;
        }
            break;
        case XWDragCellCollectionViewScrollDirectionDown:{
            [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y + 4) animated:NO];
            _tempMoveCell.center = CGPointMake(_tempMoveCell.center.x, _tempMoveCell.center.y + 4);
            _lastPoint.y += 4;
        }
            break;
        default:
            break;
    }
    
}

- (void)xwp_shakeAllCell{
//    if (!_shakeWhenMoveing) {
//        //没有开启抖动只需要遍历设置个cell的hidden属性
//        NSArray *cells = [self visibleCells];
//        for (UICollectionViewCell *cell in cells) {
//            //顺便设置各个cell的hidden属性，由于有cell被hidden，其hidden状态可能被冲用到其他cell上,不能直接利用_originalIndexPath相等判断，这很坑
//            BOOL hidden = _originalIndexPath && [self indexPathForCell:cell].item == _originalIndexPath.item && [self indexPathForCell:cell].section == _originalIndexPath.section;
//            cell.hidden = hidden;
//        }
//        return;
//    }
//    CAKeyframeAnimation* anim=[CAKeyframeAnimation animation];
//    anim.keyPath=@"transform.rotation";
//    anim.values=@[@(angelToRandian(-_shakeLevel)),@(angelToRandian(_shakeLevel)),@(angelToRandian(-_shakeLevel))];
//    anim.repeatCount=MAXFLOAT;
//    anim.duration=0.2;
//    NSArray *cells = [self visibleCells];
//    for (MoveViewCell_c *cell in cells) {
//        if ([self xwp_indexPathIsExcluded:[self indexPathForCell:cell]]) {
//            continue;
//        }
//        /**如果加了shake动画就不用再加了*/
//        if (![cell.layer animationForKey:@"shake"]) {
//            [cell.layer addAnimation:anim forKey:@"shake"];
//        }
//        //顺便设置各个cell的hidden属性，由于有cell被hidden，其hidden状态可能被冲用到其他cell上
//        BOOL hidden = _originalIndexPath && [self indexPathForCell:cell].item == _originalIndexPath.item && [self indexPathForCell:cell].section == _originalIndexPath.section;
//        cell.hidden = hidden;
//    }
//    if (![_tempMoveCell.layer animationForKey:@"shake"]) {
//        [_tempMoveCell.layer addAnimation:anim forKey:@"shake"];
//    }
}

- (void)xwp_stopShakeAllCell{
    if (!_shakeWhenMoveing || _isEdited) {
        return;
    }
    NSArray *cells = [self visibleCells];
    for (MoveViewCell_c *cell in cells) {
        [cell.layer removeAllAnimations];
    }
    [_tempMoveCell.layer removeAllAnimations];
}

- (void)xwp_setScrollDirection{
    _scrollDirection = XWDragCellCollectionViewScrollDirectionNone;
    if (self.bounds.size.height + self.contentOffset.y - _tempMoveCell.center.y < _tempMoveCell.bounds.size.height / 2 && self.bounds.size.height + self.contentOffset.y < self.contentSize.height) {
        _scrollDirection = XWDragCellCollectionViewScrollDirectionDown;
    }
    if (_tempMoveCell.center.y - self.contentOffset.y < _tempMoveCell.bounds.size.height / 2 && self.contentOffset.y > 0) {
        _scrollDirection = XWDragCellCollectionViewScrollDirectionUp;
    }
    if (self.bounds.size.width + self.contentOffset.x - _tempMoveCell.center.x < _tempMoveCell.bounds.size.width / 2 && self.bounds.size.width + self.contentOffset.x < self.contentSize.width) {
        _scrollDirection = XWDragCellCollectionViewScrollDirectionRight;
    }
    
    if (_tempMoveCell.center.x - self.contentOffset.x < _tempMoveCell.bounds.size.width / 2 && self.contentOffset.x > 0) {
        _scrollDirection = XWDragCellCollectionViewScrollDirectionLeft;
    }
}

- (void)xwp_addContentOffsetObserver{
    if (_observering) return;
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    _observering = YES;
}

- (void)xwp_removeContentOffsetObserver{
    if (!_observering) return;
    [self removeObserver:self forKeyPath:@"contentOffset"];
    _observering = NO;
}

- (BOOL)xwp_indexPathIsExcluded:(NSIndexPath *)indexPath{
    if (!indexPath || ![self.delegate respondsToSelector:@selector(excludeIndexPathsWhenMoveDragCellCollectionView:)]) {
        return NO;
    }
    NSArray<NSIndexPath *> *excludeIndexPaths = [self.delegate excludeIndexPathsWhenMoveDragCellCollectionView:self];
    __block BOOL flag = NO;
    [excludeIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.item == indexPath.item && obj.section == indexPath.section) {
            flag = YES;
            *stop = YES;
        }
    }];
    return flag;
}

#pragma mark - public methods

- (void)xw_enterEditingModel{
    /*
    _isEdited = YES;
    _oldMinimumPressDuration =  _longPressGesture.minimumPressDuration;
    _longPressGesture.minimumPressDuration = 0;
    if (_shakeWhenMoveing) {
        [self xwp_shakeAllCell];
        [self xwp_addContentOffsetObserver];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xwp_foreground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }*/
}

- (void)xw_stopEditingModel{
    /*
    _isEdited = NO;
    _longPressGesture.minimumPressDuration = _oldMinimumPressDuration;
    [self xwp_stopShakeAllCell];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
     */
}


#pragma mark - overWrite methods

/**
 *  重写hitTest事件，判断是否应该相应自己的滑动手势，还是系统的滑动手势
 */

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    _longPressGesture.enabled = [self indexPathForItemAtPoint:point];
    return [super hitTest:point withEvent:event];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (![keyPath isEqualToString:@"contentOffset"]) return;
    if (_isEdited || _isPanning) {
        [self xwp_shakeAllCell];
    }else if (!_isEdited && !_isPanning){
        [self xwp_stopShakeAllCell];
    }
}

#pragma mark - notification

- (void)xwp_foreground{
    if (_isEdited) {
        [self xwp_shakeAllCell];
    }
}

#pragma mark ------setter

//cell大小
- (void)setCellSize:(CGSize)cellSize
{
    _cellSize = cellSize;
   // [self reloadData];
}
//cell个数
- (void)setCellCount:(NSInteger)cellCount
{
    _cellCount = cellCount;
}
//历史已存
- (NSMutableDictionary *)manageDic
{
    if (!_manageDic) {
        _manageDic = [NSMutableDictionary dictionary];
    }
    return _manageDic;
}
//选中cell的数据源
- (void)setSelectDataArr:(NSMutableArray *)selectDataArr
{
//    for (int i = 0; i<selectDataArr.count; i++) {
//        ZCVideoManager *videoMange = [[ZCVideoManager alloc]init];
//        [self.videoManagesArr addObject:videoMange];
//    }
    _selectDataArr = selectDataArr;
}
- (NSMutableDictionary *)tagDic
{
    if (!_tagDic) {
        _tagDic = [[NSMutableDictionary alloc]init];
    }
    return _tagDic;
}
- (NSMutableArray *)audioManagesArr
{
    if (!_audioManagesArr) {
        _audioManagesArr = [NSMutableArray array];
    }
    return _audioManagesArr;
}
- (NSMutableArray *)videoManagesArr
{
    if (!_videoManagesArr) {
        _videoManagesArr = [NSMutableArray array];
    }
    return  _videoManagesArr;
}


- (NSMutableDictionary *)historyDic
{
    if (!_historyDic) {
        _historyDic = [NSMutableDictionary dictionary];
    }
    return _historyDic;
}

#pragma mark - 视频双击变大变小方法
- (void)doubleTap:(UIGestureRecognizer*)gestureRecognizer
{
    CGPoint pressPoint = [gestureRecognizer locationInView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:pressPoint];
    self.selectIndexPath = indexPath;
    if (self.currentState == MoveCellStateOneScreen) {
        self.currentState = MoveCellStateFourScreen;
        [self reloadData];
        NSDictionary * dic = @{@"isBig":@"NO",@"selectIndexPath":self.selectIndexPath};
        [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
    }else if (self.currentState == MoveCellStateFourScreen)
    {
        self.currentState = MoveCellStateOneScreen;
        [self reloadData];
        [self scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        NSDictionary * dic = @{@"isBig":@"YES",@"selectIndexPath":self.selectIndexPath};
        [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
    }else if (self.currentState == MoveCellStateFourScreen_HengPing)
    {
        self.currentState = MoveCellStateOneScreen_HengPing;
        [self reloadData];
        [self scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        NSDictionary * dic = @{@"isBig":@"YES",@"selectIndexPath":self.selectIndexPath};
        [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
    }else if (self.currentState == MoveCellStateOneScreen_HengPing)
    {
        self.currentState = MoveCellStateFourScreen_HengPing;
        [self reloadData];
        [self scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        NSDictionary * dic = @{@"isBig":@"NO",@"selectIndexPath":self.selectIndexPath};
        [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
    }
}

//#pragma mark ------双击手势
//- (void)doubleTap:(UIGestureRecognizer*)gestureRecognizer
//{
//    CGPoint pressPoint = [gestureRecognizer locationInView:self];
//    NSIndexPath *indexPath = [self indexPathForItemAtPoint:pressPoint];
//    self.selectIndexPath = indexPath;
//    if (self.currentState == MoveCellStateFourScreen) {
////        CGPoint pressPoint = [gestureRecognizer locationInView:self];
////        NSIndexPath *indexPath = [self indexPathForItemAtPoint:pressPoint];
////        self.selectIndexPath = indexPath;
//
//        NSLog(@"调试，双击的手势indexpath:%@===self.selectIndexPath:%@",indexPath,self.selectIndexPath);
//        MoveViewCell_c *cellView =(MoveViewCell_c *)[self cellForItemAtIndexPath:indexPath];
//
//        if (self.currentState != MoveCellStateOneScreen ||
//            self.currentState != MoveCellStateOneScreen_HengPing) {
//            [self addBordercolor:indexPath];
//        }
//        [self clearAllBorderColor];
//        self.currentState = MoveCellStateOneScreen;
//
//        _oldRect = cellView.frame;
//
//        NSData *oldRect_fourScreen = [NSKeyedArchiver archivedDataWithRootObject:[NSValue valueWithCGRect:cellView.frame]];
//        [[NSUserDefaults standardUserDefaults] setObject:oldRect_fourScreen forKey:OLDRECT_FOURSCREEN];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//
//        [cellView setFrame:self.frame];
//        [self bringSubviewToFront:cellView];
//        NSDictionary * dic = @{@"isBig":@"YES",@"selectIndexPath":self.selectIndexPath};
//        [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
//
//        NSDictionary * dic2 = @{@"hasHengPing":@"NO"};
//        [[NSNotificationCenter defaultCenter]postNotificationName:HASHENGPING object:nil userInfo:dic2];
//
//        NSDictionary * dic3 = @{@"ScrollViewScroEnable":@"YES"};
//        [[NSNotificationCenter defaultCenter]postNotificationName:SCROLLVIEWSCROENABLE object:nil userInfo:dic3];
//
//    }else if(self.currentState == MoveCellStateOneScreen && self.lastState != MoveCellStateOneScreen_HengPing){
//        self.currentState = MoveCellStateFourScreen;
//        MoveViewCell_c *cellView =(MoveViewCell_c *)[self cellForItemAtIndexPath:self.selectIndexPath];
//
//        if ([[NSUserDefaults standardUserDefaults]objectForKey:OLDRECT_FOURSCREEN]) {
//            NSData * oldRect = [[NSUserDefaults standardUserDefaults]objectForKey:OLDRECT_FOURSCREEN];
//            CGRect oldRect_hengping = [[NSKeyedUnarchiver unarchiveObjectWithData:oldRect] CGRectValue];
//
//            [cellView setFrame:oldRect_hengping];
//        }
//        NSDictionary * dic = @{@"isBig":@"NO",@"selectIndexPath":self.selectIndexPath};
//        [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
//
//        NSDictionary * dic3 = @{@"ScrollViewScroEnable":@"NO"};
//        [[NSNotificationCenter defaultCenter]postNotificationName:SCROLLVIEWSCROENABLE object:nil userInfo:dic3];
//
//    }else if (self.currentState == MoveCellStateFourScreen_HengPing)
//    {
//        [self clearAllBorderColor];
//        self.currentState = MoveCellStateOneScreen_HengPing;
//        MoveViewCell_c *cellView = [self whichCellClick:gestureRecognizer];
//
//        NSData *oldRect_fourScreen_hengping = [NSKeyedArchiver archivedDataWithRootObject:[NSValue valueWithCGRect:cellView.frame]];
//        [[NSUserDefaults standardUserDefaults] setObject:oldRect_fourScreen_hengping forKey:OLDRECT_FOURSCREEN_HENGPING];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//
//        [cellView setFrame:self.frame];
//        [self bringSubviewToFront:cellView];
//
//        NSDictionary * dic = @{@"isBig":@"YES",@"selectIndexPath":self.selectIndexPath};
//        [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
//
//    }else if(self.currentState == MoveCellStateOneScreen_HengPing && self.lastState != MoveCellStateOneScreen){
//
//        self.currentState = MoveCellStateFourScreen_HengPing;
//
//        if (self.currentState != MoveCellStateFourScreen_HengPing) {
//            MoveViewCell_c *cellView = [self whichCellClick:gestureRecognizer];
//            if ([[NSUserDefaults standardUserDefaults]objectForKey:OLDRECT_FOURSCREEN_HENGPING]) {
//                NSData * oldRect = [[NSUserDefaults standardUserDefaults]objectForKey:OLDRECT_FOURSCREEN_HENGPING];
//                CGRect oldRect_hengping = [[NSKeyedUnarchiver unarchiveObjectWithData:oldRect] CGRectValue];
//
//                [cellView setFrame:oldRect_hengping];
//            }
//            NSDictionary * dic = @{@"isBig":@"NO",@"selectIndexPath":self.selectIndexPath};
//            [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
//        }else{
//            MoveViewCell_c *cellView =(MoveViewCell_c *)[self cellForItemAtIndexPath:self.selectIndexPath];
//            //            NSLog(@"我当前所在的位置：%@",self.selectIndexPath);
//            self.currentState = MoveCellStateFourScreen_HengPing;
//            self.lastState = MoveCellStateOneScreen_HengPing;
//            //=================================
//            if ([[NSUserDefaults standardUserDefaults]objectForKey:OLDRECT_FOURSCREEN_HENGPING]) {
//                NSData * oldRect = [[NSUserDefaults standardUserDefaults]objectForKey:OLDRECT_FOURSCREEN_HENGPING];
//                CGRect oldRect_hengping = [[NSKeyedUnarchiver unarchiveObjectWithData:oldRect] CGRectValue];
//
//                [cellView setFrame:oldRect_hengping];
//            }
//            NSDictionary * dic = @{@"isBig":@"NO",@"selectIndexPath":self.selectIndexPath};
//            [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
//            //=================================
//        }
//    }else if (self.currentState == MoveCellStateOneScreen && self.lastState == MoveCellStateOneScreen_HengPing)
//    {
//
//        self.currentState = MoveCellStateFourScreen;
//        self.lastState = MoveCellStateFourScreen;
//        //        [self reloadData];//注释掉
//        //        新加的
//        //==========================
//        MoveViewCell_c *cellView =(MoveViewCell_c *)[self cellForItemAtIndexPath:self.selectIndexPath];
//        if ([[NSUserDefaults standardUserDefaults]objectForKey:OLDRECT_FOURSCREEN]) {
//            NSData * oldRect = [[NSUserDefaults standardUserDefaults]objectForKey:OLDRECT_FOURSCREEN];
//            CGRect oldRect_hengping = [[NSKeyedUnarchiver unarchiveObjectWithData:oldRect] CGRectValue];
//
//            [cellView setFrame:oldRect_hengping];
//        }
//        //==========================
//        [self reloadData];
//
//        NSDictionary * dic = @{@"isBig":@"NO",@"selectIndexPath":self.selectIndexPath};
//        [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
//
//    }else if(self.currentState == MoveCellStateOneScreen_HengPing && self.lastState == MoveCellStateOneScreen){
//        self.currentState = MoveCellStateFourScreen_HengPing;
//        //        self.lastState = MoveCellStateFourScreen;之前
//        self.lastState = MoveCellStateOneScreen_HengPing;//MoveCellStateFourScreen_HengPing
//        /*
//         NSDictionary * dic = @{@"isBig":@"NO",@"selectIndexPath":self.selectIndexPath};
//         [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
//         */
//        [self reloadData];
//    }else{
//    }
//}

- (MoveViewCell_c *)whichCellClick:(UIGestureRecognizer *)gesture
{
    CGPoint pressPoint = [gesture locationInView:self];
    NSIndexPath *indexPath = [self indexPathForItemAtPoint:pressPoint];
    self.selectIndexPath = indexPath;
    if (self.currentState != MoveCellStateOneScreen ||
        self.currentState != MoveCellStateOneScreen_HengPing) {
        [self addBordercolor:indexPath];
    }
    MoveViewCell_c *cellView =(MoveViewCell_c *)[self cellForItemAtIndexPath:indexPath];
    return cellView;
}

- (void)HasHengPingToChangeSomeValue:(NSNotification*)noti
{
    if (noti) {
        NSString * str = [NSString stringWithFormat:@"%@",[noti.userInfo objectForKey:@"hasHengPing"]];
        if ([str isEqualToString:@"YES"]) {
            self.bHashengping = YES;
        }else{
            self.bHashengping = NO;
        }
    }else{
        NSLog(@"横屏通知noti为nil");
    }
}
- (void)directHengPing:(NSNotification *)noti
{
    if (noti.userInfo) {
        self.noDoubleTohengpingOldRect = [[noti.userInfo objectForKey:@"oldRect"]CGRectValue];
    }
}

- (void)beginSplitScreen
{
    if (self.selectIndexPath == nil) {
        self.selectIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];//如果没有值，则默认第一个item
    }
    if (self.currentState == MoveCellStateOneScreen) {
        self.currentState = MoveCellStateFourScreen;
        [self reloadData];
        NSDictionary * dic = @{@"isBig":@"NO",@"selectIndexPath":self.selectIndexPath};
        [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
    }else if (self.currentState == MoveCellStateFourScreen)
    {
        self.currentState = MoveCellStateOneScreen;
        [self reloadData];
        [self scrollToItemAtIndexPath:self.selectIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        NSDictionary * dic = @{@"isBig":@"YES",@"selectIndexPath":self.selectIndexPath};
        [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
    }else if (self.currentState == MoveCellStateFourScreen_HengPing)
    {
        self.currentState = MoveCellStateOneScreen_HengPing;
        [self reloadData];
        [self scrollToItemAtIndexPath:self.selectIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        NSDictionary * dic = @{@"isBig":@"YES",@"selectIndexPath":self.selectIndexPath};
        [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
    }else if (self.currentState == MoveCellStateOneScreen_HengPing)
    {
        self.currentState = MoveCellStateFourScreen_HengPing;
        [self reloadData];
        [self scrollToItemAtIndexPath:self.selectIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        NSDictionary * dic = @{@"isBig":@"NO",@"selectIndexPath":self.selectIndexPath};
        [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
    }
}
/*
- (void)beginSplitScreen
{
    if (self.currentState == MoveCellStateFourScreen) {
        
        MoveViewCell_c *cellView =(MoveViewCell_c *)[self cellForItemAtIndexPath:self.selectIndexPath];
        if (self.currentState != MoveCellStateOneScreen ||
            self.currentState != MoveCellStateOneScreen_HengPing) {
            [self addBordercolor:self.selectIndexPath];
        }
        self.currentState = MoveCellStateOneScreen;
        
        _oldRect = cellView.frame;
        NSLog(@"【点击分屏】调试，双击的手势indexpath:%@===self.selectIndexPath:%@,oldRect:%@===cellFrame:%@",self.selectIndexPath,self.selectIndexPath,NSStringFromCGRect(_oldRect),NSStringFromCGRect(cellView.frame));

        NSData *oldRect_fourScreen = [NSKeyedArchiver archivedDataWithRootObject:[NSValue valueWithCGRect:cellView.frame]];
        [[NSUserDefaults standardUserDefaults] setObject:oldRect_fourScreen forKey:OLDRECT_FOURSCREEN];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [cellView setFrame:self.frame];
        [self bringSubviewToFront:cellView];
        NSDictionary * dic = @{@"isBig":@"YES",@"selectIndexPath":self.selectIndexPath};
        [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
        
        NSDictionary * dic2 = @{@"hasHengPing":@"NO"};
        [[NSNotificationCenter defaultCenter]postNotificationName:HASHENGPING object:nil userInfo:dic2];
        
        NSDictionary * dic3 = @{@"ScrollViewScroEnable":@"YES"};
        [[NSNotificationCenter defaultCenter]postNotificationName:SCROLLVIEWSCROENABLE object:nil userInfo:dic3];
        
    }else if(self.currentState == MoveCellStateOneScreen && self.lastState != MoveCellStateOneScreen_HengPing){
        
        self.currentState = MoveCellStateFourScreen;
        MoveViewCell_c *cellView =(MoveViewCell_c *)[self cellForItemAtIndexPath:self.selectIndexPath];
        
        if ([[NSUserDefaults standardUserDefaults]objectForKey:OLDRECT_FOURSCREEN]) {
            NSData * oldRect = [[NSUserDefaults standardUserDefaults]objectForKey:OLDRECT_FOURSCREEN];
            CGRect oldRect_hengping = [[NSKeyedUnarchiver unarchiveObjectWithData:oldRect] CGRectValue];
            
            [cellView setFrame:oldRect_hengping];
        }
        NSDictionary * dic = @{@"isBig":@"NO",@"selectIndexPath":self.selectIndexPath};
        [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
        
        NSDictionary * dic3 = @{@"ScrollViewScroEnable":@"NO"};
        [[NSNotificationCenter defaultCenter]postNotificationName:SCROLLVIEWSCROENABLE object:nil userInfo:dic3];
        
    }else if (self.currentState == MoveCellStateFourScreen_HengPing)
    {
        self.currentState = MoveCellStateOneScreen_HengPing;
      
        if (self.currentState != MoveCellStateOneScreen ||
            self.currentState != MoveCellStateOneScreen_HengPing) {
            [self addBordercolor:self.selectIndexPath];
        }
        MoveViewCell_c *cellView =(MoveViewCell_c *)[self cellForItemAtIndexPath:self.selectIndexPath];
        NSData *oldRect_fourScreen_hengping = [NSKeyedArchiver archivedDataWithRootObject:[NSValue valueWithCGRect:cellView.frame]];
        [[NSUserDefaults standardUserDefaults] setObject:oldRect_fourScreen_hengping forKey:OLDRECT_FOURSCREEN_HENGPING];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [cellView setFrame:self.frame];
        [self bringSubviewToFront:cellView];
        
        NSDictionary * dic = @{@"isBig":@"YES",@"selectIndexPath":self.selectIndexPath};
        [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
        
    }else if(self.currentState == MoveCellStateOneScreen_HengPing && self.lastState != MoveCellStateOneScreen){
        self.currentState = MoveCellStateFourScreen_HengPing;
        if (self.currentState != MoveCellStateOneScreen ||
            self.currentState != MoveCellStateOneScreen_HengPing) {
            [self addBordercolor:self.selectIndexPath];
        }
        MoveViewCell_c *cellView =(MoveViewCell_c *)[self cellForItemAtIndexPath:self.selectIndexPath];
        if ([[NSUserDefaults standardUserDefaults]objectForKey:OLDRECT_FOURSCREEN_HENGPING]) {
            NSData * oldRect = [[NSUserDefaults standardUserDefaults]objectForKey:OLDRECT_FOURSCREEN_HENGPING];
            CGRect oldRect_hengping = [[NSKeyedUnarchiver unarchiveObjectWithData:oldRect] CGRectValue];
            
            [cellView setFrame:oldRect_hengping];
        }
        NSDictionary * dic = @{@"isBig":@"NO",@"selectIndexPath":self.selectIndexPath};
        [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
    }else if (self.currentState == MoveCellStateOneScreen && self.lastState == MoveCellStateOneScreen_HengPing)
    {
        self.currentState = MoveCellStateFourScreen;
        self.lastState = MoveCellStateFourScreen;
        
//        [self reloadData];
        
        //        新加的
        //==========================
        MoveViewCell_c *cellView =(MoveViewCell_c *)[self cellForItemAtIndexPath:self.selectIndexPath];
        if ([[NSUserDefaults standardUserDefaults]objectForKey:OLDRECT_FOURSCREEN]) {
            NSData * oldRect = [[NSUserDefaults standardUserDefaults]objectForKey:OLDRECT_FOURSCREEN];
            CGRect oldRect_hengping = [[NSKeyedUnarchiver unarchiveObjectWithData:oldRect] CGRectValue];
            
            [cellView setFrame:oldRect_hengping];
        }
        //==========================
        
        [self reloadData];
        
        
        NSDictionary * dic = @{@"isBig":@"NO",@"selectIndexPath":self.selectIndexPath};
        [[NSNotificationCenter defaultCenter]postNotificationName:DOUBLETAPNOTIFICATION object:nil userInfo:dic];
        
    }else if(self.currentState == MoveCellStateOneScreen_HengPing && self.lastState == MoveCellStateOneScreen){
        self.currentState = MoveCellStateFourScreen_HengPing;
        self.lastState = MoveCellStateFourScreen;
        [self reloadData];
    }else{
    }
}
*/
 
#pragma mark ------删除正在播放cell
-(void)deletePlayCell:(NSNotification *)noit
{
    if (noit) {//&& !_originalIndexPath
        if ([noit.userInfo objectForKey:@"currentIndexPath"]) {
            _originalIndexPath = [noit.userInfo objectForKey:@"currentIndexPath"];
        }
    }
    
    MoveViewCell_c *cell = (MoveViewCell_c *)[self cellForItemAtIndexPath:_originalIndexPath];
    
    [cell.videoManage JWStreamPlayerManageEndPlayLiveVideoIsStop:NO CompletionBlock:^(JWErrorCode errorCode) {
        if (errorCode == JW_SUCCESS) {
            NSLog(@"拖动删除正在播放的cell 停止成功");
        }else{
            NSLog(@"拖动删除正在播放的cell 停止失败");
        }
    }];
    
    
    //子视图删除后重新添加
    for (UIView *subView in cell.contentView.subviews) {
        [subView removeFromSuperview];
    }
    [cell setUpChildView];
    [[NSNotificationCenter defaultCenter]postNotificationName:BTNHISTORYENAL object:nil];
}




@end
