//
//  NumCollectionReusableView.m
//  CircleLayout
//
//  Created by taolv on 15/8/12.
//  Copyright (c) 2015年 Olivier Gutknecht. All rights reserved.
//

#import "NumCollectionReusableView.h"

@implementation NumCollectionReusableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.numLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.textColor = [UIColor whiteColor];
        [self addSubview:_numLabel];
    }
    return self;
}

@end
