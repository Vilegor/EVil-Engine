//
//  GraphObjectGroup.h
//  Trans Ball
//
//  Created by Egor Vilkin on 8/28/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "GraphMesh.h"
#import "GraphDrawableProtocol.h"

@interface GraphObject : GraphMesh

@property(nonatomic, weak) GraphObject *parent;

- (instancetype)initWithName:(NSString *)name;
+ (GraphObject *)groupWithName:(NSString *)groupName;

@property(nonatomic, readonly, getter = childCount) NSInteger childCount;
@property(nonatomic, readonly, getter = allChildren) NSArray *allChildren;
- (void)addChild:(GraphMesh *)child;
- (void)removeChild:(NSString *)childName;
- (GraphMesh *)childByName:(NSString *)childName;

@end
