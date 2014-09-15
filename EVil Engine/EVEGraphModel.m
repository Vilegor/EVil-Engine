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

static NSString * const kASEGroupsHeader = @"*GROUP";
static NSString * const kASEGeomobjHeader = @"*GEOMOBJECT";

+ (EVEGraphModel *)modelFromFile:(NSString *)aseFileName
{
    NSArray *objectsASE = [EVEASEConverter objectsDescriptionFromFile:aseFileName];
    if (objectsASE) {
        EVEGraphModel *model = [EVEGraphModel modelWithName:aseFileName];
        NSArray *materialsASE = [EVEASEConverter materialsDescriptionFromFile:aseFileName];
        [model setupWithASEGeomobjects:objectsASE andASEMaterials:materialsASE];
        return model;
    }
    
    return nil;
}

- (void)setupWithASEGeomobjects:(NSArray *)aseObjects andASEMaterials:(NSArray *)materialsASE
{
    for (NSString *objDesc in aseObjects) {
        EVEGraphObject *parentGroup = nil;
        
        // Check parent
        NSString *parentName = [EVEASEConverter stringValueNamed:@"NODE_PARENT" fromTextDescription:objDesc];
        if (parentName) {
            parentGroup = (EVEGraphObject *)[self childByName:parentName];
            if (!parentGroup) {
                parentGroup = [EVEGraphObject groupWithName:parentName];
                [self addChild:parentGroup];
            }
        }
        
        // Get main properties
        NSString *objName = [EVEASEConverter stringValueNamed:@"NODE_NAME" fromTextDescription:objDesc];
        int vcount = [EVEASEConverter numberValueNamed:@"MESH_NUMVERTEX" fromTextDescription:objDesc].intValue;
        int fcount = [EVEASEConverter numberValueNamed:@"MESH_NUMFACES" fromTextDescription:objDesc].intValue;
        int tcount = [EVEASEConverter numberValueNamed:@"MESH_NUMTVERTEX" fromTextDescription:objDesc].intValue;
        int ccount = [EVEASEConverter numberValueNamed:@"MESH_NUMCVERTEX" fromTextDescription:objDesc].intValue;
        
        // Setup vertex data
        EVEVertexStruct *vertices = calloc(vcount, sizeof(EVEVertexStruct));
        for (int v = 0; v < vcount; v++) {
            // Set coord
            NSArray *coord = [EVEASEConverter valueListNamed:@"MESH_VERTEX" index:v fromTextDescription:objDesc];
            vertices[v].x = [coord[0] floatValue];
            vertices[v].y = [coord[1] floatValue];
            vertices[v].z = [coord[2] floatValue];
            
            // Set normal
            NSArray *normal = [EVEASEConverter valueListNamed:@"MESH_VERTEXNORMAL" index:v fromTextDescription:objDesc];
            vertices[v].nx = [normal[0] floatValue];
            vertices[v].ny = [normal[1] floatValue];
            vertices[v].nz = [normal[2] floatValue];
            
            // Set texture coord
            if (tcount) {
                NSArray *tex = [EVEASEConverter valueListNamed:@"MESH_TVERT" index:v fromTextDescription:objDesc];
                vertices[v].tex_x = [tex[0] floatValue];
                vertices[v].tex_y = [tex[1] floatValue];
            }
            
            // Set color
            NSArray *color;
            if (ccount) {
                color = [EVEASEConverter valueListNamed:@"MESH_VERTCOL" index:v fromTextDescription:objDesc];
            }
            else {
                color = @[@1,@1,@1];
            }
            vertices[v].r = [color[0] floatValue] * 255;
            vertices[v].g = [color[1] floatValue] * 255;
            vertices[v].b = [color[2] floatValue] * 255;
            vertices[v].a = 1;  // ASE doesn't support alpha channel for the moment
        }
        
        // Setup index data
        int icount = fcount * ASE_FACE_SIZE;
        GLubyte *indices = calloc(icount, sizeof(GLubyte));
        for (int f = 0; f < fcount; f++) {
            NSDictionary *faceInfo = [EVEASEConverter valueDictionaryNamed:@"MESH_FACE" index:f fromTextDescription:objDesc];
            // ASE works only with triangle faces
            indices[f*ASE_FACE_SIZE]     = [faceInfo[@"A"] intValue];
            indices[f*ASE_FACE_SIZE + 1] = [faceInfo[@"B"] intValue];
            indices[f*ASE_FACE_SIZE + 2] = [faceInfo[@"C"] intValue];
        }
        
        // Create graph object
        EVEGraphMesh *object = [EVEGraphMesh meshWithName:objName
                                                 vertices:vertices
                                              vertexCount:vcount
                                                  indices:indices
                                               indexCount:icount];
        
        // Setup material data
        NSNumber *materialIndex = [EVEASEConverter numberValueNamed:@"MATERIAL_REF" fromTextDescription:objDesc];
        if (materialIndex && materialsASE.count > materialIndex.intValue) {
            object.material = [EVEGraphMaterial materialWithTextDescription:materialsASE[materialIndex.intValue]];
        }
        
        // Add current object
        if (parentGroup)
            [parentGroup addChild:object];
        else
            [self addChild:object];
    }
}

#pragma mark - Test Models

+ (EVEGraphModel *)paperPlaneModel
{
    GLfloat v0[] = {0,-1,0,				0,1,0,	255,255,255,255,	0,0};
    GLfloat v1[] = {0.1f,0.5f,0,        0,1,0,	204,204,204,255,	0.3,0};
    GLfloat v2[] = {-0.1f,0.5f,0,       0,1,0,  204,204,204,255,	0.3,0.3};
    GLfloat v3[] = {0,0.5f,-0.3,        0,1,0,  230,230,230,255,	0,0.3};
    GLfloat v4[] = {0.8f,0.4f,-0.1f,    0,1,0,  255,255,255,255,	0.3,0.3};
    GLfloat v5[] = {-0.8f,0.4f,-0.1f,   0,1,0,  255,255,255,255,	0,0.3};
    
    EVEVertexStruct *vertices = calloc(6, sizeof(EVEVertexStruct));
    GLubyte indices[12] = {0,2,3, 0,2,5, 0,1,3, 0,1,4};
    
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
    GLfloat v0[] = {size,size,0,    0,1,0,	255,255,255,255,	size*texScale,size*texScale};
    GLfloat v1[] = {size,-size,0,   0,1,0,	255,255,255,255,	size*texScale,0};
    GLfloat v2[] = {-size,-size,0,  0,1,0,  255,255,255,255,	0,0};
    GLfloat v3[] = {-size,size,0,   0,1,0,  255,255,255,255,	0,size*texScale};
    
    EVEVertexStruct *vertices = calloc(4, sizeof(EVEVertexStruct));
    GLubyte indices[6] = {0,1,2, 0,3,2};
    
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
