//
//  KMSectionDecorationLayout.h
//  KMSectionDecorationLayout
//
//  Created by 林杜波 on 2017/11/24.
//  Copyright © 2017年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// info for class or nib to regist
@interface KMDecorationViewItem : NSObject


/**
 Class name or nib name in section index order, layout register decorationView with the name as element kind.
 Use empty string @"" or nil to skip some section, when use xib, set as "Example" or "Example.xib".
 */
@property (nonatomic, copy) NSString * name;

/// use xib or not
@property (nonatomic, assign) BOOL isXib;

/// xib bundle, default nil represent main bundle
@property (nonatomic, strong) NSBundle * bundle;

+ (instancetype)itemWithClassName:(NSString *)clsName;

+ (instancetype)itemWithXibName:(NSString *)xibName;

+ (instancetype)itemWithXibName:(NSString *)xibName bundle:(nullable NSBundle *)bundle;

- (instancetype)initWithName:(NSString *)name isXib:(BOOL)isXib bundle:(nullable NSBundle *)bundle NS_DESIGNATED_INITIALIZER;

@end

typedef UIEdgeInsets(^DecrationViewEdgeInsets)(NSInteger section);

@interface KMSectionDecorationLayout : UICollectionViewFlowLayout

/// items for class/xib to regist. If you has one kind of decrationView for all section, you can use one item represent all same items
@property (nonatomic, copy) NSArray<KMDecorationViewItem *> * __nullable viewItems;

/// optional config for each decrationView's edge insets
@property (nonatomic, copy) DecrationViewEdgeInsets decrationEdgeInsets;

@end
NS_ASSUME_NONNULL_END
