//
//  GamePlayLayer.h
//  Swinger
//
//  Created by Min Kwon on 3/18/12.
//  Copyright GAMEPEONS, LLC 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "Box2D.h"
#import "GLES-Render.h"
#import "ContactListener.h"
#import "Constants.h"
#import "PhysicsSystem.h"
#import "AudioEngine.h"

@class Player;
@class RopeSwinger;
@class Ground;
@class PhysicsWorld;
@class LevelManager;
@class FinalPlatform;
@class GameObject;
@class GameNode;


typedef enum {
    kScrollModeNone,
    kScrollModeScroll,
    kScrollModeFinish
} ScrollMode;

typedef enum {
    kZoomStateNone,         // 0
    kZoomStateZoomingOut,   // 1
    kZoomStateZoomedOut,    // 2
    kZoomStateZoomingIn,    // 3
    kZoomStateZoomedIn      // 4
} ZoomState;

@interface GamePlayLayer : CCLayer
{
    BOOL isGameOver;
    BOOL paused;
    
	b2World* world;
    
    GameNode *gameNode;
    
    CGSize screenSize;
    
    Player *player;
    ContactLocation catchSide;
        
    Ground *ground;
        
    // scrolling
    ScrollMode scrollMode;
    
#if USE_FIXED_TIME_STEP == 1
    PhysicsSystem *physicsWorld;
#else
    PhysicsWorld *physicsWorld;
#endif
    
    CCNode<GameObject> *_gameObject;
    b2Body *_curBodyNode;
    b2Body *_curBodyBackup;
    
    LevelManager *levelManager;
    
    //XXX move to UserData
    int currentLevel;
    
    NSMutableArray *levelObjects;
    NSMutableArray *collectedObjects;

    FinalPlatform *finalPlatform;
    float          finalPlatformLeftEdge;
    float          finalPlatformRightEdge;
    
    NSMutableArray *toDeleteArray;

    ZoomState   zoomState;
    float       currentZoom;
    
    UIPinchGestureRecognizer *pinch;
    UIPanGestureRecognizer *pan;
    
    UIGestureRecognizerState lastPanState;
    
    // alert player grip is running out
    NSTimer     *gripTimeInvalideTimer;
    
    BOOL        previewShown;
    NSDate      *startTime;
}

// returns a CCScene that contains the GamePlayLayer as the only child
+(CCScene *) scene;


+ (GamePlayLayer*) sharedLayer;

- (Player *) getPlayer;
- (void) addToDeleteList:(CCNode<GameObject>*)node;
- (void) restartGame:(id)loadNextLevel;
- (void) smartZoom;
- (void) zoomInAndCenterOnPlayer;
- (void) collect:(CCNode<GameObject> *)node;
- (void) removeGameNode:(CCNode *)node cleanup:(BOOL)cleanup;
- (void) pauseGame;
- (Ground *) getGround;
- (CCNode *) getNode;
- (void) shake: (float) duration;
- (CCNode *) addTrajectoryPoint: (CGPoint) pos;

@property (nonatomic, readwrite, assign) BOOL isGameOver;
@property (nonatomic, readwrite, assign) ScrollMode scrollMode;
@property (nonatomic, readonly) float finalPlatformLeftEdge;
@property (nonatomic, readonly) float finalPlatformRightEdge;

@end
