//
//  Coin.m
//  Swinger
//
//  Created by Min Kwon on 6/19/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Coin.h"
#import "GamePlayLayer.h"
#import "AudioEngine.h"
#import "GamePlayLayer.h"
#import "HUDLayer.h"
#import "Player.h"

@implementation Coin

- (id) initCoin: (GameObjectType) theType {
    self = [super init];
    if (self) {
        state = kCoinStateNone;
        type = theType;
        
        NSString * spriteFile = @"Coin1.png";
        NSString * animName = @"coinAnimation";
        
        if (type == kGameObjectCoin5) {
            spriteFile = @"Coin5_1.png";
            animName = @"coin5Animation";
        } else if (type == kGameObjectCoin10) {
            spriteFile = @"Coin10_1.png";
            animName = @"coin10Animation";
        }
        
        coin = [CCSprite spriteWithSpriteFrameName:spriteFile];
        [self addChild:coin];
        explosion = [ARCH_OPTIMAL_PARTICLE_SYSTEM particleWithFile:@"stars_version2.plist"];
        explosion.position = self.position; 
        explosion.visible = NO;    
        [explosion stopSystem];
        [self addChild:explosion];
        
        CCAnimate *action = [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:animName] restoreOriginalFrame:NO];
        CCRepeatForever *animAction = [CCRepeatForever actionWithAction:action];
        [coin runAction:animAction];
        
        startingPosition = ccp(0,0);
    }
    return self;
}

+ (id) make {
    return [self make: kGameObjectCoin];
}

+ (id) make: (GameObjectType) type {
    return [[[self alloc] initCoin: type] autorelease];
}


- (void) destroy {
    [self unschedule:@selector(destroy)];
    explosion.visible = NO;
    [explosion removeFromParentAndCleanup:YES];
    [coin removeFromParentAndCleanup:YES];
    [self safeToDelete];
    [[GamePlayLayer sharedLayer] addToDeleteList:self];
}

- (void) collect {
    // Don't collect if the player is dead
    if (state == kCoinStateNone && [[GamePlayLayer sharedLayer] getPlayer].state != kSwingerFalling) {
        state = kCoinStateCollecting;
        
        CCLOG(@"In coin.collect(), player state=%d\n", [[GamePlayLayer sharedLayer] getPlayer].state);

        [[HUDLayer sharedLayer] collectCoin:self];
    }
}

- (void) explode {
    if (state == kCoinStateNone || state == kCoinStateCollecting) {
        state = kCoinStateExploding;
        [[AudioEngine sharedEngine] playEffect:SND_BLOP];
        coin.visible = NO;
        explosion.visible = YES;
        [explosion resetSystem];
        [self schedule:@selector(hide) interval:0.7];
        
        int value = 1;
        
        if (type == kGameObjectCoin5) {
            value = 5;
        } else if (type == kGameObjectCoin10) {
            value = 10;
        }
        
        [[HUDLayer sharedLayer] addCoin:value];
    }
}

- (void) moveTo:(CGPoint)pos {
    self.position = pos;
    //CGPoint newPos = [coin.parent convertToWorldSpace:coin.position];
    //explosion.position = ccp(newPos.x + [coin boundingBox].size.width/2, newPos.y + [coin boundingBox].size.height/2);
    //explosion.position = newPos;
    //explosion.position = pos;
    body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
}

- (void) showAt:(CGPoint)pos {
    startingPosition = pos;
    [self moveTo:pos];
    [self show];
}

#pragma mark - PhysicsObject protocol
- (void) createPhysicsObject:(b2World *)theWorld {
    world = theWorld;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_kinematicBody;
    bodyDef.position.Set(coin.position.x/PTM_RATIO, coin.position.y/PTM_RATIO);
    bodyDef.userData = self;
    body = world->CreateBody(&bodyDef);
    
    
    b2CircleShape shape;
    shape.m_radius = ([coin boundingBox].size.width/2)/PTM_RATIO;
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    fixtureDef.density = 1.f;
    fixtureDef.friction = 5.3f;
    fixtureDef.isSensor = YES;
    fixtureDef.filter.categoryBits = CATEGORY_STAR; // Use same as star (intentional)
    fixtureDef.filter.maskBits = CATEGORY_JUMPER;
    body->CreateFixture(&fixtureDef);
}

- (void) destroyPhysicsObject {
    if (world != NULL) {
        world->DestroyBody(body);
    }
}

- (b2Body*) getPhysicsBody {
    return body;
}


#pragma mark - GameObject protocol
- (GameObjectType) gameObjectType {
    return type;
}

- (int) getValue {
    int value = 1;
    
    if (type == kGameObjectCoin5) {
        value = 5;
    } else if (type == kGameObjectCoin10) {
        value = 10;
    }
    
    return value;
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    if (state == kCoinStateCollecting && coin.visible == NO) {
        [self showAt:self.position];
    }
    
}

- (BOOL) isSafeToDelete {
    return isSafeToDelete;
}

- (void) safeToDelete {
    isSafeToDelete = YES;
}

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


- (void) show {
    CCLOG(@"  Coin.show for %@, state=%d\n", self, state);
    coin.visible = YES;
}

- (void) hide {
    [self unschedule:@selector(hide)];
    CCLOG(@"  Coin.hide for %@, state=%d\n", self, state);
    state = kCoinStateHidden;
    explosion.visible = NO;
    coin.visible = NO;
}

- (void) reset {
    CCLOG(@"  Coin.reset for %@, state=%d (setting to %d)\n", self, state, kCoinStateNone);
    state = kCoinStateNone;
    explosion.visible = NO;
    [self showAt:startingPosition];
}

- (void) dealloc {
    CCLOG(@"------------------------------ Coin being dealloced");
    [super dealloc];
}



@end
