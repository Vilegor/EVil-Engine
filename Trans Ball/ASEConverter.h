//
//  ASEConverter.h
//  Trans Ball
//
//  Created by Egor Vilkin on 8/27/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GraphModel.h"

@interface ASEConverter : NSObject

+ (GraphModel *)loadModelFromFileWithPath:(NSString *)aseFilePath;
+ (GraphModel *)paperPlaneModel;

@end
