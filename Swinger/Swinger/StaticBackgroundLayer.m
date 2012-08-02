//
//  StaticBackgroundLayer.m
//  Swinger
//
//  Created by James Sandoz on 4/23/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "StaticBackgroundLayer.h"
#import "MainGameScene.h"
#import "TextureTypes.h"
#import "Constants.h"
#import "GPUtil.h"
#import "StarsFirework.h"
#import "AudioEngine.h"
#import "Macros.h"

@interface StaticBackgroundLayer(Private) 
- (void) createBackground;
@end

@implementation StaticBackgroundLayer

static StaticBackgroundLayer* instanceOfLayer;

+ (StaticBackgroundLayer*) sharedLayer {
	NSAssert(instanceOfLayer != nil, @"StaticBackgroundLayer instance not yet initialized!");
	return instanceOfLayer;
}

- (id) init {
    
    if ((self = [super init])) {
        instanceOfLayer = self;
        screenSize = [[CCDirector sharedDirector] winSize];        
        [self initLayer];
    }
    
    return self;
}

- (void) initLayer {
    
    [self setIsTouchEnabled:NO];
    [self createBackground];    
}

- (void) createBackground {
    
    NSString * prefix = @"L1a";
    
    if ([[[MainGameScene sharedScene] world] isEqualToString: WORLD_FOREST_RETREAT]) {
        prefix = @"L2a";
    }
    
    background = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@_Background.png", prefix]];
    
    background.scaleX = ssipad(screenSize.width/960.f, 1.0);
    background.scaleY = ssipad(screenSize.height/640.f, 1.0);
    background.position = ccp(screenSize.width/2, screenSize.height/2);
    
    
    [self addChild: background z: 0];
}



- (void) cleanupLayer {
    [self stopAllActions];
    [self unscheduleAllSelectors];  
    
    [background removeAllChildrenWithCleanup:YES];  
    [self removeChild:background cleanup:YES];
    
    
    batchNode = nil;
    background = nil;
}

- (void) dealloc {
    CCLOG(@"----------------------------- StaticBackgroundLayer dealloc");
    [self cleanupLayer];
    [super dealloc];
}

@end
