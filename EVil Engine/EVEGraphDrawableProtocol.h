//
//  GraphDrawableProtocol.h
//  Trans Ball
//
//  Created by Egor Vilkin on 8/1/14.
//  Copyright (c) 2014 EVil corp. All rights reserved.
//

#import <GLKit/GLKit.h>

@protocol EVEGraphDrawableProtocol <NSObject>

- (void)draw;
- (void)resetDrawableData;

@end
