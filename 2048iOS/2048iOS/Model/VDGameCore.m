//
//  VDGameCore.m
//  2048Mac
//
//  Created by Vladimir Deriglazov on 05.07.14.
//  Copyright (c) 2014 Vladimir Deriglazov. All rights reserved.
//

#import "VDGameCore.h"

#import "VDGameData.h"

static CGFloat const kVDGameCoreTimerUpdateInterval = 1.0f;

@interface VDGameCore ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSTimer *timer;

- (NSUInteger)valueAtRow:(NSUInteger)row column:(NSUInteger)column;

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

- (void)dealloc
{
    [self.timer invalidate];
}

#pragma mark -

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
    return [self valueAtPosition:VDPositionMake(row, column)];
}

- (NSUInteger)valueAtPosition:(VDPosition)position
{
    return [self.data valueAtPosition:position];
}

- (NSUInteger)score
{
    return [self.data.score integerValue];
}

- (NSUInteger)bestScore
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"bestScore"];
}

- (void)setBestScore:(NSUInteger)bestScore
{
    [[NSUserDefaults standardUserDefaults] setInteger:bestScore forKey:@"bestScore"];
    //nsnotification??
}

#pragma mark - Time

- (CGFloat)time
{
    return [self.data.time floatValue];
}

- (void)startGame
{
    if (self.timer == nil)
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:kVDGameCoreTimerUpdateInterval target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    }
}

- (void)pauseGame
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)updateTime
{
    self.data.time = [NSNumber numberWithFloat:self.time + kVDGameCoreTimerUpdateInterval];
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


- (BOOL)moveToDirection:(VDMoveDirection)direction movedCells:(NSDictionary **)movedCells mergedCells:(NSDictionary **)mergedCells newValue:(VDPosition *)newValuePosition //if return no - gameOver
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
    
    VDPosition newPosition = [self.data addRandomValue];
    if (newValuePosition != NULL)
    {
        *newValuePosition = newPosition;
    }
    
    if (self.bestScore < self.score)
    {
        [self setBestScore:self.score];
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
            VDPosition position = VDPositionMake(row, col);
            NSUInteger value = [self valueAtRow:row column:col];
            if (value == 0)
            {
                continue;
            }
            
            NSUInteger colToMove = col;
            for (NSInteger curCol = col - 1; curCol >= 0; curCol--)
            {
                VDPosition curPosition = VDPositionMake(row, curCol);
                if (![mergedCols containsObject:@(curCol)] && [self valueAtRow:row column:curCol] == value)
                {
                    [self.data setValue:2 * value atPosition:curPosition];
                    [self.data setValue:0 atPosition:position];
                    [mergedCols addObject:@(curCol)];
                    colToMove = col;
                    
                    NSLog(@"pos = %@ merged with %@, value = %lu", VDPositionToString(position), VDPositionToString(curPosition), (unsigned long)2*value);
                    
                    NSString *curPositionStr = VDPositionToString(curPosition);
                    result[VDPositionToString(position)] = curPositionStr;
                    mergedDictionary[curPositionStr] = @(2 * value);
                    
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
                VDPosition positionToMove = VDPositionMake(row, colToMove);
                NSLog(@"pos = %@ move to = %@", VDPositionToString(position), VDPositionToString(positionToMove));
                [self.data setValue:value atPosition:positionToMove];
                [self.data setValue:0 atPosition:position];
                
                result[VDPositionToString(position)] = VDPositionToString(positionToMove);
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
            VDPosition position = VDPositionMake(row, col);
            NSUInteger value = [self valueAtRow:row column:col];
            if (value == 0)
            {
                continue;
            }
            
            NSUInteger colToMove = col;
            for (NSInteger curCol = col + 1; curCol < [self numberOfColumns]; curCol++)
            {
                VDPosition curPosition = VDPositionMake(row, curCol);
                NSUInteger curValue = [self valueAtRow:row column:curCol];
                if (![mergedCols containsObject:@(curCol)] && curValue == value)
                {
                    [self.data setValue:2 * value atPosition:curPosition];
                    [self.data setValue:0 atPosition:position];
                    [mergedCols addObject:@(curCol)];
                    colToMove = col;
                    
                    NSLog(@"pos = %@ merged with %@, value = %lu", VDPositionToString(position), VDPositionToString(curPosition), (unsigned long)2*value);
                    
                    result[VDPositionToString(position)] = VDPositionToString(curPosition);
                    mergedDictionary[VDPositionToString(curPosition)] = @(2 * value);
                    
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
                VDPosition positionToMove = VDPositionMake(row, colToMove);
                NSLog(@"pos = %@ move to = %@", VDPositionToString(position), VDPositionToString(positionToMove));
                
                [self.data setValue:value atPosition:positionToMove];
                [self.data setValue:0 atPosition:position];
                
                result[VDPositionToString(position)] = VDPositionToString(positionToMove);
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
            VDPosition position = VDPositionMake(row, col);
            NSUInteger value = [self valueAtRow:row column:col];
            if (value == 0)
            {
                continue;
            }
            
            NSUInteger rowToMove = row;
            for (NSInteger curRow = row - 1; curRow >= 0; curRow--)
            {
                VDPosition curPosition = VDPositionMake(curRow, col);
                NSUInteger curValue = [self valueAtRow:curRow column:col];
                if (![mergedRows containsObject:@(curRow)] && curValue == value)
                {
                    [self.data setValue:2 * value atPosition:curPosition];
                    [self.data setValue:0 atPosition:position];
                    [mergedRows addObject:@(curRow)];
                    rowToMove = row;
                    
                    NSLog(@"pos = %@ merged with %@, value = %lu", VDPositionToString(position), VDPositionToString(curPosition), (unsigned long)2*value);
                    
                    result[VDPositionToString(position)] = VDPositionToString(curPosition);
                    mergedDictionary[VDPositionToString(curPosition)] = @(2 * value);
                    
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
                VDPosition positionToMove = VDPositionMake(rowToMove, col);
                NSLog(@"pos = %@ move to = %@", VDPositionToString(position), VDPositionToString(positionToMove));
                
                [self.data setValue:value atPosition:positionToMove];
                [self.data setValue:0 atPosition:position];
                
                result[VDPositionToString(position)] = VDPositionToString(positionToMove);
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
            VDPosition position = VDPositionMake(row, col);
            NSUInteger value = [self valueAtRow:row column:col];
            if (value == 0)
            {
                continue;
            }
            
            NSUInteger rowToMove = row;
            for (NSInteger curRow = row + 1; curRow < [self numberOfRows]; curRow++)
            {
                VDPosition curPosition = VDPositionMake(curRow, col);
                NSUInteger curValue = [self valueAtRow:curRow column:col];
                if (![mergedRows containsObject:@(curRow)] && curValue == value)
                {
                    [self.data setValue:2 * value atPosition:curPosition];
                    [self.data setValue:0 atPosition:position];
                    [mergedRows addObject:@(curRow)];
                    rowToMove = row;
                    
                    NSLog(@"pos = %@ merged with %@, value = %lu", VDPositionToString(position), VDPositionToString(curPosition), (unsigned long)2*value);
                    
                    result[VDPositionToString(position)] = VDPositionToString(curPosition);
                    mergedDictionary[VDPositionToString(curPosition)] = @(2 * value);
                    
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
                VDPosition positionToMove = VDPositionMake(rowToMove, col);
                NSLog(@"pos = %@ move to = %@", VDPositionToString(position), VDPositionToString(positionToMove));
                
                [self.data setValue:value atPosition:positionToMove];
                [self.data setValue:0 atPosition:position];
                
                result[VDPositionToString(position)] = VDPositionToString(positionToMove);
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
