//
//  GraphObject.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphDrawableProtocol.h"
#import "GraphMaterial.h"
#import "GraphVertex.h"

@interface GraphMesh : NSObject <GraphDrawableProtocol> {
    NSString *_name;
}

@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic, readonly) VertexStruct *vertexData;
@property(nonatomic, readonly) GLuint vertexCount;
@property(nonatomic, strong) GraphMaterial *material;

+ (GraphMesh *)meshWithName:(NSString *)name
                   vertices:(VertexStruct *)vertices
                vertexCount:(int)vcount
                    indices:(GLubyte *)indices
                 indexCount:(int)icount;

@end
