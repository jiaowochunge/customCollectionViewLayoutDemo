//
//  ViewController.swift
//  FloatFlexHeaderLayout
//
//  Created by john on 16/8/18.
//  Copyright © 2016年 taolv365.ios.recycle. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var collectionData: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = collectionView.collectionViewLayout as! FloatFlexCollectionViewLayout
        layout.headerReferenceSize = CGSizeMake(100, 100)
        layout.footerReferenceSize = CGSizeMake(70, 70)
        layout.floatHeaderRegion = CGRect(x: 30, y: 30, width: 50, height: 50)
        
        collectionView.registerNib(UINib(nibName: "FixSupplementaryHeadCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "head")
        collectionView.registerNib(UINib(nibName: "FixSupplementaryHeadCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "foot")
        collectionView.registerNib(UINib(nibName: "SupplyHeadCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeaderFloat, withReuseIdentifier: "supplementaryHead")
        collectionView.registerNib(UINib(nibName: "NormalCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "reuseIdentifier")
        collectionData = ["airport-icon.png", "beer-icon.png", "bicep-icon.png", "bike-icon.png", "birthday-icon.png", "bloody-mary-icon.png", "book-icon.png", "brunch-icon.png", "candy-cane-icon.png", "cat-icon.png", "chicken-leg-icon.png", "chinese-take-out-icon.png", "christmas-tree-icon.png", "clapper-icon.png", "coffee-icon.png", "coffee-2-icon.png", "cosmo-icon.png", "croissant-icon.png", "dog-icon.png", "dreidel-icon.png"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = collectionView.collectionViewLayout as! FloatFlexCollectionViewLayout
        
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 5, right: 15)
        // 每行3个
        let width = floor((collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing * 2) / 3)
        layout.itemSize = CGSizeMake(width, width)
        
        layout.invalidateLayout()
    }

}

extension ViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
{
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionData.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("reuseIdentifier", forIndexPath: indexPath) as! NormalCollectionViewCell
        
        cell.paint.image = UIImage(named: collectionData[indexPath.item])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeaderFloat {
            return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "supplementaryHead", forIndexPath: indexPath)
        } else if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "head", forIndexPath: indexPath) as! FixSupplementaryHeadCollectionReusableView
            
            view.text.text = "fixed header \(indexPath.section)"
            
            return view
        } else {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "foot", forIndexPath: indexPath) as! FixSupplementaryHeadCollectionReusableView
            
            view.text.text = "fixed footer \(indexPath.section)"
            
            return view
        }
    }

}

