//
//  GraphModel.m
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphModel.h"

@interface GraphModel() {
    NSMutableDictionary *_objectDictionary;
}
@end

@implementation GraphModel

+ (GraphModel *)emptyModel
{
    return [[GraphModel alloc] init];
}

+ (GraphModel *)modelWithName:(NSString *)modelName
{
    return [[GraphModel alloc] initWithName:modelName];
}

- (id)initWithName:(NSString *)modelName
{
    self = [super init];
    if (self) {
        _name = modelName;
        _objectDictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (GLuint)objectCount
{
    return [_objectDictionary count];
}

- (void)addObject:(GraphObject *)object
{
    [_objectDictionary setObject:object forKey:object.name];
}

- (void)removeObject:(NSString *)objectName
{
    [_objectDictionary removeObjectForKey:objectName];
}

- (GraphObject *)objectByName:(NSString *)objectName
{
    return _objectDictionary[objectName];
}

- (void)draw
{
    for (GraphObject *obj in _objectDictionary.allValues) {
        [obj draw];
    }
}

- (void)resetDrawableData
{
    for (GraphObject *obj in _objectDictionary.allValues) {
        [obj resetDrawableData];
    }
}

@end
