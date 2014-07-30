//
//  GraphVertex.m
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphVertex.h"

@interface GraphVertex() {
    GLfloat *_coord;
    GLfloat *_normal;
    GLfloat *_color;
}
@end

@implementation GraphVertex

- (id)initWithDataArray:(GLfloat *)data         // data[10]
{
    self = [super init];
    if (self) {
        _coord = calloc(3, sizeof(GLfloat));    // XYZ
        _normal = calloc(3, sizeof(GLfloat));   // XYZ
        _color = calloc(4, sizeof(GLfloat));    // RGBA
        
        _coord[0] = data[0];
        _coord[1] = data[1];
        _coord[2] = data[2];
        
        _normal[0] = data[3];
        _normal[1] = data[4];
        _normal[2] = data[5];
        
        _color[0] = data[6];
        _color[1] = data[7];
        _color[2] = data[8];
        _color[3] = data[9];
    }
    return self;
}

- (GLfloat *)coordArray
{
    GLfloat *tmp = calloc(3, sizeof(GLfloat));
    tmp[0] = _coord[0];
    tmp[1] = _coord[1];
    tmp[2] = _coord[2];
    
    return tmp;
}

- (GLfloat *)normalArray
{
    GLfloat *tmp = calloc(3, sizeof(GLfloat));
    tmp[0] = _normal[0];
    tmp[1] = _normal[1];
    tmp[2] = _normal[2];
    
    return tmp;
}

- (GLfloat *)colorArray
{
    GLfloat *tmp = calloc(4, sizeof(GLfloat));
    tmp[0] = _color[0];
    tmp[1] = _color[1];
    tmp[2] = _color[2];
    tmp[3] = _color[3];
    
    return tmp;
}

- (GLfloat *)baseInfoArray
{
    GLfloat *tmp = calloc(6, sizeof(GLfloat));    // XYZ nXnYnZ
    tmp[0] = _coord[0];
    tmp[1] = _coord[1];
    tmp[2] = _coord[2];
    
    tmp[3] = _normal[0];
    tmp[4] = _normal[1];
    tmp[5] = _normal[2];
    
    return tmp;
}

@end
