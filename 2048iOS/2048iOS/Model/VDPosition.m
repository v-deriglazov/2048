//
//  VDPosition.m
//  2048iOS
//
//  Created by Vladimir Deriglazov on 27.07.14.
//  Copyright (c) 2014 Vladimir Deriglazov. All rights reserved.
//

#import "VDPosition.h"

VDPosition VDPositionMake(NSUInteger row, NSUInteger col)
{
    VDPosition position;
    position.row = row;
    position.column = col;
    return position;
}

NSString *VDPositionToString(VDPosition pos)
{
    return [NSString stringWithFormat:@"%lu.%lu", (unsigned long)pos.row, (unsigned long)pos.column];
}

VDPosition VDPositionFromString(NSString *str)
{
    float floatVal = [str floatValue];
    NSInteger intVal = [str integerValue];
    VDPosition pos = VDPositionMake(intVal, roundf((floatVal - intVal) * 10));
    return pos;
}

VDColor *VDColorForValue(NSUInteger value)
{
    VDColor *result = nil;
    if (value <= 4)
    {
        result = [VDColor grayColor];
    }
    else if (value <= 32)
    {
        result = [VDColor yellowColor];
    }
    else if (value <= 128)
    {
        result = [VDColor redColor];
    }
    else
    {
        result = [VDColor purpleColor];
    }
    
    return result;
}