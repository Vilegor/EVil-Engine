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
    NSString *filePath = [[NSBundle mainBundle] pathForResource:aseFileName ofType:@"ASE"];
    // read everything from text
    NSError *error = nil;
    NSString *fileContents = [NSString stringWithContentsOfFile:filePath
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
    if (!fileContents) {
        NSLog(@"ERROR! %@", error);
    }
    else {
        NSString *pattern = @"\\*GEOMOBJECT \\{(.(?!\\*GEOMOBJECT))*\\}\\r\\n";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                               options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                                 error:&error];
        if (error) {
            NSLog(@"ERROR! Model: %@", error);
        }
        else {
            NSMutableArray *objectsASE = [NSMutableArray array];
            NSArray *resultRegex = [regex matchesInString:fileContents options:0 range:NSMakeRange(0, fileContents.length)];
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
        //NSArray *lines = [objDesc componentsSeparatedByString:@"\r\n"];
        //GraphObject *newObject = [GraphObject objectWithName:(NSString *) andMeshes:(NSArray *)];
        NSString *parentName = [ASEConverter stringValueNamed:@"NODE_PARENT" fromTextDescription:objDesc];
        NSString *objName = [ASEConverter stringValueNamed:@"NODE_NAME" fromTextDescription:objDesc];
    }
}

#pragma mark - Test Models

+ (GraphModel *)paperPlaneModel
{
    GLfloat v0[] = {0,-1,0,				0,1,0,	255,255,255,255,	0,0};
    GLfloat v1[] = {0.1f,0.5f,0,        0,1,0,	204,204,204,255,	80,0};
    GLfloat v2[] = {-0.1f,0.5f,0,       0,1,0,  204,204,204,255,	80,80};
    GLfloat v3[] = {0,0.5f,-0.3,        0,1,0,  230,230,230,255,	0,80};
    GLfloat v4[] = {0.8f,0.4f,-0.1f,    0,1,0,  255,255,255,255,	80,80};
    GLfloat v5[] = {-0.8f,0.4f,-0.1f,   0,1,0,  255,255,255,255,	0,80};
    
    VertexStruct *w_vl = calloc(3, sizeof(VertexStruct));
    VertexStruct *w_vr = calloc(3, sizeof(VertexStruct));
    VertexStruct *b_vl = calloc(3, sizeof(VertexStruct));
    VertexStruct *b_vr = calloc(3, sizeof(VertexStruct));
    
    w_vl[0] = VertexMake(v0);
    w_vl[1] = VertexMake(v1);
    w_vl[2] = VertexMake(v4);
    
    w_vr[0] = VertexMake(v0);
    w_vr[1] = VertexMake(v2);
    w_vr[2] = VertexMake(v5);
    
    b_vl[0] = VertexMake(v0);
    b_vl[1] = VertexMake(v2);
    b_vl[2] = VertexMake(v3);
    
    b_vr[0] = VertexMake(v0);
    b_vr[1] = VertexMake(v1);
    b_vr[2] = VertexMake(v3);
    
    GraphModel * planeModel = [GraphModel modelWithName:@"Plane_test"];
    GraphObject *plane = [GraphObject objectWithName:@"Plane" andMeshes:@[[GraphMesh meshWithName:@"left" andVertices:b_vl vsize:3],
                                                                          [GraphMesh meshWithName:@"right" andVertices:b_vr vsize:3],
                                                                          [GraphMesh meshWithName:@"leftWing" andVertices:w_vl vsize:3],
                                                                          [GraphMesh meshWithName:@"rightWing" andVertices:w_vr vsize:3]]];
    [planeModel addChild:plane];
    planeModel.material = [GraphMaterial materialWithName:@"Newspaper" andFullFileName:@"texture.jpg"];
    
    return planeModel;
}

@end
