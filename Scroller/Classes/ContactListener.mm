//
//  ContactListener.m
//  Scroller
//
//  Created by min on 1/16/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import "ContactListener.h"
#import "Runner.h"
#import "Meteor.h"
#import "Building.h"
#import "PowerUpSpeedBoost.h"
#import "PowerUpDoubleJump.h"
#import "PowerUpFlight.h"
#import "PowerUpSpeedBoostExtender.h"
#import "Constants.h"
#import "SimpleAudioEngine.h"
#import "GamePlayLayer.h"
#import "MainGameScene.h"
#import "GameRules.h"
#import "StaticBackgroundLayer.h"
#import "GamePlayLayer.h"
#import "Runner.h"

extern GameRules rules;

#define IS_RUNNER(x,y)          (x.gameObjectType == kGameObjectRunner || y.gameObjectType == kGameObjectRunner)
#define IS_PLATFORM(x,y)        (x.gameObjectType == kGameObjectPlatform || y.gameObjectType == kGameObjectPlatform)
#define IS_METEOR(x,y)          (x.gameObjectType == kGameObjectMeteor || y.gameObjectType == kGameObjectMeteor)
#define IS_SPEED_BOOST(x,y)     (x.gameObjectType == kGameObjectPowerUpSpeedBoost || y.gameObjectType == kGameObjectPowerUpSpeedBoost)
#define IS_DOUBLE_JUMP(x,y)     (x.gameObjectType == kGameObjectPowerUpDoubleJump || y.gameObjectType == kGameObjectPowerUpDoubleJump)
#define IS_SPEED_BOOST_EXT(x,y) (x.gameObjectType == kGameObjectPowerUpSpeedBoostExtender || y.gameObjectType == kGameObjectPowerUpSpeedBoostExtender)
#define IS_FLIGHT(x,y)          (x.gameObjectType == kGameObjectPowerUpFlight || y.gameObjectType == kGameObjectPowerUpFlight)


ContactListener::ContactListener() {
}

ContactListener::~ContactListener() {
}

void ContactListener::BeginContact(b2Contact *contact) {
	GameObject *o1 = (GameObject*)contact->GetFixtureA()->GetBody()->GetUserData();
	GameObject *o2 = (GameObject*)contact->GetFixtureB()->GetBody()->GetUserData();
	
	if (IS_PLATFORM(o1, o2) && IS_RUNNER(o1, o2)) {
        float diff = CFAbsoluteTimeGetCurrent() - startContactTime;
		Runner *runner = [[GamePlayLayer sharedLayer] runner];
        Building *bldg = (Building*)(o1.gameObjectType == kGameObjectPlatform ? o1 : o2);
        
        if (runner.isFlying) {
            [runner stopFlying];
            [runner setJumpHeight:0.0f];
            [runner rollThenRunAnimation];
        } else {
            if ((diff >= MAX_IN_AIR_TRESHOLD_NORMAL_JUMP && runner.jumpHeight - [runner body]->GetPosition().y > ROLL_THRESHOLD_NORMAL_HEIGHT) 
                || runner.jumpHeight - [runner body]->GetPosition().y > ROLL_THRESHOLD_HIGH_HEIGHT
                || diff >= MAX_IN_AIR_TRESHOLD_LONG_JUMP) {
                [runner setJumpHeight:0.0f];
                [runner rollThenRunAnimation];
            } else {
                [runner setJumpHeight:0.0f];
                [runner runningAnimation];
            }
        }
        
        [runner resetNumJumpsPerformedInAir];
        [runner setBuilding:bldg];
        [[GamePlayLayer sharedLayer] sendMeteorShower];
        [[GamePlayLayer sharedLayer] queueMeteor];
        rules.jump_force = JUMP_IMPULSE_FORCE;
    } else if (IS_PLATFORM(o1, o2) && IS_METEOR(o1, o2)) {
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.10f];
		[[SimpleAudioEngine sharedEngine] playEffect:@"bomb_hit.caf"];
		[[SimpleAudioEngine sharedEngine] playEffect:@"crumble.caf"];
     //   [[SimpleAudioEngine sharedEngine] setEffectsVolume:1.0f];
        MainGameScene *mainScene = (MainGameScene*)[[GamePlayLayer sharedLayer] parent];
        [mainScene quake];

	} else if (IS_RUNNER(o1, o2) && IS_SPEED_BOOST(o1, o2)) {
		PowerUpSpeedBoost *powerUp = (PowerUpSpeedBoost*)(o1.gameObjectType == kGameObjectPowerUpSpeedBoost ? o1 : o2);
		powerUp.state = kPowerUpStateDestroy;
        [[StaticBackgroundLayer sharedLayer] displayPowerUpLabel:kPowerUpLableSpeedBoost];
		[[GamePlayLayer sharedLayer] runner].speedBoostState = kRunnerSpeedBoostReceived;
	} else if (IS_RUNNER(o1, o2) && IS_DOUBLE_JUMP(o1, o2)) {
        PowerUpDoubleJump *powerUp = (PowerUpDoubleJump*)(o1.gameObjectType == kGameObjectPowerUpDoubleJump ? o1 : o2);
		powerUp.state = kPowerUpStateDestroy;
        [[StaticBackgroundLayer sharedLayer] displayPowerUpLabel:kPowerUpLableDoubleJump];
        [[[GamePlayLayer sharedLayer] runner] incrementDoubleJumpInventoryCount];
	} else if (IS_RUNNER(o1, o2) && IS_SPEED_BOOST_EXT(o1, o2)) {
        PowerUpSpeedBoostExtender *powerUp = (PowerUpSpeedBoostExtender*)(o1.gameObjectType == kGameObjectPowerUpSpeedBoostExtender ? o1 : o2);
        [[StaticBackgroundLayer sharedLayer] displayPowerUpLabel:kPowerUpLableSpeedBoostExtender];
        powerUp.state = kPowerUpStateDestroy;
        rules.speed_boost_duration += rules.speed_extension_duration;
    } else if (IS_RUNNER(o1, o2) && IS_FLIGHT(o1, o2)) {
        PowerUpFlight *powerUp = (PowerUpFlight*)(o1.gameObjectType == kGameObjectPowerUpFlight ? o1 : o2);
        [[StaticBackgroundLayer sharedLayer] growFlightBar];
        [[StaticBackgroundLayer sharedLayer] displayPowerUpLabel:kPowerUpLableFlight];
        powerUp.state = kPowerUpStateDestroy;        
 //       [[[GamePlayLayer sharedLayer] runner] startFlying];
    } else if (IS_RUNNER(o1, o2) && IS_METEOR(o1, o2)) { 
        Runner *runner = [[GamePlayLayer sharedLayer] runner];
        [[GamePlayLayer sharedLayer] setGameOver: true];
        [runner setRunnerState:kRunnerMeteorHit];
        [runner setVisible:NO];
        Meteor *meteor = (Meteor*)[[GamePlayLayer sharedLayer] meteor];
        if (meteor) {
            [meteor setState:kMeteorStateDestroy];
        }
    }
}

void ContactListener::EndContact(b2Contact *contact) {
	GameObject *o1 = (GameObject*)contact->GetFixtureA()->GetBody()->GetUserData();
	GameObject *o2 = (GameObject*)contact->GetFixtureB()->GetBody()->GetUserData();
    Runner *runner = [[GamePlayLayer sharedLayer] runner];	
	if (IS_RUNNER(o1, o2) && IS_PLATFORM(o1, o2) && [runner.building isCrumbling] == NO) {
        startContactTime = CFAbsoluteTimeGetCurrent();
		if (runner.runnerState != kRunnerJumping) {
			[runner fallingAnimation];
		}
	}
}

void ContactListener::PreSolve(b2Contact *contact, const b2Manifold *oldManifold) {
}

void ContactListener::PostSolve(b2Contact *contact, const b2ContactImpulse *impulse) {
}