//
//  DoubleGridLayout.m
//  CircleLayout
//
//  Created by taolv on 15/8/12.
//  Copyright (c) 2015年 Olivier Gutknecht. All rights reserved.
//

#import "DoubleGridLayout.h"

NSString *const UICollectionElementKindTopHeader = @"UICollectionElementKindTopHeader";
NSString *const UICollectionElementKindLeftHeader = @"UICollectionElementKindLeftHeader";

@interface DoubleGridLayout ()

@property (nonatomic, strong) NSArray *cellFrameArr;

@property (nonatomic, strong) NSArray *leftHeaderFrameArr;

@property (nonatomic, strong) NSArray *topHeaderFrameArr;

@end

@implementation DoubleGridLayout

- (void)prepareLayout
{
    [super prepareLayout];
    
    // content offset 变化时，无需重新计算cell的frame
    if (!self.cellFrameArr) {
        // 缓存frame
        NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:self.columnNumber * self.rowNumber];
        for (NSInteger i = 0; i != self.rowHeight; ++i) {
            for (NSInteger j = 0; j != self.columnNumber; ++j) {
                CGRect frame = [self frameForItem:i * self.columnNumber + j];
                [tmpArr addObject:[NSValue valueWithCGRect:frame]];
            }
        }
        self.cellFrameArr = tmpArr;
    }
    
    id<UICollectionViewDelegateDoubleGridLayout> collectionViewDelegate = (id<UICollectionViewDelegateDoubleGridLayout>)self.collectionView.delegate;

    // 计算左表头各单元格位置
    NSMutableArray *tmpArr2 = [NSMutableArray arrayWithCapacity:self.rowNumber + 1];
    for (NSInteger i = 0; i != self.rowNumber; ++i) {
        CGFloat x = self.collectionView.contentOffset.x;
        CGFloat y = self.topHeaderHeight;
        // 计算规则。第一行高 topHeaderHeight 累加其他行高
        if ([collectionViewDelegate respondsToSelector:@selector(collectionView:heightForRow:)]) {
            for (NSInteger j = 0; j < i; ++j) {
                y += [collectionViewDelegate collectionView:self.collectionView heightForRow:j];
            }
        } else {
            y += i * self.rowHeight;
        }

        CGFloat width = self.leftHeaderWidth;
        // 计算高度。如果实现了代理，返回代理指定高度
        CGFloat height = self.rowHeight;
        if ([collectionViewDelegate respondsToSelector:@selector(collectionView:heightForRow:)]) {
            height = [collectionViewDelegate collectionView:self.collectionView heightForRow:i];
        }
        
        CGRect frame = CGRectMake(x, y, width, height);
        [tmpArr2 addObject:[NSValue valueWithCGRect:frame]];
    }
    
    // 插入左上角
    if (_leftTopHeaderIsLeft) {
        CGRect frame = CGRectMake(0, 0, self.leftHeaderWidth, self.topHeaderHeight);
        frame.origin = self.collectionView.contentOffset;
        [tmpArr2 insertObject:[NSValue valueWithCGRect:frame] atIndex:0];
    }
    self.leftHeaderFrameArr = tmpArr2;
    
    // 计算上表头各单元格位置
    NSMutableArray *tmpArr3 = [NSMutableArray arrayWithCapacity:self.columnNumber + 1];
    for (NSInteger i = 0; i != self.columnNumber; ++i) {
        CGFloat y = self.collectionView.contentOffset.y;
        CGFloat x = self.leftHeaderWidth;
        if ([collectionViewDelegate respondsToSelector:@selector(collectionView:widthForColumn:)]) {
            for (NSInteger j = 0; j < i; ++j) {
                x += [collectionViewDelegate collectionView:self.collectionView widthForColumn:j];
            }
        } else {
            x += i * self.columnWidth;
        }

        CGFloat width = self.columnWidth;
        if ([collectionViewDelegate respondsToSelector:@selector(collectionView:widthForColumn:)]) {
            width = [collectionViewDelegate collectionView:self.collectionView widthForColumn:i];
        }
        CGFloat height = self.topHeaderHeight;
        
        CGRect frame = CGRectMake(x, y, width, height);
        [tmpArr3 addObject:[NSValue valueWithCGRect:frame]];
    }
    
    // 插入左上角
    if (!_leftTopHeaderIsLeft) {
        CGRect frame = CGRectMake(0, 0, self.leftHeaderWidth, self.topHeaderHeight);
        frame.origin = self.collectionView.contentOffset;
        [tmpArr3 insertObject:[NSValue valueWithCGRect:frame] atIndex:0];
    }
    self.topHeaderFrameArr = tmpArr3;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    // contentoffset 变化时，重新布局。
    return YES;
}

-(CGSize)collectionViewContentSize
{
    id<UICollectionViewDelegateDoubleGridLayout> collectionViewDelegate = (id<UICollectionViewDelegateDoubleGridLayout>)self.collectionView.delegate;

    CGFloat width = self.leftHeaderWidth;
    for (NSInteger i = 0; i < self.columnNumber; ++i) {
        if ([collectionViewDelegate respondsToSelector:@selector(collectionView:widthForColumn:)]) {
            width += [collectionViewDelegate collectionView:self.collectionView widthForColumn:i];
        } else {
            width += self.columnWidth;
        }
    }
    width = MAX(width, self.collectionView.frame.size.width);
    
    CGFloat height = self.topHeaderHeight;
    for (NSInteger j = 0; j < self.rowNumber; ++j) {
        if ([collectionViewDelegate respondsToSelector:@selector(collectionView:heightForRow:)]) {
            height += [collectionViewDelegate collectionView:self.collectionView heightForRow:j];
        } else {
            height += self.rowHeight;
        }
    }
    height = MAX(height, self.collectionView.frame.size.height);
    
    return CGSizeMake(width, height);
}

- (CGRect)frameForItem:(NSInteger)item
{
    id<UICollectionViewDelegateDoubleGridLayout> collectionViewDelegate = (id<UICollectionViewDelegateDoubleGridLayout>)self.collectionView.delegate;
    
    NSInteger row = item / self.columnNumber;
    NSInteger column = item % self.columnNumber;
    // 计算x坐标
    CGFloat x = self.leftHeaderWidth;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:widthForColumn:)]) {
        for (NSInteger i = 0; i < column; ++i) {
            x += [collectionViewDelegate collectionView:self.collectionView widthForColumn:i];
        }
    } else {
        x += column * self.columnWidth;
    }
    // 计算y坐标
    CGFloat y = self.topHeaderHeight;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:heightForRow:)]) {
        for (NSInteger j = 0; j < row; ++j) {
            y += [collectionViewDelegate collectionView:self.collectionView heightForRow:j];
        }
    } else {
        y += row * self.rowHeight;
    }
    // 计算宽度和高度
    CGFloat width = self.columnWidth;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:widthForColumn:)]) {
        width = [collectionViewDelegate collectionView:self.collectionView widthForColumn:column];
    }
    CGFloat height = self.rowHeight;
    if ([collectionViewDelegate respondsToSelector:@selector(collectionView:heightForRow:)]) {
        height = [collectionViewDelegate collectionView:self.collectionView heightForRow:row];
    }
    
    return CGRectMake(x, y, width, height);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
    
    attributes.frame = [self.cellFrameArr[path.item] CGRectValue];
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    if ([elementKind isEqualToString:UICollectionElementKindTopHeader]) {
        attributes.frame = [self.topHeaderFrameArr[indexPath.item] CGRectValue];
        // 左上角算左表头时，左表头优先显示
        if (_leftTopHeaderIsLeft) {
            attributes.zIndex = 5;
        } else {
            attributes.zIndex = 10;
            // 左上角优先级最高
            if (indexPath.item == 0) {
                attributes.zIndex = 20;
            }
        }
    } else if ([elementKind isEqualToString:UICollectionElementKindLeftHeader]) {
        attributes.frame = [self.leftHeaderFrameArr[indexPath.item] CGRectValue];
        if (_leftTopHeaderIsLeft) {
            attributes.zIndex = 10;
            // 左上角优先级最高
            if (indexPath.item == 0) {
                attributes.zIndex = 20;
            }
        } else {
            attributes.zIndex = 5;
        }
    } else {
        NSAssert(false, @"no such kind SupplementaryView");
    }
    return attributes;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributes = [NSMutableArray array];
    for (NSInteger i = 0; i != self.rowNumber; ++i) {
        for (NSInteger j = 0; j != self.columnNumber; ++j) {
            CGRect frame = [self.cellFrameArr[i * self.columnNumber + j] CGRectValue];
            if (CGRectIntersectsRect(rect, frame) || CGRectContainsRect(rect, frame)) {
                [attributes addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i * self.columnNumber + j inSection:0]]];
            }
        }
    }
    
    NSInteger leftHeaderCellCount = self.rowNumber;
    NSInteger topHeaderCellCount = self.columnNumber;
    if (_leftTopHeaderIsLeft) {
        ++leftHeaderCellCount;
    } else {
        ++topHeaderCellCount;
    }
    for (NSInteger i = 0; i != leftHeaderCellCount; ++i) {
        [attributes addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindLeftHeader atIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]];
    }
    for (NSInteger j = 0; j != topHeaderCellCount; ++j) {
        [attributes addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindTopHeader atIndexPath:[NSIndexPath indexPathForItem:j inSection:0]]];
    }

    return attributes;
}

@end
