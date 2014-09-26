//
//  GraphObject.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//
#import "EVEGraphDrawableProtocol.h"
#import "EVEGraphMaterial.h"
#import "EVEGraphVertex.h"

@interface EVEGraphMesh : NSObject <EVEGraphDrawableProtocol> {
    NSString *_name;
}

@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic, readonly) EVEVertexStruct *vertexData;
@property(nonatomic, readonly) GLuint vertexCount;
@property(nonatomic, strong) EVEGraphMaterial *material;

+ (EVEGraphMesh *)meshWithName:(NSString *)name
                   vertices:(EVEVertexStruct *)vertices
                vertexCount:(int)vcount
                    indices:(GLubyte *)indices
                 indexCount:(int)icount;

@end
