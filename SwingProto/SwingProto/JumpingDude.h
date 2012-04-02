//
//  JumpingDude.h
//  SwingProto
//
//  Created by James Sandoz on 3/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GameObject.h"

@interface JumpingDude : CCNode<GameObject> {
    CCNode *parent;
    
    b2World *world;
    b2Body *body;
    CCSprite *sprite;
    
    ContactLocation top;
    ContactLocation bottom;
}

- (id) initWithParent:(CCNode *)parent;
- (void) createPhysicsObject:(b2World*)theWorld at:(CGPoint)p;

@property (nonatomic, readonly) b2Body *body;
@property (nonatomic, readonly) CCSprite *sprite;

@end
