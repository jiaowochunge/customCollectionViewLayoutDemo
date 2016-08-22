//
//  FloatFlexCollectionViewLayout.swift
//  CustomCollectionViewLayoutDemo
//
//  Created by john on 16/8/18.
//  Copyright © 2016年 taolv365.ios.recycle. All rights reserved.
//

import UIKit

/**
 *  定义浮动头部参数
 *	TODO: not implemented yet
 */
@objc protocol UICollectionViewDelegateFloatFlex: UICollectionViewDelegateFlowLayout {

    /**
     浮动头部高度伸缩区间。覆盖 floatHeaderRegion
     
     - parameter collectionView:		The collection view object displaying the flow layout.
     - parameter collectionViewLayout:	The layout object requesting the information.
     - parameter section:				The index of the section whose header rect is being requested
     
     - returns: The float region of the header
     */
    optional func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceFloatRegionForHeaderInSection section: Int) -> CGRect

}

/// 浮动头部，demo效果是，如果添加一个 UICollectionElementKindSectionHeader 代表的头部，该浮动头部在 UICollectionElementKindSectionHeader 以下
let UICollectionElementKindSectionHeaderFloat = "UICollectionElementKindSectionFloatHeader"

/** 具有一个浮动的头部，头部高度可伸缩。这个demo演示浮动效果，为了使表格丰富些，继承经典的流布局。
 *
 *  布局思路说明
 *  本布局演示添加一个浮动、高度可伸缩的头部。演示效果是，`UICollectionViewFlowLayout`本身所具有的`UICollectionElementKindSectionHeader`代表的头部是固定位置。我们添加的浮动头部在这个固定头部以下，cell之上。
 *  浮动头部具有一个最大高度和最小高度，由`floatHeaderRegion`决定。目前只是个demo，没有添加代理方法来控制不同的section高度。contentSize由super方法计算，直接加上浮动头部最大高度。cell的frame由super方法计算，y直接加上浮动头部高度
 *  上面的处理之后，`UICollectionViewFlowLayout`继承的UI满足需求。下面是浮动&伸缩处理
 *  浮动的处理，目前并不支持多个section，没有进行计算。浮动，要求总是invalidateLayout，好重新计算frame。frame的y(x)值保持与collectionView的contentOffset的y(x)保持一致即可。
 *  伸缩的处理。浮动头部占据的区域总是最大的伸缩范围，这样方便计算contentSize和cell的frame。所以其实当浮动头部收缩时，contentView其实会有一部分空白。这样处理，对于计算很多frame都很方便。如果在伸缩过程中，改变contentSize，保持contentView没有空白，将会导致计算量剧增。
 */
class FloatFlexCollectionViewLayout: UICollectionViewFlowLayout {

    /// 浮动头部高度伸缩区间。当滚动方向为垂直方向时，`y`表示最小高度，`y + height`表示最大高度。宽度与`collectionView`一致
    var floatHeaderRegion: CGRect = CGRectZero
    
    /// 缓存
    private var sectionNum: Int = 1

}

extension FloatFlexCollectionViewLayout {
    
    override func prepareLayout() {
        super.prepareLayout()
        
        guard let dataSource = self.collectionView?.dataSource else {
            fatalError()
        }
        
        if let num = dataSource.numberOfSectionsInCollectionView?(self.collectionView!) {
            sectionNum = num
        }

    }

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func collectionViewContentSize() -> CGSize {
        var size = super.collectionViewContentSize()
        
        // 添加浮动头部高度
        if self.scrollDirection == .Vertical {
            for _ in 0 ..< sectionNum {
                size.height += CGRectGetMaxY(floatHeaderRegion)
            }
        } else {
            for _ in 0 ..< sectionNum {
                size.width += CGRectGetMaxX(floatHeaderRegion)
            }
        }
        
        return size
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        // 使用copy方法。http://stackoverflow.com/questions/31508153/warning-uicollectionviewflowlayout-has-cached-frame-mismatch-for-index-path-ab
        if let super_attributes = super.layoutAttributesForItemAtIndexPath(indexPath) {
            let attributes = super_attributes.copy() as! UICollectionViewLayoutAttributes
            
            var frame = attributes.frame
            if self.scrollDirection == .Vertical {
                frame.origin.y += CGRectGetMaxY(floatHeaderRegion) * CGFloat(indexPath.section + 1)
            } else {
                frame.origin.x += CGRectGetMaxX(floatHeaderRegion) * CGFloat(indexPath.section + 1)
            }
            attributes.frame = frame
            
            return attributes
        } else {
            return nil
        }
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionElementKindSectionHeaderFloat {
            // 自己算不好算，让父类去算吧
            guard let head_attributes = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath), let foot_attributes = layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionFooter, atIndexPath: indexPath) else {
                return nil
            }
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)

            // 计算frame
            if self.scrollDirection == .Vertical {
                // 固定头部依然可见
                if self.collectionView!.contentOffset.y < CGRectGetMaxY(head_attributes.frame) {
                    attributes.frame = CGRect(x: 0, y: CGRectGetMaxY(head_attributes.frame), width: self.collectionView!.frame.width, height: CGRectGetMaxY(floatHeaderRegion))
                }
                // 这个section将消失，这时浮动头部固定位置，随着collectionView滑动一起消失
                else if self.collectionView!.contentOffset.y > CGRectGetMaxY(foot_attributes.frame) - floatHeaderRegion.origin.y {
                    attributes.frame = CGRect(x: 0, y: CGRectGetMaxY(foot_attributes.frame) - floatHeaderRegion.origin.y, width: self.collectionView!.frame.width, height: floatHeaderRegion.origin.y)
                }
                // 最小尺寸浮动
                else if self.collectionView!.contentOffset.y > CGRectGetMaxY(head_attributes.frame) + CGRectGetMaxY(floatHeaderRegion) {
                    attributes.frame = CGRect(x: 0, y: self.collectionView!.contentOffset.y, width: self.collectionView!.frame.width, height: floatHeaderRegion.origin.y)
                }
                // 可变尺寸浮动
                else {
                    let deltaY = self.collectionView!.contentOffset.y - CGRectGetMaxY(head_attributes.frame)
                    attributes.frame = CGRect(x: 0, y: self.collectionView!.contentOffset.y, width: self.collectionView!.frame.width, height: max(CGRectGetMinY(floatHeaderRegion), CGRectGetMaxY(floatHeaderRegion) - deltaY))
                }
            } else {
                // 固定头部依然可见
                if self.collectionView!.contentOffset.x < CGRectGetMaxX(head_attributes.frame) {
                    attributes.frame = CGRect(x: CGRectGetMaxX(head_attributes.frame), y: 0, width: CGRectGetMaxX(floatHeaderRegion), height: self.collectionView!.frame.height)
                }
                // 这个section将消失，这时浮动头部固定位置，随着collectionView滑动一起消失
                else if self.collectionView!.contentOffset.x > CGRectGetMaxX(foot_attributes.frame) - floatHeaderRegion.origin.x {
                    attributes.frame = CGRect(x: CGRectGetMaxX(foot_attributes.frame) - floatHeaderRegion.origin.x, y: 0, width: floatHeaderRegion.origin.x, height: self.collectionView!.frame.height)
                }
                // 最小尺寸浮动
                else if self.collectionView!.contentOffset.x > CGRectGetMaxX(head_attributes.frame) + CGRectGetMaxX(floatHeaderRegion) {
                    attributes.frame = CGRect(x: self.collectionView!.contentOffset.x, y: 0, width: floatHeaderRegion.origin.x, height: self.collectionView!.frame.height)
                }
                // 可变尺寸浮动
                else {
                    let deltaX = self.collectionView!.contentOffset.x - CGRectGetMaxX(head_attributes.frame)
                    attributes.frame = CGRect(x: self.collectionView!.contentOffset.x, y: 0, width: max(CGRectGetMaxX(floatHeaderRegion) - deltaX, CGRectGetMinX(floatHeaderRegion)), height: self.collectionView!.frame.height)
                }
            }
            
            attributes.zIndex = head_attributes.zIndex + 1
            
            return attributes
        } else if elementKind == UICollectionElementKindSectionHeader {
            // 第0个section不用处理，第n个section需要加额外的(n-1)*CGRectGetMaxY(floatHeaderRegion)高度

            if indexPath.section == 0 {
                // 这个地方不能直接 return super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath)。否则会返回一个nil，导致浮动头部无法根据这个header的相关属性计算。
                if let super_attributes = super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath) {
                    return super_attributes
                } else {
                    let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
                    attributes.frame = CGRectZero
                    // 为什么是10，我也不知道。debug打印日志得到的
                    attributes.zIndex = 10
                    return attributes
                }
            } else {
                if let super_attributes = super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath) {
                    let attributes = super_attributes.copy() as! UICollectionViewLayoutAttributes
                    
                    var frame = attributes.frame
                    if self.scrollDirection == .Vertical {
                        frame.origin.y += CGRectGetMaxY(floatHeaderRegion) * CGFloat(indexPath.section)
                    } else {
                        frame.origin.x += CGRectGetMaxX(floatHeaderRegion) * CGFloat(indexPath.section)
                    }
                    attributes.frame = frame
                    
                    return attributes
                } else {
                    let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
                    attributes.frame = CGRectZero
                    // 为什么是10，我也不知道。debug打印日志得到的
                    attributes.zIndex = 10
                    return attributes
                }
            }
        } else if elementKind == UICollectionElementKindSectionFooter {
            if let super_attributes = super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath) {
                let attributes = super_attributes.copy() as! UICollectionViewLayoutAttributes
                
                var frame = attributes.frame
                if self.scrollDirection == .Vertical {
                    frame.origin.y += CGRectGetMaxY(floatHeaderRegion) * CGFloat(indexPath.section + 1)
                } else {
                    frame.origin.x += CGRectGetMaxX(floatHeaderRegion) * CGFloat(indexPath.section + 1)
                }
                attributes.frame = frame
                
                return attributes
            } else {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
                if self.scrollDirection == .Vertical {
                    attributes.frame = CGRect(x: 0, y: CGFloat.max, width: 0, height: 0)
                } else {
                    attributes.frame = CGRect(x: CGFloat.max, y: 0, width: 0, height: 0)
                }
                // 为什么是10，我也不知道。debug打印日志得到的
                attributes.zIndex = 10
                return attributes
            }
        } else {
            // this is impossible. we can assert but we dont.
            return nil
        }
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributesArr: [UICollectionViewLayoutAttributes] = []
        // 调用父方法，获得显示项。纠正显示项属性
        if let super_attributesArr = super.layoutAttributesForElementsInRect(rect) {
            for super_attributes in super_attributesArr {
                switch super_attributes.representedElementCategory {
                case .Cell:
                    if let attributes = layoutAttributesForItemAtIndexPath(super_attributes.indexPath) {
                        attributesArr.append(attributes)
                    }
                case .SupplementaryView:
                    if let attributes = layoutAttributesForSupplementaryViewOfKind(super_attributes.representedElementKind!, atIndexPath: super_attributes.indexPath) {
                        attributesArr.append(attributes)
                    }
                default:
                    break
                }
            }
        }
        // 添加浮动头部
        for i in 0 ..< sectionNum {
            if let attributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeaderFloat, atIndexPath: NSIndexPath(forItem: 0, inSection: i)) where CGRectIntersectsRect(rect, attributes.frame) {
                attributesArr.append(attributes)
            }
        }
        
        return attributesArr
    }
}
