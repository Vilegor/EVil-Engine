//
//  GraphFace.m
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphFace.h"

@interface GraphFace() {
    GLfloat *_vertexData;
    GLuint _vertexCount;
}
@end

@implementation GraphFace

+ (GraphFace *)faceWithID:(GLuint)faceID andVertices:(NSArray *)vertices
{
    return [[GraphFace alloc] initWithID:faceID andVertices:vertices];
}

- (id)initWithID:(GLuint)faceID andVertices:(NSArray *)vertices
{
    self = [super init];
    if (self) {
        _faceID = faceID;
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
