//
//  SpriteObject.m
//  apocalypsemmxii
//
//  Created by Min Kwon on 11/16/11.
//  Copyright (c) 2011 GAMEPEONS LLC. All rights reserved.
//

#import "SpriteObject.h"

@implementation SpriteObject
@synthesize gameObjectType;
@synthesize body;
@synthesize size;
@synthesize lifeState;

- (id) init {
	if ((self = [super init])) {
		gameObjectType = kGameObjectNone;
        lifeState = kLifeStateAlive;
        isSafeToDelete = NO;
        world = NULL;
		body = NULL;
	}
	return self;
}

- (b2Body*) getBody {
	return body;
}

- (void) createPhysicsObject:(b2World *)theWorld {
	world = theWorld;	
}

- (BOOL) isSafeToDelete {
    return isSafeToDelete;
}


- (void) safeToDelete {
    isSafeToDelete = YES;
}

- (GameObjectType) gameObjectType {
    return gameObjectType;
}

- (void) updateObject:(ccTime)dt {
    // Override
}

- (void) destroyPhysicsObject {
    if (world != NULL) {
        world->DestroyBody(body);
    }
}

/*
 * Make sure dealloc is being called. If not, that means there is a memory leak.
 */
- (void) dealloc {
//	CCLOG(@"----------------------------------> SPRITE OJBJECT DEALLOC");
//    if (world != NULL) {
//        //CCLOG(@"**** GmaeObject + Physics Body dealloc is called, type: %d", gameObjectType);
//        world->DestroyBody(body);
//    } else {
//        //CCLOG(@"**** GmaeObject dealloc is called, type: %d", gameObjectType);
//    }
	[super dealloc];	
}

@end
