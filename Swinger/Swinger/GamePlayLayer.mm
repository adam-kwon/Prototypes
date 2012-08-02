//
//  GamePlayLayer.mm
//  Swinger
//
//  Created by Min Kwon on 3/18/12.
//  Copyright GAMEPEONS, LLC 2012. All rights reserved.
//


// Import the interfaces
#import "GamePlayLayer.h"
#import "AudioEngine.h"
#import "AudioManager.h"
#import "GameObject.h"
#import "Constants.h"
#import "Player.h"
#import "RopeSwinger.h"
#import "Ground.h"
#import "PhysicsWorld.h"
#import "LevelManager.h"
#import "LevelItem.h"
#import "ParallaxBackgroundLayer.h"
#import "StaticBackgroundLayer.h"
#import "HUDLayer.h"
#import "TouchCloudLayer.h"
#import "FinalPlatform.h"
#import "Cannon.h"
#import "Spring.h"
#import "GameNode.h"
#import "Macros.h"
#import "Notifications.h"
#import "SkyLayer.h"
#import "GPDialog.h"
#import "DummyCatcherObject.h"
#import "Star.h"
#import "Coin.h"
#import "TextureTypes.h"
#import "Elephant.h"
#import "Wheel.h"
#import "FloatingPlatform.h"
#import "StrongMan.h"
#import "UserData.h"
#import "MainGameScene.h"
#import "FireRing.h"
#import "TrajectoryPoint.h"

#define SPECIAL_TAG     9271977
#define TRAJECTORY_TAG  9271978

static const float maxZoom = 1.0f;
static float minPinchZoom = 0.25f;
static const float verticalZoomScrollThreshold = 0.4f;
static const int   maxStrongMen = 2;

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};


@interface GamePlayLayer(Private)
- (void) initGame;
- (void) cleanupGameObjects;
- (void) cleanupGameAndLoadNextLevel:(BOOL)loadNextLevel;
- (void) gameOver;
- (void) loadLevel:(int)level;
- (void) levelComplete;
- (void) handleScreenScroll:(ccTime)dt;
- (void) onPinch:(UIPinchGestureRecognizer*)pinch;
- (void) handlePanFrom:(UIPanGestureRecognizer *)recognizer;
- (void) adjustZoomBasedOnHeight:(ccTime)dt;
- (void) finishedLevel:(NSNotification *)notification;
- (void) handleZoomInAndCenterOnPlayer:(float)dt;
@end


// GamePlayLayer implementation
@implementation GamePlayLayer
@synthesize isGameOver;
@synthesize scrollMode;
@synthesize finalPlatformLeftEdge;
@synthesize finalPlatformRightEdge;

static GamePlayLayer* instanceOfGamePlayLayer;

#pragma mark - Initialization
+(GamePlayLayer*) sharedLayer {
	NSAssert(instanceOfGamePlayLayer != nil, @"GamePlayLayer instance not yet initialized!");
	return instanceOfGamePlayLayer;
}


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GamePlayLayer *layer = [GamePlayLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// enable touches
		self.isTouchEnabled = YES;
        
		// enable accelerometer
		self.isAccelerometerEnabled = NO;
        
        self.anchorPoint = CGPointZero;
        
        gameNode = [GameNode node];
        gameNode.tag = SPECIAL_TAG;
        [self addChild:gameNode];

        instanceOfGamePlayLayer = self;
		
        toDeleteArray = [[NSMutableArray alloc] init];

		screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
        
        // Register a pinch gesture recognizer for pinch zooming
        pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
        [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:pinch];
        
        pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
        [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:pan];
        pan.minimumNumberOfTouches = 2; //number of fingers
        
        //UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)] autorelease];
        //[[[CCDirector sharedDirector] openGLView] addGestureRecognizer:tap];
        
        //UISwipeGestureRecognizer *swipe = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)] autorelease];
        //[[[CCDirector sharedDirector] openGLView] addGestureRecognizer:swipe];
        
        // Instantiate and create the physics world
#if USE_FIXED_TIME_STEP
        physicsWorld = PhysicsSystem::Instance();
        world = physicsWorld->getWorld();        
#else
        [PhysicsWorld createInstance];
        physicsWorld = [PhysicsWorld sharedWorld];
        world = [physicsWorld getWorld];
#endif                
        // Create the ground
        ground = [[Ground alloc] initWithParent:self];
        [ground createPhysicsObject:world];
        
        // Create the player
        player = [[Player alloc] initWithHeadSkin:[UserData sharedInstance].headSkin 
                                         bodySkin:[UserData sharedInstance].bodySkin];
        [player createPhysicsObject:world];
        [gameNode addChild:player z:10];
        player.visible = NO;

        // LevelManager
        levelManager = [[LevelManager alloc] init];
        levelObjects = [NSMutableArray array];
        [levelObjects retain];
        currentLevel = [MainGameScene sharedScene].level;
        [self loadLevel:currentLevel];
        
        collectedObjects = [NSMutableArray array];
        [collectedObjects retain];

        // Register for notification
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(finishedLevel:) 
                                                     name:NOTIFICATION_FINISHED_LEVEL 
                                                   object:nil];
        
        // Register for notification
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(playerCaught:) 
                                                     name:NOTIFICATION_PLAYER_CAUGHT 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(timeOutGripTimeOut:) 
                                                     name:NOTIFICATION_GAME_OVER 
                                                   object:nil];
        
        /*[[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(timeRunningOut) 
                                                     name:NOTIFICATION_TIME_RUNNING_OUT 
                                                   object:nil];*/
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(noObjectCollisions:) 
                                                     name:NOTIFICATION_PLAYER_FALLING 
                                                   object:nil];

        [self initGame];
	}
	return self;
}

- (void) previewStage {
    self.isTouchEnabled = NO;
    float minZoom = MAX(minPinchZoom, 0.2f);
    //float zoomDuration = 1.f;
    float panDistance = -1*(finalPlatformRightEdge + ssipadauto(50) - screenSize.width/minZoom)*minZoom;
    
    CCCallFunc  * zoomOut = [CCCallFunc actionWithTarget:self selector:@selector(zoomOut)];
    //CCDelayTime * waitForZoom = [CCDelayTime actionWithDuration:2*zoomDuration];
    CCMoveTo    * panOver = [CCMoveTo actionWithDuration:5.f position:ccp(panDistance, 0)];
    //CCDelayTime * wait = [CCDelayTime actionWithDuration:0.5f];
    CCMoveBy    * jerkForward = [CCMoveBy actionWithDuration:0.2f position:ccp(ssipadauto(-5)/minZoom,0)];
    
    CCMoveTo  * backToStart = [CCMoveTo actionWithDuration:0.1f position:ccp(0,0)];
    CCCallFunc  * zoomIn = [CCCallFunc actionWithTarget:self selector:@selector(zoomBackToStart)];
    CCDelayTime * shortWait = [CCDelayTime actionWithDuration:0.2f];
    //CCScaleTo   * zoomIn = [CCScaleTo actionWithDuration:0.3f scale:maxZoom];
    //CCSpawn   * spawn = [CCSpawn actions:backToStart, zoomIn, nil];
    
    CCSequence * seq = [CCSequence actions: zoomOut, shortWait, panOver, /*shortWait,*/ jerkForward, shortWait, backToStart, zoomIn,/*spawn,*/ nil];

    //[self scaleTo:minZoom duration:zoomDuration];
    [self runAction: seq];
}

- (void) zoomOut {
    float minZoom = MAX(minPinchZoom, 0.2f);
    [self scaleTo: minZoom duration:0.0f];
}

- (void) scaleTo: (float) newScale duration: (float) duration {
    CCScaleTo * scaleChange = [CCScaleTo actionWithDuration:duration scale:newScale];
    [self runAction: scaleChange];
    
    [[ParallaxBackgroundLayer sharedLayer] scaleBy: (self.scale-newScale) duration: duration];
    [[SkyLayer sharedLayer] scaleBy: (self.scale-newScale) duration: duration];
}

- (void) zoomBackToStart {
    
    float duration = 0.3f;
    
    //[self scaleTo:1.f duration:duration];
    
    CCDelayTime * wait = [CCDelayTime actionWithDuration: duration];
    CCCallFunc * smartZoom = [CCCallFunc actionWithTarget:self selector:@selector(smartZoom)];
    CCCallFunc * startGame = [CCCallFunc actionWithTarget:self selector:@selector(startGame)];
    
    [self runAction: [CCSequence actions: wait, smartZoom, startGame, nil]];
}

- (void) initGame {
    
    CCLOG(@"===   initGame   ===\n");
    
    isGameOver = NO;
    paused = NO;
    finalPlatform = nil;
    scrollMode = kScrollModeNone;
    self.scale = 1.f;
    currentZoom = self.scale;

    [[AudioEngine sharedEngine] stopBackgroundMusic];
    [[AudioEngine sharedEngine] setBackgroundMusicVolume:1.0];
    [[AudioEngine sharedEngine] playBackgroundMusic:GAME_MUSIC loop:YES];
    
    // Initialize background layer
    [[ParallaxBackgroundLayer sharedLayer] initLayer];
    
    /*if (finalPlatformRightEdge > screenSize.width && !previewShown) {
        [self previewStage];
        previewShown = YES;
    } else {*/
        //[self scheduleUpdate];
        [self startGame];
    //}
}

- (void) startGame {
    // reset the score counters in HUDLayer
    //[[HUDLayer sharedLayer] resetScores];
    
    // XXXX - For testing magnetGrip
    /*for(GameObject *obj in levelObjects) {
     if([obj gameObjectType] == kGameObjectCatcher) {
     [(RopeSwinger *) obj createMagneticGrip: 100];
     }
     }*/
    
    // skip over any initial dummy objects
    int firstCatcherIndex = 0;
    CCNode<GameObject, PhysicsObject, CatcherGameObject> *catcher = [levelObjects objectAtIndex:firstCatcherIndex];
    while ([catcher gameObjectType] == kGameObjectDummy) {
        catcher = [levelObjects objectAtIndex:++firstCatcherIndex];
    }
    
    // randomly initialize strong men
    CCNode *node;
    for (int i = [[gameNode children] count]-1; i >= 0; i--) {
        node = [[gameNode children] objectAtIndex:i];
        if ([node conformsToProtocol:@protocol(GameObject)]) {
            CCNode<GameObject, PhysicsObject> *go = (CCNode<GameObject, PhysicsObject>*)node;
            switch ([go gameObjectType]) {
                case kGameObjectStrongMan: {
                    StrongMan * sm = (StrongMan*) go;
                    
                    float rand = arc4random() % 100;
                    
                    if (rand <= 100) {
                        // randomly chose the strong men to run across screen
                        [sm begin];
                    } else {
                        [sm reset];
                    }
                    break;
                }
                default:
                    break;
            }
        }
    }
    
    //[player initPlayer: catcher];
    [player initPlayer: nil];
    [player processContactWithCatcher:catcher];
    //[[catcher getNextCatcherGameObject] setCollideWithPlayer:YES];
    [self allowObjectCollisions]; // allow everything in the level to catch the player
    // send game started notification
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GAME_STARTED object:catcher];
    startTime = [[NSDate alloc] init];
    self.isTouchEnabled = YES;
    [self scheduleUpdate];
    [self smartZoom];
}

- (void) shake: (float) duration {
    // shake the screen
    [[MainGameScene sharedScene] shake: ssipadauto(2.5) duration: duration];
}


#pragma mark - Overridden methods

- (void) addChild:(CCNode *)node {
    if (node.tag != SPECIAL_TAG) {
        [gameNode addChild:node];
    } else {
        [super addChild:node];
    }
}

- (void) addChild:(CCNode *)node z:(NSInteger)z {
    if (node.tag != SPECIAL_TAG) {
        [gameNode addChild:node z:z];
    } else {
        [super addChild:node z:z];
    }
}

- (void) addChild:(CCNode *)node z:(NSInteger)z tag:(NSInteger)tag {
    if (node.tag != SPECIAL_TAG) {
        [gameNode addChild:node z:z tag:tag];
    } else {
        [super addChild:node z:z tag:tag];
    }
}

#pragma mark - Main game loop

- (void) update:(ccTime)dt {
    if (isGameOver) {
        [self handleScreenScroll:dt];
        return;
    }
    
#if USE_FIXED_TIME_STEP == 1
    physicsWorld->update(dt);
#else
    [physicsWorld step:dt];
#endif
    
    [player updateObject:dt scale:self.scale];
    
    if (player.state == kSwingerDead) {
        [self gameOver];
        return;
    }
    
    [self adjustZoomBasedOnHeight:dt];
    
    [self handleScreenScroll:dt];
    
    //Iterate over the bodies in the physics world
    _curBodyNode = world->GetBodyList();
    while (_curBodyNode) {
        _curBodyBackup = _curBodyNode;
        _curBodyNode = _curBodyNode->GetNext();
		_gameObject = (CCNode<GameObject>*)_curBodyBackup->GetUserData();
		if (_gameObject != NULL) {
            //if ([_gameObject conformsToProtocol:@protocol(GameObject)]) {
            //    CCLOG(@"-------------------------------------------------------------------------------> %d", [_gameObject gameObjectType]);
            //}
            switch ([_gameObject gameObjectType]) {
                case kGameObjectCatcher:
                case kGameObjectWind:
                case kGameObjectCannon:
                case kGameObjectSpring:
                case kGameObjectWheel:
                case kGameObjectElephant:
                case kGameObjectFloatingPlatform:
                case kGameObjectStrongMan:
                case kGameObjectFireRing:
                    [_gameObject updateObject:dt scale:self.scale];
                    break;
                default:
                    break;
            }            
		}
	}
    
    // To prevent the player from overshooting the final platform, detect when they reach
    // the final platform and do a landing animation
    if (finalPlatform != nil && player.position.x > (finalPlatform.position.x - ([finalPlatform boundingBox].size.width*.4))) {
        [player getPhysicsBody]->SetTransform([player getPhysicsBody]->GetPosition(), 0);
        
        [player getPhysicsBody]->SetLinearVelocity(b2Vec2(4, 3));
        finalPlatform = nil;
    }
    
    [self cleanupGameObjects];
}

- (void) pauseGame {
    [super pauseGame];
    [[HUDLayer sharedLayer] pauseGame];
    paused = YES;
}

- (void) resumeGame {
    [super resumeGame];
    [[HUDLayer sharedLayer] resumeGame];
    paused = NO;
}

#pragma mark - Zoom Control
- (void) finishedZoomingIn {
    zoomState = kZoomStateNone;
}

- (void) finishedZoomingOut {
    zoomState = kZoomStateZoomedOut;
}

/* Zoom based on how high the player is. Works in tandem with smartZoom for complete zoom control. */
- (void) adjustZoomBasedOnHeight:(ccTime)dt {
    if (player.state == kSwingerInAir) 
    {
        // Use constant value instead of boundingBox because it causes it to jiggle (height keeps changing)
        float yPos = (player.position.y + /*[player boundingBox].size.height*/ 50);
        float newScale = screenSize.height/yPos;
        float oldScale = self.scale;
       
        if (newScale < self.scale) {
            if (self.scale > verticalZoomScrollThreshold) {
                // Whenever player is caught, zoom is set appropriately. So we don't want
                // to undo that zoom. So only apply new zoom if it's less than current zoom.
                self.scale = newScale;

                [[AudioManager sharedManager] playChildrenAah];
            }
        } else {
            // currentZoom is the zoom calcualted when player is caught. If we're on
            // the way down, newScale will increase. Cap it to the currentZoom. Else
            // continue to zoom in as player comes down the screen.
            if (newScale > currentZoom) {
                self.scale = currentZoom;
            } else {
                self.scale = newScale;
            }
        }

        // zoom the parallax layers
        [[ParallaxBackgroundLayer sharedLayer] zoomBy:(oldScale - self.scale)];
        [[SkyLayer sharedLayer] zoomBy:(oldScale - self.scale)];
    }    
}

/* Zooms enough to show the next pole. */
- (void) smartZoom {

    float distanceToNextCatcher = [player.currentCatcher distanceToNextCatcher];
    float poleHeight = [player.currentCatcher getHeight];
    
    //CCLOG(@"************************************** poleHeight=%f", poleHeight);
    // First convert to screen coordinates [0, 480]
    float currentPos = normalizeToScreenCoord(gameNode.position.x, player.currentCatcher.position.x, self.scale);
    
    //CCLOG(@"**********smartZoom: distanceToNext=%f screenSize=%f minsu=%f scale=%f", distanceToNextCatcher, screenSize.width/self.scale, screenSize.width/self.scale - currentPos, self.scale);
    // +---------------+---------
    // |   Player      |   Catcher
    // |   *           |   *
    // +---------------+----------
    if (distanceToNextCatcher > screenSize.width - currentPos || poleHeight > screenSize.height) {
        zoomState = kZoomStateZoomingOut;
        // Calcualte what zoom level it needs to be to show the next item (plus buffer) 

        currentZoom = (screenSize.width)/(currentPos + distanceToNextCatcher + 50);


        float zoomForPole = (screenSize.height)/(poleHeight + 20);
        //CCLOG(@"************************************** zoom=%f  zoomForPole=%f", currentZoom, zoomForPole);
        if (zoomForPole < currentZoom) {
            currentZoom = zoomForPole;
        } else {
//            if (currentZoom < 0.4) {
//                currentZoom = 0.4;
//            }
        }

        float scaleAmount = self.scale - currentZoom;

        //CCLOG(@"n**************************** newScale = %f   screenPos=%f   sum=%f", currentZoom, currentPos, currentPos + distanceToNextCatcher);
        id scaleAction = [CCScaleTo actionWithDuration:1.0 scale:currentZoom];
        id finishedZoom = [CCCallFunc actionWithTarget:self selector:@selector(finishedZoomingOut)];
        id seq = [CCSequence actions:scaleAction, finishedZoom, nil];
        [self runAction:seq];
        
        [[ParallaxBackgroundLayer sharedLayer] scaleBy:scaleAmount duration:1.0];
        [[SkyLayer sharedLayer] scaleBy:scaleAmount duration:1.0];
    } else if (self.scale < 1.0) {
        zoomState = kZoomStateZoomingIn;
        currentZoom = 1.0;
        float scaleAmount = self.scale - currentZoom;

        id scaleAction = [CCScaleTo actionWithDuration:1.0 scale:currentZoom];
        id finishedZoom = [CCCallFunc actionWithTarget:self selector:@selector(finishedZoomingIn)];
        id seq = [CCSequence actions:scaleAction, finishedZoom, nil];
        [self runAction:seq];
        
        [[ParallaxBackgroundLayer sharedLayer] scaleBy:scaleAmount duration:1.0];
        [[SkyLayer sharedLayer] scaleBy:scaleAmount duration:1.0];
    }
}

- (void) timeRunningOut {
    
    [[UserData sharedInstance] setReduceVolume:YES];
    [[AudioManager sharedManager] playHeartBeat];
    [gripTimeInvalideTimer invalidate];
    gripTimeInvalideTimer = nil;
    gripTimeInvalideTimer = [NSTimer scheduledTimerWithTimeInterval:10 
                                                               target:self 
                                                             selector:@selector(timeOutGripTimeOut:)  
                                                             userInfo:nil 
                                                              repeats:NO];
}


- (void) timeOutGripTimeOut:(id)param {
    
    if (gripTimeInvalideTimer != nil) {
        [gripTimeInvalideTimer invalidate];
    }
    
    gripTimeInvalideTimer = nil;
    
    [[UserData sharedInstance] setReduceVolume:NO];
    [[AudioManager sharedManager] stopHeartBeat];
}

- (void) playerCaught:(NSNotification *)notification {
    
    [self timeOutGripTimeOut:nil];
}

/**
 * Allow player to fall to the ground without interference from other objects
 * when the grip runs out.
 */ 
- (void) noObjectCollisions: (NSNotification *)notification {
    
    CatcherGameObject * catcher = notification.object;
    
    if ([catcher gameObjectType] == kGameObjectCannon) {
        return;
    }
    
    for (CCNode<GameObject, PhysicsObject, CatcherGameObject> *go in levelObjects)  {
        switch ([go gameObjectType]) {
            case kGameObjectSpring:
            case kGameObjectCannon:
            case kGameObjectWheel:
            case kGameObjectElephant:
            case kGameObjectFireRing:
                [go setCollideWithPlayer:NO]; // stop all collisions
                break;
            default:
                break;
        }
    }
}

/**
 * Allow player to fall to the ground without interference from other objects
 * when the grip runs out.
 */ 
- (void) allowObjectCollisions {
    
    for (CCNode<GameObject, PhysicsObject, CatcherGameObject> *go in levelObjects)  {
        switch ([go gameObjectType]) {
            case kGameObjectSpring:
            case kGameObjectCannon:
            case kGameObjectWheel:
            case kGameObjectElephant:
            case kGameObjectFireRing:
                [go setCollideWithPlayer:YES]; // allow all collisions
                break;
            default:
                break;
        }
    }
}

- (void) onPinch:(UIPinchGestureRecognizer*)recognizer {
    
    if (isGameOver || !self.isTouchEnabled) {
        return;
    }
    
    if (zoomState != kZoomStateZoomingIn && zoomState != kZoomStateZoomingOut) {
    
        if(recognizer.state == UIGestureRecognizerStateBegan && self.scale != 0.0f) {
            recognizer.scale = self.scale;
        } else {
            float newScale = recognizer.scale;
            if (newScale < minPinchZoom) {
                newScale = minPinchZoom;
            } else if (newScale > maxZoom) {
                newScale = maxZoom;
            }
            [[ParallaxBackgroundLayer sharedLayer] zoomBy: (self.scale-newScale)];
            [[SkyLayer sharedLayer] zoomBy: (self.scale-newScale)];
            self.scale = newScale;
            currentZoom = self.scale;
        }
    }
}

- (void) handlePanFrom:(UIPanGestureRecognizer *)recognizer {
    
    if (isGameOver || !self.isTouchEnabled) {
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        // Set our boundaries
        float leftBoundary = -1*((screenSize.width/8));
        float rightBoundary = finalPlatformRightEdge - ((screenSize.width - 10)/self.scale);
        
        CGPoint translation = [recognizer translationInView:recognizer.view];
        
        // adjust the amount of movement by the scale so that panning feels appropriately
        // responsive
        float xScrollDelta = -translation.x/self.scale;
        float newX = gameNode.position.x - xScrollDelta;
        
        // If you are panning left and your current pan will overshoot left boundary
        // then cap pan scroll delta to what will bring you to the left boundary
        if(translation.x > 0) { // I am panning left
            float deltaX = gameNode.position.x + fabsf(xScrollDelta);
            
            if(deltaX > -leftBoundary) {
                newX = -leftBoundary;
                xScrollDelta = gameNode.position.x + leftBoundary;
            }
        } else if(translation.x < 0) { // I am panning right
            // if you are panning right and your current pan will overshoot right boundary
            // then cap pan scroll delta to what will bring you to the right boundary
            float deltaX = fabsf(gameNode.position.x) + fabsf(xScrollDelta);

            if(deltaX > rightBoundary) {
                newX = -rightBoundary;
                xScrollDelta = -(rightBoundary - fabsf(gameNode.position.x)); 
            }
        }
        
        CGPoint newPos = ccp(newX, gameNode.position.y);
        
        // for the parallax scrolling, adjust by the scale
        [[ParallaxBackgroundLayer sharedLayer] scrollXBy:(xScrollDelta*self.scale) YBy:0];

        gameNode.position = ccp(newPos.x, gameNode.position.y);
            
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    } else {
        // pan that went nowhere
        if (lastPanState == UIGestureRecognizerStateBegan && recognizer.state == UIGestureRecognizerStateEnded) {
            CCLOG(@"\n\n\n####   Manually invoking CCTouchesEnded  ####\n\n\n");
            [self ccTouchesEnded:nil withEvent:nil];
        }
    }
    
    lastPanState = recognizer.state;
}


/* Scroll handling. Starts scrolling when player reaches middle of screen. */
- (void) handleScreenScroll:(ccTime)dt { 
    float deltaXScroll = 0.f;
    float deltaYScroll = 0.f;
    
    switch (scrollMode) {
        case kScrollModeScroll: {
            float normalizedPlayerXPosition = normalizeToScreenCoord(gameNode.position.x, player.position.x, self.scale);
            deltaXScroll = normalizedPlayerXPosition - screenSize.width/2;            
            break;
        }
        case kScrollModeFinish: {
            // handle the elephant as a special case, since it moves left and right
            if ([player.currentCatcher gameObjectType] == kGameObjectElephant) {
                
                // Wait until zoom has completed before scrolling
                if (zoomState != kZoomStateZoomingIn && zoomState != kZoomStateZoomingOut) {
                    Elephant *elephant = (Elephant *)player.currentCatcher;
                    float leftPos = normalizeToScreenCoord(gameNode.position.x, elephant.leftPos, self.scale);

                    // determine if we need to scroll backwards
                    if (leftPos < screenSize.width/5) {
                        deltaXScroll = -400 * dt;
                        
                        // This makes sure we don't jitter once we finish scrolling backwards
                        if (leftPos + fabs(deltaXScroll) > screenSize.width/5) {
                            deltaXScroll = screenSize.width/5 - leftPos;
                            scrollMode = kScrollModeNone;
                        }
                    } else if (leftPos > screenSize.width/5) {
                        deltaXScroll = 400 * dt;
                    } else {
                        scrollMode = kScrollModeNone;
                    }
                }
            } else {
                // After player catches (when he catches the next catcher), we may need to
                // scroll the screen a bit more so he's not so near the center of screen.
                float currentCatcherPos = normalizeToScreenCoord(gameNode.position.x, player.currentCatcher.position.x, self.scale);
                //CCLOG(@"%%%%%%%%%%%% catcherPos=%f %f", currentCatcherPos, screenSize.width/5);
                if (currentCatcherPos > screenSize.width/5) {
                    //CCLOG(@"%%%%%%%%%%%% scrolling by %f", 400*dt);
                    deltaXScroll = 400 * dt;
                } else {
                    //CCLOG(@"%%%%%%%%%%%% stop scrolling");
                    scrollMode = kScrollModeNone;
                }
            }
            break;
        }
        case kScrollModeNone: {
            // Start the scroll if player has jumped and is at least half way across screen
            if (player.state == kSwingerInAir) {
                float playerScreenPos = normalizeToScreenCoord(gameNode.position.x, player.position.x, self.scale);
                if (playerScreenPos > screenSize.width/2) {
                    scrollMode = kScrollModeScroll;
                }
            }
            break;
        }
        default:
            break;
    }
        
    if (self.scale <= verticalZoomScrollThreshold) {
        float scaledScreenHeight = screenSize.height/self.scale;
        
        if (player.position.y + 50 > scaledScreenHeight) {
            deltaYScroll = scaledScreenHeight - (player.position.y + 50);
        }        
    }
    
//CCLOG(@"SCROLL 1 x: %f, y: %f", deltaXScroll, deltaYScroll);
    // Scroll the screen from right to left by how far the player has moved or up or down
    gameNode.position = ccp(gameNode.position.x - deltaXScroll, deltaYScroll);
    [[ParallaxBackgroundLayer sharedLayer] scrollXBy:(deltaXScroll*self.scale) YBy:(deltaYScroll)];    
    [[SkyLayer sharedLayer] scrollUp:deltaYScroll];
}

- (void) zoomInAndCenterOnPlayer {

    scrollMode = kScrollModeScroll;

    if (self.scale != 1) {
        float centerScrollTime = 1.5f; //- too long allowing player to start touching before zoom in was complete
        float scaleAmount = self.scale - 1.f;
        
        CCLOG(@"In zoomInAndCenterOnPlayer, scaleAmount=%f (self.scale=%f)\n", scaleAmount, self.scale);
        
        CCScaleTo * scaleAction = [CCScaleTo actionWithDuration:centerScrollTime scale:1];
        CCCallFunc * disableTouch = [CCCallFunc actionWithTarget:self selector:@selector(disableTouch)];
        CCCallFunc * enableTouch = [CCCallFunc actionWithTarget:self selector:@selector(enableTouch)];
        CCSequence * zoomIn = [CCSequence actions: disableTouch, scaleAction, enableTouch, nil];
        [self runAction:zoomIn];
        
        [[ParallaxBackgroundLayer sharedLayer] scaleBy:scaleAmount duration:centerScrollTime];
    }
}



- (void) disableTouch {
    self.isTouchEnabled = NO;
}

- (void) enableTouch {
    self.isTouchEnabled = YES;
}


#pragma mark - Touch handling
/*- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    BaseCatcherObject * catcher = (BaseCatcherObject *) [player currentCatcher];
    
    if([catcher gameObjectType] == kGameObjectWheel) {

        NSSet *allTouches = [event allTouches];
        //CCLOG(@"TOUCH COUNT %i", [allTouches count]);
        for (UITouch *touch in allTouches) { 
            // if tapping on the wheel, send a tap event, else touch event
            //UITouch * touch = [touches anyObject];
            
            CGRect objRect = [catcher boundingBox];
            CGPoint touchLoc = [touch locationInView: [touch view]];
            touchLoc = [[CCDirector sharedDirector] convertToGL:touchLoc];
            //CCLOG(@"TOUCH LOC: %f,%f", touchLoc.x, touchLoc.y);
            
            float scale = self.scale;
            CGPoint gamePlayPosition = gameNode.position;
            CGRect rect = CGRectMake((objRect.origin.x + gamePlayPosition.x) * scale, (objRect.origin.y + gamePlayPosition.y) * scale, objRect.size.width*scale, objRect.size.height*scale);
            //CCLOG(@"WHEEL RECT: %f,%f,%f,%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
            
            if (CGRectContainsPoint(rect, touchLoc)) {
                [player handleTapEvent];
            } else {
                [player handleTouchEvent];
            }
        }
    }
}*/

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (isGameOver) return;
    
    NSArray *touchArray = [touches allObjects];
    int touchCount = [touchArray count];
    
    BOOL nonGameTouch = NO;
    CGPoint touchPoint;
    for (int i = 0; i < touchCount; i++) {
        UITouch *touch = [touchArray objectAtIndex:i];
        touchPoint = [touch locationInView:[touch view]];
        touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
        if (touchPoint.x >= screenSize.width - ssipadauto(50) && touchPoint.y >= screenSize.height - ssipadauto(50)) {
            nonGameTouch = YES;
            if (!paused) {
                [self pauseGame];
            } 
            break;
        } else if(player.currentWind != nil && touchPoint.x >= screenSize.width - ssipadauto(100) && touchPoint.y >= screenSize.height - ssipadauto(50)) {
            nonGameTouch = YES;
            [[HUDLayer sharedLayer] displayWind:player.currentWind];
        }
    }
    
    if (!nonGameTouch && !paused ) {
        BOOL swallowed = [[HUDLayer sharedLayer] handleTouchEvent:touchPoint];
        if (!swallowed) {
            [player handleTouchEvent];
        }
    }
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


#pragma mark - Accessors
- (Player *) getPlayer {
    return player;
}

- (Ground *) getGround {
    return ground;
}

- (CCNode*) getNode {
    return gameNode;
}


#pragma mark - Level management

- (void) levelComplete {
    CCLOG(@"===   levelComplete   ===\n");
    [self unscheduleUpdate];
    
    NSDate *timeNow = [[[NSDate alloc] init] autorelease];
    double timeDelta = [timeNow timeIntervalSinceDate: startTime];
    
    [UserData sharedInstance].currentTime = timeDelta;
    
    [self cleanupGameAndLoadNextLevel: YES];
    
    self.isTouchEnabled = NO;
    
    // stop listening for pans/pinches
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:pan];
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:pinch];
    
    [[HUDLayer sharedLayer] showLevelCompleteScreen];
}

- (CCNode *) addTrajectoryPoint: (CGPoint) pos {
    
    TrajectoryPoint *dot = [TrajectoryPoint make];
    
    dot.tag = TRAJECTORY_TAG;
    dot.position = pos;
    [self addChild:dot z:10];
    
    return dot;
}

-(void) loadLevel:(int)level {

    // first world - grassy knoll
    int gameWorld = 0;
    
    if ([[[MainGameScene sharedScene] world] isEqualToString: WORLD_FOREST_RETREAT]) {
        gameWorld = 1;
    }
    
    NSArray *levelItems = [levelManager getItemsForLevel:level inWorld:gameWorld];

    if (levelItems == nil) {
        CCLOG(@"\n\n*****   ERROR: Requested to load a nonexistent level: %d   *****\n\n", level);
        return;
    }

    int count = 0;
    for (LevelItem *item in levelItems) {
        Wind * wind = nil;
        
        if(item.windSpeed > 0) {
            wind = [[Wind alloc] initWithValues: item.windSpeed direction: item.windDirection];
        }
        
        if (item.type == kGameObjectCatcher) {
            RopeSwinger *swinger = [RopeSwinger node];
            swinger.period = item.period;
            swinger.swingAngle = item.swingAngle;
            swinger.swingScale = item.ropeLength;
            swinger.grip = item.grip;
            swinger.poleScale = item.poleScale;
            swinger.wind = wind;
            
            [swinger setLevelObjects:levelObjects];
            [swinger setIndexInLevelObjects:count];
            [swinger createPhysicsObject:world];
            [swinger showAt:item.position];
//            swinger.catcherBody->SetGravityScale(count);

            // Add to the list of objects in this level
            [levelObjects addObject:swinger];
            count++;
        } else if (item.type == kGameObjectCannon) {
            Cannon *cannon = [Cannon node];
            cannon.motorSpeed = item.speed;
            cannon.rotationAngle = item.swingAngle;
            cannon.shootingForce = item.force;
            cannon.timeout = item.grip;
            cannon.wind = wind;
            
            [cannon setLevelObjects:levelObjects];
            [cannon setIndexInLevelObjects:count];
            [cannon createPhysicsObject:world];
            [cannon showAt:item.position];
            
            [levelObjects addObject:cannon];
            count++;
        } else if (item.type == kGameObjectSpring) {
            Spring *spring = [Spring node];
            spring.bounceFactor = item.bounce;
            spring.timeout = item.grip;
            spring.wind = wind;
            
            [spring setLevelObjects: levelObjects];
            [spring setIndexInLevelObjects: count];
            [spring createPhysicsObject:world];
            [spring showAt:item.position];
            
            [levelObjects addObject: spring];
            count++;
        } else if (item.type == kGameObjectElephant) {
            Elephant *elephant = [Elephant node];
            [gameNode addChild:elephant];
            
            elephant.leftPos = item.leftEdge;
            elephant.rightPos = item.rightEdge;
            elephant.walkVelocity = item.walkVelocity;
            elephant.wind = wind;
            elephant.timeout = item.grip;
            CCLOG(@"  ADDING ELEPHANT, grip=%f/%f\n", item.grip, elephant.timeout);
            
            [elephant setLevelObjects:levelObjects];
            [elephant setIndexInLevelObjects:count];
            [elephant createPhysicsObject:world];
            [elephant showAt:item.position];
            
            [levelObjects addObject:elephant];
            count++;
        } else if (item.type == kGameObjectWheel) {
            Wheel *wheel = [Wheel node];
            wheel.motorSpeed = item.speed;
            wheel.timeout = item.grip;
            wheel.wind = wind;
            
            [wheel setLevelObjects: levelObjects];
            [wheel setIndexInLevelObjects: count];
            [wheel createPhysicsObject:world];
            [wheel showAt:item.position];
            
            [levelObjects addObject: wheel];
            count++;
        } else if (item.type == kGameObjectFireRing) {
            FireRing *fireRing = [FireRing node];
            fireRing.wind = wind;
            
            [fireRing setLevelObjects: levelObjects];
            [fireRing setIndexInLevelObjects: count];
            [fireRing createPhysicsObject:world];
            [fireRing showAt:item.position];
            [fireRing setFrequency:item.speed]; // frequency in hz
            [fireRing setMovement:item.movement];
            
            [levelObjects addObject: fireRing];
            count++;
        } else if (item.type == kGameObjectFinalPlatform) {
            FinalPlatform *fp = [FinalPlatform node];
            [gameNode addChild:fp];
            [fp setLevelObjects:levelObjects];
            [fp createPhysicsObject:world];
            [fp setIndexInLevelObjects:count];
            [fp showAt:item.position];
            [levelObjects addObject:fp];
            finalPlatformLeftEdge = item.position.x;
            finalPlatformRightEdge = item.position.x + [fp boundingBox].size.width;
            
            minPinchZoom = screenSize.width/(finalPlatformRightEdge + 20);
            
            if (minPinchZoom > 1) {
                minPinchZoom = 1;
            }
            
            count++;
        } else if (item.type == kGameObjectDummy) {
            DummyCatcherObject *dummy = [DummyCatcherObject node];
            [dummy createPhysicsObject:world];
            [dummy setLevelObjects:levelObjects];
            [dummy setIndexInLevelObjects:count];
            [dummy showAt:item.position];
            [gameNode addChild:dummy];
            [levelObjects addObject:dummy];
            count++;
        } else if (item.type == kGameObjectStrongMan) {
            StrongMan *strongMan = [StrongMan node];
            [strongMan createPhysicsObject:world];
            [strongMan showAt: item.position];
            [gameNode addChild: strongMan z: 10];
            // Don't add it to levelObjects
            // Don't increment count
        } else if (item.type == kGameObjectFloatingPlatform) {
            FloatingPlatform *platform = [FloatingPlatform make: item.width];
            [platform createPhysicsObject:world];
            [platform setLevelObjects:levelObjects];
            [platform showAt:item.position];
            [gameNode addChild:platform z:-2];
            [levelObjects addObject:platform];
            count++;
        } else if (item.type == kGameObjectStar) {
            Star *star = [Star make];
            [star createPhysicsObject:world];
            [star showAt:item.position];
            [gameNode addChild:star];
            // Don't add it to levelObjects
            // Don't increment count
        } else if (item.type == kGameObjectCoin ||
                   item.type == kGameObjectCoin5 ||
                   item.type == kGameObjectCoin10) {
            Coin *coin = [Coin make: item.type];
            [coin createPhysicsObject:world];
            [coin showAt:item.position];
            [gameNode addChild:coin];
            // Don't add it to levelObjects
            // Don't increment count
        }
        else if (item.type == kGameObjectTreeClump1 
                   || item.type == kGameObjectTreeClump2  
                   || item.type == kGameObjectTreeClump3
                   || item.type == kGameObjectTent1
                   || item.type == kGameObjectTent2
                   || item.type == kGameObjectTree1
                   || item.type == kGameObjectTree2
                   || item.type == kGameObjectTree3
                   || item.type == kGameObjectTree4
                   || item.type == kGameObjectPopcornCart
                   || item.type == kGameObjectBalloonCart
                   || item.type == kGameObjectTorch
                   || item.type == kGameObjectBoxes) 
        {
            [[ParallaxBackgroundLayer sharedLayer] addToForegroundObjectsList:item];            
            // Don't add it to levelObjects
            // Don't increment count
        }
    }
}




#pragma mark - House keeping
- (void) onExit {
    // Because NSTimer retains the target, it must first be invalidated
    // before the target will be deallocated. So it cannot be invalidated
    // in dealloc, so invalidate in onExit, which will be called immediately 
    // when scene is replaced.
    if (gripTimeInvalideTimer != nil) {
        [gripTimeInvalideTimer invalidate];
        gripTimeInvalideTimer = nil;
    }
    [super onExit];
}

- (void) finishedLevel:(NSNotification *)notification {    
    //    scrollMode = kScrollModeNone;
    
    id delay = [CCDelayTime actionWithDuration:2.0f];
    id complete = [CCCallFunc actionWithTarget:self selector:@selector(levelComplete)];
    id seq = [CCSequence actions:delay, complete, nil];
    [self runAction:seq];
}

- (void) removeGameNode:(CCNode *)node cleanup:(BOOL)cleanup {
    [gameNode removeChild:node cleanup:cleanup];
}

- (void) collect:(CCNode<GameObject> *)node {
    [collectedObjects addObject:node];
    [gameNode removeChild:node cleanup:NO];
}

- (void) gameOver {
    CCLOG(@"===   gameOver   ===\n");
    isGameOver = YES;
    
    [[HUDLayer sharedLayer] showGameOverDialog];
}

// Pre: main game loop has been unscheduled
- (void) restartGame:(id)loadNextLevel {
    CCLOG(@"===   restartGame   ===\n");
    
    [self unscheduleUpdate];
    
    // cleanup all layers
    [[ParallaxBackgroundLayer sharedLayer] cleanupLayer:[loadNextLevel boolValue]];
    [[StaticBackgroundLayer sharedLayer] cleanupLayer];
    [[TouchCloudLayer sharedLayer] cleanupLayer];
    
    // cleanup game objects and load next level if level completed
    [self cleanupGameAndLoadNextLevel:[loadNextLevel boolValue]];
    
    // re-init all layers
    //[[ParallaxBackgroundLayer sharedLayer] initLayer];
    [[StaticBackgroundLayer sharedLayer] initLayer];
    [[TouchCloudLayer sharedLayer] initLayer];
    [SkyLayer sharedLayer].scale = 1.f;
    
    // cleanup time
    [startTime release];
    startTime = nil;
    
    [self initGame];
}

// Pre: main game loop has been unscheduled
- (void) cleanupGameAndLoadNextLevel:(BOOL)loadNextLevel {
    [self cleanupGameObjects];
    [toDeleteArray removeAllObjects];
    
    if (loadNextLevel) {
        CCLOG(@"**** cleanupGameAndLoadNextLevel: loading next level");
        //[self cleanupEverything];
        
        // not loading next level rather show level complete menu allowing user to pick next game play level
        //currentLevel++;
        //[self loadLevel:currentLevel];
    } else { // Restart level
        for (CCNode<GameObject, PhysicsObject, CatcherGameObject> *go in levelObjects)  {
            [go reset]; // Reset all game objects on restart.
        }
        
        // remove all collected objects from HUDLayer and add them back to the gameNode
        // so they can be reset
        for (CCNode *node in collectedObjects) {
            [[HUDLayer sharedLayer] removeChild:node cleanup:NO];
            [gameNode addChild:node];
        }
        [collectedObjects removeAllObjects];
        
        CCNode *node;
        for (int i = [[gameNode children] count]-1; i >= 0; i--) {
            node = [[gameNode children] objectAtIndex:i];
            if ([node conformsToProtocol:@protocol(GameObject)]) {
                CCNode<GameObject, PhysicsObject> *go = (CCNode<GameObject, PhysicsObject>*)node;
                [go reset];
            }
        }
    }
    
    gameNode.position = ccp(0,0);
    
}

- (void) cleanupGameObjects {
    CCNode<GameObject, PhysicsObject> *node;
    // Clean up. Do physics first then cocos objects
    for (int last = [toDeleteArray count]-1; last >= 0; last--) {
        node = (CCNode<GameObject, PhysicsObject>*)[toDeleteArray objectAtIndex:last];
        CCLOG(@"***** deleting %@", node);
        if ([node isSafeToDelete]) {
            CCLOG(@"deleting node of type %d\n", [node gameObjectType]);
            [toDeleteArray removeObjectAtIndex:last];
            [node destroyPhysicsObject];
            [node removeFromParentAndCleanup:YES];
        }
    }
}

- (void) addToDeleteList:(CCNode<GameObject>*)node {
    if (NO == [toDeleteArray containsObject:node]) {
        [toDeleteArray addObject:node];
    }
}


- (void) cleanupEverything {
    CCNode *node;
    
    for (int i = [levelObjects count]-1; i >= 0; i--) {
        CCNode *node = [levelObjects objectAtIndex:i];
        if ([node conformsToProtocol:@protocol(PhysicsObject)]) {
            CCNode<PhysicsObject>* physicsObject = (CCNode<PhysicsObject>*)node;
            [physicsObject destroyPhysicsObject];
        }
        [node removeFromParentAndCleanup:YES];
    }        
    [levelObjects removeAllObjects];
    
    for (int i = [collectedObjects count]-1; i>= 0; i--) {
        CCNode *node = [collectedObjects objectAtIndex:i];
        if ([node conformsToProtocol:@protocol(PhysicsObject)]) {
            CCNode<PhysicsObject>* physicsObject = (CCNode<PhysicsObject>*)node;
            [physicsObject destroyPhysicsObject];
        }
        [node removeFromParentAndCleanup:YES];
        
    }
    [collectedObjects removeAllObjects];
    
    // Remove game objects
    for (int i = [[gameNode children] count]-1; i >= 0; i--) {
        node = [[gameNode children] objectAtIndex:i];
        if ([node conformsToProtocol:@protocol(GameObject)]) {
            if ([node conformsToProtocol:@protocol(PhysicsObject)]) {
                CCNode<PhysicsObject>* physicsObject = (CCNode<PhysicsObject>*)node;
                [physicsObject destroyPhysicsObject];                    
            }
            [node removeFromParentAndCleanup:YES];
        }
    }
    
    
    for (int i = [[self children] count]-1; i >= 0; i--) {
        node = [[self children] objectAtIndex:i];
        if ([node conformsToProtocol:@protocol(PhysicsObject)]) {
            CCNode<PhysicsObject> *physicsObject = (CCNode<PhysicsObject>*)node;
            [physicsObject destroyPhysicsObject];
        }
        [node removeFromParentAndCleanup:YES];
    }    
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc {
    CCLOG(@"----------------------------- GamePlayLayer dealloc");

    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_GAME_STARTED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FINISHED_LEVEL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLAYER_CAUGHT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_GAME_OVER object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_TIME_RUNNING_OUT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PLAYER_FALLING object:nil];

    [[AudioManager sharedManager] reset];
    
    // Destroy player first (this should remove from parent node below)
    [player destroyPhysicsObject];
    [player removeFromParentAndCleanup:YES];
    [player release];

    [startTime release];
    
    [self cleanupEverything];
    
    [toDeleteArray removeAllObjects];
    [toDeleteArray release];
    [levelManager release];
    [ground release];
    
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:pan];
    [[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:pinch];
    
    [pinch release];
    [pan release];

    [levelObjects release];
    [collectedObjects release];

    
	// don't forget to call "super dealloc"
	[super dealloc];
}


#pragma mark - Debug / Misc

@end
