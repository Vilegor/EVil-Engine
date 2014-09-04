//
//  ASEConverter.m
//  Trans Ball
//
//  Created by Egor Vilkin on 8/29/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "EVEASEConverter.h"
static NSString * const kLineFormat =           @"\\*%@[ \\t]+(.(?!\\*))+\\n";
static NSString * const kIndexedLineFormat =    @"\\*%@[ \\t]+%d([ \\t]|:)+(.(?!\\*|\\n))+";

@implementation EVEASEConverter

+ (NSString *)lineNamed:(NSString *)name fromTextDescription:(NSString *)description
{
    NSError *error = nil;
    NSString *pattern = [NSString stringWithFormat:kLineFormat, name];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                             error:&error];
    if (error) {
        NSLog(@"ERROR! ASEConverter: %@", error);
    }
    else {
        NSArray *resultRegex = [regex matchesInString:description options:0 range:NSMakeRange(0, description.length)];
        if (resultRegex.count) {
            NSRange range = [(NSTextCheckingResult *)resultRegex[0] range];
            range.length += 1;      // substringWithRange cuts last char like a BITCH!
            return [description substringWithRange:range];
        }
    }
    return nil;
}

+ (NSString *)lineNamed:(NSString *)name index:(int)index fromTextDescription:(NSString *)description
{
    NSError *error = nil;
    NSString *pattern = [NSString stringWithFormat:kIndexedLineFormat, name, index];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                             error:&error];
    if (error) {
        NSLog(@"ERROR! ASEConverter: %@", error);
    }
    else {
        NSArray *resultRegex = [regex matchesInString:description options:0 range:NSMakeRange(0, description.length)];
        if (resultRegex.count) {
            NSRange range = [(NSTextCheckingResult *)resultRegex[0] range];
            range.length += 1;      // substringWithRange cuts last char like a BITCH!
            return [description substringWithRange:range];
        }
    }
    return nil;
}

+ (NSString *)stringValueNamed:(NSString *)name fromTextDescription:(NSString *)description
{
    NSString *line = [self lineNamed:name fromTextDescription:description];
    if (line) {
        NSRange start = [line rangeOfString:[NSString stringWithFormat:@"*%@ \"", name]];
        NSRange end = [line rangeOfString:@"\"\n"];
        return [line substringWithRange:NSMakeRange(start.location + start.length, end.location - start.location - start.length)];
    }
    return nil;
}

+ (NSNumber *)numberValueNamed:(NSString *)name fromTextDescription:(NSString *)description
{
    NSString *line = [self lineNamed:name fromTextDescription:description];
    if (line) {
        NSRange start = [line rangeOfString:[NSString stringWithFormat:@"*%@ ", name]];
        if (start.length == 0)
            start = [line rangeOfString:[NSString stringWithFormat:@"*%@\t", name]];
        NSRange end = [line rangeOfString:@"\n"];
        NSString *valueStr = [line substringWithRange:NSMakeRange(start.location + start.length, end.location - start.location - start.length)];
        return @([valueStr floatValue]);
    }
    return nil;
}

+ (NSArray *)valueListNamed:(NSString *)name fromTextDescription:(NSString *)description
{
    NSString *line = [self lineNamed:name fromTextDescription:description];
    if (line) {
        NSRange nameRange = [line rangeOfString:name];
        NSString *listStr = [line substringFromIndex:nameRange.location + nameRange.length];
        listStr = [listStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t\n"]];
        NSArray *list = [listStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t"]];
        list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
        NSMutableArray *values = [NSMutableArray array];
        for (NSString *str in list) {
            [values addObject:@(str.floatValue)];
        }
        return values;
    }
    return nil;
}

+ (NSArray *)valueListNamed:(NSString *)name index:(int)index fromTextDescription:(NSString *)description
{
    NSString *line = [self lineNamed:name index:index fromTextDescription:description];
    if (line) {
        NSRange nameRange = [line rangeOfString:name];
        NSString *listStr = [line substringFromIndex:nameRange.location + nameRange.length];
        listStr = [listStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t\n"]];
        NSArray *list = [listStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t"]];
        list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
        NSMutableArray *values = [NSMutableArray array];
        for (int i = 1; i < list.count; i++) {          // skiping index
            [values addObject:@([list[i] floatValue])];
        }
        return values;
    }
    return nil;
}

+ (NSDictionary *)valueDictionaryNamed:(NSString *)name index:(int)index fromTextDescription:(NSString *)description
{
    NSString *line = [self lineNamed:name index:index fromTextDescription:description];
    if (line) {
        NSRange nameRange = [line rangeOfString:name];
        NSString *listStr = [line substringFromIndex:nameRange.location + nameRange.length];
        listStr = [listStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t\n"]];
        NSArray *list = [listStr componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t:"]];
        list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
        NSMutableDictionary *values = [NSMutableDictionary dictionary];
        for (int i = 1; i < list.count-1; i+=2) {       
            [values setObject:@([list[i+1] floatValue]) forKey:list[i]];
        }
        return values;
    }
    return nil;
}

+ (NSString *)normalizeTextDescription:(NSString *)description
{
    return [description stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
}

@end
