//
//  VDBoardView.m
//  2048Mac
//
//  Created by Vladimir Deriglazov on 06.07.14.
//  Copyright (c) 2014 Vladimir Deriglazov. All rights reserved.
//

#import "VDBoardView.h"
#import "VDCellView.h"

#import "VDGameData.h"

@interface VDBoardView () <NSAnimationDelegate>

@end


@implementation VDBoardView


- (void)setDataSource:(id<VDBoardViewDataSource>)dataSource
{
    if (_dataSource != dataSource)
    {
        _dataSource = dataSource;
        
        NSArray *cells = [self.subviews copy];
        [cells makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        NSUInteger numOfRows = [self.dataSource numberOfRowsForBoard:self];
        NSUInteger numOfCols = [self.dataSource numberOfRowsForBoard:self];
        
        for (int row = 0; row < numOfRows; row++)
        {
            for (int col = 0; col < numOfCols; col++)
            {
                NSRect cellFrame = [self realCellFrameForRow:row column:col];
                VDCellView *cellView = [[VDCellView alloc] initWithFrame:cellFrame];
                cellView.value = [self.dataSource valueForRow:row column:col board:self];
                cellView.tag = [self tagForRow:row column:col];
                [self addSubview:cellView];
            }
        }
    }
}

- (NSRect)cellFrameForRow:(NSUInteger)row column:(NSUInteger)column
{
    NSRect bounds = self.bounds;
    NSUInteger numOfRows = [self.dataSource numberOfRowsForBoard:self];
    NSUInteger numOfCols = [self.dataSource numberOfRowsForBoard:self];
    CGSize cellSize = CGSizeMake(bounds.size.width / numOfCols, bounds.size.height / numOfRows);
    NSRect cellFrame = CGRectMake(column * cellSize.width, row * cellSize.height, cellSize.width, cellSize.height);
    return cellFrame;
}

- (NSRect)realCellFrameForRow:(NSUInteger)row column:(NSUInteger)column
{
    NSRect cellFrame = [self cellFrameForRow:row column:column];
    NSRect realCellFrame = NSInsetRect(cellFrame, 2, 2);
    return realCellFrame;
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    
    NSUInteger numOfRows = [self.dataSource numberOfRowsForBoard:self];
    NSUInteger numOfCols = [self.dataSource numberOfRowsForBoard:self];
    for (int row = 0; row < numOfRows; row++)
    {
        for (int col = 0; col < numOfCols; col++)
        {
            NSRect cellFrame = [self realCellFrameForRow:row column:col];
            VDCellView *cellView = [self viewWithTag:[self tagForRow:row column:col]];
            cellView.frame = cellFrame;
        }
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = self.bounds;
    [[NSColor grayColor] setFill];
    NSRectFill(bounds);
    [[NSColor blackColor] set];
    NSFrameRectWithWidth(bounds, 2);
    
    NSUInteger numOfRows = [self.dataSource numberOfRowsForBoard:self];
    NSUInteger numOfCols = [self.dataSource numberOfRowsForBoard:self];
    for (int row = 0; row < numOfRows; row++)
    {
        for (int col = 0; col < numOfCols; col++)
        {
            NSRect cellFrame = [self cellFrameForRow:row column:col];
             NSFrameRectWithWidth(cellFrame, 1);
        }
    }
}

#pragma mark -

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
    NSString *chars = theEvent.charactersIgnoringModifiers;
    if ([chars length] == 0)
        return;
    unichar c = [chars characterAtIndex:0];
    VDMoveDirection direction = VDMoveDirectionNone;
    if (c == NSUpArrowFunctionKey)
    {
        direction = VDMoveDirectionUp;
    }
    else if (c == NSDownArrowFunctionKey)
    {
        direction = VDMoveDirectionDown;
    }
    else if (c == NSLeftArrowFunctionKey)
    {
        direction = VDMoveDirectionLeft;
    }
    else if (c == NSRightArrowFunctionKey)
    {
        direction = VDMoveDirectionRight;
    }
    
    NSDictionary *movedCells = nil;
    NSDictionary *mergedCells = nil;
    NSString *newPath = nil;
    BOOL makeMove = [self.delegate tryToMakeMove:direction board:self movedCells:&movedCells mergedCells:&mergedCells newValue:&newPath];
    if (makeMove)
    {
        __block NSMutableArray *movingAnimationDictionaries = [NSMutableArray new];
        __block NSMutableArray *mergedAnimationDictionaries = [NSMutableArray new];
        [movedCells enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop)
        {
            NSUInteger rowFrom = 0;
            NSUInteger colFrom = 0;
            NSUInteger rowTo = 0;
            NSUInteger colTo = 0;
            
            [VDGameData decodeString:key row:&rowFrom column:&colFrom];
            [VDGameData decodeString:obj row:&rowTo column:&colTo];
            
            NSUInteger tag = [self tagForRow:rowFrom column:colFrom];
            VDCellView *cell = [self viewWithTag:tag];
            [self addSubview:cell positioned:NSWindowAbove relativeTo:nil];
            cell.animationMode = YES;
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            dict[NSViewAnimationTargetKey] = cell;
            dict[NSViewAnimationStartFrameKey] = [NSValue valueWithRect:cell.frame];
            dict[NSViewAnimationEndFrameKey] = [NSValue valueWithRect:[self realCellFrameForRow:rowTo column:colTo]];

            [movingAnimationDictionaries addObject:dict];
        }];
        
        NSViewAnimation *animation = [[NSViewAnimation alloc] initWithDuration:1 animationCurve:NSAnimationEaseIn];
        animation.delegate = self;
        [animation setViewAnimations:movingAnimationDictionaries];
        
        
        NSUInteger newRow = 0;
        NSUInteger newCol = 0;
        [VDGameData decodeString:newPath row:&newRow column:&newCol];
        NSUInteger tag = [self tagForRow:newRow column:newCol];
        VDCellView *cell = [self viewWithTag:tag];
        [cell setValue:[self.dataSource valueForRow:newRow column:newCol board:self] withAnimation:YES];
        
        [mergedCells enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSUInteger row = 0;
            NSUInteger col = 0;
            [VDGameData decodeString:key row:&row column:&col];
            NSUInteger tag = [self tagForRow:row column:col];
            VDCellView *cell = [self viewWithTag:tag];
            
            [cell setValue:[obj integerValue] withAnimation:YES];
        }];

        
        [animation startAnimation];
    }
    else
    {
        NSBeep();
    }
}

#pragma mark - NSAnimationDelegate

- (void)animationDidEnd:(NSViewAnimation *)animation
{
    NSUInteger numOfRows = [self.dataSource numberOfRowsForBoard:self];
    NSUInteger numOfCols = [self.dataSource numberOfRowsForBoard:self];
    for (int row = 0; row < numOfRows; row++)
    {
        for (int col = 0; col < numOfCols; col++)
        {
            VDCellView *cellView = [self viewWithTag:[self tagForRow:row column:col]];
            cellView.animationMode = NO;
            cellView.value = [self.dataSource valueForRow:row column:col board:self];
            cellView.frame = [self realCellFrameForRow:row column:col];
            
            [cellView setNeedsDisplay:YES];
            NSLog(@"row = %d col = %d cellView = %@ frame = %@ value = %lu", row, col, cellView, NSStringFromRect(cellView.frame), cellView.value);
        }
    }
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (NSUInteger)tagForRow:(NSUInteger)row column:(NSUInteger)column
{
    return 1000 + row*100 + column;
}

- (NSUInteger)rowForTag:(NSUInteger)tag
{
    return (tag - 1000) / 100;
}

- (NSUInteger)colForTag:(NSUInteger)tag
{
    return tag % 100;
}

@end
