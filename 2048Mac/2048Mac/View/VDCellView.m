//
//  VDCellView.m
//  2048Mac
//
//  Created by Vladimir Deriglazov on 19.07.14.
//  Copyright (c) 2014 Vladimir Deriglazov. All rights reserved.
//

#import "VDCellView.h"

static CGFloat const kVDCellViewChangeValueAnimationDuration = 0.3;
static CGFloat const kVDCellViewAnimationTimeOffset = 0.3;//1;

@interface VDCellView () <NSAnimationDelegate>
@property (nonatomic, strong) NSTextField *valueField;
@end


@implementation VDCellView

+ (NSColor *)cellColorForValue:(NSUInteger)value
{
    NSColor *result = nil;
    if (value <= 4)
    {
        result = [NSColor grayColor];
    }
    else if (value <= 32)
    {
        result = [NSColor yellowColor];
    }
    else if (value <= 128)
    {
        result = [NSColor redColor];
    }
    else
    {
        result = [NSColor purpleColor];
    }
    
    return result;
}

#pragma mark -

- (NSTextField *)valueField
{
    if (_valueField == nil)
    {
        _valueField = [[NSTextField alloc] initWithFrame:self.bounds];
        [_valueField setFont:[NSFont boldSystemFontOfSize:32]];
        _valueField.alignment = NSCenterTextAlignment;

        [_valueField setBackgroundColor:[NSColor clearColor]];
        [_valueField setDrawsBackground:YES];
        
        _valueField.editable = NO;
        _valueField.bezeled = NO;
        _valueField.selectable = NO;
        
        [_valueField setWantsLayer:YES];
        
        _valueField.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
        [self addSubview:_valueField];
    }
    return _valueField;
}

- (void)setValue:(NSUInteger)value
{
    if (value > 0)
    {
        self.valueField.stringValue = [NSString stringWithFormat:@"%lu", value];
    }
    else
    {
        self.valueField.stringValue = @"";
    }
    
    [self refreshColor];
}

- (void)refreshColor
{
    NSColor *color = [[self class] cellColorForValue:self.value];
    if (self.animationMode && self.value > 4)
        color = [color colorWithAlphaComponent:0.5];
    else if (self.animationMode)
        color = [NSColor clearColor];
    self.valueField.layer.backgroundColor = [color CGColor];
}

- (NSUInteger)value
{
    return [self.valueField.stringValue integerValue];
}

- (void)setValue:(NSUInteger)aValue withAnimation:(BOOL)flag
{
    if (flag)
    {
        CALayer *layer = self.valueField.layer;
        layer.opacity = 0;

        CABasicAnimation* fadeOutAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeOutAnim.fromValue = [NSNumber numberWithFloat:1.0];
        fadeOutAnim.toValue = [NSNumber numberWithFloat:0.0];
        fadeOutAnim.duration = 1;
        [layer addAnimation:fadeOutAnim forKey:@"fadeOutAnim"];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kVDCellViewAnimationTimeOffset * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           CABasicAnimation* fadeInAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
                           fadeInAnim.fromValue = [NSNumber numberWithFloat:0.0];
                           fadeInAnim.toValue = [NSNumber numberWithFloat:1.0];
                           fadeInAnim.duration = kVDCellViewChangeValueAnimationDuration;
                           
                           self.value = aValue;
                           layer.opacity = 1;
                           [layer addAnimation:fadeInAnim forKey:@"addvalueanimation"];
                       });
    }
    else
    {
        self.value = aValue;
    }
}

- (void)setAnimationMode:(BOOL)animationMode
{
    _animationMode = animationMode;
    [self refreshColor];
}

@end
