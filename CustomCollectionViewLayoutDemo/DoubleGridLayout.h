//
//  DoubleGridLayout.h
//  CircleLayout
//
//  Created by taolv on 15/8/12.
//  Copyright (c) 2015年 Olivier Gutknecht. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const UICollectionElementKindTopHeader;
extern NSString *const UICollectionElementKindLeftHeader;
extern NSString *const UICollectionElementKindSupplyHeader;

@protocol UICollectionViewDelegateDoubleGridLayout <UICollectionViewDelegate>

@optional
- (CGFloat)collectionView:(UICollectionView *)collectionView heightForRow:(NSInteger)row;

- (CGFloat)collectionView:(UICollectionView *)collectionView widthForColumn:(NSInteger)column;

@end

/** 双向拖动表格布局。假设算上表头表格为8*10的表（8行10列），表格分为三部分，上面表头1*10（默认左上角格子属于上表头），左表头7*1（从第二行开始计数），单元格为7*9（第二行第二列开始计数）。
 * 表格原理为，上表头和左表头是SupplementaryView，分别由上面给出的两个extern string标识，其余单元格为cell。每当collectionView拖动时，重新计算布局，使表头悬浮不动。单元格位置无需重新计算。
 * 请注意填充表格的 SupplementaryView 避免数组越界
 */
@interface DoubleGridLayout : UICollectionViewLayout

/** 每行高度
 * 如果实现了 collectionView: heightForRow: 协议，将按协议返回高度计算
 */
@property (nonatomic, assign) CGFloat rowHeight;

/** 每列宽度
 * 如果实现了 collectionView: widthForColumn: 协议，将按协议返回宽度计算
 */
@property (nonatomic, assign) CGFloat columnWidth;

// 左边固定列宽度
@property (nonatomic, assign) CGFloat leftHeaderWidth;

// 顶部固定行高度
@property (nonatomic, assign) CGFloat topHeaderHeight;

// 表格行数。不包括上表头，上表头一行是固定的
@property (nonatomic, assign) NSInteger rowNumber;

// 表格列数。不包括左表头，左表头一列固定。
@property (nonatomic, assign) NSInteger columnNumber;

// 左上角cell算左边header还是上面header。默认为NO，算上面header。那么上表头个数为columnNumber + 1，左表头格子数为rowNumber，从第二行算起
@property (nonatomic, assign) BOOL leftTopHeaderIsLeft;

// 额外添加一个头部
@property (nonatomic, assign) CGFloat supplyHeaderHeight;

// 是否显示表格水平分割线。默认不显示
@property (nonatomic, assign) BOOL showHorizonLine;
// 水平分割线是否延伸至左表头。默认否
@property (nonatomic, assign) BOOL extendHorizonLine;

// 是否显示表格垂直分割线。默认不显示
@property (nonatomic, assign) BOOL showVerticalLine;
// 垂直分割线是否延伸至上表头。默认否
@property (nonatomic, assign) BOOL extendVerticalLine;

@end
