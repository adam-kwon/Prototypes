//
//  FireRing.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/12/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "FireRing.h"
#import "GamePlayLayer.h"
#import "PlayerFire.h"

@implementation FireRing

@synthesize movement;
@synthesize frequency;

- (id) init {
    
    if ((self = [super init])) {
        //
        screenSize = [CCDirector sharedDirector].winSize;
        offset = 12.5f; // offset at original scale
    }
    
    return self;
}

- (GameObjectType) gameObjectType {
    return kGameObjectFireRing;
}

- (void) burn: (Player *) player {
    //[player setOnFire:YES];
    [player fallingAnimation];
    [self setCollideWithPlayer:NO];
}

- (void) createPhysicsObject:(b2World*)theWorld {
    world = theWorld;
    
    ringFront = [CCSprite spriteWithSpriteFrameName:@"FireRingFront.png"];
    ringFront.scale = 0.75f;
    ringBack = [CCSprite spriteWithSpriteFrameName:@"FireRingBack.png"];
    ringBack.scale = 0.75f;
    offset *= 0.75f;
    
    [[GamePlayLayer sharedLayer] addChild:ringFront z:3]; // ring front should appear infront of the player
    [[GamePlayLayer sharedLayer] addChild:ringBack z:-1]; // ring back should appear behind the player
    
    collideWithPlayer.categoryBits = CATEGORY_FIRE_RING;
    collideWithPlayer.maskBits = CATEGORY_JUMPER;
    noCollideWithPlayer.categoryBits = 0;
    noCollideWithPlayer.maskBits = 0;
    
    //=================================================
    // Create the collision edges of the ring
    //=================================================
    b2BodyDef topEdgeBodyDef;
    topEdgeBodyDef.type = b2_staticBody;
    topEdgeBodyDef.userData = self;
    topEdgeBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    body = world->CreateBody(&topEdgeBodyDef);
    
    float edgeRadius = [ringFront boundingBox].size.width/PTM_RATIO/8;
    
    b2CircleShape topEdgeShape;
    topEdgeShape.m_radius = edgeRadius;
    b2FixtureDef topEdgeFixture;
    topEdgeFixture.shape = &topEdgeShape;
#ifdef USE_CONSISTENT_PTM_RATIO
    topEdgeFixture.density = 10.0f;
#else
    topEdgeFixture.density = 10.0f/ssipad(4.0, 1);
#endif
    topEdgeFixture.filter.categoryBits = collideWithPlayer.categoryBits;
    topEdgeFixture.filter.maskBits = collideWithPlayer.maskBits;
    topEdge = body->CreateFixture(&topEdgeFixture);
       
    b2BodyDef bottomEdgeBodyDef;
    bottomEdgeBodyDef.type = b2_staticBody;
    bottomEdgeBodyDef.userData = self;
    bottomEdgeBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
    bottom = world->CreateBody(&bottomEdgeBodyDef);
    
    b2CircleShape bottomEdgeShape;
    bottomEdgeShape.m_radius = edgeRadius;
    b2FixtureDef bottomEdgeFixture;
    bottomEdgeFixture.shape = &bottomEdgeShape;
#ifdef USE_CONSISTENT_PTM_RATIO
    bottomEdgeFixture.density = 10.0f;
#else
    bottomEdgeFixture.density = 10.0f/ssipad(4.0, 1);
#endif
    bottomEdgeFixture.filter.categoryBits = collideWithPlayer.categoryBits;
    bottomEdgeFixture.filter.maskBits = collideWithPlayer.maskBits;
    bottomEdge = bottom->CreateFixture(&bottomEdgeFixture);
    
    // Particle effects
    fire = [PlayerFire particleWithFile:@"ringOfFire.plist"];
    fire.scaleY = ssipadauto(0.82f);//1.2f;
    fire.scaleX = ssipadauto(0.20f);//0.3f;
    
    [[GamePlayLayer sharedLayer] addChild: fire z:3];
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    
    // NOTE: REMOVED THIS BECAUSE IT THROWS OFF THE TIMING OF THE RINGS
    
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everything from GamePlayLayer. Convert to world coordinate first, and then compare.
    /*CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    
    CGPoint worldPos = ccp(normalizeToScreenCoord(gamePlayPosition.x, (body->GetPosition().x * PTM_RATIO), scale), 
                           gamePlayPosition.y + (body->GetPosition().y * PTM_RATIO));
    
    if (ringBack.visible && (worldPos.x < -([ringBack boundingBox].size.width/2) || worldPos.x > screenSize.width)) {
        [self hide];
    } else if (!ringBack.visible && worldPos.x >= -([ringBack boundingBox].size.width/2) && worldPos.x <= screenSize.width) {
        [self show];
    }
    
    // no need to do anything in this method if we are offscreen
    if (!ringFront.visible)
        return;*/
    
    dtSum += dt;
    
    if (dtSum >= (0.01f/frequency)) {
        [self oscillate];
        dtSum = 0;
    }
}

- (void) setMovement:(CGPoint)theMovement {
    movement = theMovement;
    moveFactor = 0.01f;
    origin = self.position;
    
    /*[self unscheduleAllSelectors];
    
    if (movement.x !=0.f || movement.y != 0.f) {
        
        // oscillate
        //[[CCScheduler sharedScheduler] scheduleSelector : @selector(oscillate) forTarget:self interval:0.01f/frequency paused:NO];
        [self oscillate];
    }*/
}

- (void) oscillate {
    
    if (ringFront.visible && (movement.x != 0 || movement.y != 0)) {
        
        float moveX = movement.x * moveFactor;
        float moveY = movement.y * moveFactor;
        
        [self moveTo: ccp(self.position.x + moveX, self.position.y + moveY)];
        
        if ([self hasReachedBoundary]) {
            //CCLOG(@"Changing directions");
            moveFactor *= -1.f;
        }
    }
}

- (BOOL) hasReachedBoundary {

    BOOL hitXBounds = NO;
    BOOL hitYBounds = NO;
    int moveFactorSign = (moveFactor > 0 ? 1 : -1);
    CGPoint myPos = self.position;
    CGPoint endPos = ccp(origin.x + (movement.x*moveFactorSign), origin.y + (movement.y*moveFactorSign));
    
    //CCLOG(@"MY POS: (%f,%f), END POS:(%f,%f)", myPos.x, myPos.y, endPos.x, endPos.y);
    
    if (movement.x != 0) {
        // check x boundary
        if (endPos.x > origin.x) {
            hitXBounds = (myPos.x >= endPos.x);
        } else {
            hitXBounds = (myPos.x <= endPos.x);
        }
    } else if (movement.y != 0) {
        // check y boundary
        if (endPos.y > origin.y) {
            hitYBounds = (myPos.y >= endPos.y);
        } else {
            hitYBounds = (myPos.y <= endPos.y);
        }
    }
    
    return hitXBounds || hitYBounds;
}

- (void) reset {
    moveFactor = fabsf(moveFactor);
    [self moveTo: origin];
}

-(void) moveTo:(CGPoint)pos {
    self.position = pos;
    
    body->SetTransform(b2Vec2((pos.x - ssipadauto(offset))/PTM_RATIO, (pos.y + ([ringFront boundingBox].size.height/2) - ([ringFront boundingBox].size.width/2) + ssipadauto(offset))/PTM_RATIO), 0);
    bottom->SetTransform(b2Vec2((pos.x - ssipadauto(offset))/PTM_RATIO, (pos.y - ([ringFront boundingBox].size.height/2) + ([ringFront boundingBox].size.width/2) - ssipadauto(offset))/PTM_RATIO), 0);
    
    ringFront.position = pos;
    ringBack.position = ccp(pos.x - ssipadauto(offset), pos.y-1);
    fire.position = ccp(pos.x - ssipadauto(offset), pos.y-1);
}

-(void) showAt:(CGPoint)pos {
    
    // Move the fire ring
    [self moveTo:pos];
    origin = pos;
    
    [self show];
}

- (void) hide {
    
    [ringFront setVisible:NO];
    [ringBack setVisible:NO];
    
    fire.visible = NO;
    [fire stopSystem];
    
    body->SetActive(NO);
    bottom->SetActive(NO);
}

- (void) show {
    
    [ringFront setVisible:YES];
    [ringBack setVisible:YES];
    
    //fire.visible = YES;
    //[fire resetSystem];
    
    body->SetActive(YES);
    bottom->SetActive(YES);
}

- (void) destroyPhysicsObject {
    if (world != NULL) {
        world->DestroyBody(body);
        world->DestroyBody(bottom);
    }
}

- (void) dealloc {
    // DO NOT DESTROY PHYSICS OBJECTS HERE!
    // SOMETHING WILL CALL destroyPhysicsObject
    
    CCLOG(@"------------------------------ Fire Ring being deallocated");
    [self stopAllActions];
    [self unscheduleAllSelectors];
    
    [ringFront removeFromParentAndCleanup:YES];
    [ringBack removeFromParentAndCleanup:YES];
    [fire removeFromParentAndCleanup:YES];
    
    [super dealloc];
}

- (void) setCollideWithPlayer:(BOOL)doCollide {
    if (doCollide) {
        topEdge->SetFilterData(collideWithPlayer);
        bottomEdge->SetFilterData(collideWithPlayer);
    } else {
        topEdge->SetFilterData(noCollideWithPlayer);
        bottomEdge->SetFilterData(noCollideWithPlayer);        
    }
}

- (CGPoint) getCatchPoint {
    return ccp(0,0);
}

- (float) getHeight {
    // Return the height of object (used for zoom)
    return ringFront.position.y + [ringFront boundingBox].size.height/2;
}

- (void) setSwingerVisible:(BOOL)visible {
    
}

@end
