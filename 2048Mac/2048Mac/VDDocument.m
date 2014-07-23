//
//  VDDocument.m
//  2048Mac
//
//  Created by Vladimir Deriglazov on 05.07.14.
//  Copyright (c) 2014 Vladimir Deriglazov. All rights reserved.
//

#import "VDDocument.h"
#import "VDBoardView.h"
#import "VDGameCore.h"

@interface VDDocument () <VDBoardViewDataSource, VDBoardViewDelegate>

@property (nonatomic, strong) VDGameCore *game;

@property (nonatomic, weak) IBOutlet VDBoardView *boardView;
@property (nonatomic, weak) IBOutlet NSTextField *scoreTextField;
@property (nonatomic, weak) IBOutlet NSTextField *topScoreTextField;

@end

@implementation VDDocument

- (id)init
{
    self = [super init];
    if (self)
    {
        self.game = [[VDGameCore alloc] initWithDocument:self];
    }
    return self;
}

- (NSString *)windowNibName
{
    return @"VDDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    [self.boardView becomeFirstResponder];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

#pragma mark - VDBoardViewDataSource

- (NSUInteger)numberOfRowsForBoard:(VDBoardView *)view
{
    return [self.game numberOfRows];
}

- (NSUInteger)numberOfColumnsForBoard:(VDBoardView *)view
{
    return [self.game numberOfColumns];
}

- (NSUInteger)valueForRow:(NSUInteger)row column:(NSUInteger)column board:(VDBoardView *)view
{
    return [self.game valueAtRow:row column:column];
}

#pragma mark - VDBoardViewDelegate

- (BOOL)tryToMakeMove:(VDMoveDirection)direction board:(VDBoardView *)view movedCells:(NSDictionary **)movedCells mergedCells:(NSDictionary **)mergedCells newValue:(NSString **)newValuePath
{
    BOOL result = [self.game canMoveToDirection:direction];
    if (result)
    {
        BOOL isGameOver = ![self.game moveToDirection:direction movedCells:movedCells mergedCells:mergedCells newValue:newValuePath];
        NSUInteger gameScore = self.game.score;
        [self.scoreTextField setStringValue:[NSString stringWithFormat:@"%lu", gameScore]];
        
        if (gameScore > [self bestScore])
            [self setBestScore:gameScore];
        
        [self.topScoreTextField setStringValue:[NSString stringWithFormat:@"%lu", [self bestScore]]];
        
        if (isGameOver)
        {
            [[NSAlert alertWithMessageText:@"Game Over" defaultButton:@"OK" alternateButton:Nil otherButton:nil informativeTextWithFormat:@"Try again;)"] runModal];
        }
    }
    return result;
}

#pragma mark - Best Score

- (NSUInteger)bestScore
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"bestScore"];
}

- (void)setBestScore:(NSUInteger)bestScore
{
    [[NSUserDefaults standardUserDefaults] setInteger:bestScore forKey:@"bestScore"];
    //nsnotification??
}

@end
