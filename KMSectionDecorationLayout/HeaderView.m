//
//  HeaderView.m
//  KMSectionDecorationLayout
//
//  Created by 林杜波 on 2017/11/28.
//  Copyright © 2017年 林杜波. All rights reserved.
//

#import "HeaderView.h"

@interface HeaderView()
@property (nonatomic, strong) UILabel *label;
@end

@implementation HeaderView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        [self addSubview:_label];
        _label.text = @"Header";
        self.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5];
        self.layer.borderWidth = 1. / [UIScreen mainScreen].scale;
        self.layer.borderColor = [UIColor blackColor].CGColor;
    }
    return self;
}
@end
