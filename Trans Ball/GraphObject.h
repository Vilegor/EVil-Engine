//
//  GraphObject.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "GraphMesh.h"
#import "GraphDrawableProtocol.h"

@class GraphModel;
@interface GraphObject : NSObject <GraphDrawableProtocol>

@property(weak, nonatomic) GraphModel *parent;
@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic, readonly) GLfloat *vertexData;
@property(nonatomic, readonly) GLuint vertexCount;

+ (GraphObject *)objectWithName:(NSString *)objectName andMeshes:(NSArray *)meshes;
- (id)initWithName:(NSString *)objectName andMeshes:(NSArray *)meshes;

- (GraphMesh *)meshByName:(NSString *)meshName;
- (GLuint)meshCount;

@end
