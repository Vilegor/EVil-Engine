//
//  GraphObjectGroup.m
//  Trans Ball
//
//  Created by Egor Vilkin on 8/28/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphObjectGroup.h"
#import "GraphObjectGroup.h"

@interface GraphObjectGroup() {
    NSMutableDictionary *_childDictionary;
}

@end

@implementation GraphObjectGroup

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _childDictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}

+ (GraphObjectGroup *)groupWithName:(NSString *)groupName
{
    return [[GraphObjectGroup alloc] initWithName:groupName];
}

#pragma mark - Group

- (void)setParent:(GraphObjectGroup *)parent
{
    if (parent != _parent)
        [parent removeChild:self.name];
    _parent = parent;
    [_parent addChild:self];
}

- (NSInteger)childCount
{
    return _childDictionary.count;
}

- (NSArray *)allChildren
{
    return _childDictionary.allValues;
}

- (void)addChild:(GraphObject *)child
{
    if ([_childDictionary objectForKey:child.name])
        NSLog(@"WARNING! %@: Object name '%@' is already in use!", self.name, child.name);
    else {
        [_childDictionary setObject:child forKey:child.name];
    }
}

- (void)removeChild:(NSString *)childName
{
    [_childDictionary removeObjectForKey:childName];
}

- (GraphObject *)childByName:(NSString *)childName
{
    return _childDictionary[childName];
}

#pragma mark - Material

- (void)setMaterial:(GraphMaterial *)material
{
    for (GraphObject *obj in _childDictionary.allValues) {
        obj.material = material;
    }
}

- (GraphMaterial *)material
{
    GraphMaterial *lastMaterial;
    for (GraphObject *obj in _childDictionary.allValues) {
        if (!lastMaterial)
            lastMaterial = obj.material;
        else if (![lastMaterial isEqual:obj.material])
            return nil;
    }
    return lastMaterial;
}

#pragma mark - GraphDrawableProtocol

- (void)draw
{
    for (GraphObject *obj in _childDictionary.allValues) {
        [obj draw];
    }
    
}

- (void)resetDrawableData
{
    for (GraphObject *obj in _childDictionary.allValues) {
        [obj resetDrawableData];
    }

}

@end
