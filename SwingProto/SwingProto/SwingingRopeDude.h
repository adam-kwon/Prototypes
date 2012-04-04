//
//  SwingingRopeDude.h
//  SwingProto
//
//  Created by James Sandoz on 3/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GameObject.h"


@interface SwingingRopeDude : CCNode<GameObject> {
    
    CGPoint anchorPos;
    b2World *world;
    CCNode *parent;
    
    b2Body *anchor;
    b2Body *ropeBody;
    b2Body *catcherBody;
    
    CCSprite *catcherSprite;
    CCSprite *ropeSprite;
    
    b2RevoluteJoint *revJoint;
    
    float minAngleRads;
    float maxAngleRads;
    float motorSpeed;
}

- (id) initWithParent:(CCNode *)theParent at:(CGPoint)pos withSpeed:(float)speed;
- (void) createPhysicsObject:(b2World*)theWorld;
- (void) updateObject:(ccTime)dt;

- (void) showAt:(CGPoint)pos;

@property (nonatomic, readonly) b2Body *catcherBody;
@property (nonatomic, readonly) CCSprite *catcherSprite;
@property (nonatomic, readonly) CGPoint anchorPos;

@end
