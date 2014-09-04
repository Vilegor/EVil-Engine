//
//  GraphObjectGroup.h
//  Trans Ball
//
//  Created by Egor Vilkin on 8/28/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "GraphFace.h"
#import "GraphObject.h"
#import "GraphDrawableProtocol.h"

@interface GraphObjectGroup : GraphObject

@property(nonatomic, weak) GraphObjectGroup *parent;

- (instancetype)initWithName:(NSString *)name;
+ (GraphObjectGroup *)groupWithName:(NSString *)groupName;

@property(nonatomic, readonly, getter = childCount) NSInteger childCount;
@property(nonatomic, readonly, getter = allChildren) NSArray *allChildren;
- (void)addChild:(GraphObject *)child;
- (void)removeChild:(NSString *)childName;
- (GraphObject *)childByName:(NSString *)childName;

@end
