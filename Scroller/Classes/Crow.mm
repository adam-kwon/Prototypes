//
//  Crow.m
//  Scroller
//
//  Created by min on 3/14/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import "Crow.h"

@implementation Crow
@synthesize state;

static BOOL animationLoaded = NO;

-(void) setupAnimations {
    if (NO == animationLoaded) {
        animationLoaded = YES;
        NSMutableArray *animFrames = [NSMutableArray array];
        for (int i = 1; i <= 6; i++) {
			NSString *file = [NSString stringWithFormat:@"Crow%d.png", i];
    		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
			[animFrames addObject:frame];            
        }
        
        CCAnimation *flying = [CCAnimation animationWithFrames:animFrames delay:0.035];        
		[[CCAnimationCache sharedAnimationCache] addAnimation:flying name:@"birdFlyingAnimation"];
    }
}

-(id) init {
    if ((self = [super init])) {
        gameObjectType = kGameObjectCrow;
        state = kBirdSitting;
        [self setupAnimations];
    }
    return self;
}


-(id) generateBirdPath {
    float v = CCRANDOM_0_1();
    float d = v * 600;
    if (v < 0) {
        d = v * 500;
    }
    if (self.flipX == NO) {
        d = -d;
    }
    id action = [CCMoveTo actionWithDuration:1.5+CCRANDOM_0_1()*1 position:ccp(self.position.x + d, 1000)];
    return action;
}

-(void) destroyMe {
    state = kBirdDestroy;
}

-(void) fly {
    if (state != kBirdFlying) {
        state = kBirdFlying;
        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"birdFlyingAnimation"] restoreOriginalFrame:NO];
        CCRepeatForever *flyAction = [CCRepeatForever actionWithAction:action];
        id fly = [self generateBirdPath];
        id callback = [CCCallFunc actionWithTarget:self selector:@selector(destroyMe)];
        id sequence = [CCSequence actions:fly, callback, nil];
        [self runAction:sequence];
        [self runAction:flyAction];
    }
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


@end
