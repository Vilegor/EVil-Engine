//
//  GraphMesh.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//
#import "GraphFace.h"

@interface GraphMesh : NSObject

+ (GraphMesh *)meshWithName:(NSString *)meshName andFaces:(NSArray *)faces;
- (id)initWithName:(NSString *)meshName andFaces:(NSArray *)faces;

@end
