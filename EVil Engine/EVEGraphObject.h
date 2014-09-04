//
//  GraphObjectGroup.h
//  Trans Ball
//
//  Created by Egor Vilkin on 8/28/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "EVEGraphMesh.h"
#import "EVEGraphDrawableProtocol.h"

@interface EVEGraphObject : EVEGraphMesh

@property(nonatomic, weak) EVEGraphObject *parent;

- (instancetype)initWithName:(NSString *)name;
+ (EVEGraphObject *)groupWithName:(NSString *)groupName;

@property(nonatomic, readonly, getter = childCount) NSInteger childCount;
@property(nonatomic, readonly, getter = allChildren) NSArray *allChildren;
- (void)addChild:(EVEGraphMesh *)child;
- (void)removeChild:(NSString *)childName;
- (EVEGraphMesh *)childByName:(NSString *)childName;

@end
