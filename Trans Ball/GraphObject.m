//
//  GraphObjectGroup.m
//  Trans Ball
//
//  Created by Egor Vilkin on 8/28/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphObject.h"
#import "GraphObject.h"

@interface GraphObject() {
    NSMutableDictionary *_childDictionary;
}
@end

@implementation GraphObject

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name;
        _childDictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}

+ (GraphObject *)groupWithName:(NSString *)groupName
{
    return [[GraphObject alloc] initWithName:groupName];
}

#pragma mark - Group

- (void)setParent:(GraphObject *)parent
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

- (void)addChild:(GraphMesh *)child
{
    if (!child || !child.name) {
        NSLog(@"ERROR! %@<ADD>: Child is nil!", self.name);
        return;
    }
    if ([_childDictionary objectForKey:child.name])
        NSLog(@"WARNING! %@: Object name '%@' is already in use!", self.name, child.name);
    else {
        [_childDictionary setObject:child forKey:child.name];
    }
}

- (void)removeChild:(NSString *)childName
{
    if (childName) {
        [_childDictionary removeObjectForKey:childName];
    }
    else {
        NSLog(@"ERROR! %@<REMOVE>: ChildName is nil!", self.name);
    }
}

- (GraphMesh *)childByName:(NSString *)childName
{
    if (childName) {
        return _childDictionary[childName];
    }
    return nil;
}

#pragma mark - Material

- (void)setMaterial:(GraphMaterial *)material
{
    for (GraphMesh *obj in _childDictionary.allValues) {
        obj.material = material;
    }
}

- (GraphMaterial *)material
{
    GraphMaterial *lastMaterial;
    for (GraphMesh *obj in _childDictionary.allValues) {
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
    for (GraphMesh *obj in _childDictionary.allValues) {
        [obj draw];
    }
    
}

- (void)resetDrawableData
{
    for (GraphMesh *obj in _childDictionary.allValues) {
        [obj resetDrawableData];
    }

}

@end
