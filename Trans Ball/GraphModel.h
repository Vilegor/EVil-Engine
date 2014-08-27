//
//  GraphModel.h
//  Trans Ball
//
//  Created by Egor Vilkin on 7/30/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import "GraphObject.h"
#import "GraphMaterial.h"

@interface GraphModel : NSObject <GraphDrawableProtocol>

@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic, readonly) NSInteger objectCount;
@property(nonatomic, setter = setMaterial:, getter = getMaterial) GraphMaterial *material;

+ (GraphModel *)emptyModel;
+ (GraphModel *)modelWithName:(NSString *)modelName;
- (id)initWithName:(NSString *)modelName;

- (void)addObject:(GraphObject *)object;
- (void)removeObject:(NSString *)objectName;
- (GraphObject *)objectByName:(NSString *)objectName;

@end
