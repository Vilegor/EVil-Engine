//
//  GraphObject.m
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "EVEGraphMesh.h"
#import "EVEGraphModel.h"
#import <OpenGLES/ES3/gl.h>

@interface EVEGraphMesh() {
    GLuint _vertexBuffer;
    GLuint _indexBuffer;
    GLuint _meshVBA;
    
    EVEVertexStruct *_vertexData;
    GLuint _vertexCount;
	
	GLubyte *_indices;
	GLuint _indexCount;

    EVEGraphMaterial *_material;
}

@end

@implementation EVEGraphMesh

@synthesize name = _name;

+ (EVEGraphMesh *)meshWithName:(NSString *)name
                   vertices:(EVEVertexStruct *)vertices
                vertexCount:(int)vcount
                    indices:(GLubyte *)indices
                 indexCount:(int)icount
{
    return [[EVEGraphMesh alloc] initWithName:name vertices:vertices vertexCount:vcount indices:indices indexCount:icount];
}

- (id)initWithName:(NSString *)name
          vertices:(EVEVertexStruct *)vertices
       vertexCount:(int)vcount
           indices:(GLubyte *)indices
        indexCount:(int)icount
{
    self = [super init];
    if (self) {
        _name = name;
        _vertexCount = vcount;
        _vertexData = calloc(vcount, sizeof(EVEVertexStruct));
        for (int v = 0; v < vcount; v++)
            _vertexData[v] = vertices[v];
        _indexCount = icount;
        _indices = calloc(icount, sizeof(GLubyte));
        for (int i = 0; i < icount; i++)
            _indices[i] = indices[i];
        [self resetDrawableData];
    }
    
    return self;
}

- (void)dealloc
{
    free(_vertexData);
    free(_indices);
    glDeleteBuffers(1, &_vertexBuffer);
}

- (void)resetDrawableData
{
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
        _vertexBuffer = 0;
    }
    
    [self setupGL];
}

#pragma mark - GL usage
//#define SHOW_LINES

- (void)setupGL
{
    // Create VBA
    glGenVertexArrays(1,&_meshVBA);
    glBindVertexArray(_meshVBA);
    
    // Create VBs
    if (!_vertexBuffer)
        glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(EVEVertexStruct)*_vertexCount, _vertexData, GL_STATIC_DRAW);
    
    // Configure vertex data
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(EVEVertexStruct), (void *)offsetof(EVEVertexStruct, x));
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(EVEVertexStruct), (void *)offsetof(EVEVertexStruct, nx));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_UNSIGNED_BYTE, GL_TRUE, sizeof(EVEVertexStruct), (void *)offsetof(EVEVertexStruct, r));
    glEnableVertexAttribArray(GLKVertexAttribColor);
    
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(EVEVertexStruct), (void *)offsetof(EVEVertexStruct, u));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    if (!_indexBuffer)
        glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GL_UNSIGNED_BYTE)*_indexCount, _indices, GL_STATIC_DRAW);
    
    // Clean up VBs
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}

- (void)draw
{
    glBindVertexArray(_meshVBA);
    
    [_material enable];
#ifdef SHOW_LINES
	glDrawElements(GL_LINE_LOOP, _indexCount, GL_UNSIGNED_BYTE, (void *)NULL);
#else
    glDrawElements(GL_TRIANGLES, _indexCount, GL_UNSIGNED_BYTE, (void *)NULL);
#endif
    [_material disable];
}

#pragma mark - Material

- (void)setMaterial:(EVEGraphMaterial *)material
{
    if (!material)
    [_material disable];
    _material = material;
    [material load];
}

- (EVEGraphMaterial *)material
{
    return _material;
}

#pragma mark - Additional Functionality

- (void)minimizeVertexCount
{
    _indexCount = _vertexCount;
    _indices = calloc(_indexCount, sizeof(GLubyte));
    GLubyte *used = calloc(_vertexCount, sizeof(GLubyte));
    for (int i = 0, v = 0; i < _vertexCount; i++) {
        if (used[i] != 0)
        continue;
        
        used[i] = 1;            // mark to skip
        _indices[i] = v;
        for (int j = i + 1; j < _vertexCount; j++) {
            if (EVEVertexCompare(_vertexData[i], _vertexData[j])) {
                _indices[j] = v;
                used[j] = 255;  // mark to skip then delete
            }
        }
        v++;
    }
    
    // delete vertecies
    for (int i = 0; i < _vertexCount; i++) {
        if (used[i] == 255) {
            [self deleteVertexAt:i andMark:used];
            i--;
        }
    }
    
    free(used);
}

- (void)deleteVertexAt:(int)index andMark:(GLubyte *)marksArray
{
    _vertexCount--;
    EVEVertexStruct *newVertexArray = calloc(_vertexCount, sizeof(EVEVertexStruct));
    for (int i = 0; i < _vertexCount; i++) {
        if (i >= index) {
            newVertexArray[i] = _vertexData[i+1];
            marksArray[i] = marksArray[i+1];
        }
        else {
            newVertexArray[i] = _vertexData[i];
        }
    }
    _vertexData = newVertexArray;
}

#pragma mark - Debug Methods

- (void)printArray:(GLubyte *)arr size:(int)s
{
    for (int i = 0; i < s; i++) {
        printf("%d - %d\n", i, arr[i]);
    }
}

- (void)printVertecies
{
    for (int i = 0; i < _vertexCount; i++) {
        printf("%d - (%.1f,%.1f,%.1f)\n", i, _vertexData[i].x,_vertexData[i].y,_vertexData[i].z);
    }
}

@end
