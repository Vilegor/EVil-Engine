//
//  ASEConverter.h
//  Trans Ball
//
//  Created by Egor Vilkin on 8/29/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#define ASE_FACE_SIZE 3

typedef NSDictionary ASEModelInfo;

static NSString * const kSceneKey = @"Scene";
@interface ASESceneInfo : NSObject
@property (nonatomic, strong) NSString *blendFileName;
@property (nonatomic, assign) int firstFrame;
@property (nonatomic, assign) int lastFrame;
@property (nonatomic, assign) int frameRate;
@end

static NSString * const kMaterialsKey = @"Materials";
@interface ASEMaterialInfo : NSObject
@property (nonatomic, assign) int materialId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *filePath;
@end

#import "EVEGraphVertex.h"
static NSString * const kObjectsKey = @"Geomobjects";
@interface ASEGeomObjectInfo : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *parentName;
@property (nonatomic, assign) int vertexCount;
@property (nonatomic, assign) EVEVertexStruct *vertices;
@property (nonatomic, assign) int indexCount;
@property (nonatomic, assign) GLushort *indices;
@property (nonatomic, assign) int materialIndex;
@end

@interface EVEASEConverter : NSObject

+ (ASEModelInfo *)modelInfoFromFile:(NSString *)aseFileName;

+ (NSArray *)objectsDescriptionFromFile:(NSString *)aseFileName;
+ (NSArray *)materialsDescriptionFromFile:(NSString *)aseFileName;

+ (NSString *)stringValueNamed:(NSString *)name fromTextDescription:(NSString *)description;
+ (NSNumber *)numberValueNamed:(NSString *)name fromTextDescription:(NSString *)description;
+ (NSArray *)valueListNamed:(NSString *)name fromTextDescription:(NSString *)description;
+ (NSArray *)valueListNamed:(NSString *)name atIndex:(int)index fromTextDescription:(NSString *)description;
+ (NSDictionary *)valueDictionaryNamed:(NSString *)name atIndex:(int)index fromTextDescription:(NSString *)description;

@end