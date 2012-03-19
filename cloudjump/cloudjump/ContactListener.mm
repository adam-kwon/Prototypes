//
//  ContactListener.m
//  Scroller
//
//  Created by min on 1/16/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "ContactListener.h"
#import "Constants.h"
#import "GamePlayLayer.h"
#import "Player.h"

#define IS_PLAYER(x,y)              ([x gameObjectType] == kGameObjectPlayer || [y gameObjectType] == kGameObjectPlayer)
#define IS_ENERGY(x,y)              ([x gameObjectType] == kGameObjectEnergy || [y gameObjectType] == kGameObjectEnergy)

#define GAMEOBJECT_OF_TYPE(class, type, o1, o2)    (class*)([o1 gameObjectType] == type ? o1 : o2)

ContactListener::ContactListener() {
}

ContactListener::~ContactListener() {
}


void ContactListener::BeginContact(b2Contact *contact) {
	CCNode<GameObject> *o1 = (CCNode<GameObject>*)contact->GetFixtureA()->GetBody()->GetUserData();
	CCNode<GameObject> *o2 = (CCNode<GameObject>*)contact->GetFixtureB()->GetBody()->GetUserData();
    
    if (IS_PLAYER(o1, o2)) {
        if (IS_ENERGY(o1, o2)) {
            Player *player = GAMEOBJECT_OF_TYPE(Player, kGameObjectPlayer, o1, o2);
            player.state = kPlayerStateGotEnergy;
        }
    }
}

// EndContact is called when the contact end OR when the body is destroyed.
void ContactListener::EndContact(b2Contact *contact) {    
	CCNode<GameObject> *o1 = (CCNode<GameObject>*)contact->GetFixtureA()->GetBody()->GetUserData();
	CCNode<GameObject> *o2 = (CCNode<GameObject>*)contact->GetFixtureB()->GetBody()->GetUserData();    
}

void ContactListener::PreSolve(b2Contact *contact, const b2Manifold *oldManifold) {
}

void ContactListener::PostSolve(b2Contact *contact, const b2ContactImpulse *impulse) {
}