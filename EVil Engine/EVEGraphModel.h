//
//  GraphModel.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "EVEGraphObject.h"
#import "EVEGraphMaterial.h"

/*!
 All models suggest Counter Clock Wise vertex ordering
 */

@interface EVEGraphModel : EVEGraphObject

+ (EVEGraphModel *)emptyModel;
+ (EVEGraphModel *)modelWithName:(NSString *)modelName;
+ (EVEGraphModel *)modelFromASEFile:(NSString *)aseFileName;

///Test models
+ (EVEGraphModel *)paperPlaneModel:(float)height;
+ (EVEGraphModel *)woodFloorModel:(float)size textureScale:(float)texScale;

@end
