//
//  PowerUp.m
//  Scroller
//
//  Created by min on 3/8/11.
//  Copyright 2011 L00Kout. All rights reserved.
//

#import "PowerUp.h"
#import "Constants.h"
#import "GamePlayLayer.h"

@implementation PowerUp
@synthesize state;

- (id) init {
	if ((self = [super init])) {
		gameObjectType = kGameObjectPowerUp;
		state = kPowerUpStateNone;
	}
	return self;
}

- (void) createPhysicsObject:(b2World *)theWorld {
	[super createPhysicsObject:theWorld];
	b2BodyDef playerBodyDef;
	playerBodyDef.type = b2_kinematicBody;
	playerBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
	playerBodyDef.userData = self;
	playerBodyDef.fixedRotation = false;
	
	body = theWorld->CreateBody(&playerBodyDef);
	
	b2CircleShape circleShape;
	circleShape.m_radius = 0.5f;
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &circleShape;
	fixtureDef.density = 5000.0f;
	fixtureDef.friction = 3.0f;
	fixtureDef.restitution =  0.18f;
	fixtureDef.isSensor = true;
	body->CreateFixture(&fixtureDef);	
}

- (void) explode {
	CCParticleSystem *system = [[GamePlayLayer sharedLayer] system];
	system.position = self.position;
	[system resetSystem];
}

@end
