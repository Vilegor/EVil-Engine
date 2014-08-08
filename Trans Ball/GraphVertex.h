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
    
    GLubyte tex_x;
    GLubyte tex_y;
    
} VertexStruct;

VertexStruct VertexMake(GLfloat data[VERTEX_DATA_SIZE]);
GLfloat* VertexData(VertexStruct vertex);
BOOL VertexCompare(VertexStruct v1, VertexStruct v2);
GLfloat VerteciesRange(VertexStruct v1, VertexStruct v2);