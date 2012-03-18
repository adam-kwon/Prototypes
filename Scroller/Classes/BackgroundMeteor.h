//
//  MeteorSystem.h
//  Scroller
//
//  Created by min on 3/24/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

typedef enum {
    kBackgroundMeteorStateNone,
    kBackgroundMeteorStateAtInitialPosition,
    kBackgroundMeteorStateFalling,
    kBackgroundMeteorStateAtFinalPosition
} BackgroundMeteorState;


@interface BackgroundMeteor : ARCH_OPTIMAL_PARTICLE_SYSTEM {
    BackgroundMeteorState   gameState;
    float                   fallRate;
    float                   minFallRate;
}

+ (id) particleWithFile:(NSString*)plistFile minFallRate:(float)rate;
- (id) initWithFile:(NSString *)plistFile minFallRate:(float)rate;
- (void) generateSizeAndScale;

@property (nonatomic, readwrite) float fallRate;
@property (nonatomic, readwrite) float minFallRate;

@end
