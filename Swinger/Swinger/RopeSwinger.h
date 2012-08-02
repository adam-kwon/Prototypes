//
//  RopeSwinger.h
//  SwingProto
//
//  Created by James Sandoz on 3/16/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Box2D.h"
#import "GameObject.h"
#import "PhysicsObject.h"
#import "CatcherGameObject.h"
#import "Wind.h"
#import "BaseCatcherObject.h"
#import "Player.h"

typedef enum {
    kSignPositive,
    kSignNegative
} SignType;


@interface RopeSwinger : BaseCatcherObject {
    CGPoint anchorPos;
    CCNode *parent;
    
    b2Fixture *catcherFixture;
    b2Fixture *magneticGripFixture;
    
    CCSprite *catcherSprite;
    CCLayerColor *rope;
    CCSprite *poleSprite;
    CCSprite *cap;
    CCSprite *swingerHead;
    CCSprite *swingerBody;
        
    CGPoint ropeSwivelPosition;
    
    
 
    float scrollBufferZone;
    
    double dtSum;
    float swingAngle;
    float gravity;
    float ropeLength;
    float swingScale;
    float period;
    float grip;
    
    b2Vec2 jumpForce;
    
    b2MouseJoint *mouseJoint;
    
    float poleScale;
    
    SignType previousSign;
    SignType sign;
    
    BOOL trajectoryDrawn;
    CCArray *dashes;
}

- (void) showAt:(CGPoint)pos;
- (void) createMagneticGrip : (float) radius;
- (void) destroyMagneticGrip;
- (void) calcJumpForce;
- (void) swing: (Player *) player;

@property (nonatomic, readwrite, assign) float swingAngle;
@property (nonatomic, readwrite, assign) float swingScale;
@property (nonatomic, readwrite, assign) float period;
@property (nonatomic, readwrite, assign) float grip;
@property (nonatomic, readwrite, assign) float poleScale;
@property (nonatomic, readonly) CCSprite *poleSprite;
@property (nonatomic, readonly) CCSprite *catcherSprite;
@property (nonatomic, readonly) CGPoint anchorPos;
@property (nonatomic, readonly) CGPoint ropeSwivelPosition;
@property (nonatomic, readonly) b2Vec2 jumpForce;

@end
