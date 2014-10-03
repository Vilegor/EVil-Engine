//
//  ASEConverter.m
//  Trans Ball
//
//  Created by Egor Vilkin on 8/29/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "EVEASEConverter.h"

typedef enum {
    SCENE_FILENAME, SCENE_FIRSTFRAME, SCENE_LASTFRAME, SCENE_FRAMESPEED,
    MATERIAL_COUNT, MATERIAL, MATERIAL_NAME, BITMAP,
    GEOMOBJECT, NODE_NAME, NODE_PARENT, MESH_NUMVERTEX, MESH_VERTEX, MESH_NUMFACES, MESH_FACE, MESH_TVERT, MESH_VERTCOL, MESH_VERTEXNORMAL, MATERIAL_REF, PROP_RECVSHADOW
} ASEToken;

@implementation ASESceneInfo
@end

@implementation ASEMaterialInfo
@end

@implementation ASEGeomObjectInfo
@end

@implementation EVEASEConverter

#pragma mark - Fast loading

+ (NSDictionary *)tokenMap
{
    static NSDictionary *map;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = @{
                @"*SCENE_FILENAME" : @(SCENE_FILENAME),
                @"*SCENE_FIRSTFRAME" : @(SCENE_FIRSTFRAME),
                @"*SCENE_LASTFRAME" : @(SCENE_LASTFRAME),
                @"*SCENE_FRAMESPEED" : @(SCENE_FRAMESPEED),
                
                @"*MATERIAL_COUNT" : @(MATERIAL_COUNT),
                @"*MATERIAL" : @(MATERIAL),
                @"*MATERIAL_NAME" : @(MATERIAL_NAME),
                @"*BITMAP" : @(BITMAP),
                
                @"*GEOMOBJECT" : @(GEOMOBJECT),
                @"*NODE_NAME" : @(NODE_NAME),
                @"*NODE_PARENT" : @(NODE_PARENT),
                @"*MESH_NUMVERTEX" : @(MESH_NUMVERTEX),
                @"*MESH_VERTEX" : @(MESH_VERTEX),
                @"*MESH_NUMFACES" : @(MESH_NUMFACES),
                @"*MESH_FACE" : @(MESH_FACE),
                @"*MESH_TVERT" : @(MESH_TVERT),
                @"*MESH_VERTCOL" : @(MESH_VERTCOL),
                @"*MESH_VERTEXNORMAL" : @(MESH_VERTEXNORMAL),
                @"*MATERIAL_REF" : @(MATERIAL_REF),
                @"*PROP_RECVSHADOW" : @(PROP_RECVSHADOW)
                };
    });
    return map;
}

+ (ASEModelInfo *)modelInfoFromFile:(NSString *)aseFileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:aseFileName ofType:@"ase" inDirectory:@"Models"];
    if (!filePath) {
        NSLog(@"Error! Model file '%@' not found!", aseFileName);
    }
    // get lines of file (all at a time :( )
    // read everything from text
    NSError *error = nil;
    NSString *fileContents = [NSString stringWithContentsOfFile:filePath
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
    if (!fileContents) {
        NSLog(@"ERROR! %@", error);
    }
    else {
        NSArray *lines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        if (lines.count <= 1) {
            NSLog(@"Error! Model file '%@' is empty or description format is wrong!", aseFileName);
            return nil;
        }
        
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        NSMutableArray *materialList;
        NSMutableArray *objectList = [NSMutableArray array];
        ASESceneInfo *scene = [ASESceneInfo new];
        ASEMaterialInfo *currentMaterial = nil;
        ASEGeomObjectInfo *currentObject = nil;
        
        for (NSString *line in lines) {
            NSCharacterSet *separators = [NSCharacterSet characterSetWithCharactersInString:@" \t"];
            NSString *clearLine = [line stringByTrimmingCharactersInSet:separators];
            NSArray *components = [clearLine componentsSeparatedByCharactersInSet:separators];
            components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
            NSNumber *tokenNum = components.count ? [self tokenMap][components[0]] : nil;
            if (tokenNum) {
                ASEToken token = [tokenNum intValue];
                switch (token) {
                /* parse scene info */
                    case SCENE_FILENAME: {
                        scene.blendFileName = [self getStringValueFromLine:line];
                        break;
                    }
                    case SCENE_FIRSTFRAME: {
                        scene.firstFrame = [components[1] intValue];
                        break;
                    }
                    case SCENE_LASTFRAME: {
                        scene.lastFrame = [components[1] intValue];
                        break;
                    }
                    case SCENE_FRAMESPEED: {
                        scene.frameRate = [components[1] intValue];
                        break;
                    }
                        
                /* parse materials info */
                    case MATERIAL_COUNT: {
                        int materialCount = [components[1] intValue];
                        materialList = [NSMutableArray arrayWithCapacity:materialCount];
                        break;
                    }
                    case MATERIAL: {
                        currentMaterial = [ASEMaterialInfo new];
                        currentMaterial.materialId = [components[1] intValue];
                        break;
                    }
                    case MATERIAL_NAME: {
                        currentMaterial.name = [self getStringValueFromLine:line];
                        break;
                    }
                    case BITMAP: {  // last material token
                        currentMaterial.filePath = [self getStringValueFromLine:line];
                        currentMaterial.fileName = [currentMaterial.filePath lastPathComponent];
                        [materialList insertObject:currentMaterial atIndex:currentMaterial.materialId];
                        break;
                    }
                        
                /* parse geomobjects */
                    case GEOMOBJECT: {
                        currentObject = [ASEGeomObjectInfo new];
                        currentObject.materialIndex = -1;
                        break;
                    }
                    case NODE_NAME: {
                        currentObject.name = [self getStringValueFromLine:line];
                        break;
                    }
                    case NODE_PARENT: {
                        currentObject.parentName = [self getStringValueFromLine:line];
                        break;
                    }
                    case MESH_NUMVERTEX: {
                        currentObject.vertexCount = [components[1] intValue];
                        currentObject.vertices = malloc(currentObject.vertexCount * sizeof(EVEVertexStruct));
                        break;
                    }
                    case MESH_VERTEX: {
                        int vi = [components[1] intValue];
                        currentObject.vertices[vi].x = [components[2] floatValue];
                        currentObject.vertices[vi].y = [components[3] floatValue];
                        currentObject.vertices[vi].z = [components[4] floatValue];
                        
                        // set default color to white
                        currentObject.vertices[vi].r =
                        currentObject.vertices[vi].g =
                        currentObject.vertices[vi].b =
                        currentObject.vertices[vi].a = 255;
                        break;
                    }
                    case MESH_TVERT: {
                        int vi = [components[1] intValue];
                        currentObject.vertices[vi].u = [components[2] floatValue];
                        currentObject.vertices[vi].v = [components[3] floatValue];
                        break;
                    }
                    case MESH_VERTCOL: {
                        int vi = [components[1] intValue];
                        currentObject.vertices[vi].r = [components[2] floatValue] * 255;
                        currentObject.vertices[vi].g = [components[3] floatValue] * 255;
                        currentObject.vertices[vi].b = [components[4] floatValue] * 255;
                        break;
                    }
                    case MESH_VERTEXNORMAL: {
                        int vi = [components[1] intValue];
                        currentObject.vertices[vi].nx = [components[2] floatValue];
                        currentObject.vertices[vi].ny = [components[3] floatValue];
                        currentObject.vertices[vi].nz = [components[4] floatValue];
                        break;
                    }
                    case MESH_NUMFACES: {
                        currentObject.indexCount = [components[1] intValue] * ASE_FACE_SIZE;
                        currentObject.indices = malloc(currentObject.indexCount * sizeof(GLushort));
                        break;
                    }
                    case MESH_FACE: {   //*MESH_FACE 0: A: 5 B: 1 C: 0 *MESH_SMOOTHING 0 *MESH_MTLID 1
                        int fi = [components[1] intValue];
                        currentObject.indices[fi * ASE_FACE_SIZE] = [components[3] intValue];
                        currentObject.indices[fi * ASE_FACE_SIZE + 1] = [components[5] intValue];
                        currentObject.indices[fi * ASE_FACE_SIZE + 2] = [components[7] intValue];
                        break;
                    }
                    case MATERIAL_REF: {
                        currentObject.materialIndex = [components[1] intValue];
                        break;
                    }
                    case PROP_RECVSHADOW: { // last geomobject token
                        [objectList addObject:currentObject];
                        break;
                    }

                    default:
                        break;
                }
            }
        }
        
        [info setValue:scene forKey:kSceneKey];
        [info setValue:materialList forKey:kMaterialsKey];
        [info setValue:objectList forKey:kObjectsKey];
        
        return info;
    }
    
    return nil;
}

+ (NSString *)getStringValueFromLine:(NSString *)line
{
    NSRange start = [line rangeOfString:@"\""];
    NSRange end = [line rangeOfString:@"\"" options:0 range:NSMakeRange(start.location + 1, [line length] - start.location - 1)];
    return [line substringWithRange:NSMakeRange(start.location + start.length, end.location - start.location - start.length)];
}

@end
