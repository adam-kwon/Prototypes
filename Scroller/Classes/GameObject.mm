//
//  GameObject.m
//  Scroller
//
//  Created by min on 1/16/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import "GameObject.h"

@implementation GameObject
@synthesize gameObjectType;
@synthesize body;

- (id) init {
	if ((self = [super init])) {
		gameObjectType = kGameObjectNone;
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

- (void) updateObject:(ccTime)dt {
    // Override
}

/*
 * Make sure dealloc is being called. If not, that means there is a memory leak.
 */
- (void) dealloc {
//	CCLOG(@"GmaeObject dealloc is called, type: %d", gameObjectType);
	[super dealloc];	
}

@end
