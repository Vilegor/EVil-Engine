//
//  GraphMesh.m
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphMesh.h"

@implementation GraphMesh

+ (GraphMesh *)meshWithName:(NSString *)meshName andFaces:(NSArray *)faces
{
    return [[GraphMesh alloc] initWithName:meshName andFaces:faces];
}
- (id)initWithName:(NSString *)meshName andFaces:(NSArray *)faces
{
    self = [super init];
    if (self) {
        
        
        glBindBuffer(GL_ARRAY_BUFFER, *_vb);
        glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*3, _vertex, GL_STATIC_DRAW);
        
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, 0);
        
        GLuint nb;
        glGenBuffers(1, &nb);
        glBindBuffer(GL_ARRAY_BUFFER, nb);
        glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*3*3, _normal, GL_STATIC_DRAW);
        
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, 0);
    }
}

@end
