//
//  GraphFace.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GraphVertex.h"

@interface GraphFace : NSObject     // always triangle face

@property(nonatomic, readonly) GLint faceID;
@property(nonatomic, readonly) GLfloat *normalArray;
@property(nonatomic, readonly) NSArray *vertexArray;    // size = 3

- (id)initWithID:(GLint)faceID vertexes:(NSArray *)vertexex andNormal:(GLfloat *)normal;

@end
