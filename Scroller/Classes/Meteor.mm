//
//  Meteor.m
//  Scroller
//
//  Created by min on 3/1/11.
//  Copyright 2011 L00Kout. All rights reserved.
//

#import "Meteor.h"
#import "GamePlayLayer.h"

@implementation Meteor
@synthesize state;

- (id) init {
	if ((self = [super init])) {
		gameObjectType = kGameObjectMeteor;
		state = kMeteorStateNone;
		self.position = ccp(340.0f, 600.0f);
		self.scale = 0.7;
		CCLOG(@"INIT Meteor");
		
	}
	return self;
}

- (void) createPhysicsObject:(b2World *)theWorld {
	[super createPhysicsObject:theWorld];
	b2BodyDef playerBodyDef;
	playerBodyDef.type = b2_dynamicBody;
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
	body->CreateFixture(&fixtureDef);

	b2Vec2 impulse = b2Vec2(body->GetMass() * -10, body->GetMass() * -30);
	b2Vec2 impulsePoint;
	impulsePoint.x = body->GetPosition().x + 0.05;
	impulsePoint.y = body->GetPosition().y;
	body->ApplyLinearImpulse(impulse, impulsePoint);	
}

- (void) explode {
	CCParticleSystem *system = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"explosion.plist"];
	system.positionType = kCCPositionTypeFree;
	system.autoRemoveOnFinish = YES;
	system.position = self.position;
	[[GamePlayLayer sharedLayer] addChild:system z:10 tag:TAG_METEOR_EXPLODE];
}

- (void) updateObject:(ccTime)dt {
	self.position = CGPointMake(body->GetPosition().x * PTM_RATIO + 12, 
								body->GetPosition().y * PTM_RATIO + 17);
	self.rotation = CC_RADIANS_TO_DEGREES(body->GetAngle());
	
}


@end
