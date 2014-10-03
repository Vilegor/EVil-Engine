//
//  GraphModel.m
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "EVEGraphModel.h"
#import "EVEASEConverter.h"

static int modelId;

@interface EVEGraphModel() {

}
@end

@implementation EVEGraphModel

+ (EVEGraphModel *)emptyModel
{
    return [[EVEGraphModel alloc] initWithName:[NSString stringWithFormat:@"Model_%d", modelId++]];
}

+ (EVEGraphModel *)modelWithName:(NSString *)modelName
{
    return [[EVEGraphModel alloc] initWithName:modelName];
}

#pragma mark - Load from .ASE

+ (EVEGraphModel *)modelFromASEFile:(NSString *)aseFileName
{
    NSLog(@"Start parsing file(fast): %@", aseFileName);
    NSDate *startTime = [NSDate date];
    
    EVEGraphModel *model = nil;
    ASEModelInfo *info = [EVEASEConverter modelInfoFromFile:aseFileName];
    if (info) {
        model = [EVEGraphModel modelWithName:aseFileName];
        [model setupWithASEModelInfo:info];
    }
    
    NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:startTime];
    NSLog(@"Done (in %3f sec)", delta);
    
    return model;
}

- (void)setupWithASEModelInfo:(ASEModelInfo *)aseInfo
{
    NSArray *objects = aseInfo[kObjectsKey];
    NSArray *materials = aseInfo[kMaterialsKey];
    
    for (ASEGeomObjectInfo *obj in objects) {
        EVEGraphObject *parent = nil;
        if (obj.parentName) {
            parent = (EVEGraphObject *)[self childByName:obj.parentName];
            if (!parent) {
                parent = [[EVEGraphObject alloc] initWithName:obj.parentName];
                [self addChild:parent];
            }
        }
        
        EVEGraphMesh *mesh = [EVEGraphMesh meshWithName:obj.name
                                               vertices:obj.vertices
                                            vertexCount:obj.vertexCount
                                                indices:obj.indices
                                             indexCount:obj.indexCount];
        if (obj.materialIndex >= 0) {
            ASEMaterialInfo *mat = materials[obj.materialIndex];
            mesh.material = [EVEGraphMaterial materialWithASEMaterialInfo:mat];
        }
        
        if (parent) {
            [parent addChild:mesh];
        }
        else {
            [self addChild:mesh];
        }
    }
}

#pragma mark - Test Models

+ (EVEGraphModel *)paperPlaneModel:(float)height
{
    GLfloat v0[] = {0,-1,height,			0,0,1,	255,255,255,255,	0,0};
    GLfloat v1[] = {0.1f,0.5f,height,       0,0,1,	204,204,204,255,	0.5,0};
    GLfloat v2[] = {-0.1f,0.5f,height,      0,0,1,  204,204,204,255,	0.5,0.5};
    GLfloat v3[] = {0,0.5f,height-0.3,      0,0,1,  230,230,230,255,	0,0.5};
    GLfloat v4[] = {0.8f,0.4f,height-0.1f,  0,0,1,  255,255,255,255,	0.5,0.5};
    GLfloat v5[] = {-0.8f,0.4f,height-0.1f, 0,0,1,  255,255,255,255,	0,0.5};
    
    EVEVertexStruct *vertices = calloc(6, sizeof(EVEVertexStruct));
    GLushort indices[12] = {0,3,2, 0,2,5, 0,1,3, 0,4,1};
    
    vertices[0] = EVEVertexMake(v0);
    vertices[1] = EVEVertexMake(v1);
    vertices[2] = EVEVertexMake(v2);
    vertices[3] = EVEVertexMake(v3);
    vertices[4] = EVEVertexMake(v4);
    vertices[5] = EVEVertexMake(v5);
    
    EVEGraphModel *planeModel = [EVEGraphModel modelWithName:@"Plane_test"];
    EVEGraphMesh *plane = [EVEGraphMesh meshWithName:@"Paper plane" vertices:vertices vertexCount:6 indices:indices indexCount:12];
    
    [planeModel addChild:plane];
    planeModel.material = [EVEGraphMaterial materialWithName:@"Newspaper" andFullFileName:@"newspaper.png"];
    
    return planeModel;
}

+ (EVEGraphModel *)woodFloorModel:(float)size textureScale:(float)texScale
{
    GLfloat v0[] = {size,size,0,    0,0,1,	255,255,255,255,	size*texScale,size*texScale};
    GLfloat v1[] = {size,-size,0,   0,0,1,	255,255,255,255,	size*texScale,0};
    GLfloat v2[] = {-size,-size,0,  0,0,1,  255,255,255,255,	0,0};
    GLfloat v3[] = {-size,size,0,   0,0,1,  255,255,255,255,	0,size*texScale};
    
    EVEVertexStruct *vertices = calloc(4, sizeof(EVEVertexStruct));
    GLushort indices[6] = {0,2,1, 0,3,2};
    
    vertices[0] = EVEVertexMake(v0);
    vertices[1] = EVEVertexMake(v1);
    vertices[2] = EVEVertexMake(v2);
    vertices[3] = EVEVertexMake(v3);
    
    EVEGraphModel *floorModel = [EVEGraphModel modelWithName:@"Floor_test"];
    EVEGraphMesh *floor = [EVEGraphMesh meshWithName:@"Wooden floor" vertices:vertices vertexCount:4 indices:indices indexCount:6];
    [floorModel addChild:floor];
    floorModel.material = [EVEGraphMaterial materialWithName:@"Wood" andFullFileName:@"woodfloor.png"];
    
    return floorModel;
}

@end
