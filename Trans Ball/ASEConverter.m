//
//  ASEConverter.m
//  Trans Ball
//
//  Created by Egor Vilkin on 8/29/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "ASEConverter.h"


@implementation ASEConverter

+ (NSString *)stringValueNamed:(NSString *)name fromTextDescription:(NSString *)description
{
    NSError *error = nil;
    NSString *pattern = [NSString stringWithFormat:@"\\*%@ (.(?!\\*))*\\r\\n", name];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                             error:&error];
    if (error) {
        NSLog(@"ERROR! ASEConverter: %@", error);
    }
    else {
        NSArray *resultRegex = [regex matchesInString:description options:0 range:NSMakeRange(0, description.length)];
        if (resultRegex.count) {
            NSString *fullParamStr = [description substringWithRange:[(NSTextCheckingResult *)resultRegex[0] range]];
            NSRange start = [fullParamStr rangeOfString:[NSString stringWithFormat:@"*%@ \"", name]];
            NSRange end = [fullParamStr rangeOfString:@"\"\r\n"];
            return [fullParamStr substringWithRange:NSMakeRange(start.location + start.length, end.location - start.location - start.length)];
        }
    }
    return nil;
}

+ (NSNumber *)numberValueNamed:(NSString *)name fromTextDescription:(NSString *)description
{
    return nil;
}

+ (NSArray *)valuesNamed:(NSString *)name fromTextDescription:(NSString *)description
{
    return nil;
}

@end
