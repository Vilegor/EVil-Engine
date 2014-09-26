//
//  GraphVertex.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import <GLKit/GLKit.h>

#define EVE_VERTEX_DATA_SIZE 12
#define EVE_MAX_RANGE_LIMIT 0.05f

typedef struct
{
    GLfloat x;
    GLfloat y;
    GLfloat z;
    
    GLfloat nx;
    GLfloat ny;
    GLfloat nz;
    
    GLubyte r;
    GLubyte g;
    GLubyte b;
    GLubyte a;
    
    GLfloat u;
    GLfloat v;
    
} EVEVertexStruct;

EVEVertexStruct EVEVertexMake(GLfloat data[EVE_VERTEX_DATA_SIZE]);
GLfloat* EVEVertexData(EVEVertexStruct vertex);
BOOL EVEVertexCompare(EVEVertexStruct v1, EVEVertexStruct v2);
GLfloat EVEVerteciesRange(EVEVertexStruct v1, EVEVertexStruct v2);