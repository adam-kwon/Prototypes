//
//  GamePlayLayer.h
//  Scroller
//
//  Created by min on 1/16/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import "Box2D.h"
#import "GLES-Render.h"
#import "ContactListener.h"
#import "Constants.h"
#import "Building.h"

#if USE_FIXED_TIMESTEP
#import "PhysicsSystem.h"
#endif

typedef enum {
    kMeteorShowerQueueNone,
    kMeteorShowerQueueQueued,
    kMeteorShowerQueueQueuedSendKillerMeteor,
    kMeteorShowerQueueCleared
} MeteorShowerQueueState;

@class Runner;
@class Meteor;
@class PowerUp;
@class Crow;
@class MainGameScene;

@interface GamePlayLayer : CCLayer {
	CGSize                  screenSize;
	GLESDebugDraw           *m_debugDraw;

	b2World                 *world;         // weak reference        
	ContactListener         *contactListener;

#if USE_FIXED_TIMESTEP
    PhysicsSystem *physics; // manages the fixed timestep implementation
#endif
    
#ifndef USE_RANDOM_BUILDINGS
	// Used to clean up bodies that are no longer visible
	NSMutableDictionary     *tileMapToBodies;    
	CCTMXTiledMap           *currentTileMapNode;
	CCTMXTiledMap           *oldTileMapNode;
	int                     oldTileRightEdge;
	int                     currentTileRightEdge;
#endif

	Runner                  *player;
	CCParticleSystem        *system;
    
    
    BOOL                    gameOver;
    BOOL                    calledDisplayGameOver;
    BOOL                    preCleanup;
    
    Building                *previousBuilding;
    Building                *currentBuilding;
    Building                *landingBuilding;

    Meteor                  *meteor;
    
    CCArray                 *buildingsGroupedByHeight[BUILDING_MAX_HEIGHT_TILES-1];
    
    CCSpriteBatchNode       *mainBatchNode;
    
    char                    buildingsSinceLastSpeedBoostX2;
    char                    buildingsSinceLastSpeedBoostX1;
    char                    buildingsSinceLastDoubleJump;
    char                    buildingsSinceLastSpeedExtender;
    char                    buildingsSinceLastFlight;
    
//    b2Joint                 *lastBridgeStartJoint;
//    b2Joint                 *lastBridgeEndJoint;
    
    float                   leadout_offset;
    CCSprite                *top;       // letter box top
    CCSprite                *bottom;    // letter box bottom
    float                   letterBoxIncrement;
    BOOL                    letterBoxShowing;
    BOOL                    startLiftingLetterbox;

    MeteorShowerQueueState  meteorShowerQueued;
    BOOL                    killerMeteorQueued;
    
    CGPoint                 touchStart;
    
    // Variables that are used used over and over again (in update), so may as well be here
    GameObject              *_gameObject;
    Meteor                  *_meteor;
    PowerUp                 *_powerup;
    Crow                    *_crow;
    float                   _zFactor;
    float                   _oldScale;
    float                   _newScale;
    float                   _dScale;
    float                   _zRate;
    MainGameScene           *_mgs;
    CCSpriteBatchNode       *_parallaxBatchNode;
}

+(GamePlayLayer*) sharedLayer;
-(Runner*) runner;
-(CCParticleSystem*) system;
-(void) setupPhysicsWorld;
-(void) sendMeteorShower;
- (void) queueMeteor;

//@property (nonatomic, readwrite, assign) BOOL meteorShowerQueued;
@property (nonatomic, readwrite, assign) BOOL killerMeteorQueued;
@property (nonatomic, readwrite, assign) Meteor *meteor;
@property (nonatomic, readwrite, assign) BOOL gameOver;
@property (nonatomic, readonly) CGSize screenSize;
@end
