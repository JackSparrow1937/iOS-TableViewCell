//
//  JListView.h
//  TableViewCellStyle
//
//  Created by Jack-Sparrow on 2020/3/23.
//  Copyright © 2020 Jack-Sparrow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JListViewDelegate <NSObject>

@optional  //可不实现方法

/**
 * 返回分区个数
 */
- (NSInteger)JListViewNumberForSection;

/**
 * 返回头部高度
 */
- (CGFloat)JListViewOfHeaderViewHeightWithSection:(NSInteger)section;

/**
 * 返回分区头部view
 */
- (UIView *)JListViewOfHeadViewWithSection:(NSInteger)section;

/**
 * 返回cell高度
 */
- (CGFloat)JListViewCellHeightWithSection:(NSInteger)section row:(NSInteger)row;

/**
 * 返回整个分区阴影颜色
 */
- (UIColor *)JListViewSectionShaowColorWithSection:(NSInteger)section;

/**
 * 分区cell第一个和左后一个是否有圆角
 */
- (CGFloat)JListViewSectionCornerRadiusWithSection:(NSInteger)section;

/**
 * 加载错误
 */
- (void)JListViewLoadError:(NSString *)errorStr;

/**
 * 点击事件
 */
- (void)JListViewdidSelectRowCell:(UIView *)cell indexPath:(NSIndexPath *)indexPath;

@required  //必须实现方法
/**
 * 返回分区,cell个数
 */
- (NSInteger)JListViewNumberOfCellForSection:(NSInteger)section;

/**
 * 返回cell
 */
- (UIView *)JListViewForCell:(NSIndexPath *)indexPath;

@end
@interface JListView : UIView
@property (nonatomic, weak)id<JListViewDelegate> delegate;

/**
 * 是否根据内容自动适配高度.默认false
 */
@property (nonatomic, assign)BOOL autoAdaptation;
/**
 * 是否显示分割线,默认显示
 */
@property (nonatomic, assign)BOOL separatorStyle;
/**
 * JListView的头部view
 */
@property (nonatomic, strong)UIView *JListViewheadView;
/**
 * 重新加载UI数据
 */
- (void)reloadData;
@end

