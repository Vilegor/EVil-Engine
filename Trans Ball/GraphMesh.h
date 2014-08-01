//
//  GraphMesh.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import <GLKit/GLKit.h>

@class GraphObject;
@interface GraphMesh : NSObject

@property(weak, nonatomic) GraphObject *parent;
@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic, readonly) GLfloat *vertexData;
@property(nonatomic, readonly) GLuint vertexCount;

+ (GraphMesh *)meshWithName:(NSString *)meshName andFaces:(NSArray *)faces;
+ (GraphMesh *)meshWithName:(NSString *)meshName andVertices:(NSArray *)vertices;
- (id)initWithName:(NSString *)meshName andFaces:(NSArray *)faces;
- (id)initWithName:(NSString *)meshName andVertices:(NSArray *)vertices;

@end
