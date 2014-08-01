//
//  GraphObject.m
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphObject.h"
#import "GraphFace.h"
#define MAX_RANGE_LIMIT 0.05f

@interface GraphObject() {
    GLuint _vertexBuffer;
    GLfloat *_vertexData;   // 1 vertex = 10 GLfloat
    GLuint _vertexCount;
    NSMutableDictionary *_meshDictionary;
}

@end

@implementation GraphObject

+ (GraphObject *)objectWithName:(NSString *)objectName andMeshes:(NSArray *)meshes
{
    return [[GraphObject alloc] initWithName:objectName andMeshes:meshes];
}

- (id)initWithName:(NSString *)objectName andMeshes:(NSArray *)meshes
{
    self = [super init];
    if (self) {
        _name = objectName;
        _vertexCount = 0;
        _meshDictionary = [NSMutableDictionary dictionary];
        for (GraphMesh *m in meshes) {
            if ([_meshDictionary objectForKey:m.name])
                NSLog(@"WARNING! Mesh name '%@' is already in use!", m.name);
            else {
                _vertexCount += m.vertexCount;
                [_meshDictionary setObject:m forKey:m.name];
            }
        }
        _vertexBuffer = 0;
        [self resetDrawableData];
    }
    
    return self;
}

- (void)setupVertexData
{
    _vertexData = calloc(_vertexCount, sizeof(GLfloat));
    NSArray *meshes = [_meshDictionary allValues];
    int v = 0;
    for (GraphMesh *m in meshes) {
        for (int i = 0; i < m.vertexCount; i++) {
            for (int j = 0; j < VERTEX_DATA_SIZE; j++)
                _vertexData[v] = m.vertexData[i*VERTEX_DATA_SIZE + j];
        }
    }
    
    [self minimizeVertexCount:MAX_RANGE_LIMIT];
}

- (void)setupGL
{
    if (!_vertexBuffer)
        glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*3, _vertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, 0);
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, 0);
}


- (void)minimizeVertexCount:(GLfloat)limit
{
    
}

- (GraphMesh *)meshByName:(NSString *)meshName
{
    return _meshDictionary[meshName];
}

- (GLuint)meshCount
{
    return [_meshDictionary count];
}

- (void)draw
{
    glDrawArrays(GL_TRIANGLE_FAN, 0, _vertexCount);
}

- (void)resetDrawableData
{
    [self setupVertexData];
    [self setupGL];
}

@end
