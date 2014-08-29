//
//  ASEConverter.m
//  Trans Ball
//
//  Created by Egor Vilkin on 8/29/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "ASEConverter.h"

NSString *stringValue(NSString *descriptionText, NSString *parameterName)
{
    NSError *error = nil;
    NSString *pattern = @"\\*GEOMOBJECT \\{(.(?!\\*GEOMOBJECT))*\\}\\r\\n";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                             error:&error];
    return nil;
}

NSArray *allValues(NSString *descriptionText, NSString *parameterName)
{
    return nil;
}

NSNumber *numberValue(NSString *descriptionText, NSString *parameterName)
{
    return nil;
}
