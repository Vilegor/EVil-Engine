//
//  GraphMaterial.h
//  Trans Ball
//
//  Created by Egor Vilkin on 8/5/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import <GLKit/GLKit.h>
@interface GraphMaterial : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *fileName;
@property (nonatomic, strong, readonly) NSString *fileExt;

+ (GraphMaterial *)materialWithName:(NSString *)name andFullFileName:(NSString *)fileName;
- (id)initWithName:(NSString *)name andFullFileName:(NSString *)fileName;

- (void)load;
- (void)enable;
- (void)disable;

@end
