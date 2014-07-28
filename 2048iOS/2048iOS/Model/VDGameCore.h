//
//  VDGameCore.h
//  2048Mac
//
//  Created by Vladimir Deriglazov on 05.07.14.
//  Copyright (c) 2014 Vladimir Deriglazov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VDPosition.h"

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
- (NSUInteger)valueAtPosition:(VDPosition)position;
- (NSUInteger)score;
@property (nonatomic, readonly) NSUInteger bestScore;

@property (nonatomic, readonly) CGFloat time;
- (void)startGame;
- (void)pauseGame;

- (BOOL)canMoveToDirection:(VDMoveDirection)direction;
- (BOOL)moveToDirection:(VDMoveDirection)direction movedCells:(NSDictionary **)movedCells mergedCells:(NSDictionary **)mergedCells newValue:(VDPosition *)newValuePosition; //if return no - gameOver

@end
