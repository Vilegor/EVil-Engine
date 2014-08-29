//
//  GraphModel.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphObjectGroup.h"
#import "GraphMaterial.h"

@interface GraphModel : GraphObjectGroup

+ (GraphModel *)emptyModel;
+ (GraphModel *)modelWithName:(NSString *)modelName;
+ (GraphModel *)modelFromFile:(NSString *)aseFileName;

///Test models
+ (GraphModel *)paperPlaneModel;

@end
