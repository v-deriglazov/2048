//
//  VDBoardCell.m
//  2048iOS
//
//  Created by Vladimir Deriglazov on 27.07.14.
//  Copyright (c) 2014 Vladimir Deriglazov. All rights reserved.
//

#import "VDBoardCell.h"
#import "VDPosition.h"

@interface VDBoardCell ()
@property (nonatomic, strong) UILabel *valueLabel;
@end

@implementation VDBoardCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.value = 0;
}

- (UILabel *)valueLabel
{
    if (_valueLabel == nil)
    {
        _valueLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        _valueLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.font = [UIFont systemFontOfSize:24];
        [self.contentView addSubview:_valueLabel];
    }
    return _valueLabel;
}

- (NSUInteger)value
{
    return [self.valueLabel.text integerValue];
}

- (void)setValue:(NSUInteger)value
{
    if (value > 0)
        self.valueLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)value];
    else
        self.valueLabel.text = @"";
    self.contentView.backgroundColor = VDColorForValue(value);
}

- (void)makeNewValueAnimation
{
    [UIView animateWithDuration:0.5 animations:^
    {
        self.valueLabel.transform = CGAffineTransformMakeScale(2, 2);
//        self.contentView.backgroundColor = [UIColor greenColor];
    } completion:^(BOOL finished)
    {
        [UIView animateWithDuration:0.5 animations:^
        {
            self.valueLabel.transform = CGAffineTransformIdentity;
        }];
    }];
}

@end
