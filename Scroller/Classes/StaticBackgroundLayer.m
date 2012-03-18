//
//  StaticBackgroundLayer.m
//  Scroller
//
//  Created by Yongrim Rhee on 3/13/11.
//  Copyright 2011 L00Kout LLC. All rights reserved.
//

#import "StaticBackgroundLayer.h"
#import "Constants.h"
#import "BackgroundMeteor.h"
#import "GameOptions.h"

extern GameOptions gameOptions;

@implementation StaticBackgroundLayer

static StaticBackgroundLayer* instanceOfLayer;

+ (StaticBackgroundLayer*) sharedLayer {
	NSAssert(instanceOfLayer != nil, @"StaticBackgroundLayer instance not yet initialized!");
	return instanceOfLayer;
}


-(void) pauseRain {
//    [[SimpleAudioEngine sharedEngine] stopEffect:rainSound];
//    [rain stopSystem];
//    [self unschedule:@selector(pauseRain)];    
//    [self schedule:@selector(startRain) interval:10 + CCRANDOM_0_1() * 5];
}

-(void) stopRain {
//    [self unschedule:@selector(pauseRain)];  
//    [self unschedule:@selector(startRain)];  
//    [[SimpleAudioEngine sharedEngine] stopEffect:rainSound];
//    [rain stopSystem];
//    [self removeChildByTag:TAG_PARTICLE_SYSTEM_RAIN cleanup:YES]; 
}

-(void) initPowerUpLabels {
    lblSpeedBoost = [CCLabelTTF labelWithString:@"BOOST!" fontName:@"Helvetica" fontSize:16];
    lblSpeedBoost.visible = NO;
    [self addChild:lblSpeedBoost];
    lblSpeedBoost.position = ccp(250, 250);
    
    lblSpeedBoostExtender = [CCLabelTTF labelWithString:@"EXTEND!" fontName:@"Helvetica" fontSize:16];
    lblSpeedBoostExtender.visible = NO;
    [self addChild:lblSpeedBoostExtender];
    lblSpeedBoostExtender.position = ccp(250, 250);
    
    
    lblDoubleJump = [CCLabelTTF labelWithString:@"DOUBLE JUMP!" fontName:@"Helvetica" fontSize:16];
    lblDoubleJump.visible = NO;
    [self addChild:lblDoubleJump];
    lblDoubleJump.position = ccp(250, 250);
    
    lblFlight = [CCLabelTTF labelWithString:@"+5 SECONDS FLIGHT!" fontName:@"Helvetica" fontSize:16];
    lblFlight.visible = NO;
    [self addChild:lblFlight];
    lblFlight.position = ccp(250, 250);
}

- (void) growFlightBar {
    flightBar.scaleX += FLIGHTBAR_UNIT_SIZE;
}

- (void) shrinkFlightBar {
    flightBar.scaleX -= (FLIGHTBAR_UNIT_SIZE/(FLIGHT_TIME_PER_POWERUP/FLIGHT_CHECK_FREQUENCY));
    if (flightBar.scaleX <= 0.0f) {
        flightBar.scaleX = 0.0f;
    }
}

- (float) remainingFuel {
    return flightBar.scaleX / FLIGHTBAR_UNIT_SIZE;
}

- (void) initFlightBar {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    flightBar = [CCSprite spriteWithSpriteFrameName:@"1x2.png"];
    flightBar.anchorPoint = ccp(0, 0);
    flightBar.position = ccp(5, screenSize.height - 5);
    flightBar.scaleX = 0.0;
    [batchNode addChild:flightBar];
}

-(id) init {
    self = [super init];
    if (self) {
        instanceOfLayer = self;
        batchNode = [CCSpriteBatchNode batchNodeWithFile:@"BackgroundAtlas.png"];
        [self setIsTouchEnabled:NO];
        [self createBackground];
        [self initPowerUpLabels];
        [self initFlightBar];
    }
    
    return self;
}

-(void) displayPowerUpLabelCallback {
    switch (powerUpLabelKind) {
        case kPowerUpLableFlight:
            lblFlight.visible = NO;
            lblFlight.scale = 1.0;
            lblFlight.position = ccp(250, 250);
            break;
        case kPowerUpLableDoubleJump:
            lblDoubleJump.visible = NO;
            lblDoubleJump.scale = 1.0;
            lblDoubleJump.position = ccp(250, 250);
            break;
        case kPowerUpLableSpeedBoost:
            lblSpeedBoost.visible = NO;
            lblSpeedBoost.scale = 1.0;
            lblSpeedBoost.position = ccp(250, 250);
            break;
        case kPowerUpLableSpeedBoostExtender:
            lblSpeedBoostExtender.visible = NO;
            lblSpeedBoostExtender.scale = 1.0;
            lblSpeedBoostExtender.position = ccp(250, 250);
            break;
    }    
}

-(void) displayPowerUpLabel:(PowerUpLableKind)lblType {
    powerUpLabelKind = lblType;
    id callback = [CCCallFunc actionWithTarget:self selector:@selector(displayPowerUpLabelCallback)];
    id action = [CCMoveTo actionWithDuration:0.5 position:ccp(250, 300)];
    id action2 = [CCFadeOut actionWithDuration:0.5];
    id action3 = [CCScaleTo actionWithDuration:0.5 scale:1.5];
    id s = [CCSpawn actions:action, action2, action3, nil];
    id seq = [CCSequence actions:s, callback, nil];
    
    switch (powerUpLabelKind) {
        case kPowerUpLableFlight:
            lblFlight.visible = YES;
            [lblFlight runAction:seq];
            break;
        case kPowerUpLableDoubleJump:
            lblDoubleJump.visible = YES;
            [lblDoubleJump runAction:seq];
            break;
        case kPowerUpLableSpeedBoost:
            lblSpeedBoost.visible = YES;
            [lblSpeedBoost runAction:seq];
            break;
        case kPowerUpLableSpeedBoostExtender:
            lblSpeedBoostExtender.visible = YES;
            [lblSpeedBoostExtender runAction:seq];
            break;
    }
}


-(void) dealloc {
    [super dealloc];
}

-(void) createBackground {
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"Background.png"];
    background.anchorPoint = ccp(0,0);
    background.position = ccp(0, 65);
    [batchNode addChild:background];
    [self addChild:batchNode];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
}

@end
