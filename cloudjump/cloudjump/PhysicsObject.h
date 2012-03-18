/*
 *  PhysicsObject.h
 *  Scroller
 *
 *  Created by min on 3/1/11.
 *  Copyright 2011 GAMEPEONS LLC. All rights reserved.
 *
 */

#import "Box2D.h"

@protocol PhysicsObject

- (void) createPhysicsObject:(b2World *)theWorld;
- (void) destroyPhysicsObject;

@end