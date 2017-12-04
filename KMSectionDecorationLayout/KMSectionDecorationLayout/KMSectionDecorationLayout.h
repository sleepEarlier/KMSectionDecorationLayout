//
//  KMSectionDecorationLayout.h
//  KMSectionDecorationLayout
//
//  Created by 林杜波 on 2017/11/24.
//  Copyright © 2017年 KimiLin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// info for class or nib to regist
@interface KMDecorationViewItem : NSObject

/**
 Class name or nib name in section index order, layout register decorationView with the name as element kind.
 Use empty item, when use xib, set as "Example" or "Example.xib".
 */
@property (nonatomic, copy) NSString * name;

/// use xib or not
@property (nonatomic, assign) BOOL isXib;

/// xib bundle, default nil represent main bundle
@property (nonatomic, strong) NSBundle * bundle;

/// use this to skip a decoration view in section
+ (instancetype)emptyItem;

+ (instancetype)itemWithClassName:(NSString *)clsName;

+ (instancetype)itemWithXibName:(NSString *)xibName;

+ (instancetype)itemWithXibName:(NSString *)xibName bundle:(nullable NSBundle *)bundle;

- (instancetype)initWithName:(NSString *)name isXib:(BOOL)isXib bundle:(nullable NSBundle *)bundle NS_DESIGNATED_INITIALIZER;

@end


typedef UIEdgeInsets(^DecorationExtendEdges)(NSInteger section);

@interface KMSectionDecorationLayout : UICollectionViewFlowLayout

/// items for class/xib to regist. If you has one kind of decrationView for all section, you can use one item represent all same items
/// if you dont want decorationView in section, an [KMDecorationViewItem emptyItem] is needed
@property (nonatomic, copy) NSArray<KMDecorationViewItem *> * __nullable viewItems;

/// optional config for each decrationView's extend layout
/// eg. return UIEdgeInsets(5,10,5,10), decoration view will extend it's area by 5(left and right), 10(top and bottom)
@property (nonatomic, copy) DecorationExtendEdges decorationExtendEdges;

/// by default section header's width(height if scroll horizonal) will be equal to collectionView's width, set this to true will make header's width equal to decrationView's width
@property (nonatomic, assign) BOOL adjustHeaderLayout;

@end
NS_ASSUME_NONNULL_END
