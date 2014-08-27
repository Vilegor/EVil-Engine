//
//  GraphModel.m
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphModel.h"

static int modelId;

@interface GraphModel() {
    NSMutableDictionary *_objectDictionary;
}
@end

@implementation GraphModel

+ (GraphModel *)emptyModel
{
    return [[GraphModel alloc] initWithName:[NSString stringWithFormat:@"Model_%d", modelId++]];
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

- (id)initWithName:(NSString *)modelName andMeshes:(NSArray *)meshes
{
    self = [super init];
    if (self) {
        _name = modelName;
        _objectDictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (NSInteger)objectCount
{
    return [_objectDictionary count];
}

- (void)addObject:(GraphObject *)object
{
    if ([_objectDictionary objectForKey:object.name])
        NSLog(@"WARNING! %@: Object name '%@' is already in use!", _name, object.name);
    else {
        [_objectDictionary setObject:object forKey:object.name];
    }
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

- (void)setMaterial:(GraphMaterial *)material
{
    for (GraphObject *obj in _objectDictionary.allValues) {
        obj.material = material;
    }
}

- (GraphMaterial *)getMaterial
{
    GraphMaterial *lastMaterial;
    for (GraphObject *obj in _objectDictionary.allValues) {
        if (!lastMaterial)
            lastMaterial = obj.material;
        else if (![lastMaterial isEqual:obj.material])
            return nil;
    }
    return lastMaterial;
}

@end
