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
NSString *const UICollectionElementKindSupplyHeader = @"UICollectionElementKindSupplyHeader";

NSString *const UICollectionElementKindVerticalLine = @"UICollectionElementKindVerticalLine";
NSString *const UICollectionElementKindHorizonLine = @"UICollectionElementKindHorizonLine";

NSInteger const zIndexHeadTopLeft = 20;
NSInteger const zIndexHeadTop = 10;
NSInteger const zIndexHeadLeft = 5;
NSInteger const zIndexSeperateLine = 25;
NSInteger const zIndexCell = 0;


@interface DoubleGridHorizonLine : UICollectionReusableView

@end

@interface DoubleGridVerticalLine : UICollectionReusableView

@end

#pragma mark - DoubleGridLayout

@interface DoubleGridLayout ()

@property (nonatomic, strong) NSArray *cellFrameArr;

@property (nonatomic, strong) NSArray *leftHeaderFrameArr;

@property (nonatomic, strong) NSArray *topHeaderFrameArr;

@end

@implementation DoubleGridLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self registerClass:[DoubleGridHorizonLine class] forDecorationViewOfKind:UICollectionElementKindHorizonLine];
        [self registerClass:[DoubleGridVerticalLine class] forDecorationViewOfKind:UICollectionElementKindVerticalLine];
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    // content offset 变化时，无需重新计算cell的frame。取消缓存机制，代码难写。修改了rowHeight或者任一高度时，都应该重新计算。其实只是contentoffset修改时不用重新计算，但我找不到优雅的办法判断什么时候是contentoffset变化。先修复bug，优化将来再说。
//    if (!self.cellFrameArr) {
        // 缓存frame
        NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:self.columnNumber * self.rowNumber];
        for (NSInteger i = 0; i != self.rowNumber; ++i) {
            for (NSInteger j = 0; j != self.columnNumber; ++j) {
                CGRect frame = [self frameForItem:i * self.columnNumber + j];
                [tmpArr addObject:[NSValue valueWithCGRect:frame]];
            }
        }
        self.cellFrameArr = tmpArr;
//    }
    
    id<UICollectionViewDelegateDoubleGridLayout> collectionViewDelegate = (id<UICollectionViewDelegateDoubleGridLayout>)self.collectionView.delegate;

    // 计算左表头各单元格位置
    NSMutableArray *tmpArr2 = [NSMutableArray arrayWithCapacity:self.rowNumber + 1];
    for (NSInteger i = 0; i != self.rowNumber; ++i) {
        CGFloat x = self.collectionView.contentOffset.x;
        CGFloat y = self.topHeaderHeight + self.supplyHeaderHeight;
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
        CGRect frame = CGRectMake(0, 0, self.leftHeaderWidth, self.topHeaderHeight + self.supplyHeaderHeight);
        frame.origin = self.collectionView.contentOffset;
        if (self.supplyHeaderHeight > 0) {
            frame.origin.y = MAX(self.supplyHeaderHeight, frame.origin.y);
        }
        [tmpArr2 insertObject:[NSValue valueWithCGRect:frame] atIndex:0];
    }
    self.leftHeaderFrameArr = tmpArr2;
    
    // 计算上表头各单元格位置
    NSMutableArray *tmpArr3 = [NSMutableArray arrayWithCapacity:self.columnNumber + 1];
    for (NSInteger i = 0; i != self.columnNumber; ++i) {
        CGFloat y = self.collectionView.contentOffset.y;
        // 当上表头存在额外视图时，上表头相对浮动
        if (self.supplyHeaderHeight > 0) {
            y = MAX(self.collectionView.contentOffset.y, self.supplyHeaderHeight);
        }
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
        if (self.supplyHeaderHeight > 0) {
            frame.origin.y = MAX(self.supplyHeaderHeight, frame.origin.y);
        }
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
    
    CGFloat height = self.topHeaderHeight + self.supplyHeaderHeight;
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
    CGFloat y = self.topHeaderHeight + self.supplyHeaderHeight;
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
    attributes.zIndex = zIndexCell;
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    if ([elementKind isEqualToString:UICollectionElementKindTopHeader]) {
        attributes.frame = [self.topHeaderFrameArr[indexPath.item] CGRectValue];
        // 左上角算左表头时，左表头优先显示
        if (_leftTopHeaderIsLeft) {
            attributes.zIndex = zIndexHeadLeft;
        } else {
            attributes.zIndex = zIndexHeadTop;
            // 左上角优先级最高
            if (indexPath.item == 0) {
                attributes.zIndex = zIndexHeadTopLeft;
            }
        }
    } else if ([elementKind isEqualToString:UICollectionElementKindLeftHeader]) {
        attributes.frame = [self.leftHeaderFrameArr[indexPath.item] CGRectValue];
        if (_leftTopHeaderIsLeft) {
            attributes.zIndex = zIndexHeadTop;
            // 左上角优先级最高
            if (indexPath.item == 0) {
                attributes.zIndex = zIndexHeadTopLeft;
            }
        } else {
            attributes.zIndex = zIndexHeadLeft;
        }
    }  else if ([elementKind isEqualToString:UICollectionElementKindSupplyHeader]) {
        attributes.frame = CGRectMake(self.collectionView.contentOffset.x, 0, CGRectGetWidth(self.collectionView.frame), self.supplyHeaderHeight);
    } else {
        NSAssert(false, @"no such kind SupplementaryView");
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:elementKind withIndexPath:indexPath];
    if ([elementKind isEqualToString:UICollectionElementKindHorizonLine]) {
        // 取左表头已经算好的坐标
        NSInteger leftHeadIndex = indexPath.item;
        if (_leftTopHeaderIsLeft) {
            ++leftHeadIndex;
        }
        // 纵坐标是frame的下边y值
        CGRect leftHeadFrame = [self.leftHeaderFrameArr[leftHeadIndex] CGRectValue];
        CGFloat yPos = CGRectGetMaxY(leftHeadFrame);
        // 计算横坐标和宽度
        CGFloat xPos = self.collectionView.contentOffset.x + _leftHeaderWidth;
        CGFloat width = self.collectionView.frame.size.width - _leftHeaderWidth;
        if (_extendHorizonLine) {
            xPos = self.collectionView.contentOffset.x;
            width = self.collectionView.frame.size.width;
        }
        attributes.frame = CGRectMake(xPos, yPos, width, 0.5);
        attributes.zIndex = zIndexSeperateLine;
        // 上表头以上的水平线不显示。线的zIndex比表头的要大，会显示在表头以上，做个隐藏处理
        if (yPos < self.collectionView.contentOffset.y + _topHeaderHeight) {
            attributes.hidden = YES;
        }
    } else if ([elementKind isEqualToString:UICollectionElementKindVerticalLine]) {
        NSInteger topHeadIndex = indexPath.item;
        if (!_leftTopHeaderIsLeft) {
            ++topHeadIndex;
        }
        CGRect topHeadFrame = [self.topHeaderFrameArr[topHeadIndex] CGRectValue];
        CGFloat xPos = CGRectGetMaxX(topHeadFrame);
        CGFloat yPos = CGRectGetMaxY(topHeadFrame);
        if (_extendVerticalLine) {
            yPos = CGRectGetMinY(topHeadFrame);
        }
        CGFloat height = self.collectionView.frame.size.height + self.collectionView.contentOffset.y - yPos;
        attributes.frame = CGRectMake(xPos, yPos, 0.5, height);
        attributes.zIndex = zIndexSeperateLine;
        // 左表头左边的垂线不显示
        if (xPos < self.collectionView.contentOffset.x + _leftHeaderWidth) {
            attributes.hidden = YES;
        }
    } else {
        NSAssert(false, @"no such kind DecorationView");
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
    if (_supplyHeaderHeight > 0) {
        [attributes addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSupplyHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]];
    }

    if (_showHorizonLine) {
        // 最后一行不显示分割线
        for (NSInteger i = 0; i != _rowNumber - 1; ++i) {
            [attributes addObject:[self layoutAttributesForDecorationViewOfKind:UICollectionElementKindHorizonLine atIndexPath:[NSIndexPath indexPathForItem:i inSection:0]]];
        }
    }
    if (_showVerticalLine) {
        // 最后一列不显示分割线
        for (NSInteger j = 0; j != _columnNumber - 1; ++j) {
            [attributes addObject:[self layoutAttributesForDecorationViewOfKind:UICollectionElementKindVerticalLine atIndexPath:[NSIndexPath indexPathForItem:j inSection:0]]];
        }
    }

    return attributes;
}

@end

#pragma mark - separate line

@implementation DoubleGridHorizonLine

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

@end

@implementation DoubleGridVerticalLine

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

@end
