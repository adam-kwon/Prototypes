//
//  Player.h
//  Grappler
//
//  Created by James Sandoz on 8/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"

#import "GameObject.h"
#import "PhysicsObject.h"


@interface Player : CCSprite<GameObject, PhysicsObject> {
    
    BOOL safeToDelete;
    
    b2Body *body;
    b2World *world;
    
//    b2DistanceJoint *swingJoint;
    b2RopeJoint *swingJoint;
    
    b2Body *currentAnchor;
    
    float maxRopeLength;
    float ropeLengthDelta;
}

- (void) swingFrom:(b2Body *)anchor;
- (void) destroyRopeJoint;
- (void) shortenRope:(float)dt;

@property (nonatomic, readonly) b2Body *currentAnchor;
@property (nonatomic, readonly) b2RopeJoint *swingJoint;
@property (nonatomic, readwrite, assign) float maxRopeLength;

@end
