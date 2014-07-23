//
//  VDCellView.h
//  2048Mac
//
//  Created by Vladimir Deriglazov on 19.07.14.
//  Copyright (c) 2014 Vladimir Deriglazov. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VDCellView : NSView
@property (nonatomic) NSUInteger value;
@property (nonatomic) NSUInteger tag;

@property (nonatomic) BOOL animationMode;

- (void)setValue:(NSUInteger)aValue withAnimation:(BOOL)flag;

@end
