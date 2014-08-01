//
//  GraphFace.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "GraphVertex.h"

@interface GraphFace : NSObject     // always triangle face

@property(nonatomic, readonly) GLuint faceID;
@property(nonatomic, readonly) GLfloat *vertexData;
@property(nonatomic, readonly) GLuint vertexCount;

+ (GraphFace *)faceWithID:(GLuint)faceID andVertices:(NSArray *)vertices;
- (id)initWithID:(GLuint)faceID andVertices:(NSArray *)vertices;

@end
