//
//  VDViewController.m
//  2048iOS
//
//  Created by Vladimir Deriglazov on 27.07.14.
//  Copyright (c) 2014 Vladimir Deriglazov. All rights reserved.
//

#import "VDViewController.h"

#import "VDGameCore.h"
#import "VDBoardCell.h"
#import "VDPosition.h"


static NSString *const VDBoardCellReuseIdentifier = @"VDBoardCellReuseIdentifier";

@interface VDViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) VDGameCore *gameCore;

- (IBAction)swipeGesture:(UISwipeGestureRecognizer *)recognizer;

@end

@implementation VDViewController


- (VDGameCore *)gameCore
{
    if (_gameCore == nil)
    {
        _gameCore = [VDGameCore new];
    }
    return _gameCore;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.collectionView registerClass:[VDBoardCell class] forCellWithReuseIdentifier:VDBoardCellReuseIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGRect bounds = self.collectionView.bounds;
    layout.minimumLineSpacing = 1;
    layout.minimumInteritemSpacing = 1;
    NSUInteger numOfCols = [self.gameCore numberOfColumns];
    NSUInteger numOfRows = [self.gameCore numberOfRows];
    
    CGFloat itemWidth = floorf((CGRectGetWidth(bounds) - (numOfCols - 1) * layout.minimumInteritemSpacing) / numOfCols);
    CGFloat itemHeight = floorf((CGRectGetHeight(bounds) - (numOfRows - 1) * layout.minimumLineSpacing) / numOfRows);
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

- (IBAction)swipeGesture:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateRecognized)
        return;
    
    CGPoint distance = [recognizer translationInView:self.collectionView];
    VDMoveDirection moveDirection = VDMoveDirectionNone;
    if (fabs(distance.x) > fabs(distance.y))
    {
        moveDirection = (distance.x > 0) ? VDMoveDirectionRight : VDMoveDirectionLeft;
    }
    else
    {
        moveDirection = (distance.y > 0) ? VDMoveDirectionUp : VDMoveDirectionDown;
    }
    
    if ([self.gameCore canMoveToDirection:moveDirection])
    {
        NSDictionary *movedCells = nil;
        NSDictionary *mergedCells = nil;
        NSString *newPath = nil;
        [self.gameCore moveToDirection:moveDirection movedCells:&movedCells mergedCells:&mergedCells newValue:&newPath];

        [self.collectionView reloadData];
        
        NSMutableArray *indexPaths = [NSMutableArray new];
        [movedCells enumerateKeysAndObjectsUsingBlock:^(NSString *positionFrom, NSString *positionTo, BOOL *stop)
        {
            [indexPaths addObject:[self indexPathFromPositionStr:positionFrom]];
            [indexPaths addObject:[self indexPathFromPositionStr:positionTo]];
        }];
        
        NSMutableArray *mergedIndexPaths = [NSMutableArray arrayWithObject:[self indexPathFromPositionStr:newPath]];
        [mergedCells enumerateKeysAndObjectsUsingBlock:^(NSString *position, NSString *value, BOOL *stop)
         {
             [mergedIndexPaths addObject:[self indexPathFromPositionStr:position]];
         }];
        
        [self.collectionView performBatchUpdates:^
        {
            [self.collectionView reloadItemsAtIndexPaths:indexPaths];
        } completion:^(BOOL finished)
        {
            for (NSIndexPath *iPath in mergedIndexPaths)
            {
                VDBoardCell *cell = (VDBoardCell *)[self.collectionView cellForItemAtIndexPath:iPath];
                [cell makeNewValueAnimation];
            }
        }];
    }
}

- (NSIndexPath *)indexPathFromPositionStr:(NSString *)posStr
{
    VDPosition position = VDPositionFromString(posStr);
    NSIndexPath *result = [NSIndexPath indexPathForItem:position.row * [self.gameCore numberOfColumns] + position.column inSection:0];
    return result;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.gameCore numberOfColumns] * [self.gameCore numberOfRows];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VDBoardCell *cell = (VDBoardCell *)[collectionView dequeueReusableCellWithReuseIdentifier:VDBoardCellReuseIdentifier forIndexPath:indexPath];
    NSUInteger row = indexPath.item / [self.gameCore numberOfColumns];
    NSUInteger col = indexPath.item  - row * [self.gameCore numberOfColumns];
    cell.value = [self.gameCore valueAtRow:row column:col];
    return cell;
}

@end
