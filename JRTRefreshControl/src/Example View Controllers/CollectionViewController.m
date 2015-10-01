//
//  CollectionViewController.m
//  RefreshControl
//
//  Created by Joride on 04/09/15.
//  Copyright (c) 2015 KerrelInc. All rights reserved.
//

#import "CollectionViewController.h"
#import "UIColor+Additions.h"
#import "JRTEqualizerRefreshingView.h"


NSString * const kCollectionViewCellID = @"collectionViewCellID";

@interface CollectionViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView * collectionView;
@property (nonatomic, readonly) NSMutableDictionary * colorsByIndexPath;
@end


@implementation CollectionViewController
-(UIScrollView *)scrollView
{
    return self.collectionView;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerClass: [UICollectionViewCell class]
            forCellWithReuseIdentifier: kCollectionViewCellID];
}
- (CGFloat ) relativeChangeOffset
{
    return 0.5f;
}
- (CGFloat ) relativeChangeRate
{
    return 4.0f;
}

#pragma mark -
@synthesize colorsByIndexPath = _colorsByIndexPath;
-(NSMutableDictionary *)colorsByIndexPath
{
    if (nil == _colorsByIndexPath)
    {
        _colorsByIndexPath = [[NSMutableDictionary alloc] init];
    }
    return _colorsByIndexPath;
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return 200;
}
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView
                   cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewCellID
                                                     forIndexPath: indexPath];
    
    [self configureCell: cell atIndexPath: indexPath];
    
    return cell;
}

#pragma mark -
- (void) configureCell: (UICollectionViewCell*) cell
           atIndexPath: (NSIndexPath *) indexPath
{
    UIColor * color = self.colorsByIndexPath[indexPath];
    if (nil == color)
    {
        color = [UIColor randomColor];
        self.colorsByIndexPath[indexPath] = color;
    }
    
    cell.contentView.backgroundColor = color;
}
-(Class)refreshControlViewClass
{
    return [JRTEqualizerRefreshingView class];
}
@end


























