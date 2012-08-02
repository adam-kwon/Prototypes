//
//  Player.m
//  SwingProto
//
//  Created by James Sandoz on 3/25/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Player.h"
#import "RopeSwinger.h"
#import "Cannon.h"
#import "Spring.h"
#import "Wheel.h"
#import "GamePlayLayer.h"
#import "CatcherGameObject.h"
#import "HUDLayer.h"
#import "AudioEngine.h"
#import "AudioManager.h"
#import "Notifications.h"
#import "SkyLayer.h"
#import "Macros.h"
#import "Elephant.h"
#import "Constants.h"
#import "CCHeadBodyAnimate.h"
#import "CCHeadBodyAnimation.h"
#import "UserData.h"
#import "FinalPlatform.h"
#import "FireRing.h"
#import "PlayerFire.h"
#import "FloatingPlatform.h"

#define INITIAL_SWING_ANIM_DELAY 0.15f

static const int animationTag = 57;
static const int runningTag = 58;
static const float playerScale = 1.0f;

@interface Player(Private)
- (void) crash;
- (void) jumpFromElephant;
@end

@implementation Player
@synthesize state;
@synthesize isCaught;
@synthesize bodyWidth;
@synthesize bodyHeight;
@synthesize currentCatcher;
@synthesize receivedFirstJumpInput;
@synthesize landingScore;
@synthesize headSkin;
@synthesize bodySkin;
@synthesize currentWind;

static CCArray *swingHeadFrames;
static CCArray *swingBodyFrames;

#pragma mark - Initialization, setup and class members
+ (CCArray*) getSwingHeadFrames {
    return swingHeadFrames;
}

+ (CCArray*) getSwingBodyFrames {
    return swingBodyFrames;
}

+ (CCSprite*) getInstanceOfCannonHead {
    CCSprite *cannonHead;
    switch ([UserData sharedInstance].headSkin) {
        case kPlayerHeadDareDevilDave:
            cannonHead = [CCSprite spriteWithSpriteFrameName:@"Default_CannonHead.png"];
            break;            
        case kPlayerHeadRebel:
            cannonHead = [CCSprite spriteWithSpriteFrameName:@"Rebel_CannonHead.png"];
            break;
        default:
            break;
    }
    
    //cannonHead.scale = playerScale;
    
    return cannonHead;
}

- (void) reset {
    //
    [self initPlayer:nil];
}

- (id) initWithHeadSkin:(PlayerHead)h bodySkin:(PlayerBody)b {
    NSString *headSpriteName;
    NSString *bodySpriteName;
    
    headSkin = h;
    bodySkin = b;
    
    switch (headSkin) {
        case kPlayerHeadDareDevilDave:
            headSpriteName = @"Default_H_Swing1.png";
            break;
        case kPlayerHeadRebel:
            headSpriteName = @"Rebel_H_Swing1.png";
            break;
        default:
            headSpriteName = @"Default_H_Swing1.png";
            break;
    }

    switch (bodySkin) {
        case kPlayerBodyDareDevilDave:
            bodySpriteName = @"Default_B_Swing1.png";
            break;
        case kPlayerBodyRebel:
            bodySpriteName = @"Rebel_B_Swing1.png";
            break;            
        default:
            bodySpriteName = @"Default_B_Swing1.png";
            break;
    }

	if ((self = [super initWithSpriteFrameName:headSpriteName])) {
        screenSize = [[CCDirector sharedDirector] winSize];
#if USE_FIXED_TIME_STEP == 1
        fixedPhysicsSystem = PhysicsSystem::Instance();
#endif
        [self initPlayer: nil];
        [self setupAnimationsWithHeadSkin:headSkin bodySkin:bodySkin];

        // First child should be the body
        bodySprite = [CCSprite spriteWithSpriteFrameName:bodySpriteName];
        bodySprite.tag = PLAYER_BODY_SPRITE_TAG;
        [self addChild:bodySprite];
        
        // coin sprite to show for bonus coin collection
        coin = [CCSprite spriteWithSpriteFrameName:@"Coin1.png"];
        coin.visible = NO;
        [self addChild:coin];
        
    }
    
    return self;
}

- (void) initPlayer: (CatcherGameObject *) initialCatcher {
    top = kContactTop;
    bottom = kContactBottom;
    state = kSwingerNone;

    if (body != NULL) {
        // Move it so that it doesn't hit the final platform 
        // when the mouse joint tries to move the player
        body->SetActive(NO);
        body->SetTransform(b2Vec2(0, screenSize.height/PTM_RATIO), 0);
        body->SetActive(YES);
    }
    
    if (jointWithCatcher != NULL) {
        world->DestroyJoint(jointWithCatcher);
    }
    jointWithCatcher = NULL;
    
    [self stopAnimation];
    
    /*if(initialCatcher != nil) {
        [self moveTo: [initialCatcher getCatchPoint]];
        [self catchCatcher: initialCatcher];
        [self processContactWithCatcher: initialCatcher];
    }*/
    
    fromCurrentCatcherIndex = 0;
    numCatchersSkipped = 0;
    isCaught = NO;
    currentCatcher = nil;
    receivedFirstJumpInput = NO;
    playerAdvanced = NO;
    
    self.scale = playerScale;
    [self showTrail: NO];
    [self setOnFire: NO];
}



- (void) setupAnimationsWithHeadSkin:(PlayerHead)h bodySkin:(PlayerBody)b {

    NSString *swingHeadStr, *swingBodyStr;
    NSString *landingHeadStr, *landingBodyStr;
    NSString *poseHeadStr, *poseBodyStr;
    NSString *fallHeadStr, *fallBodyStr;
    NSString *flyHeadStr, *flyBodyStr;
    NSString *bounceHeadStr, *bounceBodyStr;
    NSString *balanceHeadStr, *balanceBodyStr;
    NSString *jumpHeadStr, *jumpBodyStr;
    NSString *crashHeadStr, *crashBodyStr;
    NSString *runHeadStr, *runBodyStr;
    
    switch (h) {
        case kPlayerHeadDareDevilDave:
            swingHeadStr = @"Default_H_Swing%d.png";
            landingHeadStr = @"Default_H_Land%d.png";
            poseHeadStr = @"Default_H_Pose%d.png";
            fallHeadStr = @"Default_H_Fall%d.png";
            flyHeadStr = @"Default_H_Fly%d.png";
            bounceHeadStr = @"Default_H_Bounce%d.png";
            balanceHeadStr = @"Default_H_Balance%d.png";
            jumpHeadStr = @"Default_H_Jump%d.png";
            crashHeadStr = @"Default_H_Crash%d.png";
            runHeadStr = @"Default_H_Run%d.png";
            break;
        case kPlayerHeadRebel:
            swingHeadStr = @"Rebel_H_Swing%d.png";
            landingHeadStr = @"Rebel_H_Land%d.png";
            poseHeadStr = @"Rebel_H_Pose%d.png";
            fallHeadStr = @"Rebel_H_Fall%d.png";
            flyHeadStr = @"Rebel_H_Fly%d.png";
            bounceHeadStr = @"Rebel_H_Bounce%d.png";
            balanceHeadStr = @"Rebel_H_Balance%d.png";
            jumpHeadStr = @"Rebel_H_Jump%d.png";
            crashHeadStr = @"Rebel_H_Crash%d.png";
            runHeadStr = @"Rebel_H_Run%d.png";
            break;
        default:
            break;
    }
    
    switch (b) {
        case kPlayerBodyDareDevilDave:
            swingBodyStr = @"Default_B_Swing%d.png";
            landingBodyStr = @"Default_B_Land%d.png";
            poseBodyStr = @"Default_B_Pose%d.png";
            fallBodyStr = @"Default_B_Fall%d.png";
            flyBodyStr = @"Default_B_Fly%d.png";
            bounceBodyStr = @"Default_B_Bounce%d.png";
            balanceBodyStr = @"Default_B_Balance%d.png";
            jumpBodyStr = @"Default_B_Jump%d.png";
            crashBodyStr = @"Default_B_Crash%d.png";
            runBodyStr = @"Default_B_Run%d.png";
            break;
        case kPlayerBodyRebel:
            swingBodyStr = @"Rebel_B_Swing%d.png";
            landingBodyStr = @"Rebel_B_Land%d.png";
            poseBodyStr = @"Rebel_B_Pose%d.png";
            fallBodyStr = @"Rebel_B_Fall%d.png";
            flyBodyStr = @"Rebel_B_Fly%d.png";
            bounceBodyStr = @"Rebel_B_Bounce%d.png";
            balanceBodyStr = @"Rebel_B_Balance%d.png";
            jumpBodyStr = @"Rebel_B_Jump%d.png";
            crashBodyStr = @"Rebel_B_Crash%d.png";
            runBodyStr = @"Rebel_B_Run%d.png";
            break;
        default:
            break;
    }
        
    CCSpriteFrame *frame;

    if (swingHeadFrames == nil) {
        swingHeadFrames = [[CCArray alloc] init];
    }
    // Remove all as setupAnimations can be called again
    [swingHeadFrames removeAllObjects];
    for (int i = 1; i <= 5; i++) {
        NSString *file = [NSString stringWithFormat:swingHeadStr, i];
        CCLOG(@"  loading sprite %@\n", file);
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
        [swingHeadFrames addObject:frame];
    }

    if (swingBodyFrames == nil) {
        swingBodyFrames = [[CCArray alloc] init];
    }
    // Remove all as setupAnimations can be called again
    [swingBodyFrames removeAllObjects];
    for (int i = 1; i <= 5; i++) {
        NSString *file = [NSString stringWithFormat:swingBodyStr, i];
        CCLOG(@"  loading sprite %@\n", file);
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
        [swingBodyFrames addObject:frame];
    }
    [swingBodyFrames retain];

        
    // Place them in blocks so we don't make stupid mistake of using wrong frame arrays
    
    // Jumping
    {
        NSMutableArray *jumpHeadFrames = [NSMutableArray array];
        for (int i=1; i <= 1; i++){
            NSString *file = [NSString stringWithFormat:jumpHeadStr, i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [jumpHeadFrames addObject:frame];
        }

        NSMutableArray *jumpBodyFrames = [NSMutableArray array];
        for (int i=1; i <= 1; i++){
            NSString *file = [NSString stringWithFormat:jumpBodyStr, i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [jumpBodyFrames addObject:frame];
        }

        CCHeadBodyAnimation *animJumping = [CCHeadBodyAnimation animationWithHeadFrames:jumpHeadFrames 
                                                                             bodyFrames:jumpBodyFrames 
                                                                                  delay:0.03125f
                                                             bodyPositionRelativeToHead:CGPointMake(ssipadauto(16.5), ssipadauto(0)) 
                                                      flippedBodyPositionRelativeToHead:CGPointMake(ssipadauto(21.75), ssipadauto(0))];

        
        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"jumpingAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animJumping name:@"jumpingAnimation"];
    }

    // Landing
    {
        NSMutableArray *landHeadFrames = [NSMutableArray array];
        for (int i=1; i <= 1; i++){
            NSString *file = [NSString stringWithFormat:landingHeadStr, i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [landHeadFrames addObject:frame];
        }

        NSMutableArray *landBodyFrames = [NSMutableArray array];
        for (int i=1; i <= 1; i++){
            NSString *file = [NSString stringWithFormat:landingBodyStr, i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [landBodyFrames addObject:frame];
        }

        CCHeadBodyAnimation *animLanding = [CCHeadBodyAnimation animationWithHeadFrames:landHeadFrames 
                                                                             bodyFrames:landBodyFrames 
                                                                                  delay:0.5f
                                                             bodyPositionRelativeToHead:CGPointMake(ssipadauto(30), ssipadauto(-11)) 
                                                      flippedBodyPositionRelativeToHead:CGPointMake(ssipadauto(9.75), ssipadauto(-11))];

        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"landingAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animLanding name:@"landingAnimation"];
    }
    
    // Posing
    {
        NSMutableArray *poseHeadFrames = [NSMutableArray array];
        for (int i=1; i <= 1; i++){
            NSString *file = [NSString stringWithFormat:poseHeadStr, i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [poseHeadFrames addObject:frame];
        }

        NSMutableArray *poseBodyFrames = [NSMutableArray array];
        for (int i=1; i <= 1; i++){
            NSString *file = [NSString stringWithFormat:poseBodyStr, i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [poseBodyFrames addObject:frame];
        }

        
        CCHeadBodyAnimation *animPosing = [CCHeadBodyAnimation animationWithHeadFrames:poseHeadFrames 
                                                                            bodyFrames:poseBodyFrames 
                                                                                 delay:0.5f
                                                            bodyPositionRelativeToHead:CGPointMake(ssipadauto(13.5), ssipadauto(-7.5)) 
                                                     flippedBodyPositionRelativeToHead:CGPointMake(ssipadauto(12), ssipadauto(-7.5))];
        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"posingAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animPosing name:@"posingAnimation"];
    }
    
    // Falling
    {
        NSMutableArray *fallHeadFrames = [NSMutableArray array];
        for (int i = 1; i <= 3; i++) {
            NSString *file = [NSString stringWithFormat:fallHeadStr, i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [fallHeadFrames addObject:frame];
        }
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:fallHeadStr, 2]];
        [fallHeadFrames addObject:frame];

        
        NSMutableArray *fallBodyFrames = [NSMutableArray array];
        for (int i = 1; i <= 3; i++) {
            NSString *file = [NSString stringWithFormat:fallBodyStr, i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [fallBodyFrames addObject:frame];
        }
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:fallBodyStr, 2]];
        [fallBodyFrames addObject:frame];

        CCHeadBodyAnimation *animFalling = [CCHeadBodyAnimation animationWithHeadFrames:fallHeadFrames 
                                                                             bodyFrames:fallBodyFrames 
                                                                                  delay:0.025f
                                                             bodyPositionRelativeToHead:CGPointMake(ssipadauto(21.75), ssipadauto(-7.5)) 
                                                      flippedBodyPositionRelativeToHead:CGPointMake(ssipadauto(19.5), ssipadauto(-7.5))];

        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"fallingAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animFalling name:@"fallingAnimation"];
    }
    
    // Crashing
    {
        NSMutableArray *crashHeadFrames = [NSMutableArray array];
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:crashHeadStr, 1]];
        [crashHeadFrames addObject:frame];

        NSMutableArray *crashBodyFrames = [NSMutableArray array];
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:crashBodyStr, 1]];
        [crashBodyFrames addObject:frame];

        CCHeadBodyAnimation *animCrashing = [CCHeadBodyAnimation animationWithHeadFrames:crashHeadFrames 
                                                                             bodyFrames:crashBodyFrames 
                                                                                  delay:0.5f
                                                             bodyPositionRelativeToHead:CGPointMake(ssipadauto(6), ssipadauto(8.25)) 
                                                       flippedBodyPositionRelativeToHead:CGPointMake(ssipadauto(28.5), ssipadauto(8.25))];

        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"crashingAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animCrashing name:@"crashingAnimation"];
    }
    
    // Dizzy stars
    {
        NSMutableArray *dizzyFrames = [NSMutableArray array];
        for (int i=1; i <= 5; i++) {
            NSString *file = [NSString stringWithFormat:@"Dizzy%d.png", i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [dizzyFrames addObject:frame];
        }
        CCAnimation *animDizzy = [CCAnimation animationWithFrames:dizzyFrames delay:.056f];    
        [[CCAnimationCache sharedAnimationCache] addAnimation:animDizzy name:@"dizzyAnimation"];
    
        // Add the dizzy stars as a child
        dizzyStars = [CCSprite spriteWithSpriteFrameName:@"Dizzy1.png"];
        [self addChild:dizzyStars];
        dizzyStars.position = ccp(ssipadauto(22), ssipadauto(35));
        dizzyStars.visible = NO;    
    }
    
    // Flying    
    {
        NSMutableArray *flyingHeadFrames = [NSMutableArray array];
        for(int i=1; i <= 2; i++) {
            NSString *file = [NSString stringWithFormat:flyHeadStr, i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [flyingHeadFrames addObject:frame];
        }

        NSMutableArray *flyingBodyFrames = [NSMutableArray array];
        for(int i=1; i <= 2; i++) {
            NSString *file = [NSString stringWithFormat:flyBodyStr, i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [flyingBodyFrames addObject:frame];
        }

        CCHeadBodyAnimation *animFlying = [CCHeadBodyAnimation animationWithHeadFrames:flyingHeadFrames 
                                                                            bodyFrames:flyingBodyFrames 
                                                                                 delay:0.05f
                                                            bodyPositionRelativeToHead:CGPointMake(ssipadauto(1.25), ssipadauto(2.5)) 
                                                     flippedBodyPositionRelativeToHead:CGPointMake(ssipadauto(37.25), ssipadauto(2.5))];
        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"flyingAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animFlying name:@"flyingAnimation"];
    }

    // Bouncing
    {
        NSMutableArray *bouncingHeadFrames = [NSMutableArray array];
        for(int i=1; i <= 3; i++) {
            NSString *file = [NSString stringWithFormat:bounceHeadStr, i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [bouncingHeadFrames addObject:frame];
        }

        NSMutableArray *bouncingBodyFrames = [NSMutableArray array];
        for(int i=1; i <= 3; i++) {
            NSString *file = [NSString stringWithFormat:bounceBodyStr, i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [bouncingBodyFrames addObject:frame];
        }

        CCArray *bounceBodyPositions = [CCArray array];
        [bounceBodyPositions addObject:[NSValue valueWithCGPoint:CGPointMake(ssipadauto(28.75), ssipadauto(-6.25))]];
        [bounceBodyPositions addObject:[NSValue valueWithCGPoint:CGPointMake(ssipadauto(28.75), ssipadauto(-10))]];
        [bounceBodyPositions addObject:[NSValue valueWithCGPoint:CGPointMake(ssipadauto(28.75), ssipadauto(-16))]];
        
        CCHeadBodyAnimation *animBouncing = [CCHeadBodyAnimation animationWithHeadFrames:bouncingHeadFrames 
                                                                              bodyFrames:bouncingBodyFrames
                                                                                   delay:0.3f
                                                             bodyPositionsRelativeToHead:bounceBodyPositions];

        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"bouncingAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animBouncing name:@"bouncingAnimation"];
    }

    // Balance
    {    
        NSMutableArray *balanceHeadFrames = [NSMutableArray array];
        for (int i=1; i <= 4; i++) {
            NSString *file = [NSString stringWithFormat:balanceHeadStr, i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [balanceHeadFrames addObject:frame];
        }

        NSMutableArray *balanceBodyFrames = [NSMutableArray array];
        for (int i=1; i <= 4; i++) {
            NSString *file = [NSString stringWithFormat:balanceBodyStr, i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [balanceBodyFrames addObject:frame];
        }

        CCHeadBodyAnimation *animBalance = [CCHeadBodyAnimation animationWithHeadFrames:balanceHeadFrames 
                                                                            bodyFrames:balanceBodyFrames 
                                                                                 delay:0.0833f
                                                            bodyPositionRelativeToHead:CGPointMake(ssipadauto(8), ssipadauto(-3.75)) 
                                                      flippedBodyPositionRelativeToHead:CGPointMake(ssipadauto(34.25), ssipadauto(-3.75))];
        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"balanceAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animBalance name:@"balanceAnimation"];
    }
    
    // Running
    {    
        NSMutableArray *runningHeadFrames = [NSMutableArray array];
        for (int i=1; i <= 7; i++) {
            NSString *file = [NSString stringWithFormat:runHeadStr, i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [runningHeadFrames addObject:frame];
        }
        
        NSMutableArray *runningBodyFrames = [NSMutableArray array];
        for (int i=1; i <= 7; i++) {
            NSString *file = [NSString stringWithFormat:runBodyStr, i];
            frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:file];
            [runningBodyFrames addObject:frame];
        }
        
        CCArray *bounceBodyPositions = [CCArray array];
        [bounceBodyPositions addObject:[NSValue valueWithCGPoint:CGPointMake(ssipadauto(8.375), ssipadauto(-5.5))]];
        [bounceBodyPositions addObject:[NSValue valueWithCGPoint:CGPointMake(ssipadauto(8.375), ssipadauto(-7))]];
        [bounceBodyPositions addObject:[NSValue valueWithCGPoint:CGPointMake(ssipadauto(8.375), ssipadauto(-10.75))]];
        [bounceBodyPositions addObject:[NSValue valueWithCGPoint:CGPointMake(ssipadauto(8.375), ssipadauto(-12.25))]];
        [bounceBodyPositions addObject:[NSValue valueWithCGPoint:CGPointMake(ssipadauto(8), ssipadauto(-5.5))]];
        [bounceBodyPositions addObject:[NSValue valueWithCGPoint:CGPointMake(ssipadauto(8.375), ssipadauto(-5.5))]];
        [bounceBodyPositions addObject:[NSValue valueWithCGPoint:CGPointMake(ssipadauto(8.375), ssipadauto(-12.25))]];
                
        
        CCHeadBodyAnimation *animRun = [CCHeadBodyAnimation animationWithHeadFrames:runningHeadFrames 
                                                                         bodyFrames:runningBodyFrames 
                                                                              delay:0.0833f
                                                        bodyPositionsRelativeToHead:bounceBodyPositions];
        [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"runningAnimation"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:animRun name:@"runningAnimation"];
    }
    
    //=================================
    // Setup particle effects
    //=================================
    
    {
        trail = [PlayerTrail particleWithFile:@"playerTrail.plist"];
        trail.scale = ssipadauto(0.85f);
        trail.position = ccp(0,0);
        [[GamePlayLayer sharedLayer] addChild:trail z:-1];
    }
     
    {
        fire = [PlayerFire particleWithFile:@"playerFire.plist"];
        fire.scale = ssipadauto(0.1f);
        fire.position = ccp(ssipadauto(20),ssipadauto(0));
        [self addChild: fire z:1];
    }
}

- (void) flip:(BOOL)flipX {
    CCLOG(@"In player.flip(%d)\n", flipX);
    
    self.flipX = flipX;
    bodySprite.flipX = flipX;
}

- (void) showTrail: (BOOL) show {
    
    if (show && !trail.visible) {
        trail.position = self.position;
        [trail resetSystem];
    } else if(!show && trail.visible) {
        [trail stopSystem];
    }
    
    trail.visible = show;
}

- (void) setOnFire: (BOOL) onFire {
    
    fire.visible = onFire;
    
    if (onFire) {
        
        [fire resetSystem];
        
        fire.scale = ssipadauto(0.05f);
        CCScaleTo *scale1 = [CCScaleTo actionWithDuration:0.4 scale:ssipadauto(0.3f)];
        CCScaleTo *scale2 = [CCScaleTo actionWithDuration:0.8 scale:ssipadauto(0.1f)];
        
        CCSequence *seq = [CCSequence actions:scale1, scale2, nil];
        [fire stopAllActions];
        [fire runAction: seq];
    } else {
        [fire stopSystem];
    }
}

- (void) createPhysicsObject:(b2World*)theWorld {

    CGPoint p = ccp(0,0);
    
    world = theWorld;
    
//    sprite = [CCSprite spriteWithFile:@"jumper.png"];
//    sprite.position = p;
//    [parent addChild:sprite];
    
    b2BodyDef jumperBodyDef;
    jumperBodyDef.type = b2_dynamicBody;
    jumperBodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    jumperBodyDef.userData = self;
    body = world->CreateBody(&jumperBodyDef);
    
    
//    b2PolygonShape topShape;
//    topShape.SetAsBox(self.contentSize.width*self.scale/PTM_RATIO/2, self.contentSize.height*self.scale/PTM_RATIO/4, b2Vec2(0, self.contentSize.height*self.scale/PTM_RATIO/4), 0);
//    b2FixtureDef topFixtureDef;
//    topFixtureDef.shape = &topShape;
//    topFixtureDef.density = 2.0f;
//    topFixtureDef.friction = 0.3f;
//    topFixtureDef.filter.categoryBits = CATEGORY_JUMPER;
//    topFixtureDef.filter.maskBits = CATEGORY_CATCHER | CATEGORY_GROUND;
//    b2Fixture *topFixture = body->CreateFixture(&topFixtureDef);
//    topFixture->SetUserData(&top);
//    
//    b2PolygonShape bottomShape;
//    bottomShape.SetAsBox(self.contentSize.width*self.scale/PTM_RATIO/2, self.contentSize.height*self.scale/PTM_RATIO/4, b2Vec2(0, -self.contentSize.height*self.scale/PTM_RATIO/4), 0);
//    b2FixtureDef bottomFixtureDef;
//    bottomFixtureDef.shape = &bottomShape;
//    bottomFixtureDef.density = 2.0f;
//    bottomFixtureDef.friction = 0.3f;
//    bottomFixtureDef.filter.categoryBits = CATEGORY_JUMPER;
//    bottomFixtureDef.filter.maskBits = CATEGORY_CATCHER | CATEGORY_GROUND;
//    b2Fixture *bottomFixture = body->CreateFixture(&bottomFixtureDef);
//    bottomFixture->SetUserData(&bottom);
        
    b2PolygonShape shape;
    
    // Hard code in size (due to separate head and body, can't rely on content size)
    bodyWidth = ssipadauto(40)*self.scale/PTM_RATIO;//ssipadauto(49)*self.scale/PTM_RATIO;
    bodyHeight = ssipadauto(60)*self.scale/PTM_RATIO;//ssipadauto(73)*self.scale/PTM_RATIO;
    shape.SetAsBox(bodyWidth/2, bodyHeight/2, b2Vec2(0, 0), 0);
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
#ifdef USE_CONSISTENT_PTM_RATIO
    fixtureDef.density = 1.f;
#else
    fixtureDef.density = 1.f/ssipad(4.f, 1.f);
#endif
    fixtureDef.friction = 5.3f;
    fixtureDef.filter.categoryBits = CATEGORY_JUMPER;
    fixtureDef.filter.maskBits = CATEGORY_CATCHER | CATEGORY_GROUND | CATEGORY_FINAL_PLATFORM | CATEGORY_CANNON | CATEGORY_STAR | CATEGORY_ELEPHANT | CATEGORY_SPRING | CATEGORY_WHEEL | CATEGORY_FIRE_RING | CATEGORY_FLOATING_PLATFORM;
    body->CreateFixture(&fixtureDef);
    
    CCLOG(@"*************************** player mass = %f %f %f %f", body->GetMass(), self.contentSize.width*self.scale/PTM_RATIO/2, self.contentSize.height*self.scale/PTM_RATIO/2,
          (self.contentSize.width*self.scale/PTM_RATIO/2*2 * self.contentSize.height*self.scale/PTM_RATIO/2*2)/4.0);
    //body->SetGravityScale(0.5);
}

#pragma mark - Helpers and controllers
- (void) catchCatcher:(CCNode<GameObject, PhysicsObject, CatcherGameObject>*)newCatcher  {
    [self catchCatcher:newCatcher at: CGPointZero];
}

- (void) catchCatcher:(CCNode<GameObject, PhysicsObject, CatcherGameObject>*)newCatcher at: (CGPoint) location  {
    
    if (state == kSwingerDead || state == kSwingerCrashed || state == kSwingerDizzy || state == kSwingerFalling) {
        return;
    }
    
    // attach to catcher - the same cannon/spring can recatch the player
    if (([self isMultiCatchAllowed : newCatcher] || currentCatcher != newCatcher) 
        && NULL == jointWithCatcher) 
    {
        catchLocation = location;
        
        if ([currentCatcher gameObjectType] == kGameObjectSpring && currentCatcher != newCatcher) {
            [(Spring *)currentCatcher unloadPlayer];
        }
        
        playerAdvanced = (currentCatcher != newCatcher);
        currentCatcher = newCatcher;
        
        isCaught = YES;
        self.rotation = 0;
        self.flipX = NO;
        self.flipY = NO;
                
        if ([newCatcher gameObjectType] == kGameObjectFireRing) {
            // special type of catcher which player passes through and is not necessarily caught by the catcher
            // if caught by this catcher usually a bad thing, usually means you ran into the catcher rather than through it
            
            return;
        } else if ([newCatcher gameObjectType] == kGameObjectCannon) {
            self.visible = NO;
        }
        
        /* 
         
         Game changed so that player stops on spring. Need to re-enable smart zoom.
         
         // Disable zoom when it's a spring so that the screen doesn't jerk.
         // The screen continuously move when you're landing on a screen
         // because you're not latching onto anything.
         */
         if ([currentCatcher gameObjectType] != kGameObjectFloatingPlatform) {
         [GamePlayLayer sharedLayer].scrollMode = kScrollModeFinish;
         [[GamePlayLayer sharedLayer] smartZoom];
         } else {
             [GamePlayLayer sharedLayer].scrollMode = kScrollModeScroll;
         }
        
        //[GamePlayLayer sharedLayer].scrollMode = kScrollModeFinish;
        //[[GamePlayLayer sharedLayer] smartZoom];
        
        // Calculate how many Dummy Catcher Objects (DCO) are between previous and current catcher
        // We want to ignore DCOs because they are as their name suggest, Dummys
        NSArray *levelObjects = [currentCatcher getLevelObjects];
        int numDummyObjects = 0;
        int indexInLevelObjects = [currentCatcher getIndexInLevelObjects];
        for (int i = fromCurrentCatcherIndex; i < indexInLevelObjects; i++) {
            CCNode<GameObject> *node = [levelObjects objectAtIndex:i];
            if ([node gameObjectType] == kGameObjectDummy) {
                numDummyObjects++;
            }
        }
        numCatchersSkipped =  (indexInLevelObjects - fromCurrentCatcherIndex) - numDummyObjects - 1;
        fromCurrentCatcherIndex = indexInLevelObjects;
        
        if (numCatchersSkipped > 0) {
            [[SkyLayer sharedLayer] showFireWork];
            [[HUDLayer sharedLayer] skippedCatchers: numCatchersSkipped];
        }
        
        if (playerAdvanced) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLAYER_CAUGHT object:currentCatcher];
        }
        
        CCLOG(@"======================> numCatchersSkiped = %d", numCatchersSkipped);
    }
}

- (void) processContactWithCatcher:(CCNode<GameObject, PhysicsObject, CatcherGameObject>*)catcher {
    
    if(state == kSwingerCrashed || state == kSwingerDizzy || state == kSwingerDead || state == kSwingerFalling) {
        return;
    }
    
    isFlying = NO;
    
    BOOL firstContact = NO;
    
    if (currentCatcher == nil) {
        firstContact = YES;
    }
    
    currentCatcher = catcher;
    currentWind = [(BaseCatcherObject*)catcher wind];
    float timeout = 0.f;
    
    [self resetGravity];

    switch ([currentCatcher gameObjectType]) {
        case kGameObjectCatcher: {
            timeout = ((RopeSwinger *) catcher).grip;
            [self createWeldJoint : catcher];
            [currentCatcher setSwingerVisible:YES];
            self.visible = NO;
            [self swingingAnimation];
            break;
        }
        case kGameObjectCannon: {
            Cannon * cannon = (Cannon *) catcher;
            [self createWeldJoint : catcher];
            body->SetSleepingAllowed(false);
            timeout = cannon.timeout;
            [(Cannon *) catcher load: self]; // load yourself into the cannon
            [self cannonLoadedAnimation];
            
            break;
        }
        case kGameObjectWheel: {
            timeout = [(Wheel *) catcher timeout];
            body->SetSleepingAllowed(false);
            [(Wheel *) catcher load: self at: catchLocation]; // climb on the wheel
            break;
        }
        case kGameObjectSpring: {
            timeout = [(Spring*) catcher timeout];
            [self bounceOnSpring];
            [[catcher getNextCatcherGameObject] setCollideWithPlayer: YES];
            
            if (!playerAdvanced /*&& !firstContact*/) {
                // bouncing on the spring
                timeout = 0;
            }
            
            break;
        }
        case kGameObjectElephant: {
            timeout = ((Elephant *) catcher).timeout;
            // load player on the elephant
            [(Elephant *) catcher load:self];
            break;
        }
        case kGameObjectFireRing: {
            [(FireRing *) catcher burn:self];
            break;
        }
        case kGameObjectFloatingPlatform: {
            [(FloatingPlatform *) catcher run:self at: catchLocation];
            break;
        }
        case kGameObjectFinalPlatform:
            state = kSwingerOnFinalPlatform;
            break;
        default:
            break;
    }
    
    if(DO_GRIP == 1 && timeout > 0 /*&& (!receivedFirstJumpInput || playerAdvanced)*/) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_WIND_BLOWING object:currentWind];
        [[HUDLayer sharedLayer] resetGripBar];
        [[HUDLayer sharedLayer] countDownGrip:timeout];
    }
}

- (void) createWeldJoint : (CCNode<GameObject, PhysicsObject, CatcherGameObject>*) catcher {
    NSAssert(jointWithCatcher == NULL, @"Joint with catcher should be NULL!");
    
    b2Body * catcherBody = [catcher getPhysicsBody];
    
    if ([catcher gameObjectType] == kGameObjectCannon || [catcher gameObjectType] == kGameObjectWheel) {
        [self moveTo: [catcher getCatchPoint]];
        body->SetTransform(body->GetPosition(), catcherBody->GetAngle());
    }
    
    b2WeldJointDef playerJointDef;
    playerJointDef.Initialize(catcherBody, body, catcherBody->GetWorldCenter());
    playerJointDef.collideConnected = NO;
    playerJointDef.bodyA = catcherBody;
    playerJointDef.bodyB = body;
    
    // set the local anchors of the joint to be the player and catcher's hands
    //XXX these will need to be set for iPad
    switch ([catcher gameObjectType]) {
        case kGameObjectCatcher: {
            playerJointDef.localAnchorA = b2Vec2(-10.f/PTM_RATIO, -7.f/PTM_RATIO);
            playerJointDef.localAnchorB = b2Vec2(8.f/PTM_RATIO, 6.f/PTM_RATIO);
            // start the grip countdown and update the grip bar in HUDLayer
            /*if(DO_GRIP == 1) {
                RopeSwinger *rs = (RopeSwinger*)catcher;
                [[HUDLayer sharedLayer] resetGripBar];
                [self schedule:@selector(countDownGrip) interval:rs.grip];
            }*/
            // XXX trying out magnegrip - destroying it on catch
            RopeSwinger *rs = (RopeSwinger*)catcher;
            [rs destroyMagneticGrip];
            break;            
        }
        case kGameObjectCannon: {
            /*if(DO_GRIP == 1) {
                Cannon *cannon = (Cannon*)catcher;
                [[HUDLayer sharedLayer] resetGripBar];
                [self schedule:@selector(countDownGrip) interval:cannon.timeout];
            }*/
            
            playerJointDef.localAnchorA = b2Vec2(0,0);
            playerJointDef.localAnchorB = b2Vec2(0, ssipadauto(-110.f)/PTM_RATIO);
            break;
        }
        case kGameObjectWheel: {
            /*if(DO_GRIP == 1) {
                Wheel *wheel = (Wheel *)catcher;
                [[HUDLayer sharedLayer] resetGripBar];
                [self schedule:@selector(countDownGrip) interval:wheel.timeout];
            }*/
            
            //float scale = (screenSize.height/640) * 2; // get scale for ipad/iphone
            playerJointDef.localAnchorA = b2Vec2(0,0);
            playerJointDef.localAnchorB = b2Vec2(ssipadauto(110.f)*self.scale/PTM_RATIO,0);
            //playerJointDef.localAnchorB = b2Vec2(0,0);
            break;
        }
        case kGameObjectElephant: {
            /*if(DO_GRIP == 1) {
                Elephant *elephant = (Elephant *)catcher;
                [[HUDLayer sharedLayer] resetGripBar];
                [self schedule:@selector(countDownGrip) interval:elephant.timeout];
                CCLOG(@"\n\n\n####   scheduling countdown for elephant with interval=%f  ####\n\n\n", elephant.timeout);
            }*/
        }
            break;
        default:
            break;
    }
    
    jointWithCatcher = world->CreateJoint(&playerJointDef);
}




- (BOOL) isMultiCatchAllowed: (CCNode<GameObject, PhysicsObject, CatcherGameObject>*) newCatcher {
    return ([currentCatcher gameObjectType] == kGameObjectCannon ||
            [currentCatcher gameObjectType] == kGameObjectSpring ||
            [currentCatcher gameObjectType] == kGameObjectFloatingPlatform);
}

- (void) gripRanOut {
    if(jointWithCatcher != NULL) {
        world->DestroyJoint(jointWithCatcher);
    }
    jointWithCatcher = NULL;
    
    [currentCatcher setSwingerVisible:NO];
    [currentCatcher setCollideWithPlayer: NO];
    self.visible = YES;
    
    receivedFirstJumpInput = YES;
    
    if (state == kSwingerFalling || state == kSwingerCrashed || state == kSwingerDizzy || state == kSwingerDead) {
        return;
    }
    
    switch ([currentCatcher gameObjectType]) {
        case kGameObjectCatcher:
            // Stop all forward momentum so the player will fall straight down
            [currentCatcher setCollideWithPlayer:NO];
            body->SetLinearVelocity(b2Vec2(0, body->GetLinearVelocity().y));
            [self fallingAnimation];
            break;
        case kGameObjectCannon:
            //state = kSwingerInAir; // shoot the player up
            [self shootFromCannon];
            break;
        case kGameObjectSpring:
            [self fallingAnimation];
            [(Spring *) currentCatcher fallApart]; // Uncomment this if we want spring to fall apart
            break;
        case kGameObjectWheel:
            body->SetLinearVelocity(b2Vec2(0,5));
            [self fallingAnimation];
            [(Wheel *) currentCatcher unload];
            // notification so wheel button can be hidden
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLAYER_IN_AIR object:nil];
            break;
        case kGameObjectElephant:
            body->SetLinearVelocity(b2Vec2(2.5, 5));
            [(Elephant *)currentCatcher buck];
            //                [currentCatcher setCollideWithPlayer:NO];
            [self fallingAnimation];
            break;
        default:
            break;
    }        
}


- (void) scoreLanding {
    FinalPlatform *fp = (FinalPlatform*)currentCatcher;
    
    float finalPlatformLeftEdge = fp.position.x;
    float finalPlatformRightEdge = fp.position.x + [fp boundingBox].size.width;
    
    float finalPlatformHalfWidth = (finalPlatformRightEdge - finalPlatformLeftEdge)/2;
    float finalPlatformCenter = finalPlatformLeftEdge + finalPlatformHalfWidth;
    float offset = fabs(self.position.x-finalPlatformCenter);
    
    // The score is the percent away from the center of the platform (lower is better)
    landingScore = offset/finalPlatformHalfWidth;
    
    //    CCLOG(@"\n\n\n***  scoreLanding: set score to %f, offset was %f (half width=%f)  ***\n\n\n", player.landingScore, offset, finalPlatformHalfWidth);
    
    int score=0;
    if (landingScore < .15f) {
        score = 3;
    } else if (landingScore < .35f) {
        score = 2;
    } else if (landingScore < .5f) {
        score = 1;
    }
    
    if (score > 0) {
        [self bonusCoins:score];
    }
}

- (void) moveTo:(CGPoint)position {
    self.position = position;
    body->SetTransform(b2Vec2(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO), body->GetAngle());
}


#pragma mark - Touch handling
- (void) doTouchAction {
    
    switch ([currentCatcher gameObjectType]) {
        case kGameObjectCatcher:
            [self jumpFromSwing];
            break;
        case kGameObjectCannon:
            [self shootFromCannon];
            break;
        case kGameObjectSpring:
            [self bounceOffSpring];
            break;
        case kGameObjectElephant:
            [self jumpFromElephant];
            break;
        case kGameObjectWheel:
            [self jumpFromWheel];
            break;
        case kGameObjectFloatingPlatform:
            [self jumpFromPlatform];
            break;
        default:
            break;
    }
}

- (BOOL) handleTouchEvent {
    
    if(state == kSwingerCrashed || state == kSwingerDizzy || state == kSwingerDead || state == kSwingerFalling) {
        return NO;
    }
    
    if (jointWithCatcher != NULL || 
        (([currentCatcher gameObjectType] == kGameObjectSpring   || 
        [currentCatcher gameObjectType] == kGameObjectElephant || 
        [currentCatcher gameObjectType] == kGameObjectWheel ||
        [currentCatcher gameObjectType] == kGameObjectFloatingPlatform) && state != kSwingerInAir)) {
        
        [[HUDLayer sharedLayer] resetGripBar];
        
        // make sure the old catcher no longer collides with the player, and enable collision
        // for the next object
        [currentCatcher setCollideWithPlayer:NO];
        
        [[currentCatcher getNextCatcherGameObject] setCollideWithPlayer:YES];
        [currentCatcher setSwingerVisible:NO];
        
        if(jointWithCatcher != NULL) {
            //XXX is it safe to just destroy this here or does this need to happen in update?
            //XXX seems safe so far but I'm not 100% convinced
            world->DestroyJoint(jointWithCatcher);
            jointWithCatcher = NULL;
        }
        
        // switch to the jumping animation
        [self doTouchAction];

        receivedFirstJumpInput = YES;
        
        //[[AudioEngine sharedEngine] playEffect:SND_SWOOSH];
        return YES;
    }
    
    return NO;
}

- (BOOL) handleTapEvent {
    
    if([currentCatcher gameObjectType] == kGameObjectWheel) {
    
        [(Wheel *) currentCatcher handleTap];
        
        return YES;
    }
    
    return NO;
}


#pragma mark - Player control
- (void) jump {
    [self jumpingAnimation];
    body->ApplyLinearImpulse(b2Vec2(0.0, body->GetMass()*15), body->GetWorldCenter());
}

- (void) jumpFromSwing {
    [self jumpingAnimation];
    
#ifdef USE_CONSTANT_JUMP_FORCE_FROM_SWING
    [(RopeSwinger *)currentCatcher swing: self];
    /*b2Vec2 jumpForce = ((RopeSwinger *)currentCatcher).jumpForce;
    // jump backwards if on the backswing
//    if (self.position.x < currentCatcher.position.x) {
//        jumpForce = b2Vec2(-jumpForce.x, jumpForce.y);
//    }
    body->SetLinearVelocity(jumpForce);*/
#endif
}

- (void) jumpFromWheel {
    [self jumpingAnimation];
    [(Wheel *)currentCatcher fling];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLAYER_IN_AIR object:nil];
    currentCatcher = nil;
}

- (void) jumpFromPlatform {
    [self showTrail: YES];
    [(FloatingPlatform *)currentCatcher jump: self];
    [currentCatcher setCollideWithPlayer: YES];
}

- (void) shootFromCannon {
    [self setVisible: YES];
    
    [self showTrail: YES];
    [(Cannon *)currentCatcher shoot];
    [currentCatcher setCollideWithPlayer: YES];
}

- (void) bounceOnSpring {
    [self setVisible: YES];
    [(Spring *)currentCatcher catchPlayer: self];
}

- (void) bounceOffSpring {
    state = kSwingerOnSpring;
    [(Spring *)currentCatcher bounce];
    [currentCatcher setCollideWithPlayer: YES];
}

- (void) jumpFromElephant {
    [self jumpingAnimation];
    [self setVisible: YES];
    [(Elephant *)currentCatcher jump];
    [currentCatcher setCollideWithPlayer: YES];
}

- (void) bouncingAnimation: (float) delay {
    CCLOG(@"In Player.springBounceAnimation, state=%d\n", state);
    if (state != kSwingerOnSpring) {        
        state = kSwingerOnSpring;
        
        //if (animAction != nil)
            //[self stopAnimation];
        
        //animAction = nil;
    }
    
    [self stopAnimation];
    
    CCAnimation *anim = [[CCAnimationCache sharedAnimationCache] animationByName:@"bouncingAnimation"];
    anim.delay = delay; // setting the delay based on the bounce factor of the spring
    CCAnimate *animate = [CCHeadBodyAnimate actionWithHeadBodyAnimation:anim restoreOriginalFrame:NO];
    CCSequence *seq = [CCSequence actions: animate, [CCCallFunc actionWithTarget:self selector:@selector(stopAnimation)], nil];
    animAction = seq;
    animAction.tag = animationTag;
    [self runAction:animAction];
}

- (void) runningAnimation: (float) pace {
    CCLOG(@"In Player.wheelRunningAnimation, state=%d\n", state);
    if (state != kSwingerOnWheel) {        
        state = kSwingerOnWheel;
        
        [self stopAnimation];
        
        CCAnimate *action = [CCHeadBodyAnimate actionWithHeadBodyAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"runningAnimation"] restoreOriginalFrame:NO];
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        
        runSpeedAction = [CCSpeed actionWithAction:(CCActionInterval*)animAction speed:pace];
        runSpeedAction.tag = runningTag;
    
        [self runAction:runSpeedAction];
    } else {
        // changing pace
        if (pace != runSpeedAction.speed) {
            [runSpeedAction setSpeed: pace];
        }
    }
}

- (void) platformRunningAnimation: (float) pace {
    CCLOG(@"In Player.platformRunningAnimation, state=%d\n", state);
    if (state != kSwingerOnFloatingPlatform) {       
        state = kSwingerOnFloatingPlatform;
        
        [self stopAnimation];
        
        CCAnimate *action = [CCHeadBodyAnimate actionWithHeadBodyAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"runningAnimation"] restoreOriginalFrame:NO];
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        
        runSpeedAction = [CCSpeed actionWithAction:(CCActionInterval*)animAction speed:pace];
        runSpeedAction.tag = runningTag;
        
        [self runAction:runSpeedAction];
    } else {
        // changing pace
        if (pace != runSpeedAction.speed) {
            [runSpeedAction setSpeed: pace];
        }
    }
}
                                              
- (void) cannonLoadedAnimation {
    CCLOG(@"In Player.swingingAnimation, state=%d\n", state);
    if (state != kSwingerInCannon) {        
        state = kSwingerInCannon;
        
        [self stopAnimation];
        
        //        
        //        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"swingingAnimation"] restoreOriginalFrame:NO];
        //        animAction = [CCRepeatForever actionWithAction:action];
        //        [self runAction:animAction];
    }
}

- (void) swingingAnimation {
    CCLOG(@"In Player.swingingAnimation, state=%d\n", state);
    if (state != kSwingerSwinging) {        
        state = kSwingerSwinging;
        
        [self stopAnimation];
        
        animAction = nil;
//        
//        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"swingingAnimation"] restoreOriginalFrame:NO];
//        animAction = [CCRepeatForever actionWithAction:action];
//        [self runAction:animAction];
    }
}

- (void) jumpingFromPlatformAnimation {
    CCLOG(@"In Player.jumpingFromPlatformAnimation, state=%d\n", state);
    if (state != kSwingerInAir) {        
        state = kSwingerInAir;
        self.visible = YES;
        
        [self stopAnimation];
        
        CCAnimate *action = [CCHeadBodyAnimate actionWithHeadBodyAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"runningAnimation"] restoreOriginalFrame:NO];
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        
        runSpeedAction = [CCSpeed actionWithAction:(CCActionInterval*)animAction speed:0.5f];
        runSpeedAction.tag = runningTag;
        
        [self runAction:runSpeedAction];
    }
}

- (void) jumpingAnimation {

    CCLOG(@"In Player.jumpingAnimation, state=%d\n", state);
    if (state != kSwingerInAir || [currentCatcher gameObjectType] == kGameObjectSpring) {        
        state = kSwingerInAir;
        self.visible = YES;
        
        [self stopAnimation];
  
        CCAnimate *action = [CCHeadBodyAnimate actionWithHeadBodyAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"jumpingAnimation"] restoreOriginalFrame:NO];
        
        id rotate = [CCRotateBy actionWithDuration:0.2 angle:360];
        
        id spawn = [CCSpawn actions:action, rotate, nil];
        animAction = [CCRepeatForever actionWithAction:spawn];
        animAction.tag = animationTag;
        self.anchorPoint = ccp(0.5, 0.30);
        
        [self runAction:animAction];
    }
}

- (void) flyingAnimation: (float) angle {
    
    CCLOG(@"In Player.flyingAnimation, angle=%f state=%d\n", angle, state);
    if (state != kSwingerInAir) {        
        state = kSwingerInAir;
        
        self.visible = YES;
        
        [self stopAnimation];
        
        CCAnimate *action = [CCHeadBodyAnimate actionWithHeadBodyAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"flyingAnimation"] restoreOriginalFrame:NO];
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        

        [self runAction:animAction];
        
        self.flipX = NO;
        /*if(angle < 0) {
            self.flipY = YES;
        } else {
            self.flipY = NO;
        }*/
        
        isFlying = YES;
        launchAngle = angle;
        self.rotation = angle - 90; // rotate sprite to match launch angle
    }
}

- (void) landingAnimation {
    if (state != kSwingerLanding) {        
        state = kSwingerLanding;
        
        [self stopAnimation];
        
        CCAnimate *action = [CCHeadBodyAnimate actionWithHeadBodyAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"landingAnimation"] restoreOriginalFrame:NO];

        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        self.rotation = 0;
        [self runAction:animAction];
    }
}

- (void) posingAnimation {
    if (state != kSwingerPosing) {        
        state = kSwingerPosing;
        
        [self stopAnimation];
        
        CCAnimate *action = [CCHeadBodyAnimate actionWithHeadBodyAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"posingAnimation"] restoreOriginalFrame:NO];
        
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        [self runAction:animAction];
    }
}

- (void) land {
    id land;
    if (landingScore < .85) {
        land = [CCCallFunc actionWithTarget:self selector:@selector(landingAnimation)];
    } else {
        land = [CCCallFunc actionWithTarget:self selector:@selector(balancingAnimation)];        
    }
    
    id delay = [CCDelayTime actionWithDuration:0.5f];
    id pose = [CCCallFunc actionWithTarget:self selector:@selector(posingAnimation)];
    
    id seq = [CCSequence actions:land, delay, pose, nil];
    [self runAction:seq];
    [self showTrail:NO];
    
    [[GamePlayLayer sharedLayer] zoomInAndCenterOnPlayer];
}

- (void) fallingAnimation {
    // make the player fall straight down
    body->SetLinearVelocity(b2Vec2(0,5));
    
    CCLOG(@"In Player.fallingAnimation, state=%d speed=%f,%f\n", state,body->GetLinearVelocity().x,body->GetLinearVelocity().y);
    if (state != kSwingerFalling) {        
        state = kSwingerFalling;
        //currentCatcher = nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PLAYER_FALLING object:currentCatcher];
        
        [self stopAnimation];
        
        CCAnimate *action = [CCHeadBodyAnimate actionWithHeadBodyAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"fallingAnimation"] restoreOriginalFrame:NO];
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        [self runAction:animAction];
    }
}

- (void) balancingAnimation {
    [self balancingAnimation:NO];
}

- (void) balancingAnimation:(BOOL)flipX {
    if (state != kSwingerBalancing) {        
        state = kSwingerBalancing;
        
        [self stopAnimation];
        
        [self flip:flipX];
        
        CCAnimate *action = [CCHeadBodyAnimate actionWithHeadBodyAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"balanceAnimation"] restoreOriginalFrame:NO];
        animAction = [CCRepeatForever actionWithAction:action];
        animAction.tag = animationTag;
        self.rotation = 0;
        [self runAction:animAction];
    }
}


- (void) crash {
    if (state != kSwingerDizzy) {        
        state = kSwingerDizzy;
        [[AudioEngine sharedEngine] playEffect:SND_FOLLY];
        [[AudioEngine sharedEngine] playEffect:SND_DIZZY];

        [self stopAnimation];
        [self showTrail: NO];
        
        animAction = [CCHeadBodyAnimate actionWithHeadBodyAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"crashingAnimation"] restoreOriginalFrame:NO];
        animAction.tag = animationTag;
       [self runAction:animAction];
        
        dizzyStars.visible = YES;
        CCAnimate *dizzy = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"dizzyAnimation"] restoreOriginalFrame:NO];
        id dizzyRepeat = [CCRepeatForever actionWithAction:dizzy];
        [dizzyStars runAction:dizzyRepeat]; 
        
//        id delay = [CCDelayTime actionWithDuration:3.0f];
//        id die = [CCCallFunc actionWithTarget:self selector:@selector(die)];
//        id seq = [CCSequence actions:delay, die, nil];
//        [self runAction:seq];
        
        //[[GamePlayLayer sharedLayer] zoomInAndCenterOnPlayer];
    }
}

//- (void) die {
//    state = kSwingerDead;
//}

- (void) doBonusCoin {
    // reset the coin
    [coin stopAllActions];
    CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"coinAnimation"] restoreOriginalFrame:NO];
    CCRepeatForever *anim = [CCRepeatForever actionWithAction:action];
    [coin runAction:anim];
    
    float x=ssipadauto(18);
    float y=ssipadauto(40);
    if (state == kSwingerPosing) {
        x = ssipadauto(15);
    }
    
    coin.position = ccp(x,y);
    coin.visible = YES;
    
    id moveUp = [CCMoveBy actionWithDuration:.2f position:ccp(0,ssipad(300,150))];
    id moveDown = [CCMoveBy actionWithDuration:.1f position:ccp(0,ssipad(-150,-75))];
    id hide = [CCFadeOut actionWithDuration:0];
    id seq = [CCSequence actions:moveUp, moveDown, hide, nil];
    [coin runAction:seq];
    [[AudioEngine sharedEngine] playEffect:SND_BLOP];
    [[HUDLayer sharedLayer] addBonusCoin:1];
}

- (void) bonusCoins:(int)numCoins {

    NSMutableArray *coinActions = [NSMutableArray arrayWithCapacity:2*numCoins];
    for (int i=0; i < numCoins; i++) {
        id coinAction = [CCCallFunc actionWithTarget:self selector:@selector(doBonusCoin)];
        id delay = [CCDelayTime actionWithDuration:.3f];
        [coinActions addObject:coinAction];
        [coinActions addObject:delay];
    }
    
    id seq = [CCSequence actionsWithArray:coinActions];
    [self runAction:seq];
}


#pragma mark - GameObject protocol
- (void) updateObject:(ccTime)dt scale:(float)scale {    
    if (state == kSwingerFinishedLevel || state == kSwingerDead) {
        /*if (state == kSwingerDead) {
            CCLOG(@" Game over detected!  player.position.y=%f\n", self.position.y);
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GAME_OVER object:nil];
        }*/
        return;
    }
    
    if (state == kSwingerOnFinalPlatform) {
        self.rotation = 0;
        self.flipX = NO;
        self.flipY = NO;
        state = kSwingerFinishedLevel;
        body->SetActive(NO);
        [self scoreLanding];
        [self land];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FINISHED_LEVEL object:nil];
        return;
    }
    
    if (state == kSwingerCrashed) {
        self.rotation = 0;
        self.flipX = NO;
        self.flipY = NO;
        [self crash];
    }
    
    if (state == kSwingerDizzy) {
        self.rotation = 0;
        self.flipX = NO;
        self.flipY = NO;
        if (body->GetLinearVelocity().x <= 0.1) {
            [[GamePlayLayer sharedLayer] zoomInAndCenterOnPlayer];
            state = kSwingerDead;
            
            CCLOG(@" Game over detected!  player.position.y=%f\n", self.position.y);
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GAME_OVER object:nil];
        }
    }
    
    // stop rotating when we are standing
    if ((state == kSwingerLanding || state == kSwingerPosing || state == kSwingerFalling) && body->GetAngle() != 0) {
        body->SetTransform(body->GetPosition(), 0);
    }
    
    // XXX - TEMP FIX FOR SPRING MESSING UP PLAYERS ROTATION
    if(body->GetAngle() != 0) {
        // fix rotation
        body->SetTransform(body->GetPosition(), 0);
    }
    
    // Apply a y-offset to the sprite to make sure all animations display at the appropriate
    // height.  This is needed because the box2d object is sized based on the swinging 
    // animation, and other animations are not the same size, which can result in the player
    // "floating" above the ground.
    float yOffset = 0;
    float xOffset = 0;
    if (state == kSwingerCrashed || state == kSwingerDizzy || state == kSwingerDead) {
        float cosAngle = fabs(cosf(body->GetAngle()));
        if (cosAngle <= 0.7 ) {
            yOffset = ssipadauto(-3); //-12
        } else {
            yOffset = ssipadauto(-5); //-15
        }
    } else if (state == kSwingerPosing) {
        yOffset = ssipadauto(18);//11
    } else if (state == kSwingerLanding) {
        yOffset = ssipadauto(14);//7
    } else if (state == kSwingerBalancing) {
        yOffset = ssipadauto(11);//3
    } else if (state == kSwingerOnWheel || kSwingerOnFloatingPlatform) {
        yOffset = ssipadauto(16);//16
        xOffset = ssipadauto(4);
    } else if (state == kSwingerOnSpring) {
        yOffset = ssipadauto(20);
        xOffset = ssipadauto(0);
    } else if (isFlying) {
        yOffset = ssipadauto(16);
        xOffset = ssipadauto(-10);
    }
    
    BOOL fallingFromPlatform = NO;
    
    if (state == kSwingerOnFloatingPlatform && 
        body->GetContactList() != NULL && body->GetContactList()->next != NULL) {
        fallingFromPlatform = YES;
    }
    
    if (fallingFromPlatform) {
        [self fallingAnimation];
    }
    
#if USE_FIXED_TIME_STEP == 1
    const float oneMinusRatio = 1.f - fixedPhysicsSystem->fixedTimestepAccumulatorRatio;
    self.position = CGPointMake((body->GetPosition().x * fixedPhysicsSystem->fixedTimestepAccumulatorRatio + oneMinusRatio * previousPosition.x) * PTM_RATIO + xOffset, 
                                (body->GetPosition().y * fixedPhysicsSystem->fixedTimestepAccumulatorRatio + oneMinusRatio * previousPosition.y) * PTM_RATIO + yOffset);
#else
    self.position = CGPointMake((body->GetPosition().x) * PTM_RATIO + xOffset, 
                                (body->GetPosition().y) * PTM_RATIO + yOffset);    
#endif
    
    if (state != kSwingerNone && state != kSwingerFalling) {
        // start trail when player goes fast enough
        /*float threshold = 50.f;
        BOOL showTrail = NO;
        if (fabsf(body->GetLinearVelocity().x) >= threshold || fabsf(body->GetLinearVelocity().y) >= threshold) {
            showTrail = YES;
        }
        
        [self showTrail: showTrail];*/
        
        if (trail.visible) {
            trail.position = ccp(self.position.x + ssipadauto(10), self.position.y - ssipadauto(20));
            
            if (isFlying) {
                float rotation = 0;
                b2Vec2 vel = body->GetLinearVelocity();
                
                if (self.rotation + 90 == 0) {
                    // going straight up
                    if (vel.y > 0) {
                        rotation = -10;
                    } else if (vel.y < 0) {
                        rotation = 10;
                    }
                }
                
                trail.rotation = rotation;
            } else {
                trail.rotation = 0;
            }
        }
    }
    
    // If we are swinging, set the visible sprite to the appropriate frame based on the rotation
    if(state == kSwingerInCannon)
    {
        //CCSpriteFrame * frame = [jumpFrames objectAtIndex:0];
        
        //[self setDisplayFrame: frame];
        [self setVisible: NO];
    } else if(state == kSwingerInAir) {
        if(currentWind != nil) {
            [currentWind blow: body];
            currentWind = nil;
        }
        
        if (isFlying) {
            // Fix rotation if flying
            float currentVelocity = body->GetLinearVelocity().y;
            
            if (prevVelocity > 0 && currentVelocity <= 0) {
                // player is coming down
                float angle = 0;
                
                if (launchAngle == 0 || self.flipY) {
                    angle = 90;
                    CCRotateTo *rotate = [CCRotateTo actionWithDuration:0.75f angle: angle];
                    [self runAction: rotate];
                } else {
                    state = kSwingerNone; // have to set this for swinging animation to take
                    [self jumpingAnimation];
                    
                    isFlying = NO;
                }
            }
            
            prevVelocity = currentVelocity;
        }
        
        // limiting the players world bounds - x only
        float32 xPos = body->GetPosition().x * PTM_RATIO;
        
        if (xPos <= -(screenSize.width/4)) {
            body->SetLinearVelocity(b2Vec2(0, (body->GetLinearVelocity().y)));
        } else if (xPos >= [GamePlayLayer sharedLayer].finalPlatformRightEdge + ((screenSize.width/4)*self.scale)) {
            body->SetLinearVelocity(b2Vec2(0, (body->GetLinearVelocity().y)));
        }
    }
    
    // Player has caught catcher
    if (isCaught) {
        [self processContactWithCatcher: currentCatcher];
        isCaught = NO;
        
        //if ([currentCatcher gameObjectType] != kGameObjectCannon) {
            [self showTrail: NO];
        //}
    }
}

- (GameObjectType) gameObjectType {
    return kGameObjectJumper;
}

- (void) show {
    
}

- (void) hide {
    
}

- (BOOL) isSafeToDelete {
    return isSafeToDelete;
}

- (void) safeToDelete {
    isSafeToDelete = YES;
}


#pragma mark - PhysicsObject protocol
- (b2Vec2) previousPosition {
    return previousPosition;
}

- (b2Vec2) smoothedPosition {
    return smoothedPosition;
}

- (void) setPreviousPosition:(b2Vec2)p {
    previousPosition = p;
}

- (void) setSmoothedPosition:(b2Vec2)p {
    smoothedPosition = p;
}

- (float) previousAngle {
    return previousAngle;
}

- (float) smoothedAngle {
    return smoothedAngle;
}

- (void) setPreviousAngle:(float)a {
    previousAngle = a;
}

- (void) setSmoothedAngle:(float)a {
    smoothedAngle = a;
}


- (b2Body*) getPhysicsBody {
    return body;
}


- (void) destroyPhysicsObject {
    if (world != NULL) {
        world->DestroyBody(body);
    }
}

- (void) resetGravity {
    
    if (body != nil) {
        body->SetGravityScale(1.f);
    }
}

#pragma mark - Cleanup
- (void) stopAnimation {
    // Stop it by tag, becaue if animation is done, 
    // it will point to garbage causing it to crash.
    [self stopActionByTag:animationTag];
    [self stopActionByTag:runningTag];
    animAction = nil;
    runSpeedAction = nil;
    
    self.anchorPoint = ccp(0.5, 0.5);
    
    [dizzyStars stopAllActions];
    dizzyStars.visible = NO;
    
    // unflip
    self.flipX = NO;
    bodySprite.flipX = NO;
}

- (void) dealloc {
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [swingHeadFrames release];
    swingHeadFrames = nil;
    [swingBodyFrames release];
    swingBodyFrames = nil;
    [self removeChild:coin cleanup:YES];
    [trail removeFromParentAndCleanup:YES];
    [super dealloc];
}

@end
