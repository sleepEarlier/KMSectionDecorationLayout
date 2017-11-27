//
//  KMSectionDecorationLayout.m
//  KMSectionDecorationLayout
//
//  Created by 林杜波 on 2017/11/24.
//  Copyright © 2017年 tanyang. All rights reserved.
//

#import "KMSectionDecorationLayout.h"

@implementation KMDecorationViewItem


- (instancetype)initWithName:(NSString *)name isXib:(BOOL)isXib bundle:(NSBundle *)bundle {
    if (self = [super init]) {
        _name = name;
        _isXib = isXib;
        _bundle = bundle;
    }
    return self;
}

+ (instancetype)itemWithClassName:(NSString *)clsName {
    KMDecorationViewItem *item = [[KMDecorationViewItem alloc] initWithName:clsName isXib:NO bundle:nil];
    return item;
}

+ (instancetype)itemWithXibName:(NSString *)xibName {
    return [self itemWithXibName:xibName bundle:nil];
}

+ (instancetype)itemWithXibName:(NSString *)xibName bundle:(NSBundle *)bundle {
    
    KMDecorationViewItem *item = [[KMDecorationViewItem alloc] initWithName:xibName isXib:YES bundle:bundle];
    return item;
}

@end

@interface KMSectionDecorationLayout()
@property (nonatomic, copy) NSArray<UICollectionViewLayoutAttributes *> * decorationViewAttrs;
@end

@implementation KMSectionDecorationLayout

- (void)prepareLayout {
    [super prepareLayout];
    [self registerAllItems];
    [self caculateDecorationLayoutAttributes];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *originAttrs = [super layoutAttributesForElementsInRect:rect].mutableCopy;
    [self.decorationViewAttrs enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(rect, obj.frame)) {
            [originAttrs addObject:obj];
        }
    }];
    return originAttrs.copy;
}

- (void)registerAllItems {
    [self.viewItems enumerateObjectsUsingBlock:^(KMDecorationViewItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.name.length > 0) {
            if (obj.isXib) {
                NSBundle *bundle = obj.bundle?:[NSBundle mainBundle];
                NSString *ext = [obj.name hasSuffix:@".xib"]?nil:@".xib";
                NSString *xibPath = [bundle pathForResource:obj.name ofType:ext];
                if (!xibPath) {
                    NSLog(@"%@: can not find xib with name \"%@\" in the bundle:%@.", NSStringFromClass(self.class), obj.name, bundle);
                }
                else {
                    [self registerNib:[UINib nibWithNibName:obj.name bundle:bundle] forDecorationViewOfKind:obj.name];
                }
            }
            else {
                Class cls = NSClassFromString(obj.name);
                if (!cls) {
                    NSLog(@"%@: can not find class with name \"%@\".", NSStringFromClass(self.class), obj.name);
                }
                else {
                    [self registerClass:cls forDecorationViewOfKind:obj.name];
                }
            }
        }
    }];
}

- (void)caculateDecorationLayoutAttributes {
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections > 0) {
        NSMutableArray *decorationViewsAttrs = [NSMutableArray arrayWithCapacity:numberOfSections];
        for (NSInteger section = 0; section < numberOfSections; section++) {
            NSString *elementKind = self.viewItems[section % self.viewItems.count].name;
            if (!(elementKind.length > 0)) {
                continue;
            }
            
            NSIndexPath *firstItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            
            UICollectionViewLayoutAttributes *decrationViewAttr = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:elementKind withIndexPath:firstItemIndexPath];
            decrationViewAttr.frame = [self decrationViewFrameForSection:section firstItemIndexPath:firstItemIndexPath];
            decrationViewAttr.zIndex = -1;
            [decorationViewsAttrs addObject:decrationViewAttr];
        }
        self.decorationViewAttrs = decorationViewsAttrs;
    }
}

- (CGRect)decrationViewFrameForSection:(NSInteger)section firstItemIndexPath:(NSIndexPath *)firstItemIndexPath {
    NSInteger sectionItemCount = [self.collectionView numberOfItemsInSection:section];
    
    UICollectionViewLayoutAttributes *firstItemAttr = [self layoutAttributesForItemAtIndexPath:firstItemIndexPath];
    UICollectionViewLayoutAttributes *lastItemAttr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:(sectionItemCount - 1) inSection:section]];
    
    CGRect firstItemFrame = firstItemAttr.frame;
    CGRect lastItemFrame = lastItemAttr.frame;
    
    CGRect decrationFrame = CGRectUnion(firstItemFrame, lastItemFrame);
    
    if (firstItemFrame.origin.x == lastItemFrame.origin.x && sectionItemCount >= 3) {
        // in case of last item is the first item in the row, need last two item to get the right RECT
        UICollectionViewLayoutAttributes *lastTwoItemAttr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:(sectionItemCount - 2) inSection:section]];
        decrationFrame = CGRectUnion(decrationFrame, lastTwoItemAttr.frame);
    }
    
    
    UIEdgeInsets insets = self.decrationEdgeInsets?self.decrationEdgeInsets(section):UIEdgeInsetsZero;
    if (!UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero)) {
        decrationFrame.origin.x -= insets.left;
        decrationFrame.origin.y -= insets.top;
        decrationFrame.size.width += (insets.left + insets.right);
        decrationFrame.size.height += (insets.top + insets.bottom);
    }
    
    return decrationFrame;
}

@end
