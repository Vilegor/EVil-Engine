//
//  ASEConverter.h
//  Trans Ball
//
//  Created by Egor Vilkin on 8/29/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#define ASE_FACE_SIZE 3

@interface EVEASEConverter : NSObject

+ (NSArray *)objectsDescriptionFromFile:(NSString *)aseFileName;
+ (NSArray *)materialsDescriptionFromFile:(NSString *)aseFileName;

+ (NSString *)stringValueNamed:(NSString *)name fromTextDescription:(NSString *)description;
+ (NSNumber *)numberValueNamed:(NSString *)name fromTextDescription:(NSString *)description;
+ (NSArray *)valueListNamed:(NSString *)name fromTextDescription:(NSString *)description;
+ (NSArray *)valueListNamed:(NSString *)name atIndex:(int)index fromTextDescription:(NSString *)description;
+ (NSDictionary *)valueDictionaryNamed:(NSString *)name atIndex:(int)index fromTextDescription:(NSString *)description;

+ (NSArray *)allMatchedValuesListNamed:(NSString *)name atIndex:(int)index fromTextDescription:(NSString *)description;

@end