//
//  Runner.m
//  Scroller
//
//  Created by min on 1/15/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import "Runner.h"
#import "Constants.h"
#import "GamePlayLayer.h"
#import "GameRules.h"
#import "StaticBackgroundLayer.h"

extern GameRules rules;

#define INITIAL_RUN_ANIM_DELAY      0.075f
#define MAX_ANIM_SPEEDUP_FACTOR     6.0f

// Private methods
@interface Runner(Private) 
- (void) setupAnimations;
- (void) handleFlight;
- (void) adjustAnimationSpeed;
- (void) flight;
- (void) spendFlightFuel;
@end  

@implementation Runner

@synthesize runnerState;
@synthesize jumpHeight;
@synthesize isMousePressed;
@synthesize speedBoostState;
@synthesize powerUpDoubleJumpCount;
@synthesize numJumpsPerformedInAir;
@synthesize building;
@synthesize nextBuilding;
@synthesize coolOff;
@synthesize entranceMode;
@synthesize isFlying;

static BOOL animationLoaded = NO;


- (void) fallingAnimation {
	b2Vec2 pos = [self body]->GetPosition();
	runnerState = kRunnerFalling;
	[self stopAllActions];
	CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"fallAnimation"] restoreOriginalFrame:NO];
	inAirAction = [CCRepeatForever actionWithAction:action];
	[self runAction:inAirAction];
}

- (void) flyingAnimationHelper {
    [self stopAllActions];
	CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"flyingAnimation"] restoreOriginalFrame:NO];
	flyingAction = [CCRepeatForever actionWithAction:action];
	[self runAction:flyingAction];        
}

- (void) flyingAnimationFromGround {
    runnerState = kRunnerFlying;
    [self stopAllActions];
    id flyingCallBack = [CCCallFunc actionWithTarget:self selector:@selector(flyingAnimationHelper)];
    id startJump = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"startJumpAnimation"] restoreOriginalFrame:NO];
    id sequence = [CCSequence actions:startJump, flyingCallBack, nil];
    [self runAction:sequence];	
}

- (void) flyingAnimationInAir {
    runnerState = kRunnerFlying;
    [self flyingAnimationHelper];
}

- (void) glideCallback {
    [self stopAllActions];
    id glide = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"glideAnimation"] restoreOriginalFrame:NO];
    id repeat = [CCRepeatForever actionWithAction:glide];
    [self runAction:repeat];
    
}

- (void) glideAnimation {
    runnerState = kRunnerGliding;
    [self stopAllActions];
    
    id callback = [CCCallFunc actionWithTarget:self selector:@selector(glideCallback)];
    
    id flyGlide = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"flyGlideAnimation"] restoreOriginalFrame:NO];
    id seq = [CCSequence actions:flyGlide, callback, nil];
    [self runAction:seq];    
}


- (void) rollingAnimation {
	[self stopAllActions];
	CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"rollAnimation"] restoreOriginalFrame:NO];
	[self runAction:action];
}

- (void) runningAnimation {
	if (runnerState != kRunnerRunning) {
        isFlying = NO;
        rules.max_zoom_out = MAX_ZOOM_OUT;
		runnerState = kRunnerRunning;
		[self stopAllActions];
		[self runAction:runSpeedAction]; 
	}
}

//- (void) landThenRunAnimation {
//	if (kRunnerFalling  == runnerState) {
//        id runCallBack = [CCCallFunc actionWithTarget:self selector:@selector(runningAnimation)];
//        CCAnimate *landAction = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"landAnimation"] restoreOriginalFrame:NO];
//        [self stopAction:inAirAction];
//        id sequence = [CCSequence actions:landAction, runCallBack, nil];
//        [self runAction:sequence];    
//    }
//}

- (void) rollThenRunAnimation {
	if (kRunnerFalling  == runnerState || kRunnerFlying == runnerState || kRunnerGliding == runnerState) {
        if (entranceMode == YES) {
            entranceMode = NO;
            world->SetGravity(b2Vec2(0.0f, GRAVITY));
            [[CCAnimationCache sharedAnimationCache] animationByName:@"fallAnimation"].delay = 0.075;
            coolOff = kCoolOffEntrance;
        } else if (runnerState == kRunnerFlying || runnerState == kRunnerGliding) {
            coolOff = kCoolOffFromFlight;
            [self unschedule:@selector(spendFlightFuel)];
        }
		runnerState = kRunnerRolling;                
		id runCallBack = [CCCallFunc actionWithTarget:self selector:@selector(runningAnimation)];
		CCAnimate *rollAction = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"rollAnimation"] restoreOriginalFrame:NO];
        [self stopAllActions];
		id sequence = [CCSequence actions:rollAction, runCallBack, nil];
		[self runAction:sequence];
	}
}

- (void) jumpingAnimation {
	runnerState = kRunnerJumping;
	[self stopAllActions];
	id inAirCallBack = [CCCallFunc actionWithTarget:self selector:@selector(fallingAnimation)];
	id startJump = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"startJumpAnimation"] restoreOriginalFrame:NO];
	id sequence = [CCSequence actions:startJump, inAirCallBack, nil];
	[self runAction:sequence];	
}


- (void) jump {
	if (runnerState != kRunnerFlying && runnerState != kRunnerRolling && numJumpsPerformedInAir < rules.num_jumps_allowed_in_air) {
		float xForce = 0.0;
        float jumpForce = rules.jump_force;

        if ((runnerState == kRunnerJumping || runnerState == kRunnerFalling) && powerUpDoubleJumpCount > 0) {
            jumpForce = JUMP_IMPULSE_FORCE + (body->GetLinearVelocity().y * -1);
            numJumpsPerformedInAir++;
            powerUpDoubleJumpCount--;
        }        
		b2Vec2 impulse = b2Vec2(body->GetMass() * xForce, body->GetMass() * jumpForce);
		b2Vec2 impulsePoint = body->GetPosition(); //playerBody->GetWorldCenter();
		body->ApplyLinearImpulse(impulse, impulsePoint);	

		[self jumpingAnimation];

	}
}

- (void) BANG {
    world->SetGravity(b2Vec2(0.0, -6.0));
    [self fallingAnimation];
    b2Vec2 impulse = b2Vec2(body->GetMass() * 50.0, body->GetMass() * 15);
    body->ApplyLinearImpulse(impulse, body->GetPosition());
}

- (void) showTrail {
    if (!trailShowing) {
        trailShowing = YES;
        [trail resetSystem];
    }
}

- (void) hideTrail {
    [trail stopSystem];
    trailShowing = NO;
}

- (void) drainPower {
//    CCLOG(@"############# DRAIN POWER");
	speedBoostState = kRunnerSpeedBoostDrain;
	[self unschedule:@selector(drainPower)];
}

- (void) spendFlightFuel {
    StaticBackgroundLayer *layer = [StaticBackgroundLayer sharedLayer];
    [layer shrinkFlightBar];
    if ([layer remainingFuel] <= 0.0f) {
        [self unschedule:@selector(spendFlightFuel)];
        [self stopFlying];
        [self fallingAnimation];
        coolOff = kCoolOffFromFlight;
    }
}

- (void) flight {
    CCLOG(@"---------------------------------- FLIGHT");
    [self unschedule:@selector(flight)];
    world->SetGravity(b2Vec2(0.0f, -9.8f));

    isFlying = YES;
    [self flyingAnimationFromGround];
    rules.max_zoom_out = 0.65;
    [self schedule:@selector(spendFlightFuel) interval:FLIGHT_CHECK_FREQUENCY];
}

- (void) startFlying {
//    [self stopAllActions];
//    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f], [CCCallFunc actionWithTarget:self selector:@selector(flight)], nil]]
    [self schedule:@selector(flight) interval:0.5];
}

- (void) stopFlying {
    [self unschedule:@selector(flight)];
    world->SetGravity(b2Vec2(0.0f, GRAVITY));
    isFlying = NO;
}


- (float) speedBoostDurationRemaining {
    if (speedBoostState == kRunnerSpeedBoostInEffect) {
        return rules.speed_boost_duration - (CFAbsoluteTimeGetCurrent() - speedBoostStartTime);
    }
    return NAN;
}

- (float) timeSpeedBoostInEffect {
    if (speedBoostState == kRunnerSpeedBoostInEffect) {
        return CFAbsoluteTimeGetCurrent() - speedBoostStartTime;
    }
    return NAN;
}

- (BOOL) canMakeToEndOfBuildingWithSpeedBoost {
    if (speedBoostState == kRunnerSpeedBoostInEffect) {
        float timeToEnd = ((building.position.x + building.size.width - self.position.x) / PTM_RATIO) / body->GetLinearVelocity().x;
        float speedBoostRemaining = rules.speed_boost_duration - (CFAbsoluteTimeGetCurrent() - speedBoostStartTime);
        return speedBoostRemaining > timeToEnd;
    } 
    
    return NO;
}


- (float) distanceRemaining {
    return (building.position.x + building.size.width - self.position.x) / PTM_RATIO;
}

- (float) timeToEndOfBuilding {
    float distanceRemaining = [self distanceRemaining];
    return distanceRemaining / body->GetLinearVelocity().x;
}

- (void) incrementDoubleJumpInventoryCount {
    ++powerUpDoubleJumpCount;
}

- (void) resetNumJumpsPerformedInAir {
    numJumpsPerformedInAir = 0;
}

- (void) adjustAnimationSpeed {
    _newSpeed = _speed / MAX_RUN_SPEED_ADJ;
    if (_newSpeed > 1.0 && _newSpeed < MAX_ANIM_SPEEDUP_FACTOR) {
        [runSpeedAction setSpeed:_newSpeed];
    } else if (_newSpeed > MAX_ANIM_SPEEDUP_FACTOR) {
        [runSpeedAction setSpeed:MAX_ANIM_SPEEDUP_FACTOR];
    } else {
        [runSpeedAction setSpeed:1.0];
    }    
}

- (void) handleFlight {
    if (isMousePressed) {
        b2Vec2 f = b2Vec2(0.0f, body->GetMass()*20.0f);
        body->ApplyForce(f, body->GetPosition());            
    } 
    if (body->GetLinearVelocity().x < MAX_RUN_SPEED*2) {
        b2Vec2 f = b2Vec2(body->GetMass()*RUN_ACCELERATION_FORCE, 0.0f);
        body->ApplyForce(f, body->GetPosition());
    }
    
    if (self.position.y < -100.0f) {
        self.visible = NO;
    }
}

- (void) updateObject:(ccTime)dt {
#if USE_FIXED_TIMESTEP
    self.position = CGPointMake(self.smoothedPosition.x * PTM_RATIO, self.smoothedPosition.y * PTM_RATIO + PLAYER_Y_OFFSET);
#else
	self.position = CGPointMake(body->GetPosition().x * PTM_RATIO, body->GetPosition().y * PTM_RATIO + PLAYER_Y_OFFSET);
#endif
    if (isFlying) {
        [self handleFlight];
    } else {
        if (runnerState == kRunnerFalling || runnerState == kRunnerJumping) {
            // If not in dramatic entrance mode and mouse is pressed while in jump or fall state, then
            // apply a constant upward force to the runner so that he stays in the air longer (floaty force).
            if (!entranceMode && isMousePressed) {
                body->ApplyForce(b2Vec2(0.0f, body->GetMass()*FLOAT_FORCE), body->GetPosition());
            }
            // Determine max height used as one of the factors to determine whether runner rolls on landing
            _height = body->GetPosition().y;
            if (_height > jumpHeight) {
                jumpHeight = _height;
            }
            
            if (self.position.y < -100.0f) {
                self.visible = NO;
            }
        }

        _speed = body->GetLinearVelocity().x;

        // Player acceleration
        if (_speed < MAX_RUN_SPEED) {
            body->ApplyForce(b2Vec2(body->GetMass()*RUN_ACCELERATION_FORCE, 0.0f), body->GetPosition());
            if (speedBoostState == kRunnerSpeedBoostDrain || coolOff != kCoolOffOff) {
                CCLOG(@"==========+++++++++++++++++++++++ returned to normal speed");
                coolOff = kCoolOffOff;
                speedBoostState = kRunnerSpeedBoostNone;
            }
        } else {
//            if (_speed > COOL_OFF_SPEED) {
//                coolOff = kCoolOffNormal;
//            }
            if (coolOff == kCoolOffNormal) {
                body->ApplyForce(b2Vec2(-body->GetMass()*RUN_DECELERATION_FORCE, 0.0f), body->GetPosition());            
            } else if (coolOff == kCoolOffEntrance) {
                body->ApplyForce(b2Vec2(-body->GetMass()*RUN_DECELERATION_FORCE_ENTRANCE, 0.0f), body->GetPosition());                          
            } else if (coolOff == kCoolOffFromFlight) {
                body->ApplyForce(b2Vec2(-body->GetMass()*RUN_DECELERATION_FORCE_AFTER_FLIGHT, 0.0f), body->GetPosition());
            } else if (speedBoostState == kRunnerSpeedBoostDrain) {
                body->ApplyForce(b2Vec2(-body->GetMass()*RUN_ACCELERATION_FORCE, 0.0f), body->GetPosition());
            }             
            if (_speed > 25.0f) {
                if (runnerState == kRunnerRunning) {
                    [self showTrail];
                    trail.speed = 100+_speed;
                    trail.position = ccp(self.position.x - 15, self.position.y - 38);
                }
            } else {
                [self hideTrail];
            }
        }


        if (speedBoostState == kRunnerSpeedBoostReceived) {
            speedBoostState = kRunnerSpeedBoostInEffect;
            float xForce = 5.5f;
            float yForce = 3.0f;
            
            float zoom = [[GamePlayLayer sharedLayer] scale];
            
            // We're zoomed out, which means player speed is pretty high. Give more oompfh to jump height.
            if (zoom <= 0.35) {
                yForce += 4.0;
            } else if (zoom <= 0.50) {
                yForce += 3.0;
            } else if (zoom <= 0.65) {
                yForce += 2.0f;
            } 
            
            b2Vec2 impulse = b2Vec2(body->GetMass() * xForce, body->GetMass() * yForce);
            b2Vec2 impulsePoint = body->GetPosition(); //playerBody->GetWorldCenter();
            body->ApplyLinearImpulse(impulse, impulsePoint);
            // May have hit more than one speed boost at the same time, so unschedule existing one first.
            [self unschedule:@selector(drainPower)];
            speedBoostStartTime = CFAbsoluteTimeGetCurrent();
            [self schedule:@selector(drainPower) interval:rules.speed_boost_duration];
            
        } else if (speedBoostState == kRunnerSpeedBoostInEffect) {

        }        
        
        if (CCRANDOM_0_1() <= rules.bldg_crumble_probability) {
            if ([self distanceRemaining] <= 15.0f && [building numTilesHigh] > [nextBuilding numTilesHigh]
                || powerUpDoubleJumpCount > 3) {
                rules.jump_force += 2.0;
                [building crumble];
            } 
        }

    }
}

#pragma mark -
#pragma mark Initialization methods
- (id) init {
	if ((self = [super init])) {
		gameObjectType = kGameObjectRunner;
		runnerState = kRunnerStateNone;
        speedBoostState = kRunnerSpeedBoostNone;
        powerUpDoubleJumpCount = 0;
        numJumpsPerformedInAir = 0;
        coolOff = kCoolOffOff;
        entranceMode = YES;
        isFlying = NO;
        
		self.scale = PLAYER_SCALE;
        self.jumpHeight = 0.0;
		[self setupAnimations];
        
        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"runAnimation"] restoreOriginalFrame:NO];
        id runAction = [CCRepeatForever actionWithAction:action];
        runSpeedAction = [CCSpeed actionWithAction:runAction speed:1.0f];
        [runSpeedAction retain];    // must retain or it will crash
        
        
        trail = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"trail.plist"];
        [[GamePlayLayer sharedLayer] addChild:trail];
        [trail stopSystem];
        
        [self schedule:@selector(adjustAnimationSpeed) interval:0.2];
	}
	return self;
}

- (void) createPhysicsObject:(b2World *)theWorld {
	[super createPhysicsObject:theWorld];
	b2BodyDef playerBodyDef;
	playerBodyDef.type = b2_dynamicBody;
	playerBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
	playerBodyDef.userData = self;
	playerBodyDef.fixedRotation = true;
	
	body = theWorld->CreateBody(&playerBodyDef);
	
	b2CircleShape circleShape;
	circleShape.m_radius = HIT_CIRCLE_RADIUS;
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &circleShape;
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	fixtureDef.restitution =  0.0f;
	body->CreateFixture(&fixtureDef);
	
	
	b2PolygonShape sensorShape;
	sensorShape.SetAsBox(0.2f, 
						 0.6f,
                         b2Vec2(0, 0.9), 0);
	fixtureDef.shape = &sensorShape;
	fixtureDef.density = 0.0;
	body->CreateFixture(&fixtureDef);
	
	b2Vec2 linVel = b2Vec2(INITIAL_RUN_SPEED, 0.0);
	body->SetLinearVelocity(linVel);
	
}

- (void) setupAnimations {
	if (NO == animationLoaded) {
		animationLoaded = YES;
        CCSpriteFrame *frame;
		NSMutableArray *animFrames = [NSMutableArray array];
		for (int i = 3; i <= 16; i++) {
			NSString *file = [NSString stringWithFormat:@"Run-Cycle-%d.png", i];
			frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
			[animFrames addObject:frame];
		}	
		
		NSMutableArray *startJumpFrames = [NSMutableArray array];
		for (int i = 1; i <= 4; i++) {
			NSString *file = [NSString stringWithFormat:@"Jump-Cycle-Start-%d.png", i];
			frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
			[startJumpFrames addObject:frame];
		}	
		
		NSMutableArray *fallFrames = [NSMutableArray array];
		for (int i = 1; i <= 9; i++) {
			NSString *file = [NSString stringWithFormat:@"Jump-Cycle-%d.png", i];
			frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
			[fallFrames addObject:frame];
		}	
        
		NSMutableArray *rollFrames = [NSMutableArray array];
		for (int i = 3; i <= 10; i++) {
			NSString *file = [NSString stringWithFormat:@"Roll-Cycle-%d.png", i];
			frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
			[rollFrames addObject:frame];
		}	
        
        //		NSMutableArray *landFrames = [NSMutableArray array];
        //        for (int i = 1; i <= 2; i++) {
        //			NSString *file = [NSString stringWithFormat:@"Land-Cycle-%d.png", i];
        //            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
        //            [landFrames addObject:frame];
        //        }
        
        NSMutableArray *flyingFrames = [NSMutableArray array];
        for (int i = 1; i <= 3; i++) {
            NSString *file = [NSString stringWithFormat:@"Fly-Cycle-%d.png", i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [flyingFrames addObject:frame];
        }
        
        NSMutableArray *flyGlideFrames = [NSMutableArray array];
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Fly-Glide.png"];
        [flyGlideFrames addObject:frame];
        //        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Glide-Cycle-1.png"];
        //        [flyGlideFrames addObject:frame];
        
        NSMutableArray *glideFrames = [NSMutableArray array];
        for (int i = 1; i <= 3; i++) {
            NSString *file = [NSString stringWithFormat:@"Glide-Cycle-%d.png", i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [glideFrames addObject:frame];
        }
        
		CCAnimation *animRunning = [CCAnimation animationWithFrames:animFrames delay:INITIAL_RUN_ANIM_DELAY];
		CCAnimation *animStartJump = [CCAnimation animationWithFrames:startJumpFrames delay:0.075];
        CCAnimation *animFall = [CCAnimation animationWithFrames:fallFrames delay:0.1];
		CCAnimation *animRoll = [CCAnimation animationWithFrames:rollFrames delay:0.05];
        CCAnimation *animFlying = [CCAnimation animationWithFrames:flyingFrames delay:0.075];
        CCAnimation *animFlyGlide = [CCAnimation animationWithFrames:flyGlideFrames delay:0.075];
        CCAnimation *animGlide = [CCAnimation animationWithFrames:glideFrames delay:0.075];
        
        //        CCAnimation *animLand = [CCAnimation animationWithFrames:landFrames delay:0.05];
        
		[[CCAnimationCache sharedAnimationCache] addAnimation:animRunning name:@"runAnimation"];
		[[CCAnimationCache sharedAnimationCache] addAnimation:animStartJump name:@"startJumpAnimation"];
		[[CCAnimationCache sharedAnimationCache] addAnimation:animFall name:@"fallAnimation"];	
		[[CCAnimationCache sharedAnimationCache] addAnimation:animRoll name:@"rollAnimation"];        
		[[CCAnimationCache sharedAnimationCache] addAnimation:animFlying name:@"flyingAnimation"];        
        [[CCAnimationCache sharedAnimationCache] addAnimation:animFlyGlide name:@"flyGlideAnimation"];        
		[[CCAnimationCache sharedAnimationCache] addAnimation:animGlide name:@"glideAnimation"];        
        
        //        [[CCAnimationCache sharedAnimationCache] addAnimation:animLand name:@"landAnimation"];        
        
    }
}

- (void) dealloc {
    [runSpeedAction release];
    [super dealloc];
}

@end
