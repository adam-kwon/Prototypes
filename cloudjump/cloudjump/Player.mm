//
//  Player.mm
//  cloudjump
//
//  Created by Min Kwon on 3/9/12.
//  Copyright (c) 2012 GAMEPEONS. All rights reserved.
//

#import "Player.h"
#import "AudioEngine.h"

@implementation Player
@synthesize state;

- (id) init {
    self = [super init];
    if (self) {
        gameObjectType = kGameObjectPlayer;
        state = kPlayerStateNone;
        screenSize = [[CCDirector sharedDirector] winSize];
    }
    return self;
}

- (void) createPhysicsObject:(b2World *)theWorld {
    world = theWorld;
    
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
    
	bodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
	bodyDef.userData = self;
	body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox([self boundingBox].size.width/2/PTM_RATIO,[self boundingBox].size.height/2/PTM_RATIO);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);    
}

- (void) jump {
    self.state = kPlayerStateNone;
//    if (body->GetLinearVelocity().y < 0) {
//        body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x, 0));
//
//    }
    body->SetLinearVelocity(b2Vec2(body->GetLinearVelocity().x, 0));

    body->ApplyLinearImpulse(b2Vec2(0, body->GetMass()*20), body->GetPosition());    
}


- (void) updateObject:(ccTime)dt withAccelX:(float)accelX {
    
    float halfSize = [self boundingBox].size.width/2;
    
    // If going out of view (left or right), make it appear from opposite side
    if (self.position.x + halfSize > screenSize.width) {
        body->SetActive(NO);
        body->SetTransform(b2Vec2((halfSize+2)/PTM_RATIO, body->GetPosition().y), 0);
        body->SetActive(YES);
    
    } else if (self.position.x - halfSize < 0) {
        body->SetActive(NO);
        body->SetTransform(b2Vec2((screenSize.width-(halfSize+2))/PTM_RATIO, body->GetPosition().y), 0);
        body->SetActive(YES);
    }


    body->ApplyForce(b2Vec2(accelX*50, 0.f), body->GetPosition());

    if (state == kPlayerStateGotEnergy) {
        [[AudioEngine sharedEngine] playEffect:@"energy.caf"];
        [self jump];
    }

    self.position = ccp(body->GetPosition().x * PTM_RATIO, body->GetPosition().y * PTM_RATIO);
    self.rotation = -1 * CC_RADIANS_TO_DEGREES(body->GetAngle());

}

@end

