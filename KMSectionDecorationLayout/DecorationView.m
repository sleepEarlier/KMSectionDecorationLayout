//
//  DecorationView.m
//  KMSectionDecorationLayout
//
//  Created by 林杜波 on 2017/11/27.
//  Copyright © 2017年 林杜波. All rights reserved.
//

#import "DecorationView.h"

@implementation DecorationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.45 green:0.67 blue:0.22 alpha:0.5];
        self.layer.cornerRadius = 8.;
    }
    return self;
}

@end
