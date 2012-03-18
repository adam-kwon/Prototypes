//
//  GameObject.h
//  Scroller
//
//  Created by min on 1/16/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Box2D.h"
#import "PhysicsObject.h"

#if USE_FIXED_TIMESTEP
    #import "CCPhysicsSprite.h"
#endif

@class GameScene;

#if USE_FIXED_TIMESTEP
@interface GameObject : CCPhysicsSprite<PhysicsObject> {
#else
@interface GameObject : CCSprite<PhysicsObject> {    
#endif
	GameObjectType			gameObjectType;
	b2World					*world;
	b2Body					*body;
}
    
- (void) updateObject:(ccTime)dt;
    
@property (nonatomic, readwrite) GameObjectType gameObjectType;
@property (nonatomic, readwrite) b2Body *body;
@end
