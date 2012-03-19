//
//  SwingingRopeDude.h
//  SwingProto
//
//  Created by James Sandoz on 3/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"


@interface SwingingRopeDude : CCNode {
    
    b2World *world;
    
    b2Body *anchor;
    b2Body *rope;
    b2RevoluteJoint *revJoint;
    
    float minAngleRads;
    float maxAngleRads;
}

- (void) createPhysicsObjectAsBox:(b2World*)theWorld;
- (void) updateObject:(ccTime)dt;

- (void) showAt:(CGPoint)pos;

@end
