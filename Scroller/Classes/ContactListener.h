//
//  ContactListener.h
//  Scroller
//
//  Created by min on 1/16/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import "Box2D.h"

class ContactListener : public b2ContactListener {
	CFTimeInterval startContactTime;
public:
	ContactListener();
	~ContactListener();
	
	virtual void BeginContact(b2Contact *contact);
	virtual void EndContact(b2Contact *contact);
	virtual void PreSolve(b2Contact *contact, const b2Manifold *oldManifold);
	virtual void PostSolve(b2Contact *contact, const b2ContactImpulse *impulse);
};