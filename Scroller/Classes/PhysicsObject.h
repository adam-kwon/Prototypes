/*
 *  PhysicsObject.h
 *  Scroller
 *
 *  Created by min on 3/1/11.
 *  Copyright 2011 L00Kout. All rights reserved.
 *
 */

#import "Box2D.h"

@protocol PhysicsObject

- (void) createPhysicsObject:(b2World *)theWorld;

@end