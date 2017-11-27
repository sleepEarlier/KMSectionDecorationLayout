//
//  ViewController.m
//  CollectionCellFrame
//
//  Created by 林杜波 on 2017/11/27.
//  Copyright © 2017年 林杜波. All rights reserved.
//

#import "ViewController.h"
#import "KMSectionDecorationLayout.h"
@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collect;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor redColor];
    
    //    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    //    KMDecorationViewItem *item =
    KMDecorationViewItem *item = [KMDecorationViewItem itemWithClassName:@"DecorationView"];
    KMSectionDecorationLayout *layout = [KMSectionDecorationLayout new];
    layout.viewItems = @[item];
    layout.minimumLineSpacing = 6;
    layout.minimumInteritemSpacing = 6.;
    layout.itemSize = CGSizeMake(100, 50);
    layout.sectionInset = UIEdgeInsetsMake(10, 20, 10, 20);
    layout.decrationEdgeInsets = ^UIEdgeInsets(NSInteger section) {
        return UIEdgeInsetsMake(2, 3, 2, 3);
    };
    
    self.collect = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collect.dataSource = self;
    self.collect.delegate = self;
    [self.collect registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.collect.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.collect];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 10;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    CGFloat blue = (arc4random() % 255) / 255.;
    CGFloat red = (arc4random() % 255) / 255.;
    CGFloat green = (arc4random() % 255) / 255.;
    cell.contentView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.75];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@--%@",indexPath, NSStringFromCGRect(cell.frame));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

