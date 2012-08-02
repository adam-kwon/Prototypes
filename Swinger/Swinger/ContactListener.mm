//
//  ContactListener.m
//  SwingProto
//
//  Created by James Sandoz on 3/16/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "ContactListener.h"
#import "Constants.h"

#import "CatcherGameObject.h"
#import "RopeSwinger.h"
#import "Player.h"
#import "Cannon.h"
#import "Spring.h"
#import "Star.h"
#import "Coin.h"
#import "AudioEngine.h"
#import "GamePlayLayer.h"
#import "Elephant.h"
#import "Wheel.h"
#import "FireRing.h"
#import "FinalPlatform.h"
#import "FloatingPlatform.h"

#define IS_CATCHER(x,y)                     ([x gameObjectType] == kGameObjectCatcher || [y gameObjectType] == kGameObjectCatcher)
#define IS_JUMPER(x,y)                      ([x gameObjectType] == kGameObjectJumper || [y gameObjectType] == kGameObjectJumper)
#define IS_GROUND(x,y)                      ([x gameObjectType] == kGameObjectGround || [y gameObjectType] == kGameObjectGround)
#define IS_FINAL_PLATFORM(x,y)              ([x gameObjectType] == kGameObjectFinalPlatform || [y gameObjectType] == kGameObjectFinalPlatform)
#define IS_FLOATING_PLATFORM(x,y)           ([x gameObjectType] == kGameObjectFloatingPlatform || [y gameObjectType] == kGameObjectFloatingPlatform)
#define IS_CANNON(x,y)                      ([x gameObjectType] == kGameObjectCannon || [y gameObjectType] == kGameObjectCannon)
#define IS_SPRING(x,y)                      ([x gameObjectType] == kGameObjectSpring || [y gameObjectType] == kGameObjectSpring)
#define IS_STAR(x,y)                        ([x gameObjectType] == kGameObjectStar || [y gameObjectType] == kGameObjectStar)
#define IS_COIN(x,y)                        (([x gameObjectType] == kGameObjectCoin || [y gameObjectType] == kGameObjectCoin) || ([x gameObjectType] == kGameObjectCoin5 || [y gameObjectType] == kGameObjectCoin5) || ([x gameObjectType] == kGameObjectCoin10 || [y gameObjectType] == kGameObjectCoin10))
#define IS_ELEPHANT(x,y)                    ([x gameObjectType] == kGameObjectElephant || [y gameObjectType] == kGameObjectElephant)
#define IS_WHEEL(x,y)                       ([x gameObjectType] == kGameObjectWheel || [y gameObjectType] == kGameObjectWheel)
#define IS_FIRE_RING(x,y)                   ([x gameObjectType] == kGameObjectFireRing || [y gameObjectType] == kGameObjectFireRing)

#define GAMEOBJECT_OF_TYPE(class, type, o1, o2)    (class*)([o1 gameObjectType] == type ? o1 : o2)


ContactListener::ContactListener() {
}

ContactListener::~ContactListener() {
}


void ContactListener::handleJumperStarCollison(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    Star *star = GAMEOBJECT_OF_TYPE(Star, kGameObjectStar, o1, o2);
    [star collect];
}

void ContactListener::handleJumperCoinCollison(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    Coin *coin = GAMEOBJECT_OF_TYPE(Coin, kGameObjectCoin, o1, o2);
    [coin collect];
}


void ContactListener::handleCatcherJumperCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    RopeSwinger *catcher = GAMEOBJECT_OF_TYPE(RopeSwinger, kGameObjectCatcher, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
//    ContactLocation where = kContactTop;
//    if (userData != NULL) {
//        where = *((ContactLocation *)userData);
//    }
    
    [jumper catchCatcher:catcher];
}

void ContactListener::handleJumperSpringCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    
    CCLOG(@"In handleJumperSpringCollision\n");
    
    Spring *spring = GAMEOBJECT_OF_TYPE(Spring, kGameObjectSpring, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    [jumper catchCatcher:spring];
}

void ContactListener::handleJumperWheelCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location) {
    
    CCLOG(@"In handleJumperWheelCollision\n");
    
    Wheel *wheel = GAMEOBJECT_OF_TYPE(Wheel, kGameObjectWheel, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    [jumper catchCatcher:wheel at: location];
}

void ContactListener::handleJumperFireRingCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    
    CCLOG(@"In handleJumperFireRingCollision\n");
    
    FireRing *ring = GAMEOBJECT_OF_TYPE(FireRing, kGameObjectFireRing, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    [jumper catchCatcher:ring];
}

void ContactListener::handleJumperFinalPlatformCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    FinalPlatform *fp = GAMEOBJECT_OF_TYPE(FinalPlatform, kGameObjectFinalPlatform, o1, o2);
    
    [jumper catchCatcher:fp];
}

void ContactListener::handleJumperGroundCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {    
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    // Only die when player has started jumping, else game will prematurely end
    // because the physics body will hit the ground before the mouse joint has
    // time to bring the bodies to their proper positions
    if ([jumper receivedFirstJumpInput] && jumper.state != kSwingerCrashed && jumper.state != kSwingerDizzy) {
        jumper.state = kSwingerCrashed;
    }
}

void ContactListener::handleJumperCannonCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    
    CCLOG(@"In handleJumperCannonCollision\n");
    
    Cannon *cannon = GAMEOBJECT_OF_TYPE(Cannon, kGameObjectCannon, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    [jumper catchCatcher:cannon];
}

void ContactListener::handleJumperElephantCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2) {
    
    CCLOG(@"In handleJumperElephantCollision\n");
    
    Elephant *elephant = GAMEOBJECT_OF_TYPE(Elephant, kGameObjectElephant, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    [jumper catchCatcher:elephant];
}

void ContactListener::handleJumperFloatingPlatformCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location) {
    
    CCLOG(@"In handleJumperFloatingPlatformCollision\n");
    
    FloatingPlatform *platform = GAMEOBJECT_OF_TYPE(FloatingPlatform, kGameObjectFloatingPlatform, o1, o2);
    Player *jumper = GAMEOBJECT_OF_TYPE(Player, kGameObjectJumper, o1, o2);
    
    [jumper catchCatcher:platform at: location];
}

void ContactListener::BeginContact(b2Contact *contact) {
    
	CCNode<GameObject> *o1 = (CCNode<GameObject>*)contact->GetFixtureA()->GetBody()->GetUserData();
	CCNode<GameObject> *o2 = (CCNode<GameObject>*)contact->GetFixtureB()->GetBody()->GetUserData();
    
    CCLOG(@"BeginContact:  %@(%d)  %@(%d)\n", o1, [o1 gameObjectType] , o2, [o2 gameObjectType]);
    
    b2Manifold* manifold = contact->GetManifold();
    b2Vec2 contactPoint = manifold->localPoint;
    
    //CCLOG(@"CONTACT POINT: %f, %f", contactPoint.x*PTM_RATIO, contactPoint.y*PTM_RATIO);

    if (IS_JUMPER(o1, o2)) {
        if (IS_CATCHER(o1, o2)) {
            this->handleCatcherJumperCollision(o1, o2);
        } else if (IS_GROUND(o1, o2)) {
            this->handleJumperGroundCollision(o1, o2);            
        } else if (IS_FINAL_PLATFORM(o1, o2)) {
            b2WorldManifold worldManifold;
            contact->GetWorldManifold(&worldManifold);
            b2Vec2 worldNormal = worldManifold.normal;
            CCLOG(@"*********************************************Worldnormalx greater 0 x=%f y=%f", worldNormal.x, worldNormal.y);
            
            if (worldNormal.y >= 0.9999) {
                CCLOG(@"Worldnormalx greater 0");
                this->handleJumperFinalPlatformCollision(o1, o2);
            }            
        } else if (IS_CANNON(o1, o2)) {
            this->handleJumperCannonCollision(o1, o2);            
        } else if (IS_SPRING(o1, o2)) {
            this->handleJumperSpringCollision(o1, o2);            
        } else if (IS_WHEEL(o1, o2)) {
            // get world location of collision                
            b2WorldManifold * worldManifold = new b2WorldManifold();
            contact->GetWorldManifold(worldManifold);
            b2Vec2 location = worldManifold->points[0];
            
            this->handleJumperWheelCollision(o1, o2, ccp(location.x*PTM_RATIO, location.y*PTM_RATIO));
        } else if (IS_STAR(o1, o2)) {
            this->handleJumperStarCollison(o1, o2);
        } else if (IS_COIN(o1, o2)) {
            this->handleJumperCoinCollison(o1, o2);
        } else if (IS_ELEPHANT(o1, o2)) {
            this->handleJumperElephantCollision(o1, o2);
        } else if (IS_FIRE_RING(o1, o2)) {
            this->handleJumperFireRingCollision(o1, o2);
        } else if (IS_FLOATING_PLATFORM(o1, o2)) {
            b2WorldManifold * worldManifold = new b2WorldManifold();
            contact->GetWorldManifold(worldManifold);
            b2Vec2 location = worldManifold->points[0];
            
            this->handleJumperFloatingPlatformCollision(o1, o2, ccp(location.x*PTM_RATIO, location.y*PTM_RATIO));
        }
    }    
}

void ContactListener::EndContact(b2Contact *contact) {
//  CCNode *o1 = (CCNode*)contact->GetFixtureA()->GetBody()->GetUserData();
//	CCNode *o2 = (CCNode*)contact->GetFixtureB()->GetBody()->GetUserData();
    
    //CCLOG(@"EndContact:  %@  %@\n", o1, o2);

}



void ContactListener::PreSolve(b2Contact *contact, const b2Manifold *oldManifold) {
//    b2WorldManifold worldManifold;
//    contact->GetWorldManifold(&worldManifold);
//    b2PointState state1[2], state2[2];
//    
//    b2GetPointStates(state1, state2, oldManifold, contact->GetManifold());
//    
//    if(state2[0] == b2_addState)
//    {
//        const b2Body* bodyA = contact->GetFixtureA()->GetBody();
//        const b2Body* bodyB = contact->GetFixtureB()->GetBody();
//        
//        b2Vec2 point = worldManifold.points[0];
//        b2Vec2 vA = bodyA->GetLinearVelocityFromWorldPoint(point);
//        b2Vec2 vB = bodyB->GetLinearVelocityFromWorldPoint(point);
//        
//        float32 approachVelocity = b2Dot(vB - vA, worldManifold.normal);
//        
//        CCLOG(@"VELOCITY A (%f,%f), VELOCITY B (%f,%f), APPROACH VELOCITY ON COLLISSION IS: %f", vA.x, vA.y, vB.x, vB.y, approachVelocity);
//    }
}

void ContactListener::PostSolve(b2Contact *contact, const b2ContactImpulse *impulse) {
}
