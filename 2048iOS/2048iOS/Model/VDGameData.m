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

- (NSUInteger)valueAtPosition:(VDPosition)position
{
    if (position.row >= VDBoardSize || position.column >= VDBoardSize)
        return 0;
    
    NSNumber *number = self.rawData[position.row][position.column];
    return [number unsignedIntegerValue];
}

- (void)setValue:(NSUInteger)value atPosition:(VDPosition)position
{
    if (position.row >= VDBoardSize || position.column >= VDBoardSize)
        return;

    self.rawData[position.row][position.column] = @(value);
    NSString *rowCol = VDPositionToString(position);
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

- (VDPosition)addRandomValue
{
    VDPosition position = [[self class] randomCellFromArray:self.freeCells];
    NSLog(@"addRandomValue at %@", VDPositionToString(position));
    
    NSUInteger addValue = 2;
    [self setValue:addValue atPosition:position];
    self.score = [NSNumber numberWithInteger:self.score.integerValue + addValue];
    
    return position;
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
            [self.freeCells addObject:VDPositionToString(VDPositionMake(i, j))];
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
            NSInteger value = [self valueAtPosition:VDPositionMake(i, j)];
            [boardData appendFormat:@"%lu;", (long)value];
        }
    }
    self.boardData = boardData;
}

#pragma mark - Utils

+ (VDPosition)randomCellFromArray:(NSArray *)cells
{
    NSUInteger randIndex = [self randomValueBetweenMin:0 max:cells.count - 1];
    return VDPositionFromString(cells[randIndex]);
}

+ (NSUInteger)randomValueBetweenMin:(NSUInteger)min max:(NSUInteger)max
{
    CGFloat rand = (float)random() / RAND_MAX;
    return (NSUInteger) roundf((min + (max - min) * rand));
}

@end
