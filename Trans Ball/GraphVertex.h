//
//  GraphVertex.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GraphVertex : NSObject

@property(nonatomic, readonly) GLfloat x;
@property(nonatomic, readonly) GLfloat y;
@property(nonatomic, readonly) GLfloat z;

@property(nonatomic, readonly) GLfloat *coordArray;
@property(nonatomic, readonly) GLfloat *normalArray;
@property(nonatomic, readonly) GLfloat *baseInfoArray;
@property(nonatomic, readonly) GLfloat *colorArray;

- (id)initWithDataArray:(GLfloat *)data;

@end
