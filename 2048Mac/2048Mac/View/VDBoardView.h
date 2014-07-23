//
//  VDBoardView.h
//  2048Mac
//
//  Created by Vladimir Deriglazov on 06.07.14.
//  Copyright (c) 2014 Vladimir Deriglazov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VDGameCore.h"

@class VDBoardView;

@protocol VDBoardViewDataSource

- (NSUInteger)numberOfRowsForBoard:(VDBoardView *)view;
- (NSUInteger)numberOfColumnsForBoard:(VDBoardView *)view;
- (NSUInteger)valueForRow:(NSUInteger)row column:(NSUInteger)column board:(VDBoardView *)view;

@end

@protocol VDBoardViewDelegate

- (BOOL)tryToMakeMove:(VDMoveDirection)direction board:(VDBoardView *)view movedCells:(NSDictionary **)movedCells mergedCells:(NSDictionary **)mergedCells newValue:(NSString **)newValuePath;

@end

@interface VDBoardView : NSView
@property (nonatomic, weak) IBOutlet id<VDBoardViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<VDBoardViewDelegate> delegate;
@end
