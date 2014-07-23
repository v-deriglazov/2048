//
//  VDGameData.h
//  2048Mac
//
//  Created by Vladimir Deriglazov on 05.07.14.
//  Copyright (c) 2014 Vladimir Deriglazov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSUInteger const VDBoardSize;

@interface VDGameData : NSManagedObject

@property (nonatomic, retain) NSString * data;
@property (nonatomic, retain) NSNumber * score;


@property (nonatomic, strong) NSMutableArray *rawData;
@property (nonatomic) NSUInteger currentScrore; //temporary property


- (NSUInteger)valueAtBoardCellRow:(NSUInteger)row column:(NSUInteger)column;
- (void)setValue:(NSUInteger)value atBoardCellRow:(NSUInteger)row column:(NSUInteger)column;
- (NSString *)addRandomValue;


+ (NSString *)encodeRow:(NSUInteger)row column:(NSUInteger)column;
+ (void)decodeString:(NSString *)str row:(NSUInteger *)row column:(NSUInteger *)column;

@end
