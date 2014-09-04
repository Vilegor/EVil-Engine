//
//  GraphObjectGroup.m
//  Trans Ball
//
//  Created by Egor Vilkin on 8/28/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "EVEGraphObject.h"
#import "EVEGraphObject.h"

@interface EVEGraphObject() {
    NSMutableDictionary *_childDictionary;
}
@end

@implementation EVEGraphObject

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name;
        _childDictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}

+ (EVEGraphObject *)groupWithName:(NSString *)groupName
{
    return [[EVEGraphObject alloc] initWithName:groupName];
}

#pragma mark - Group

- (void)setParent:(EVEGraphObject *)parent
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

- (void)addChild:(EVEGraphMesh *)child
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

- (EVEGraphMesh *)childByName:(NSString *)childName
{
    if (childName) {
        return _childDictionary[childName];
    }
    return nil;
}

#pragma mark - Material

- (void)setMaterial:(EVEGraphMaterial *)material
{
    for (EVEGraphMesh *obj in _childDictionary.allValues) {
        obj.material = material;
    }
}

- (EVEGraphMaterial *)material
{
    EVEGraphMaterial *lastMaterial;
    for (EVEGraphMesh *obj in _childDictionary.allValues) {
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
    for (EVEGraphMesh *obj in _childDictionary.allValues) {
        [obj draw];
    }
    
}

- (void)resetDrawableData
{
    for (EVEGraphMesh *obj in _childDictionary.allValues) {
        [obj resetDrawableData];
    }

}

@end
