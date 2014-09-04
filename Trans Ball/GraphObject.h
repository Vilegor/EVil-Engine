//
//  GraphObject.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphDrawableProtocol.h"
#import "GraphMaterial.h"
#import "GraphMesh.h"

@interface GraphObject : NSObject <GraphDrawableProtocol> {
    NSString *_name;
}

@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic, readonly) VertexStruct *vertexData;
@property(nonatomic, readonly) GLuint vertexCount;
@property(nonatomic, strong) GraphMaterial *material;

+ (GraphObject *)objectWithName:(NSString *)objectName andMeshes:(NSArray *)meshes;
+ (GraphObject *)objectWithName:(NSString *)objectName
                     vertices:(VertexStruct *)vertices
                  vertexCount:(int)vcount
                      indices:(GLubyte *)indices
                  vertexCount:(int)icount;

- (GraphMesh *)meshByName:(NSString *)meshName;
- (NSInteger)meshCount;

@end
