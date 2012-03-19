//
//  ContactListener.h
//  SwingProto
//
//  Created by James Sandoz on 3/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Box2D.h"
#import "cocos2d.h"

class ContactListener : public b2ContactListener {
    
public:

	ContactListener();
	~ContactListener();
    
    
	virtual void BeginContact(b2Contact *contact);
	virtual void EndContact(b2Contact *contact);
	virtual void PreSolve(b2Contact *contact, const b2Manifold *oldManifold);
	virtual void PostSolve(b2Contact *contact, const b2ContactImpulse *impulse);
};

