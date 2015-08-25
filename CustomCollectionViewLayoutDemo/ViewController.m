//
//  ViewController.m
//  CustomCollectionViewLayoutDemo
//
//  Created by taolv on 15/8/13.
//  Copyright (c) 2015年 taolv365.ios.recycle. All rights reserved.
//

#import "ViewController.h"
#import "DoubleGridLayout.h"
#import "NumCollectionViewCell.h"
#import "NumCollectionReusableView.h"
#import "SepicalHeadCollectionReusableView.h"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegateDoubleGridLayout>

@property (nonatomic, strong) NSArray *collectionData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    DoubleGridLayout *layout = [[DoubleGridLayout alloc] init];
    layout.rowHeight = 30;
    layout.columnWidth = 50;
    layout.rowNumber = 30;
    layout.columnNumber = 10;
    layout.leftHeaderWidth = 80;
    layout.topHeaderHeight = 50;
    layout.supplyHeaderHeight = 40;
    layout.showHorizonLine = YES;
    layout.showVerticalLine = YES;
    
    NSMutableArray *tmpArr = [NSMutableArray arrayWithCapacity:300];
    for (int i = 0; i != 10; ++i) {
        for (int j = 0; j != 30; ++j) {
            [tmpArr addObject:[NSNumber numberWithInt:i * 30 + j]];
        }
    }
    self.collectionData = tmpArr;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[NumCollectionViewCell class] forCellWithReuseIdentifier:@"MY_CELL"];
    [collectionView registerClass:[NumCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindTopHeader withReuseIdentifier:@"TOP_HEAD"];
    [collectionView registerClass:[NumCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindLeftHeader withReuseIdentifier:@"LEFT_HEAD"];
    [collectionView registerNib:[UINib nibWithNibName:@"SepicalHeadCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSupplyHeader withReuseIdentifier:@"SUPPLY_HEAD"];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.directionalLockEnabled = YES;
    [self.view addSubview:collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return self.collectionData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    NumCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    
    NSNumber *num = _collectionData[indexPath.item];
    
    cell.numLabel.text = num.stringValue;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindTopHeader]) {
        NumCollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"TOP_HEAD" forIndexPath:indexPath];
        view.numLabel.text = [NSString stringWithFormat:@"top %ld", (long)indexPath.item];
        view.backgroundColor = [UIColor redColor];
        return view;
    } else if ([kind isEqualToString:UICollectionElementKindLeftHeader]) {
        NumCollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"LEFT_HEAD" forIndexPath:indexPath];
        view.numLabel.text = [NSString stringWithFormat:@"left %ld", (long)indexPath.item];
        view.backgroundColor = [UIColor greenColor];
        return view;
    } else {
        SepicalHeadCollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"SUPPLY_HEAD" forIndexPath:indexPath];
        view.label.text = @"hello, world";
        return view;
    }
}

@end
