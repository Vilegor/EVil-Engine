//
//  GraphVertex.c
//  Trans Ball
//
//  Created by Egor Vilkin on 8/5/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "EVEGraphVertex.h"

EVEVertexStruct VertexMake(GLfloat data[VERTEX_DATA_SIZE]) {
    EVEVertexStruct vertex;
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

GLfloat* VertexData(EVEVertexStruct vertex) {
	GLfloat *data = calloc(VERTEX_DATA_SIZE, sizeof(GLfloat));
	
	data[0] = vertex.x;
	data[1] = vertex.y;
    data[2] = vertex.z;
    
    data[3] = vertex.nx;
	data[4] = vertex.ny;
    data[5] = vertex.nz;
    
    data[6] = vertex.r;
	data[7] = vertex.g;
    data[8] = vertex.b;
    data[9] = vertex.a;
    
    data[10] = vertex.tex_x;
    data[11] = vertex.tex_y;
	
	return data;
}

BOOL VertexCompare(EVEVertexStruct v1, EVEVertexStruct v2) {
	if (VerteciesRange(v1, v2) > MAX_RANGE_LIMIT)
		return NO;
	
	GLfloat *d1 = VertexData(v1);
	GLfloat *d2 = VertexData(v2);
	for (int i = 3; i < VERTEX_DATA_SIZE; i++) {
		if (d1[i] != d2[i]) {
            free(d1);
            free(d2);
			return NO;
        }
    }
	
    free(d1);
    free(d2);
	return YES;
}

GLfloat VerteciesRange(EVEVertexStruct v1, EVEVertexStruct v2) {
	GLfloat dx = v1.x - v2.x;
	GLfloat dy = v1.y - v2.y;
	GLfloat dz = v1.z - v2.z;
	
	GLfloat lxy = sqrtf(dx*dx + dy*dy);
	return sqrtf(lxy*lxy + dz*dz);
}