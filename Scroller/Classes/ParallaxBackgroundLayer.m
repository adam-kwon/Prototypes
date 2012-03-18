//
//  ParallaxBackgroundLayer.m
//  Scroller
//
//  Created by min on 3/10/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import "ParallaxBackgroundLayer.h"
#import "Constants.h"
#import "BackgroundMeteor.h"
#import "GameOptions.h"

extern GameOptions gameOptions;
/*
 * The sprites that make the up parallax layer is pregenerated and their visible property is set to NO so that it is not rendered on screen.
 * Because CCSpriteBatchNode ignores the visible property of its children, it cannot be used. So the sprites are added into a CCNode which 
 * as the container (for zooming purposes). The objects are then scrolled to the left of the screen at a certain rate. Only the sprites that
 * are within the screen's width is set to visible, and the rest are ignored. As the sprite scrolls from right to left and falls off the
 * screen, this sprite's visible property is set to NO and it is repositioned next to the right most sprite for reuse.
 */
@interface ParallaxBackgroundLayer(Private)
- (void) setVisibleBuildings;
#ifdef DEBUG
- (int) numVisibleBuildingsOnBackParallax;
- (int) numVisibleBuildingsOnFrontParallax;
#endif
@end

@implementation ParallaxBackgroundLayer

@synthesize parallaxSpeed;

const int frontParallax_minGapBetweenBldgs = 25;
const int frontParallax_maxRandGapBetweenBldgs = 250;
const int backParallax_minGapBetweenBldgs = 10;
const int backParallax_maxRandGapBetweenBldgs = 5;

static BOOL veryFirstTime = YES;
static ParallaxBackgroundLayer *instanceOfLayer;

+ (ParallaxBackgroundLayer*) sharedLayer {
	NSAssert(instanceOfLayer != nil, @"StaticBackgroundLayer instance not yet initialized!");
	return instanceOfLayer;
}

-(id) init {
    if ((self = [super init])) {
        [self setIsTouchEnabled:NO];
        
        instanceOfLayer = self;
        
        originalScreenSize  = [[CCDirector sharedDirector] winSize];
        
        
        meteors = [[CCArray alloc] initWithCapacity:NUM_BACKGROUND_METEORS*2];
        [self initIntroMeteorSystem];
        
        // Container to hold the parallax sprites. Used for zooming purposes.
        backParallax = [CCNode node];
        frontParallax = [CCNode node];
        [self addChild:backParallax z:0];
        [self addChild:frontParallax z:2];

        
        srand(time(NULL));
        
        // Generate the buidings for the back parallax layer
        for (int i = 0, j = 1; i < NUM_BACK_BLDGS_TO_GEN; i++, j++) {
            if (j > NUM_BACK_PARALLAX_BLDGS) {
                j = 1;
            }
            NSString *file = [NSString stringWithFormat:@"Building-B-%d.png", j];
            backLayerBldgs[i] = [CCSprite spriteWithSpriteFrameName:file];
            backLayerBldgs[i].anchorPoint = ccp(0, 0);
            float xOffSet = 0;
            if (i > 0) {
                xOffSet += (backLayerBldgs[i-1].position.x 
                            + [backLayerBldgs[i-1] boundingBox].size.width 
                            + (backParallax_minGapBetweenBldgs + rand() % backParallax_maxRandGapBetweenBldgs));
            }
#if ZOOM_BACKMOST_PARALLAX
            backLayerBldgs[i].position = ccp(xOffSet, 0);
#else
            backLayerBldgs[i].position = ccp(xOffSet, 0);
#endif
            backLayerBldgs[i].visible = NO;
            [backParallax addChild:backLayerBldgs[i]];
        }
        // Save the position of the last building generated in the back parallax layer
        backLayerLastBldgIdx = NUM_BACK_BLDGS_TO_GEN - 1;


        // Generate the buildings for the front parallax layer
        for (int i = 0, j = 1; i < NUM_FRONT_BLDGS_TO_GEN; i++, j++) {
            if (j > NUM_FRONT_PARALLAX_BLDGS) {
                j = 1;
            }
            NSString *file = [NSString stringWithFormat:@"Building%d.png", j];
            frontLayerBldgs[i] = [CCSprite spriteWithSpriteFrameName:file];
            frontLayerBldgs[i].anchorPoint = ccp(0, 0);
            float xOffSet = 0;
            if (i > 0) {
                xOffSet += (frontLayerBldgs[i-1].position.x 
                            + [frontLayerBldgs[i-1] boundingBox].size.width 
                            + (frontParallax_minGapBetweenBldgs + rand() % frontParallax_maxRandGapBetweenBldgs));
            }
            frontLayerBldgs[i].position = ccp(xOffSet, 0);
            frontLayerBldgs[i].visible = NO;
            [frontParallax addChild:frontLayerBldgs[i]];
        }
        frontLayerLastBldgIdx = NUM_FRONT_BLDGS_TO_GEN - 1;
        
        parallaxSpeed = 1.0;
        
        [self setZoom:MAX_ZOOM_OUT];
        
        scaledScreenWidth = originalScreenSize.width / frontParallax.scale;
        
        [self setVisibleBuildings];
        
        // No need to go at full 1/60 cycle.
//        [self schedule:@selector(update:) interval:1.0f/24];
        [self scheduleUpdate];
    }
    
    return self;
}

#ifdef DEBUG
- (int) numVisibleBuildingsOnFrontParallax {
    int c = 0;
    CCSprite *sprite;
    CCARRAY_FOREACH([frontParallax children], sprite) {
        if (sprite.visible) {
            c++;
        }
    }
    return c;
}

- (int) numVisibleBuildingsOnBackParallax {
    int c = 0;
    CCSprite *sprite;
    CCARRAY_FOREACH([backParallax children], sprite) {
        if (sprite.visible) {
            c++;
        }
    }
    return c;
}

#endif

-(void) setZoom:(float)zoom {
    frontParallax.scale = zoom;
#if ZOOM_BACKMOST_PARALLAX
    backParallax.scale = zoom;
#endif
}

-(void) dealloc {
    [meteors removeAllObjects];
    [meteors release];

    [super dealloc];
}

/*
 * Set buildings that are within the screen's clipping range visible, otherwise deactivate them
 */
-(void) setVisibleBuildings {    
	CCSprite *sprite;
    
    // Prune buildings in the back parallax
    CCARRAY_FOREACH([backParallax children], sprite) {
        float leftEdge = sprite.position.x;
        float rightEdge = leftEdge + [sprite boundingBox].size.width;
#if ZOOM_BACKMOST_PARALLAX
        // If zoom is enabled, then must compare to the scaled screen width
        if ((rightEdge >= 0.0 && rightEdge < scaledScreenWidth) || (leftEdge < scaledScreenWidth && leftEdge > 0.0)) {
#else
        // If zoom is disabled, then just compare to unscaled screen width
        if ((rightEdge >= 0.0 && rightEdge < originalScreenSize.width) || (leftEdge < originalScreenSize.width && leftEdge > 0.0)) {
#endif
            [sprite setVisible:YES];
        } else {
            [sprite setVisible:NO];
        }
    }

    // Prune buildings in the front parallax
	CCARRAY_FOREACH([frontParallax children], sprite) {
        float leftEdge = sprite.position.x;
        float rightEdge = leftEdge + [sprite boundingBox].size.width;
        if ((rightEdge >= 0.0 && rightEdge < scaledScreenWidth) || (leftEdge < scaledScreenWidth && leftEdge > 0.0)) {
            [sprite setVisible:YES];
//            CCLOG(@"---------------------------->YES BLDG[%d] (%f  >= 0.0 &&  %f < %f) || (%f < %f && %f > 0.0)",  
//                  i++,(rightEdge), rightEdge, scaledScreenWidth,
//                  leftEdge, scaledScreenWidth, leftEdge);
        } else {
            [sprite setVisible:NO];
//            CCLOG(@"---------------------------->NO  BLDG[%d] (%f  >= 0.0 &&  %f < %f) || (%f < %f && %f > 0.0)",  
//                  i,(rightEdge), rightEdge, scaledScreenWidth,
//                  leftEdge, scaledScreenWidth, leftEdge);
//            CCLOG(@"---------------------------->NO  BLDG[%d] %f < 0 || %f > %f",  i++, rightEdge, leftEdge, scaledScreenWidth);
        }
    }
}

-(void) update:(ccTime)delta {
    scaledScreenWidth = originalScreenSize.width / frontParallax.scale;
    

    int         idx = 0;
    BOOL        found = NO;
    CCSprite    *sprite;

    // Scroll the back parallax
    CCARRAY_FOREACH([backParallax children], sprite) {
        CGPoint pos = sprite.position;
 
        // Scroll from right to left in 0.5 pixel increment
        pos.x -= 0.5;
        float bldgWidth = [sprite boundingBox].size.width;
        float rightEdge = pos.x + bldgWidth;
        if (rightEdge < 0.0) {
            sprite.visible = NO;
            found = YES;
            break;
        } else {
            sprite.position = pos;
        }
        idx++;
	}
    if (found) {
        sprite.position = ccp(backLayerBldgs[backLayerLastBldgIdx].position.x
                              + [backLayerBldgs[backLayerLastBldgIdx] boundingBox].size.width
                              + backParallax_minGapBetweenBldgs + rand() % backParallax_maxRandGapBetweenBldgs, 0);
        backLayerLastBldgIdx = idx;
    }
//    CCLOG(@"+++++++++++++++++++++++++++++++++> nuMVisible back = %d", [self numVisibleBuildingsOnBackParallax]);
    
    
    found = NO;
    idx = 0;
    // Scroll the front parallax (scroll speed affected by player's speed)
	CCARRAY_FOREACH([frontParallax children], sprite) {
        CGPoint pos = sprite.position;

        // Scroll from right to left in 1 pixel increment
        pos.x -= parallaxSpeed;
        float bldgWidth = [sprite boundingBox].size.width;
        float rightEdge = pos.x + bldgWidth;
        if (rightEdge < 0.0) {
            sprite.visible = NO;
            found = YES;
            break;
        } else {
            sprite.position = pos;
        }
        idx++;
	}
    if (found) {
        sprite.position = ccp(frontLayerBldgs[frontLayerLastBldgIdx].position.x
                              + [frontLayerBldgs[frontLayerLastBldgIdx] boundingBox].size.width
                              + frontParallax_minGapBetweenBldgs + rand() % frontParallax_maxRandGapBetweenBldgs, 0);
        frontLayerLastBldgIdx = idx;
    }
//     CCLOG(@"----------------------------------> nuMVisible front = %d", [self numVisibleBuildingsOnFrontParallax]);    
    
    [self setVisibleBuildings];

}

    
- (void) initMeteorSystem {
    CCLOG(@"**** Initializing meteor system");
    NSAssert([meteors count] > NUM_BACKGROUND_METEORS, @"Intro system has more, so resizing. Make sure it had more.");    
    BackgroundMeteor *meteor;
    
    int last = [meteors count] - 1;
    for (int i = 0; i < NUM_BACKGROUND_METEORS; i++) {
        [self removeChild:[meteors objectAtIndex:last] cleanup:YES];
        [meteors removeObjectAtIndex:last--];
    }
    
    CCLOG(@"*** Removed meteors form system, remaining meteors = %d", [meteors count]);
    
    int i = 0;
    // Remove all meteors from intro scene
    CCARRAY_FOREACH(meteors, meteor) {
        [meteor setVisible:NO];
        [meteor generateSizeAndScale];
        meteor.position = ccp(300+(i++)*40+(rand()%50), 320+(20+rand()%200));
    }
}

- (void) initIntroMeteorSystem {
    CCLOG(@"**** Initializing intro meteor system");
    BackgroundMeteor *meteor;
    int multiplier = (gameOptions.profile == kPerformanceHigh ? 2 : 1);
    for (int i = 0; i < NUM_BACKGROUND_METEORS*multiplier; i++) {        
        meteor = [BackgroundMeteor particleWithFile:@"rain.plist" minFallRate:2.5f];
        [self addChild:meteor z:1];
        if (gameOptions.profile == kPerformanceHigh) {
            meteor.position = ccp(200+i*20+(rand()%50), 320+(20+rand()%200));
        } else if (gameOptions.profile == kPerformanceLow) {
            meteor.position = ccp(300+i*40+(rand()%50), 320+(20+rand()%200));            
        }
        [meteor setVisible:NO];
        [meteors addObject:meteor];
    }
}    

- (BOOL) areAllMeteorsOffScreen {
    BackgroundMeteor *meteor;
    CCARRAY_FOREACH(meteors, meteor) {
        if (meteor.visible == YES) {
            return NO;
        }
    }
    return YES;
}

- (void) updateMeteorSystem {
    BackgroundMeteor *meteor;
    BOOL allStopped = YES;
    
    CCARRAY_FOREACH(meteors, meteor) {
        if (meteor.visible == YES) {
            allStopped = NO;
            meteor.position = ccp(meteor.position.x - meteor.fallRate, meteor.position.y - meteor.fallRate);
            if (meteor.position.y < 0) {
                [meteor stopSystem];
                meteor.visible = NO;
            }
        }
    }
    
    
    if (allStopped) {
        CCLOG(@"**** Unscheduling meteor");
        if (veryFirstTime) {
            veryFirstTime = NO;
            CCLOG(@"**** Ending meteor system for firs titme, must have been intro, reinit system");
            [self initMeteorSystem];            
        }
        [self unschedule:@selector(updateMeteorSystem)];
    }
}

- (void) startMeteorSystemIsForIntro:(BOOL)isIntro {
    BackgroundMeteor *meteor;
    int i = 0;
    CCARRAY_FOREACH(meteors, meteor) {
        if (isIntro) {
            if (gameOptions.profile == kPerformanceHigh) {
                meteor.position = ccp(200+(i++)*20+(rand()%50), 320+(20+rand()%200));
            } else if (gameOptions.profile == kPerformanceLow) {
                meteor.position = ccp(300+(i++)*40+(rand()%50), 320+(20+rand()%200));            
            }
        } else {
            meteor.position = ccp(300+(i++)*40+(rand()%50), 320+(20+rand()%200));            
        }
        [meteor generateSizeAndScale];
        [meteor setVisible:YES];
        [meteor resetSystem];
    }
    
    [self schedule:@selector(updateMeteorSystem) interval:1/15];
}
@end
