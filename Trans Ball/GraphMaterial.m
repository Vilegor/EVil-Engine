//
//  GraphMaterial.m
//  Trans Ball
//
//  Created by Egor Vilkin on 8/5/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphMaterial.h"

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
        _fileName = [fileName pathComponents][0];
        _fileExt = [fileName pathExtension];
    }
    return self;
}

- (void)load
{
    glGetError();
    NSError *theError;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:_fileName ofType:_fileExt];
    texInfo = [GLKTextureLoader textureWithContentsOfFile:filePath options:nil error:&theError];
    [self enable];
}

- (void)enable
{
    glBindTexture(texInfo.target, texInfo.name);
    glEnable(texInfo.target);
}

- (void)disable
{
    glBindTexture(texInfo.target, 0);
    glDisable(texInfo.target);
}

@end
