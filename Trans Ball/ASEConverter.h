//
//  ASEConverter.h
//  Trans Ball
//
//  Created by Egor Vilkin on 8/29/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

@interface ASEConverter : NSObject

+ (NSString *)stringValueNamed:(NSString *)name fromTextDescription:(NSString *)description;
+ (NSNumber *)numberValueNamed:(NSString *)name fromTextDescription:(NSString *)description;
+ (NSArray *)valueListNamed:(NSString *)name fromTextDescription:(NSString *)description;
+ (NSArray *)valueListNamed:(NSString *)name index:(NSInteger)index fromTextDescription:(NSString *)description;
+ (NSDictionary *)valueDictionaryNamed:(NSString *)name index:(NSInteger)index fromTextDescription:(NSString *)description;

@end