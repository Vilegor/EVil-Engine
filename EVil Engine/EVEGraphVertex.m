//
//  GraphVertex.c
//  Trans Ball
//
//  Created by Egor Vilkin on 8/5/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "EVEGraphVertex.h"

EVEVertexStruct EVEVertexMake(GLfloat data[EVE_VERTEX_DATA_SIZE]) {
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
    
    vertex.u = data[10];
    vertex.v = data[11];
    
    return vertex;
}

GLfloat* EVEVertexData(EVEVertexStruct vertex) {
	GLfloat *data = calloc(EVE_VERTEX_DATA_SIZE, sizeof(GLfloat));
	
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
    
    data[10] = vertex.u;
    data[11] = vertex.v;
	
	return data;
}

BOOL EVEVertexCompare(EVEVertexStruct v1, EVEVertexStruct v2) {
	if (EVEVerteciesRange(v1, v2) > EVE_MAX_RANGE_LIMIT)
		return NO;
	
	GLfloat *d1 = EVEVertexData(v1);
	GLfloat *d2 = EVEVertexData(v2);
	for (int i = 3; i < EVE_VERTEX_DATA_SIZE; i++) {
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

GLfloat EVEVerteciesRange(EVEVertexStruct v1, EVEVertexStruct v2) {
	GLfloat dx = v1.x - v2.x;
	GLfloat dy = v1.y - v2.y;
	GLfloat dz = v1.z - v2.z;
	
	GLfloat lxy = sqrtf(dx*dx + dy*dy);
	return sqrtf(lxy*lxy + dz*dz);
}