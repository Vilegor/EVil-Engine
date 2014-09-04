//
//  GraphVertex.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#define VERTEX_DATA_SIZE 12
#define MAX_RANGE_LIMIT 0.05f

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
    
    GLfloat tex_x;
    GLfloat tex_y;
    
} EVEVertexStruct;

EVEVertexStruct VertexMake(GLfloat data[VERTEX_DATA_SIZE]);
GLfloat* VertexData(EVEVertexStruct vertex);
BOOL VertexCompare(EVEVertexStruct v1, EVEVertexStruct v2);
GLfloat VerteciesRange(EVEVertexStruct v1, EVEVertexStruct v2);