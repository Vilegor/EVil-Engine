//
//  GraphVertex.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#define VERTEX_DATA_SIZE 10

@interface GraphVertex : NSObject

@property(nonatomic, readonly) GLfloat x;
@property(nonatomic, readonly) GLfloat y;
@property(nonatomic, readonly) GLfloat z;

@property(nonatomic, readonly) GLfloat *coordArray;
@property(nonatomic, readonly) GLfloat *normalArray;
@property(nonatomic, readonly) GLfloat *colorArray;
@property(nonatomic, readonly) GLfloat *dataArray;

+ (GraphVertex *)vertexWithData:(GLfloat *)data;
- (id)initWithDataArray:(GLfloat *)data;

@end
