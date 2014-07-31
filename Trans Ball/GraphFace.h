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

@property(nonatomic, readonly) GLint faceID;
@property(nonatomic, readonly) GLfloat *vertexData;

+ (GraphFace *)faceWithID:(GLint)faceID vertexes:(NSArray *)vertexex;
- (id)initWithID:(GLint)faceID vertexes:(NSArray *)vertexex;

@end
