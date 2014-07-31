//
//  GraphVertex.m
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphVertex.h"

@interface GraphVertex() {
    GLfloat *_data;
}
@end

@implementation GraphVertex

+ (GraphVertex *)vertexWithData:(GLfloat *)data
{
    return [[GraphVertex alloc] initWithDataArray:data];
}

- (id)initWithDataArray:(GLfloat *)data         // data[10] = xyz nxnynz rgba
{
    self = [super init];
    if (self) {
        _data = calloc(VERTEX_DATA_SIZE, sizeof(GLfloat));
        for (int i = 0; i < VERTEX_DATA_SIZE; i++)
            _data[i] = data[i];
    }
    return self;
}

- (GLfloat *)coordArray
{
    GLfloat *tmp = calloc(3, sizeof(GLfloat));
    tmp[0] = _data[0];
    tmp[1] = _data[1];
    tmp[2] = _data[2];
    
    return tmp;
}

- (GLfloat *)normalArray
{
    GLfloat *tmp = calloc(3, sizeof(GLfloat));
    tmp[0] = _data[3];
    tmp[1] = _data[4];
    tmp[2] = _data[5];
    
    return tmp;
}

- (GLfloat *)colorArray
{
    GLfloat *tmp = calloc(4, sizeof(GLfloat));
    tmp[0] = _data[6];
    tmp[1] = _data[7];
    tmp[2] = _data[8];
    tmp[3] = _data[9];
    
    return tmp;
}

- (GLfloat *)dataArray
{
    GLfloat *tmp = calloc(VERTEX_DATA_SIZE, sizeof(GLfloat));
    for (int i = 0; i < VERTEX_DATA_SIZE; i++)
        tmp[i] = _data[i];
    
    return tmp;
}

- (GLfloat)x
{
    return _data[0];
}
- (GLfloat)y
{
    return _data[1];
}
- (GLfloat)z
{
    return _data[2];
}

@end
