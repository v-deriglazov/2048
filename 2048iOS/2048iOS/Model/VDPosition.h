//
//  VDPosition.h
//  2048iOS
//
//  Created by Vladimir Deriglazov on 27.07.14.
//  Copyright (c) 2014 Vladimir Deriglazov. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct
{
    NSUInteger row;
    NSUInteger column;
} VDPosition;

VDPosition VDPositionMake(NSUInteger row, NSUInteger col);

NSString *VDPositionToString(VDPosition pos);
VDPosition VDPositionFromString(NSString *posStr);


#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE //TARGET_OS_MAC
    typedef UIColor VDColor;
#else
    typedef NSColor VDColor;
#endif

VDColor *VDColorForValue(NSUInteger value);
