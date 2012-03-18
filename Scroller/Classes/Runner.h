//
//  Runner.h
//  Scroller
//
//  Created by min on 1/15/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameObject.h"
#import "Box2D.h"
#import "PhysicsObject.h"

@class Building;

typedef enum {
	kRunnerStateNone,
	kRunnerRunning,
	kRunnerFalling,
	kRunnerJumping,
	kRunnerRolling,
    kRunnerMeteorHit,
    kRunnerFlying,
    kRunnerGliding
} RunnerState;


typedef enum {
    kRunnerSpeedBoostNone,
    kRunnerSpeedBoostDestroy,
    kRunnerSpeedBoostReceived,
    kRunnerSpeedBoostDrain,
    kRunnerSpeedBoostInEffect
} RunnerSpeedBoostState;

typedef enum {
    kCoolOffOff,
    kCoolOffNormal,
    kCoolOffEntrance,
    kCoolOffFromFlight
} CoolOffType;

@interface Runner : GameObject<PhysicsObject> {
	RunnerState             runnerState;
    RunnerSpeedBoostState   speedBoostState;
	CCRepeatForever         *inAirAction;
    CCRepeatForever         *flyingAction;
    BOOL                    isMousePressed;
    BOOL                    isFlying;
    CoolOffType             coolOff;
    char                    numJumpsPerformedInAir;
    char                    powerUpDoubleJumpCount;
    float32                 jumpHeight;
    CCSpeed                 *runSpeedAction;
    Building                *building;                      // Building player is on
    Building                *nextBuilding;                  // Next buiding player will see
    CFTimeInterval          speedBoostStartTime;
    CCParticleSystem        *trail;
    BOOL                    trailShowing;
    BOOL                    entranceMode;
    
    
    b2Vec2                  _force;
    float                   _height;
    float                   _speed;
    float                   _newSpeed;
}

- (void) stopFlying;
- (void) startFlying;
- (void) jump;
- (void) rollThenRunAnimation;
//- (void) landThenRunAnimation;
- (void) flyingAnimationFromGround;
- (void) flyingAnimationInAir;
- (void) glideAnimation;
- (void) fallingAnimation;
- (void) rollingAnimation;
- (void) runningAnimation;
- (void) jumpingAnimation;
- (void) createPhysicsObject:(b2World *)theWorld;
- (void) incrementDoubleJumpInventoryCount;
- (void) resetNumJumpsPerformedInAir;
- (float) distanceRemaining;
- (float) timeToEndOfBuilding;
- (float) timeSpeedBoostInEffect;
- (float) speedBoostDurationRemaining;
- (BOOL) canMakeToEndOfBuildingWithSpeedBoost;
- (void) BANG;

@property (nonatomic, readwrite, assign) BOOL isFlying;
@property (nonatomic, readwrite, assign) BOOL entranceMode;
@property (nonatomic, readwrite, assign) CoolOffType coolOff;
@property (nonatomic, readwrite, assign) BOOL isMousePressed;
@property (nonatomic, readwrite, assign) Building *building;
@property (nonatomic, readwrite, assign) Building *nextBuilding;
@property (nonatomic, readwrite) RunnerState runnerState;
@property (nonatomic, readwrite) RunnerSpeedBoostState speedBoostState;
@property (nonatomic, readwrite) float32 jumpHeight;
@property (nonatomic, readwrite) char powerUpDoubleJumpCount;
@property (nonatomic, readwrite) char numJumpsPerformedInAir;
@end
