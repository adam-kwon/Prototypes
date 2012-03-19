//
//  Energy.mm
//  cloudjump
//
//  Created by Min Kwon on 3/18/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "Constants.h"
#import "Energy.h"

@implementation Energy


- (id) init {
	if ((self = [super init])) {
		gameObjectType = kGameObjectEnergy;
	}
	return self;
}

- (void) createPhysicsObject:(b2World *)theWorld {
    world = theWorld;
	b2BodyDef playerBodyDef;
	playerBodyDef.type = b2_kinematicBody;
	playerBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
	playerBodyDef.userData = self;
	playerBodyDef.fixedRotation = false;
	
	body = theWorld->CreateBody(&playerBodyDef);
	
	b2CircleShape circleShape;
	circleShape.m_radius = ([self boundingBox].size.width/PTM_RATIO)/2;
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &circleShape;
	fixtureDef.density = 5000.0f;
	fixtureDef.friction = 3.0f;
	fixtureDef.restitution =  0.18f;
	fixtureDef.isSensor = true;
//    fixtureDef.filter.categoryBits = CATEGORY_DEFAULT;
//    fixtureDef.filter.maskBits = CATEGORY_RUNNER;
//    fixtureDef.filter.groupIndex = 2;
	body->CreateFixture(&fixtureDef);	
}


@end
