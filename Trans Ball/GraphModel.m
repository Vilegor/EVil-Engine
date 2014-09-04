//
//  GraphModel.m
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphModel.h"
#import "ASEConverter.h"

static int modelId;

@interface GraphModel() {

}
@end

@implementation GraphModel

+ (GraphModel *)emptyModel
{
    return [[GraphModel alloc] initWithName:[NSString stringWithFormat:@"Model_%d", modelId++]];
}

+ (GraphModel *)modelWithName:(NSString *)modelName
{
    return [[GraphModel alloc] initWithName:modelName];
}

#pragma mark - Load from .ASE

static NSString * const kASEGroupsHeader = @"*GROUP";
static NSString * const kASEGeomobjHeader = @"*GEOMOBJECT";

+ (GraphModel *)modelFromFile:(NSString *)aseFileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:aseFileName ofType:@"ase" inDirectory:@"Models"];
    if (!filePath) {
        NSLog(@"Error! Model '%@' not found!", aseFileName);
        return nil;
    }
    
    // read everything from text
    NSError *error = nil;
    NSString *fileContents = [NSString stringWithContentsOfFile:filePath
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
    if (!fileContents) {
        NSLog(@"ERROR! %@", error);
    }
    else {
        fileContents = [ASEConverter normalizeTextDescription:fileContents];
        NSString *pattern = @"\\*GEOMOBJECT \\{(.(?!\\*GEOMOBJECT))*\\}";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                               options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                                 error:&error];
        if (error) {
            NSLog(@"ERROR! Load model: %@", error);
        }
        else {
            NSMutableArray *objectsASE = [NSMutableArray array];
            NSArray *resultRegex = [regex matchesInString:fileContents options:0 range:NSMakeRange(0, fileContents.length)];
            if (!resultRegex.count) {
                NSLog(@"Error! Model '%@' is empty or description format is wrong!", aseFileName);
                return nil;
            }
            for (NSTextCheckingResult *result in resultRegex) {
                [objectsASE addObject:[fileContents substringWithRange:result.range]];
            }
            GraphModel *model = [GraphModel modelWithName:aseFileName];
            [model setupWithASEGeomobjects:objectsASE];
            
            return model;
        }
    }
    return nil;
}

- (void)setupWithASEGeomobjects:(NSArray *)aseObjects
{
    for (NSString *objDesc in aseObjects) {
        GraphObject *parentGroup = nil;
        NSMutableArray *texCoords = nil;
        NSMutableArray *colors = nil;
        
        // Check parent
        NSString *parentName = [ASEConverter stringValueNamed:@"NODE_PARENT" fromTextDescription:objDesc];
        if (parentName) {
            parentGroup = (GraphObject *)[self childByName:parentName];
            if (!parentGroup) {
                parentGroup = [GraphObject groupWithName:parentName];
                [self addChild:parentGroup];
            }
        }
        
        // Get main properties
        NSString *objName = [ASEConverter stringValueNamed:@"NODE_NAME" fromTextDescription:objDesc];
        int vcount = [ASEConverter numberValueNamed:@"MESH_NUMVERTEX" fromTextDescription:objDesc].intValue;
        int fcount = [ASEConverter numberValueNamed:@"MESH_NUMFACES" fromTextDescription:objDesc].intValue;
        
        // Load texture coords
        int tcount = [ASEConverter numberValueNamed:@"MESH_NUMTVERTEX" fromTextDescription:objDesc].intValue;
        if (tcount)
            texCoords = [NSMutableArray array];
        for (int t = 0; t < tcount; t++) {
            NSArray *coord = [ASEConverter valueListNamed:@"MESH_TVERT" index:t fromTextDescription:objDesc];
            [texCoords addObject:coord];
        }
    
        // Load colors
        int ccount = [ASEConverter numberValueNamed:@"MESH_NUMCVERTEX" fromTextDescription:objDesc].intValue;
        if (ccount)
            colors = [NSMutableArray array];
        for (int c = 0; c < ccount; c++) {
            NSArray *color = [ASEConverter valueListNamed:@"MESH_VERTCOL" index:c fromTextDescription:objDesc];
            [colors addObject:color];
        }
        
        // Setup vertex data
        VertexStruct *vertices = calloc(vcount, sizeof(VertexStruct));
        for (int v = 0; v < vcount; v++) {
            // Set coord
            NSArray *coord = [ASEConverter valueListNamed:@"MESH_VERTEX" index:v fromTextDescription:objDesc];
            vertices[v].x = [coord[0] floatValue];
            vertices[v].y = [coord[1] floatValue];
            vertices[v].z = [coord[2] floatValue];
            
            // Set normal
            NSArray *normal = [ASEConverter valueListNamed:@"MESH_VERTEXNORMAL" index:v fromTextDescription:objDesc];
            vertices[v].nx = [normal[0] floatValue];
            vertices[v].ny = [normal[1] floatValue];
            vertices[v].nz = [normal[2] floatValue];
        }
        
        // Setup index data
        int icount = fcount * ASE_FACE_SIZE;
        GLubyte *indices = calloc(icount, sizeof(GLubyte));
        for (int f = 0; f < fcount; f++) {
            NSDictionary *faceInfo = [ASEConverter valueDictionaryNamed:@"MESH_FACE" index:f fromTextDescription:objDesc];
            // ASE works only with triangle faces
            NSArray *ABC = @[faceInfo[@"A"], faceInfo[@"B"], faceInfo[@"C"]];
            
            // Set vertex color and texture coord
            NSArray *colorIndices = [ASEConverter valueListNamed:@"MESH_CFACE" index:f fromTextDescription:objDesc];
            NSArray *texIndices = [ASEConverter valueListNamed:@"MESH_TFACE" index:f fromTextDescription:objDesc];
            if (colorIndices.count != ASE_FACE_SIZE && ccount) {
                NSLog(@"WARNING! %@->%@: Face size doesn't normalized <Color>!", _name, objName);
            }
            if (texIndices.count != ASE_FACE_SIZE && tcount) {
                NSLog(@"WARNING! %@->%@: Face size doesn't normalized <Texture>!", _name, objName);
            }
            
            for (int i = 0; i < ASE_FACE_SIZE; i++) {
                int v = [ABC[i] intValue];
                if (vertices[v].a == 0) {   // alpha = 0 means vertex color or texture was not set before
                    int c = [colorIndices[i] intValue];
                    int t = [texIndices[i] intValue];
                    
                    vertices[v].tex_x = [texCoords[t][0] floatValue];
                    vertices[v].tex_y = [texCoords[t][1] floatValue];
                    
                    vertices[v].r = [colors[c][0] floatValue] * 255;
                    vertices[v].g = [colors[c][1] floatValue] * 255;
                    vertices[v].b = [colors[c][2] floatValue] * 255;
                    
                    vertices[v].a = 1;  // ASE doesn't support alpha channel for the moment, so I use it mark vertex
                }
            }
            
            // Set indices
            indices[f*ASE_FACE_SIZE] = [ABC[0] intValue];
            indices[f*ASE_FACE_SIZE + 1] = [ABC[1] intValue];
            indices[f*ASE_FACE_SIZE + 2] = [ABC[2] intValue];
        }
        
        // Create graph object
        GraphMesh *object = [GraphMesh meshWithName:objName
                                           vertices:vertices
                                        vertexCount:vcount
                                            indices:indices
                                         indexCount:icount];
        
        // Add current object
        if (parentGroup)
            [parentGroup addChild:object];
        else
            [self addChild:object];
    }
}

#pragma mark - Test Models

+ (GraphModel *)paperPlaneModel
{
    GLfloat v0[] = {0,-1,0,				0,1,0,	255,255,255,255,	0,0};
    GLfloat v1[] = {0.1f,0.5f,0,        0,1,0,	204,204,204,255,	0.3,0};
    GLfloat v2[] = {-0.1f,0.5f,0,       0,1,0,  204,204,204,255,	0.3,0.3};
    GLfloat v3[] = {0,0.5f,-0.3,        0,1,0,  230,230,230,255,	0,0.3};
    GLfloat v4[] = {0.8f,0.4f,-0.1f,    0,1,0,  255,255,255,255,	0.3,0.3};
    GLfloat v5[] = {-0.8f,0.4f,-0.1f,   0,1,0,  255,255,255,255,	0,0.3};
    
    VertexStruct *vertices = calloc(6, sizeof(VertexStruct));
    GLubyte *indices = calloc(12, sizeof(VertexStruct));
    
    vertices[0] = VertexMake(v0);
    vertices[1] = VertexMake(v1);
    vertices[2] = VertexMake(v2);
    vertices[3] = VertexMake(v3);
    vertices[4] = VertexMake(v4);
    vertices[5] = VertexMake(v5);
    
    indices[0] = 0; indices[1] = 2; indices[2] = 5;
    indices[3] = 0; indices[4] = 2; indices[5] = 3;
    indices[6] = 0; indices[7] = 1; indices[8] = 3;
    indices[9] = 0; indices[10] = 1; indices[11] = 4;
    
    GraphModel *planeModel = [GraphModel modelWithName:@"Plane_test"];
    GraphMesh *plane = [GraphMesh meshWithName:@"Paper plane" vertices:vertices vertexCount:6 indices:indices indexCount:12];
    
    [planeModel addChild:plane];
    planeModel.material = [GraphMaterial materialWithName:@"Newspaper" andFullFileName:@"newspaper.png"];
    
    return planeModel;
}

+ (GraphModel *)woodFloorModel:(int)size
{
    GLfloat v0[] = {size,size,0,    0,1,0,	255,255,255,255,	size/10,size/10};
    GLfloat v1[] = {size,-size,0,   0,1,0,	255,255,255,255,	size/10,0};
    GLfloat v2[] = {-size,-size,0,  0,1,0,  255,255,255,255,	0,0};
    GLfloat v3[] = {-size,size,0,   0,1,0,  255,255,255,255,	0,size/10};
    
    VertexStruct *vertices = calloc(4, sizeof(VertexStruct));
    GLubyte *indices = calloc(6, sizeof(VertexStruct));
    
    vertices[0] = VertexMake(v0);
    vertices[1] = VertexMake(v1);
    vertices[2] = VertexMake(v2);
    vertices[3] = VertexMake(v3);
    
    indices[0] = 0; indices[1] = 1; indices[2] = 2;
    indices[3] = 0; indices[4] = 3; indices[5] = 2;
    
    GraphModel *floorModel = [GraphModel modelWithName:@"Floor_test"];
    GraphMesh *floor = [GraphMesh meshWithName:@"Wooden floor" vertices:vertices vertexCount:4 indices:indices indexCount:6];
    [floorModel addChild:floor];
    floorModel.material = [GraphMaterial materialWithName:@"Wood" andFullFileName:@"woodfloor.png"];
    
    return floorModel;
}

@end
