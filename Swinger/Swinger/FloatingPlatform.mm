//
//  FloatingPlatform.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/3/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "FloatingPlatform.h"
#import "GamePlayLayer.h"
#import "Player.h"

@implementation FloatingPlatform

@synthesize width;

- (id) initPlatform: (float) theWidth {
    self = [super init];
    if (self) {
        screenSize = [CCDirector sharedDirector].winSize;
        
        width = theWidth;
        
        //[self build];
    }
    return self;
}

- (void) build {
    
    platform = [CCNode node];
    [self addChild:platform];
    self.anchorPoint = ccp(0,1);
    
    CCSprite * left = [CCSprite spriteWithSpriteFrameName:@"Tile_Left.png"];
    left.anchorPoint = ccp(0,0.5);
    CCSprite * middle = [CCSprite spriteWithSpriteFrameName:@"Tile_Middle.png"];
    middle.anchorPoint = ccp(0,0.5);
    CCSprite * right = [CCSprite spriteWithSpriteFrameName:@"Tile_Right.png"];
    right.anchorPoint = ccp(0,0.5);
    
    float remainingWidth = width - [left boundingBox].size.width - [right boundingBox].size.width;
    
    int numMiddle = 1;
    
    if (remainingWidth > 0) {
        numMiddle = ceil(remainingWidth/[middle boundingBox].size.width);
    
        if (numMiddle < 1) {
            numMiddle = 1;
        }
    }
    
    [platform addChild:left];
    
    int xPos = [left boundingBox].size.width - 1;
    
    middle.position = ccp(xPos,0);
    [platform addChild: middle];
    
    xPos += [middle boundingBox].size.width - 1;
    for (int i=1; i < numMiddle; i++) {
        
        CCSprite * middle = [CCSprite spriteWithSpriteFrameName:@"Tile_Middle.png"];
        middle.anchorPoint = ccp(0,0.5);
        middle.position = ccp(xPos,0);
        [platform addChild: middle];
        
        xPos += [middle boundingBox].size.width - 1;
    }
    
    right.position = ccp(xPos, 0);
    [platform addChild: right];
}
- (void) run: (Player *) player at:(CGPoint)location {
    if(player != nil) {
        b2Body * pBody = [player getPhysicsBody];
        CGPoint myPos = self.position;
        
        pBody->SetGravityScale(1.f);
        // run fool
        [player platformRunningAnimation:1.5];
        
        if (location.x < myPos.x) {
            // bounce the player back
            pBody->SetLinearVelocity(b2Vec2(0,0));
            pBody->ApplyLinearImpulse(b2Vec2(-9*pBody->GetMass(),0), pBody->GetWorldCenter());
            return;
        }
        
        float impulseMag = 7;
        float x = impulseMag;
        float y = 0;
        
        pBody->SetLinearVelocity(b2Vec2(x,y));
    }
}

- (void) jump: (Player *) player {
    if(player != nil) {
        b2Body * pBody = [player getPhysicsBody];
        
        // jump fool
        pBody->SetGravityScale(0.95);
        
        float impulseMag = 13;
        float x = impulseMag*0.75;
        float y = impulseMag;
        
        if ([[self getNextCatcherGameObject] gameObjectType] == kGameObjectFinalPlatform) {
            [player jumpingAnimation];
        } else {
            [player jumpingFromPlatformAnimation];
        }
        
        pBody->SetLinearVelocity(b2Vec2(x,y));
    }
}

- (void) reset {
    //
}

+ (id) make: (float) theWidth {
    return [[[self alloc] initPlatform: theWidth] autorelease];
}

- (void) moveTo:(CGPoint)pos {
    self.position = pos;
    
    body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
}

- (void) showAt:(CGPoint)pos {
    [self moveTo:pos];
    [self show];
}

#pragma mark - GameObject protocol
- (GameObjectType) gameObjectType {
    return kGameObjectFloatingPlatform;
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    //
    
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everything from GamePlayLayer. Convert to world coordinate first, and then compare.
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    
    CGPoint worldPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, (self.position.x), scale), 
                           gamePlayPosition.y + (self.position.y * PTM_RATIO));
    if (worldPos.x < -([platform boundingBox].size.width) || worldPos.x > screenSize.width) {
        if (platform.visible) {
            [self hide];
        }
    } else if (worldPos.x >= -([platform boundingBox].size.width) && worldPos.x <= screenSize.width) {
        if (!platform.visible) {
            [self show];
        }
    }
}

- (BOOL) isSafeToDelete {
    return isSafeToDelete;
}

- (void) safeToDelete {
    isSafeToDelete = YES;
}

- (void) show {
    [platform setVisible: YES];
    
    body->SetActive(true);
}

- (void) hide {
    //[platform setVisible: NO];
    
    //body->SetActive(false);
}

#pragma mark - physics object methods

- (void) createPhysicsObject:(b2World *)theWorld {
    
    float height = 0;
    platform = [CCNode node];
    [self addChild:platform];
    self.anchorPoint = ccp(0,1);
    
    CCSprite * left = [CCSprite spriteWithSpriteFrameName:@"Tile_Left.png"];
    left.anchorPoint = ccp(0,0.5);
    CCSprite * middle = [CCSprite spriteWithSpriteFrameName:@"Tile_Middle.png"];
    middle.anchorPoint = ccp(0,0.5);
    height = [middle boundingBox].size.height;
    CCSprite * right = [CCSprite spriteWithSpriteFrameName:@"Tile_Right.png"];
    right.anchorPoint = ccp(0,0.5);
    
    float remainingWidth = width - [left boundingBox].size.width - [right boundingBox].size.width;
    
    int numMiddle = 1;
    
    if (remainingWidth > 0) {
        numMiddle = ceil(remainingWidth/[middle boundingBox].size.width);
        
        if (numMiddle < 1) {
            numMiddle = 1;
        }
    }
    
    [platform addChild:left];
    
    int xPos = [left boundingBox].size.width - 1;
    
    middle.position = ccp(xPos,0);
    [platform addChild: middle];
    
    xPos += [middle boundingBox].size.width - 1;
    for (int i=1; i < numMiddle; i++) {
        
        CCSprite * middle = [CCSprite spriteWithSpriteFrameName:@"Tile_Middle.png"];
        middle.anchorPoint = ccp(0,0.5);
        middle.position = ccp(xPos,0);
        [platform addChild: middle];
        
        xPos += [middle boundingBox].size.width - 1;
    }
    
    right.position = ccp(xPos, 0);
    [platform addChild: right];
    
    world = theWorld;
    
    b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.fixedRotation = true;
    bodyDef.userData = self;
    body = world->CreateBody(&bodyDef);
	
    float32 theWidth = (xPos + [right boundingBox].size.width)/PTM_RATIO/2;
    
    b2PolygonShape shape;
    shape.SetAsBox(theWidth, height/PTM_RATIO/2, b2Vec2(theWidth, 0), 0);
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
#ifdef USE_CONSISTENT_PTM_RATIO
    fixtureDef.density = 5.f;
#else
    fixtureDef.density = 5.f/ssipad(4.f, 1.f);
#endif
    fixtureDef.friction = 0;
    
    fixtureDef.filter.categoryBits = CATEGORY_FLOATING_PLATFORM;
    fixtureDef.filter.maskBits = CATEGORY_JUMPER;
    body->CreateFixture(&fixtureDef);
}

- (void) destroyPhysicsObject {
    if (world != NULL) {
        world->DestroyBody(body);
    }
}

// Do not override unless absolutely necessary
- (b2Vec2) previousPosition {
    return previousPosition;
}

// Do not override unless absolutely necessary
- (b2Vec2) smoothedPosition {
    return smoothedPosition;
}

// Do not override unless absolutely necessary
- (void) setPreviousPosition:(b2Vec2)p {
    previousPosition = p;
}

// Do not override unless absolutely necessary
- (void) setSmoothedPosition:(b2Vec2)p {
    smoothedPosition = p;
}

// Do not override unless absolutely necessary
- (float) previousAngle {
    return previousAngle;
}

// Do not override unless absolutely necessary
- (float) smoothedAngle {
    return smoothedAngle;
}

// Do not override unless absolutely necessary
- (void) setPreviousAngle:(float)a {
    previousAngle = a;
}

// Do not override unless absolutely necessary
- (void) setSmoothedAngle:(float)a {
    smoothedAngle = a;
}

- (b2Body*) getPhysicsBody {
    return body;
}

- (float) getHeight {
    return self.position.y + [self boundingBox].size.height + [[[GamePlayLayer sharedLayer] getPlayer] boundingBox].size.height*2;
}

- (void) setCollideWithPlayer:(BOOL)doCollide {
    //
}

- (void) setSwingerVisible:(BOOL)visible {
    //
}

- (CGPoint) getCatchPoint {
    return CGPointZero;
}

- (void) dealloc {
    CCLOG(@"------------------------------ Floating platform being dealloced");
    
    [platform removeAllChildrenWithCleanup:YES];
    [platform removeFromParentAndCleanup: YES];
    
    [super dealloc];
}


@end
