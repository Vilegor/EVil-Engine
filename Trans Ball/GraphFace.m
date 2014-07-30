//
//  GraphFace.m
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphFace.h"

@interface GraphFace() {
    NSMutableArray *_vertex;
    GLfloat *_normal;
}
@end

@implementation GraphFace

- (id)initWithID:(GLint)faceID vertexes:(NSArray *)vertexex andNormal:(GLfloat *)normal
{
    self = [super init];
    if (self) {
        _faceID = faceID;
        _vertex = [[NSMutableArray alloc] initWithArray:vertexex];
        _normal = calloc(3, sizeof(GLfloat));   // XYZ
        
        _normal[0] = normal[0];
        _normal[1] = normal[1];
        _normal[2] = normal[2];
    }
    
    return self;
}

- (NSArray *)vertexArray
{
    return [NSArray arrayWithArray:_vertex];
}

- (GLfloat *)normalArray
{
    GLfloat *tmp = calloc(3, sizeof(GLfloat));
    tmp[0] = _normal[0];
    tmp[1] = _normal[1];
    tmp[2] = _normal[2];
    
    return tmp;
}

@end
