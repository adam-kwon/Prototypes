//
//  ContactListener.m
//  SwingProto
//
//  Created by James Sandoz on 3/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ContactListener.h"



ContactListener::ContactListener() {
}

ContactListener::~ContactListener() {
}


void ContactListener::BeginContact(b2Contact *contact) {
    
	CCNode *o1 = (CCNode*)contact->GetFixtureA()->GetBody()->GetUserData();
	CCNode *o2 = (CCNode*)contact->GetFixtureB()->GetBody()->GetUserData();
    
    CCLOG(@"BeginContact:  %@  %@\n", o1, o2);

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