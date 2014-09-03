//
//  GraphMaterial.m
//  Trans Ball
//
//  Created by Egor Vilkin on 8/5/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphMaterial.h"

static int hasTextureUniform;

@interface GraphMaterial() {
    GLKTextureInfo *texInfo;
}
@end

@implementation GraphMaterial

+ (GraphMaterial *)materialWithName:(NSString *)name andFullFileName:(NSString *)fileName
{
    return [[GraphMaterial alloc] initWithName:name andFullFileName:fileName];
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
    NSError *theError;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:_fileName ofType:_fileExt inDirectory:@"Texture"];
    if (filePath) {
        texInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:nil error:&theError];
        [self enable];
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
        GraphMaterial *material = object;
        return [material.name isEqualToString:_name];
    }

    return NO;
}

@end
