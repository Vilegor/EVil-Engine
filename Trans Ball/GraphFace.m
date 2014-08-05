//
//  GraphFace.m
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphFace.h"

@interface GraphFace() {
    VertexStruct *_vertexData;
    size_t _vertexCount;
}
@end

@implementation GraphFace

+ (GraphFace *)faceWithID:(GLuint)faceID andVertices:(VertexStruct *)vertices vsize:(size_t)count
{
    return [[GraphFace alloc] initWithID:faceID andVertices:vertices vsize:count];
}

- (id)initWithID:(GLuint)faceID andVertices:(VertexStruct *)vertices vsize:(size_t)count
{
    self = [super init];
    if (self) {
        _faceID = faceID;
        _vertexCount = count;
        _vertexData = calloc(_vertexCount, sizeof(VertexStruct));
        for (int i = 0; i < _vertexCount; i++)
            _vertexData[i] = vertices[i];
    }
    
    return self;
}

- (VertexStruct *)vertexData
{
    VertexStruct *tmp = calloc(_vertexCount, sizeof(VertexStruct));
    for (int i = 0; i < _vertexCount; i++)
        tmp[i] = _vertexData[i];
    
    return tmp;
}

- (size_t)vertexCount
{
    return _vertexCount;
}

@end
