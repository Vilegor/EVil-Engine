//
//  UniformProcessorProtocol.h
//  Trans Ball
//
//  Created by Egor Vilkin on 8/7/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import <GLKit/GLKit.h>

@protocol EVEUniformProcessorProtocol <NSObject>

+ (void)setUniformLocations:(GLint)program;

@end
