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
    GLfloat *_vertexData;
    GLuint _vertexCount;
}
@end

@implementation GraphMesh

+ (GraphMesh *)meshWithName:(NSString *)meshName andFaces:(NSArray *)faces
{
    return [[GraphMesh alloc] initWithName:meshName andFaces:faces];
}

+ (GraphMesh *)meshWithName:(NSString *)meshName andVertices:(NSArray *)vertices
{
    return [[GraphMesh alloc] initWithName:meshName andVertices:vertices];
}

- (id)initWithName:(NSString *)meshName andFaces:(NSArray *)faces
{
    self = [super init];
    if (self) {
        _name = meshName;
        _vertexCount = 0;
        for (GraphFace *f in faces)
            _vertexCount += f.vertexCount;
        _vertexData = calloc(_vertexCount * VERTEX_DATA_SIZE, sizeof(GLfloat));
        for (int i = 0; i < _vertexCount; i++) {
            GLfloat *f = [faces[i] vertexData];
            GLuint size = [faces[i] vertexCount]*VERTEX_DATA_SIZE;
            for (int j = 0; j < size; j++)
                _vertexData[i*size + j] = f[j];
        }
    }
    
    return self;
}

- (id)initWithName:(NSString *)meshName andVertices:(NSArray *)vertices
{
    self = [super init];
    if (self) {
        _name = meshName;
        _vertexCount = vertices.count;
        _vertexData = calloc(_vertexCount * VERTEX_DATA_SIZE, sizeof(GLfloat));
        for (int i = 0; i < _vertexCount; i++) {
            GLfloat *v = [vertices[i] dataArray];
            for (int j = 0; j < VERTEX_DATA_SIZE; j++)
                _vertexData[i*VERTEX_DATA_SIZE + j] = v[j];
        }
    }
    
    return self;
}

- (GLfloat *)vertexData
{
    GLfloat *tmp = calloc(VERTEX_DATA_SIZE * _vertexCount, sizeof(GLfloat));
    for (int i = 0; i < VERTEX_DATA_SIZE * _vertexCount; i++)
        tmp[i] = _vertexData[i];
    
    return tmp;
}

- (GLuint)vertexCount
{
    return _vertexCount;
}

@end
