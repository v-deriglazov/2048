//
//  VDGameData.m
//  2048Mac
//
//  Created by Vladimir Deriglazov on 05.07.14.
//  Copyright (c) 2014 Vladimir Deriglazov. All rights reserved.
//

#import "VDGameData.h"

NSUInteger const VDBoardSize = 4;


@interface VDGameData ()

@property (nonatomic, strong) NSMutableArray *freeCells;
@property (nonatomic, strong) NSMutableArray *rawData;

@end


@implementation VDGameData

@dynamic boardData;
@dynamic score;
@dynamic time;

@synthesize rawData;
@synthesize freeCells;

#pragma mark - Public

- (NSUInteger)valueAtBoardCellRow:(NSUInteger)row column:(NSUInteger)column
{
    NSNumber *number = self.rawData[row][column];
    return [number unsignedIntegerValue];
}

- (void)setValue:(NSUInteger)value atBoardCellRow:(NSUInteger)row column:(NSUInteger)column
{
    self.rawData[row][column] = @(value);
    NSString *rowCol = [[self class] encodeRow:row column:column];
    if (value == 0)
    {
        [self.freeCells addObject:rowCol];
    }
    else
    {
        [self.freeCells removeObject:rowCol];
    }
    [self syncData];
}

- (NSString *)addRandomValue
{
    NSString *cellIndex = [[self class] randomCellFromArray:self.freeCells];
    NSLog(@"addRandomValue at %@", cellIndex);
    NSUInteger row = 0;
    NSUInteger col = 0;
    [[self class] decodeString:cellIndex row:&row column:&col];
    
    NSUInteger addValue = 2;
    [self setValue:addValue atBoardCellRow:row column:col];
    self.score = [NSNumber numberWithInteger:self.score.integerValue + addValue];
    
    return cellIndex;
}

#pragma mark - Core Data

- (void)awakeFromInsert
{
    self.freeCells = [NSMutableArray new];
    
    self.rawData = [NSMutableArray new];
    for (int i = 0; i < VDBoardSize; i++)
    {
        NSMutableArray *rowData = [NSMutableArray new];
        for (int j = 0; j < VDBoardSize; j++)
        {
            [rowData addObject:@(0)];
            [self.freeCells addObject:[[self class] encodeRow:i column:j]];
        }
        
        [self.rawData addObject:rowData];
    }
    
    for (int i = 0; i < 3; i++)
    {
        [self addRandomValue];
    }
    [self syncData];
}

- (void)awakeFromFetch
{
    NSLog(@"awakeFromFetch %@", self.boardData);
}

- (void)syncData
{
    NSMutableString *boardData = [NSMutableString new];
    for (int i = 0; i < VDBoardSize; i++)
    {
        for (int j = 0; j < VDBoardSize; j++)
        {
            NSInteger value = [self valueAtBoardCellRow:i column:j];
            [boardData appendFormat:@"%lu;", value];
        }
    }
    self.boardData = boardData;
}

#pragma mark - Utils

+ (NSString *)encodeRow:(NSUInteger)row column:(NSUInteger)column
{
    return [NSString stringWithFormat:@"%lu.%lu", row, column];
}

+ (void)decodeString:(NSString *)str row:(NSUInteger *)row column:(NSUInteger *)column
{
    float floatVal = [str floatValue];
    NSInteger intVal = [str integerValue];
    if (row != NULL)
    {
        *row = intVal;
    }
    if (column != NULL)
    {
        *column = roundf((floatVal - intVal) * 10);
    }
}

+ (NSString *)randomCellFromArray:(NSArray *)cells
{
    NSUInteger randIndex = [self randomValueBetweenMin:0 max:cells.count - 1];
    return cells[randIndex];
}

+ (NSUInteger)randomValueBetweenMin:(NSUInteger)min max:(NSUInteger)max
{
    CGFloat rand = (float)random() / RAND_MAX;
    return (NSUInteger) roundf((min + (max - min) * rand));
}

@end
