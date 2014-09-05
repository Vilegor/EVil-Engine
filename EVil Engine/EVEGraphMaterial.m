//
//  GraphMaterial.m
//  Trans Ball
//
//  Created by Egor Vilkin on 8/5/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "EVEGraphMaterial.h"
#import "EVEASEConverter.h"

static int hasTextureUniform;

@interface EVEGraphMaterial() {
    GLKTextureInfo *texInfo;
}
@end

@implementation EVEGraphMaterial

+ (EVEGraphMaterial *)materialWithTextDescription:(NSString *)description
{
    NSString *name = [EVEASEConverter stringValueNamed:@"MATERIAL_NAME" fromTextDescription:description];
    NSString *filePath = [EVEASEConverter stringValueNamed:@"BITMAP" fromTextDescription:description];
    NSString *fileName = [filePath lastPathComponent];
    
    return [self materialWithName:name andFullFileName:fileName];
}

+ (EVEGraphMaterial *)materialWithName:(NSString *)name andFullFileName:(NSString *)fileName
{
    return [[EVEGraphMaterial alloc] initWithName:name andFullFileName:fileName];
}

- (id)initWithName:(NSString *)name andFullFileName:(NSString *)fileName
{
    self = [super init];
    if (self) {
        _name = name;
        _fileName = [[fileName lastPathComponent] stringByDeletingPathExtension];
        _fileExt = [fileName pathExtension];
    }
    return self;
}

- (void)load
{
    glGetError();
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:_fileName ofType:_fileExt inDirectory:@"Textures"];
    if (filePath) {
        NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft: @YES};
        texInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:options error:&error];
        if (error) {
            NSLog(@"Error! Texture '%@' cannot be loaded: %@", _fileName, error);
        }
    }
    else {
        NSLog(@"ERROR! Material '%@' not found!", _name);
    }
}

- (void)enable
{
    glUniform1i(hasTextureUniform, 1);
    glBindTexture(texInfo.target, texInfo.name);
    glEnable(texInfo.target);
    // To let this parameters work, texture size must be normalized (power of 2)
    glTexParameteri(texInfo.target, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(texInfo.target, GL_TEXTURE_WRAP_T, GL_REPEAT);
}

- (void)disable
{
    glUniform1i(hasTextureUniform, 0);
    glBindTexture(texInfo.target, 0);
    glDisable(texInfo.target);
}

+ (void)setUniformLocations:(GLint)program
{
    hasTextureUniform = glGetUniformLocation(program, "hasTexture");
}

#pragma mark - Compare

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        EVEGraphMaterial *material = object;
        return [material.name isEqualToString:_name];
    }

    return NO;
}

@end
