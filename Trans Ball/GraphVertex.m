//
//  GraphVertex.c
//  Trans Ball
//
//  Created by Egor Vilkin on 8/5/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphVertex.h"

VertexStruct VertexMake(GLfloat data[VERTEX_DATA_SIZE]) {
    VertexStruct vertex;
    vertex.x = data[0];
    vertex.y = data[1];
    vertex.z = data[2];
    
    vertex.nx = data[3];
    vertex.ny = data[4];
    vertex.nz = data[5];
    
    vertex.r = data[6];
    vertex.g = data[7];
    vertex.b = data[8];
    vertex.a = data[9];
    
    vertex.tex_x = data[10];
    vertex.tex_y = data[11];
    
    return vertex;
}