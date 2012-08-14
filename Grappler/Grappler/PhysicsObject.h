//
//  PhysicsObject.h
//  Grappler
//
//  Created by James Sandoz on 8/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Box2D.h"

@protocol PhysicsObject

- (void) createPhysicsObject:(b2World *)theWorld;
- (void) destroyPhysicsObject;
- (b2Body*) getPhysicsBody;

@end
