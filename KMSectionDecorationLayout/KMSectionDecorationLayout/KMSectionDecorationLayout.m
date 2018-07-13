//
//  KMSectionDecorationLayout.m
//  KMSectionDecorationLayout
//
//  Created by 林杜波 on 2017/11/24.
//  Copyright © 2017年 KimiLin. All rights reserved.
//

#import "KMSectionDecorationLayout.h"

@implementation KMDecorationViewItem

- (instancetype)init
{
    if (self = [self initWithName:@"" isXib:NO bundle:nil]) {}
    return self;
}

- (instancetype)initWithName:(NSString *)name isXib:(BOOL)isXib bundle:(NSBundle *)bundle {
    if (self = [super init]) {
        _name = name;
        _isXib = isXib;
        _bundle = bundle;
    }
    return self;
}

+ (instancetype)emptyItem {
    return [self itemWithClassName:@""];
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

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attrs = [super layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader] && self.adjustHeaderLayout) {
        UIEdgeInsets sectionInsets = UIEdgeInsetsZero;
        if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            sectionInsets = [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:indexPath.section];
        }
        else {
            sectionInsets = self.sectionInset;
        }
        CGRect frame = attrs.frame;
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            frame.origin.x = sectionInsets.left;
            frame.size.width -= (sectionInsets.left + sectionInsets.right);
        } else {
            
        }
        
    }
    return attrs;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<UICollectionViewLayoutAttributes *> *originAttrs = [super layoutAttributesForElementsInRect:rect];
    if (self.adjustHeaderLayout) {
        
        // if use NSEnumerationConcurrent, get main thread warning: Main Thread Checker: UI API called on a background thread: -[UIScrollView delegate]
        [originAttrs enumerateObjectsWithOptions:0 usingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
                
                // get section insets
                UIEdgeInsets sectionInsets = UIEdgeInsetsZero;
                if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
                    sectionInsets = [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:obj.indexPath.section];
                }
                else {
                    sectionInsets = self.sectionInset;
                }
                
                // get extend insets
                UIEdgeInsets decorationInsets = self.decorationExtendEdges?self.decorationExtendEdges(obj.indexPath.section):UIEdgeInsetsZero;
                
                CGRect frame = obj.frame;
                if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
                    frame.origin.x += (sectionInsets.left - decorationInsets.left);
                    frame.size.width -= (sectionInsets.left + sectionInsets.right - decorationInsets.left - decorationInsets.right);
                } else {
                    frame.origin.y += (sectionInsets.top - decorationInsets.top);
                    frame.size.height -= (sectionInsets.top + sectionInsets.bottom - decorationInsets.top - sectionInsets.bottom);
                }
                obj.frame = frame;
            }
        }];
    }
    
    NSMutableArray *mut_originAttrs = originAttrs.mutableCopy;
    [mut_originAttrs addObjectsFromArray:self.decorationViewAttrs];
    
    return mut_originAttrs.copy;
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
            decrationViewAttr.frame = [self decrationViewFrameForSection:section];
            decrationViewAttr.zIndex = -1;
            [decorationViewsAttrs addObject:decrationViewAttr];
        }
        self.decorationViewAttrs = decorationViewsAttrs;
    }
}

- (CGRect)decrationViewFrameForSection:(NSInteger)section {
    CGRect decrationFrame = CGRectZero;
    
    NSInteger sectionItemCount = [self.collectionView numberOfItemsInSection:section];
    if (sectionItemCount == 0) {
        return decrationFrame;
    }
    
    UICollectionViewLayoutAttributes *firstItemAttr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
    UICollectionViewLayoutAttributes *lastItemAttr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:(sectionItemCount - 1) inSection:section]];
    
    CGRect firstItemFrame = firstItemAttr.frame;
    CGRect lastItemFrame = lastItemAttr.frame;
    
    UIEdgeInsets sectionInsets = UIEdgeInsetsZero;
    if ([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        sectionInsets = [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    }
    else {
        sectionInsets = self.sectionInset;
    }

    
    decrationFrame.origin.x = firstItemFrame.origin.x;
    decrationFrame.origin.y = firstItemFrame.origin.y;
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        decrationFrame.size.height = CGRectGetMaxY(lastItemFrame) - firstItemFrame.origin.y;
        decrationFrame.size.width = CGRectGetWidth(self.collectionView.bounds) - sectionInsets.left - sectionInsets.right;
    } else {
        decrationFrame.size.height = CGRectGetHeight(self.collectionView.bounds) - sectionInsets.top - sectionInsets.bottom;
        decrationFrame.size.width = CGRectGetMaxX(lastItemFrame) - firstItemFrame.origin.x;
    }
    
    
    UIEdgeInsets insets = self.decorationExtendEdges?self.decorationExtendEdges(section):UIEdgeInsetsZero;
    if (!UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero)) {
        decrationFrame.origin.x -= insets.left;
        decrationFrame.origin.y -= insets.top;
        decrationFrame.size.width += (insets.left + insets.right);
        decrationFrame.size.height += (insets.top + insets.bottom);
    }
    
    return decrationFrame;
}

@end
