//
//  Player.h
//  SwingProto
//
//  Created by James Sandoz on 3/25/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Box2D.h"
#import "GameObject.h"
#import "PhysicsObject.h"
#import "CatcherGameObject.h"
#import "PhysicsSystem.h"
#import "PlayerFire.h"
#import "PlayerTrail.h"

typedef enum {
    kSwingerNone,                   // 0
    kSwingerSwinging,               // 1
    kSwingerInAir,                  // 2
    kSwingerLanding,                // 3
    kSwingerPosing,                 // 4
    kSwingerFalling,                // 5
    kSwingerInCannon,               // 6
    kSwingerOnSpring,               // 7
    kSwingerOnWheel,                // 8
    kSwingerOnFinalPlatform,        // 9
    kSwingerFinishedLevel,          // 10
    kSwingerCrashed,                // 11
    kSwingerDizzy,                  // 12
    kSwingerBalancing,              // 13
    kSwingerDead,                   // 14
    kSwingerOnFloatingPlatform      // 15
} SwingerState;

@class CatcherGameObject;
@class RopeSwinger;
@class Cannon;
@class Wind;

@interface Player : CCSprite<GameObject, PhysicsObject> {
    CGSize screenSize;
    
    b2World *world;
    b2Body *body;
    b2Joint *jointWithCatcher;
    float bodyWidth;
    float bodyHeight;
    
    ContactLocation top;
    ContactLocation bottom;
    
    CCSprite *bodySprite;
    PlayerHead headSkin; 
    PlayerBody bodySkin;
    
    BOOL receivedFirstJumpInput;
    BOOL isCaught;
    BOOL playerAdvanced;
    BOOL isSafeToDelete;
    
    SwingerState state;

    Wind * currentWind;
    
    int fromCurrentCatcherIndex;
    int numCatchersSkipped;
    CCNode<GameObject, PhysicsObject, CatcherGameObject>  *currentCatcher; // current catcher eg. RopeSwinger, Cannon etc...
    
    b2Vec2 previousPosition;
    b2Vec2 smoothedPosition;
    float previousAngle;
    float smoothedAngle;

#if USE_FIXED_TIME_STEP == 1
    PhysicsSystem *fixedPhysicsSystem;
#endif
        
    CCAction *animAction;
    CCSpeed  *runSpeedAction;
    
    CCSprite *dizzyStars;
    
    float landingScore;
    CCSprite *coin;
    
    BOOL  isFlying; // 
    BOOL  bounceRequested;
    float launchAngle; // angle that the player took flight
    float prevVelocity;  // used to track when flying player starts falling
    
    CGPoint catchLocation;
    
    // particle effects
    PlayerTrail *trail;
    PlayerFire *fire;
}

- (id) initWithHeadSkin:(PlayerHead)h bodySkin:(PlayerBody)b;

- (void) initPlayer:(CatcherGameObject *) initialCatcher;
- (void) moveTo:(CGPoint)pos;

- (BOOL) handleTouchEvent;
- (BOOL) handleTapEvent;

- (void) jump;
- (void) land;
- (void) setOnFire: (BOOL) onFire;

- (void) doTouchAction;
- (void) gripRanOut;
- (void) fallingAnimation;
- (void) swingingAnimation;
- (void) jumpingAnimation;
- (void) jumpingFromPlatformAnimation;
- (void) landingAnimation;
- (void) flyingAnimation: (float) angle;
- (void) bouncingAnimation : (float) delay;
- (void) runningAnimation : (float) delay;
- (void) platformRunningAnimation: (float) delay;
- (void) posingAnimation;
- (void) balancingAnimation;
- (void) balancingAnimation:(BOOL)flipX;
- (void) stopAnimation;
- (void) setupAnimationsWithHeadSkin:(PlayerHead)h bodySkin:(PlayerBody)b;
- (void) flip:(BOOL)flipX;

- (void) catchCatcher:(CCNode<GameObject, PhysicsObject, CatcherGameObject>*)newCatcher;
- (void) catchCatcher:(CCNode<GameObject, PhysicsObject, CatcherGameObject>*)newCatcher at: (CGPoint) location;
- (void) processContactWithCatcher:(CCNode<GameObject, PhysicsObject, CatcherGameObject>*)catcher;


- (void) bonusCoins:(int)numCoins;
+ (CCSprite*) getInstanceOfCannonHead;

+ (CCArray*) getSwingHeadFrames;
+ (CCArray*) getSwingBodyFrames;

@property (nonatomic, readonly) BOOL receivedFirstJumpInput;
@property (nonatomic, readonly) BOOL isCaught;
@property (nonatomic, readonly) float bodyWidth;
@property (nonatomic, readonly) float bodyHeight;
@property (nonatomic, readonly) Wind *currentWind;
@property (nonatomic, readwrite, assign) SwingerState state;
@property (nonatomic, readwrite, assign) CCNode<GameObject, PhysicsObject, CatcherGameObject> *currentCatcher;
@property (nonatomic, readwrite, assign) float landingScore;
@property (nonatomic, readwrite, assign) PlayerHead headSkin;
@property (nonatomic, readwrite, assign) PlayerBody bodySkin;

@end
