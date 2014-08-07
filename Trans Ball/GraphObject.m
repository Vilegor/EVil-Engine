//
//  GraphObject.m
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphObject.h"
#import "GraphFace.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define MAX_RANGE_LIMIT 0.05f

@interface GraphObject() {
    GLuint _vertexBuffer;
    VertexStruct *_vertexData;   // 1 vertex = 10 GLfloat
    GLuint _vertexCount;
    NSMutableDictionary *_meshDictionary;
    GraphMaterial *_material;
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
        [self resetDrawableData];
    }
    
    return self;
}

- (void)setupVertexData
{
    if (_vertexData)
        free(_vertexData);
    _vertexData = calloc(_vertexCount, sizeof(VertexStruct));
    NSArray *meshes = [_meshDictionary allValues];
    int v = 0;
    for (GraphMesh *m in meshes) {
        for (int i = 0; i < m.vertexCount; i++) {
            _vertexData[v++] = m.vertexData[i];
        }
    }
    
    [self minimizeVertexCount:MAX_RANGE_LIMIT];
}

- (void)setupGL
{
    if (!_vertexBuffer)
        glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(VertexStruct)*_vertexCount, _vertexData, GL_STATIC_DRAW);
}

- (void)minimizeVertexCount:(GLfloat)limit
{
    
}

- (GraphMesh *)meshByName:(NSString *)meshName
{
    return _meshDictionary[meshName];
}

- (NSInteger)meshCount
{
    return [_meshDictionary count];
}

- (void)draw
{
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(VertexStruct), (void*)offsetof(VertexStruct, x));
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(VertexStruct), (void*)offsetof(VertexStruct, nx));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(VertexStruct), (void*)offsetof(VertexStruct, r));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(VertexStruct), (void*)offsetof(VertexStruct, tex_x));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    [_material enable];
    glDrawArrays(GL_TRIANGLE_FAN, 0, _vertexCount);
    [_material disable];
}

- (void)setMaterial:(GraphMaterial *)material
{
    @synchronized(self) {
        if (!material)
            [_material disable];
        _material = material;
        [material load];
    }
}

- (GraphMaterial *)material
{
    @synchronized(self) {
        return _material;
    }
}

- (void)resetDrawableData
{
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
    }
    
    [self setupVertexData];
    [self setupGL];
}

- (void)dealloc
{
    glDeleteBuffers(1, &_vertexBuffer);
}

@end
