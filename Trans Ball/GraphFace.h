//
//  GraphMesh.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphVertex.h"

@class GraphObject;
@interface GraphFace : NSObject

@property(weak, nonatomic) GraphObject *parent;
@property(nonatomic, readonly) NSNumber *faceId;
@property(nonatomic, readonly) VertexStruct *vertexData;
@property(nonatomic, readonly) size_t vertexCount;

+ (GraphFace *)faceWithId:(NSInteger)faceId andVertices:(VertexStruct *)vertices vsize:(size_t)count;

@end
