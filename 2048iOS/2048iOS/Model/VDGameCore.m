//
//  VDGameCore.m
//  2048Mac
//
//  Created by Vladimir Deriglazov on 05.07.14.
//  Copyright (c) 2014 Vladimir Deriglazov. All rights reserved.
//

#import "VDGameCore.h"

#import "VDGameData.h"


@interface VDGameCore ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation VDGameCore

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator == nil)
    {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext == nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel == nil)
    {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"VDGameData" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
    }
    return _managedObjectModel;
}

//- (id)initWithDocument:(VDDocument *)document
- (id)init
{
    self = [super init];
    if (self)
    {
        VDGameData *gameData = [NSEntityDescription insertNewObjectForEntityForName:@"VDGameData" inManagedObjectContext:self.managedObjectContext];
        self.data = gameData;
    }
    return self;
}

- (NSUInteger)numberOfRows
{
    return VDBoardSize;
}

- (NSUInteger)numberOfColumns
{
    return VDBoardSize;
}

- (NSUInteger)valueAtRow:(NSUInteger)row column:(NSUInteger)column
{
    return [self.data valueAtBoardCellRow:row column:column];
}

- (NSUInteger)score
{
    return [self.data.score integerValue];
}

#pragma mark - Move

- (BOOL)canMoveToDirection:(VDMoveDirection)direction
{
    for (NSUInteger row = 0; row < [self numberOfRows]; row++)
    {
        for (NSUInteger col = 0; col < [self numberOfColumns]; col++)
        {
            if ([self valueAtRow:row column:col] > 0 && [self canMoveCellAtRow:row column:col toDirection:direction])
            {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)canMoveCellAtRow:(NSUInteger)row column:(NSUInteger)col toDirection:(VDMoveDirection)direction
{
    BOOL result = NO;
    NSUInteger value = [self valueAtRow:row column:col];
    switch (direction)
    {
        case VDMoveDirectionLeft:
            do
            {
                if (col == 0)
                    break;
                
                if ([self valueAtRow:row column:col - 1] == value)
                {
                    result = YES;
                    break;
                }
                for (NSUInteger curCol = 0; curCol < col; curCol++)
                {
                    if ([self valueAtRow:row column:curCol] == 0)
                    {
                        result = YES;
                        break;
                    }
                }
            } while (NO);
            break;
            
        case VDMoveDirectionRight:
            do
            {
                if (col == [self numberOfColumns] - 1)
                    break;
                
                if ([self valueAtRow:row column:col + 1] == value)
                {
                    result = YES;
                    break;
                }
                for (NSUInteger curCol = col + 1; curCol < [self numberOfColumns]; curCol++)
                {
                    if ([self valueAtRow:row column:curCol] == 0)
                    {
                        result = YES;
                        break;
                    }
                }
            } while (NO);
            break;
            
        case VDMoveDirectionDown:
            do
            {
                if (row == 0)
                    break;
                
                if ([self valueAtRow:row - 1 column:col] == value)
                {
                    result = YES;
                    break;
                }
                for (NSUInteger curRow = 0; curRow < row; curRow++)
                {
                    if ([self valueAtRow:curRow column:col] == 0)
                    {
                        result = YES;
                        break;
                    }
                }
            } while (NO);
            break;
            
        case VDMoveDirectionUp:
            do
            {
                if (row == [self numberOfRows] - 1)
                    break;
                
                if ([self valueAtRow:row + 1 column:col] == value)
                {
                    result = YES;
                    break;
                }
                for (NSUInteger curRow = row + 1; curRow < [self numberOfRows]; curRow++)
                {
                    if ([self valueAtRow:curRow column:col] == 0)
                    {
                        result = YES;
                        break;
                    }
                }
            } while (NO);
            break;
        default:
            return NO;
            break;
    }
    return result;
}


- (BOOL)moveToDirection:(VDMoveDirection)direction movedCells:(NSDictionary **)movedCells mergedCells:(NSDictionary **)mergedCells newValue:(NSString **)newValuePath //if return no - gameOver
{
    NSDictionary *movedDictionary = nil;
    switch (direction)
    {
        case VDMoveDirectionLeft:
            movedDictionary = [self moveAllValuesToLeftMergedCells:mergedCells];
            break;
            
        case VDMoveDirectionRight:
            movedDictionary = [self moveAllValuesToRightMergedCells:mergedCells];
            break;
            
        case VDMoveDirectionUp:
            movedDictionary = [self moveAllValuesToUpMergedCells:mergedCells];
            break;
            
        case VDMoveDirectionDown:
            movedDictionary = [self moveAllValuesToDownMergedCells:mergedCells];
            break;
        default:
            return NO;
            break;
    }
    
    NSLog(@"after move. %@", self.data.boardData);
    
    if (movedCells != NULL)
    {
        *movedCells = movedDictionary;
    }
    
    NSString *newPath = [self.data addRandomValue];
    if (newValuePath != NULL)
    {
        *newValuePath = newPath;
    }
    
    BOOL result = [self canMoveToDirection:VDMoveDirectionLeft] || [self canMoveToDirection:VDMoveDirectionRight] || [self canMoveToDirection:VDMoveDirectionUp] || [self canMoveToDirection:VDMoveDirectionDown];
    return result;
}

- (NSDictionary *)moveAllValuesToLeftMergedCells:(NSDictionary **)mergedCells
{
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSMutableDictionary *mergedDictionary = [NSMutableDictionary new];
    
    NSLog(@"moveAllValuesToLeft. %@", self.data.boardData);
    for (NSUInteger row = 0; row < [self numberOfRows]; row++)
    {
        NSMutableSet *mergedCols = [NSMutableSet new];
        for (NSUInteger col = 1; col < [self numberOfColumns]; col++)
        {
            NSUInteger value = [self valueAtRow:row column:col];
            if (value == 0)
            {
                continue;
            }
            
            NSUInteger colToMove = col;
            for (NSInteger curCol = col - 1; curCol >= 0; curCol--)
            {
                if (![mergedCols containsObject:@(curCol)] && [self valueAtRow:row column:curCol] == value)
                {
                    [self.data setValue:2 * value atBoardCellRow:row column:curCol];
                    [self.data setValue:0 atBoardCellRow:row column:col];
                    [mergedCols addObject:@(curCol)];
                    colToMove = col;
                    
//                    NSLog(@"row = %lu, col = %lu merged with curCol = %lu value = %lu", row, col, curCol, 2*value);
                    
                    result[[VDGameData encodeRow:row column:col]] = [VDGameData encodeRow:row column:curCol];
                    mergedDictionary[[VDGameData encodeRow:row column:curCol]] = @(2 * value);
                    
                    break;
                }
                if ([self valueAtRow:row column:curCol] == 0)
                {
                    colToMove = curCol;
                }
                else
                {
                    break;
                }
            }
            if (colToMove != col)
            {
//                NSLog(@"row = %lu, col = %lu move to coltomove = %lu", row, col, colToMove);
                [self.data setValue:value atBoardCellRow:row column:colToMove];
                [self.data setValue:0 atBoardCellRow:row column:col];
                
                result[[VDGameData encodeRow:row column:col]] = [VDGameData encodeRow:row column:colToMove];
            }
        }
    }
    
    if (mergedCells != NULL)
    {
        *mergedCells = mergedDictionary;
    }
    
    return result;
}

- (NSDictionary *)moveAllValuesToRightMergedCells:(NSDictionary **)mergedCells
{
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSMutableDictionary *mergedDictionary = [NSMutableDictionary new];
    
    NSLog(@"moveAllValuesToRight. %@", self.data.boardData);
    for (NSUInteger row = 0; row < [self numberOfRows]; row++)
    {
        NSMutableSet *mergedCols = [NSMutableSet new];
        for (NSInteger col = [self numberOfColumns] - 2; col >= 0; col--)
        {
            NSUInteger value = [self valueAtRow:row column:col];
            if (value == 0)
            {
                continue;
            }
            
            NSUInteger colToMove = col;
            for (NSInteger curCol = col + 1; curCol < [self numberOfColumns]; curCol++)
            {
                NSUInteger curValue = [self valueAtRow:row column:curCol];
                if (![mergedCols containsObject:@(curCol)] && curValue == value)
                {
                    [self.data setValue:2 * value atBoardCellRow:row column:curCol];
                    [self.data setValue:0 atBoardCellRow:row column:col];
                    [mergedCols addObject:@(curCol)];
                    colToMove = col;
                    
//                    NSLog(@"row = %lu, col = %lu merged with curCol = %lu value = %lu", row, col, curCol, 2*value);
                    
                    result[[VDGameData encodeRow:row column:col]] = [VDGameData encodeRow:row column:curCol];
                    mergedDictionary[[VDGameData encodeRow:row column:curCol]] = @(2 * value);
                    
                    break;
                }
                if (curValue == 0)
                {
                    colToMove = curCol;
                }
                else
                {
                    break;
                }
            }
            if (colToMove != col)
            {
//                NSLog(@"row = %lu, col = %lu move to coltomove = %lu", row, col, colToMove);
                
                [self.data setValue:value atBoardCellRow:row column:colToMove];
                [self.data setValue:0 atBoardCellRow:row column:col];
                
                result[[VDGameData encodeRow:row column:col]] = [VDGameData encodeRow:row column:colToMove];
            }
        }
    }
    
    if (mergedCells != NULL)
    {
        *mergedCells = mergedDictionary;
    }
    
    return result;
}

- (NSDictionary *)moveAllValuesToDownMergedCells:(NSDictionary **)mergedCells
{
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSMutableDictionary *mergedDictionary = [NSMutableDictionary new];
    
    NSLog(@"moveAllValuesToDown. %@", self.data.boardData);
    for (NSInteger col = 0; col < [self numberOfColumns]; col++)
    {
        NSMutableSet *mergedRows = [NSMutableSet new];
        for (NSUInteger row = 1; row < [self numberOfRows]; row++)
        {
            NSUInteger value = [self valueAtRow:row column:col];
            if (value == 0)
            {
                continue;
            }
            
            NSUInteger rowToMove = row;
            for (NSInteger curRow = row - 1; curRow >= 0; curRow--)
            {
                NSUInteger curValue = [self valueAtRow:curRow column:col];
                if (![mergedRows containsObject:@(curRow)] && curValue == value)
                {
                    [self.data setValue:2 * value atBoardCellRow:curRow column:col];
                    [self.data setValue:0 atBoardCellRow:row column:col];
                    [mergedRows addObject:@(curRow)];
                    rowToMove = row;
                    
//                    NSLog(@"row = %lu, col = %lu merged with curRow = %lu value = %lu", row, col, curRow, 2*value);
                    
                    result[[VDGameData encodeRow:row column:col]] = [VDGameData encodeRow:curRow column:col];
                    mergedDictionary[[VDGameData encodeRow:curRow column:col]] = @(2 * value);
                    
                    break;
                }
                if (curValue == 0)
                {
                    rowToMove = curRow;
                }
                else
                {
                    break;
                }
            }
            if (rowToMove != row)
            {
//                NSLog(@"row = %lu, col = %lu move to rowToMove = %lu", row, col, rowToMove);
                
                [self.data setValue:value atBoardCellRow:rowToMove column:col];
                [self.data setValue:0 atBoardCellRow:row column:col];
                
                result[[VDGameData encodeRow:row column:col]] = [VDGameData encodeRow:rowToMove column:col];
            }
        }
    }
    
    if (mergedCells != NULL)
    {
        *mergedCells = mergedDictionary;
    }
    
    return result;
}

- (NSDictionary *)moveAllValuesToUpMergedCells:(NSDictionary **)mergedCells
{
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSMutableDictionary *mergedDictionary = [NSMutableDictionary new];
    
    NSLog(@"moveAllValuesToUp. %@", self.data.boardData);
    
    for (NSInteger col = 0; col < [self numberOfColumns]; col++)
    {
        NSMutableSet *mergedRows = [NSMutableSet new];
        for (NSInteger row = [self numberOfRows] - 2; row >= 0; row--)
        {
            NSUInteger value = [self valueAtRow:row column:col];
            if (value == 0)
            {
                continue;
            }
            
            NSUInteger rowToMove = row;
            for (NSInteger curRow = row + 1; curRow < [self numberOfRows]; curRow++)
            {
                NSUInteger curValue = [self valueAtRow:curRow column:col];
                if (![mergedRows containsObject:@(curRow)] && curValue == value)
                {
                    [self.data setValue:2 * value atBoardCellRow:curRow column:col];
                    [self.data setValue:0 atBoardCellRow:row column:col];
                    [mergedRows addObject:@(curRow)];
                    rowToMove = row;
                    
//                    NSLog(@"row = %lu, col = %lu merged with curRow = %lu value = %lu", row, col, curRow, 2*value);
                    
                    result[[VDGameData encodeRow:row column:col]] = [VDGameData encodeRow:curRow column:col];
                    mergedDictionary[[VDGameData encodeRow:curRow column:col]] = @(2 * value);
                    
                    break;
                }
                if (curValue == 0)
                {
                    rowToMove = curRow;
                }
                else
                {
                    break;
                }
            }
            if (rowToMove != row)
            {
//                NSLog(@"row = %lu, col = %lu move to rowToMove = %lu", row, col, rowToMove);
                
                [self.data setValue:value atBoardCellRow:rowToMove column:col];
                [self.data setValue:0 atBoardCellRow:row column:col];
                
                result[[VDGameData encodeRow:row column:col]] = [VDGameData encodeRow:rowToMove column:col];
            }
        }
    }
    
    if (mergedCells != NULL)
    {
        *mergedCells = mergedDictionary;
    }
    
    return result;
}

@end
