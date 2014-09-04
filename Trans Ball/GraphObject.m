//
//  GraphObject.m
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphObject.h"
#import "GraphModel.h"

@interface GraphObject() {
    GLuint _vertexBuffer;
    VertexStruct *_vertexData;
    GLuint _vertexCount;
	
	GLubyte *_indices;
	GLuint _indexCount;
	
    NSMutableDictionary *_faceDictionary;
    GraphMaterial *_material;
}

@end

@implementation GraphObject

@synthesize name = _name;

+ (GraphObject *)objectWithName:(NSString *)objectName andFaces:(NSArray *)faces
{
    return [[GraphObject alloc] initWithName:objectName andFaces:faces];
}

- (id)initWithName:(NSString *)objectName andFaces:(NSArray *)faces
{
    self = [super init];
    if (self) {
        _name = objectName;
        _vertexCount = 0;
        _faceDictionary = [NSMutableDictionary dictionary];
        for (GraphFace *f in faces) {
            if ([_faceDictionary objectForKey:f.faceId])
                NSLog(@"WARNING! %@: Face #%d is already in use!", _name, f.faceId.intValue);
            else {
                _vertexCount += f.vertexCount;
                [_faceDictionary setObject:f forKey:f.faceId];
            }
        }
        [self resetDrawableData];
    }
    
    return self;
}

+ (GraphObject *)objectWithName:(NSString *)objectName
                       vertices:(VertexStruct *)vertices
                    vertexCount:(int)vcount
                        indices:(GLubyte *)indices
                    vertexCount:(int)icount
{
    return [[GraphObject alloc] initWithName:objectName vertices:vertices vertexCount:vcount indices:indices vertexCount:icount];
}

- (id)initWithName:(NSString *)objectName
          vertices:(VertexStruct *)vertices
       vertexCount:(int)vcount
          indices:(GLubyte *)indices
       vertexCount:(int)icount
{
    self = [super init];
    if (self) {
        _name = objectName;
        _vertexCount = vcount;
        _vertexData = vertices;
        _indexCount = icount;
        _indices = indices;
        [self resetDrawableData];
    }
    
    return self;
}

- (void)dealloc
{
    glDeleteBuffers(1, &_vertexBuffer);
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

- (void)setupVertexData
{
    if (!_faceDictionary)   // was initialised with vertex and index arrays, so data already ready to use
        return;
    
    if (_vertexData)
        free(_vertexData);
    if (!_vertexCount)
        return;
    
    _vertexData = calloc(_vertexCount, sizeof(VertexStruct));
    NSArray *meshes = [_faceDictionary allValues];
    int v = 0;
    for (GraphFace *m in meshes) {
        for (int i = 0; i < m.vertexCount; i++) {
            _vertexData[v++] = m.vertexData[i];
        }
    }
    [self minimizeVertexCount];     // removes duplicates and creates index array
}

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
			if (VertexCompare(_vertexData[i], _vertexData[j])) {
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
	VertexStruct *newVertexArray = calloc(_vertexCount, sizeof(VertexStruct));
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

#pragma mark - GL usage

- (void)setupGL
{
    if (!_vertexBuffer)
        glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(VertexStruct)*_vertexCount, _vertexData, GL_STATIC_DRAW);
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
    
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(VertexStruct), (void*)offsetof(VertexStruct, tex_x));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    
    [_material enable];
	glDrawElements(GL_TRIANGLES, _indexCount, GL_UNSIGNED_BYTE, _indices);
    [_material disable];
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

#pragma mark - Meshes

- (GraphFace *)meshByName:(NSString *)meshName
{
    return _faceDictionary[meshName];
}

- (NSInteger)meshCount
{
    return [_faceDictionary count];
}

#pragma mark - Material

- (void)setMaterial:(GraphMaterial *)material
{
    if (!material)
        [_material disable];
    _material = material;
    [material load];
}

- (GraphMaterial *)material
{
    return _material;
}

@end
