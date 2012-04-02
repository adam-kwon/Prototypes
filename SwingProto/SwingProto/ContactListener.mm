//
//  ContactListener.m
//  SwingProto
//
//  Created by James Sandoz on 3/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactListener.h"
#import "Constants.h"

#import "SwingingRopeDude.h"
#import "JumpingDude.h"

#import "HelloWorldLayer.h"


#define IS_CATCHER(x,y)              ([x gameObjectType] == kGameObjectCatcher || [y gameObjectType] == kGameObjectCatcher)
#define IS_JUMPER(x,y)               ([x gameObjectType] == kGameObjectJumper || [y gameObjectType] == kGameObjectJumper)

#define GAMEOBJECT_OF_TYPE(class, type, o1, o2)    (class*)([o1 gameObjectType] == type ? o1 : o2)


ContactListener::ContactListener() {
}

ContactListener::~ContactListener() {
}

void ContactListener::handleCatcherJumperCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, void *userData) {
    CCLOG(@"In handleCatcherJumperCollision\n");
    
    SwingingRopeDude *catcher = GAMEOBJECT_OF_TYPE(SwingingRopeDude, kGameObjectCatcher, o1, o2);    
    ContactLocation where = kContactTop;
    if (userData != NULL) {
        where = *((ContactLocation *)userData);
    }
    [[HelloWorldLayer sharedLayer] catchJumper:catcher at:where];
}


void ContactListener::BeginContact(b2Contact *contact) {
    
	CCNode<GameObject> *o1 = (CCNode<GameObject>*)contact->GetFixtureA()->GetBody()->GetUserData();
	CCNode<GameObject> *o2 = (CCNode<GameObject>*)contact->GetFixtureB()->GetBody()->GetUserData();
    
    CCLOG(@"BeginContact:  %@  %@\n", o1, o2);
    
    if (IS_CATCHER(o1, o2) && IS_JUMPER(o1, o2)) {
        void *data = contact->GetFixtureA()->GetUserData();
        if ( data == NULL) {
            data = contact->GetFixtureB()->GetUserData();
        }
        this->handleCatcherJumperCollision(o1, o2, data);
    }
}

void ContactListener::EndContact(b2Contact *contact) {
    CCNode *o1 = (CCNode*)contact->GetFixtureA()->GetBody()->GetUserData();
	CCNode *o2 = (CCNode*)contact->GetFixtureB()->GetBody()->GetUserData();
    
    CCLOG(@"EndContact:  %@  %@\n", o1, o2);

}



void ContactListener::PreSolve(b2Contact *contact, const b2Manifold *oldManifold) {
}

void ContactListener::PostSolve(b2Contact *contact, const b2ContactImpulse *impulse) {
}