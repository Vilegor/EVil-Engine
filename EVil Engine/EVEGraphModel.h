//
//  GraphModel.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "EVEGraphObject.h"
#import "EVEGraphMaterial.h"

@interface EVEGraphModel : EVEGraphObject

+ (EVEGraphModel *)emptyModel;
+ (EVEGraphModel *)modelWithName:(NSString *)modelName;
+ (EVEGraphModel *)modelFromFile:(NSString *)aseFileName;

///Test models
+ (EVEGraphModel *)paperPlaneModel;
+ (EVEGraphModel *)woodFloorModel:(float)size textureScale:(float)texScale;

@end
