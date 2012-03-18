//
//  ParallaxBackgroundLayer.h
//  Scroller
//
//  Created by min on 3/10/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import "Constants.h"

#define NUM_BACK_PARALLAX_BLDGS         12
#define NUM_FRONT_PARALLAX_BLDGS        4
#define NUM_FRONT_BLDGS_TO_GEN          8
#if ZOOM_BACKMOST_PARALLAX
    #define NUM_BACK_BLDGS_TO_GEN       20
#else
    // If back building is not zoomed, better performance can be achieved if the width of the sprite does not exceed screen width
    #define NUM_BACK_BLDGS_TO_GEN       2
#endif

#define NUM_BACKGROUND_METEORS 10

@interface ParallaxBackgroundLayer : CCLayer { 
    float      parallaxSpeed;                               // Speed at which the parallax layers scroll (set from main game loop)
    CGSize     originalScreenSize;                          // Original screen size before being scaled
    CCSprite   *frontLayerBldgs[NUM_FRONT_BLDGS_TO_GEN];    // Buildings in the front parallax layer 
    CCSprite   *backLayerBldgs[NUM_BACK_BLDGS_TO_GEN];      // Buildings in the back parallax layer
    CCNode     *backParallax;                               // CCNode that holds all buildings in the front parallax layer (used as container for zoom purposes)
    CCNode     *frontParallax;                              // CCNode that holds all buildings in the back parallax layer (used as container for zoom purposes) 
    int        frontLayerLastBldgIdx;                       // Index tot he last building in the front parallax layer
    int        backLayerLastBldgIdx;                        // Index to the last building in the back parallax layer
    float      scaledScreenWidth;
    
    CCArray                 *meteors;
}

- (void) update:(ccTime) delta;
- (void) setZoom:(float)zoom;

+ (ParallaxBackgroundLayer*) sharedLayer;
- (void) initIntroMeteorSystem;
- (void) initMeteorSystem;
- (void) startMeteorSystemIsForIntro:(BOOL)isIntro;
- (BOOL) areAllMeteorsOffScreen;

@property (nonatomic, readwrite, assign) float parallaxSpeed;

@end
