//
//  VDGameData.h
//  2048Mac
//
//  Created by Vladimir Deriglazov on 05.07.14.
//  Copyright (c) 2014 Vladimir Deriglazov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "VDPosition.h"

extern NSUInteger const VDBoardSize;

@interface VDGameData : NSManagedObject

@property (nonatomic, retain) NSString *boardData;
@property (nonatomic, retain) NSNumber *score;
@property (nonatomic, retain) NSNumber *time;


- (NSUInteger)valueAtPosition:(VDPosition)position;
- (void)setValue:(NSUInteger)value atPosition:(VDPosition)position;
- (VDPosition)addRandomValue;

@end
