//
//  GraphMesh.m
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphMesh.h"
#import "GraphFace.h"

@interface GraphMesh() {
    VertexStruct *_vertexData;
    size_t _vertexCount;
}
@end

@implementation GraphMesh

+ (GraphMesh *)meshWithName:(NSString *)meshName andFaces:(NSArray *)faces
{
    return [[GraphMesh alloc] initWithName:meshName andFaces:faces];
}

+ (GraphMesh *)meshWithName:(NSString *)meshName andVertices:(VertexStruct *)vertices vsize:(size_t)count
{
    return [[GraphMesh alloc] initWithName:meshName andVertices:vertices vsize:count];
}

- (id)initWithName:(NSString *)meshName andFaces:(NSArray *)faces
{
    self = [super init];
    if (self) {
        _name = meshName;
        _vertexCount = 0;
        for (GraphFace *f in faces)
            _vertexCount += f.vertexCount;
        if (_vertexCount)
            _vertexData = calloc(_vertexCount, sizeof(VertexStruct));
        for (int i = 0; i < _vertexCount; i++) {
            VertexStruct *f = [faces[i] vertexData];
            size_t size = [faces[i] vertexCount];
            for (int j = 0; j < size; j++)
                _vertexData[i*size + j] = f[j];
        }
    }
    
    return self;
}

- (id)initWithName:(NSString *)meshName andVertices:(VertexStruct *)vertices vsize:(size_t)count
{
    self = [super init];
    if (self) {
        _name = meshName;
        _vertexCount = count;
        _vertexData = calloc(_vertexCount, sizeof(VertexStruct));
        for (int i = 0; i < _vertexCount; i++) {
            _vertexData[i] = vertices[i];
        }
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
