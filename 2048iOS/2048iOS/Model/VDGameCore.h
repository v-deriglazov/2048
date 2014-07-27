//
//  VDGameCore.h
//  2048Mac
//
//  Created by Vladimir Deriglazov on 05.07.14.
//  Copyright (c) 2014 Vladimir Deriglazov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    VDMoveDirectionNone = 0,
    VDMoveDirectionLeft,
    VDMoveDirectionRight,
    VDMoveDirectionUp,
    VDMoveDirectionDown
} VDMoveDirection;

@class VDGameData, VDDocument;

@interface VDGameCore : NSObject

@property (nonatomic, strong) VDGameData *data;

//- (id)initWithDocument:(VDDocument *)document;
- (NSUInteger)numberOfRows;
- (NSUInteger)numberOfColumns;
- (NSUInteger)valueAtRow:(NSUInteger)row column:(NSUInteger)column;
- (NSUInteger)score;

- (BOOL)canMoveToDirection:(VDMoveDirection)direction;
- (BOOL)moveToDirection:(VDMoveDirection)direction movedCells:(NSDictionary **)movedCells mergedCells:(NSDictionary **)mergedCells newValue:(NSString **)newValuePath; //if return no - gameOver

@end
