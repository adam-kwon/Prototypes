//
//  MainGameScene.m
//  Scroller
//
//  Created by min on 3/9/11.
//  Copyright 2011 L00Kout. All rights reserved.
//

#import "MainGameScene.h"
#import "GamePlayLayer.h"
#import "ParallaxBackgroundLayer.h"
#import "SimpleAudioEngine.h"
#import "StaticBackgroundLayer.h"
#import "UserInterfaceLayer.h"
#import "DeviceDetection.h"

GameOptions gameOptions;

@interface MainGameScene(Private)
- (void) initGameOptions;
@end

@implementation MainGameScene

-(id) init {
	if ((self=[super init])) {
        screenSize = [CCDirector sharedDirector].winSize;
        srandom(time(NULL));
        [self initGameOptions];
        [self loadSpriteAtlas];
        [self addStaticBackgroundLayer];
		[self addParallaxBackgroundLayer];
        [self addGamePlayLayer];
        [self addUiLayer];
	}
	return self;
}

- (void) initGameOptions {
    gameOptions.device = [DeviceDetection detectDevice];
    
    switch (gameOptions.device) {
        case MODEL_IPHONE_SIMULATOR:
        case MODEL_IPAD_SIMULATOR:
        case MODEL_IPOD_TOUCH_GEN2:
        case MODEL_IPOD_TOUCH_GEN3:
        case MODEL_IPHONE_3GS:
        case MODEL_IPHONE_4:
        case MODEL_IPAD:
            gameOptions.profile = kPerformanceHigh;
            break;            
        case MODEL_IPHONE_3G:
        case MODEL_IPOD_TOUCH_GEN1:
        case MODEL_IPHONE:
            gameOptions.profile = kPerformanceLow;
            break;
        default:
            gameOptions.profile = kPerformanceNone;
            break;
    }
}

-(void) dealloc {
	[super dealloc];
}

-(void) onEnterTransitionDidFinish {
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@GAME_MUSIC loop:YES];
}

-(void) loadSpriteAtlas {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"BackgroundAtlas.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"BuildingTileAtlas.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ForegroundPlayerAtlas.plist"];    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ParallaxAtlas.plist"];    
}

-(void) stopRain {
    StaticBackgroundLayer *sbg = (StaticBackgroundLayer*)[self getChildByTag:TAG_STATIC_BG_LAYER];
    [sbg stopRain];
}

-(void) restoreOriginalPosition {
    self.position = ccp(0, 0);
}

-(void) quake {
    id callBack = [CCCallFunc actionWithTarget:self selector:@selector(restoreOriginalPosition)];
    CCSequence *seq = [CCSequence actions:[CCMoveBy actionWithDuration:0.025 position:ccp(0,-5)],
                                          [CCMoveBy actionWithDuration:0.025 position:ccp(0,5.2)], 
                                          [CCMoveBy actionWithDuration:0.025 position:ccp(-5,0)],
                                          [CCMoveBy actionWithDuration:0.025 position:ccp(5.2,0)],nil];
    id repeat = [CCRepeat actionWithAction:seq times:20];
    CCSequence *seq2 = [CCSequence actions:repeat, callBack, nil];
    [self runAction:seq2];
}

-(void) addStaticBackgroundLayer {
    [self addChild:[StaticBackgroundLayer node] z:-10 tag:TAG_STATIC_BG_LAYER];
}

-(void) addParallaxBackgroundLayer {
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
    parallaxBackground = [ParallaxBackgroundLayer node];
    [self addChild:parallaxBackground z:-8];
}

-(void) addGamePlayLayer {
    [self addChild:[GamePlayLayer node]];
}

-(void) addUiLayer {
    uiLayer = [UserInterfaceLayer node];
	[self addChild:uiLayer z:2];
}

-(UserInterfaceLayer*) uiLayer {
    return uiLayer;
}

-(ParallaxBackgroundLayer*) parallaxBackground {
    return parallaxBackground;
}

@end
