//
//  GraphMesh.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphFace.h"

@class GraphObject;
@interface GraphMesh : NSObject

@property(weak, nonatomic) GraphObject *parent;
@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic, readonly) VertexStruct *vertexData;
@property(nonatomic, readonly) size_t vertexCount;

+ (GraphMesh *)meshWithName:(NSString *)meshName andFaces:(NSArray *)faces;
+ (GraphMesh *)meshWithName:(NSString *)meshName andVertices:(VertexStruct *)vertices vsize:(size_t)count;

@end
