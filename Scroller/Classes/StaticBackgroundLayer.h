//
//  StaticBackgroundLayer.h
//  Scroller
//
//  Created by Yongrim Rhee on 3/13/11.
//  Copyright 2011 L00Kout LLC. All rights reserved.
//

#import "SimpleAudioEngine.h"
#import "BackgroundMeteor.h"

#define NUM_BACKGROUND_METEORS 10

typedef enum {
    kPowerUpLableSpeedBoost,
    kPowerUpLableSpeedBoostExtender,
    kPowerUpLableDoubleJump,
    kPowerUpLableFlight
} PowerUpLableKind;

@interface StaticBackgroundLayer : CCLayer {
    ALuint                  rainSound;
    CCLabelTTF              *lblSpeedBoost;
    CCLabelTTF              *lblDoubleJump;
    CCLabelTTF              *lblFlight;
    CCLabelTTF              *lblSpeedBoostExtender;
    PowerUpLableKind        powerUpLabelKind;
    CCSprite                *flightBar;
    CCSpriteBatchNode       *batchNode;
}

+ (StaticBackgroundLayer*) sharedLayer;
- (void) createBackground;
- (void) growFlightBar;
- (void) shrinkFlightBar;
- (void) pauseRain;
- (void) stopRain;
- (void) displayPowerUpLabel:(PowerUpLableKind)lblType;
- (float) remainingFuel;
@end
